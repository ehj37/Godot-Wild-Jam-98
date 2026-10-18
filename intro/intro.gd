extends Control

var _dialog_cursor: int
var _next_dialog_blocked: bool

@onready var _dialog_box: DialogBox = $MarginContainer/DialogBox
@onready var _dialog_box_configs: Array[DialogBox.DialogBoxConfig] = [
	DialogBox.DialogBoxConfig.new("THIS IS THE WORST DAY OF MY LIFE."),
	DialogBox.DialogBoxConfig.new("FROG RADIO IS BROKEN. IT SOUNDS ALL WRONG. THIS WON'T DO."),
	DialogBox.DialogBoxConfig.new("THIS MUST BE FIXED.")
]


func _process(_delta: float) -> void:
	# NOTE: Would ideally have a back to level select button after the last dialog has been finished.
	if (
		!_next_dialog_blocked
		&& Input.is_action_just_pressed("dialog_next")
		&& _dialog_cursor < _dialog_box_configs.size()
	):
		_next_dialog_blocked = true
		_play_dialog_at_current_cursor()

	if _dialog_cursor == _dialog_box_configs.size() && !_next_dialog_blocked:
		_next_dialog_blocked = true
		ScreenFadeLayer.fade_out()
		await ScreenFadeLayer.fade_finished

		get_tree().change_scene_to_file("res://levels/00_tutorial.tscn")


func _ready() -> void:
	# NOTE: Shouldn't be strictly necessary.
	AudioManager.remove_low_pass_filter_from_music()

	_next_dialog_blocked = true
	_dialog_box.assume_idle_state()
	ScreenFadeLayer.fade_in()
	await ScreenFadeLayer.fade_finished

	_play_dialog_at_current_cursor()


func _play_dialog_at_current_cursor() -> void:
	_next_dialog_blocked = true
	var dialog_box_config: DialogBox.DialogBoxConfig = _dialog_box_configs[_dialog_cursor]
	_dialog_box.play_dialog(dialog_box_config)
	await _dialog_box.dialog_finished

	_next_dialog_blocked = false
	_dialog_cursor += 1


func _on_level_select_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level_select/level_select.tscn")
