@tool

extends Node2D
class_name BoardCell

@onready var cell_frame: AnimatedSprite2D = $CellFrame
@onready var cell_xo: AnimatedSprite2D = $CellFrame/CellXO
@onready var area2d: Area2D = $CellFrame/Area2D
@onready var collision_shape2d: CollisionShape2D = $CellFrame/Area2D/CollisionShape2D

@export var _board_settings: BoardSettings

var is_hover := false
var current_state := CellStates.None

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
	match state:
		CellStates.None:
			cell_xo.visible = false
		_:
			cell_xo.visible = true
			cell_xo.frame = state - 1
	current_state = state

func _ready() -> void:
	area2d.mouse_entered.connect(_on_mouse_entered)
	area2d.mouse_exited.connect(_on_mouse_exited)
	area2d.input_event.connect(_on_input)
	
	if _board_settings:
		cell_frame.position = Vector2.ONE * _board_settings.cell_size * 0.5
		(collision_shape2d.shape as RectangleShape2D).size = Vector2.ONE * _board_settings.cell_size
		if _board_settings.cell_sprite_frames:
			cell_frame.sprite_frames = _board_settings.cell_sprite_frames
			
		if _board_settings.cell_xo_sprite_frames:
			cell_xo.sprite_frames = _board_settings.cell_xo_sprite_frames
	
	set_cell_state(CellStates.None)

func _process(_delta: float) -> void:
	if !Engine.is_editor_hint():
		if (is_hover and Input.is_mouse_button_pressed(MouseButton.MOUSE_BUTTON_LEFT)):
			set_frame_state(FrameStates.Pressed)
		elif (is_hover and !Input.is_mouse_button_pressed(MouseButton.MOUSE_BUTTON_LEFT)):
			set_frame_state(FrameStates.Hover)
	
func _pressed():
	print("pressed")
	current_state = (int(current_state) + 1) % 3 as CellStates
	set_cell_state(current_state)

func _on_input(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event.is_action_pressed("ClickCell"):
		_pressed()

func _on_mouse_entered():
	is_hover = true
	set_frame_state(FrameStates.Hover)
	
func _on_mouse_exited():
	is_hover = false
	set_frame_state(FrameStates.Normal)
