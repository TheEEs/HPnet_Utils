require_relative "./approve"
require_relative "./upload"

module HPNET
  module Windows
    class Main < Base
      include Glimmer::LibUI::CustomWindow

      body {
        window() {
          margined true
          resizable false
          vertical_box {
            horizontal_box {
              stretchy true
              button("Trình văn bản hàng loạt") {
                on_clicked &self.method(:upload)
              }
              button("Chuyển duyệt văn bản hàng loạt") {
                on_clicked &self.method(:approve)
              }
            }
            label("Phát triển bởi Trần Bá Đạt - 2026") {
              stretchy false
            }
          }
        }
      }
      def approve(...)
        approve_window = HPNET::Windows::Approve.new(engine:, parent: self) do |w|
          w.title = "Chuyển duyệt văn bản hàng loạt - #{engine.client.display_name}"
          self.disable
        end
        approve_window.show
      end

      def upload(...)
        upload_window = HPNET::Windows::Upload.new(engine:, parent: self) do |w|
          w.title = "Trình văn bản hàng loạt - #{engine.client.display_name}"
          self.disable
        end
        upload_window.show
      end
    end
  end
end
