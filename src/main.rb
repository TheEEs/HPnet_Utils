#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
Bundler.require :default
Dotenv.load
include Glimmer

require_relative './components/helpers/kernel'
require_relative './components/Engine'
require_relative './windows/base'
require_relative './windows/main'

engine = HPNET::Engine.new

engine.launch do |authenticated|
  unless authenticated
    w = window {}
    msg_box_error(w, 'Lỗi đăng nhập',
                  "Chưa đăng nhập vào hệ thống HPNET.\n" \
                  'Hãy đảm bảo bạn đã điền đúng USER_NAME và PASSWORD vào file .env ở thư mục gốc của ứng dụng.')
    exit 1
  end

  main_window = HPNET::Windows::Main.new(engine: engine) do |w|
    w.title = "Tiện ích HPNET - #{engine.client.display_name}"
  end
  main_window.show
end
