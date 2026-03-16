class_name Menu extends Node

signal online_play(settings: OnlineSettings)
signal offline_play
signal settings

@onready var online_settings_widget = preload("res://scenes/window/online_play_settings_widget.tscn")
var menu_stack: Array[Control] = []

func _ready() -> void:
	%PlayOnlineButton.pressed.connect(_on_play_online)
	%PlayOfflineButton.pressed.connect(_on_play_offline)
	%SettingsButton.pressed.connect(_on_settings)
	%QuitButton.pressed.connect(_on_quit)

func _on_play_online() -> void:
	var settings_widget: OnlineSettingsMenu = online_settings_widget.instantiate()
	settings_widget.cancelled.connect(_on_online_cancelled)
	add_child(settings_widget)
	menu_stack.push_back(settings_widget)
	var settings: OnlineSettings = await settings_widget.proceed
	var widget: Control = menu_stack.pop_back()
	widget.queue_free()
	print("Host: %s, Username: %s " % [settings.host, settings.username])
	online_play.emit(settings)

func _on_online_cancelled() -> void:
	var widget: Control = menu_stack.pop_back()
	widget.queue_free()

func _on_play_offline() -> void:
	offline_play.emit()

func _on_settings() -> void:
	settings.emit()

func _on_quit() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
