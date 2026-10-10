extends Node

var _frogs: Array[Frog] = []


func register_frog(frog: Frog) -> void:
	_frogs.append(frog)


func get_frogs() -> Array[Frog]:
	return _frogs.duplicate()
