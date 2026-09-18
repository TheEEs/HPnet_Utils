class AssignmentAgent < RubyLLM::Agent
  class ClientNotLoggedInException < Exception
  end

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
                                  description: "IDs của các chuyên viên phối hợp với main_worker để thực hiện công việc", required: false
      array :notify_workers, of: :string,
                             description: "IDs của các chuyên viên được thông báo về văn bản này", required: false
    end

    def execute(main_worker:, cooperative_workers:, notify_workers:)
      puts r = {
        main_worker:,
        cooperative_workers:,
        notify_workers:
      }
      r
    end
  end

  model "gemini-3.1-flash-lite"

  inputs :client

  instructions client: -> { self.client }

  tools calls: :one do
    [
      AssignTool.new(client)
    ]
  end

  schema do 
    boolean :processed, description: "Văn bản có thể được xử lý và tools đã được gọi"
    string :name, description: "Tên của người được giao phụ trách chính văn bản", required: false
  end

  def initialize(client:, **kw)
    raise ClientNotLoggedInException.new unless client.logged_in? && client.is_a?(HPNET::Client)

    super client:, **kw
  end
end
