# The 03:17 Customer

A first-person psychological horror game set during the night shift at a roadside convenience store.

> Every customer looks human. Not every customer is.

## Status

Early playable prototype / pre-production.

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
- an interactable register and CCTV terminal
- a prototype shift clock
- fluorescent/refrigerator lighting and a dark exterior parking area
- the first full game-design document in `docs/GDD.md`

The prototype deliberately uses generated geometry and materials so it can run before final art assets are introduced.

## Run locally

1. Install Godot 4.x.
2. Clone or download this repository.
3. Import `project.godot` in the Godot Project Manager.
4. Run the project with **F5**.

The game now starts at `scenes/main_menu.tscn`. Select **NEW SHIFT** to create the initial save and enter the store. **CONTINUE** is disabled until a save exists.

Gameplay controls: **WASD** move, **Mouse** look, **E** interact, **Esc** release/capture mouse.

## Core idea

Work the register, restock shelves, watch the CCTV system, and decide who is safe to serve. At exactly 03:17, the store stops behaving like a normal place.

The first development milestone is a vertical slice containing one customer flow, the CCTV view, a playable register interaction, and the first 03:17 anomaly.

See `docs/GDD.md` for the current game design.
