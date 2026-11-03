require_relative "./Client"
require_relative "../components/helpers/engine_helpers"
require "async/semaphore"

module HPNET
  class Engine
    include HPNET::Engine::Helpers
    attr_reader :client

    def launch
      @client = HPNET::Client.new
      client.login(username: ENV['USER_NAME'], password: ENV['PASSWORD'])
      yield client.logged_in? if block_given?
    end

    def approve(filter: nil, lanhdao_id: nil)
      Sync do
        semaphore = Async::Semaphore.new(20)
        docs = client.get_uploaded_documents(filter: filter)
        docs.each do |doc|
          semaphore.async do
            doc_id = doc["VanbanDiId"]
            res = client.approve_document(document_id: doc_id, lanhdao_id: lanhdao_id)
            yield res, doc, docs if block_given?
          end
        end
      end
    end

    def upload(upload_dir, lanhdao_id: nil, how_we_should_set_title_of_document: nil)
      upload_dir = upload_dir&.force_encoding("utf-8")
      return unless Dir.exist?(upload_dir) and lanhdao_id and how_we_should_set_title_of_document
      upload_dir.tr!("\\", "/")
      
      Sync do
        yield if block_given?
      end
    end
  end
end
