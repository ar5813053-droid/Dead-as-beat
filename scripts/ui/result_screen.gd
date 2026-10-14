extends CanvasLayer

@onready var title_label: Label = $Panel/Title
@onready var score_label: Label = $Panel/Score
@onready var combo_label: Label = $Panel/Combo
@onready var restart_btn: Button = $Panel/VBox/RestartButton
@onready var menu_btn: Button = $Panel/VBox/MenuButton

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameState.game_over.connect(_on_game_over)
	if restart_btn:
		restart_btn.pressed.connect(_on_restart)
	if menu_btn:
		menu_btn.pressed.connect(_on_menu)

func _on_game_over(victory: bool) -> void:
	visible = true
	if title_label:
		title_label.text = "VICTORY" if victory else "GAME OVER"
		title_label.modulate = Color(0.3, 1.0, 0.8) if victory else Color(1.0, 0.3, 0.4)
	if score_label:
		score_label.text = "SCORE  %d" % GameState.score
	if combo_label:
		combo_label.text = "MAX COMBO  x%d" % GameState.max_combo
	SaveManager.record_run_results()

func _on_restart() -> void:
	GameState.reset_run()
	get_tree().reload_current_scene()

func _on_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
