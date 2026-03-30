class_name LocalModeAPI extends Node

signal server_hosted

enum PeerKind {
	Client,
	Host,
}
	
func start_offline_game() -> PeerKind:
	print_rich("[color=green]Starting local game![/color]")
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(9099, 2)
	if err != OK:
		print_rich("[color=red]Local server already exists, connecting to it now...[/color]")
		peer.create_client("127.0.0.1", 9099)
		multiplayer.multiplayer_peer = peer
		return PeerKind.Client
		
	print_rich("[color=green]Successfully created the server!")
	multiplayer.multiplayer_peer = peer
	return PeerKind.Host

func start_online_game():
	pass
