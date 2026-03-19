extends Control

signal play_again

func _ready() -> void:
	%PlayAgainButton.pressed.connect(_on_play_again)
	%MainMenuButton.pressed.connect(_on_main_menu)

func _on_play_again():
	play_again.emit()

func _on_main_menu():
	pass

func set_winning_player_texture(tex: Texture2D):
	%WinningPlayerIcon.texture = tex
