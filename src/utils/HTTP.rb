require "httparty"
require "nokogiri"

module HPNET
  module Utils
    LOGIN_SUCCESS_REGEX = /ASPXAUTH|ASPXFORMSAUTH/
    ORIGIN = "https://qlvb.hpnet.vn"
    LOGIN_URL = 'https://qlvb.hpnet.vn/style/qlvb2013/Login.aspx?ReturnURL=https%3a%2f%2fqlvb.hpnet.vn%2fdefault.aspx'
    LOGIN_HEADERS = {
      'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0',
      'Content-Type': 'application/x-www-form-urlencoded',
      'Origin': 'https://qlvb.hpnet.vn',
      'Referer': 'https://qlvb.hpnet.vn/style/qlvb2013/Login.aspx?ReturnURL=https://qlvb.hpnet.vn/default.aspx'
    }
    def login_body(username: "", password: "")
      {
        '__EVENTTARGET' => '',
        '__EVENTARGUMENT' => '',
        '__VIEWSTATE' => 'OzB0Tiqetl10GgwLFoAU8Lziur1tnI5gqVDCoVDAHdUt5Ayp23byZEPAXVXfIpor6DZGQSVKaWy3VwiSO7tmi4ngMhaG7u64sGuHleqVcnVwh2qeqygOcoBtd38A6ks38C5/Y+Pe/vWoa0bI9B9+zOSwpiy92l5KQkLsrVKzVkd9Mou2TQ7kUnXwuDXjbJFG8qjUeRlRYUwUj9NuzbCj6FZoHLCUD2MEJD4bHkbqMd9BD61po3mCCdIkvBgj3n7pbGYUpRpqBEYP6qEeyQ5mXgNmdG0=',
        '__VIEWSTATEGENERATOR' => '9EC021CD',
        '__EVENTVALIDATION' => 'Ot1MAI5VgTW/YpxgZFXFS8y1ZTT4vEYTVCCdOWUWq9A1GQ5XBjbeBOWDXgtsRqpogDMolx8sk2Ynwg/kLo75+B7wdeidbx4bzzFU+C8xbsKAf8K0SGCnOkpP+2NaBvfrYhcLqzKy7dgDSwduFjoZbd+IyKM5+pTiGgPIETFeFfe27P4UaaOB5M0XGd197oJEJHYFsA==',
        'Login1$UserName' => username,
        'Login1$Password' => password,
        'Login1$Login' => 'Đăng nhập'
      }
    end

    def login(username: "", password: "")
      res = HTTParty.post(LOGIN_URL, headers: LOGIN_HEADERS, body: login_body(username: username, password: password),
                                     follow_redirects: true)
      if res.success? and res.request.options[:headers]["Cookie"]&.match? LOGIN_SUCCESS_REGEX
        File.write(".cookie", res.request.options[:headers]["Cookie"])
        return res
      end
      return nil
    end

    EXPIRED_SESSION_REGEX = /đăng nhập lại/i
    UPLOAD_PAGE_URL = "https://qlvb.hpnet.vn/vpdt/dungchung/DuthaoVanbanQuanhuyenV2/DuthaoVanbandi.aspx"
    UPLOAD_PAGE_HEADERS = {
      'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0',
      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      'Accept-Language': 'en-US,en;q=0.9',
      #   'Accept-Encoding': 'gzip, deflate, br, zstd',
      'Sec-GPC': '1',
      'Connection': 'keep-alive',
      'Upgrade-Insecure-Requests': '1',
      'Sec-Fetch-Dest': 'document',
      'Sec-Fetch-Mode': 'navigate',
      'Sec-Fetch-Site': 'none',
      'Sec-Fetch-User': '?1',
      'Priority': 'u=0, i',
    }
    def extract_get_leaders
      cookie = File.read(".cookie").strip rescue ""
      return if cookie.empty?

      UPLOAD_PAGE_HEADERS["Cookie"] = cookie
      res = HTTParty.get UPLOAD_PAGE_URL, headers: UPLOAD_PAGE_HEADERS
      return if res.body.match? EXPIRED_SESSION_REGEX

      html_doc = Nokogiri.HTML5(res.body)
      html_doc.css("select#drpLanhDao option").to_a.map! do |a|
        {
          name: a.text.strip,
          value: a.values.join("")
        }
      end.select! { |a| !a[:value].empty? }
    end

    def extract_validation_tokens
      cookie = File.read(".cookie").strip rescue ""
      return if cookie.empty?

      UPLOAD_PAGE_HEADERS["Cookie"] = cookie
      res = HTTParty.get UPLOAD_PAGE_URL, headers: UPLOAD_PAGE_HEADERS
      return if res.body.match? EXPIRED_SESSION_REGEX

      html_doc = Nokogiri.HTML5(res.body)
      {
        view_state: html_doc.css("input#__VIEWSTATE")&.attr('value')&.value,
        viewstate_generator: html_doc.css('input#__VIEWSTATEGENERATOR')&.attr('value')&.value,
        event_validation: html_doc.css('input#__EVENTVALIDATION')&.attr('value')&.value
      }
    end

    UPLOAD_URL = 'https://qlvb.hpnet.vn/vpdt/dungchung/DuthaoVanbanQuanhuyenV2/DuthaoVanbandi.aspx'
    UPLOAD_HEADERS = {
      'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0',
      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      'Accept-Language': 'en-US,en;q=0.9',
      # 'Accept-Encoding': 'gzip, deflate, br, zstd',
      # 'Content-Type': 'multipart/form-data; boundary=----geckoformboundary6c9f8d981cc784421ca8bebf20be1e7f',
      'Origin': 'https://qlvb.hpnet.vn',
      'Connection': 'keep-alive',
      'Referer': 'https://qlvb.hpnet.vn/vpdt/dungchung/DuthaoVanbanQuanhuyenV2/DuthaoVanbandi.aspx',
      'Cookie': '',
      'Upgrade-Insecure-Requests': '1',
      'Sec-Fetch-Dest': 'iframe',
      'Sec-Fetch-Mode': 'navigate',
      'Sec-Fetch-Site': 'same-origin',
      'Sec-Fetch-User': '?1',
      'Priority': 'u=4',
      'TE': 'trailers',
    }

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
    def upload(file_path, to: "", title: '', cookie: '', token: extract_validation_tokens)
      return if cookie.empty?

      UPLOAD_HEADERS["Cookie"] = cookie
      UPLOAD_BODY["txtTrichYeu"] = title
      UPLOAD_BODY["drpLanhDao"] = to
      UPLOAD_BODY["txtFileTrinh"] = File.open(file_path)
      UPLOAD_BODY["__VIEWSTATE"] = token[:view_state]
      UPLOAD_BODY["__VIEWSTATEGENERATOR"] = token[:viewstate_generator]
      UPLOAD_BODY["__EVENTVALIDATION"] = token[:event_validation]
      res = HTTParty.post UPLOAD_URL, headers: UPLOAD_HEADERS, body: UPLOAD_BODY
    end
  end
end
