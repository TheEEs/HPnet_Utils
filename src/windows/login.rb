# frozen_string_literal: true

module HPNET
  module Windows
    class Login < Base
      include Glimmer::LibUI::CustomWindow

      attr_accessor :username, :password, :remember_me, :status_message

      body {
        @window = window("Đăng nhập HPNET", 380, 240) {
          margined true
          resizable false

          vertical_box {
            group("Thông tin tài khoản HPNET") {
              stretchy false

              vertical_box {
                label("Tên đăng nhập:") { stretchy false }
                @controls << entry {
                  stretchy false
                  text <=> [self, :username]
                }

                label("Mật khẩu:") { stretchy false }
                @controls << password_entry {
                  stretchy false
                  text <=> [self, :password]
                }

                @controls << checkbox("Ghi nhớ thông tin đăng nhập trên máy này") {
                  stretchy false
                  checked <=> [self, :remember_me]
                }
              }
            }

            label {
              stretchy false
              text <= [self, :status_message]
            }

            horizontal_box {
              stretchy false

              @controls << button("Đăng nhập") {
                on_clicked { handle_login }
              }

              @controls << button("Thoát") {
                on_clicked { ::LibUI.quit }
              }
            }

            grid {
              label {
                left 0
                hexpand true
                top 1
              }
              label(FOOTER_TEXT) {
                left 1
                top 1
              }
              label {
                left 2
                hexpand true
                top 1
              }
            }
          }
        }
      }

      def initialize(engine: nil, parent: nil)
        self.username = ""
        self.password = ""
        self.remember_me = true
        self.status_message = ""
        super(engine: engine, parent: parent, require_login: false)

        on_closing do
          ::LibUI.quit unless engine&.client&.logged_in?
        end
      end

      def handle_login
        if username.to_s.strip.empty? || password.to_s.empty?
          self.status_message = "Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu."
          return
        end

        self.status_message = "Đang đăng nhập vào hệ thống HPNET..."
        @controls.each(&:disable)

        Thread.new do
          success = engine.login(username.strip, password, remember: remember_me)
          Glimmer::LibUI.queue_main do
            if success
              @window.destroy
              main_win = HPNET::Windows::Main.new(engine: engine) do |w|
                w.title = "Tiện ích HPNET - #{engine.client.display_name}"
              end
              main_win.show
            else
              self.status_message = "Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin."
              @controls.each(&:enable)
            end
          end
        end
      end
    end
  end
end
