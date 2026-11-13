# frozen_string_literal: true

module HPNET
  module Windows
    class Approve < Base
      include Glimmer::LibUI::CustomWindow

      attr_accessor :filter_text, :percent, :selected_leader_index

      body do
        @window = window('Chuyển duyệt văn bản hàng loạt') do
          margined true
          resizable false

          vertical_box do
            group('Lọc văn bản trong tên có chứa:') do
              stretchy false
              @controls << entry do
                text <=> [self, :filter_text]
              end
            end

            group('Chọn lãnh đạo để chuyển tiếp:') do
              stretchy false
              @controls << combobox do
                items 
                [self, :leader_names]
                selected <=> [self, :selected_leader_index]
              end
            end

            progress_bar do
              stretchy false
              value <= [self, :percent]
            end

            label('Tiến trình thực hiện:') do
              stretchy false
            end

            @controls << button('Chuyển duyệt') do
              stretchy false
              on_clicked { approve }
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
        self.percent = 0
        super
      end

      def approve
        leader_id = selected_leader_id(selected_leader_index)
        unless leader_id
          msg_box_error(@window, 'Lỗi', 'Vui lòng chọn lãnh đạo để chuyển tiếp.')
          return
        end

        @count = 0
        @controls.each(&:disable)

        Thread.new do
          engine.approve(filter: filter_text, lanhdao_id: leader_id) do |success, _processed_doc, all_docs|
            next unless success

            @count += 1
            Glimmer::LibUI.queue_main do
              self.percent = (@count * 100.to_f) / all_docs.size
            end
          end
        rescue HPNET::Client::ClericalAssistantNotFound
          Glimmer::LibUI.queue_main do
            msg_box_error(@window, 'Lỗi',
                          "Không tìm thấy tài khoản văn thư.\nHãy đảm bảo rằng văn thư cơ quan có chứa cụm từ \"Văn thư\" trong tên của họ")
          end
        rescue StandardError => e
          Glimmer::LibUI.queue_main do
            msg_box_error(@window, 'Lỗi', "Đã xảy ra lỗi trong quá trình chuyển duyệt: #{e.message}")
          end
        ensure
          Glimmer::LibUI.queue_main do
            @controls.each(&:enable)
          end
        end
      end
    end
  end
end
