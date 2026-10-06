module HPNET
  module Windows
    class Base
      include Glimmer::LibUI::CustomWindow

      attr_reader :engine
      attr_reader :parent_window

      def initialize(engine: nil, parent: nil)
        unless engine.is_a?(HPNET::Engine) and engine&.client&.logged_in?
          self.destroy
          ::LibUI.quit
        end
        @engine = engine
        @parent_window = parent
        super(parent, nil, nil, nil)
        yield self if block_given?
      end
    end
  end
end
