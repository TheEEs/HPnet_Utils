# frozen_string_literal: true

require "test_helper"
require "minitest/autorun"
require_relative "../src/components/Engine"

class EngineTest < Minitest::Test
  attr_reader :engine

  def setup
    @engine = HPNET::Engine.new
  end

  def test_engine_initialization_success
    engine.launch
    assert engine.client.logged_in?
  end

  def test_engine_initialization_fail
    temp_user_name, temp_password = ENV['USER_NAME'], ENV['PASSWORD']
    ENV['USER_NAME'] = "wrong_user_name"
    ENV['PASSWORD'] = "wrong_password"
    engine.launch
    refute engine.client.logged_in?
    ENV['USER_NAME'], ENV['PASSWORD'] = temp_user_name, temp_password
  end
end
