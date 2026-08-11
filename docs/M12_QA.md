# M12 — Save / Settings / Accessibility / Localization QA

Status: FEATURE COMPLETE / RUNTIME QA GATE

## Implemented
- Save schema version 2 with migration for older dictionary saves.
- Progress night is clamped to valid Nights 1–6.
- Invalid/missing `unlocked_endings` and completion flags are repaired on load.
- `save_backup.json` recovery path exists if the primary JSON cannot be parsed.
- Bed transition validates current progress and creates a recoverable checkpoint before loading the next night.
- New Game clears primary and backup progression while keeping user settings.
- Main-menu Continue reads the repaired save and still supports the legacy `save.cfg` bootstrap.
- Master volume persists.
- Fullscreen persists.
- Language persists.
- Mouse sensitivity persists and is applied by `player.gd` in every night.
- Transient subtitle/message toggle persists and is applied across Nights 1–6.
- Reduce-flashing option disables the menu glitch flash and enables runtime flash limiting.
- Text size has Small / Normal / Large options and is applied to runtime UI controls.
- Reset Settings restores safe defaults without deleting progress.
- Ending Archive shows 0–4 unlocked endings without revealing locked ending names.
- Russian/English versions exist for all new M12 menu labels and accessibility controls.

## Localization audit rules
- Gameplay names and brand names such as Morrow Market remain consistent between languages.
- `03:17` is never localized into another time format.
- Player-facing actions use Russian infinitive/imperative consistently: ПРОВЕРИТЬ, ДОВЕРИТЬСЯ, ОБСЛУЖИТЬ, ОТКАЗАТЬ.
- CCTV technical language remains concise so 1280x720 layouts are not overloaded.
- Locked ending titles are not exposed before discovery.
- All late-game M9–M11 content already has explicit RU/EN branches; M12 adds RU/EN for its menu/settings additions.

## Required runtime QA
1. Start with no saves: Continue disabled.
2. Create a Night 1 save, quit, Continue returns to correct night.
3. Advance through a bed transition and verify `save_backup.json` is created.
4. Corrupt/delete primary `save.json`; menu must recover from backup.
5. Test legacy `save.cfg` with no JSON.
6. Test volume at 0, 70 and 100 after restart.
7. Test mouse sensitivity at 35%, 100%, 200% after scene changes.
8. Toggle subtitles off/on and confirm transient dialogue/messages follow the option while objective UI remains readable.
9. Toggle Reduce Flashing and confirm menu glitch flicker is suppressed; inspect late-night effects for comfort.
10. Test Small/Normal/Large text at 1280x720 in English and Russian.
11. Test fullscreen persistence after restart.
12. Test language switching and restart persistence.
13. Unlock at least two endings and verify Ending Archive count and hidden locked entries.
14. Reset Settings; ensure save progression/endings remain intact.
15. Confirm Godot debugger contains no parser/runtime blocker.

## M12 closure rule
M12 feature implementation is complete. Runtime QA findings are bug-fix work to be handled in M13/M14 and do not require additional M12 feature scope unless a blocker proves the design incomplete.
