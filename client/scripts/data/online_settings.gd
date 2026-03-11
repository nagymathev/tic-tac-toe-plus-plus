class_name OnlineSettings extends RefCounted

var host: bool = false
var server_address: String
var username: String = "unknown"

func _init(_username: String, _server_address: String, _host: bool) -> void:
	self.host = _host
	self.server_address = _server_address
	self.username = _username
