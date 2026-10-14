# Neon Beat — Asset Upload Guide (Android-friendly)

Upload your 3D models **one file at a time** from your phone.  
Do **not** try to upload a single 160 MB ZIP through the chat. Use GitHub instead.

Existing Kenney Mini Arena assets under `assets/3d/kenney_mini_arena/` stay in place until integration.  
Your new files go into the folders below; the game will keep building until we switch scenes to your models.

---

## 1. Where each asset goes

| Asset type | Exact GitHub folder path | Example filename | What to upload | Special notes |
|---|---|---|---|---|
| **Main character (Michael Jackson)** | `assets/characters/player/models/` | `michael_jackson.glb` | The original player `.glb` / `.gltf` | Preferred format: **glTF Binary (.glb)**. Keep the original name or rename clearly. |
| Player textures (if separate) | `assets/characters/player/textures/` | `body_albedo.png`, `outfit_normal.png` | PNG / JPG / WebP textures | Only if the GLB does **not** embed them. Match names the model expects. |
| Player materials (optional) | `assets/characters/player/materials/` | `skin.tres` | Godot `.tres` materials if you already made them | Usually not needed if the GLB has materials. |
| Player extra animations | `assets/characters/player/animations/` | `moonwalk.glb`, `idle.glb` | Standalone animation GLBs/FBX | Skeleton must match or be retargetable to the player model. |
| **Enemy 1** | `assets/characters/enemies/enemy_01/models/` | `enemy_01.glb` | First enemy mesh | One enemy type per `enemy_XX` folder. |
| Enemy 1 textures | `assets/characters/enemies/enemy_01/textures/` | `enemy_01_diff.png` | Separate textures if any | Same rules as player textures. |
| Enemy 1 animations | `assets/characters/enemies/enemy_01/animations/` | `walk.glb` | Extra clips for that enemy | Optional if clips are already inside the model GLB. |
| **Enemy 2** | `assets/characters/enemies/enemy_02/models/` | `enemy_02.glb` | Second enemy | Add `enemy_03`, `enemy_04`, … the same way. |
| Enemy 2 textures / anims | `assets/characters/enemies/enemy_02/textures/` and `.../animations/` | — | Same pattern | Different enemies may use different skeletons — do not mix their animation folders. |
| **Main map / arena** | `assets/environments/maps/` | `main_arena.glb` | Full environment mesh | Prefer one combined arena GLB. |
| Map textures | `assets/environments/textures/` | `floor_albedo.png` | External map textures | Skip if textures are embedded in the GLB. |
| Map materials | `assets/environments/materials/` | `neon_floor.tres` | Optional Godot materials | Created later during integration if needed. |
| **Props** | `assets/environments/props/` | `speaker.glb`, `barrier.glb` | Furniture, stage gear, barriers, decorations | For large sets, make subfolders: `props/stage/`, `props/barriers/`. |
| Music (legal only) | `assets/audio/music/` | `track_01.ogg` | OGG / WAV | Must be allowed for redistribution in a game APK. |
| Sound effects | `assets/audio/sfx/` | `punch.wav`, `ui_click.ogg` | Short SFX | Prefer OGG for smaller size. |
| Ambience | `assets/audio/ambience/` | `club_loop.ogg` | Loops | Optional. |
| VFX / particles | `assets/effects/` | `hit_spark.tscn`, textures | Godot scenes or images | Optional for now. |

---

## 2. Upload from an Android phone (GitHub website)

Works in Chrome or Firefox on Android.

1. Open: **https://github.com/ar5813053-droid/Dead-as-beat**
2. Sign in with the account that owns the repo.
3. Tap the folder path you need, e.g.  
   `assets` → `characters` → `player` → `models`
4. Tap **Add file** → **Upload files**.
5. Choose the `.glb` (or texture) from your phone storage / Downloads / Files app.
6. Scroll down, leave **Commit directly to the `main` branch** selected (or use a branch if you prefer).
7. Write a short message, e.g. `Add michael_jackson.glb`.
8. Tap **Commit changes**.
9. Confirm the file appears in the folder list (refresh if needed).

Repeat for each file. Prefer **several smaller uploads** over one huge batch.

### File size tips (mobile web)

- GitHub web upload often handles **under ~25–50 MB** per file more reliably on mobile.
- If a single GLB is larger:
  - Try Wi‑Fi and a smaller number of files per commit.
  - Or use **Termux** (below).
- Never commit secrets, passwords, or personal tokens in the same commit.

---

## 3. Alternative: Termux + git (Android)

If the web UI rejects a large file:

1. Install **Termux** from F-Droid (recommended) or Play Store.
2. Install git: `pkg install git`
3. Clone (use a **Personal Access Token** as password when asked):
   ```bash
   git clone https://github.com/ar5813053-droid/Dead-as-beat.git
   cd Dead-as-beat
   ```
4. Copy your GLB into the right folder (from shared storage):
   ```bash
   cp /sdcard/Download/michael_jackson.glb assets/characters/player/models/
   ```
5. Commit and push:
   ```bash
   git add assets/characters/player/models/michael_jackson.glb
   git commit -m "Add michael_jackson.glb player model"
   git push origin main
   ```

For very large binaries, enable **Git LFS** before the first large commit (`pkg install git-lfs`, then `git lfs install` and track `*.glb`).

---

## 4. Suggested upload order (checklist)

Upload in this order so integration can start as soon as the first pieces land:

- [ ] **1.** `assets/characters/player/models/michael_jackson.glb` ← highest priority  
- [ ] **2.** Any separate player textures → `assets/characters/player/textures/`  
- [ ] **3.** `assets/environments/maps/main_arena.glb` (or your map name)  
- [ ] **4.** Map textures if not embedded → `assets/environments/textures/`  
- [ ] **5.** Enemy 1 model → `assets/characters/enemies/enemy_01/models/`  
- [ ] **6.** Enemy 2 model → `assets/characters/enemies/enemy_02/models/`  
- [ ] **7.** Props → `assets/environments/props/`  
- [ ] **8.** Extra animation GLBs (if separate from the character)  
- [ ] **9.** Legal audio (optional)

When a batch is done, reply in chat: **“uploads complete”** (or list the filenames).  
The next step will inspect **only what is on GitHub**, then integrate models, collisions, AnimationTree, enemies, and a new APK.

---

## 5. Naming rules (keep it simple)

- Prefer **lowercase** with underscores: `michael_jackson.glb`, `enemy_01.glb`, `main_arena.glb`
- No spaces in filenames if possible (`my model.glb` → `my_model.glb`)
- Keep original names if renaming would break embedded texture paths inside the GLB
- Do **not** overwrite Kenney files under `assets/3d/kenney_mini_arena/` unless asked

---

## 6. Licenses

If your assets came with a license text (Sketchfab, Gumroad, etc.):

- Upload a short note or the license file next to the model, e.g.  
  `assets/characters/player/models/LICENSE.txt`
- Commercial / redistribution restrictions must be respected before shipping an APK

---

## 7. After upload — what happens next

1. You confirm uploads are on `main`.
2. We inspect each GLB (skeleton, clips, materials, size).
3. Player scene switches from Kenney soldier → Michael Jackson model.
4. Map + collision + enemy scenes use your models.
5. AnimationTree / combat / menu updated as the real clips allow.
6. GitHub Actions builds **NeonBeat-Android-APK**.

Until then, the current APK (Kenney 3D build) remains valid and unchanged by this folder setup.
