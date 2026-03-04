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
	button.mouse_entered.connect(_on_hover)
	button.mouse_exited.connect(_off_hover)
	button.pivot_offset_ratio = Vector2(0.5, 0.5)

	set_cell_state(BoardData.PlayerStates.Spectator)

func _on_button_pressed():
	clicked.emit(board_pos)

func _on_hover():
	z_index = 10
	var tween := create_tween()
	tween.tween_property(button, "scale", Vector2(1.2, 1.2), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _off_hover():
	z_index = 0
	var tween := create_tween()
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.4).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
