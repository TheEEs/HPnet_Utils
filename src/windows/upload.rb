require_relative "../utils/HTTP"
require_relative "../utils/Summarizer"
require_relative "../utils/PDFConverter"
require "async/semaphore"

class UploadWindow
  include Glimmer::LibUI::CustomWindow
  include HPNET::Utils
  include HPNET::Summarizer
  include HPNET::PDFConverter

  option :trigger
  attr_accessor :leaders
  attr_accessor :selected_folder
  attr_accessor :progress
  attr_accessor :selected_leader
  attr_accessor :worker_thread

  before_body do
    self.progress = 0
    self.leaders = extract_get_leaders
  end

  body {
    window("Trình văn bản") {
      margined true
      vertical_box {
        group("Lựa chọn thư mục") {
          stretchy false
          horizontal_box {
            button("Chọn") {
              stretchy false
              on_clicked do
                self.selected_folder = open_folder(self)
              end
            }
            label {
              text <=> [self, :selected_folder]
              stretchy true
            }
          }
        }
        group("Lãnh đạo trình") {
          stretchy false
          vertical_box {
            combobox {
              stretchy false
              items self.leaders.map { |l| l[:name] }
              selected <=> [self, :selected_leader]
            }
            button("Trình") { |b|
              cookie = File.read(".cookie").strip rescue ""
              token = extract_validation_tokens
              stretchy false
              on_clicked do
                is_directory = File.directory? self.selected_folder.to_s
                next msg_box("Lỗi",
                             "Cần chọn thư mục chứa các file cần trình và lãnh đạo trình") unless is_directory and self.selected_leader

                file_paths = Dir.glob("#{selected_folder}/*.{doc,docx}")
                total = file_paths.size
                counter = 0
                self.progress = 0
                b.disable
                self.worker_thread = Thread.new do
                  Sync do
                    semaphore = Async::Semaphore.new(20)
                    file_paths.each do |file_path|
                      semaphore.async do
                        pdf_path = convert file_path
                        if pdf_path
                          summary = summarize(pdf_path).content
                          title = "#{summary["type"]} - #{summary["title"]} - #{summary["name"]}"
                          to = self.leaders[selected_leader][:value]
                          upload(file_path, to:, title:, cookie:, token:)
                        end
                        counter += 1
                        Glimmer::LibUI.queue_main do
                          self.progress = (counter * 100) / total.to_f
                        end
                        File.unlink pdf_path
                        File.unlink file_path
                      end
                    end
                  end
                  b.enable
                end
              end
            }
          }
        }
        horizontal_box {
          progress_bar {
            value <=> [self, :progress]
          }
        }
      }
      on_closing do
        self.worker_thread&.exit
        trigger&.enable
      end
    }
  }
end
