extends Control
## Main menu with Play, Settings, Quit.

@onready var play_btn: Button = $VBox/PlayButton
@onready var settings_btn: Button = $VBox/SettingsButton
@onready var quit_btn: Button = $VBox/QuitButton
@onready var title_label: Label = $Title
@onready var high_score_label: Label = $HighScore

func _ready() -> void:
	if play_btn:
		play_btn.pressed.connect(_on_play)
	if settings_btn:
		settings_btn.pressed.connect(_on_settings)
	if quit_btn:
		quit_btn.pressed.connect(_on_quit)
	if high_score_label:
		high_score_label.text = "HIGH SCORE  %d" % SaveManager.data.get("high_score", 0)

func _on_play() -> void:
	GameState.reset_run()
	get_tree().change_scene_to_file("res://scenes/gameplay/arena.tscn")

func _on_settings() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/settings.tscn")

func _on_quit() -> void:
	# On Android this will exit the app
	get_tree().quit()
