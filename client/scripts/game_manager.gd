class_name GameManager extends Node

@export var board_data: BoardData
@export var player_x_tex: Texture2D
@export var player_o_tex: Texture2D
@export var tie_tex: Texture2D

func _ready() -> void:
	board_data.game_finished.connect(_on_game_finished)
	%GameFinishedScreen.play_again.connect(_on_play_again)

func _on_play_again():
	board_data.game_restart.emit()

func _on_game_finished(winner: String):
	var winning_screen = %GameFinishedScreen
	winning_screen.visible = true
	match winner:
		"X":
			winning_screen.set_winning_player_texture(player_x_tex)
		"O":
			winning_screen.set_winning_player_texture(player_o_tex)
		_:
			winning_screen.set_winning_player_texture(tie_tex)
