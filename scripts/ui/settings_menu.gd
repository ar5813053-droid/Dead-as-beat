extends Control

@onready var master_slider: HSlider = $VBox/MasterVolume
@onready var back_btn: Button = $VBox/BackButton
@onready var vibration_check: CheckButton = $VBox/Vibration

func _ready() -> void:
	if master_slider:
		master_slider.value = GameState.master_volume
		master_slider.value_changed.connect(_on_master)
	if vibration_check:
		vibration_check.button_pressed = GameState.vibration_enabled
		vibration_check.toggled.connect(_on_vibration)
	if back_btn:
		back_btn.pressed.connect(_on_back)

func _on_master(v: float) -> void:
	GameState.master_volume = v
	AudioManager.set_master_volume(v)

func _on_vibration(on: bool) -> void:
	GameState.vibration_enabled = on

func _on_back() -> void:
	SaveManager.save_game()
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
