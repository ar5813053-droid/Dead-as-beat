extends CanvasLayer

@onready var health_bar: ProgressBar = $Root/HealthBar
@onready var score_label: Label = $Root/Score
@onready var combo_label: Label = $Root/Combo
@onready var timing_label: Label = $Root/Timing
@onready var wave_label: Label = $Root/Wave

func _ready() -> void:
	GameState.score_changed.connect(_on_score)
	GameState.combo_changed.connect(_on_combo)
	GameState.player_health_changed.connect(_on_health)
	GameState.game_over.connect(_on_game_over)
	_on_score(GameState.score)
	_on_combo(GameState.combo)
	_on_health(GameState.player_health, GameState.player_max_health)
	if BeatClock.has_signal("timing_window"):
		BeatClock.timing_window.connect(_on_timing)

func _on_score(s: int) -> void:
	if score_label:
		score_label.text = "SCORE  %d" % s

func _on_combo(c: int) -> void:
	if combo_label:
		combo_label.text = ("COMBO  x%d" % c) if c > 0 else ""

func _on_health(cur: int, mx: int) -> void:
	if health_bar:
		health_bar.max_value = mx
		health_bar.value = cur

func _on_timing(q: String) -> void:
	if timing_label:
		timing_label.text = q.to_upper()
		timing_label.modulate = Color(0.3, 1.0, 1.0) if q == "perfect" else Color(1, 1, 1)
		var tw := create_tween()
		tw.tween_property(timing_label, "modulate:a", 0.0, 0.6).from(1.0)

func _on_game_over(victory: bool) -> void:
	await get_tree().create_timer(0.8).timeout
	get_tree().change_scene_to_file("res://scenes/menus/result.tscn")
