# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CognitiveQuicksilver
      module Helpers
        class Pool
          attr_reader :id, :surface_type, :depth, :droplet_ids, :surface_tension, :created_at

          DEPTH_CHANGE     = 0.05
          TENSION_DECREASE = 0.1
          TENSION_INCREASE = 0.05

          def initialize(surface_type:, depth: 0.5, surface_tension: Constants::SURFACE_TENSION)
            raise ArgumentError, "invalid surface_type: #{surface_type}" unless Constants::SURFACE_TYPES.include?(surface_type)

            @id              = SecureRandom.uuid
            @surface_type    = surface_type
            @depth           = depth.clamp(0.0, 1.0)
            @droplet_ids     = []
            @surface_tension = surface_tension.clamp(0.0, 1.0)
            @created_at      = Time.now.utc
          end

          def add_droplet(droplet_id)
            @droplet_ids << droplet_id unless @droplet_ids.include?(droplet_id)
            @depth = (@depth + DEPTH_CHANGE).clamp(0.0, 1.0).round(10)
            self
          end

          def remove_droplet(droplet_id)
            @droplet_ids.delete(droplet_id)
            @depth = (@depth - DEPTH_CHANGE).clamp(0.0, 1.0).round(10)
            self
          end

          def agitate!
            @surface_tension = (@surface_tension - TENSION_DECREASE).clamp(0.0, 1.0).round(10)
            released = []
            @droplet_ids.each do |did|
              released << did if rand > @surface_tension
            end
            released.each { |did| remove_droplet(did) }
            released
          end

          def settle!
            @surface_tension = (@surface_tension + TENSION_INCREASE).clamp(0.0, 1.0).round(10)
            self
          end

          def reflective?
            @depth >= 0.7 && @surface_tension >= 0.5
          end

          def shallow?
            @depth < 0.2
          end

          def to_h
            {
              id:              @id,
              surface_type:    @surface_type,
              depth:           @depth.round(10),
              droplet_ids:     @droplet_ids.dup,
              droplet_count:   @droplet_ids.size,
              surface_tension: @surface_tension.round(10),
              reflective:      reflective?,
              shallow:         shallow?,
              created_at:      @created_at
            }
          end
        end
      end
    end
  end
end
