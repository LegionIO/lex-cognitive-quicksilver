# lex-cognitive-quicksilver

A LegionIO cognitive architecture extension that models mental fluidity using a mercury metaphor. Cognitive content flows, coalesces, splits, and evaporates as droplets of varying form and mass.

## What It Does

Represents thought-units as **droplets** moving across cognitive surfaces. Droplets have:

- **Form**: liquid, droplet, bead, stream, or pool — each with different fluidity characteristics
- **Mass**: accumulates through merging, depletes through evaporation
- **Fluidity**: determines how easily the droplet moves; capture reduces fluidity, release restores it

Droplets can collect into **pools** on surfaces (glass, metal, wood, stone, fabric). Pools track depth and surface tension; agitating a pool releases some droplets.

This extension provides a low-level building block for modeling states of mental flow, dissociation, and cognitive cohesion.

## Usage

```ruby
require 'lex-cognitive-quicksilver'

client = Legion::Extensions::CognitiveQuicksilver::Client.new

# Create a droplet
result = client.create_droplet(form: :droplet, content: 'working memory fragment')
droplet_id = result[:droplet][:id]

# Create a pool and add the droplet
pool_result = client.create_pool(surface_type: :glass)
client.add_to_pool(droplet_id: droplet_id, pool_id: pool_result[:pool][:id])

# Shift form and check state
client.shift_form(droplet_id: droplet_id, new_form: :stream)
client.quicksilver_status
# => { total_droplets: 1, total_pools: 1, elusive_count: 0, ... }
```

### Key Operations

```ruby
# Merge two droplets
client.merge(droplet_a_id: id1, droplet_b_id: id2)

# Split a droplet in half (requires mass > 0.2)
client.split(droplet_id: id)

# Capture a droplet (reduces fluidity)
client.capture(droplet_id: id)

# Release it again
client.release(droplet_id: id)

# List all droplets
client.list_droplets
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
