# frozen_string_literal: true

module HPNET
  class Client
    module Helpers
      LOGIN_SUCCESS_REGEX = /ASPXAUTH|ASPXFORMSAUTH/
      EXPIRED_SESSION_REGEX = /đăng nhập lại/i
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
      Session = Struct.new :cookie, :display_name

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

      GET_ARRIVED_DOCUMENTS_REQUEST_BODY = {
        'all' => 'false',
        'key' => '',
        'status' => '18',
        'sokyhieu' => '',
        'trichyeu' => '',
        'coquan' => ''
      }

      def login_url = ROOT_URL + "/style/qlvb2013/Login.aspx?ReturnURL=https%3a%2f%2fqlvb.hpnet.vn%2fdefault.aspx"

      def upload_url = ROOT_URL + "/vpdt/dungchung/DuthaoVanbanQuanhuyenV2/DuthaoVanbandi.aspx"

      def arrived_documents_url(doc_number: 5)
        ROOT_URL + "/vpdt/xaphuong/VanbanDenTruongPhong.aspx?jtPageSize=#{doc_number}"
      end

      def assign_document_url(document_id: nil)
        ROOT_URL + "/vpdt/xaphuong/TruongPhongGiaoviecVBDen.aspx?VanbanDenId=#{document_id}"
      end

      WORKER_KEY_REGEX = /userId$/
      Worker = Struct.new :name, :key, :id
      Worker.class_eval do
        def cooperative_on
          { "#{key.gsub(WORKER_KEY_REGEX, "chkPhoihop")}" => "on" }
        end

        def notify_on
          { "#{key.gsub(WORKER_KEY_REGEX, "chkThongbao")}" => "on" }
        end

        def main_worker
          { 'radChuyenVien' => self.id }
        end
      end
    end
  end
end
