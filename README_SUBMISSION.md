# UCSD CSE 167 — Homework 1 (Sections 1–9)

This archive contains the HW1 source code, the scenes used for the included checks, and CPU-rendered PNGs. Sections 1–5 were already implemented before this work and their source code was reviewed but not changed. Sections 6–8 are implemented through `hw1/hw1_render.slang` and the entry points `hw1/hw1_6.slang`, `hw1/hw1_7.slang`, and `hw1/hw1_8.slang`.

## Included scene and render locations

All scene files are in `scenes/hw1/`; all output PNGs are in `outputs/`.

- **1 — Circle:** `hw1/hw1_1.slang`; scene parameters were provided directly to the renderer; render `outputs/verify_1_1.png`.
- **2 — Polylines:** `hw1/hw1_2.slang`; render `outputs/verify_1_2.png`.
- **3 — Multiple shapes:** `hw1/hw1_3.slang`; scene `scenes/hw1/four_shapes.json`; render `outputs/verify_1_3.png`.
- **4 — 2D transformations:** `hw1/hw1_4.slang`; scene `scenes/hw1/transformation.json`; render `outputs/verify_1_4.png`.
- **5 — Keyframe animation:** uses `hw1/hw1_4.slang` and interpolation in `hw1/hw1_scene.py`; scene `scenes/hw1/animation.json` at time 0.45; render `outputs/verify_1_5.png`.
- **6 — Antialiasing:** `hw1/hw1_6.slang` and `hw1/hw1_render.slang`; scenes `antialiasing.json` and `antialiasing_2.json`; renders `outputs/hw1_6_antialiasing.png` and `outputs/verify_1_6_scene.png`.
- **7 — Alpha blending:** `hw1/hw1_7.slang` and `hw1/hw1_render.slang`; scenes `alpha.json` and `alpha_2.json`; renders `outputs/hw1_7_alpha.png` and `outputs/verify_1_7_scene.png`.
- **8 — Quadratic Bézier curves:** `hw1/hw1_8.slang` and `hw1/hw1_render.slang`; scenes `test_card.json`, `heart.json`, `flower.json`, and `jellyfish.json`; renders `outputs/hw1_8_test_card.png`, `outputs/verify_1_8_heart.png`, `outputs/verify_1_8_flower.png`, and `outputs/verify_1_8_jellyfish.png` (jellyfish at time 0.91).
- **9 — Custom scene:** `scenes/hw1/tri_custom_scene.json`; a stylized cat made from circles, polylines, and quadratic Bézier curves; render `outputs/hw1_9_custom_scene.png`.

Only the scenes referenced above are packaged; other unused starter-library demos are omitted.

## Reproduce the custom-scene render

From the repository root:

```bash
uv sync
uv run python main.py -output outputs/hw1_9_custom_scene.png 1_8 scenes/hw1/tri_custom_scene.json
```

The included renders were produced using SlangPy's CPU backend on macOS. GPU/Metal was not verified because the Metal shader compiler from full Xcode is not installed on this Mac; CPU runs are not GPU verification.

## Bonus

No bonus work is claimed. Section 9 is the required custom-scene portion.

Review and understand the implementations before submission; the handout describes an in-person code interview.
