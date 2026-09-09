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
    session = client.login(username: username, password: password)
    assert_instance_of HPNET::Client::Session, session
    refute_empty session.display_name.to_s
  end

  def test_login_fail
    session = client.login(username: username, password: "wrong password")
    assert_nil session
  end

  def test_get_leaders_success
    session = client.login(username: username, password: password)
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
    session = client.login(username: username, password: password)
    assert_instance_of HPNET::Client::Session, session

    tokens = client.validation_tokens
    assert_kind_of Hash, tokens

    refute_nil tokens["__VIEWSTATE"]
    refute_nil tokens["__VIEWSTATEGENERATOR"]
    refute_nil tokens["__EVENTVALIDATION"]
  end

  def test_validation_tokens_fail
    # When not logged in, should return nil
    assert_nil client.validation_tokens
  end

  def test_upload_success
    file_paths = Dir.glob("./spec/sample_files/*.{doc,docx}")
    refute_empty file_paths
    client.login(username:, password:)
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

    client.login(username:, password:)

    # when file_path is not a regular file, should be falsy
    refute client.upload('./')
  end
end
