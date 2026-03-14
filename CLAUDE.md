# lex-cognitive-quicksilver

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-cognitive-quicksilver`
- **Version**: 0.1.0
- **Namespace**: `Legion::Extensions::CognitiveQuicksilver`

## Purpose

Models cognitive fluidity as a mercury-like substance. Thoughts, impulses, and mental contents are represented as **droplets** that can merge, split, evaporate, be captured, or pool together. The metaphor reflects how cognitive content flows, coalesces, and transforms in states of high versus low mental fluidity.

## Gem Info

- **Gemspec**: `lex-cognitive-quicksilver.gemspec`
- **Require**: `lex-cognitive-quicksilver`
- **Ruby**: >= 3.4
- **License**: MIT
- **Homepage**: https://github.com/LegionIO/lex-cognitive-quicksilver

## File Structure

```
lib/legion/extensions/cognitive_quicksilver/
  version.rb                          # VERSION = '0.1.0'
  helpers/
    constants.rb                      # FORM_TYPES, SURFACE_TYPES, label tables, fluidity constants
    droplet.rb                        # Droplet class — individual unit of cognitive content
    pool.rb                           # Pool class — collection of droplets on a surface
    quicksilver_engine.rb             # QuicksilverEngine — manages droplets and pools
  runners/
    cognitive_quicksilver.rb          # Runner module — public API methods
  client.rb                           # Client class — instantiates engine, includes runner
```

## Key Constants

| Constant | Value | Meaning |
|---|---|---|
| `FORM_TYPES` | `[:liquid, :droplet, :bead, :stream, :pool]` | Valid droplet forms |
| `SURFACE_TYPES` | `[:glass, :metal, :wood, :stone, :fabric]` | Valid pool/droplet surfaces |
| `MAX_DROPLETS` | 500 | Hard cap on tracked droplets |
| `MAX_POOLS` | 50 | Hard cap on tracked pools |
| `FLUIDITY_BASE` | 0.8 | Default fluidity for new droplets |
| `SURFACE_TENSION` | 0.3 | Default pool surface tension |
| `EVAPORATION_RATE` | 0.02 | Mass reduction per `evaporate!` call |
| `COALESCENCE_BONUS` | 0.1 | Extra mass added when two droplets merge |

## Key Classes

### `Helpers::Droplet`

An individual unit of cognitive content with form, mass, fluidity, and surface properties.

- `shift_form!(new_form)` — changes form and adjusts fluidity to `FORM_FLUIDITY[form]`
- `merge!(other_droplet)` — absorbs another droplet; mass sums + coalescence bonus; fluidity averages
- `split!` — halves mass and spawns twin; returns nil if mass <= 0.2
- `capture!` / `release!` — halves/doubles fluidity; toggles `@captured` flag
- `evaporate!` — reduces mass by `EVAPORATION_RATE`
- `elusive?` — fluidity >= 0.7 and not captured
- `stable?` — fluidity < 0.4 or captured
- `vanishing?` — mass < 0.1

### `Helpers::Pool`

A surface that holds droplets.

- `add_droplet(id)` / `remove_droplet(id)` — adjusts depth by `DEPTH_CHANGE`
- `agitate!` — lowers surface tension, probabilistically releases droplets
- `settle!` — raises surface tension
- `reflective?` — depth >= 0.7 and surface_tension >= 0.5
- `shallow?` — depth < 0.2

### `Helpers::QuicksilverEngine`

Registry and coordinator for droplets and pools.

- `create_droplet(form:, content:, **)` — enforces MAX_DROPLETS
- `create_pool(surface_type:, **)` — enforces MAX_POOLS
- `shift_form / merge_droplets / split_droplet / capture_droplet / release_droplet`
- `add_to_pool(droplet_id:, pool_id:)`
- `agitate_pool(pool_id:)`
- `evaporate_all!` — evaporates all droplets, removes vanishing ones, returns removed IDs
- `quicksilver_report` — aggregate counts and averages

## Runners

Module: `Legion::Extensions::CognitiveQuicksilver::Runners::CognitiveQuicksilver`

| Runner | Key Args | Returns |
|---|---|---|
| `create_droplet` | `form:`, `content:` | `{ success:, droplet: }` |
| `create_pool` | `surface_type:` | `{ success:, pool: }` |
| `shift_form` | `droplet_id:`, `new_form:` | `{ success:, droplet: }` |
| `merge` | `droplet_a_id:`, `droplet_b_id:` | `{ success:, droplet: }` |
| `split` | `droplet_id:` | `{ success:, original:, twin: }` or `{ success: false, error: }` |
| `capture` | `droplet_id:` | `{ success:, droplet: }` |
| `release` | `droplet_id:` | `{ success:, droplet: }` |
| `add_to_pool` | `droplet_id:`, `pool_id:` | `{ success:, pool: }` |
| `list_droplets` | — | `{ success:, droplets:, count: }` |
| `quicksilver_status` | — | aggregate report hash |

All runners accept optional `engine:` keyword to inject a test engine instance.

## Helpers

- `Constants#label_for(table, value)` — range-table lookup for `COHESION_LABELS` and `FLUIDITY_LABELS`
- `Droplet#cohesion_label` / `#fluidity_label` — delegates to `Constants.label_for`

## Integration Points

- No direct dependencies on other LegionIO extensions
- Designed as a standalone cognitive metaphor subsystem
- Can be wired into `lex-tick` phase handlers via `lex-cortex` if a fluidity signal is needed
- All state is in-memory per `QuicksilverEngine` instance; no persistence

## Development Notes

- The `engine:` keyword in each runner method allows test injection without mocking global state
- `split!` returns `nil` (not an error) when mass <= 0.2; runner handles this as `{ success: false, error: }`
- `merge!` deletes the absorbed droplet from the engine registry; only one object remains
- `evaporate_all!` is a batch operation; individual evaporation is only through direct Droplet calls
- No actors defined; this extension is driven entirely by external calls or task triggers
