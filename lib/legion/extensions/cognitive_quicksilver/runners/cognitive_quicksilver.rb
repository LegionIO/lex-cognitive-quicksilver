# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveQuicksilver
      module Runners
        module CognitiveQuicksilver
          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)

          def create_droplet(form: :droplet, content: '', engine: nil, **)
            raise ArgumentError, "invalid form: #{form}" unless Helpers::Constants::FORM_TYPES.include?(form)

            eng = engine || quicksilver_engine
            droplet = eng.create_droplet(form: form, content: content.to_s)
            Legion::Logging.debug "[cognitive_quicksilver] create_droplet id=#{droplet.id} form=#{droplet.form}"
            { success: true, droplet: droplet.to_h }
          rescue ArgumentError => e
            Legion::Logging.debug "[cognitive_quicksilver] create_droplet failed: #{e.message}"
            { success: false, error: e.message }
          end

          def create_pool(surface_type: :glass, engine: nil, **)
            raise ArgumentError, "invalid surface_type: #{surface_type}" unless Helpers::Constants::SURFACE_TYPES.include?(surface_type)

            eng = engine || quicksilver_engine
            pool = eng.create_pool(surface_type: surface_type)
            Legion::Logging.debug "[cognitive_quicksilver] create_pool id=#{pool.id} surface=#{pool.surface_type}"
            { success: true, pool: pool.to_h }
          rescue ArgumentError => e
            Legion::Logging.debug "[cognitive_quicksilver] create_pool failed: #{e.message}"
            { success: false, error: e.message }
          end

          def shift_form(droplet_id:, new_form:, engine: nil, **)
            raise ArgumentError, "invalid form: #{new_form}" unless Helpers::Constants::FORM_TYPES.include?(new_form)

            eng = engine || quicksilver_engine
            droplet = eng.shift_form(droplet_id: droplet_id, new_form: new_form)
            Legion::Logging.debug "[cognitive_quicksilver] shift_form id=#{droplet_id} new_form=#{new_form}"
            { success: true, droplet: droplet.to_h }
          rescue ArgumentError => e
            Legion::Logging.debug "[cognitive_quicksilver] shift_form failed: #{e.message}"
            { success: false, error: e.message }
          end

          def merge(droplet_a_id:, droplet_b_id:, engine: nil, **)
            eng = engine || quicksilver_engine
            droplet = eng.merge_droplets(droplet_a_id: droplet_a_id, droplet_b_id: droplet_b_id)
            Legion::Logging.debug "[cognitive_quicksilver] merge a=#{droplet_a_id} b=#{droplet_b_id} result_mass=#{droplet.mass.round(2)}"
            { success: true, droplet: droplet.to_h }
          rescue ArgumentError => e
            Legion::Logging.debug "[cognitive_quicksilver] merge failed: #{e.message}"
            { success: false, error: e.message }
          end

          def split(droplet_id:, engine: nil, **)
            eng = engine || quicksilver_engine
            result = eng.split_droplet(droplet_id: droplet_id)
            if result.nil?
              Legion::Logging.debug "[cognitive_quicksilver] split id=#{droplet_id} too_small"
              return { success: false, error: 'droplet mass too small to split' }
            end

            original, twin = result
            Legion::Logging.debug "[cognitive_quicksilver] split id=#{droplet_id} twin_id=#{twin.id}"
            { success: true, original: original.to_h, twin: twin.to_h }
          rescue ArgumentError => e
            Legion::Logging.debug "[cognitive_quicksilver] split failed: #{e.message}"
            { success: false, error: e.message }
          end

          def capture(droplet_id:, engine: nil, **)
            eng = engine || quicksilver_engine
            droplet = eng.capture_droplet(droplet_id: droplet_id)
            Legion::Logging.debug "[cognitive_quicksilver] capture id=#{droplet_id} fluidity=#{droplet.fluidity.round(2)}"
            { success: true, droplet: droplet.to_h }
          rescue ArgumentError => e
            Legion::Logging.debug "[cognitive_quicksilver] capture failed: #{e.message}"
            { success: false, error: e.message }
          end

          def release(droplet_id:, engine: nil, **)
            eng = engine || quicksilver_engine
            droplet = eng.release_droplet(droplet_id: droplet_id)
            Legion::Logging.debug "[cognitive_quicksilver] release id=#{droplet_id} fluidity=#{droplet.fluidity.round(2)}"
            { success: true, droplet: droplet.to_h }
          rescue ArgumentError => e
            Legion::Logging.debug "[cognitive_quicksilver] release failed: #{e.message}"
            { success: false, error: e.message }
          end

          def add_to_pool(droplet_id:, pool_id:, engine: nil, **)
            eng = engine || quicksilver_engine
            pool = eng.add_to_pool(droplet_id: droplet_id, pool_id: pool_id)
            Legion::Logging.debug "[cognitive_quicksilver] add_to_pool droplet=#{droplet_id} pool=#{pool_id}"
            { success: true, pool: pool.to_h }
          rescue ArgumentError => e
            Legion::Logging.debug "[cognitive_quicksilver] add_to_pool failed: #{e.message}"
            { success: false, error: e.message }
          end

          def list_droplets(engine: nil, **)
            eng = engine || quicksilver_engine
            items = eng.droplets
            Legion::Logging.debug "[cognitive_quicksilver] list_droplets count=#{items.size}"
            { success: true, droplets: items, count: items.size }
          end

          def quicksilver_status(engine: nil, **)
            eng = engine || quicksilver_engine
            report = eng.quicksilver_report
            Legion::Logging.debug "[cognitive_quicksilver] status droplets=#{report[:total_droplets]} pools=#{report[:total_pools]}"
            { success: true, **report }
          end

          private

          def quicksilver_engine
            @quicksilver_engine ||= Helpers::QuicksilverEngine.new
          end
        end
      end
    end
  end
end
