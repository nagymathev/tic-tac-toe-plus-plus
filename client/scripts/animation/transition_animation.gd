class_name TransitionAnimation extends Node

@export var entry_position: Vector2
@export var exit_position: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play_entry_animation() -> void:
	var parent := get_parent() as Control
	parent.position = exit_position
	
	var tween := create_tween()
	tween.tween_property(parent, "position", entry_position, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

func play_exit_animation() -> void:
	var parent := get_parent() as Control
	parent.position = entry_position
	
	var tween := create_tween()
	tween.tween_property(parent, "position", exit_position, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
