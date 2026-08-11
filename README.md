# The 03:17 Customer

A first-person psychological horror game set during the night shift at a roadside convenience store.

> Every customer looks human. Not every customer is.

## Status

Early playable vertical slice / pre-production.

## Engine

Godot 4.x

## Current prototype

The repository currently contains:

- a full main menu presented as a CCTV security feed
- `NEW SHIFT`, save-aware `CONTINUE`, `SETTINGS`, `CREDITS`, and `QUIT`
- saved master-volume and fullscreen settings
- a walkable convenience-store interior with shelves, products, refrigerators, checkout hardware, fluorescent lighting, and a dark exterior lot
- first-person mouse look and WASD movement
- raycast interaction on `E`
- an interactable manager note
- a playable checkout loop: open REGISTER 01, scan each item, see a running total, and take payment
- a dedicated fullscreen CCTV interface with four selectable cameras
- true rendered CCTV views using a shared-world Godot `SubViewport`
- CCTV signal deterioration before 03:17 and camera/person-detection contradictions during the anomaly
- a first environment-quality pass with a glass storefront, framed entrance, illuminated `MORROW MARKET` sign, 24-hour sign, curb, parking details, bollards, exterior lamps, trash bin, register equipment, stocked shelves, and visible security-camera domes
- a playable Night 1 event timeline from 00:00 to the first 03:17 encounter
- two ordinary prototype customers followed by the anomalous 03:17 customer
- more detailed procedural customer bodies with faces, eyes, arms, clothing, and an intentionally uncanny anomalous variant
- a final `SERVE CUSTOMER` / `REFUSE SERVICE` decision
- separate Night 1 outcomes and save-state persistence into Night 2
- the first full game-design document in `docs/GDD.md`

The current Night 1 clock is intentionally accelerated for development so the complete event flow can be tested quickly. Character and environment art are still generated prototype geometry; the new visual-pass module is designed so those pieces can be replaced by authored assets later without rewriting the Night 1 scenario.

## Run locally

1. Install Godot 4.x.
2. Clone or download this repository.
3. Import `project.godot` in the Godot Project Manager.
4. Run the project with **F5**.

The game starts at `scenes/main_menu.tscn`. Select **NEW SHIFT** to create the initial save and enter Night 1. **CONTINUE** is disabled until a save exists.

Gameplay controls: **WASD** move, **Mouse** look, **E** interact, **Esc** release/capture mouse.

## Night 1 test flow

Read the note by the register. When an ordinary customer reaches the counter, interact with **REGISTER 01**, scan all listed items, and take payment. Use the nearby **CCTV** terminal to switch among Register, Aisles, Entrance, and Stockroom feeds. The monitor now renders the actual 3D store from four physical camera positions. As the clock approaches **03:17**, compare the rendered image with the security-system diagnostics. At 03:17, the system can claim that no customer is present even while one is visibly standing at the register, then you choose whether to serve or refuse them.

## Architecture note

`scripts/main.gd` owns gameplay and Night 1 progression. `scripts/visual_pass.gd` owns the current presentation layer: storefront dressing, props, exterior lighting, security-camera domes, and the shared-world rendered CCTV viewport. Keeping these layers separate should make future art upgrades safer.

## Core idea

Work the register, restock shelves, watch the CCTV system, and decide who is safe to serve. At exactly 03:17, the store stops behaving like a normal place.

The next development milestone is an audio/atmosphere pass plus stronger physical interaction: entrance chime, refrigerator hum, fluorescent buzz, scanner beeps, rain ambience, door movement, item placement on the counter, and a more cinematic 03:17 sequence.

See `docs/GDD.md` for the current game design.
