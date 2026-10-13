extends CanvasLayer

@onready var _radios_synced_popup: CenterContainer = $Control/RadiosSyncedPopup


func display_win_popup() -> void:
	_radios_synced_popup.visible = true


func _ready() -> void:
	_radios_synced_popup.visible = false


func _on_reset_button_pressed() -> void:
	get_tree().reload_current_scene()
