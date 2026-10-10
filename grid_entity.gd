@tool

class_name GridEntity

extends Node2D

@export var grid_residency: GridState.Residency
var grid_location: Vector2i:
	set(new_value):
		grid_location = new_value
		global_position = Grid.get_global_position_center(grid_location)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint() && EditorInterface.get_edited_scene_root() != self:
		var nearest_grid_position: Vector2i = Grid.get_nearest_grid_location(global_position)
		grid_location = nearest_grid_position
		global_position = Grid.get_global_position_center(nearest_grid_position)


func _ready() -> void:
	if !Engine.is_editor_hint():
		grid_location = Grid.get_nearest_grid_location(global_position)
		GridState.register_residency(grid_residency, grid_location)
