extends Level

var _dialog_box: DialogBox
var _dialog_cursor: int = -1
var _next_dialog_blocked: bool = true

@onready var _dialog_box_configs: Array[DialogBox.DialogBoxConfig] = [
	DialogBox.DialogBoxConfig.new("WE'RE DEALING WITH ADVANCED FROG TECHNOLOGY HERE."),
	DialogBox.DialogBoxConfig.new(
		"THESE SIGNAL TOWERS LET US CHANGE A FROG'S INSTRUCTIONS AFTER THEY'VE LEFT A PIPE."
	),
	DialogBox.DialogBoxConfig.new("SCIENCE HAS POTENTIALLY GONE TOO FAR.", false),
]


func _process(delta: float) -> void:
	super(delta)

	# NOTE: Final dialog will just sort of stick around. That's fine.
	if (
		!_next_dialog_blocked
		&& Input.is_action_just_pressed("dialog_next")
		&& _dialog_cursor < _dialog_box_configs.size()
	):
		_play_dialog_at_current_cursor()


func _ready() -> void:
	super()

	assert(DialogConfig.current_dialog_box)
	_dialog_box = DialogConfig.current_dialog_box
	_dialog_box.visible = true
	_dialog_box.assume_idle_state()
	await get_tree().create_timer(4.0).timeout

	_dialog_cursor = 0
	_play_dialog_at_current_cursor()


func _play_dialog_at_current_cursor() -> void:
	_next_dialog_blocked = true

	var dialog_box_config: DialogBox.DialogBoxConfig = _dialog_box_configs[_dialog_cursor]
	_dialog_box.play_dialog(dialog_box_config)
	await _dialog_box.dialog_finished

	_next_dialog_blocked = false
	_dialog_cursor += 1
