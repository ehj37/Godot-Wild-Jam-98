class_name LevelSelect

extends Control

const LEVELS: Array[String] = ["res://levels/00_tutorial.tscn", "res://levels/01_warm_up.tscn"]

@onready var _level_widget_container: GridContainer = $VBoxContainer/LevelWidgetContainer
@onready var _mouse_blocking_color_rect: ColorRect = $MouseBlockingColorRect


func _ready() -> void:
	ScreenFadeLayer.instant_fade_in()
	for level_widget: LevelWidget in _level_widget_container.get_children():
		level_widget.play_button_pressed.connect(_block_mouse_clicks)


func _block_mouse_clicks() -> void:
	_mouse_blocking_color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
