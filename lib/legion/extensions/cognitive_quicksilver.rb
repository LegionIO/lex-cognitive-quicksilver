# frozen_string_literal: true

require 'securerandom'
require 'legion/extensions/cognitive_quicksilver/version'
require 'legion/extensions/cognitive_quicksilver/helpers/constants'
require 'legion/extensions/cognitive_quicksilver/helpers/droplet'
require 'legion/extensions/cognitive_quicksilver/helpers/pool'
require 'legion/extensions/cognitive_quicksilver/helpers/quicksilver_engine'
require 'legion/extensions/cognitive_quicksilver/runners/cognitive_quicksilver'
require 'legion/extensions/cognitive_quicksilver/client'

module Legion
  module Extensions
    module CognitiveQuicksilver
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
