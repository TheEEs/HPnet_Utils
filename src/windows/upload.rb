# frozen_string_literal: true

module HPNET
  module Windows
    class Upload < Base
      include Glimmer::LibUI::CustomWindow
      include HPNET::Engine::Helpers

      attr_accessor :selected_dir, :how_we_should_set_title_of_document,
                    :manual_document_title, :progress, :selected_leader_index

      body do
        @window = window('Trình văn bản hàng loạt') do
          resizable false
          margined true

          vertical_box do
            group('Chọn thư mục chứa các tệp cần upload') do
              stretchy false
              vertical_box do
                @controls << button('Chọn thư mục') do
                  stretchy false
                  on_clicked -> { select_directory }
                end
                label do
                  stretchy false
                  text <= [self, :selected_dir, { on_read: lambda { |val|
                    "Thư mục được chọn: #{val&.ellipsis(max_length: 50)}"
                  } }]
                end
              end
            end

            group('Trích yếu của văn bản') do
              stretchy false
              vertical_box do
                @controls << radio_buttons do
                  stretchy false
                  items [
                    'Điền thủ công',
                    'Lấy từ tên file',
                    'Trí tuệ nhân tạo (AI)'
                  ]
                  selected <=> [self, :how_we_should_set_title_of_document]
                end

                @controls << form do
                  stretchy false
                  content(self, :how_we_should_set_title_of_document) { radio_button_selected_change }
                end
              end
            end

            group('Lãnh đạo trình') do
              stretchy false
              @controls << combobox do
                items
                [self, :leader_names]
                selected <=> [self, :selected_leader_index]
              end
            end

            group('Tiến trình thực hiện') do
              progress_bar do
                value <=> [self, :progress]
              end
            end

            @controls << button('Trình duyệt hàng loạt') do
              stretchy false
              on_clicked -> { upload }
            end

            grid do
              label do
                left 0
                hexpand true
                top 1
              end
              label(FOOTER_TEXT) do
                left 1
                top 1
              end
              label do
                left 2
                hexpand true
                top 1
              end
            end
          end
        end
      end

      def initialize(...)
        self.selected_dir = ''
        self.progress = 0
        self.how_we_should_set_title_of_document = TitleMode::MANUAL
        super
      end

      def select_directory
        chosen = open_folder(self)&.force_encoding('utf-8')
        self.selected_dir = chosen if chosen && !chosen.empty?
      end

      def radio_button_selected_change
        case how_we_should_set_title_of_document
        when TitleMode::MANUAL
          manual_form
        when TitleMode::FROM_FILE_PATH
          label('Trích yếu của văn bản được lấy từ tên file nạp vào')
        when TitleMode::AI
          label("- Trích yếu của văn bản được sinh ra bởi trí tuệ nhân tạo (AI).\n- Sử dụng tính năng này có thể khiến bạn phải trả phí.")
        end
      end

      def upload
        if selected_dir.to_s.strip.empty? || !Dir.exist?(selected_dir)
          msg_box_error(@window, 'Lỗi', 'Vui lòng chọn thư mục chứa tệp văn bản hợp lệ.')
          return
        end

        leader_id = selected_leader_id(selected_leader_index)
        unless leader_id
          msg_box_error(@window, 'Lỗi', 'Vui lòng chọn lãnh đạo trình duyệt.')
          return
        end

        @count = 0
        self.progress = 0
        @controls.each(&:disable)

        Thread.new do
          engine.upload(selected_dir,
                        lanhdao_id: leader_id,
                        how_we_should_set_title_of_document: how_we_should_set_title_of_document,
                        manual_title: manual_document_title) do |_res, _file, files|
            @count += 1
            Glimmer::LibUI.queue_main do
              self.progress = (@count * 100.to_f) / files.size
            end
          end
        rescue StandardError => e
          Glimmer::LibUI.queue_main do
            msg_box_error(@window, 'Lỗi', "Đã xảy ra lỗi khi tải văn bản: #{e.message}")
          end
        ensure
          Glimmer::LibUI.queue_main do
            @controls.each(&:enable)
          end
        end
      end

      private

      def manual_form
        entry do
          label 'Điền trích yếu vào đây:'
          text <=> [self, :manual_document_title]
        end
      end
    end
  end
end
