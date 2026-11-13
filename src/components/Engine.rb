# frozen_string_literal: true

require 'async/semaphore'
require_relative './Client'
require_relative './CredentialStore'
require_relative './PDFConverter'
require_relative './Summarizer'
require_relative '../components/helpers/engine_helpers'

module HPNET
  class Engine
    include HPNET::Engine::Helpers
    attr_reader :client

    def launch(username: nil, password: nil)
      @client = HPNET::Client.new

      creds = CredentialStore.load
      user = username || ENV['USER_NAME'] || creds&.[](:username)
      pass = password || ENV['PASSWORD'] || creds&.[](:password)

      if user.to_s.strip.empty? || pass.to_s.empty?
        yield false if block_given?
        return false
      end

      client.login(username: user, password: pass)
      yield client.logged_in? if block_given?
      client.logged_in?
    end

    def login(username, password, remember: true)
      @client ||= HPNET::Client.new
      client.login(username: username, password: password)
      if client.logged_in?
        if remember
          CredentialStore.save(username, password)
        else
          CredentialStore.clear
        end
        true
      else
        false
      end
    end

    def logout(clear_saved: true)
      CredentialStore.clear if clear_saved
      client&.logout
    end

    def approve(filter: nil, lanhdao_id: nil)
      docs = client.get_uploaded_documents(filter: filter) || []
      return if docs.empty?

      Sync do
        semaphore = Async::Semaphore.new(20)
        docs.each do |doc|
          semaphore.async do
            doc_id = doc['VanbanDiId']
            res = client.approve_document(document_id: doc_id, lanhdao_id: lanhdao_id)
            yield res, doc, docs if block_given?
          end
        end
      end
    end

    def upload(upload_dir, lanhdao_id: nil, how_we_should_set_title_of_document: nil, manual_title: nil)
      upload_dir = "#{upload_dir}".force_encoding('utf-8')
      return unless upload_dir && Dir.exist?(upload_dir) && lanhdao_id && !how_we_should_set_title_of_document.nil?

      upload_dir = upload_dir.tr('\\', '/')
      files = Dir.glob(File.join(upload_dir, '*.{doc,docx,DOC,DOCX}'), File::FNM_CASEFOLD).select { |f| File.file?(f) }
      return if files.empty?

      Sync do
        semaphore = Async::Semaphore.new(5)
        files.each do |file|
          semaphore.async do
            upload_file = convert_to_pdf_if_possible(file)
            title = resolve_title(
              file: file,
              upload_file: upload_file,
              mode: how_we_should_set_title_of_document,
              manual_title: manual_title
            )

            res = client.upload(upload_file, to: lanhdao_id, title: title)
            yield res, file, files if block_given?
          end
        end
      end
    end

    private

    def convert_to_pdf_if_possible(file)
      return file if file.end_with?('.pdf')

      PDFConverter.convert(file)
    rescue StandardError
      file
    end

    def resolve_title(file:, upload_file:, mode:, manual_title:)
      case mode
      when TitleMode::MANUAL
        manual_title.to_s.strip.empty? ? File.basename(file, '.*') : manual_title.to_s.strip
      when TitleMode::FROM_FILE_PATH
        Summarizer.file_summarize(file)
      when TitleMode::AI
        resolve_ai_title(file, upload_file)
      else
        File.basename(file, '.*')
      end
    end

    def resolve_ai_title(file, upload_file)
      target_for_ai = upload_file.end_with?('.pdf') ? upload_file : file
      res = Summarizer.ai_summarize(target_for_ai)
      summary = Summarizer::SummarySchema.from_hash(res.parsed)
      ai_title = summary.title.to_s.strip

      ai_title.empty? ? File.basename(file, '.*') : ai_title
    rescue StandardError
      File.basename(file, '.*')
    end
  end
end
