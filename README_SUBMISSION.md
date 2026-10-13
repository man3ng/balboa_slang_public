# UCSD CSE 167 — Homework 1 (Sections 1–9)

This submission includes the complete Homework 1 project source, the supplied HW1 scene library, CPU-rendered PNG checks, and the custom Section 9 scene/render. Sections 1–5 were already implemented in the project before this work; their source was reviewed and left unchanged. Sections 6–8 use `hw1/hw1_render.slang` as a shared implementation, with entry points in the corresponding `hw1_6.slang`, `hw1_7.slang`, and `hw1_8.slang` files.

## What is included

- **1 — Circle:** `hw1/hw1_1.slang`; CPU render `outputs/verify_1_1.png`.
- **2 — Polylines:** `hw1/hw1_2.slang`; CPU render `outputs/verify_1_2.png`.
- **3 — Multiple scene shapes:** `hw1/hw1_3.slang`; `hw1/hw1_scene.py`; scene `scenes/hw1/four_shapes.json`; CPU render `outputs/verify_1_3.png`.
- **4 — 2D transformations:** `hw1/hw1_4.slang`; scene `scenes/hw1/transformation.json`; CPU render `outputs/verify_1_4.png`.
- **5 — Keyframe animation:** rendered with `hw1/hw1_4.slang` and the interpolation in `hw1/hw1_scene.py`; scene `scenes/hw1/animation.json` at time 0.45; CPU render `outputs/verify_1_5.png`.
- **6 — Supersampling antialiasing:** `hw1/hw1_6.slang` and `hw1/hw1_render.slang`; scenes `scenes/hw1/antialiasing.json` and `scenes/hw1/antialiasing_2.json`; renders `outputs/hw1_6_antialiasing.png` and `outputs/verify_1_6_scene.png`.
- **7 — Alpha blending:** `hw1/hw1_7.slang` and `hw1/hw1_render.slang`; scenes `scenes/hw1/alpha.json` and `scenes/hw1/alpha_2.json`; renders `outputs/hw1_7_alpha.png` and `outputs/verify_1_7_scene.png`.
- **8 — Quadratic Bézier curves:** `hw1/hw1_8.slang` and `hw1/hw1_render.slang`; test scenes `scenes/hw1/test_card.json`, `heart.json`, `flower.json`, and `jellyfish.json`; renders `outputs/hw1_8_test_card.png`, `outputs/verify_1_8_heart.png`, `outputs/verify_1_8_flower.png`, and `outputs/verify_1_8_jellyfish.png` (jellyfish rendered at time 0.91).
- **9 — Custom scene:** `scenes/hw1/tri_custom_scene.json`; a recognizable stylized cat built from circles, polylines, and quadratic Bézier curves; rendering `outputs/hw1_9_custom_scene.png`.

All supplied HW1 JSON scene files are included under `scenes/hw1/`. The `outputs/` folder in the archive contains the rendered images listed above; no temporary compiler files, virtual environment, Python caches, or compiled shader/object binaries are included.

## Run the project

From the project root, install the Python dependencies with `uv sync`. The recorded PNG renders were generated on SlangPy's CPU backend using the same Slang shader implementations and scene inputs. For example, render the custom Section 9 scene with:

```bash
uv run python main.py -output outputs/hw1_9_custom_scene.png 1_8 scenes/hw1/tri_custom_scene.json
```

**Backend verification note:** GPU/Metal rendering has not been verified on this Mac because the Metal shader compiler from full Xcode is not installed. CPU-backend runs succeeded for the representative scenes listed above; these are not claimed as GPU runs.

## Bonus

No bonus work is claimed. Section 9 is the required custom-scene portion of the homework.

Please review and understand the implementations before submission; the course handout describes an in-person code interview.
