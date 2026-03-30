class_name Menu extends Control

signal online_play(settings: OnlineSettings)
signal settings

@onready var online_settings_widget = preload("res://scenes/window/online_play_settings_widget.tscn")
var menu_stack: Array[Control] = []

@onready var online_button: Button = %PlayOnlineButton
@onready var offline_button: Button = %PlayOfflineButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_button: Button = %QuitButton

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
	print_rich("[color=green]Playing online with username: %s[/color]" % settings.username)
	
	# Start searching for games
	var eos = TTTEOS.new()
	add_child(eos)
	eos.hosting_server.connect(_on_server_hosting)
	
	var search_window = preload("res://scenes/window/game_search_window.tscn")
	search_window = search_window.instantiate()
	add_child(search_window)
	
	await eos.game_started
	search_window.queue_free()
	online_play.emit(settings)

# TODO: Remove it from this class, it doesn't belong here.
func _on_server_hosting() -> void:
	pass

func _on_online_cancelled() -> void:
	var widget: Control = menu_stack.pop_back()
	widget.queue_free()

func _on_play_offline() -> void:
	pass

func _on_settings() -> void:
	settings.emit()

func _on_quit() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
