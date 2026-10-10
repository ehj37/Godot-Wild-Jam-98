extends Node2D

@export var frog_pipes: Array[FrogPipe]

var _turn_in_progress: bool = false

@onready var _frog_packed_scene: PackedScene = preload("res://frog/frog.tscn")


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if !_turn_in_progress && Input.is_action_just_pressed("test"):
		_turn_in_progress = true
		await _move_frogs()
		_spawn_frogs()
		_turn_in_progress = false


func _move_frogs() -> void:
	var frogs: Array[Frog] = EntityRepository.get_frogs()
	for frog: Frog in frogs:
		var next_grid_location: Vector2i = frog.get_next_grid_location()
		if EntityRepository.is_empty(next_grid_location):
			EntityRepository.move_entity(frog, next_grid_location)
		else:
			pass
		await get_tree().create_timer(0.1).timeout


func _spawn_frogs() -> void:
	var pipes: Array[FrogPipe] = EntityRepository.get_pipes()
	for pipe: FrogPipe in pipes:
		var spawn_location: Vector2i = pipe.get_spawn_location()
		if EntityRepository.is_empty(spawn_location):
			var new_frog: Frog = _frog_packed_scene.instantiate()
			new_frog.grid_location = spawn_location
			new_frog.direction = pipe.direction
			add_child(new_frog)
