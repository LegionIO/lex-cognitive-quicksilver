# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveQuicksilver
      module Helpers
        class QuicksilverEngine
          def initialize
            @droplets = {}
            @pools    = {}
          end

          def create_droplet(form:, content:, **)
            raise ArgumentError, 'droplet limit reached' if @droplets.size >= Constants::MAX_DROPLETS

            droplet = Droplet.new(form: form, content: content, **)
            @droplets[droplet.id] = droplet
            droplet
          end

          def create_pool(surface_type:, **)
            raise ArgumentError, 'pool limit reached' if @pools.size >= Constants::MAX_POOLS

            pool = Pool.new(surface_type: surface_type, **)
            @pools[pool.id] = pool
            pool
          end

          def shift_form(droplet_id:, new_form:)
            droplet = fetch_droplet!(droplet_id)
            droplet.shift_form!(new_form)
            droplet
          end

          def merge_droplets(droplet_a_id:, droplet_b_id:)
            a = fetch_droplet!(droplet_a_id)
            b = fetch_droplet!(droplet_b_id)
            a.merge!(b)
            @droplets.delete(droplet_b_id)
            a
          end

          def split_droplet(droplet_id:)
            droplet = fetch_droplet!(droplet_id)
            twin = droplet.split!
            return nil unless twin

            @droplets[twin.id] = twin
            [droplet, twin]
          end

          def capture_droplet(droplet_id:)
            fetch_droplet!(droplet_id).capture!
          end

          def release_droplet(droplet_id:)
            fetch_droplet!(droplet_id).release!
          end

          def add_to_pool(droplet_id:, pool_id:)
            fetch_droplet!(droplet_id)
            pool = fetch_pool!(pool_id)
            pool.add_droplet(droplet_id)
            pool
          end

          def agitate_pool(pool_id:)
            fetch_pool!(pool_id).agitate!
          end

          def evaporate_all!
            vanished = []
            @droplets.each_value(&:evaporate!)
            @droplets.each { |id, d| vanished << id if d.vanishing? }
            vanished.each { |id| @droplets.delete(id) }
            vanished
          end

          def quicksilver_report
            droplets = @droplets.values
            total    = droplets.size
            {
              total_droplets:  total,
              total_pools:     @pools.size,
              captured_count:  droplets.count(&:captured),
              elusive_count:   droplets.count(&:elusive?),
              vanishing_count: droplets.count(&:vanishing?),
              avg_mass:        avg_metric(droplets, total, :mass),
              avg_fluidity:    avg_metric(droplets, total, :fluidity)
            }
          end

          def droplets
            @droplets.values.map(&:to_h)
          end

          def pools
            @pools.values.map(&:to_h)
          end

          private

          def avg_metric(droplets, total, method)
            return 0.0 if total.zero?

            (droplets.sum(&method) / total.to_f).round(10)
          end

          def fetch_droplet!(id)
            @droplets.fetch(id) { raise ArgumentError, "droplet not found: #{id}" }
          end

          def fetch_pool!(id)
            @pools.fetch(id) { raise ArgumentError, "pool not found: #{id}" }
          end
        end
      end
    end
  end
end
