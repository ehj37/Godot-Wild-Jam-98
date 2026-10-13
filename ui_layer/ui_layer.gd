extends CanvasLayer

signal sync_button_pressed
signal undo_button_pressed

@onready var _radio_sync_status_popup: CenterContainer = $Control/RadioSyncStatusPopup


func on_level_won() -> void:
	_radio_sync_status_popup.visible = true


func _ready() -> void:
	_radio_sync_status_popup.visible = false


func _on_reset_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_sync_button_pressed() -> void:
	sync_button_pressed.emit()


func _on_undo_button_pressed() -> void:
	undo_button_pressed.emit()
