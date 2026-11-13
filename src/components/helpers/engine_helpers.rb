# frozen_string_literal: true

module HPNET
  class Engine
    module Helpers
      module TitleMode
        MANUAL = 0
        FROM_FILE_PATH = 1
        AI = 2
      end

      # Backward compatibility alias
      HowWeShouldSetTitleOfDocument = TitleMode
      HowWeShouldSetTitleOfDocument::Manual = TitleMode::MANUAL
      HowWeShouldSetTitleOfDocument::FromFilePath = TitleMode::FROM_FILE_PATH
      HowWeShouldSetTitleOfDocument::AI = TitleMode::AI
    end
  end
end
