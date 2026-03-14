# frozen_string_literal: true

require 'legion/extensions/cognitive_quicksilver/helpers/constants'
require 'legion/extensions/cognitive_quicksilver/helpers/droplet'
require 'legion/extensions/cognitive_quicksilver/helpers/pool'
require 'legion/extensions/cognitive_quicksilver/helpers/quicksilver_engine'
require 'legion/extensions/cognitive_quicksilver/runners/cognitive_quicksilver'

module Legion
  module Extensions
    module CognitiveQuicksilver
      class Client
        include Runners::CognitiveQuicksilver

        def initialize
          @quicksilver_engine = Helpers::QuicksilverEngine.new
        end

        private

        attr_reader :quicksilver_engine
      end
    end
  end
end
