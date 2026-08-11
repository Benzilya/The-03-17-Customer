# M11 — Nights 5–6 Completion / QA

Status: FEATURE COMPLETE / RUNTIME QA GATE

## Implemented gameplay
- Night 5 inherits memory/identity state from Night 4.
- Identity verification compares badge, biometric record and handwritten manager log.
- The Namekeeper arrives at 03:17 and forces the paper-vs-system identity choice.
- Night 5 writes the Night 6 route and unlocks the employee-rest-room bed transition.
- Night 6 inherits memory integrity, identity integrity, threat and Night 5 choice.
- Final 03:17 Customer confrontation is an active three-choice sequence.
- Four endings are implemented and persisted: Escape, Witness, Merge, Replaced.
- Ending unlock history is persisted in `unlocked_endings`.
- Ending screen supports replaying Night 6 or returning to the main menu.
- Current Night 5/6 player-facing strings are available in Russian and English.

## Late-game lore canon
The security system is not the original anomaly. It is an amplifier and record surface. At 03:17, the Customer can make digital records agree on a false history. Repeated agreement causes people to trust the false record until identity itself is overwritten. Handwritten records created before a corruption event are resistant because they are not part of the synchronized camera/database state.

The `417 days` line in the Merge ending is deliberate: it represents the first complete identity-cycle stored by the system. The merged clerk remembers the fabricated employment history as lived memory. This is not presented as a literal time loop; it is a record/identity overwrite cycle.

## Required runtime QA before release
1. Night 4 → bed → Night 5 loads without losing route state.
2. Identity terminal appears and cannot resolve before all three sources are checked.
3. Test paper and system choices at Night 5 03:17.
4. Night 5 save advances to night 6 and bed becomes usable.
5. Night 5 → bed → Night 6 loads the expected route.
6. Night 6 final Customer triggers once at 03:17.
7. Test all final choices and verify each reachable ending condition.
8. Verify `ending_id`, `final_choice`, `game_complete`, and `unlocked_endings` persist.
9. Replay Night 6 does not delete unlocked endings.
10. Return to menu works after every ending.
11. Repeat Night 5 and Night 6 at 1280x720 in RU and EN.
12. Confirm no parser/runtime errors in the Godot debugger.

## M11 closure rule
Feature development for M11 is complete. Runtime QA findings are bug-fix work and must be resolved before Gate C/release, but no additional M11 content is required unless QA exposes a blocker.
