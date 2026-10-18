extends Level

var _dialog_box: DialogBox
var _dialog_cursor: int = -1
var _dialog_in_progress: bool = false

@onready var _pipe: FrogPipe = $FrogPipe
@onready var _dialog_box_configs: Array[DialogBox.DialogBoxConfig] = [
	DialogBox.DialogBoxConfig.new("WE NEED FROGS AT THESE TOWERS PRONTO, ASAP, AND YESTERDAY."),
	DialogBox.DialogBoxConfig.new(
		"PRESS THE POWER BUTTON ON THAT PIPE, THEN PRESS SPACE TO POP OUT A FROG.", false
	),
	DialogBox.DialogBoxConfig.new(
		"PHENOMENAL. ARGUABLY EXCELLENT. LET'S POP OUT A FEW MORE.", false
	),
	DialogBox.DialogBoxConfig.new("LOVELY."),
	DialogBox.DialogBoxConfig.new("SEE THAT OTHER BUTTON ON THE PIPE?"),
	DialogBox.DialogBoxConfig.new("THAT TELLS THE FROGS WHAT TO DO WHEN THEY CAN'T GO FORWARD."),
	DialogBox.DialogBoxConfig.new(
		"FROGS CAN BE TOLD TO TURN CLOCKWISE, COUNTERCLOCKWISE, OR FLIP AROUND."
	),
	DialogBox.DialogBoxConfig.new(
		"LET'S GET FROGS STANDING AT BOTH TOWERS. THEN WE SYNC WITH THE ATTEMPT SYNC BUTTON.", false
	),
	(
		DialogBox
		. DialogBoxConfig
		. new(
			"INSPIRATIONAL. GOOD WORK.\nTHERE'S MORE WHERE THAT CAME FROM. GOOD LUCK HAVE FUN GOODBYE SEE YOU LATER.",
			false
		)
	),
]


func _process(delta: float) -> void:
	super(delta)

	# WE NEED FROGS AT THESE TOWERS PRONTO, ASAP, AND YESTERDAY.
	if _dialog_cursor == 0:
		if !_dialog_in_progress && Input.is_action_just_pressed("dialog_next"):
			_dialog_cursor += 1
			_play_dialog_at_current_cursor()

		return

	# PRESS THE POWER BUTTON ON THAT PIPE, THEN PRESS SPACE TO POP OUT A FROG.
	if _dialog_cursor == 1:
		_pipe.power_button_stuck = false
		if !_dialog_in_progress && grid.get_num_frogs() > 0:
			_dialog_cursor += 1
			_play_dialog_at_current_cursor()

		return

	# PHENOMENAL. ARGUABLY EXCELLENT. LET'S POP OUT A FEW MORE.
	if _dialog_cursor == 2:
		if !_dialog_in_progress && grid.get_num_frogs() >= 3:
			_dialog_cursor += 1
			_play_dialog_at_current_cursor()

		return

	if _dialog_cursor >= 3 && _dialog_cursor < 7:
		_pipe.instruction_button_stuck = false

		if !_dialog_in_progress && Input.is_action_just_pressed("dialog_next"):
			_dialog_cursor += 1
			_play_dialog_at_current_cursor()

		return

	if _dialog_cursor == 7:
		if _level_won && !_dialog_in_progress:
			_dialog_cursor += 1
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
	var dialog_box_config: DialogBox.DialogBoxConfig = _dialog_box_configs[_dialog_cursor]
	_dialog_box.play_dialog(dialog_box_config)
	_dialog_in_progress = true
	await _dialog_box.dialog_finished

	_dialog_in_progress = false
