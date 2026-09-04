require_relative "../utils/HTTP"
require_relative "../windows/upload"

class LoginWindow
  include Glimmer::LibUI::CustomWindow
  include HPNET::Utils
  option :trigger

  attr_accessor :username
  attr_accessor :password
  attr_accessor :error

  before_body do
    self.username = self.password = ""
  end

  body {
    window("Đăng nhập") {
      resizable false
      margined true
      vertical_box {
        l = label {
          text <=> [self, :error]
        }
        l.hide
        form {
          stretchy false
          entry {
            label "Tên đăng nhập"
            text <=> [self, :username]
          }
          password_entry {
            label "Mật khẩu"
            text <=> [self, :password]
          }
          button("Đăng nhập") {
            on_clicked do
              success = login(username: self.username, password: self.password)
              if success
                self.hide
                App.launch(bypass_login: true)
              else
                l.show
                self.error = "Thông tin đăng nhập không chính xác"
              end
            end
          }
        }
      }
    }
  }
end
