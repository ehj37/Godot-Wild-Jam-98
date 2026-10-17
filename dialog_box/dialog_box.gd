@tool

class_name DialogBox

extends PanelContainer

enum FrogActivity { IDLE, YAP }

const _BASE_TEXT_SPEED: float = 10.0
const _DIALOG_SPEED_TO_MULTIPLIER: Dictionary = {
	DialogConfig.DialogSpeed.SLOW: 0.5,
	DialogConfig.DialogSpeed.NORMAL: 1.0,
	DialogConfig.DialogSpeed.FAST: 2.0,
}
const _SPEED_UP_MULTIPLIER: float = 3.0

@export_multiline var dialog: String:
	set(new_value):
		dialog = new_value
		if is_node_ready():
			_rich_text_label.text = new_value
			print("Foobar")

var frog_activity: FrogActivity
var _parsed_text_length: int

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready
var _rich_text_label: RichTextLabel = get_node("MarginContainer/HBoxContainer/RichTextLabel")


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	var config_multiplier: float = _DIALOG_SPEED_TO_MULTIPLIER.get(
		DialogConfig.selected_dialog_speed
	)
	var text_speed: float = _BASE_TEXT_SPEED * config_multiplier
	if Input.is_action_pressed("speed_up_text"):
		text_speed *= _SPEED_UP_MULTIPLIER

	var visible_ratio_progress: float = (text_speed * delta) / _parsed_text_length
	_rich_text_label.visible_ratio += visible_ratio_progress


func _ready() -> void:
	_rich_text_label.text = dialog
	_parsed_text_length = _rich_text_label.get_parsed_text().length()
	assert(_parsed_text_length > 0)
	frog_activity = FrogActivity.YAP
	_update_visuals_from_activity()
	if Engine.is_editor_hint():
		_rich_text_label.visible_ratio = 1.0
	else:
		_rich_text_label.visible_ratio = 0.0


func _update_visuals_from_activity() -> void:
	match frog_activity:
		FrogActivity.IDLE:
			_animation_player.play("idle")
		FrogActivity.YAP:
			_animation_player.play("yap")
