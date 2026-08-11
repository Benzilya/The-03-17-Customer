# The 03:17 Customer — Production Roadmap

This file is the project-wide progress tracker. Percentages are planning estimates, not measured completion metrics, and are updated as the playable build matures.

## Current overall progress: ~48%

Gate A has been reached in a real Godot 4.7.x local playtest. The project is now in the final portion of M7: visual readability, bilingual Night 1 presentation, character refinement and CCTV treatment.

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
The shipping game supports English and Russian as first-class languages. Main-menu selection persists in `user://settings.cfg`. Night 1 localization now includes the story beats plus customer names/dialogue, checkout terminology, movement/interact HUD, results and transaction messages. Remaining hard-coded CCTV labels are scheduled for the final M7 cleanup.

## Playability gates
### Gate A — First playable — REACHED
Night 1 reaches the 03:17 decision and completes the SERVE outcome in a real Godot 4.7.x run.

### Gate B — Public-facing vertical slice
Target: polished Night 1 with improved graphics/audio, bilingual UI/dialogue, and reliable performance. Expected overall progress: ~55–60%.

### Gate C — Content complete alpha
Target: Nights 1–6 and all ending routes implemented. Expected overall progress: ~85%.

### Gate D — Release candidate
Target: optimized, tested, bilingual packaged build with no known blocker bugs. Expected overall progress: 100%.

## Current priority
1. Wire the expanded EN/RU dictionary through remaining Night 1 HUD/checkout/CCTV code.
2. Rebuild the signature bearded regular so the approved concept reads naturally rather than as procedural tendrils.
3. Improve manager-note presentation and prevent 720p text overlap.
4. Finish CCTV treatment and scene-material/lighting cleanup.
5. Verify REFUSE branch and then begin M8 audio quality pass.

## Current M7 changes
- Improved register framing, store dressing, ceiling fixtures, refrigerators, products and clutter.
- Improved procedural customer silhouettes and increased customer waiting distance.
- Added Space jump, Ctrl crouch and Shift sprint.
- Fixed freed-customer runtime reference in the procedural audio monitor.
- Added the signature hat/glasses/beard regular as an initial prototype; second character-art pass remains required.
- Reduced scanner glow based on real gameplay screenshots.
- Expanded EN/RU dictionary to cover movement HUD, interactions, normal customer names/dialogue, products, checkout states/actions, payment messages and both Night 1 outcomes.
- Real local screenshots remain the visual QA source of truth.

## Current controls
- WASD — movement
- Mouse — look
- E — interact
- Space — jump
- Left/Right Ctrl — crouch
- Left/Right Shift — sprint
- Esc — pause
- F8/F9/F10 — QA time jumps (development only)

## Art direction commitment
Target: stylized indie realism rather than AAA photorealism, with believable materials, strong fluorescent/night lighting, wet exterior surfaces, readable silhouettes, convincing store clutter, CCTV-specific rendering and deliberately uncanny customers. Procedural geometry is a prototyping layer and is progressively replaced/upgraded where most visible.

## Reporting format
Every development report must state current milestone, estimated overall completion percentage, work completed, known blockers/risks, and next milestone / remaining major work.
