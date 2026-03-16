class_name TTTEOS extends Node

var secrets = preload("res://product_details.gd")
const PORT = 9099
const SOCKET_NAME = "tttgame"
const LOBBY_BUCKET_ID = "TTTGameLobby"

var eos_setup = false
var local_user_id = ""
var is_server = false
var peer := EOSGMultiplayerPeer.new()
var peer_user_id = 0
var local_lobby: HLobby

signal game_started
signal hosting_server

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if !eos_setup:
		var init_opts := EOS.Platform.InitializeOptions.new()
		init_opts.product_name = secrets.product_name
		init_opts.product_version = secrets.product_version
		
		var init_results = EOS.Platform.PlatformInterface.initialize(init_opts)
		if init_results != EOS.Result.Success:
			printerr("Failed to initialize EOS SDK: " + EOS.result_str(init_results))
			return
		print("Initialized EOS Platform")
		
		var create_opts := EOS.Platform.CreateOptions.new()
		create_opts.product_id = secrets.product_id
		create_opts.client_id = secrets.client_id
		create_opts.client_secret = secrets.client_secret
		create_opts.deployment_id = secrets.deployment_id
		create_opts.sandbox_id = secrets.sandbox_id
		
		var _create_results = 0
		_create_results = EOS.Platform.PlatformInterface.create(create_opts)
		print("EOS Platform created")
		
		# Setup Logs from EOS
		EOS.get_instance().logging_interface_callback.connect(_on_eos_log_msg)
		var res := EOS.Logging.set_log_level(EOS.Logging.LogCategory.AllCategories, EOS.Logging.LogLevel.Info)
		if res != EOS.Result.Success:
			print("Failed to set log level: ", EOS.result_str(res))
			
		EOS.get_instance().connect_interface_login_callback.connect(_on_connect_login_callback)
		
		peer.peer_connected.connect(_on_peer_connected)
		peer.peer_disconnected.connect(_on_peer_disconnected)
		
		await HAuth.login_anonymous_async("User")
		eos_setup = true
	else:
		peer.peer_connected.connect(_on_peer_connected)
		peer.peer_disconnected.connect(_on_peer_disconnected)

func _exit_tree() -> void:
	exit_game()

func _on_connect_login_callback(data: Dictionary) -> void:
	if not data.success:
		print("Login failed")
		EOS.print_result(data)
		return
	print_rich("[color=green][b]Login successfull[/b][/color]: local_user_id=", data.local_user_id)
	local_user_id = data.local_user_id
	HAuth.product_user_id = local_user_id
	find_match()

func _on_eos_log_msg(msg) -> void:
	msg = EOS.Logging.LogMessage.from(msg) as EOS.Logging.LogMessage
	print("SDK %s | %s" % [msg.category, msg.message])

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("Shutting down EOS...")
		EOS.Platform.PlatformInterface.release()
		var res := EOS.Platform.PlatformInterface.shutdown()
		if not EOS.is_success(res):
			printerr("Failed to shutdown EOS: ", EOS.result_str(res))

func _on_peer_connected(id: int) -> void:
	print_rich("[color=orange]Player %s connected![/color]" % id)
	lock_lobby()
	peer_user_id = id
	start_game()

func _on_peer_disconnected(id: int) -> void:
	print_rich("[color=orange]Player %s disconnected![/color]" % id)
	exit_game()

func find_match() -> void:
	await get_tree().create_timer(1.0).timeout
	if not await search_lobbies():
		await get_tree().create_timer(1.0).timeout
		if not await search_lobbies():
			create_lobby()

func search_lobbies() -> bool:
	var lobbies = await HLobbies.search_by_bucket_id_async(LOBBY_BUCKET_ID)
	if !lobbies:
		printerr("No lobbies found!")
		return false
	
	var lobby: HLobby = lobbies[0]
	await HLobbies.join_by_id_async(lobby.lobby_id)
	
	var result := peer.create_client(SOCKET_NAME, lobby.owner_product_user_id)
	if result != OK:
		printerr("Failed to create client: " + EOS.result_str(result))
		return false
	
	multiplayer.multiplayer_peer = peer
	return true
	
func create_lobby() -> void:
	var create_opts := EOS.Lobby.CreateLobbyOptions.new()
	create_opts.bucket_id = LOBBY_BUCKET_ID
	create_opts.max_lobby_members = 2
	
	var new_lobby = await HLobbies.create_lobby_async(create_opts)
	if new_lobby == null:
		return
	
	var result := peer.create_server(SOCKET_NAME)
	if result != OK:
		printerr("Failed to create server: " + EOS.result_str(result))
		return
	
	multiplayer.multiplayer_peer = peer
	is_server = true
	local_lobby = new_lobby
	hosting_server.emit()

func lock_lobby() -> void:
	if is_server and local_lobby:
		local_lobby.permission_level = EOS.Lobby.LobbyPermissionLevel.InviteOnly
		var success := await local_lobby.update_async()
		if success:
			print("Lobby locked (hidden)")
		else:
			print("Failed to lock lobby")

@rpc("any_peer", "call_local", "reliable")
func start_game() -> void:
	print_rich("[color=orange]Game Started\n----------[/color]")
	game_started.emit()

func exit_game() -> void:
	if peer != null:
		peer.close()
	
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer = null
	if is_server and local_lobby:
		await local_lobby.destroy_async()
	elif local_lobby:
		await local_lobby.leave_async()
	
	
	
	
