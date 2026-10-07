# Pass 7 findings

This pass moves into the state/context cluster immediately preceding the main frame dispatcher.

- `0x080491E4` is a signed scaling helper. It uses the magnitude of the first argument and repeatedly halves the second argument while the magnitude exceeds `limit << 8`, preserving sign.
- `0x08049214` clamps an index against an active object's `+0x1C` limit and stores `index + 1` in state byte `+0x7D`.
- `0x08049268` initializes a substantial record rooted at `0x03000FB0`, including sentinel/context fields, counters and multiple state bytes.
- `0x08049348` is a genuine five-entry indirect dispatcher. Its target bodies are deliberately still represented by addresses until each target is independently recovered.

The assembly in `asm/pass7/game_state_cluster.thumb.s` is authoritative; the C reconstruction is deliberately conservative where exact structure ownership remains unresolved.
