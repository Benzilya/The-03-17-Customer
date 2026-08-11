# The 03:17 Customer — Production Roadmap

## Current progress
- Functional/system progress: ~95%
- Visual production progress: ~48%

M1–M13 are feature-implemented. M14 is now split into a dense graphics production pass followed by full-game runtime QA, audio/license completion, export and release-candidate stabilization. The visual percentage is tracked separately because the gameplay systems are much further along than the final art quality.

## Milestones
- [x] M1 — Concept, story hook, GDD, repository foundation (8%)
- [x] M2 — Main menu, settings, save bootstrap (6%)
- [x] M3 — First-person controller and procedural store blockout (6%)
- [x] M4 — Night 1 gameplay systems: customers, checkout, CCTV, 03:17 decision (8%)
- [x] M5 — First atmosphere pass: rain, lighting, audio prototype, cinematic 03:17, physical checkout props (7%)
- [x] M6 — Godot 4.7.x runtime stabilization and complete Night 1 playtest (5%) — GATE A
- [x] M7 — Visual quality/readability pass (10%)
- [x] M8 — Audio quality implementation pass (6%) — RECORDED-SFX QA DEBT
- [x] M9 — Night 2 and anomaly verification mechanics (7%) — FEATURE COMPLETE / RUNTIME QA DEBT
- [x] M10 — Nights 3–4, evidence/lore progression, advanced CCTV contradictions (10%) — FEATURE COMPLETE / RUNTIME QA DEBT
- [x] M11 — Nights 5–6, final 03:17 confrontation, four ending routes (10%) — FEATURE COMPLETE / RUNTIME QA DEBT
- [x] M12 — Save/load progression, settings completeness, subtitles/accessibility, full English/Russian localization (5%) — FEATURE COMPLETE / RUNTIME QA DEBT
- [x] M13 — Performance/graphics presets, input polish, bug fixing and balancing (5%) — FEATURE COMPLETE / RUNTIME QA DEBT
- [ ] M14 — GRAPHICS PRODUCTION + full QA + release candidate (7%) — ACTIVE

Total production milestones: 14 (M1–M14).

## M14 graphics production — Pass 1 complete
- Shared production visual runtime injected into Nights 1–6.
- Store floor receives commercial tile/grout and wear language instead of a single uninterrupted plane.
- Added baseboards, utility/electrical details, conduit, fire equipment, signage and scale cues.
- Added authored-looking ceiling fixture language and intentionally dead fixtures for less procedural repetition.
- Register cluster receives monitor/bezel, receipt printer/slot, paper, trim and counter fabrication details.
- Added shipping cartons, tape, mop/bucket, extinguisher and back-room clutter.
- Employee rest room receives headboard, bedding detail, bedside table, mug and notice board.
- Lighting gains cool register/fridge/entrance pools and a contrasting warm rest-room pool.
- Customer V2 implemented: revised head proportions, jaw/chin, cheeks, ears, better eyes, brows, nose, hair masses, layered clothing and improved limbs.
- Signature beard customer rebuilt around the approved silhouette with round glasses, hat, dense beard and multiple curled locks.
- Anomaly/CCTV visibility layer behavior preserved.

Detailed art-pass notes: `docs/M14_GRAPHICS_PASS.md`.

## M14 graphics next
1. Runtime screenshot QA and eliminate z-fighting/geometry overlap with Night 1 legacy M7 layers.
2. Add distinct clothing/silhouette variants per recurring visitor instead of primarily recoloring one body.
3. Improve glass, wet surfaces, reflections and CCTV image treatment.
4. Increase prop fidelity at the register and rest room where the player stands closest.
5. Add authored external textures/models where licensing and import path are available.
6. Capture before/after screenshots at 1280×720 and tune lighting from real Godot output.

## M14 release work after graphics
1. Run complete Nights 1–6 progression in Godot 4.7.x.
2. Regression-test RU/EN, accessibility, save recovery, bed transitions and all endings.
3. Profile Low/Balanced/High presets and fix runtime blockers.
4. Physically import/finalize recorded CC0 ordinary SFX and complete license manifest.
5. Audit credits, licenses and third-party asset provenance.
6. Create/verify Windows export preset and release folder structure.
7. Fix release-blocking bugs and produce release-candidate checklist/package.

## Gates
- Gate A — first playable: reached.
- Gate B — polished public-facing Night 1: implementation reached; final visual/audio/runtime verification pending.
- Gate C — content-complete alpha: reached by feature scope.
- Gate D — release candidate: M14 target.

## Reporting format
Every development report states: milestone, functional progress, visual progress, completed work, current repository/game size, blockers/risks and next major work.
