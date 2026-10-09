#!/usr/bin/env ruby

require "bundler/setup"
Bundler.require :default
Dotenv.load

require_relative "./components/Engine"
require_relative "./windows/base"
require_relative "./windows/main"

Engine = HPNET::Engine.new

Engine.launch do |authenticated|
  unless authenticated
    STDERR.puts "Chưa đăng nhập. Hãy đảm bảo bạn đã điền đúng và đủ thông tin đăng nhập vào file .env ở thư mục gốc của ứng dụng"
    exit 1
  end
  main_window = HPNET::Windows::Main.new(engine: Engine) do |w|
    w.title = "Tiện ích HPNET - #{Engine.client.display_name}"
  end
  main_window.show
end
