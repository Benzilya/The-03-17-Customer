# The 03:17 Customer — Production Roadmap

This file is the project-wide progress tracker. Percentages are planning estimates, not measured completion metrics, and are updated as the playable build matures.

## Current overall progress: ~39%

The foundation and Night 1 vertical slice exist. The current focus is Godot 4.7.x stabilization, real local playtesting, and locking bilingual EN/RU UI architecture before the larger authored-quality art/audio and Nights 2–6 content passes.

## Milestones

- [x] M1 — Concept, story hook, GDD, repository foundation (8%)
- [x] M2 — Main menu, settings, save bootstrap (6%)
- [x] M3 — First-person controller and procedural store blockout (6%)
- [x] M4 — Night 1 gameplay systems: customers, checkout, CCTV, 03:17 decision (8%)
- [x] M5 — First atmosphere pass: rain, lighting, audio prototype, cinematic 03:17, physical checkout props (7%)
- [ ] M6 — Godot 4.7.x runtime stabilization and complete Night 1 playtest (5%) — IN PROGRESS
- [ ] M7 — Visual quality pass: materials, store dressing, authored props, improved customer presentation, post-processing (10%)
- [ ] M8 — Audio quality pass: authored ambience, scanner/door/footsteps/electrical sounds, mix and spatial audio (6%)
- [ ] M9 — Night 2 and anomaly verification mechanics (7%)
- [ ] M10 — Nights 3–4, evidence/lore progression, advanced CCTV contradictions (10%)
- [ ] M11 — Nights 5–6, final 03:17 confrontation, four ending routes (10%)
- [ ] M12 — Save/load progression, settings completeness, subtitles/accessibility, full English/Russian localization (5%)
- [ ] M13 — Performance/graphics presets, input polish, bug fixing and balancing (5%)
- [ ] M14 — Full-game QA, credits/legal/license audit, export presets and release-candidate packaging (7%)

Total planned weight: 100%.

## Language commitment

The shipping game must support both English and Russian.

- English remains the canonical source text for internal content keys.
- Russian is a first-class supported language, not a post-release add-on.
- Main menu language selection is implemented in Settings and persisted in `user://settings.cfg`.
- A shared localization dictionary now exists in `scripts/localization.gd`.
- All future story/UI strings should move through localization keys rather than being permanently hard-coded in gameplay scripts.
- Night 1 gameplay/dialogue localization is the next localization task during M6/M7.

## Playability gates

### Gate A — First playable
Target: Night 1 can be completed from main menu to result without parser/runtime errors.
Expected overall project progress at gate: ~40%.

### Gate B — Public-facing vertical slice
Target: polished Night 1 with improved graphics/audio, bilingual UI/dialogue, and reliable performance.
Expected overall project progress at gate: ~55–60%.

### Gate C — Content complete alpha
Target: Nights 1–6 and all ending routes implemented.
Expected overall project progress at gate: ~85%.

### Gate D — Release candidate
Target: optimized, tested, bilingual packaged build with no known blocker bugs.
Expected overall project progress at gate: 100%.

## Current priority

1. Fix all Godot 4.7.x parser/runtime issues found in the real local playtest.
2. Complete Night 1 end-to-end without blockers.
3. Move Night 1 UI/dialogue to shared EN/RU localization keys.
4. Lock the visual target and replace the weakest procedural placeholders.
5. Begin Night 2 only after the core interaction/CCTV/checkout loop is stable.

## Current M6 changes

- Audio prototype variables explicitly typed for strict Godot 4.7.x parsing.
- Player and checkout prototype scripts hardened against Variant type-inference warnings.
- Pause menu added for faster QA and restarts.
- Development time-jump helpers added.
- Checkout customer waiting position corrected: NPCs now remain on the public side of REGISTER 01 rather than entering the cashier/player space.
- Customer prototype script explicitly typed for Godot 4.7.x strict warning settings.
- Shared EN/RU localization foundation added.
- Main menu now includes a persistent English/Russian language selector.

## Current QA helpers

The Night 1 scene includes development-only time jumps to accelerate local testing:

- `F8` — jump to 02:30
- `F9` — jump to 03:10
- `F10` — jump to 03:16

These are temporary QA controls and are intended to be disabled before release packaging.

## Art direction commitment

Graphics are part of the development scope. The target is stylized indie realism rather than AAA photorealism: believable PBR-like materials, strong fluorescent/night lighting, wet exterior surfaces, readable silhouettes, convincing store clutter, CCTV-specific rendering, and deliberately uncanny customers. Procedural geometry remains a prototyping layer and should progressively be replaced or upgraded where it is most visible to the player.

## Reporting format

Every development report should state:
- current milestone;
- estimated overall completion percentage;
- work completed in the latest pass;
- known blockers/risks;
- next milestone and remaining major work.
