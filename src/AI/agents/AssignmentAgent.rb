class AssignmentAgent < RubyLLM::Agent
  GEMINI_API_KEY = ENV["GEMINI_API_KEY"]

  RubyLLM.configure do |c|
    c.gemini_api_key = GEMINI_API_KEY
  end

  class AssignTool < RubyLLM::Tool
    attr_reader :client

    def initialize(client)
      @client = client
    end

    desc "Giao việc cho một hoặc nhiều chuyên viên cụ thể"

    params do
      string :main_worker, description: "ID của chuyên viên được giao phụ trách chính", required: true
      array :cooperative_workers, of: :string,
                                  description: "Danh sách ID của các chuyên viên phối hợp với main_worker để thực hiện công việc", required: false
      array :notify_workers, of: :string,
                             description: "Danh sách ID của các chuyên viên được thông báo về văn bản này", required: false
    end

    def execute(main_worker:, cooperative_workers:, notify_workers:)
    end
  end

  model "gemini-3.1-flash-lite"

  inputs :client

  tools do
    [
      AssignTool.new(client)
    ]
  end
end
