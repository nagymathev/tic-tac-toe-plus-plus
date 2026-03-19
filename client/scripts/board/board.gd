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
	GameStateManager.placed_tile.connect(_on_tile_placed)

func _on_tile_placed(piece: GameState.Tile, at: int) -> void:
	cells[at].set_cell_state(piece)
	cells[at]._placed_animation()

## Notify server of action
func _on_cell_pressed(at: int):
	print("[Board] Cell %d pressed" % at)
	
	GameStateManager.send_place_tile_event.rpc(at)
	self.placed_tile.emit(at)

func place_tile(at: int, tile: GameState.Tile):
	var cell := cells[at]
	cell.set_cell_state(tile)
