require "ruby_llm/schema"
module HPNET
  class Summarizer
    GEMINI_API_KEY = ENV["GEMINI_API_KEY"]

    RubyLLM.configure do |c|
      c.gemini_api_key = GEMINI_API_KEY
    end

    class SummarySchema < RubyLLM::Schema
      string :type, description: "Loại văn bản (ví dụ: Thông báo, Tờ trình, Báo cáo, ...)"
      string :title, description: "Mô tả ngắn gọn về nội dung văn bản"
      string :name, description: "Đối tượng chịu ảnh hưởng của văn bản"

      def self.from_hash hash
        schema = SummarySchema.new
        schema.instance_eval do
          @hash = hash
          def method_missing(symbol, *args)
            if @hash.has_key? symbol
              return @hash[symbol]
            elsif @hash.has_key? symbol.name
              return @hash[symbol.name]
            else
              super
            end
          end
        end
        schema
      end
    end

    class << self
      def summarize(path)
        RubyLLM.chat(model: "gemini-3.1-flash-lite").with_schema(SummarySchema).ask with: path
      end
    end
  end
end
