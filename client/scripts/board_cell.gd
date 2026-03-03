@tool

class_name BoardCell extends Control

@export var playerO_texture: Texture
@export var playerX_texture: Texture
@export var _board_settings: BoardSettings

@onready var button = $BackgroundButton
@onready var player_texture_rect = $BackgroundButton/TextureRect

var board_pos: Vector2i
var current_state := BoardData.PlayerStates.Spectator

signal clicked(pos: Vector2i)

func set_cell_state(state: BoardData.PlayerStates):
	match state:
		BoardData.PlayerStates.PlayerX:
			player_texture_rect.visible = true
			player_texture_rect.texture = playerX_texture
		BoardData.PlayerStates.PlayerO:
			player_texture_rect.visible = true
			player_texture_rect.texture = playerO_texture
		_:
			player_texture_rect.visible = false

	current_state = state

func _ready() -> void:
	button.pressed.connect(_on_button_pressed)

	set_cell_state(BoardData.PlayerStates.Spectator)

func _on_button_pressed():
	clicked.emit(board_pos)
