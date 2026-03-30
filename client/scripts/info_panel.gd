class_name InfoPanel extends Node

@onready var my_player_cell: BoardCell = %MyPlayer
@onready var current_player_cell: BoardCell = %CurrentPlayer

func _ready() -> void:
	EventBus.game_started.connect(_on_game_started)
	EventBus.back_to_menu.connect(_hide)

func _hide() -> void:
	var trans_anim := $TransitionAnimation as TransitionAnimation
	trans_anim.play_exit_animation()

func _on_game_started() -> void:
	var trans_anim := $TransitionAnimation as TransitionAnimation
	trans_anim.play_entry_animation()
