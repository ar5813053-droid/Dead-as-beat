extends Control

@onready var score_label: Label = $VBox/Score
@onready var combo_label: Label = $VBox/Combo
@onready var retry_btn: Button = $VBox/Retry
@onready var menu_btn: Button = $VBox/Menu

func _ready() -> void:
	if score_label:
		score_label.text = "Score: %d" % GameState.score
	if combo_label:
		combo_label.text = "Max Combo: %d" % GameState.max_combo
	if retry_btn:
		retry_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/gameplay/arena_3d.tscn"))
	if menu_btn:
		menu_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/menus/main_menu_3d.tscn"))
