@tool

class_name BoardCell extends TextureButton

@export var playerO_texture: Texture
@export var playerX_texture: Texture

@onready var button: BoardCell = self
@onready var player_texture_rect = $TextureRect

## Between 0 and 9(non inclusive)
var board_pos: int
var current_state := GameState.Tile.Empty

signal clicked(pos: Vector2i)

func set_cell_state(state: GameState.Tile):
	match state:
		GameState.Tile.Tic:
			player_texture_rect.visible = true
			player_texture_rect.texture = playerX_texture
		GameState.Tile.Tac:
			player_texture_rect.visible = true
			player_texture_rect.texture = playerO_texture
		_:
			player_texture_rect.visible = false

	current_state = state

func _ready() -> void:
	button.pressed.connect(_on_button_pressed)
	button.button_down.connect(_on_button_down)
	button.mouse_entered.connect(_on_hover)
	button.mouse_exited.connect(_off_hover)
	button.pivot_offset_ratio = Vector2(0.5, 0.5)

	set_cell_state(GameState.Tile.Empty)

func _play_audio() -> void:
	var pitch = floor(board_pos / 3) + board_pos % 3
	$AudioStreamPlayer.pitch_scale = (randf() * 0.1) + 1 + (pitch * 0.1)
	$AudioStreamPlayer.play()

func _on_button_down() -> void:
	_play_audio()

func _on_button_pressed():
	clicked.emit(board_pos)

func _on_hover():
	_play_audio()
	z_index = 10
	var tween := create_tween()
	tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _off_hover():
	z_index = 0
	var tween := create_tween()
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.4).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
