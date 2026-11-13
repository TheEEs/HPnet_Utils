# frozen_string_literal: true

require 'uri'
require_relative './helpers/client_helpers'

module HPNET
  class Client
    include Helpers

    attr_accessor :current_session

    def login(username: '', password: '')
      body = LOGIN_BODY.merge(
        'Login1$UserName' => username,
        'Login1$Password' => password,
        **login_validation_tokens
      )
      res = HTTParty.post(login_url, headers: COMMON_HEADERS, body: body, follow_redirects: true)
      cookie = res.request.options.dig(:headers, 'Cookie')

      if res.success? && cookie&.match?(LOGIN_SUCCESS_REGEX)
        html_doc = Nokogiri.HTML5(res.body)
        display_name = html_doc.at_css('span#ctl09_hovaten')&.text.to_s.strip
        self.current_session = Session.new(cookie, display_name)
        return current_session
      end

      self.current_session = nil
    end

    def logged_in?
      !current_session&.cookie.to_s.strip.empty?
    end

    def logout
      self.current_session = nil
      @leaders = nil
      @workers = nil
      @vanthu_id = nil
      @upload_validation_tokens = nil
      @approve_validation_tokens = nil
      true
    end

    def display_name
      current_session&.display_name
    end

    def leaders(force_update: false)
      return unless logged_in?

      @leaders = nil if force_update
      @leaders ||= begin
        headers = authenticated_headers
        res = HTTParty.get(upload_url, headers: headers)
        return if res.body.match?(EXPIRED_SESSION_REGEX)

        html_doc = Nokogiri.HTML5(res.body)
        html_doc.css('select#drpLanhDao option').filter_map do |option|
          val = option.values.join('').strip
          next if val.empty?

          { name: option.text.strip, value: val }
        end
      end
    end

    def upload(file_path, to: nil, title: nil)
      return unless current_session && File.file?(file_path)

      File.open(file_path) do |file|
        body = UPLOAD_BODY.merge(
          'txtTrichYeu' => title,
          'drpLanhDao' => to,
          'txtFileTrinh' => file,
          **upload_validation_tokens
        )
        res = HTTParty.post(upload_url, headers: authenticated_headers, body: body)
        res.success?
      end
    end

    def get_arrived_documents(doc_number: 500)
      return unless current_session

      res = HTTParty.post(arrived_documents_url(doc_number: doc_number),
                          headers: authenticated_headers,
                          body: GET_ARRIVED_DOCUMENTS_REQUEST_BODY)
      data = JSON.parse(res.body)
      data.fetch('Records', []).flatten
    end

    def workers(force_update: false)
      return unless logged_in?

      @workers = nil if force_update
      @workers ||= begin
        docs = get_arrived_documents(doc_number: 1)
        return [] unless (first_doc = docs&.first)

        res = HTTParty.get(assign_document_url(document_id: first_doc['VanbanDenId']),
                           headers: authenticated_headers)
        html_doc = Nokogiri.HTML5(res.body)
        user_id_elements = html_doc.css('td:has(> input[type="hidden"][name^="repChuyenVien"][name$="userId"])')

        user_id_elements.filter_map do |e|
          input = e.at_css('input[name$="userId"]')
          next unless input

          Worker.new(e.text.strip, input.attr('name'), input.attr('value'))
        end
      end
    end

    def build_assign_workers_form_params(main_worker: nil, cooperative_workers: nil, notify_workers: nil)
      result = {}
      result.merge!(main_worker.main_worker) if main_worker.is_a?(Worker)

      if cooperative_workers.is_a?(Array) && cooperative_workers.all?(Worker)
        result.merge!(cooperative_workers.map(&:cooperative_on).reduce({}, :merge))
      end

      if notify_workers.is_a?(Array) && notify_workers.all?(Worker)
        result.merge!(notify_workers.map(&:notify_on).reduce({}, :merge))
      end

      result
    end

    def get_uploaded_documents(filter: nil)
      return unless logged_in?

      body = GET_UPLOADED_DOCUMENTS_REQUEST_BODY.merge('key' => filter.to_s)
      encoded_body = URI.encode_www_form(body).gsub('+', '%20')
      res = HTTParty.post(uploaded_documents_url(doc_number: 500),
                          headers: authenticated_headers,
                          body: encoded_body)
      data = JSON.parse(res.body)
      data.fetch('Records', []).flatten
    end

    def approve_document(document_id: nil, lanhdao_id: nil)
      return unless logged_in? && document_id && lanhdao_id

      @vanthu_id ||= workers.find { |w| w.name.match?(VANTHU_REGEX) }&.id
      raise ClericalAssistantNotFound, 'Không tìm thấy tài khoản văn thư' unless @vanthu_id

      body = APPROVE_DOCUMENT_REQUEST_BODY.merge(
        **approve_validation_tokens,
        'dataLanhdaoId' => lanhdao_id,
        'drpVanthuId' => @vanthu_id
      )
      res = HTTParty.post(approve_document_url(document_id: document_id),
                          headers: authenticated_headers,
                          body: body,
                          multipart: true)
      res.success?
    end

    private

    def authenticated_headers
      COMMON_HEADERS.merge('Cookie' => current_session&.cookie.to_s)
    end

    def extract_asp_tokens(html_doc)
      return {} unless html_doc

      {
        '__VIEWSTATE' => html_doc.at_css('input#__VIEWSTATE')&.attr('value'),
        '__VIEWSTATEGENERATOR' => html_doc.at_css('input#__VIEWSTATEGENERATOR')&.attr('value'),
        '__EVENTVALIDATION' => html_doc.at_css('input#__EVENTVALIDATION')&.attr('value')
      }
    end

    def login_validation_tokens
      login_page { |doc| extract_asp_tokens(doc) } || {}
    end

    def upload_validation_tokens(force_update: false)
      if force_update || !@upload_validation_tokens
        @upload_validation_tokens = upload_page { |doc| extract_asp_tokens(doc) }
      end
      @upload_validation_tokens
    end

    alias validation_tokens upload_validation_tokens

    def approve_validation_tokens(force_update: false)
      if force_update || !@approve_validation_tokens
        @approve_validation_tokens = approve_page { |doc| extract_asp_tokens(doc) }
      end
      @approve_validation_tokens
    end

    def login_page
      return if logged_in?

      res = HTTParty.get(login_url, headers: COMMON_HEADERS)
      html_doc = Nokogiri.HTML5(res.body)
      yield html_doc if block_given?
    end

    def upload_page
      return unless logged_in?

      res = HTTParty.get(upload_url, headers: authenticated_headers)
      return if res.body.match?(EXPIRED_SESSION_REGEX)

      html_doc = Nokogiri.HTML5(res.body)
      yield html_doc if block_given?
    end

    def approve_page
      return unless logged_in?

      docs = get_uploaded_documents
      return unless (doc = docs&.sample)

      res = HTTParty.get(approve_page_url(document_id: doc['VanbanDiId']), headers: authenticated_headers)
      return if res.body.match?(EXPIRED_SESSION_REGEX)

      html_doc = Nokogiri.HTML5(res.body)
      yield html_doc if block_given?
    end
  end
end
