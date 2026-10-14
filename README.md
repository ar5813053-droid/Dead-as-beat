# Neon Beat

**Neon Beat** is an original neon cyberpunk rhythm-action beat-'em-up built with **Godot 4.3** for Android.  
It is inspired by the *general idea* of neon side-view rhythm combat games, but contains **no copyrighted characters, music, levels, or assets**.

This repository is a **playable vertical slice** designed to be developed entirely from an Android phone using GitHub + GitHub Actions (no local PC required).

---

## Game overview

- 2.5D side-view arena
- Touch controls (left / right / jump / attack / dodge) + keyboard for editor testing
- BPM-driven beat clock with perfect / early / late timing windows
- Player melee attacks with hitboxes and visual feedback
- Basic enemies with health, chase and attack AI
- Health, score, combo UI
- Pause, game-over and victory screens
- Simple neon layered background (placeholder art)
- Save system for high score and settings

---

## Godot version

- **Engine:** Godot 4.3 stable  
- **Renderer:** Mobile (Compatibility)  
- **Language:** GDScript  
- **Target:** Android (armeabi-v7a + arm64-v8a debug APK)

---

## Project structure

```
NeonBeat/
├── project.godot
├── export_presets.cfg
├── README.md
├── LICENSE
├── .gitignore
├── .gitattributes
├── scenes/
│   ├── boot/boot.tscn
│   ├── menus/main_menu.tscn, settings.tscn
│   ├── gameplay/arena.tscn
│   ├── player/player.tscn
│   ├── enemies/basic_enemy.tscn
│   └── ...
├── scripts/
│   ├── core/          # GameState, AudioManager, Boot
│   ├── player/        # PlayerController
│   ├── rhythm/        # BeatClock
│   ├── enemies/       # BasicEnemy
│   ├── levels/        # ArenaManager
│   ├── ui/            # Menus, HUD, TouchControls, Pause, Results
│   └── save/          # SaveManager
├── assets/            # Placeholder textures, future art
├── resources/         # Future data resources
├── tests/
└── .github/workflows/
    ├── validate.yml
    └── android-apk.yml
```

---

## How to upload from an Android phone

1. Download the ZIP from the release / artifact / this repo.
2. Unzip on your phone (Files app or Solid Explorer).
3. Open **github.com** in your mobile browser → create a new repository (e.g. `NeonBeat`).
4. Use the “Upload files” button and select **all contents inside the NeonBeat folder** (so that `project.godot` is at the root of the repo).
5. Commit.

Alternatively use a Git client app that supports Android (e.g. MGit, Termux + git).

---

## How to build the Android APK with GitHub Actions

1. Push (or upload) the project to the `main` (or `master`) branch.
2. Open the repository on GitHub → **Actions** tab.
3. Select **Build Android APK**.
4. Tap **Run workflow** → **Run workflow**.
5. Wait for the job to finish (first run downloads Godot + templates and can take several minutes).
6. When the job is green, open it and download the artifact **NeonBeat-debug-apk**.
7. Install the APK on your phone (enable “Install from unknown sources” if needed).

### Inspecting failed builds

- Open the failed workflow run.
- Expand the **Export debug APK** step.
- Read `export.log` output. Common issues:
  - Export templates not found → check the download step.
  - Android SDK path → the workflow sets `ANDROID_HOME`.
  - Signing: this workflow produces an **unsigned/debug** APK (`package/signed=false`).  
    For a signed release you must supply your own keystore (never commit private keys).

---

## Controls

| Action   | Keyboard     | Touch          |
|----------|--------------|----------------|
| Move     | A/D or ←/→   | ◀ ▶ buttons    |
| Jump     | Space / W    | JUMP           |
| Attack   | J / Z        | ATK            |
| Dodge    | K / X        | DODGE          |
| Pause    | Esc          | PAUSE button   |

---

## Implemented features (vertical slice)

- [x] Main menu (Play / Settings / Quit)
- [x] Settings (volume, vibration flag)
- [x] Playable side-view arena
- [x] Player movement, jump, dodge, melee attack
- [x] Touch controls + keyboard
- [x] One functional enemy type with health, chase, attack
- [x] Hitboxes / damage
- [x] Health bar, score, combo
- [x] BPM beat clock (frame-rate independent)
- [x] Perfect / early / late timing windows + visual feedback
- [x] Win (clear all enemies) and lose states
- [x] Pause / resume / restart
- [x] Simple neon layered background
- [x] Adaptive UI layout
- [x] Save / load high score & settings
- [x] GitHub Actions validate + Android export workflows

---

## Incomplete / future work

- Real music tracks & SFX (currently silent metronome / visual only)
- Multiple levels and level select
- Boss characters with phases
- Destructible props
- Full animation libraries and sprite/3D art
- Particle combat VFX
- Combo attack strings and special moves
- Signed release builds
- Accessibility options

---

## How to extend

### Add a new enemy
1. Duplicate `scenes/enemies/basic_enemy.tscn` and `scripts/enemies/basic_enemy.gd`.
2. Adjust stats (`max_health`, `move_speed`, `attack_damage`…).
3. Change the colored rectangles under `Visual` or replace with sprites later.
4. Instance the new scene from `ArenaManager` or a future spawn table.

### Add a boss
1. Create `scripts/bosses/your_boss.gd` and `scenes/bosses/your_boss.tscn`.
2. Implement phase logic (health thresholds → different attack patterns).
3. Emit the same `died` signal so the arena can detect victory.

### Configure BPM for a level
- In `scenes/gameplay/arena.tscn` set the `bpm` export on the root `Arena` node,  
  **or** change `GameState.bpm` / `BeatClock.bpm` from a level resource later.

### Replace placeholder art
- Keep node names under `Visual` the same (or update script references).
- Swap `ColorRect` nodes for `Sprite2D` / `AnimatedSprite2D` / imported 3D scenes.
- Combat logic never hard-codes texture paths.

### Add a new player character
- Duplicate `scenes/player/player.tscn`.
- Change visual children and export stats.
- Point the arena’s player instance at the new scene.

---

## Development roadmap

1. **v0.1** – This vertical slice (current)
2. **v0.2** – Second enemy type, basic props, real SFX
3. **v0.3** – First boss + phase system
4. **v0.4** – Second arena theme + parallax polish
5. **v0.5** – Music sync with imported tracks
6. **v1.0** – Multiple levels, polish, signed release

---

## Verification checklist (first playable build)

- [ ] `project.godot` main scene = `res://scenes/boot/boot.tscn`
- [ ] Main menu → Play loads arena
- [ ] Player can move, jump, attack, dodge
- [ ] Enemies spawn and can be damaged / die
- [ ] Score and combo increase on kills
- [ ] Beat indicator pulses
- [ ] Timing text appears on attack
- [ ] Player death → Game Over screen
- [ ] All enemies dead → Victory screen
- [ ] Pause works
- [ ] Settings save volume
- [ ] GitHub Actions “Validate Project” passes
- [ ] GitHub Actions “Build Android APK” produces an artifact

---

## Known limitations

- No real audio assets yet (visual beat feedback only).
- TouchScreenButton shapes are visual-only rectangles (works on most devices; refine collision shapes later).
- Debug APK is **unsigned**. Android 8+ may require “Install unknown apps”.
- First CI run must download ~100 MB of Godot + templates.
- Headless validation cannot fully exercise rendering or input; it only checks project load.

---

## License

MIT – see `LICENSE`.

---

**Neon Beat** – feel the pulse. Fight on the beat.
