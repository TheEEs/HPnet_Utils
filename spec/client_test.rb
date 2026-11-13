# frozen_string_literal: true

require 'test_helper'
require 'minitest/autorun'
require_relative '../src/components/Client'

class ClientTest < Minitest::Test
  attr_reader :username, :password, :client

  class MockClient < HPNET::Client
    def upload(file_path, to: nil, title: nil)
      return unless current_session && File.file?(file_path)

      true
    end

    def approve_document(document_id: nil, lanhdao_id: nil)
      return unless logged_in? and document_id and lanhdao_id

      @vanthu_id ||= workers.find { |w| w.name.match?(VANTHU_REGEX) }&.id

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
    session = client.login(username: username, password: 'wrong password')
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
    client.login(username: username, password: 'wrong password')
    leaders = client.leaders
    assert_nil leaders
  end

  def test_upload_and_approve_validation_tokens_success
    session = client_login_success
    assert_instance_of HPNET::Client::Session, session

    tokens = client.instance_eval do
      break upload_validation_tokens
    end
    assert_kind_of Hash, tokens

    refute_nil tokens['__VIEWSTATE']
    refute_nil tokens['__VIEWSTATEGENERATOR']
    refute_nil tokens['__EVENTVALIDATION']

    tokens = client.instance_eval do
      break approve_validation_tokens
    end

    assert_kind_of Hash, tokens

    refute_nil tokens['__VIEWSTATE']
    refute_nil tokens['__VIEWSTATEGENERATOR']
    refute_nil tokens['__EVENTVALIDATION']
  end

  def test_upload_and_approve_validation_tokens_fail
    # When not logged in, should return nil
    assert_nil(client.instance_eval { upload_validation_tokens })
    assert_nil(client.instance_eval { approve_validation_tokens })
  end

  def test_upload_success
    file_paths = Dir.glob('./spec/sample_files/*.{doc,docx}')
    refute_empty file_paths
    client_login_success
    file_path = file_paths.first
    success = client.upload(file_path)
    assert success
  end

  def test_upload_fail
    # when not logged in, should be falsy
    file_paths = Dir.glob('./spec/sample_files/*.{doc,docx}')
    refute_empty file_paths
    success = client.upload(file_paths.first)
    refute success

    client_login_success

    # when file_path is not a regular file, should be falsy
    refute client.upload('./')
  end

  def test_get_docs_list_and_extract_worker_fail
    # fails unless logged in
    client.login(username:, password: 'wrong password')
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

  def test_client_approve_success
    client_login_success
    docs = client.get_uploaded_documents
    assert_instance_of Array, docs
    refute_empty docs
    doc = docs.first
    lanhdao_id = client.leaders.find { |l| l[:name].include?('PCVP') }[:value]
    assert_instance_of String, lanhdao_id
    refute_empty lanhdao_id
    success = client.approve_document(document_id: doc['VanbanDiId'], lanhdao_id: lanhdao_id)
    assert success
  end

  private

  def client_login_success
    client.login(username:, password:)
  end
end
