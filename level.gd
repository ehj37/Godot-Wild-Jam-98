extends Node2D


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if Input.is_action_just_pressed("test"):
		_move_frogs()


func _move_frogs() -> void:
	var frogs: Array[Frog] = FrogRepository.get_frogs()
	for frog: Frog in frogs:
		var next_grid_location: Vector2i = frog.get_next_grid_location()
		frog.grid_location = next_grid_location
		await get_tree().create_timer(0.2).timeout
