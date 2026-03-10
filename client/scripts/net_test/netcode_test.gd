extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	var karenclient = ClientRenet.create_connection("KaReN", "127.0.0.1:8991")
	karenclient.connected_to_game.connect(_on_connected)
	karenclient.player_joined.connect(_player_joined)
	add_child(karenclient)
	# var bobclient := ClientRenet.new()
	# bobclient.create_connection("BoB", "127.0.0.1:8991")
	# var jesseclient := ClientRenet.new()
	# jesseclient.create_connection("JessE", "127.0.0.1:8991")
	# add_child(bobclient)
	# add_child(jesseclient)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_connected(client_id: int) -> void:
	print("Hello I connected with id: ", client_id)

func _player_joined(client_id: int, username: String) -> void:
	print("Player: " + str(client_id) + " with username: " + username + " joined!")