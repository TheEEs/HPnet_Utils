# frozen_string_literal: true

require "test_helper"
require "minitest/autorun"
require_relative "../src/components/Client.rb"

class ClientTest < Minitest::Test
  attr_reader :username, :password, :client

  class MockClient < HPNET::Client
    def upload(file_path, to: nil, title: nil)
      return unless self.current_session && File.file?(file_path)

      true
    end
  end

  def setup
    @client = MockClient.new
    @username = ENV['USER_NAME']
    @password = ENV['PASSWORD']
  end

  def test_login_success
    session = client_login_success
    assert_instance_of HPNET::Client::Session, session
    refute_empty session.display_name.to_s
  end

  def test_login_fail
    session = client.login(username: username, password: "wrong password")
    assert_nil session
  end

  def test_get_leaders_success
    session = client_login_success
    assert_instance_of HPNET::Client::Session, session

    leaders = client.leaders
    assert_kind_of Array, leaders
    refute_empty leaders

    leaders.each do |leader|
      assert_kind_of Hash, leader
      refute_nil leader[:name]
      refute_nil leader[:value]
      refute_empty leader[:name]
      refute_empty leader[:value]
    end
  end

  def test_get_leaders_fail
    client.login(username: username, password: "wrong password")
    leaders = client.leaders
    assert_nil leaders
  end

  def test_validation_tokens_success
    session = client_login_success
    assert_instance_of HPNET::Client::Session, session

    tokens = client.instance_eval do
      break validation_tokens
    end
    assert_kind_of Hash, tokens

    refute_nil tokens["__VIEWSTATE"]
    refute_nil tokens["__VIEWSTATEGENERATOR"]
    refute_nil tokens["__EVENTVALIDATION"]
  end

  def test_validation_tokens_fail
    # When not logged in, should return nil
    assert_nil client.instance_eval { validation_tokens }
  end

  def test_upload_success
    file_paths = Dir.glob("./spec/sample_files/*.{doc,docx}")
    refute_empty file_paths
    client_login_success
    file_path = file_paths.first
    success = client.upload(file_path)
    assert success
  end

  def test_upload_fail
    # when not logged in, should be falsy
    file_paths = Dir.glob("./spec/sample_files/*.{doc,docx}")
    refute_empty file_paths
    success = client.upload(file_paths.first)
    refute success

    client_login_success

    # when file_path is not a regular file, should be falsy
    refute client.upload('./')
  end

  def test_get_docs_list_and_extract_worker_fail
    # fails unless logged in
    client.login(username:, password: "wrong password")
    docs = client.get_arrived_documents
    refute docs
  end

  def test_get_docs_list_and_extract_worker_success
    client_login_success
    docs = client.get_arrived_documents(doc_number: 1)
    assert_equal 1, docs.size
    docs = client.get_arrived_documents
    assert_instance_of Array, docs
    docs.each do |doc|
      assert_instance_of Hash, doc
    end
    workers = client.workers
    refute_empty workers
    workers.each do |worker|
      assert_kind_of HPNET::Client::Worker, worker
      refute_empty worker.name
      refute_empty worker.id
      refute_empty worker.key
    end

    main_worker = workers.delete workers.sample
    notify_workers = workers.sample(rand(1..workers.size))
    cooperative_workers = workers.sample(rand(1..workers.size))

    final_assign_form = client.build_assign_workers_form_params(main_worker:, cooperative_workers:, notify_workers:)
    assert final_assign_form >= main_worker.main_worker
    assert final_assign_form >= begin
      notify_workers.map do |w|
        w.notify_on
      end.reduce({}, :merge)
    end
    assert final_assign_form >= begin
      cooperative_workers.map do |w|
        w.cooperative_on
      end.reduce({}, :merge)
    end
  end

  private

  def client_login_success
    client.login(username:, password:)
  end
end

