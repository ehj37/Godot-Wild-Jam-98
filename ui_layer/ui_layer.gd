extends CanvasLayer

var _selected_turn_speed_button: Button

# gdlint: disable=max-line-length
@onready var _undo_button: Button = get_node(
	"Control/HBoxContainer/RightPanel/VBoxContainer/TurnContainer/VBoxContainer2/HBoxContainer/UndoButton"
)
@onready var _redo_button: Button = get_node(
	"Control/HBoxContainer/RightPanel/VBoxContainer/TurnContainer/VBoxContainer2/HBoxContainer/RedoButton"
)
@onready var _radio_sync_status_popup: CenterContainer = get_node(
	"Control/HBoxContainer/LeftSectionContainer/RadioSyncStatusPopup"
)
@onready var _sync_successful_label: Label = get_node(
	"Control/HBoxContainer/LeftSectionContainer/RadioSyncStatusPopup/PanelContainer/MarginContainer/RadiosSyncedLabel"
)
@onready var _sync_unsuccessful_label: Label = get_node(
	"Control/HBoxContainer/LeftSectionContainer/RadioSyncStatusPopup/PanelContainer/MarginContainer/SyncUnsuccessfulLabel"
)
@onready var _turn_number_label: Label = get_node(
	"Control/HBoxContainer/RightPanel/VBoxContainer/TurnContainer/VBoxContainer2/TurnContainer/TurnNumberLabel"
)
@onready var _tenth_speed_button: Button = get_node(
	"Control/HBoxContainer/RightPanel/VBoxContainer/TurnSpeedContainer/SpeedButtonContainer/TenthSpeedButton"
)
@onready var _normal_speed_button: Button = get_node(
	"Control/HBoxContainer/RightPanel/VBoxContainer/TurnSpeedContainer/SpeedButtonContainer/NormalSpeedButton"
)
@onready var _double_speed_button: Button = get_node(
	"Control/HBoxContainer/RightPanel/VBoxContainer/TurnSpeedContainer/SpeedButtonContainer/DoubleSpeedButton"
)
@onready var _instant_button: Button = get_node(
	"Control/HBoxContainer/RightPanel/VBoxContainer/TurnSpeedContainer/InstantButton"
)
# gdlint: enable=max-line-length


func _ready() -> void:
	_radio_sync_status_popup.visible = false
	_selected_turn_speed_button = _normal_speed_button

	SignalBus.snapshots_updated.connect(_on_snapshot_update)
	SignalBus.sync_successful.connect(_on_sync_successful)
	SignalBus.sync_unsuccessful.connect(_on_sync_unsuccessful)


func _on_snapshot_update(num_level_snapshots: int, current_snapshot_cursor: int) -> void:
	_turn_number_label.text = str(current_snapshot_cursor + 1)
	_undo_button.disabled = current_snapshot_cursor == 0
	_redo_button.disabled = current_snapshot_cursor == num_level_snapshots - 1


func _on_sync_successful() -> void:
	_radio_sync_status_popup.visible = true
	_sync_successful_label.visible = true
	_sync_unsuccessful_label.visible = false


func _on_sync_unsuccessful() -> void:
	_radio_sync_status_popup.visible = true
	_sync_successful_label.visible = false
	_sync_unsuccessful_label.visible = true
	# TODO: Prevent additional sync attempts while this popup is shown.
	await get_tree().create_timer(1.0).timeout

	_radio_sync_status_popup.visible = false


func _on_turn_speed_button_pressed(button: Button, turn_speed: TurnConfig.TurnSpeed) -> void:
	_selected_turn_speed_button.disabled = false
	_selected_turn_speed_button = button
	_selected_turn_speed_button.disabled = true
	TurnConfig.set_new_turn_speed(turn_speed)


func _on_reset_button_pressed() -> void:
	SignalBus.reset_requested.emit()


func _on_sync_button_pressed() -> void:
	SignalBus.sync_requested.emit()


func _on_undo_button_pressed() -> void:
	SignalBus.undo_requested.emit()


func _on_redo_button_pressed() -> void:
	SignalBus.redo_requested.emit()


func _on_tenth_speed_button_pressed() -> void:
	_on_turn_speed_button_pressed(_tenth_speed_button, TurnConfig.TurnSpeed.TENTH)


func _on_normal_speed_button_pressed() -> void:
	_on_turn_speed_button_pressed(_normal_speed_button, TurnConfig.TurnSpeed.NORMAL)


func _on_double_speed_button_pressed() -> void:
	_on_turn_speed_button_pressed(_double_speed_button, TurnConfig.TurnSpeed.DOUBLE)


func _on_instant_button_pressed() -> void:
	_on_turn_speed_button_pressed(_instant_button, TurnConfig.TurnSpeed.INSTANT)


func _on_options_button_pressed() -> void:
	PauseLayer.show_pause_screen()
