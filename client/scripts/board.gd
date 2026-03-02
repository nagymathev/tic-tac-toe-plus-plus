@tool

class_name Board extends Node2D

# Manages all the rendering side of the game. Is not concerned with data.

@onready var _cell_render: Node2D = $CellRender

@export var _board_stats: BoardSettings
@export var _board_manager: BoardManager

func _on_board_stats_changed():
	print("[Board] Stats Changed")
	_delete_board()
	_create_board()
	queue_redraw()

func _create_board():
	var cell_scene := preload("res://scenes/board_cell.tscn")
	for y in _board_stats.size_y:
		for x in _board_stats.size_x:
			var cell: BoardCell = cell_scene.instantiate()
			cell.board_pos = Vector2i(x, y)
			cell.clicked.connect(_on_cell_pressed)
			_cell_render.add_child(cell)
			cell.position = Vector2(x * _board_stats.cell_size * _board_stats.cell_scale, y * _board_stats.cell_size * _board_stats.cell_scale)

			@warning_ignore("integer_division")
			cell.scale = Vector2.ONE * _board_stats.cell_scale

func _create_board_with_data(data: Array) -> void:
	var cell_scene := preload("res://scenes/board_cell.tscn")
	for y in _board_stats.size_y:
		for x in _board_stats.size_x:
			var cell: BoardCell = cell_scene.instantiate()
			_cell_render.add_child(cell)
			cell.clicked.connect(_on_cell_pressed)

			match data[y][x]:
				"X":
					cell.set_cell_state(BoardCell.CellStates.X)
				"O":
					cell.set_cell_state(BoardCell.CellStates.O)
				_:
					cell.set_cell_state(BoardCell.CellStates.None)

			cell.board_pos = Vector2i(x, y)
			cell.position = Vector2(x * _board_stats.cell_size * _board_stats.cell_scale, y * _board_stats.cell_size * _board_stats.cell_scale)
			@warning_ignore("integer_division")
			cell.scale = Vector2.ONE * _board_stats.cell_scale


func _delete_board():
	var children := _cell_render.get_children()
	for child in children:
		child.queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_board_stats.changed.connect(_on_board_stats_changed)
	_on_board_stats_changed()

	if !Engine.is_editor_hint():
		var player_type := await _board_manager.register()
		var my_player: BoardCell = $InfoCells/MyPlayer as BoardCell
		match player_type:
			BoardManager.PlayerType.PlayerX:
				my_player.set_cell_state(BoardCell.CellStates.X)
			BoardManager.PlayerType.PlayerO:
				my_player.set_cell_state(BoardCell.CellStates.O)
			_:
				my_player.set_cell_state(BoardCell.CellStates.None)

		var timer := Timer.new()
		add_child(timer)
		timer.timeout.connect(_on_health_check)
		timer.start()

func _draw() -> void:
	if Engine.is_editor_hint():
		draw_line(Vector2.ZERO, Vector2(_board_stats.size_x * _board_stats.cell_scale * _board_stats.cell_size, 0), Color.CORAL, 8)
		draw_line(Vector2.ZERO, Vector2(0, _board_stats.size_y * _board_stats.cell_scale * _board_stats.cell_size), Color.CORAL, 8)
		draw_line(Vector2(_board_stats.size_x * _board_stats.cell_scale * _board_stats.cell_size, 0), Vector2(_board_stats.size_x * _board_stats.cell_scale * _board_stats.cell_size, _board_stats.size_y * _board_stats.cell_scale * _board_stats.cell_size), Color.CORAL, 8)
		draw_line(Vector2(0, _board_stats.size_y * _board_stats.cell_scale * _board_stats.cell_size), Vector2(_board_stats.size_x * _board_stats.cell_scale * _board_stats.cell_size, _board_stats.size_y * _board_stats.cell_scale * _board_stats.cell_size), Color.CORAL, 8)

func _on_cell_pressed(pos: Vector2i):
	print("[Board] Cell pressed")
	_board_manager.take_turn(pos)

func _on_health_check():
	var board_data := await _board_manager.health_check()
	var players: Array = board_data["players"]
	print(players)
	var current_player: int = board_data["current_player"]
	print(current_player)
	var current_player_cell: BoardCell = $InfoCells/CurrentPlayer as BoardCell
	match players[current_player]:
		"X":
			current_player_cell.set_cell_state(BoardCell.CellStates.X)
		"O":
			current_player_cell.set_cell_state(BoardCell.CellStates.O)
		_:
			current_player_cell.set_cell_state(BoardCell.CellStates.None)

	# Update Board
	# TODO: Replace this with proper updating of data.
	_delete_board()
	_create_board_with_data(board_data["board"])
	queue_redraw()
