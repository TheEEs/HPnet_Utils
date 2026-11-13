# frozen_string_literal: true

require "test_helper"
require "minitest/autorun"
require "tempfile"
require_relative "../src/components/CredentialStore"

class CredentialStoreTest < Minitest::Test
  def setup
    @temp_file = Tempfile.new("hpnet_test_credentials")
    @temp_path = @temp_file.path
    @temp_file.close
    @temp_file.unlink
    HPNET::CredentialStore.file_path = @temp_path
  end

  def teardown
    File.delete(@temp_path) if File.exist?(@temp_path)
    HPNET::CredentialStore.file_path = nil
  end

  def test_save_and_load_success
    refute HPNET::CredentialStore.saved?

    success = HPNET::CredentialStore.save("test_user", "test_pass123")
    assert success
    assert HPNET::CredentialStore.saved?

    creds = HPNET::CredentialStore.load
    assert_instance_of Hash, creds
    assert_equal "test_user", creds[:username]
    assert_equal "test_pass123", creds[:password]
  end

  def test_save_with_empty_inputs
    refute HPNET::CredentialStore.save("", "password")
    refute HPNET::CredentialStore.save("user", "")
    refute HPNET::CredentialStore.saved?
  end

  def test_clear_credentials
    HPNET::CredentialStore.save("user_demo", "pass_demo")
    assert HPNET::CredentialStore.saved?

    HPNET::CredentialStore.clear
    refute HPNET::CredentialStore.saved?
    assert_nil HPNET::CredentialStore.load
  end

  def test_load_when_file_not_exist
    assert_nil HPNET::CredentialStore.load
  end
end
