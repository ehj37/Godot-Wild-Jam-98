extends Control

@onready var _play_button: Button = get_node("MainMenu/VBoxContainer/PlayButton")
@onready var _level_select_button: Button = get_node("MainMenu/VBoxContainer/LevelSelectButton")


func _ready() -> void:
	ScreenFadeLayer.fade_in()


func _on_play_button_pressed() -> void:
	_play_button.disabled = true
	_level_select_button.disabled = true
	ScreenFadeLayer.fade_out()
	await ScreenFadeLayer.fade_finished

	get_tree().change_scene_to_file("res://intro/intro.tscn")


func _on_level_select_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level_select/level_select.tscn")
