extends SceneTree
func _init():
	var v = ProjectSettings.get_setting("rendering/textures/vram_compression/import_etc2_astc", null)
	print("ETC2_SETTING=", v)
	quit()
