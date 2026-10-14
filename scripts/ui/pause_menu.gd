extends CanvasLayer

@onready var resume_btn: Button = $Panel/VBox/ResumeButton
@onready var restart_btn: Button = $Panel/VBox/RestartButton
@onready var menu_btn: Button = $Panel/VBox/MenuButton

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameState.paused_changed.connect(_on_paused)
	if resume_btn:
		resume_btn.pressed.connect(_on_resume)
	if restart_btn:
		restart_btn.pressed.connect(_on_restart)
	if menu_btn:
		menu_btn.pressed.connect(_on_menu)

func _on_paused(is_paused: bool) -> void:
	visible = is_paused

func _on_resume() -> void:
	GameState.set_paused(false)

func _on_restart() -> void:
	GameState.set_paused(false)
	GameState.reset_run()
	get_tree().reload_current_scene()

func _on_menu() -> void:
	GameState.set_paused(false)
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
