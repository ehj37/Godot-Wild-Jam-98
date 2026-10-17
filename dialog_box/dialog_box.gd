@tool

class_name DialogBox

extends PanelContainer

signal dialog_finished

enum FrogActivity { IDLE, YAP }


class DialogBoxConfig:
	var dialog: String

	@warning_ignore("shadowed_variable")

	func _init(dialog: String) -> void:
		self.dialog = dialog


const _BASE_TEXT_SPEED: float = 10.0
const _DIALOG_SPEED_TO_MULTIPLIER: Dictionary = {
	DialogConfig.DialogSpeed.SLOW: 0.5,
	DialogConfig.DialogSpeed.NORMAL: 1.0,
	DialogConfig.DialogSpeed.FAST: 2.0,
}
const _SPEED_UP_MULTIPLIER: float = 3.0

var _parsed_text_length: int
var _dialog_in_progress: bool

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _rich_text_label: RichTextLabel = get_node(
	"MarginContainer/HBoxContainer/VBoxContainer/RichTextLabel"
)
@onready var _continue_label: RichTextLabel = get_node(
	"MarginContainer/HBoxContainer/VBoxContainer/VBoxContainer/ContinueLabel"
)


func assume_idle_state() -> void:
	assert(!_dialog_in_progress)

	_continue_label.visible = false
	_rich_text_label.text = ""


func play_dialog(dialog_box_config: DialogBoxConfig) -> void:
	assert(!_dialog_in_progress)

	_dialog_in_progress = true
	_continue_label.visible = false
	_rich_text_label.text = dialog_box_config.dialog
	_rich_text_label.visible_ratio = 0.0
	_parsed_text_length = _rich_text_label.get_parsed_text().length()
	assert(_parsed_text_length > 0)

	_set_frog_activity(FrogActivity.YAP)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if !_dialog_in_progress:
		return

	var config_multiplier: float = _DIALOG_SPEED_TO_MULTIPLIER.get(
		DialogConfig.selected_dialog_speed
	)
	var text_speed: float = _BASE_TEXT_SPEED * config_multiplier
	if Input.is_action_pressed("speed_up_text"):
		text_speed *= _SPEED_UP_MULTIPLIER

	var visible_ratio_progress: float = (text_speed * delta) / _parsed_text_length
	_rich_text_label.visible_ratio += visible_ratio_progress

	if _rich_text_label.visible_ratio >= 1.0:
		dialog_finished.emit()
		_animation_player.play("idle")
		_dialog_in_progress = false
		_continue_label.visible = true
		_set_frog_activity(FrogActivity.IDLE)


func _ready() -> void:
	_set_frog_activity(FrogActivity.IDLE)
	if Engine.is_editor_hint():
		_rich_text_label.visible_ratio = 1.0
	else:
		_rich_text_label.visible_ratio = 0.0
		_rich_text_label.text = ""
	_continue_label.visible = false
	_dialog_in_progress = false


func _set_frog_activity(frog_activity: FrogActivity) -> void:
	match frog_activity:
		FrogActivity.IDLE:
			_animation_player.play("idle")
		FrogActivity.YAP:
			_animation_player.play("yap")
