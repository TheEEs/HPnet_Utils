module HPNET
  module Windows
    class Upload < Base
      include Glimmer::LibUI::CustomWindow

      class HowWeShouldSetTitleOfDocument
        Manual = 0
        FromFilePath = 1
        AI = 2
      end

      attr_accessor :selected_dir, :how_we_should_set_title_of_document, :manual_document_title, :progress

      body {
        @window = window("Trình văn bản hàng loạt") {
          resizable false
          margined true
          vertical_box {
            group("Chọn thư mục chứa các tệp cần upload") {
              stretchy false
              horizontal_box {
                @controls << button("Chọn thư mục") {
                  stretchy false
                  on_clicked &self.method(:select_directory)
                }
              }
            }
            label {
              stretchy false
              text <= [self, :selected_dir, on_read: ->(value) { "Thư mục được lựa chọn: #{value}" }]
            }
            group("Trích yếu của văn bản") {
              stretchy false
              vertical_box {
                @controls << radio_buttons {
                  stretchy false
                  items [
                    "Điền thủ công",
                    "Lấy từ tên file",
                    "Trí tuệ nhân tạo (AI)"
                  ]
                  selected <=> [self, :how_we_should_set_title_of_document]
                }
                @controls << form {
                  stretchy false
                  content(self, :how_we_should_set_title_of_document) { radio_button_selected_change }
                }
              }
            }
            group("Tiến trình thực hiện") {
              progress_bar {
                value <=> [self, :progress]
              }
            }
            @controls << button("Trình duyệt hàng loạt") {
              stretchy false
              on_clicked &self.method(:upload)
            }
          }
        }
      }

      def initialize(...)
        @controls = []
        self.selected_dir = ""
        self.progress = 0
        self.how_we_should_set_title_of_document = 0
        super
        self.on_closing do
          parent_window&.enable
        end
      end

      def select_directory(...)
        self.selected_dir = open_folder(self)&.force_encoding("utf-8")
      end

      def radio_button_selected_change(...)
        case self.how_we_should_set_title_of_document
        when HowWeShouldSetTitleOfDocument::Manual
          manual_form
        when HowWeShouldSetTitleOfDocument::FromFilePath
          label("Trích yếu của văn bản được lấy từ tên file nạp vào")
        when HowWeShouldSetTitleOfDocument::AI
          label("- Trích yếu của văn bản được sinh ra bởi trí tuệ nhân tạo (AI).\n- Sử dụng tính năng này có thể khiến bạn phải trả phí.")
        end
      end

      def upload(...)
        # self.disable
        @controls&.each(&:disable)
        Thread.new do
          engine.upload(selected_dir, lanhdao_id: nil)
          @controls&.each(&:enable)
        end
        # self.enable
      end

      private

      def manual_form
        entry {
          label "Điền trích yếu vào đây:"
          text <=> [self, :manual_document_title]
        }
      end
    end
  end
end
