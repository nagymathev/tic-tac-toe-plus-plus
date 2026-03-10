class_name GameManager extends Node

@export var board_data: BoardData
@export var player_x_tex: Texture2D
@export var player_o_tex: Texture2D
@export var tie_tex: Texture2D

@onready var menu_scene := preload("res://scenes/menu.tscn")
var menu: Menu
@onready var game_scene := preload("res://scenes/game.tscn")
var game: Game

func _ready() -> void:
	menu = menu_scene.instantiate()
	menu.offline_play.connect(_offline_play)
	menu.online_play.connect(_online_play)
	add_child(menu)

## Starts local server with AI.
func _offline_play() -> void:
	remove_child(menu)
	game = game_scene.instantiate()
	add_child(game)
	game.start_offline_game()

## Connect to game server
func _online_play() -> void:
	# TODO: Prompt the user whether host or connect.
	remove_child(menu)
	game = game_scene.instantiate()
	add_child(game)
	game.start_online_game()
