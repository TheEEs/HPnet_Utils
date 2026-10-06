module HPNET
  module Windows
    class Approve < Base
      include Glimmer::LibUI::CustomWindow

      attr_accessor :filter_text, :percent
      attr_reader :leaders
      attr_accessor :selected_leader_index

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
            group("Chọn lãnh đạo để chuyển tiếp:") {
              stretchy false
              combobox {
                items <= [self, :leader_names]
                selected <=> [self, :selected_leader_index]
              }
            }
            progress_bar {
              stretchy false
              value <= [self, :percent]
            }
            label("Tiến trình thực hiện:") {
              stretchy false
            }
            button("Chuyển duyệt") {
              stretchy false
              on_clicked do |b|
                b.disable
                Thread.new do
                  self.approve
                  b.enable
                end
              end
            }
            grid {
              label {
                left 0
                hexpand true
                top 1
              }
              label("Phát triển bởi Trần Bá Đạt - 2026") {
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

      def approve(...)
        @count = 0
        engine.approve(filter: self.filter_text,
                       lanhdao_id: (leaders[self.selected_leader_index][:value] rescue nil)) do |success, processed_doc, all_docs|
          @doc_numbers = all_docs.size
          next unless success
          @count += 1
          Glimmer::LibUI::queue_main do
            self.percent = (@count * 100.to_f) / @doc_numbers
          end
        end
        rescue HPNET::Client::ClericalAssistantNotFound => e
          msg_box("Lỗi", "Không tìm thấy tài khoản văn thư.\nHãy đảm bảo rằng văn thư cơ quan có chứa cụm từ \"Văn thư\" trong tên của họ")
      end

      def initialize(...)
        self.percent = 0
        super
        self.on_closing do 
           parent_window&.enable
        end
      end

      def leader_names
        @leaders ||= engine.client.leaders
        @leaders.map { |l| l[:name] }
      end
    end
  end
end
