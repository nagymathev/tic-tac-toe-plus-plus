@tool

extends Resource
class_name BoardResource

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

@export_range(32, 128, 32, "prefer_slider")
var cell_size: int = 32:
	get:
		return cell_size
	set(value):
		cell_size = value
		emit_changed()