=begin
equire 'httparty'
url = 'https://qlvb.hpnet.vn/.../TruongPhongGiaoviecVBDen.aspx...'
headers = {
  'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:155.0) Gecko/20100101 Firefox/155.0',
  'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
  'Accept-Language': 'en-US,en;q=0.9',
#   'Accept-Encoding': 'gzip, deflate, br, zstd',
  'Content-Type': 'application/x-www-form-urlencoded',
  'Origin': 'https://qlvb.hpnet.vn',
  'Connection': 'keep-alive',
  'Referer': 'https://qlvb.hpnet.vn/.../TruongPhongGiaoviecVBDen.aspx...',
  'Cookie': '.ASPXFORMSAUTH=30188C6B7E618B797A20C55F81DC2D68FE57AA4A01621B6CFD26042B0322937FFB0175A23C42090919C0B34E3B9CD6F450485526808B810CCE33D59AA42DBDADB7DF7F4F153B2B6FE47CC938E7250591EBBDA8A9BC3EBBA7499B592FA46B2D019DA117A51A97625E4051BD517087438DC8753E59B6F22C05013BA3CB663EAFA60A1294D5BCC803F844DD63FFEB67E374004F031665FF95DC71148E24FCBB6BD72EE7DAE4A5D065A352473D73C78D5F5FE39DD01F; ASP.NET_SessionId=2hjkimckdcewn31kl5v0bjjx',
  'Upgrade-Insecure-Requests': '1',
  'Sec-Fetch-Dest': 'iframe',
  'Sec-Fetch-Mode': 'navigate',
  'Sec-Fetch-Site': 'same-origin',
  'Sec-Fetch-User': '?1',
  'Priority': 'u=4',
  'TE': 'trailers',
}
body = {
  '__VIEWSTATE' => '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',
  '__VIEWSTATEGENERATOR' => 'E5922906',
  '__EVENTVALIDATION' => 'LYClwoxhGemEgrvqvvqv+wRoUH9lHUop8h4gtpcsI/9pmnkeAGkse0hJxf80P9+3qcHItqno4wgEcvVKIZ2ia3wHeHirs1No/EW5AnDEzwmnoIHpMCqFX+DJ4iNX7Lu66cVV8+XwrWUOLs+BoiXicebhXdInrlvDTL4a252ziTt6RJq4itRFh37kccNERC3KC0qISYX1GvZYp3Dy5SZrxr3EEdOPOnIRmKAIlvdmDLD0y0lvxBGyi9Ha2RSJpX/3v/c1lKWeY3BJ8Dh1QvJmF7KbUWT2w5OKFMeOXaH0IZ5xmA1nLhpbhdizixUNHlVBmlPjS/Jj96vWZn7TL5ZZKDNq347jUhgT8KAB8nHTnl3KDwy/lIYqn+gSA+6zYyUuGImkRrXpZwIvs5wwJzZq4/uwmdyvfrKAwtk8CfgwQFj23bsaG3HReY/uIzRkx7UuebSpsZuGfNPq1HjuIYth5GuGeiaCo9ExdZ9x3eeazss3sSdI3EfO5BniVc8hv8tGecpTt2297QRymVWLe9NRXtUj1GKiRIfKAY4xsoXZD+iEOIoOx//AOwIOorbrh2Mwxim9Hxh/KYY/geXTXjmbQDWhzzYs5l55huDpomxP3z6JoIae',
  'txtNgayGiaoviec' => '14/09/2026',
  'txtHanHoanthanh' => '',
  'txtYKienChiDao' => '',
  'repChuyenVien$ctl00$userId' => 'a6cc3d48-548c-4d6d-9bd7-c15d7679f1a5',
  'repChuyenVien$ctl01$userId' => '9bbcb7da-e8b5-4fe9-bbbf-4e1933b8cb7a',
  'repChuyenVien$ctl02$userId' => '412a3679-d99e-43f5-bc51-c3551e216d96',
  'repChuyenVien$ctl03$userId' => '16808662-e85f-4db3-b894-ea5eba65f769',
  'repChuyenVien$ctl03$chkPhoihop' => 'on',
  'repChuyenVien$ctl04$userId' => '86f27686-8b38-452f-8f15-63be17ad54ff',
  'repChuyenVien$ctl04$chkPhoihop' => 'on',
  'repChuyenVien$ctl05$userId' => '3e9600a1-02cc-49bd-a940-dda2d07e15b1',
  'repChuyenVien$ctl06$userId' => 'a298d5fa-ab9f-4def-92ab-a171b10f8cc8',
  'radChuyenVien' => 'a298d5fa-ab9f-4def-92ab-a171b10f8cc8',
  'btnUpdate' => 'Giao việc'
}
res = HTTParty.post(url, headers: headers, body: body)
=end
