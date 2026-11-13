#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
Bundler.require :default
Dotenv.load
include Glimmer

require_relative "./components/helpers/kernel"
require_relative "./components/Engine"
require_relative "./windows/base"
require_relative "./windows/login"
require_relative "./windows/main"

engine = HPNET::Engine.new

engine.launch do |authenticated|
  if authenticated
    main_window = HPNET::Windows::Main.new(engine: engine) do |w|
      w.title = "Tiện ích HPNET - #{engine.client.display_name}"
    end
    main_window.show
  else
    login_window = HPNET::Windows::Login.new(engine: engine)
    login_window.show
  end
end
