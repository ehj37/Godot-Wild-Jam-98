extends CanvasLayer

var _selected_turn_speed_button: Button

# gdlint: disable=max-line-length
@onready var _dialog_box: DialogBox = get_node(
	"Control/HBoxContainer/LeftSectionContainer/DialogContainer/DialogBox"
)
@onready var _num_towers_label: Label = get_node(
	"Control/HBoxContainer/RightPanel/VBoxContainer/SyncContainer/HBoxContainer/NumTowersLabel"
)
@onready var _level_name_container: MarginContainer = get_node(
	"Control/HBoxContainer/LeftSectionContainer/LevelNameContainer"
)
@onready var _level_name_label: Label = get_node(
	"Control/HBoxContainer/LeftSectionContainer/LevelNameContainer/VBoxContainer/LevelNameLabelContainer/MarginContainer/Label"
)
@onready var _undo_button: Button = get_node(
	"Control/HBoxContainer/RightPanel/VBoxContainer/TurnContainer/VBoxContainer2/HBoxContainer/UndoButton"
)
@onready var _redo_button: Button = get_node(
	"Control/HBoxContainer/RightPanel/VBoxContainer/TurnContainer/VBoxContainer2/HBoxContainer/RedoButton"
)
@onready var _sync_button: Button = get_node(
	"Control/HBoxContainer/RightPanel/VBoxContainer/SyncContainer/SyncButton"
)
@onready var _radio_sync_status_popup: CenterContainer = get_node(
	"Control/HBoxContainer/LeftSectionContainer/RadioSyncStatusPopup"
)
@onready var _sync_successful_label: Label = get_node(
	"Control/HBoxContainer/LeftSectionContainer/RadioSyncStatusPopup/VBoxContainer/PanelContainer/MarginContainer/RadiosSyncedLabel"
)
@onready var _sync_unsuccessful_label: Label = get_node(
	"Control/HBoxContainer/LeftSectionContainer/RadioSyncStatusPopup/VBoxContainer/PanelContainer/MarginContainer/SyncUnsuccessfulLabel"
)
@onready var _sync_popup_next_level_button: Button = get_node(
	"Control/HBoxContainer/LeftSectionContainer/RadioSyncStatusPopup/VBoxContainer/NextLevelButton"
)
@onready var _sync_popup_level_select_button: Button = get_node(
	"Control/HBoxContainer/LeftSectionContainer/RadioSyncStatusPopup/VBoxContainer/LevelSelectButton"
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
	DialogConfig.current_dialog_box = _dialog_box

	_radio_sync_status_popup.visible = false
	_level_name_container.visible = false
	_selected_turn_speed_button = _normal_speed_button

	SignalBus.snapshots_updated.connect(_on_snapshot_update)
	SignalBus.sync_successful.connect(_on_sync_successful)
	SignalBus.sync_unsuccessful.connect(_on_sync_unsuccessful)
	SignalBus.level_ready.connect(_on_level_ready)
	SignalBus.dialog_ready.emit(_dialog_box)


func _on_level_ready(level_name: String, num_radio_towers: int) -> void:
	_num_towers_label.text = str(num_radio_towers)

	if level_name.length() > 0:
		await get_tree().create_timer(1.0).timeout

		_level_name_container.visible = true
		_level_name_container.modulate.a = 0
		_level_name_label.text = level_name

		var fade_in_tween: Tween = get_tree().create_tween()
		fade_in_tween.tween_property(_level_name_container, "modulate:a", 1.0, 1.5)

		await fade_in_tween.finished

		await get_tree().create_timer(1.5).timeout

		var fade_out_tween: Tween = get_tree().create_tween()
		fade_out_tween.tween_property(_level_name_container, "modulate:a", 0.0, 1.0)
		await fade_out_tween.finished

		_level_name_container.visible = false


func _on_snapshot_update(num_level_snapshots: int, current_snapshot_cursor: int) -> void:
	_turn_number_label.text = str(current_snapshot_cursor + 1)
	_undo_button.disabled = current_snapshot_cursor == 0
	_redo_button.disabled = current_snapshot_cursor == num_level_snapshots - 1


func _on_sync_successful() -> void:
	_radio_sync_status_popup.visible = true
	_radio_sync_status_popup.modulate.a = 1.0
	_sync_successful_label.visible = true
	_sync_unsuccessful_label.visible = false
	_sync_button.disabled = true
	_undo_button.disabled = true
	_redo_button.disabled = true

	await get_tree().create_timer(1.5).timeout
	_sync_popup_next_level_button.visible = true
	_sync_popup_level_select_button.visible = true


func _on_sync_unsuccessful() -> void:
	_radio_sync_status_popup.visible = true
	_radio_sync_status_popup.modulate.a = 1.0
	_sync_successful_label.visible = false
	_sync_unsuccessful_label.visible = true
	_sync_button.disabled = true
	await get_tree().create_timer(1.0).timeout

	_sync_button.disabled = false
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


func _on_level_select_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level_select/level_select.tscn")


func _on_next_level_button_pressed() -> void:
	_sync_popup_next_level_button.disabled = true

	var level_i: int = LevelSelect.LEVELS.find(get_tree().current_scene.scene_file_path)
	assert(level_i != -1)

	ScreenFadeLayer.fade_out()
	await ScreenFadeLayer.fade_finished

	if level_i < LevelSelect.LEVELS.size() - 1:
		var next_level_path: String = LevelSelect.LEVELS[level_i + 1]
		get_tree().change_scene_to_file(next_level_path)
	else:
		get_tree().change_scene_to_file("res://outro/outro.tscn")
