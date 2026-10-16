extends CanvasLayer

signal sync_button_pressed
signal undo_button_pressed

var _selected_turn_speed_button: Button

@onready var _radio_sync_status_popup: CenterContainer = $Control/RadioSyncStatusPopup
@onready var _sync_successful_label: Label = get_node(
	"Control/RadioSyncStatusPopup/PanelContainer/MarginContainer/RadiosSyncedLabel"
)
@onready var _sync_unsuccessful_label: Label = get_node(
	"Control/RadioSyncStatusPopup/PanelContainer/MarginContainer/SyncUnsuccessfulLabel"
)
# gdlint: disable=max-line-length
@onready var _tenth_speed_button: Button = get_node(
	"Control/HBoxContainer/RightPanel/VBoxContainer/TurnContainer/VBoxContainer2/TurnSpeedContainer/SpeedButtonContainer/TenthSpeedButton"
)
@onready var _normal_speed_button: Button = get_node(
	"Control/HBoxContainer/RightPanel/VBoxContainer/TurnContainer/VBoxContainer2/TurnSpeedContainer/SpeedButtonContainer/NormalSpeedButton"
)
@onready var _double_speed_button: Button = get_node(
	"Control/HBoxContainer/RightPanel/VBoxContainer/TurnContainer/VBoxContainer2/TurnSpeedContainer/SpeedButtonContainer/DoubleSpeedButton"
)
@onready var _instant_button: Button = get_node(
	"Control/HBoxContainer/RightPanel/VBoxContainer/TurnContainer/VBoxContainer2/TurnSpeedContainer/InstantButton"
)
# gdlint: enable=max-line-length


func on_level_won() -> void:
	_radio_sync_status_popup.visible = true
	_sync_successful_label.visible = true
	_sync_unsuccessful_label.visible = false


func on_sync_failed() -> void:
	_radio_sync_status_popup.visible = true
	_sync_successful_label.visible = false
	_sync_unsuccessful_label.visible = true
	# TODO: Prevent additional sync attempts while this popup is shown.
	await get_tree().create_timer(1.0).timeout

	_radio_sync_status_popup.visible = false


func _ready() -> void:
	_radio_sync_status_popup.visible = false
	_selected_turn_speed_button = _normal_speed_button


func _on_turn_speed_button_pressed(button: Button, turn_speed: TurnConfig.TurnSpeed) -> void:
	_selected_turn_speed_button.disabled = false
	_selected_turn_speed_button = button
	_selected_turn_speed_button.disabled = true
	TurnConfig.set_new_turn_speed(turn_speed)


func _on_reset_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_sync_button_pressed() -> void:
	sync_button_pressed.emit()


func _on_undo_button_pressed() -> void:
	undo_button_pressed.emit()


func _on_tenth_speed_button_pressed() -> void:
	_on_turn_speed_button_pressed(_tenth_speed_button, TurnConfig.TurnSpeed.TENTH)


func _on_normal_speed_button_pressed() -> void:
	_on_turn_speed_button_pressed(_normal_speed_button, TurnConfig.TurnSpeed.NORMAL)


func _on_double_speed_button_pressed() -> void:
	_on_turn_speed_button_pressed(_double_speed_button, TurnConfig.TurnSpeed.DOUBLE)


func _on_instant_button_pressed() -> void:
	_on_turn_speed_button_pressed(_instant_button, TurnConfig.TurnSpeed.INSTANT)
