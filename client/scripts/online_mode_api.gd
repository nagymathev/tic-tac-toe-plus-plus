class_name OnlineModeAPI extends Node

signal server_hosted

enum PeerKind {
	Client,
	Host,
}

@onready var online_settings_widget = preload("res://scenes/window/online_play_settings_widget.tscn")
@onready var eos: TTTEOS = $TTTEOS
var menu_stack: Array[Control] = []
	
func start_online_game() -> PeerKind:
	var settings_widget: OnlineSettingsMenu = online_settings_widget.instantiate()
	settings_widget.cancelled.connect(_on_online_cancelled)
	add_child(settings_widget)
	menu_stack.push_back(settings_widget)
	var settings: OnlineSettings = await settings_widget.proceed
	var widget: Control = menu_stack.pop_back()
	widget.queue_free()
	print_rich("[color=green]Playing online with username: %s[/color]" % settings.username)
	
	
	var search_window = preload("res://scenes/window/game_search_window.tscn")
	search_window = search_window.instantiate()
	add_child(search_window)
	
	# Start searching for games
	eos.init_connection()
	var peer_kind := await eos.find_match()
	
	search_window.queue_free()
	return peer_kind
	
func _on_online_cancelled() -> void:
	var widget: Control = menu_stack.pop_back()
	widget.queue_free()
