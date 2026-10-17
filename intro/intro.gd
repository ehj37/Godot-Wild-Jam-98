extends Control

const _FADE_IN_TIME: float = 3.0
const _FADE_OUT_TIME: float = 2.0

var _dialog_box_config_cursor: int = 0
# For the fade in and out at the beginning of the level.
var _fading: bool = true
var _dialog_in_progress: bool = false

@onready var _intro_dialog_box_configs: Array[DialogBox.DialogBoxConfig] = [
	DialogBox.DialogBoxConfig.new("THIS IS THE WORST DAY OF MY LIFE."),
	DialogBox.DialogBoxConfig.new("FROG RADIO IS DOWN. THIS WON'T DO."),
	DialogBox.DialogBoxConfig.new("THIS MUST BE FIXED.")
]

@onready var _dialog_box: DialogBox = $MarginContainer/DialogBox


func _process(_delta: float) -> void:
	if _fading:
		return

	if Input.is_action_just_pressed("dialog_next") && !_dialog_in_progress:
		if _dialog_box_config_cursor < _intro_dialog_box_configs.size() - 1:
			_dialog_box_config_cursor += 1
			_play_dialog_from_current_cursor_position()
		else:
			_dialog_box.assume_idle_state()
			_fading = true
			# TODO: FADE OUT TO BLACK


func _ready() -> void:
	_dialog_box.assume_idle_state()

	_fading = true
	# TODO: FADE IN FROM BLACK, CUTSCENE-ESQUE SOMETHING
	await get_tree().create_timer(_FADE_IN_TIME).timeout

	_fading = false
	_play_dialog_from_current_cursor_position()


func _play_dialog_from_current_cursor_position() -> void:
	var config: DialogBox.DialogBoxConfig = _intro_dialog_box_configs[_dialog_box_config_cursor]
	_dialog_box.play_dialog(config)
	_dialog_in_progress = true


func _on_dialog_box_dialog_finished() -> void:
	_dialog_in_progress = false
