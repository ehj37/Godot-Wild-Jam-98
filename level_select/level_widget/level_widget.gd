class_name LevelWidget

extends VBoxContainer

signal play_button_pressed

@export var level_number: int

var _level_path: String

@onready var _level_number_label: Label = get_node(
	"PanelContainer/MarginContainer/LevelContainer/LevelNumberContainer/LevelNumberLabel"
)
@onready var _beaten_label: Label = get_node(
	"PanelContainer/MarginContainer/LevelContainer/BeatenContainer/BeatenLabel"
)
@onready var _play_button: Button = $PlayButton


func _ready() -> void:
	_level_path = LevelSelect.LEVELS[level_number]
	assert(_level_path)
	_level_number_label.text = str(level_number + 1)
	if PlayerStats.beaten_levels.has(_level_path):
		_beaten_label.text = "YES"
		_beaten_label.modulate = Color.GREEN
	else:
		_beaten_label.text = "NO"
		_beaten_label.modulate = Color.RED


func _on_play_button_pressed() -> void:
	play_button_pressed.emit()
	_play_button.disabled = true
	ScreenFadeLayer.fade_out()
	await ScreenFadeLayer.fade_finished

	get_tree().change_scene_to_file(_level_path)
