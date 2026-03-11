class_name GameManager extends Node

## The Root of the project, this manages the stages of the game, so going from menu screen to gameplay.

@onready var menu_scene := preload("res://scenes/menu.tscn")
var menu: Menu
var menu_open: bool = false
@onready var game_scene := preload("res://scenes/game.tscn")
var game: Game

func _ready() -> void:
	_open_menu()

## Starts local server with AI.
func _offline_play() -> void:
	_close_menu()
	game = game_scene.instantiate()
	add_child(game)
	game.start_offline_game()

## Connect to game server
func _online_play(settings: OnlineSettings) -> void:
	_close_menu()
	game = game_scene.instantiate()
	add_child(game)
	game.start_online_game(settings)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel"):
		if menu_open:
			_close_menu()
		else:
			_open_menu()

func _open_menu() -> void:
	print("menu open")
	menu = menu_scene.instantiate()
	menu.offline_play.connect(_offline_play)
	menu.online_play.connect(_online_play)
	add_child(menu)
	menu_open = true

func _close_menu() -> void:
	print("menu closed")
	menu.queue_free()
	menu_open = false
