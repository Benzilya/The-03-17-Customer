# The 03:17 Customer — Production Roadmap

## Current overall progress: ~85%

M1–M11 are now feature-implemented. M9–M11 retain runtime QA debt in Godot 4.7.x, and M8 still needs the final recorded-CC0 SFX import/listening pass. M12 is next: progression/save robustness, settings completeness, subtitles/accessibility and full RU/EN localization audit.

## Milestones
- [x] M1 — Concept, story hook, GDD, repository foundation (8%)
- [x] M2 — Main menu, settings, save bootstrap (6%)
- [x] M3 — First-person controller and procedural store blockout (6%)
- [x] M4 — Night 1 gameplay systems: customers, checkout, CCTV, 03:17 decision (8%)
- [x] M5 — First atmosphere pass: rain, lighting, audio prototype, cinematic 03:17, physical checkout props (7%)
- [x] M6 — Godot 4.7.x runtime stabilization and complete Night 1 playtest (5%) — GATE A
- [x] M7 — Visual quality/readability pass: store dressing, improved customers, bilingual Night 1 UI, manager-note modal, CCTV presentation (10%)
- [x] M8 — Audio quality implementation pass (6%) — RECORDED-SFX QA DEBT
- [x] M9 — Night 2 and anomaly verification mechanics (7%) — FEATURE COMPLETE / RUNTIME QA DEBT
- [x] M10 — Nights 3–4, evidence/lore progression, advanced CCTV contradictions (10%) — FEATURE COMPLETE / RUNTIME QA DEBT
- [x] M11 — Nights 5–6, final 03:17 confrontation, four ending routes (10%) — FEATURE COMPLETE / RUNTIME QA DEBT
- [ ] M12 — Save/load progression, settings completeness, subtitles/accessibility, full English/Russian localization (5%)
- [ ] M13 — Performance/graphics presets, input polish, bug fixing and balancing (5%)
- [ ] M14 — Full-game QA, credits/legal/license audit, export presets and release-candidate packaging (7%)

Total production milestones: 14 (M1–M14).

## M11 closed scope
- Night 5 identity verification: badge, biometric and handwritten manager record.
- Night 5 03:17 Namekeeper confrontation and paper/system identity choice.
- Shared employee rest-room/bed transition carries Night 5 directly into Night 6.
- Night 6 inherits memory, identity, threat and previous 03:17 decisions.
- Active final 03:17 Customer confrontation with three player choices.
- Four implemented endings: Escape, Witness, Merge, Replaced.
- Persistent `ending_id`, `final_choice`, `game_complete` and `unlocked_endings` history.
- Ending screen supports replay Night 6 and return to main menu.
- Late-game lore establishes 03:17 as synchronized record/identity corruption; paper written before a corruption event acts as an independent anchor.
- The 417-day Merge history is a fabricated identity-cycle, not a literal time-loop requirement.
- RU/EN player-facing presentation is implemented for current M11 content.

Detailed M11 verification checklist: `docs/M11_QA.md`.

## M12 next
1. Harden save schema and progression recovery for Nights 1–6.
2. Add/finish settings persistence and reset behavior.
3. Add subtitle controls and accessibility options.
4. Audit every player-facing string in RU/EN.
5. Add ending-history presentation in the menu if it fits the final UI.

## Cross-milestone QA debt
- Physically import selected CC0 ordinary SFX and perform listening/mix QA.
- Run Nights 2–6 in Godot 4.7.x at 1280x720 in both RU and EN.
- Verify rest-room geometry and bed interaction in Nights 1–5.
- Verify every save transition and all four endings.
- Fix all parser/runtime blockers before Gate C is declared runtime-clean.

## Gates
- Gate A — first playable: reached.
- Gate B — polished public-facing Night 1: pending recorded-audio QA.
- Gate C — content-complete alpha: feature scope reached at ~85%; runtime-clean status still pending QA.
- Gate D — release candidate: 100%.

## Reporting format
Every development report states: milestone, overall progress, milestone progress, completed work, current repository/game size, blockers/risks and next major work.
