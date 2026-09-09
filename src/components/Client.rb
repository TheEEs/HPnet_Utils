module HPNET
  class Client
    module Helpers
      def login_url = ROOT_URL + "/style/qlvb2013/Login.aspx?ReturnURL=https%3a%2f%2fqlvb.hpnet.vn%2fdefault.aspx"
      def upload_url = ROOT_URL + "/vpdt/dungchung/DuthaoVanbanQuanhuyenV2/DuthaoVanbandi.aspx"
    end

    LOGIN_SUCCESS_REGEX = /ASPXAUTH|ASPXFORMSAUTH/
    EXPIRED_SESSION_REGEX = /đăng nhập lại/i

    Session = Struct.new :cookie, :display_name

    attr_accessor :current_session

    include Helpers

    ROOT_URL = "https://qlvb.hpnet.vn"

    COMMON_HEADERS = {
      'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0',
      'Content-Type': 'application/x-www-form-urlencoded',
      'Origin': 'https://qlvb.hpnet.vn',
      'Referer': 'https://qlvb.hpnet.vn/style/qlvb2013/Login.aspx?ReturnURL=https://qlvb.hpnet.vn/default.aspx'
    }

    LOGIN_BODY = {
      '__EVENTTARGET' => '',
      '__EVENTARGUMENT' => '',
      '__VIEWSTATE' => 'OzB0Tiqetl10GgwLFoAU8Lziur1tnI5gqVDCoVDAHdUt5Ayp23byZEPAXVXfIpor6DZGQSVKaWy3VwiSO7tmi4ngMhaG7u64sGuHleqVcnVwh2qeqygOcoBtd38A6ks38C5/Y+Pe/vWoa0bI9B9+zOSwpiy92l5KQkLsrVKzVkd9Mou2TQ7kUnXwuDXjbJFG8qjUeRlRYUwUj9NuzbCj6FZoHLCUD2MEJD4bHkbqMd9BD61po3mCCdIkvBgj3n7pbGYUpRpqBEYP6qEeyQ5mXgNmdG0=',
      '__VIEWSTATEGENERATOR' => '9EC021CD',
      '__EVENTVALIDATION' => 'Ot1MAI5VgTW/YpxgZFXFS8y1ZTT4vEYTVCCdOWUWq9A1GQ5XBjbeBOWDXgtsRqpogDMolx8sk2Ynwg/kLo75+B7wdeidbx4bzzFU+C8xbsKAf8K0SGCnOkpP+2NaBvfrYhcLqzKy7dgDSwduFjoZbd+IyKM5+pTiGgPIETFeFfe27P4UaaOB5M0XGd197oJEJHYFsA==',
      'Login1$Login' => 'Đăng nhập'
    }

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
      return nil
    end

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

    UPLOAD_BODY = {
      "__VIEWSTATE" => '',
      "__VIEWSTATEGENERATOR" => '',
      "__EVENTVALIDATION" => '',
      'drpDokhan' => '09b49493-9cba-4ead-bb04-9080aac6b8af',
      'txtTrichYeu' => '',
      'drpLanhDao' => '',
      'txtVanbanDen' => '',
      'txtYkien' => '',
      'txtFilePhieutrinh' => '',
      'txtFileTrinh' => nil,
      'txtFilePhieutrinhConverted' => '',
      'btnUpdate' => "Cập nhật"
    }
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
  end
end
