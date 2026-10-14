extends Node
## Global game state autoload. Holds score, combo, health, settings and high-level flow.

signal score_changed(new_score: int)
signal combo_changed(new_combo: int)
signal player_health_changed(current: int, maximum: int)
signal game_over(victory: bool)
signal paused_changed(is_paused: bool)

const MAX_COMBO_MULTIPLIER := 8.0

var score: int = 0
var combo: int = 0
var max_combo: int = 0
var player_health: int = 100
var player_max_health: int = 100
var is_paused: bool = false
var is_game_over: bool = false
var current_level_id: String = "level_01"
var bpm: float = 120.0

# Settings (persisted via SaveManager)
var master_volume: float = 1.0
var sfx_volume: float = 1.0
var music_volume: float = 0.8
var vibration_enabled: bool = true
var touch_controls_scale: float = 1.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func reset_run() -> void:
	score = 0
	combo = 0
	max_combo = 0
	player_health = player_max_health
	is_game_over = false
	is_paused = false
	score_changed.emit(score)
	combo_changed.emit(combo)
	player_health_changed.emit(player_health, player_max_health)

func add_score(base_points: int, timing_multiplier: float = 1.0) -> void:
	var points := int(base_points * timing_multiplier * get_combo_multiplier())
	score += points
	score_changed.emit(score)

func add_combo() -> void:
	combo += 1
	if combo > max_combo:
		max_combo = combo
	combo_changed.emit(combo)

func break_combo() -> void:
	combo = 0
	combo_changed.emit(combo)

func get_combo_multiplier() -> float:
	return clampf(1.0 + (combo * 0.15), 1.0, MAX_COMBO_MULTIPLIER)

func apply_damage_to_player(amount: int) -> void:
	if is_game_over:
		return
	player_health = maxi(0, player_health - amount)
	player_health_changed.emit(player_health, player_max_health)
	break_combo()
	if player_health <= 0:
		trigger_game_over(false)

func heal_player(amount: int) -> void:
	player_health = mini(player_max_health, player_health + amount)
	player_health_changed.emit(player_health, player_max_health)

func trigger_game_over(victory: bool) -> void:
	if is_game_over:
		return
	is_game_over = true
	is_paused = false
	game_over.emit(victory)

func set_paused(value: bool) -> void:
	if is_game_over:
		return
	is_paused = value
	get_tree().paused = value
	paused_changed.emit(value)

func toggle_pause() -> void:
	set_paused(not is_paused)
