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
- a walkable convenience-store blockout
- first-person mouse look and WASD movement
- raycast interaction on `E`
- an interactable manager note, register, and dynamic CCTV terminal
- a playable Night 1 event timeline from 00:00 to the first 03:17 encounter
- two ordinary prototype customers followed by the anomalous 03:17 customer
- a final `SERVE CUSTOMER` / `REFUSE SERVICE` decision
- separate Night 1 outcomes and save-state persistence into Night 2
- fluorescent/refrigerator lighting and a dark exterior parking area
- the first full game-design document in `docs/GDD.md`

The current Night 1 clock is intentionally accelerated for development so the complete event flow can be tested quickly. Character and environment art are still generated prototype geometry and will be replaced during the visual-quality pass.

## Run locally

1. Install Godot 4.x.
2. Clone or download this repository.
3. Import `project.godot` in the Godot Project Manager.
4. Run the project with **F5**.

The game starts at `scenes/main_menu.tscn`. Select **NEW SHIFT** to create the initial save and enter Night 1. **CONTINUE** is disabled until a save exists.

Gameplay controls: **WASD** move, **Mouse** look, **E** interact, **Esc** release/capture mouse.

## Night 1 test flow

Read the note by the register, work through the ordinary customers, inspect CCTV as the shift grows stranger, then decide what to do when the final customer arrives at exactly **03:17**.

## Core idea

Work the register, restock shelves, watch the CCTV system, and decide who is safe to serve. At exactly 03:17, the store stops behaving like a normal place.

The next development milestone is to replace the prototype customer interaction with a real checkout loop, add camera views instead of text-only CCTV status, and begin the environment art pass.

See `docs/GDD.md` for the current game design.
