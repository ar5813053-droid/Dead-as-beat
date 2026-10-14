extends Node
## Boot scene: quick init then go to 3D main menu.

func _ready() -> void:
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://scenes/menus/main_menu_3d.tscn")
