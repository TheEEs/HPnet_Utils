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
end