# frozen_string_literal: true

module HPNET
  class Summarizer
    class SummaryResult
      attr_reader :type, :title, :name

      def initialize(type: '', title: '', name: '')
        @type = type.to_s
        @title = title.to_s
        @name = name.to_s
      end

      def [](key)
        public_send(key) if respond_to?(key)
      end
    end

    class SummarySchema < Schematist::Schema
      string :type, description: 'Loại văn bản (ví dụ: Thông báo, Tờ trình, Báo cáo, ...)'
      string :title, description: 'Mô tả ngắn gọn về nội dung văn bản'
      string :name, description: 'Đối tượng chịu ảnh hưởng của văn bản'

      def self.from_hash(hash)
        return SummaryResult.new unless hash.is_a?(Hash)

        SummaryResult.new(
          type: hash['type'] || hash[:type] || '',
          title: hash['title'] || hash[:title] || '',
          name: hash['name'] || hash[:name] || ''
        )
      end
    end

    class << self
      def ai_summarize(path)
        ensure_configured!
        RubyLLM.chat(model: 'gemini-3.1-flash-lite').with_schema(SummarySchema).ask(with: path)
      end

      def file_summarize(path)
        File.basename(path.to_s, '.*')
      end

      private

      def ensure_configured!
        api_key = ENV['GEMINI_API_KEY']
        RubyLLM.configure do |c|
          c.gemini_api_key = api_key
        end
      end
    end
  end
end
