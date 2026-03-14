# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CognitiveQuicksilver
      module Helpers
        class Droplet
          attr_reader :id, :form, :content, :mass, :fluidity, :surface, :captured, :created_at

          FORM_FLUIDITY = {
            liquid:  0.9,
            droplet: 0.8,
            bead:    0.7,
            stream:  0.6,
            pool:    0.3
          }.freeze

          def initialize(form:, content:, mass: 0.3, fluidity: Constants::FLUIDITY_BASE, surface: :glass)
            raise ArgumentError, "invalid form: #{form}" unless Constants::FORM_TYPES.include?(form)
            raise ArgumentError, "invalid surface: #{surface}" unless Constants::SURFACE_TYPES.include?(surface)

            @id         = SecureRandom.uuid
            @form       = form
            @content    = content
            @mass       = mass.clamp(0.0, 1.0)
            @fluidity   = fluidity.clamp(0.0, 1.0)
            @surface    = surface
            @captured   = false
            @created_at = Time.now.utc
          end

          def shift_form!(new_form)
            raise ArgumentError, "invalid form: #{new_form}" unless Constants::FORM_TYPES.include?(new_form)

            @form     = new_form
            @fluidity = FORM_FLUIDITY.fetch(new_form, Constants::FLUIDITY_BASE).clamp(0.0, 1.0)
            self
          end

          def merge!(other_droplet)
            @mass     = (@mass + other_droplet.mass + Constants::COALESCENCE_BONUS).clamp(0.0, 1.0)
            @form     = @mass >= other_droplet.mass ? @form : other_droplet.form
            @fluidity = ((@fluidity + other_droplet.fluidity) / 2.0).round(10)
            self
          end

          def split!
            return nil if @mass <= 0.2

            half_mass = (@mass / 2.0).round(10)
            @mass     = half_mass

            self.class.new(
              form:     @form,
              content:  @content,
              mass:     half_mass,
              fluidity: @fluidity,
              surface:  @surface
            )
          end

          def capture!
            @captured  = true
            @fluidity  = (@fluidity / 2.0).round(10)
            self
          end

          def release!
            @captured  = false
            @fluidity  = (@fluidity * 2.0).clamp(0.0, 1.0)
            self
          end

          def evaporate!
            @mass = (@mass - Constants::EVAPORATION_RATE).clamp(0.0, 1.0).round(10)
            self
          end

          def elusive?
            @fluidity >= 0.7 && !@captured
          end

          def stable?
            @fluidity < 0.4 || @captured
          end

          def vanishing?
            @mass < 0.1
          end

          def cohesion_label
            Constants.label_for(Constants::COHESION_LABELS, @mass)
          end

          def fluidity_label
            Constants.label_for(Constants::FLUIDITY_LABELS, @fluidity)
          end

          def to_h
            {
              id:           @id,
              form:         @form,
              content:      @content,
              mass:         @mass.round(10),
              fluidity:     @fluidity.round(10),
              surface:      @surface,
              captured:     @captured,
              elusive:      elusive?,
              stable:       stable?,
              vanishing:    vanishing?,
              cohesion:     cohesion_label,
              fluidity_lbl: fluidity_label,
              created_at:   @created_at
            }
          end
        end
      end
    end
  end
end
