@tool
extends EditorPlugin

const PLUGIN_NAME = "GodotAdMob"
const ANDROID_PLUGIN_NAME = "GodotAdMob"
const ANDROID_PLUGIN_PATH = "res://addons/godot-admob-plugin/android/"

func _enter_tree():
	add_autoload_singleton("AdMob", "res://addons/godot-admob-plugin/AdMob.gd")
	_setup_android_plugin()
	print("AdMob Plugin activated")

func _exit_tree():
	remove_autoload_singleton("AdMob")
	_cleanup_android_plugin()
	print("AdMob Plugin deactivated")

func _setup_android_plugin():
	if not ProjectSettings.has_setting("android/plugins"):
		ProjectSettings.set_setting("android/plugins", PackedStringArray())
	
	var plugins = ProjectSettings.get_setting("android/plugins") as PackedStringArray
	if not ANDROID_PLUGIN_NAME in plugins:
		plugins.append(ANDROID_PLUGIN_NAME)
		ProjectSettings.set_setting("android/plugins", plugins)
		ProjectSettings.save()

func _cleanup_android_plugin():
	if ProjectSettings.has_setting("android/plugins"):
		var plugins = ProjectSettings.get_setting("android/plugins") as PackedStringArray
		var idx = plugins.find(ANDROID_PLUGIN_NAME)
		if idx != -1:
			plugins.remove_at(idx)
			ProjectSettings.set_setting("android/plugins", plugins)
			ProjectSettings.save()