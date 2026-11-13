# frozen_string_literal: true

module HPNET
  module Windows
    class Base
      include Glimmer::LibUI::CustomWindow

      FOOTER_TEXT = 'Phát triển bởi Trần Bá Đạt - 2026'

      attr_reader :engine, :parent_window, :controls

      def initialize(engine: nil, parent: nil, require_login: true)
        if require_login && !(engine.is_a?(HPNET::Engine) && engine&.client&.logged_in?)
          destroy
          ::LibUI.quit
        end

        @engine = engine
        @parent_window = parent
        @controls = []

        super(parent, nil, nil, nil)

        on_closing do
          parent_window&.enable
        end

        yield self if block_given?
      end

      def leaders
        @leaders ||= engine&.client&.leaders || []
      end

      def leader_names
        leaders.map { |l| l[:name] }
      end

      def selected_leader_id(index)
        return if index.nil?

        leaders.dig(index.to_i, :value)
      end
    end
  end
end
