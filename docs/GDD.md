# The 03:17 Customer — Game Design Document

## High concept

A first-person psychological horror game about working the graveyard shift in a roadside convenience store. The player performs ordinary retail tasks while identifying customers who may not be human. Every night builds toward 03:17, when the store begins to overwrite reality.

## Pillars

1. **Routine creates safety.** Scanning items, restocking and cleaning make the store feel familiar.
2. **Observation creates tension.** CCTV, reflections, receipts and customer behavior can contradict one another.
3. **Decisions create consequences.** SERVE, REFUSE and LOCK DOWN choices alter later nights and endings.
4. **The horror is personal.** The final anomaly is not a monster in the store; it is a replacement for the player.

## Setting

**Morrow Market**, a small 24-hour store on an isolated road. The public area contains the entrance, register, refrigerated wall and several aisles. Staff-only spaces include a stockroom, manager office and rear service door. Outside is a wet parking lot surrounded by darkness.

## Story structure

### Night 1 — The Rule
The player learns the store routine. A note warns: "If a customer arrives at 03:17, do not serve them." At 03:17 a normal-looking man buys water. CCTV shows nobody at the counter.

### Night 2 — The Same Customer
A different-looking customer arrives at 03:17, buys the same item and repeats the same phrase. Different cameras disagree about who is standing at the register.

### Night 3 — The Missing Clerk
Old records reveal that a clerk disappeared at 03:17 years ago. CCTV continued showing the missing clerk working for forty minutes after police found the store empty.

### Night 4 — Who Is Working?
The player sees their own double behind the register while physically standing elsewhere. The manager calls and insists the player is visible on camera.

### Night 5 — Previous Shift
The player discovers rules written by a former employee. The final warning reads: "If you see yourself, do not let it leave the store."

### Night 6 — The 03:17 Customer
The store becomes silent. At 03:17 the entrance opens and an exact copy of the protagonist enters, places a bottle of water on the counter and asks: "Long night?"

## Endings

- **Serve:** the copy leaves; the real protagonist becomes trapped inside the surveillance system.
- **Refuse:** the player survives the shift, but the copy remains behind the register at dawn.
- **Replacement:** accumulated mistakes reveal the protagonist was replaced earlier in the week.
- **True ending:** by finding all evidence and making key correct decisions, the player breaks the loop and sees the clock reach 03:18.

## Core gameplay loop

Receive customer → observe behavior → scan items → compare evidence → SERVE / REFUSE / LOCK DOWN → complete store task → check CCTV → survive escalating anomaly.

## Customer verification signals

Signals are intentionally imperfect and may conflict:

- CCTV appearance
- mirror/reflection behavior
- repeated purchases or phrases
- impossible timestamps
- receipt anomalies
- eye and hand animation irregularities
- duplicated regular customers
- knowledge the customer should not possess

## Visual direction

Stylized indie realism rather than retro PSX imitation. Clean primary rendering with strong materials and lighting; degraded visuals are reserved for CCTV.

- cold fluorescent ceiling lights
- refrigerator glow and practical signage
- wet asphalt and reflected exterior light
- believable but production-efficient PBR materials
- medium-detail human models where faces, eyes and hands matter
- restrained post-processing; no permanent VHS filter
- CCTV: monochrome/low saturation, low frame-rate feel, timestamp, noise and compression artifacts

## Audio direction

The soundscape is a core horror system: refrigerator hum, ventilation, rain, distant traffic, scanner beeps, automatic doors and fluorescent buzz. At 03:17 selected ambient layers disappear before any visible anomaly occurs.

## Scope target

- 6 playable nights
- 2–4 hour first playthrough
- 4 endings
- one highly detailed store location
- 10–15 reusable customer archetypes with anomaly variants
- Windows first
- target build size: approximately 2–4 GB once final art/audio is included

## Vertical slice milestone

The first playable milestone should contain:

- walkable store blockout
- first-person controller
- interaction raycast
- register and shelves
- shift clock
- CCTV interaction hook
- one basic customer flow
- one 03:17 anomaly event
