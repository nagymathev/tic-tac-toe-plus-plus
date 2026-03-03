class_name BoardData extends Resource

enum PlayerStates {
	PlayerX,
	PlayerO,
	Spectator
}

var my_player: PlayerStates:
	get:
		return my_player
	set(value):
		my_player = value
		emit_changed()
var current_player: PlayerStates:
	get:
		return current_player
	set(value):
		current_player = value
		emit_changed()
