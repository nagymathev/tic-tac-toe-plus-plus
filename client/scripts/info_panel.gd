class_name InfoPanel extends Node

@onready var my_player_cell: BoardCell = %MyPlayer
@onready var current_player_cell: BoardCell = %CurrentPlayer

@export var _board_data: BoardData

func _ready() -> void:
	_board_data.changed.connect(_on_board_data_updated)

func _on_board_data_updated() -> void:
	my_player_cell.set_cell_state(_board_data.my_player)
	current_player_cell.set_cell_state(_board_data.current_player)
