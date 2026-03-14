# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveQuicksilver::Helpers::QuicksilverEngine do
  let(:engine) { described_class.new }

  describe '#create_droplet' do
    it 'creates and stores a droplet' do
      droplet = engine.create_droplet(form: :liquid, content: 'thought')
      expect(droplet).to be_a(Legion::Extensions::CognitiveQuicksilver::Helpers::Droplet)
    end

    it 'accepts optional kwargs' do
      droplet = engine.create_droplet(form: :bead, content: 'idea', mass: 0.5, surface: :metal)
      expect(droplet.mass).to eq(0.5)
      expect(droplet.surface).to eq(:metal)
    end

    it 'raises ArgumentError when limit reached' do
      stub_const('Legion::Extensions::CognitiveQuicksilver::Helpers::Constants::MAX_DROPLETS', 1)
      engine.create_droplet(form: :liquid, content: 'first')
      expect { engine.create_droplet(form: :bead, content: 'second') }.to raise_error(ArgumentError, /limit/)
    end
  end

  describe '#create_pool' do
    it 'creates and stores a pool' do
      pool = engine.create_pool(surface_type: :glass)
      expect(pool).to be_a(Legion::Extensions::CognitiveQuicksilver::Helpers::Pool)
    end

    it 'raises ArgumentError when limit reached' do
      stub_const('Legion::Extensions::CognitiveQuicksilver::Helpers::Constants::MAX_POOLS', 1)
      engine.create_pool(surface_type: :glass)
      expect { engine.create_pool(surface_type: :metal) }.to raise_error(ArgumentError, /limit/)
    end
  end

  describe '#shift_form' do
    let(:droplet) { engine.create_droplet(form: :droplet, content: 'shifting') }

    it 'changes the droplet form' do
      engine.shift_form(droplet_id: droplet.id, new_form: :liquid)
      expect(droplet.form).to eq(:liquid)
    end

    it 'raises ArgumentError for unknown droplet' do
      expect { engine.shift_form(droplet_id: 'nope', new_form: :liquid) }.to raise_error(ArgumentError, /not found/)
    end
  end

  describe '#merge_droplets' do
    let(:a) { engine.create_droplet(form: :droplet, content: 'a', mass: 0.3) }
    let(:b) { engine.create_droplet(form: :liquid, content: 'b', mass: 0.2) }

    it 'merges b into a' do
      result = engine.merge_droplets(droplet_a_id: a.id, droplet_b_id: b.id)
      expect(result.id).to eq(a.id)
    end

    it 'removes droplet b from store' do
      b_id = b.id
      engine.merge_droplets(droplet_a_id: a.id, droplet_b_id: b_id)
      expect { engine.shift_form(droplet_id: b_id, new_form: :bead) }.to raise_error(ArgumentError)
    end

    it 'increases merged mass' do
      original_a_mass = a.mass
      engine.merge_droplets(droplet_a_id: a.id, droplet_b_id: b.id)
      expect(a.mass).to be > original_a_mass
    end
  end

  describe '#split_droplet' do
    context 'when droplet is large enough' do
      let(:big) { engine.create_droplet(form: :stream, content: 'big', mass: 0.8) }

      it 'returns an array of two droplets' do
        result = engine.split_droplet(droplet_id: big.id)
        expect(result).to be_an(Array)
        expect(result.length).to eq(2)
      end

      it 'adds twin to engine' do
        result = engine.split_droplet(droplet_id: big.id)
        twin = result[1]
        expect { engine.shift_form(droplet_id: twin.id, new_form: :bead) }.not_to raise_error
      end
    end

    context 'when droplet is too small' do
      let(:tiny) { engine.create_droplet(form: :bead, content: 'tiny', mass: 0.1) }

      it 'returns nil' do
        expect(engine.split_droplet(droplet_id: tiny.id)).to be_nil
      end
    end

    it 'raises ArgumentError for unknown droplet' do
      expect { engine.split_droplet(droplet_id: 'unknown') }.to raise_error(ArgumentError, /not found/)
    end
  end

  describe '#capture_droplet' do
    let(:droplet) { engine.create_droplet(form: :liquid, content: 'free') }

    it 'captures the droplet' do
      engine.capture_droplet(droplet_id: droplet.id)
      expect(droplet.captured).to be true
    end

    it 'raises for unknown id' do
      expect { engine.capture_droplet(droplet_id: 'ghost') }.to raise_error(ArgumentError)
    end
  end

  describe '#release_droplet' do
    let(:droplet) { engine.create_droplet(form: :liquid, content: 'trapped') }
    before { engine.capture_droplet(droplet_id: droplet.id) }

    it 'releases the droplet' do
      engine.release_droplet(droplet_id: droplet.id)
      expect(droplet.captured).to be false
    end
  end

  describe '#add_to_pool' do
    let(:droplet) { engine.create_droplet(form: :droplet, content: 'pooling') }
    let(:pool)    { engine.create_pool(surface_type: :stone) }

    it 'adds droplet to pool' do
      engine.add_to_pool(droplet_id: droplet.id, pool_id: pool.id)
      expect(pool.droplet_ids).to include(droplet.id)
    end

    it 'raises for unknown pool' do
      expect { engine.add_to_pool(droplet_id: droplet.id, pool_id: 'ghost') }.to raise_error(ArgumentError)
    end

    it 'raises for unknown droplet' do
      expect { engine.add_to_pool(droplet_id: 'ghost', pool_id: pool.id) }.to raise_error(ArgumentError)
    end
  end

  describe '#agitate_pool' do
    let(:pool) { engine.create_pool(surface_type: :fabric) }

    it 'returns an array of released droplet ids' do
      result = engine.agitate_pool(pool_id: pool.id)
      expect(result).to be_an(Array)
    end

    it 'raises for unknown pool' do
      expect { engine.agitate_pool(pool_id: 'nope') }.to raise_error(ArgumentError)
    end
  end

  describe '#evaporate_all!' do
    it 'reduces all droplet masses' do
      d = engine.create_droplet(form: :droplet, content: 'evap', mass: 0.5)
      original = d.mass
      engine.evaporate_all!
      expect(d.mass).to be < original
    end

    it 'removes vanishing droplets' do
      d = engine.create_droplet(form: :bead, content: 'fading', mass: 0.05)
      d_id = d.id
      engine.evaporate_all!
      expect { engine.capture_droplet(droplet_id: d_id) }.to raise_error(ArgumentError)
    end

    it 'returns array of removed ids' do
      d = engine.create_droplet(form: :bead, content: 'ghost', mass: 0.05)
      removed = engine.evaporate_all!
      expect(removed).to include(d.id)
    end
  end

  describe '#quicksilver_report' do
    it 'returns a hash with expected keys' do
      report = engine.quicksilver_report
      expect(report.keys).to include(:total_droplets, :total_pools, :captured_count,
                                     :elusive_count, :vanishing_count, :avg_mass, :avg_fluidity)
    end

    it 'counts droplets' do
      engine.create_droplet(form: :liquid, content: 'a')
      engine.create_droplet(form: :bead, content: 'b')
      expect(engine.quicksilver_report[:total_droplets]).to eq(2)
    end

    it 'counts pools' do
      engine.create_pool(surface_type: :glass)
      expect(engine.quicksilver_report[:total_pools]).to eq(1)
    end

    it 'computes avg_mass as 0.0 when empty' do
      expect(engine.quicksilver_report[:avg_mass]).to eq(0.0)
    end

    it 'counts captured droplets' do
      d = engine.create_droplet(form: :liquid, content: 'captured', mass: 0.5)
      engine.capture_droplet(droplet_id: d.id)
      expect(engine.quicksilver_report[:captured_count]).to eq(1)
    end
  end

  describe '#droplets' do
    it 'returns array of droplet hashes' do
      engine.create_droplet(form: :stream, content: 'flowing')
      result = engine.droplets
      expect(result).to be_an(Array)
      expect(result.first).to be_a(Hash)
      expect(result.first[:form]).to eq(:stream)
    end
  end

  describe '#pools' do
    it 'returns array of pool hashes' do
      engine.create_pool(surface_type: :wood)
      result = engine.pools
      expect(result).to be_an(Array)
      expect(result.first[:surface_type]).to eq(:wood)
    end
  end
end
