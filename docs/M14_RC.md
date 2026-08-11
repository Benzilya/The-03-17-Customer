# M14 — Release Candidate Checklist

Repository/virtual implementation status: COMPLETE.
Actual release-candidate status: BLOCKED ON RUNTIME QA + FINAL ART/AUDIO IMPORT.

## Implemented release structure
- Windows Desktop export preset exists at `export_presets.cfg`.
- Main menu routes Nights 1–6 through validated saves.
- Bed transitions create checkpoints and advance Nights 1–5.
- Four endings and ending archive are implemented.
- RU/EN, accessibility, graphics presets and pause/restart flows are implemented.
- Production procedural visual runtime is shared across Nights 1–6.
- Third-party/license manifest exists and explicitly blocks unverified assets.

## Required human/runtime QA before calling a build RC
1. Open project in Godot 4.7.x with zero parser blockers.
2. Complete Night 1 → bed → Night 2 → ... → Night 6.
3. Verify every physical evidence station and interaction range.
4. Verify no customer clips through counter/walls and customers stop at comfortable distance.
5. Verify rest room geometry is reachable in Nights 1–5.
6. Trigger all four endings and verify ending archive persistence.
7. Repeat critical UI paths in Russian and English at 1280×720.
8. Test Small/Normal/Large text and Reduce Flashing.
9. Test Low/Balanced/High graphics presets on target Windows hardware.
10. Confirm save recovery from backup after intentionally corrupting the primary save.
11. Import approved recorded ordinary SFX and perform listening/mix pass.
12. Capture representative runtime screenshots for visual QA.
13. Inspect the new production visual layer for overlap/z-fighting in all nights.
14. Verify Customer V2 proportions and signature-beard visitor in actual camera perspective.
15. Export Windows Desktop release build and smoke-test the exported EXE, not only editor play.

## Release blocker policy
Any parser error, progression blocker, save loss, inaccessible bed/evidence station, broken ending, missing required license, or exported-build startup failure blocks Gate D.

Visual-quality issues that materially resemble placeholder geometry also remain blockers for the intended public visual target, even if the game is functionally playable.

## Size planning
Repository size is not equivalent to shipped game size. Godot runtime/export binaries form a significant fixed base; textures, models and recorded audio will dominate final content size once imported.

Target planning envelope for a compact Windows indie build:
- procedural/current-content prototype export: roughly 80–150 MB;
- production build with compressed textures, character/environment assets and recorded audio: roughly 250–600 MB;
- soft budget: keep first public release below 750 MB unless visual/audio quality clearly justifies more.

These are planning estimates, not measured export sizes. Final size must be measured from the actual exported release folder.
