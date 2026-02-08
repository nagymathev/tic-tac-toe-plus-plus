@tool

extends Node2D
class_name Board

# Manages all the rendering side of the game. Is not concerned with data.

@export var _board_stats: BoardSettings
@export var _board_checker: BoardManager

func _on_board_stats_changed():
	print("[Board] Stats Changed")
	_delete_board()
	_create_board()
	queue_redraw()

func _create_board():
	var cell_scene := preload("res://scenes/board_cell.tscn")
	for y in _board_stats.size_y:
		for x in _board_stats.size_x:
			var cell: Node2D= cell_scene.instantiate()
			add_child(cell)
			cell.position = Vector2(x * _board_stats.cell_size * _board_stats.cell_scale, y * _board_stats.cell_size * _board_stats.cell_scale)
			
			@warning_ignore("integer_division")
			cell.scale = Vector2.ONE * _board_stats.cell_scale

func _delete_board():
	var children = get_children()
	for child in children:
		remove_child(child)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_board_stats.changed.connect(_on_board_stats_changed)
	_on_board_stats_changed()
	
func _draw() -> void:
	if Engine.is_editor_hint():
		draw_line(Vector2.ZERO, Vector2(_board_stats.size_x * _board_stats.cell_scale * _board_stats.cell_size, 0), Color.CORAL, 8)
		draw_line(Vector2.ZERO, Vector2(0, _board_stats.size_y * _board_stats.cell_scale * _board_stats.cell_size), Color.CORAL, 8)
		draw_line(Vector2(_board_stats.size_x * _board_stats.cell_scale * _board_stats.cell_size, 0), Vector2(_board_stats.size_x * _board_stats.cell_scale * _board_stats.cell_size, _board_stats.size_y * _board_stats.cell_scale * _board_stats.cell_size), Color.CORAL, 8)
		draw_line(Vector2(0, _board_stats.size_y * _board_stats.cell_scale * _board_stats.cell_size), Vector2(_board_stats.size_x * _board_stats.cell_scale * _board_stats.cell_size, _board_stats.size_y * _board_stats.cell_scale * _board_stats.cell_size), Color.CORAL, 8)
