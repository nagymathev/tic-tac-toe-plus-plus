@tool

extends Resource
class_name BoardSettings

@export_range(3, 27, 2)
var size_x: int = 3:
	get:
		return size_x
	set(value):
		size_x = value
		emit_changed()

@export_range(3, 27, 2)
var size_y: int = 3:
	get:
		return size_y
	set(value):
		size_y = value
		emit_changed()

@export
var cell_sprite_frames: SpriteFrames

@export
var cell_xo_sprite_frames: SpriteFrames

@export_range(8, 128, 8, "prefer_slider")
var cell_size: int = 24:
	get:
		return cell_size
	set(value):
		cell_size = value
		emit_changed()

@export_range(1, 8, 1, "prefer_slider")
var cell_scale: int = 1:
	get:
		return cell_scale
	set(value):
		cell_scale = value
		emit_changed()
