extends Control

func _ready() -> void:
	%PlayAgainButton.pressed.connect(_on_play_again)
	%MainMenuButton.pressed.connect(_on_main_menu)
	EventBus.game_ended.connect(_on_game_ended)
	EventBus.game_started.connect(_game_started)

func _game_started() -> void:
	if !multiplayer.is_server():
		%PlayAgainButton.disabled = true

func _on_play_again():
	EventBus.game_restart.emit()

func _on_main_menu():
	var trans_anim := $TransitionAnimation as TransitionAnimation
	trans_anim.play_exit_animation()
	EventBus.back_to_menu.emit()

func _on_game_ended() -> void:
	var trans_anim := $TransitionAnimation as TransitionAnimation
	trans_anim.play_entry_animation()
