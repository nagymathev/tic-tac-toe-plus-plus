@tool

extends Node2D
class_name BoardCell

@onready var cell_frame: AnimatedSprite2D = $CellFrame
@onready var cell_xo: AnimatedSprite2D = $CellFrame/CellXO
@onready var area2d: Area2D = $CellFrame/Area2D

enum FrameStates {
	Normal,
	Hover,
	Pressed
}

enum CellStates {
	None,
	X,
	O
}

func set_frame_state(state: FrameStates):
	cell_frame.frame = state

func set_cell_state(state: CellStates):
	cell_xo.frame = state

func _ready() -> void:
	area2d.mouse_entered.connect(_on_mouse_entered)
	area2d.mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	set_frame_state(FrameStates.Hover)
	
func _on_mouse_exited():
	set_frame_state(FrameStates.Normal)
