class_name WorldManager extends Node

## The Root of the project, this manages the stages of the game, so going from menu screen to gameplay.

@onready var menu: Menu = $UI/Menu
@onready var game: Game = $GameLayer/Game
@onready var game_mgr: GameStateManager = $GameStateManager

func _ready() -> void:
	menu.offline_button.pressed.connect(_offline_play)
	menu.online_button.pressed.connect(_online_play)
	EventBus.back_to_menu.connect(_on_back_to_menu)

## Starts local server with AI.
func _offline_play() -> void:
	await _transition()
	menu.visible = false
	game.visible = true
	game_mgr.start_local_game()

## Connect to game server
func _online_play() -> void:
	await _transition()
	menu.visible = false
	game.visible = true
	game_mgr.start_online_game()

func _on_back_to_menu() -> void:
	await _transition()
	menu.visible = true
	game.visible = false
	game_mgr.stop_game()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel"):
		menu.visible = !menu.visible

func _transition() -> void:
	var animation := $Transitions/AnimationPlayer as AnimationPlayer
	animation.play("enter_transition")
	await animation.animation_finished
	await get_tree().create_timer(1.0).timeout
	animation.play("exit_transition")
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
