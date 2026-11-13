# frozen_string_literal: true

module HPNET
  class Client
    module Helpers
      class UnauthorizedException < StandardError; end
      class ClericalAssistantNotFound < StandardError; end

      ROOT_URL = 'https://qlvb.hpnet.vn'

      LOGIN_SUCCESS_REGEX = /ASPXAUTH|ASPXFORMSAUTH/
      EXPIRED_SESSION_REGEX = /đăng nhập lại/i
      VANTHU_REGEX = /văn thư/i
      WORKER_KEY_REGEX = /userId$/

      COMMON_HEADERS = {
        'User-Agent' => 'Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0',
        'Content-Type' => 'application/x-www-form-urlencoded',
        'Origin' => ROOT_URL,
        'Referer' => "#{ROOT_URL}/style/qlvb2013/Login.aspx?ReturnURL=#{ROOT_URL}/default.aspx"
      }.freeze

      LOGIN_BODY = {
        '__EVENTTARGET' => '',
        '__EVENTARGUMENT' => '',
        'Login1$Login' => 'Đăng nhập'
      }.freeze

      UPLOAD_BODY = {
        '__VIEWSTATE' => '',
        '__VIEWSTATEGENERATOR' => '',
        '__EVENTVALIDATION' => '',
        'drpDokhan' => '09b49493-9cba-4ead-bb04-9080aac6b8af',
        'txtTrichYeu' => '',
        'drpLanhDao' => '',
        'txtVanbanDen' => '',
        'txtYkien' => '',
        'txtFilePhieutrinh' => '',
        'txtFileTrinh' => nil,
        'txtFilePhieutrinhConverted' => '',
        'btnUpdate' => 'Cập nhật'
      }.freeze

      GET_ARRIVED_DOCUMENTS_REQUEST_BODY = {
        'all' => 'false',
        'key' => '',
        'status' => '18',
        'sokyhieu' => '',
        'trichyeu' => '',
        'coquan' => ''
      }.freeze

      GET_UPLOADED_DOCUMENTS_REQUEST_BODY = {
        'key' => '',
        'all' => 'false',
        'status' => '1'
      }.freeze

      APPROVE_DOCUMENT_REQUEST_BODY = {
        '__VIEWSTATE' => '',
        '__VIEWSTATEGENERATOR' => '',
        '__EVENTVALIDATION' => '',
        'txtYkienDuthao' => '',
        'txtFileDuthao' => nil,
        'dataLanhdaoId' => '',
        'drpNguoikyId' => '',
        'drpVanthuId' => '',
        'txtFileConverted' => nil,
        'txtFilePhieutrinhConverted' => nil,
        'btnDuyenTrinh' => 'Duyệt trình'
      }.freeze

      class Worker < Struct.new(:name, :key, :id)
        def cooperative_on
          { key.gsub(WORKER_KEY_REGEX, 'chkPhoihop') => 'on' }
        end

        def notify_on
          { key.gsub(WORKER_KEY_REGEX, 'chkThongbao') => 'on' }
        end

        def main_worker
          { 'radChuyenVien' => id }
        end
      end

      Session = Struct.new(:cookie, :display_name)

      def login_url
        "#{ROOT_URL}/style/qlvb2013/Login.aspx?ReturnURL=https%3a%2f%2fqlvb.hpnet.vn%2fdefault.aspx"
      end

      def upload_url
        "#{ROOT_URL}/vpdt/dungchung/DuthaoVanbanQuanhuyenV2/DuthaoVanbandi.aspx"
      end

      def arrived_documents_url(doc_number: 5)
        "#{ROOT_URL}/vpdt/xaphuong/VanbanDenTruongPhong.aspx?jtPageSize=#{doc_number}"
      end

      def assign_document_url(document_id: nil)
        "#{ROOT_URL}/vpdt/xaphuong/TruongPhongGiaoviecVBDen.aspx?VanbanDenId=#{document_id}"
      end

      def uploaded_documents_url(doc_number: 5)
        "#{ROOT_URL}/vpdt/dungchung/DuthaoVanbanQuanhuyenV2/VanbanDiListDuthao.aspx?jtStartIndex=0&jtPageSize=#{doc_number}"
      end

      def approve_document_url(document_id: nil)
        "#{ROOT_URL}/vpdt/dungchung/DuthaoVanbanQuanhuyenV2/VanbanDuthaoView.aspx?VanbanDiId=#{document_id}"
      end

      alias approve_page_url approve_document_url
    end
  end
end
