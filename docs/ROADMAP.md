# The 03:17 Customer — Production Roadmap

## Current progress
- Repository / virtual implementation progress: 100%
- Functional/system implementation: 100% planned scope present
- Visual production progress relative to intended public target: ~48%
- Runtime QA / release validation: NOT COMPLETE

M1–M14 now have their planned repository-side implementation and release structure in place. This does **not** mean the game is a verified release candidate: final art assets, recorded-audio import, actual Godot 4.7.x playthroughs, exported-build testing and release-blocker fixes still require runtime/human validation.

## Milestones
- [x] M1 — Concept, story hook, GDD, repository foundation
- [x] M2 — Main menu, settings, save bootstrap
- [x] M3 — First-person controller and procedural store blockout
- [x] M4 — Night 1 gameplay systems
- [x] M5 — First atmosphere pass
- [x] M6 — Godot runtime stabilization / Gate A
- [x] M7 — Visual quality/readability pass
- [x] M8 — Audio quality implementation pass — recorded-SFX runtime debt remains
- [x] M9 — Night 2 and anomaly verification — runtime QA debt remains
- [x] M10 — Nights 3–4 and advanced evidence — runtime QA debt remains
- [x] M11 — Nights 5–6 and four endings — runtime QA debt remains
- [x] M12 — Save/settings/accessibility/RU-EN systems — runtime QA debt remains
- [x] M13 — Performance presets/input polish/balance implementation — runtime QA debt remains
- [x] M14 — Repository-side graphics/release structure/RC preparation — RUNTIME + FINAL ART/AUDIO VALIDATION REMAINS

Total planned milestones: 14 (M1–M14).

## M14 repository-side completion
- Shared production visual runtime used by Nights 1–6.
- Customer V2 procedural character pass and signature-beard visitor upgrade.
- Store/environment production-art pass 1.
- Low/Balanced/High graphics presets and 60 FPS target structure.
- Windows Desktop export preset at `export_presets.cfg`.
- Third-party/license manifest at `docs/THIRD_PARTY_LICENSES.md`.
- Release-candidate/runtime checklist at `docs/M14_RC.md`.
- Save recovery, bed transitions, all four endings, RU/EN and accessibility already integrated from earlier milestones.

## Remaining work before a true Gate D release candidate
These are validation/art-production tasks rather than missing roadmap systems:
1. Run complete Nights 1–6 progression in Godot 4.7.x and fix every parser/runtime blocker.
2. Capture actual runtime screenshots and tune lighting/material overlap from real output.
3. Replace remaining primitive-looking character/environment elements with final authored meshes/textures where needed.
4. Import only verified/licensed recorded ordinary SFX and complete listening/mix QA.
5. Verify bed/evidence interaction ranges, late-game choices, save recovery and all endings.
6. Test RU/EN and accessibility at 1280×720.
7. Profile Low/Balanced/High presets on target Windows hardware.
8. Export Windows Desktop build and smoke-test the exported EXE.
9. Measure the actual release-folder size and update the size budget.

## Size budget
GitHub repository size is not the same as game installation size.

Planning envelope:
- Current source repository: measured from GitHub metadata.
- Current procedural prototype Windows export: estimated ~80–150 MB.
- Intended production Windows release with compressed character/environment art + recorded audio: estimated ~250–600 MB.
- Soft upper budget for first release: <750 MB unless visual/audio quality clearly justifies more.

Final numbers must be measured from an actual exported release folder; estimates are not measurements.

## Gates
- Gate A — first playable: reached.
- Gate B — public-facing Night 1 implementation: reached; final visual/audio validation remains.
- Gate C — content-complete alpha scope: reached.
- Gate D — true release candidate: blocked on runtime QA, final art/audio validation and exported-build smoke test.

## Reporting format
Every development report states: virtual/functional progress, visual progress, runtime-validation status, current repository/game size, completed work, blockers and next concrete work.
