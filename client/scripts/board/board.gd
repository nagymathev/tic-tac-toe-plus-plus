@tool

class_name Board extends Control

## Manages all the rendering and input side of the game.

@onready var _cell_render: Control = %CellRender
var cells: Array[BoardCell]

@export var _board_data: BoardData

signal placed_tile(at: int)

func _init_board():
	_delete_board()
	_create_board()
	queue_redraw()

func _create_board():
	var cell_scene := preload("res://scenes/board/board_cell.tscn")

	for i in range(9):
		var cell: BoardCell = cell_scene.instantiate()
		cell.board_pos = i
		cell.clicked.connect(_on_cell_pressed)
		_cell_render.add_child(cell)
		cells.append(cell)

func _delete_board():
	var children := _cell_render.get_children()
	for child in children:
		child.queue_free()
	cells.clear()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_init_board()

# func _draw() -> void:
# 	if Engine.is_editor_hint():
# 		draw_line(Vector2.ZERO, Vector2(_board_stats.size_x * _board_stats.cell_scale * _board_stats.cell_size, 0), Color.CORAL, 1)
# 		draw_line(Vector2.ZERO, Vector2(0, _board_stats.size_y * _board_stats.cell_scale * _board_stats.cell_size), Color.CORAL, 1)
# 		draw_line(Vector2(_board_stats.size_x * _board_stats.cell_scale * _board_stats.cell_size, 0), Vector2(_board_stats.size_x * _board_stats.cell_scale * _board_stats.cell_size, _board_stats.size_y * _board_stats.cell_scale * _board_stats.cell_size), Color.CORAL, 1)
# 		draw_line(Vector2(0, _board_stats.size_y * _board_stats.cell_scale * _board_stats.cell_size), Vector2(_board_stats.size_x * _board_stats.cell_scale * _board_stats.cell_size, _board_stats.size_y * _board_stats.cell_scale * _board_stats.cell_size), Color.CORAL, 1)

## Notify server of action
func _on_cell_pressed(at: int):
	print("[Board] Cell %d pressed" % at)
	self.placed_tile.emit(at)

func place_tile(at: int, tile: GameState.Tile):
	var cell := cells[at]
	cell.set_cell_state(tile)
