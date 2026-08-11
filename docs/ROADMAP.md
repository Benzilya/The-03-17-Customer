# The 03:17 Customer — Production Roadmap

This file is the project-wide progress tracker. Percentages are planning estimates, not measured completion metrics, and are updated as the playable build matures.

## Current overall progress: ~40%

Gate A has been reached in a real Godot 4.7.x local playtest: Night 1 reaches the 03:17 decision and the SERVE branch completes to the Night 1 result. The project now moves into the visual-quality phase while continuing cleanup of bilingual UI and remaining Night 1 polish.

## Milestones

- [x] M1 — Concept, story hook, GDD, repository foundation (8%)
- [x] M2 — Main menu, settings, save bootstrap (6%)
- [x] M3 — First-person controller and procedural store blockout (6%)
- [x] M4 — Night 1 gameplay systems: customers, checkout, CCTV, 03:17 decision (8%)
- [x] M5 — First atmosphere pass: rain, lighting, audio prototype, cinematic 03:17, physical checkout props (7%)
- [x] M6 — Godot 4.7.x runtime stabilization and complete Night 1 playtest (5%) — GATE A REACHED
- [ ] M7 — Visual quality pass: materials, store dressing, authored props, improved customer presentation, post-processing (10%) — IN PROGRESS
- [ ] M8 — Audio quality pass: authored ambience, scanner/door/footsteps/electrical sounds, mix and spatial audio (6%)
- [ ] M9 — Night 2 and anomaly verification mechanics (7%)
- [ ] M10 — Nights 3–4, evidence/lore progression, advanced CCTV contradictions (10%)
- [ ] M11 — Nights 5–6, final 03:17 confrontation, four ending routes (10%)
- [ ] M12 — Save/load progression, settings completeness, subtitles/accessibility, full English/Russian localization (5%)
- [ ] M13 — Performance/graphics presets, input polish, bug fixing and balancing (5%)
- [ ] M14 — Full-game QA, credits/legal/license audit, export presets and release-candidate packaging (7%)

Total planned weight: 100%.

## Language commitment

The shipping game must support both English and Russian. Russian is a first-class supported language, not a post-release add-on. Main menu language selection is implemented in Settings and persisted in `user://settings.cfg`. A shared localization dictionary exists in `scripts/localization.gd`, and Night 1 is progressively moving to localized keys.

## Playability gates

### Gate A — First playable — REACHED
Night 1 can reach the 03:17 decision and complete the SERVE outcome in a real Godot 4.7.x run.

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

1. Improve visual readability and composition based on real gameplay screenshots.
2. Continue EN/RU cleanup for all remaining Night 1 hard-coded text.
3. Improve checkout props, customer framing, materials, lighting and store dressing.
4. Verify the REFUSE branch during ongoing QA.
5. Move toward Gate B before expanding into Night 2.

## Current M7 changes

- Removed oversized world-space checkout item labels that obscured the camera view.
- Increased customer waiting distance and reduced prototype head/body scale for more natural checkout framing.
- Localized the 03:17 decision prompt so Russian mode no longer mixes English text in the central choice panel.
- Real local screenshots are now being used as the visual QA source of truth.

## Current QA helpers

The Night 1 scene includes development-only time jumps to accelerate local testing:

- `F8` — jump to 02:30
- `F9` — jump to 03:10
- `F10` — jump to 03:16

These are temporary QA controls and are intended to be disabled before release packaging.

## Art direction commitment

Graphics are part of the development scope. The target is stylized indie realism rather than AAA photorealism: believable PBR-like materials, strong fluorescent/night lighting, wet exterior surfaces, readable silhouettes, convincing store clutter, CCTV-specific rendering, and deliberately uncanny customers. Procedural geometry remains a prototyping layer and should progressively be replaced or upgraded where it is most visible to the player.

## Reporting format

Every development report should state current milestone, estimated overall completion percentage, work completed in the latest pass, known blockers/risks, and the next milestone / remaining major work.
