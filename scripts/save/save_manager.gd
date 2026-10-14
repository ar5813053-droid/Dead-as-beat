extends Node
## Simple JSON save system for settings and high scores.

const SAVE_PATH := "user://neon_beat_save.json"

var data: Dictionary = {
	"high_score": 0,
	"max_combo": 0,
	"master_volume": 1.0,
	"sfx_volume": 1.0,
	"music_volume": 0.8,
	"vibration_enabled": true,
	"touch_controls_scale": 1.0,
	"unlocked_levels": ["level_01"]
}

func _ready() -> void:
	load_game()

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("SaveManager: could not open save file for reading")
		return
	var json_text := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(json_text)
	if typeof(parsed) == TYPE_DICTIONARY:
		data.merge(parsed, true)
		_apply_to_game_state()

func save_game() -> void:
	_sync_from_game_state()
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("SaveManager: could not open save file for writing")
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

func _sync_from_game_state() -> void:
	data["master_volume"] = GameState.master_volume
	data["sfx_volume"] = GameState.sfx_volume
	data["music_volume"] = GameState.music_volume
	data["vibration_enabled"] = GameState.vibration_enabled
	data["touch_controls_scale"] = GameState.touch_controls_scale
	if GameState.score > data.get("high_score", 0):
		data["high_score"] = GameState.score
	if GameState.max_combo > data.get("max_combo", 0):
		data["max_combo"] = GameState.max_combo

func _apply_to_game_state() -> void:
	GameState.master_volume = data.get("master_volume", 1.0)
	GameState.sfx_volume = data.get("sfx_volume", 1.0)
	GameState.music_volume = data.get("music_volume", 0.8)
	GameState.vibration_enabled = data.get("vibration_enabled", true)
	GameState.touch_controls_scale = data.get("touch_controls_scale", 1.0)
	AudioManager.set_master_volume(GameState.master_volume)

func record_run_results() -> void:
	_sync_from_game_state()
	save_game()
