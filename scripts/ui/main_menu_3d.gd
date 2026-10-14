extends Control
## Cinematic neon main menu with 3D character showcase.

@onready var play_btn: Button = $UI/VBox/Play
@onready var settings_btn: Button = $UI/VBox/Settings
@onready var quit_btn: Button = $UI/VBox/Quit
@onready var title: Label = $UI/Title
@onready var subtitle: Label = $UI/Subtitle
@onready var camera: Camera3D = $World/Camera3D
@onready var char_pivot: Node3D = $World/CharPivot

var _t: float = 0.0

func _ready() -> void:
	if play_btn:
		play_btn.pressed.connect(_on_play)
	if settings_btn:
		settings_btn.pressed.connect(_on_settings)
	if quit_btn:
		quit_btn.pressed.connect(_on_quit)
	if title:
		title.text = "NEON BEAT"
	if subtitle:
		subtitle.text = "RHYTHM ACTION COMBAT"
	# Soft ambient
	if AudioManager.has_method("play_menu_music"):
		AudioManager.play_menu_music()

func _process(delta: float) -> void:
	_t += delta
	if char_pivot:
		char_pivot.rotation.y = _t * 0.35
	if camera:
		camera.position.x = sin(_t * 0.25) * 0.4
		camera.position.y = 1.6 + sin(_t * 0.4) * 0.08

func _on_play() -> void:
	get_tree().change_scene_to_file("res://scenes/gameplay/arena_3d.tscn")

func _on_settings() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/settings.tscn")

func _on_quit() -> void:
	get_tree().quit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_on_quit()
