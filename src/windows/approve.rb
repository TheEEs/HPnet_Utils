module HPNET
  module Windows
    class Approve < Base
      include Glimmer::LibUI::CustomWindow

      attr_accessor :filter_text

      body {
        @window = window("Chuyển duyệt văn bản hàng loạt") {
          margined true
          resizable false
          vertical_box {
            group("Lọc văn bản trong tên có chứa:") {
              stretchy false
              entry {
                text <=> [self, :filter_text]
              }
            }
            progress_bar {
              stretchy false
            }
            label("Tiến trình thực hiện:"){
              stretchy false
            }
            button("Chuyển duyệt") {
              stretchy false
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
