# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveQuicksilver::Helpers::Pool do
  let(:pool) { described_class.new(surface_type: :glass) }

  describe '#initialize' do
    it 'assigns a uuid id' do
      expect(pool.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets surface_type' do
      expect(pool.surface_type).to eq(:glass)
    end

    it 'defaults depth to 0.5' do
      expect(pool.depth).to eq(0.5)
    end

    it 'starts with empty droplet_ids' do
      expect(pool.droplet_ids).to be_empty
    end

    it 'defaults surface_tension to SURFACE_TENSION' do
      expect(pool.surface_tension).to eq(Legion::Extensions::CognitiveQuicksilver::Helpers::Constants::SURFACE_TENSION)
    end

    it 'sets created_at' do
      expect(pool.created_at).to be_a(Time)
    end

    it 'raises ArgumentError for invalid surface_type' do
      expect { described_class.new(surface_type: :vapor) }.to raise_error(ArgumentError, /invalid surface_type/)
    end

    it 'clamps depth at 1.0' do
      p = described_class.new(surface_type: :metal, depth: 1.5)
      expect(p.depth).to eq(1.0)
    end
  end

  describe '#add_droplet' do
    it 'adds a droplet id' do
      pool.add_droplet('abc-123')
      expect(pool.droplet_ids).to include('abc-123')
    end

    it 'increases depth' do
      original = pool.depth
      pool.add_droplet('abc-123')
      expect(pool.depth).to be > original
    end

    it 'does not duplicate ids' do
      pool.add_droplet('dup-id')
      pool.add_droplet('dup-id')
      expect(pool.droplet_ids.count('dup-id')).to eq(1)
    end

    it 'returns self' do
      expect(pool.add_droplet('xyz')).to be(pool)
    end
  end

  describe '#remove_droplet' do
    before { pool.add_droplet('remove-me') }

    it 'removes the droplet id' do
      pool.remove_droplet('remove-me')
      expect(pool.droplet_ids).not_to include('remove-me')
    end

    it 'decreases depth' do
      depth_before = pool.depth
      pool.remove_droplet('remove-me')
      expect(pool.depth).to be < depth_before
    end

    it 'does not raise when removing non-existent id' do
      expect { pool.remove_droplet('ghost-id') }.not_to raise_error
    end
  end

  describe '#agitate!' do
    before do
      5.times { |i| pool.add_droplet("droplet-#{i}") }
      # Set low surface tension so more droplets are likely to be released
      pool.settle!
    end

    it 'reduces surface tension' do
      tension_before = pool.surface_tension
      pool.agitate!
      expect(pool.surface_tension).to be < tension_before
    end

    it 'returns an array' do
      result = pool.agitate!
      expect(result).to be_an(Array)
    end

    it 'does not raise when pool is empty' do
      empty_pool = described_class.new(surface_type: :stone)
      expect { empty_pool.agitate! }.not_to raise_error
    end
  end

  describe '#settle!' do
    it 'increases surface tension' do
      pool.agitate! # lower it first
      tension_after_agitate = pool.surface_tension
      pool.settle!
      expect(pool.surface_tension).to be > tension_after_agitate
    end

    it 'clamps surface tension at 1.0' do
      high_tension_pool = described_class.new(surface_type: :glass, surface_tension: 0.99)
      high_tension_pool.settle!
      expect(high_tension_pool.surface_tension).to eq(1.0)
    end

    it 'returns self' do
      expect(pool.settle!).to be(pool)
    end
  end

  describe '#reflective?' do
    it 'returns true when deep and high tension' do
      deep_pool = described_class.new(surface_type: :glass, depth: 0.8, surface_tension: 0.6)
      expect(deep_pool.reflective?).to be true
    end

    it 'returns false when shallow' do
      shallow = described_class.new(surface_type: :glass, depth: 0.3, surface_tension: 0.8)
      expect(shallow.reflective?).to be false
    end

    it 'returns false when low tension' do
      tense = described_class.new(surface_type: :glass, depth: 0.9, surface_tension: 0.2)
      expect(tense.reflective?).to be false
    end
  end

  describe '#shallow?' do
    it 'returns true when depth < 0.2' do
      shallow = described_class.new(surface_type: :wood, depth: 0.1)
      expect(shallow.shallow?).to be true
    end

    it 'returns false for normal depth' do
      expect(pool.shallow?).to be false
    end
  end

  describe '#to_h' do
    it 'returns a hash with all expected keys' do
      h = pool.to_h
      expect(h.keys).to include(:id, :surface_type, :depth, :droplet_ids, :droplet_count,
                                 :surface_tension, :reflective, :shallow, :created_at)
    end

    it 'reflects droplet_count' do
      pool.add_droplet('d1')
      pool.add_droplet('d2')
      expect(pool.to_h[:droplet_count]).to eq(2)
    end

    it 'droplet_ids is a copy' do
      pool.add_droplet('original')
      h = pool.to_h
      h[:droplet_ids] << 'injected'
      expect(pool.droplet_ids).not_to include('injected')
    end
  end
end
