@tool

class_name Board extends Control

# Manages all the rendering side of the game. Is not concerned with data.

@onready var _cell_render: Control = %CellRender
var cells: Array[Array]

@export var _board_stats: BoardSettings
@export var _board_manager: BoardManager
@export var _board_data: BoardData

func _on_board_stats_changed():
	print("[Board] Stats Changed")
	_delete_board()
	_create_board()
	queue_redraw()

func _create_board():
	var cell_scene := preload("res://scenes/board_cell.tscn")

	# Only for setting the position values
	for y in _board_stats.size_y:
		cells.append([])
		for x in _board_stats.size_x:
			var cell: BoardCell = cell_scene.instantiate()
			cell.board_pos = Vector2i(x, y)
			cell.clicked.connect(_on_cell_pressed)

			_cell_render.add_child(cell)
			cells[y].append(cell)

func _update_board(data: Array) -> void:
	for y in cells.size():
		for x in cells[y].size():
			var cell = cells[y][x]
			match data[y][x]:
				"X":
					cell.set_cell_state(BoardData.PlayerStates.PlayerX)
				"O":
					cell.set_cell_state(BoardData.PlayerStates.PlayerO)
				_:
					cell.set_cell_state(BoardData.PlayerStates.Spectator)

func _delete_board():
	var children := _cell_render.get_children()
	for child in children:
		child.queue_free()
	cells.clear()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_board_stats.changed.connect(_on_board_stats_changed)
	_on_board_stats_changed()

	if !Engine.is_editor_hint():
		var player_type := await _board_manager.register()
		match player_type:
			BoardData.PlayerStates.PlayerX:
				_board_data.my_player = BoardData.PlayerStates.PlayerX
			BoardData.PlayerStates.PlayerO:
				_board_data.my_player = BoardData.PlayerStates.PlayerO
			_:
				_board_data.my_player = BoardData.PlayerStates.Spectator

		var timer := Timer.new()
		add_child(timer)
		timer.timeout.connect(_on_health_check)
		timer.wait_time = 10.0/60.0
		timer.start()

# func _draw() -> void:
# 	if Engine.is_editor_hint():
# 		draw_line(Vector2.ZERO, Vector2(_board_stats.size_x * _board_stats.cell_scale * _board_stats.cell_size, 0), Color.CORAL, 1)
# 		draw_line(Vector2.ZERO, Vector2(0, _board_stats.size_y * _board_stats.cell_scale * _board_stats.cell_size), Color.CORAL, 1)
# 		draw_line(Vector2(_board_stats.size_x * _board_stats.cell_scale * _board_stats.cell_size, 0), Vector2(_board_stats.size_x * _board_stats.cell_scale * _board_stats.cell_size, _board_stats.size_y * _board_stats.cell_scale * _board_stats.cell_size), Color.CORAL, 1)
# 		draw_line(Vector2(0, _board_stats.size_y * _board_stats.cell_scale * _board_stats.cell_size), Vector2(_board_stats.size_x * _board_stats.cell_scale * _board_stats.cell_size, _board_stats.size_y * _board_stats.cell_scale * _board_stats.cell_size), Color.CORAL, 1)

func _on_cell_pressed(pos: Vector2i):
	print("[Board] Cell pressed")
	_board_manager.take_turn(pos)
	_on_health_check()

func _on_health_check():
	var board_data := await _board_manager.health_check()
	var players: Array = board_data["players"]
	var current_player: int = board_data["current_player"]
	match players[current_player]:
		"X":
			_board_data.current_player = BoardData.PlayerStates.PlayerX
		"O":
			_board_data.current_player = BoardData.PlayerStates.PlayerO
		_:
			_board_data.current_player = BoardData.PlayerStates.Spectator

	_update_board(board_data["board"])
