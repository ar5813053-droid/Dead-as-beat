extends Node
## Boot scene: quick init then go to main menu.

func _ready() -> void:
	# Ensure autoloads are ready
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
