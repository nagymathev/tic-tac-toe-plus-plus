class_name WorldManager extends Node

## The Root of the project, this manages the stages of the game, so going from menu screen to gameplay.

@onready var menu: Menu = $Menu
@onready var game: Game = $Game

func _ready() -> void:
	menu.offline_play.connect(_offline_play)
	menu.online_play.connect(_online_play)
	menu.hosting_server.connect(func(): game.player_joined(1, "Host"))

## Starts local server with AI.
func _offline_play() -> void:
	menu.visible = false
	game.visible = true
	game.start_offline_game()

## Connect to game server
func _online_play(settings: OnlineSettings) -> void:
	menu.visible = false
	game.visible = true
	game.start_online_game(settings)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel"):
		menu.visible = !menu.visible
