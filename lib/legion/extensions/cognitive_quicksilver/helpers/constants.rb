# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveQuicksilver
      module Helpers
        module Constants
          FORM_TYPES    = %i[liquid droplet bead stream pool].freeze
          SURFACE_TYPES = %i[glass metal wood stone fabric].freeze

          MAX_DROPLETS = 500
          MAX_POOLS    = 50

          FLUIDITY_BASE    = 0.8
          SURFACE_TENSION  = 0.3
          EVAPORATION_RATE = 0.02
          COALESCENCE_BONUS = 0.1

          COHESION_LABELS = [
            { range: (0.8..1.0), label: :unified },
            { range: (0.6...0.8), label: :cohesive },
            { range: (0.4...0.6), label: :scattered },
            { range: (0.2...0.4), label: :dispersed },
            { range: (0.0...0.2), label: :atomized }
          ].freeze

          FLUIDITY_LABELS = [
            { range: (0.8..1.0), label: :liquid },
            { range: (0.6...0.8), label: :flowing },
            { range: (0.4...0.6), label: :viscous },
            { range: (0.2...0.4), label: :sluggish },
            { range: (0.0...0.2), label: :solid }
          ].freeze

          module_function

          def label_for(table, value)
            clamped = value.clamp(0.0, 1.0)
            entry = table.find { |row| row[:range].include?(clamped) }
            entry ? entry[:label] : table.last[:label]
          end
        end
      end
    end
  end
end
