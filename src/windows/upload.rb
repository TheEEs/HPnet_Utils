module HPNET
  module Windows
    class Upload < Base
      include Glimmer::LibUI::CustomWindow

      attr_accessor :selected_dir

      body {
        window("Trình văn bản hàng loạt") {
          margined true
          vertical_box {
            group("Chọn thư mục chứa các tệp cần upload") {
              stretchy false
              horizontal_box {
                button("Chọn thư mục") {
                  stretchy false
                  on_clicked &self.method(:select_directory)
                }
                label {
                  text <= [self, :selected_dir, on_read: ->(value) { "Thư mục được lựa chọn: #{value}" }]
                }
              }
            }
          }
        }
      }

      def initialize(...)
        self.selected_dir = ""
        super
        self.on_closing do
          parent_window&.enable
        end
      end

      def select_directory(...)
        # Glimmer::LibUI.open_folder(self)
      end
    end
  end
end
