extends CanvasLayer


func show_pause_screen() -> void:
	get_tree().paused = true
	visible = true


func hide_pause_screen() -> void:
	get_tree().paused = false
	visible = false


func _ready() -> void:
	if !Engine.is_editor_hint():
		hide_pause_screen()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if visible:
			hide_pause_screen()
		else:
			show_pause_screen()


func _on_resume_button_pressed() -> void:
	hide_pause_screen()
