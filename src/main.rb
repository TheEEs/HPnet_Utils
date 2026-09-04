#!/usr/bin/env ruby
require "bundler/setup"
Bundler.require
require 'glimmer-dsl-libui'
Dotenv.load

require_relative "./windows/upload"
require_relative "./windows/login"
require_relative "./utils/HTTP"

class App
  include Glimmer::LibUI::Application
  include HPNET::Utils

  option :bypass_login

  before_body do
    next if bypass_login

    password = ENV["PASSWORD"]
    username = ENV["USER_NAME"]
    success = login(username:, password:)
    unless success
      LoginWindow.launch
    end
  end

  body {
    window('Tiện ích HPNET') {
      margined true
      vertical_box {
        horizontal_box {
          button("Trình văn bản") {
            stretchy true
            on_clicked do |b|
              b.disable
              UploadWindow.launch(trigger: b)
            end
          }
          button("Xóa văn bản") {
            stretchy true
          }
        }
        horizontal_separator {
          stretchy false
        }
        grid {
          padded false
          label {
            hexpand true
            left 0
            top 1
            valign :bottom
            halign :center
            text "© Tran Ba Dat 2026"
          }
        }
      }
      on_closing do
        Process.exit(0)
      end
    }
  }
end

App.launch
