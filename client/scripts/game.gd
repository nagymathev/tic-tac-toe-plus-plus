class_name Game extends Control

## Manages and orchestrates Boards along with it their signals.
## Not concerned with multiplayer that's the GameManager's role.
## This just receives actions and reflects on them.

var client_id: int
@onready var board: Board = $Board

func _ready() -> void:
	pass

#func start_offline_game():
#	print_rich("[color=green]Starting local game![/color]")
#	var peer := ENetMultiplayerPeer.new()
#	var err := peer.create_server(9099, 2)
#	if err != OK:
#		print_rich("[color=red]Local server already exists, connecting to it now...[/color]")
#		peer.create_client("127.0.0.1", 9099)
#	else:
#		print_rich("[color=green]Successfully created the server!")
#		GameStateManager._player_connected_event(1, "THEGARY") # Necessary for the host, otherwise gets added second
#	
#	multiplayer.multiplayer_peer = peer
#
#func _exit_tree() -> void:
#	if local_server_process.has("pid"):
#		OS.kill(local_server_process["pid"])
#
#func _start_local_server():
#	# TODO: have a more flexible server location
#	# Exported or not
#	if OS.has_feature("editor"):
#		local_server_process = OS.execute_with_pipe("../target/debug/server", [], false)
#	else:
#		# TODO: server should be bundled with the exported project.
#		pass
#
#func start_online_game(settings: OnlineSettings):
#	pass
#
#func _on_game_finished(winner: int):
#	var finished_screen_scene := preload("res://scenes/game_finished_screen.tscn").instantiate()
#	add_child(finished_screen_scene)
#
#func _on_game_begin_set_local_player_indicator(goes_first: int) -> void:
#	%MyPlayer.set_cell_state(GameStateManager.game_state.players[multiplayer.get_unique_id()].piece)
#
#func _on_game_begin_set_active_player_indicator(goes_first: int) -> void:
#	%CurrentPlayer.set_cell_state(GameStateManager.game_state.players[GameStateManager.game_state.active_player_id].piece)
