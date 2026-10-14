extends CanvasLayer
## In-game HUD: health, score, combo, beat indicator, pause button.

@onready var health_bar: ProgressBar = $Root/HealthBar
@onready var score_label: Label = $Root/ScoreLabel
@onready var combo_label: Label = $Root/ComboLabel
@onready var beat_indicator: ColorRect = $Root/BeatIndicator
@onready var timing_label: Label = $Root/TimingLabel
@onready var pause_btn: Button = $Root/PauseButton

func _ready() -> void:
	GameState.score_changed.connect(_on_score)
	GameState.combo_changed.connect(_on_combo)
	GameState.player_health_changed.connect(_on_health)
	BeatClock.beat.connect(_on_beat)
	BeatClock.timing_window.connect(_on_timing)
	if pause_btn:
		pause_btn.pressed.connect(_on_pause_pressed)
	_on_score(GameState.score)
	_on_combo(GameState.combo)
	_on_health(GameState.player_health, GameState.player_max_health)

func _on_score(v: int) -> void:
	if score_label:
		score_label.text = "SCORE  %d" % v

func _on_combo(v: int) -> void:
	if combo_label:
		combo_label.text = "COMBO  x%d" % v if v > 0 else ""
		combo_label.visible = v > 0

func _on_health(cur: int, mx: int) -> void:
	if health_bar:
		health_bar.max_value = mx
		health_bar.value = cur

func _on_beat(_idx: int) -> void:
	if beat_indicator:
		var tween := create_tween()
		beat_indicator.modulate = Color(0.2, 1.0, 1.0, 1.0)
		tween.tween_property(beat_indicator, "modulate", Color(0.2, 0.6, 0.8, 0.4), 0.2)

func _on_timing(quality: String) -> void:
	if timing_label == null:
		return
	match quality:
		"perfect":
			timing_label.text = "PERFECT"
			timing_label.modulate = Color(0.3, 1.0, 0.9)
		"early", "late":
			timing_label.text = quality.to_upper()
			timing_label.modulate = Color(1.0, 0.9, 0.3)
		_:
			timing_label.text = ""
	var tween := create_tween()
	timing_label.modulate.a = 1.0
	tween.tween_property(timing_label, "modulate:a", 0.0, 0.6)

func _on_pause_pressed() -> void:
	GameState.toggle_pause()
