# M13 — Performance, Input Polish, Bug Fixing and Balance

Status: FEATURE COMPLETE / RUNTIME QA GATE

## Implemented
- Shared graphics-performance runtime for all Night scenes.
- Three presets: Low, Balanced, High.
- Low: 75% 3D render scale, MSAA disabled.
- Balanced: 90% 3D render scale, MSAA 2x.
- High: 100% 3D render scale, MSAA 4x.
- Frame cap standardized at 60 FPS for deterministic timing and stable prototype behavior.
- Graphics preset persists in `settings.cfg`.
- Night 1 pause menu exposes the graphics preset.
- Nights 2–6 receive the universal pause menu and the same graphics preset control.
- Restart Current Night now reloads the actual active scene instead of hard-routing to Night 1.
- Shared player movement now uses acceleration/deceleration instead of instant horizontal velocity changes.
- Jump is edge-triggered rather than repeated every landing while Space is held.
- Added 110 ms coyote time and 120 ms jump buffer for more forgiving first-person movement.
- Crouch, sprint and jump retain the existing user-facing controls.
- Mouse sensitivity remains persistent from M12.
- Accessibility and performance runtime layers are injected in all Night scenes by the shared player controller.

## Balance decisions
- Walk speed: 4.2 m/s.
- Sprint speed: 6.8 m/s.
- Crouch speed: 2.4 m/s.
- Jump velocity: 4.8.
- Interaction ray remains 3.0 m so evidence stations/bed do not require pixel-perfect positioning.
- Horizontal acceleration: 28; deceleration: 34 to retain responsive horror-game movement without abrupt start/stop snapping.
- 60 FPS cap is intentional for the current compatibility-renderer target; uncapped/high-refresh support can be reconsidered after release-candidate profiling.

## Required Godot runtime QA
1. Run Night 1 on Low/Balanced/High and confirm the viewport changes without scene reload.
2. Confirm selected graphics preset persists after returning to menu and reloading the game.
3. Confirm ESC pause works in Nights 1–6.
4. Confirm Restart Current Night reloads Night 2–6 correctly instead of Night 1.
5. Hold Space through a landing; confirm the character does not auto-bunny-hop.
6. Press Jump shortly before landing and verify jump buffering feels correct.
7. Walk off a small edge and press Jump immediately afterward; verify coyote time works once.
8. Test sprint + jump, crouch + movement, and rapid crouch transitions.
9. Verify mouse capture restores after closing pause menus.
10. Verify evidence stations, CCTV stations and bed interaction remain comfortable at 3 m ray range.
11. Run all presets at 1280x720 in RU and EN.
12. Watch the Godot debugger for parser/runtime errors.
13. Profile FPS during CCTV and 03:17 effects on Low/Balanced/High.
14. Verify Reduce Flashing remains honored after changing graphics preset.
15. Regression-test all save transitions and all four endings after movement/runtime injection changes.

## Closure rule
M13 feature work is complete. Any failures found in these checks become M14 release-candidate bug fixes. No additional M13 system is required unless runtime QA identifies a blocker.
