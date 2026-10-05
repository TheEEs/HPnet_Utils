require_relative "./approve"
module HPNET
  module Windows
    class Main < Base
      include Glimmer::LibUI::CustomWindow

      attr_reader :engine

      body {
        @window = window() {
          margined true
          vertical_box {
            horizontal_box {
              button("Trình văn bản hàng loạt")
              button("Chuyển duyệt văn bản hàng loạt") {
                on_clicked &self.method(:approve)
              }
            }
          }
        }
      }
      def approve(...)
        approve_window = HPNET::Windows::Approve.new(engine:, parent: @window)
        approve_window.show
      end
    end
  end
end
