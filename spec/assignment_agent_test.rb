# frozen_string_literal: true

require "test_helper"
require "minitest/autorun"
require_relative "../src/AI/agents/assignment_agent"
require_relative "../src/components/Client"

class AssignmentAgentTest < Minitest::Test
  attr_reader :client, :username, :password

  ASSIGNMENT_JSON_FILE = "./spec/sample_files/assignment_agent_tests.json"

  def setup
    @client = HPNET::Client.new
    @username = ENV['USER_NAME']
    @password = ENV['PASSWORD']
  end

  def test_agent_initialization
    # should raises if client is not logged in
    client.login(username:, password: "wrong_password")
    assert_raises(AssignmentAgent::ClientNotLoggedInException) do
      agent = AssignmentAgent.new client:
    end
  end

  def test_list_workers_and_process_success
    client_login_success
    test_json = JSON.parse(File.read(ASSIGNMENT_JSON_FILE))
    refute_empty test_json
    test_json.each_pair do |f, w|
      ag = AssignmentAgent.new(client:)
      result = ag.ask(with: f).content
      assert_equal w, result["name"]
    end
  end

  private

  def client_login_success
    client.login username:, password:
  end
end
