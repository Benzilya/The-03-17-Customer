# Third-Party Assets / License Manifest

Release rule: every non-original binary asset must be listed here before Gate D.

## Current repository state
At the time of this manifest, the repository primarily contains Godot scenes/scripts and procedurally generated geometry/materials. No final third-party character models, texture packs, or recorded ordinary-SFX binaries are treated as release-approved merely because code contains placeholders for them.

## Audio
The project contains hooks for recorded CC0 ordinary sound effects. Before release, each physically imported sound must have:
- original asset/file name;
- source page/archive;
- author/creator where available;
- license (target: CC0/public-domain-equivalent for ordinary SFX where possible);
- local repository path;
- any attribution requirement.

If source/license provenance cannot be proven, the asset must not ship.

## Visual assets
Current production visuals are procedurally assembled from Godot primitive meshes/material parameters and project-authored code. Future externally sourced textures/models must be entered here before they are included in an RC build.

## Engine
Godot Engine is distributed under the MIT License. The release package must include the appropriate Godot license/copyright notice as required by the engine distribution terms.

## Release audit status
- Procedural project-authored geometry: clear for project use.
- Project-authored scripts/UI/story text: clear for project use.
- Final external recorded SFX: NOT YET AUDITED/IMPORTED.
- Final external textures/models: NONE APPROVED YET.

This document is a release blocker checklist, not a claim that all future assets are already licensed.
