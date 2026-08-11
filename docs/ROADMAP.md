# The 03:17 Customer — Production Roadmap

This file is the project-wide progress tracker. Percentages are planning estimates, not measured completion metrics, and are updated as the playable build matures.

## Current overall progress: ~35%

The foundation and Night 1 vertical slice exist, but the project still needs runtime stabilization, authored-quality art/audio, Nights 2–6, endings, balancing, optimization, accessibility, packaging, and final QA.

## Milestones

- [x] M1 — Concept, story hook, GDD, repository foundation (8%)
- [x] M2 — Main menu, settings, save bootstrap (6%)
- [x] M3 — First-person controller and procedural store blockout (6%)
- [x] M4 — Night 1 gameplay systems: customers, checkout, CCTV, 03:17 decision (8%)
- [x] M5 — First atmosphere pass: rain, lighting, audio prototype, cinematic 03:17, physical checkout props (7%)
- [ ] M6 — Godot 4.7.x runtime stabilization and complete Night 1 playtest (5%)
- [ ] M7 — Visual quality pass: materials, store dressing, authored props, improved customer presentation, post-processing (10%)
- [ ] M8 — Audio quality pass: authored ambience, scanner/door/footsteps/electrical sounds, mix and spatial audio (6%)
- [ ] M9 — Night 2 and anomaly verification mechanics (7%)
- [ ] M10 — Nights 3–4, evidence/lore progression, advanced CCTV contradictions (10%)
- [ ] M11 — Nights 5–6, final 03:17 confrontation, four ending routes (10%)
- [ ] M12 — Save/load progression, settings completeness, subtitles/accessibility, localization-ready text (5%)
- [ ] M13 — Performance/graphics presets, input polish, bug fixing and balancing (5%)
- [ ] M14 — Full-game QA, credits/legal/license audit, export presets and release-candidate packaging (7%)

Total planned weight: 100%.

## Playability gates

### Gate A — First playable
Target: Night 1 can be completed from main menu to result without parser/runtime errors.
Expected overall project progress at gate: ~40%.

### Gate B — Public-facing vertical slice
Target: polished Night 1 with improved graphics/audio and reliable performance.
Expected overall project progress at gate: ~55–60%.

### Gate C — Content complete alpha
Target: Nights 1–6 and all ending routes implemented.
Expected overall project progress at gate: ~85%.

### Gate D — Release candidate
Target: optimized, tested, packaged build with no known blocker bugs.
Expected overall project progress at gate: 100%.

## Current priority

1. Fix all Godot 4.7.x parser/runtime issues found in the real local playtest.
2. Complete Night 1 end-to-end without blockers.
3. Lock the visual target and replace the weakest procedural placeholders.
4. Begin Night 2 only after the core interaction/CCTV/checkout loop is stable.

## Art direction commitment

Graphics are part of the development scope. The target is stylized indie realism rather than AAA photorealism: believable PBR-like materials, strong fluorescent/night lighting, wet exterior surfaces, readable silhouettes, convincing store clutter, CCTV-specific rendering, and deliberately uncanny customers. Procedural geometry remains a prototyping layer and should progressively be replaced or upgraded where it is most visible to the player.

## Reporting format

Every development report should state:
- current milestone;
- estimated overall completion percentage;
- work completed in the latest pass;
- known blockers/risks;
- next milestone and remaining major work.
