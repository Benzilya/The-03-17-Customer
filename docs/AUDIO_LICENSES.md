# Audio asset licenses

The project is moving away from synthetic/procedural placeholder SFX toward recorded assets.

## Approved sources (verified CC0)

### Kenney — RPG Audio
Official source: https://kenney.nl/assets/rpg-audio
Verified license: Creative Commons CC0 1.0 Universal
Attribution required: no
Mirror used for file inspection: https://github.com/ETdoFresh/kenney.nl/tree/master/kenney_rpgaudio/Audio
Selected files:
- footstep00.ogg
- footstep01.ogg
- footstep02.ogg
- footstep03.ogg
- doorOpen_1.ogg
- doorClose_1.ogg
Intended use: player footsteps and convenience-store entrance door movement.

### Kenney — Interface Sounds
Official source: https://kenney.nl/assets/interface-sounds
Verified license: Creative Commons CC0 1.0 Universal
Attribution required: no
Mirror used for file inspection: https://github.com/ETdoFresh/kenney.nl/tree/master/kenney_interfacesounds/Audio
Selected files:
- confirmation_001.ogg — checkout scanner candidate
- confirmation_002.ogg — payment confirmation candidate
- glitch_001.ogg — CCTV transition/interference candidate
Intended use: checkout and CCTV UI/SFX after listening QA.

### Footsteps — GboxMikeFozzy / OpenGameArt
Source: https://opengameart.org/content/footsteps-0
License: CC0
Attribution required: no
Files offered by source: 01-footstep.ogg through 06-footstep.ogg
Status: alternate candidate if Kenney footsteps do not fit the store floor.

### Rain — OveMelaa / OpenGameArt
Source: https://opengameart.org/content/rain-ambient-not-loopable-2-versions-available
License: CC0
Attribution required: no
Files offered by source: Ove Melaa - Rainy (NOT loopable).ogg and long version
Intended use: exterior/window rain bed.

### 100 CC0 SFX #2 — rubberduck / OpenGameArt
Source: https://opengameart.org/content/100-cc0-sfx-2
License: CC0
Attribution required: no
Pack: sfx_100_v2.zip
Includes recorded/edited door, footsteps, ambient machine loops, switches, metal, wood and other effects.
Intended use: machinery and environmental foley after auditioning individual files.

## Integration paths
Recorded SFX are expected under `res://assets/audio/cc0/` and are loaded by `scripts/recorded_sfx_bank.gd`. The loader is deliberately tolerant of missing files so development builds remain playable while binary assets are being imported.

## Policy for shipped audio
- Prefer CC0 for repository audio whenever a suitable recording exists.
- Do not add a sound merely because a search result says “royalty free”; verify the actual license page first.
- Keep this file updated with source, author, license and intended use before release.
- Procedural tones may remain only for intentionally supernatural/non-diegetic 03:17 design, not ordinary real-world sounds such as footsteps, doors, rain or appliances.
