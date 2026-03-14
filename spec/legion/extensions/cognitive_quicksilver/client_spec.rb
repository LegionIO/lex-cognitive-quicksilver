# frozen_string_literal: true

require 'legion/extensions/cognitive_quicksilver/client'

RSpec.describe Legion::Extensions::CognitiveQuicksilver::Client do
  let(:client) { described_class.new }

  it 'responds to all runner methods' do
    %i[create_droplet create_pool shift_form merge split capture release add_to_pool
       list_droplets quicksilver_status].each do |method|
      expect(client).to respond_to(method)
    end
  end

  it 'maintains isolated state per instance' do
    client_a = described_class.new
    client_b = described_class.new

    client_a.create_droplet(form: :liquid, content: 'exclusive to a')
    expect(client_a.quicksilver_status[:total_droplets]).to eq(1)
    expect(client_b.quicksilver_status[:total_droplets]).to eq(0)
  end

  it 'round-trips a full quicksilver cycle' do
    # Create droplet
    d_result = client.create_droplet(form: :droplet, content: 'round trip idea')
    expect(d_result[:success]).to be true
    droplet_id = d_result[:droplet][:id]

    # Create pool
    p_result = client.create_pool(surface_type: :glass)
    expect(p_result[:success]).to be true
    pool_id = p_result[:pool][:id]

    # Shift form
    shift_result = client.shift_form(droplet_id: droplet_id, new_form: :liquid)
    expect(shift_result[:droplet][:form]).to eq(:liquid)

    # Add to pool
    add_result = client.add_to_pool(droplet_id: droplet_id, pool_id: pool_id)
    expect(add_result[:pool][:droplet_count]).to eq(1)

    # Capture
    cap_result = client.capture(droplet_id: droplet_id)
    expect(cap_result[:droplet][:captured]).to be true

    # Release
    rel_result = client.release(droplet_id: droplet_id)
    expect(rel_result[:droplet][:captured]).to be false

    # Status report
    status = client.quicksilver_status
    expect(status[:total_droplets]).to eq(1)
    expect(status[:total_pools]).to eq(1)
  end

  it 'handles merge and split lifecycle' do
    a = client.create_droplet(form: :stream, content: 'stream a', mass: 0.4)
    b = client.create_droplet(form: :stream, content: 'stream b', mass: 0.3)
    a_id = a[:droplet][:id]
    b_id = b[:droplet][:id]

    merged = client.merge(droplet_a_id: a_id, droplet_b_id: b_id)
    expect(merged[:success]).to be true
    merged_mass = merged[:droplet][:mass]
    expect(merged_mass).to be > 0.4

    split = client.split(droplet_id: a_id)
    expect(split[:success]).to be true
    expect(split[:twin][:id]).not_to eq(a_id)
  end
end
