module HPNET
  module Windows
    class Approve < Base
      include Glimmer::LibUI::CustomWindow

      attr_reader :engine
      attr_accessor :filter_text

      body {
        @window = window() {
          margined true
          vertical_box {
            group("Lọc văn bản trong tên có chứa:") {
              entry {
                text <=> [self, :filter_text]
              }
            }
            button("Chuyển duyệt") {
              on_clicked &self.method(:approve)
            }
          }
        }
      }

      def approve(...)
      end
    end
  end
end
