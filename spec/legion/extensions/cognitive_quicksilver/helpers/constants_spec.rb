# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveQuicksilver::Helpers::Constants do
  describe 'FORM_TYPES' do
    it 'contains expected forms' do
      expect(described_class::FORM_TYPES).to contain_exactly(:liquid, :droplet, :bead, :stream, :pool)
    end

    it 'is frozen' do
      expect(described_class::FORM_TYPES).to be_frozen
    end
  end

  describe 'SURFACE_TYPES' do
    it 'contains expected surfaces' do
      expect(described_class::SURFACE_TYPES).to contain_exactly(:glass, :metal, :wood, :stone, :fabric)
    end

    it 'is frozen' do
      expect(described_class::SURFACE_TYPES).to be_frozen
    end
  end

  describe 'numeric constants' do
    it 'MAX_DROPLETS is 500' do
      expect(described_class::MAX_DROPLETS).to eq(500)
    end

    it 'MAX_POOLS is 50' do
      expect(described_class::MAX_POOLS).to eq(50)
    end

    it 'FLUIDITY_BASE is 0.8' do
      expect(described_class::FLUIDITY_BASE).to eq(0.8)
    end

    it 'SURFACE_TENSION is 0.3' do
      expect(described_class::SURFACE_TENSION).to eq(0.3)
    end

    it 'EVAPORATION_RATE is 0.02' do
      expect(described_class::EVAPORATION_RATE).to eq(0.02)
    end

    it 'COALESCENCE_BONUS is 0.1' do
      expect(described_class::COALESCENCE_BONUS).to eq(0.1)
    end
  end

  describe '.label_for' do
    context 'with COHESION_LABELS' do
      it 'returns :unified for mass near 1.0' do
        expect(described_class.label_for(described_class::COHESION_LABELS, 0.95)).to eq(:unified)
      end

      it 'returns :cohesive for mid-high mass' do
        expect(described_class.label_for(described_class::COHESION_LABELS, 0.7)).to eq(:cohesive)
      end

      it 'returns :scattered for mid mass' do
        expect(described_class.label_for(described_class::COHESION_LABELS, 0.5)).to eq(:scattered)
      end

      it 'returns :dispersed for lower mass' do
        expect(described_class.label_for(described_class::COHESION_LABELS, 0.3)).to eq(:dispersed)
      end

      it 'returns :atomized for very low mass' do
        expect(described_class.label_for(described_class::COHESION_LABELS, 0.05)).to eq(:atomized)
      end
    end

    context 'with FLUIDITY_LABELS' do
      it 'returns :liquid for high fluidity' do
        expect(described_class.label_for(described_class::FLUIDITY_LABELS, 0.9)).to eq(:liquid)
      end

      it 'returns :flowing for upper-mid fluidity' do
        expect(described_class.label_for(described_class::FLUIDITY_LABELS, 0.65)).to eq(:flowing)
      end

      it 'returns :viscous for mid fluidity' do
        expect(described_class.label_for(described_class::FLUIDITY_LABELS, 0.5)).to eq(:viscous)
      end

      it 'returns :sluggish for lower-mid fluidity' do
        expect(described_class.label_for(described_class::FLUIDITY_LABELS, 0.25)).to eq(:sluggish)
      end

      it 'returns :solid for very low fluidity' do
        expect(described_class.label_for(described_class::FLUIDITY_LABELS, 0.05)).to eq(:solid)
      end
    end

    it 'clamps values above 1.0' do
      result = described_class.label_for(described_class::FLUIDITY_LABELS, 1.5)
      expect(result).to eq(:liquid)
    end

    it 'clamps values below 0.0' do
      result = described_class.label_for(described_class::FLUIDITY_LABELS, -0.5)
      expect(result).to eq(:solid)
    end
  end
end
