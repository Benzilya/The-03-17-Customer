# M14 — Graphics Production Pass

Status: ACTIVE

## Goal
Raise The 03:17 Customer from procedural blockout readability toward a cohesive late-night convenience-store horror presentation without changing gameplay logic.

## Pass 1 implemented
- Shared `production_visual_runtime.gd` is injected into Nights 1–6 through the common player controller.
- Commercial tile/grout language added to break up prototype floor planes.
- Baseboards, utility panels, conduit, fire panel, store signage and wall dressing added for believable scale.
- Ceiling fixture language and dead fixtures added to Nights that previously had only blockout lighting.
- Register cluster upgraded with monitor/bezel, printer slot/receipt, trim and fabricated counter details.
- Ambient props added: shipping cartons, tape, mop/bucket, extinguisher, signage.
- Rest room visually upgraded with headboard, blanket fold, pillow, bedside table, mug and notice board.
- Lighting now uses restrained cool register/fridge/entrance pools plus warm rest-room contrast.

## Character V2 implemented
- Head proportions narrowed and deepened.
- Added jaw/chin volume, cheek volume and ears.
- Added sclera, iris/pupil and eyebrows rather than single black spheres.
- Added nose bridge/tip and subtle facial shadow geometry.
- Added hair side masses and layered clothing/collars/lapels.
- Arms/hands/legs retained procedural but proportions were refined.
- Signature beard customer rebuilt with denser central beard, bowler-style hat, round glasses and six curled side locks inspired by the approved reference silhouette.
- Existing anomaly CCTV layer behavior remains intact: anomaly meshes stay on layer 2 while ordinary customers stay on layer 1.

## Important limitation
This pass still uses built-in procedural meshes and flat/parameterized materials. It is a major improvement over the prototype but it is not the final photoreal target. Final-quality faces, fabric, branded products and surface wear will ultimately benefit from external authored meshes/textures.

## Next graphics work
1. Avoid geometry overlap with legacy Night 1 visual layers and verify no z-fighting.
2. Improve customer clothing variation and silhouette per case.
3. Add more convincing glass/reflection material treatment.
4. Add wall/floor material variation and wetness cues without excessive specular noise.
5. Improve CCTV post-processing/readability.
6. Replace procedural hero props and characters with authored assets where licensing/source permits.
7. Runtime capture comparison: before/after screenshots at 1280x720.

## Visual QA
- Verify ProductionVisualRuntime exists once per Night scene.
- Verify Night 1 legacy M7 visuals do not z-fight with M14 additions.
- Verify all customer faces read correctly from register distance.
- Verify signature beard silhouette is recognizable from front and CCTV angles.
- Verify anomaly customers remain invisible to CCTV where intended.
- Check Low/Balanced/High presets for lighting and geometry readability.
- Check RU/EN UI remains legible over the richer scene.
