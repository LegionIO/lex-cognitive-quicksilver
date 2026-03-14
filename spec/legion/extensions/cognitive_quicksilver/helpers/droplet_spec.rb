# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveQuicksilver::Helpers::Droplet do
  let(:droplet) { described_class.new(form: :droplet, content: 'test idea') }

  describe '#initialize' do
    it 'assigns a uuid id' do
      expect(droplet.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets form' do
      expect(droplet.form).to eq(:droplet)
    end

    it 'sets content' do
      expect(droplet.content).to eq('test idea')
    end

    it 'defaults mass to 0.3' do
      expect(droplet.mass).to eq(0.3)
    end

    it 'defaults fluidity to FLUIDITY_BASE' do
      expect(droplet.fluidity).to eq(Legion::Extensions::CognitiveQuicksilver::Helpers::Constants::FLUIDITY_BASE)
    end

    it 'defaults surface to :glass' do
      expect(droplet.surface).to eq(:glass)
    end

    it 'defaults captured to false' do
      expect(droplet.captured).to be false
    end

    it 'clamps mass above 1.0' do
      d = described_class.new(form: :liquid, content: 'x', mass: 1.5)
      expect(d.mass).to eq(1.0)
    end

    it 'clamps mass below 0.0' do
      d = described_class.new(form: :liquid, content: 'x', mass: -0.5)
      expect(d.mass).to eq(0.0)
    end

    it 'raises ArgumentError for invalid form' do
      expect { described_class.new(form: :vapor, content: 'x') }.to raise_error(ArgumentError, /invalid form/)
    end

    it 'raises ArgumentError for invalid surface' do
      expect do
        described_class.new(form: :droplet, content: 'x', surface: :air)
      end.to raise_error(ArgumentError, /invalid surface/)
    end

    it 'sets created_at' do
      expect(droplet.created_at).to be_a(Time)
    end
  end

  describe '#shift_form!' do
    it 'changes the form' do
      droplet.shift_form!(:liquid)
      expect(droplet.form).to eq(:liquid)
    end

    it 'adjusts fluidity based on form' do
      droplet.shift_form!(:liquid)
      expect(droplet.fluidity).to eq(0.9)
    end

    it 'sets low fluidity for pool form' do
      droplet.shift_form!(:pool)
      expect(droplet.fluidity).to eq(0.3)
    end

    it 'returns self for chaining' do
      expect(droplet.shift_form!(:bead)).to be(droplet)
    end

    it 'raises ArgumentError for invalid form' do
      expect { droplet.shift_form!(:fog) }.to raise_error(ArgumentError, /invalid form/)
    end
  end

  describe '#merge!' do
    let(:other) { described_class.new(form: :liquid, content: 'other', mass: 0.4) }

    it 'combines mass with coalescence bonus' do
      bonus         = Legion::Extensions::CognitiveQuicksilver::Helpers::Constants::COALESCENCE_BONUS
      original_mass = droplet.mass
      droplet.merge!(other)
      expected = [original_mass + other.mass + bonus, 1.0].min
      expect(droplet.mass).to be_within(0.001).of(expected)
    end

    it 'clamps merged mass to 1.0' do
      heavy_a = described_class.new(form: :pool, content: 'a', mass: 0.7)
      heavy_b = described_class.new(form: :pool, content: 'b', mass: 0.7)
      heavy_a.merge!(heavy_b)
      expect(heavy_a.mass).to eq(1.0)
    end

    it 'returns self for chaining' do
      expect(droplet.merge!(other)).to be(droplet)
    end

    it 'averages fluidity' do
      original_fluidity = droplet.fluidity
      expected_fluidity = (original_fluidity + other.fluidity) / 2.0
      droplet.merge!(other)
      expect(droplet.fluidity).to be_within(0.001).of(expected_fluidity)
    end
  end

  describe '#split!' do
    context 'when mass is sufficient (> 0.2)' do
      let(:heavy_droplet) { described_class.new(form: :droplet, content: 'big idea', mass: 0.6) }

      it 'returns a twin droplet' do
        twin = heavy_droplet.split!
        expect(twin).to be_a(described_class)
      end

      it 'halves the original mass' do
        heavy_droplet.split!
        expect(heavy_droplet.mass).to be_within(0.001).of(0.3)
      end

      it 'twin has half the original mass' do
        original_mass = heavy_droplet.mass
        twin = heavy_droplet.split!
        expect(twin.mass).to be_within(0.001).of(original_mass / 2.0)
      end

      it 'twin has a different id' do
        twin = heavy_droplet.split!
        expect(twin.id).not_to eq(heavy_droplet.id)
      end

      it 'twin inherits form and surface' do
        twin = heavy_droplet.split!
        expect(twin.form).to eq(heavy_droplet.form)
        expect(twin.surface).to eq(heavy_droplet.surface)
      end
    end

    context 'when mass is too small (<= 0.2)' do
      let(:tiny_droplet) { described_class.new(form: :bead, content: 'tiny', mass: 0.15) }

      it 'returns nil' do
        expect(tiny_droplet.split!).to be_nil
      end

      it 'does not change the mass' do
        original = tiny_droplet.mass
        tiny_droplet.split!
        expect(tiny_droplet.mass).to eq(original)
      end
    end
  end

  describe '#capture!' do
    it 'sets captured to true' do
      droplet.capture!
      expect(droplet.captured).to be true
    end

    it 'halves the fluidity' do
      original_fluidity = droplet.fluidity
      droplet.capture!
      expect(droplet.fluidity).to be_within(0.001).of(original_fluidity / 2.0)
    end

    it 'returns self' do
      expect(droplet.capture!).to be(droplet)
    end
  end

  describe '#release!' do
    before { droplet.capture! }

    it 'sets captured to false' do
      droplet.release!
      expect(droplet.captured).to be false
    end

    it 'restores fluidity (doubles it, clamped)' do
      fluidity_after_capture = droplet.fluidity
      droplet.release!
      expect(droplet.fluidity).to be_within(0.001).of([fluidity_after_capture * 2.0, 1.0].min)
    end

    it 'returns self' do
      expect(droplet.release!).to be(droplet)
    end
  end

  describe '#evaporate!' do
    it 'reduces mass by EVAPORATION_RATE' do
      original_mass = droplet.mass
      droplet.evaporate!
      expected = original_mass - Legion::Extensions::CognitiveQuicksilver::Helpers::Constants::EVAPORATION_RATE
      expect(droplet.mass).to be_within(0.001).of(expected)
    end

    it 'does not go below 0.0' do
      tiny = described_class.new(form: :bead, content: 'x', mass: 0.01)
      tiny.evaporate!
      expect(tiny.mass).to be >= 0.0
    end

    it 'returns self' do
      expect(droplet.evaporate!).to be(droplet)
    end
  end

  describe '#elusive?' do
    it 'returns true when fluidity >= 0.7 and not captured' do
      d = described_class.new(form: :liquid, content: 'elusive', fluidity: 0.8)
      expect(d.elusive?).to be true
    end

    it 'returns false when captured' do
      droplet.capture!
      expect(droplet.elusive?).to be false
    end

    it 'returns false when fluidity < 0.7' do
      d = described_class.new(form: :pool, content: 'slow', fluidity: 0.3)
      expect(d.elusive?).to be false
    end
  end

  describe '#stable?' do
    it 'returns true when captured' do
      droplet.capture!
      expect(droplet.stable?).to be true
    end

    it 'returns true when fluidity < 0.4' do
      d = described_class.new(form: :pool, content: 'stable', fluidity: 0.2)
      expect(d.stable?).to be true
    end

    it 'returns false for default high-fluidity uncaptured droplet' do
      d = described_class.new(form: :liquid, content: 'free', fluidity: 0.8)
      expect(d.stable?).to be false
    end
  end

  describe '#vanishing?' do
    it 'returns true when mass < 0.1' do
      d = described_class.new(form: :bead, content: 'fading', mass: 0.05)
      expect(d.vanishing?).to be true
    end

    it 'returns false for normal mass' do
      expect(droplet.vanishing?).to be false
    end
  end

  describe '#cohesion_label' do
    it 'returns a symbol' do
      expect(droplet.cohesion_label).to be_a(Symbol)
    end

    it 'returns :unified for mass 1.0' do
      d = described_class.new(form: :pool, content: 'x', mass: 1.0)
      expect(d.cohesion_label).to eq(:unified)
    end

    it 'returns :atomized for mass near 0.0' do
      d = described_class.new(form: :bead, content: 'x', mass: 0.05)
      expect(d.cohesion_label).to eq(:atomized)
    end
  end

  describe '#fluidity_label' do
    it 'returns a symbol' do
      expect(droplet.fluidity_label).to be_a(Symbol)
    end

    it 'returns :liquid for fluidity 0.9' do
      d = described_class.new(form: :liquid, content: 'x', fluidity: 0.9)
      expect(d.fluidity_label).to eq(:liquid)
    end

    it 'returns :solid for fluidity 0.1' do
      d = described_class.new(form: :bead, content: 'x', fluidity: 0.1)
      expect(d.fluidity_label).to eq(:solid)
    end
  end

  describe '#to_h' do
    it 'returns a hash with all expected keys' do
      h = droplet.to_h
      expect(h.keys).to include(:id, :form, :content, :mass, :fluidity, :surface, :captured,
                                :elusive, :stable, :vanishing, :cohesion, :fluidity_lbl, :created_at)
    end

    it 'id matches droplet id' do
      expect(droplet.to_h[:id]).to eq(droplet.id)
    end

    it 'reflects captured state' do
      droplet.capture!
      expect(droplet.to_h[:captured]).to be true
    end
  end
end
