require_relative "./Client"
module HPNET
  class Engine
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
            yield res if block_given?
          end
        end
      end
    end
  end
end
