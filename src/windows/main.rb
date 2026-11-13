# frozen_string_literal: true

require_relative './approve'
require_relative './upload'

module HPNET
  module Windows
    class Main < Base
      include Glimmer::LibUI::CustomWindow

      body do
        window do
          margined true
          resizable false

          vertical_box do
            horizontal_box do
              stretchy true

              button('Trình văn bản hàng loạt') do
                on_clicked -> { open_upload_window }
              end

              button('Chuyển duyệt văn bản hàng loạt') do
                on_clicked ->(_, __) { open_approve_window }
              end
            end

            label(FOOTER_TEXT) do
              stretchy false
            end
          end
        end
      end

      def open_approve_window
        approve_window = HPNET::Windows::Approve.new(engine: engine, parent: self) do |w|
          w.title = "Chuyển duyệt văn bản hàng loạt - #{engine.client.display_name}"
          disable
        end
        approve_window.show
      end

      def open_upload_window
        upload_window = HPNET::Windows::Upload.new(engine: engine, parent: self) do |w|
          w.title = "Trình văn bản hàng loạt - #{engine.client.display_name}"
          disable
        end
        upload_window.show
      end

      alias approve open_approve_window
      alias upload open_upload_window
    end
  end
end
