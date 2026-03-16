class_name OnlineSettings extends RefCounted

var username: String = "unknown"

func _init(_username: String) -> void:
	self.username = _username
