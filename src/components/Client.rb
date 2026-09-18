# frozen_string_literal: true

require_relative "./helpers/client_helpers"
module HPNET
  class Client
    include Helpers

    attr_accessor :current_session

    def login(username: '', password: '')
      body = LOGIN_BODY.merge('Login1$UserName' => username,
                              'Login1$Password' => password)
      res = HTTParty.post(login_url, headers: COMMON_HEADERS, body:, follow_redirects: true)
      if res.success? and res.request.options[:headers]["Cookie"]&.match? LOGIN_SUCCESS_REGEX
        html_doc = Nokogiri.HTML5(res.body)
        display_name = html_doc.css("span#ctl09_hovaten").text
        self.current_session = Session.new(cookie: res.request.options[:headers]["Cookie"], display_name:)
        return self.current_session
      end
      self.current_session = nil
      return nil
    end

    def logged_in? = not (self.current_session.cookie.to_s.empty? rescue true)

    def leaders
      return unless self.current_session

      headers = COMMON_HEADERS.merge("Cookie" => self.current_session.cookie)
      res = HTTParty.get upload_url, headers: headers
      return if res.body.match? EXPIRED_SESSION_REGEX

      html_doc = Nokogiri.HTML5(res.body)
      yield html_doc if block_given?
      html_doc.css("select#drpLanhDao option").to_a.map! do |a|
        {
          name: a.text.strip,
          value: a.values.join("")
        }
      end.select! { |a| !a[:value].empty? }
    end

    alias upload_page leaders

    def upload(file_path, to: nil, title: nil)
      return unless self.current_session && File.file?(file_path)

      File.open(file_path) do |f|
        headers = COMMON_HEADERS.merge(
          "Cookie" => self.current_session.cookie
        )
        body = UPLOAD_BODY.merge(
          "txtTrichYeu" => title,
          "drpLanhDao" => to,
          "txtFileTrinh" => f,
          **self.validation_tokens
        )
        res = HTTParty.post(upload_url, headers:, body:)
        res.success?
      end
    end

    def get_arrived_documents(doc_number: 500)
      return unless self.current_session

      headers = COMMON_HEADERS.merge(
        "Cookie" => self.current_session.cookie
      )
      res = HTTParty.post(arrived_documents_url(doc_number:), headers:, body: GET_ARRIVED_DOCUMENTS_REQUEST_BODY)
      res = JSON.parse(res.body)
      fetched_documents = res["Records"].flatten
    end

    def workers
      return unless self.current_session

      @workers ||= begin
        headers = COMMON_HEADERS.merge(
          "Cookie" => self.current_session.cookie
        )
        docs = self.get_arrived_documents(doc_number: 1)
        res = HTTParty.get(assign_document_url(document_id: docs.first["VanbanDenId"]), headers:)
        html_doc = Nokogiri::HTML5(res.body)
        user_id_elements = html_doc.css('td:has(> input[type="hidden"][name^="repChuyenVien"][name$="userId"])')
        user_id_elements.map do |e|
          Worker.new(name: e.text.strip, key: e.children[1].attr("name"),
                     id: e.children[1].attr("value"))
        end
      end
    end

    def build_assign_workers_form_params(main_worker: nil, cooperative_workers: nil, notify_workers: nil)
      result = {}
      if main_worker.is_a? Worker
        result.merge! main_worker.main_worker
      end
      if cooperative_workers.is_a?(Array) and cooperative_workers.all?(Worker)
        result.merge! cooperative_workers.reduce({}) { |r, v| r.merge!(v.cooperative_on) }
      end
      if notify_workers.is_a?(Array) and notify_workers.all?(Worker)
        result.merge! notify_workers.reduce({}) { |r, v| r.merge!(v.notify_on) }
      end
      result
    end

    private

    def validation_tokens(force_update: false)
      if force_update or !@validation_tokens
        @validation_tokens = upload_page do |html_doc|
          break {
            "__VIEWSTATE" => html_doc.css("input#__VIEWSTATE")&.attr('value')&.value,
            "__VIEWSTATEGENERATOR" => html_doc.css('input#__VIEWSTATEGENERATOR')&.attr('value')&.value,
            "__EVENTVALIDATION" => html_doc.css('input#__EVENTVALIDATION')&.attr('value')&.value
          }
        end
      end
      @validation_tokens
    end
  end
end
