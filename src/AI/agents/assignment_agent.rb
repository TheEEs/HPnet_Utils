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

    description  "Giao việc cho một chuyên viên chính và một hoặc nhiều chuyên viên phối hợp, và thông báo cho một hoặc nhiều chuyên viên khác"

    parameters do
      string :main_worker, description: "ID của chuyên viên được giao phụ trách chính", required: true
      array :cooperative_workers, of: :string,
                                  description: "IDs của các chuyên viên phối hợp với main_worker để thực hiện công việc", required: false
      array :notify_workers, of: :string,
                             description: "IDs của các chuyên viên được thông báo về văn bản này", required: false
    end

    def execute(main_worker:, cooperative_workers:, notify_workers:)
      #return unless client.logged_in?
      #return unless client.workers.any?(main_worker)
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

  tools do
    [
      AssignTool.new(client)
    ]
  end

  tool_options calls: :one

  schema do 
    boolean :processed, description: "Văn bản có thể được xử lý và tools đã được gọi"
    string :main_worker, description: "Tên của người được giao phụ trách chính văn bản", required: false
  end

  def initialize(client:, **kw)
    raise ClientNotLoggedInException.new unless client.logged_in? && client.is_a?(HPNET::Client)

    super client:, **kw
  end
end
