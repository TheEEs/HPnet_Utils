module HPNET
  module Windows
    class Base
      include Glimmer::LibUI::CustomWindow
      def initialize(engine: nil, parent: nil)
        super(parent, nil, nil, nil)
        unless engine.is_a?(HPNET::Engine) and engine&.client&.logged_in?
          self.destroy
          ::LibUI.quit
        end
        @engine = engine
        yield self if block_given?
      end
    end
  end
end
