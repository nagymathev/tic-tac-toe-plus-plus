class_name Menu extends Node

signal online_play
signal offline_play
signal settings

func _ready() -> void:
	%PlayOnlineButton.pressed.connect(_on_play_online)
	%PlayOfflineButton.pressed.connect(_on_play_offline)
	%SettingsButton.pressed.connect(_on_settings)
	%QuitButton.pressed.connect(_on_quit)

func _on_play_online() -> void:
	online_play.emit()

func _on_play_offline() -> void:
	offline_play.emit()

func _on_settings() -> void:
	settings.emit()

func _on_quit() -> void:
	get_tree().quit()
