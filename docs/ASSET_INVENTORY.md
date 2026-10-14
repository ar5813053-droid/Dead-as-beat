# Asset inventory (inspected from actual GLB files)

Engine: **Godot 4.3** (not Unity). Project file: `project.godot`.

## Custom GLBs

| File | Size | Skins | Animations | Role |
|------|------|-------|------------|------|
| `michael__jackson_thriller.glb` | 165 MB | **0** | **none** | Main-menu showcase only (static mesh) |
| `mr_sexy_man_fighter_with_13_animations.glb` | 71 MB | 1 (102 joints) | **13 Kung Fu clips** | **Playable combat character** |
| `mma_fighter.glb` | 8 MB | 0 | none | Enemy mesh (static) |
| `arthur_morgan_from_rdr.glb` | 9 MB | 0 | none | Optional enemy mesh (static) |
| `boss_1009.glb` | 0.4 MB | 0 | none | Boss mesh (static) |
| `geonosis_arena.glb` | 22 MB | 0 | none | Playable arena environment |

### Sexy Man animation clips (used)

- Kung Fu idle guard / guard2 / guard 3 / idle drunk
- Kung Fu sexy punch, sexy no look punch, double push punch, phantom punch
- Kung Fu sexy kick, spinning elbow
- Kung Fu double head slam, the misleader, fake headbutt push

No walk/run clips in this model — locomotion is controller-driven; guard/idle plays while moving.

### Kenney Mini Arena (CC0)

`character-soldier.glb` includes: idle, walk, sprint, jump, fall, die, attack-melee-*, attack-kick-*, etc.  
Used as **animated enemy**.

## Not implemented (honest)

- Flight system (no flight clips in any model)
- Full AnimationTree state machine (uses AnimationPlayer + fuzzy clip matching)
- Parry / lock-on / NavMesh
- New licensed SFX pack (existing AudioManager retained)
- Device playtest of this build (CI APK only)

## Licensing note

Sketchfab-sourced models may have non-commercial or attribution requirements. Review each asset’s original license before public store distribution.
