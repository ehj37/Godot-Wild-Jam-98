extends Node

signal turn_speed_changed(new_turn_speed: TurnSpeed)

enum TurnSpeed { TENTH, NORMAL, DOUBLE, INSTANT }

var _turn_speed: TurnSpeed = TurnSpeed.NORMAL


func get_current_turn_speed() -> TurnSpeed:
	return _turn_speed


func set_new_turn_speed(new_turn_speed: TurnSpeed) -> void:
	if new_turn_speed == _turn_speed:
		return

	_turn_speed = new_turn_speed
	turn_speed_changed.emit(new_turn_speed)
