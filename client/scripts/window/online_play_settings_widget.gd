class_name OnlineSettingsMenu extends Control

signal proceed(settings: OnlineSettings)
signal cancelled

@export var host_toggle: CheckButton
@export var ip_panel: Control
@export var username_input: LineEdit
@export var ip_input: LineEdit
@export var ok_button: Button
@export var cancel_button: Button

func _ready() -> void:
	ok_button.pressed.connect(_on_continue)
	cancel_button.pressed.connect(_on_cancel)
	host_toggle.pressed.connect(_on_host_toggle)

func _on_host_toggle() -> void:
	if host_toggle.button_pressed:
		ip_panel.hide()
	else:
		ip_panel.show()

func _on_continue() -> void:
	var is_hosting: bool = host_toggle.button_pressed
	if username_input.text.is_empty() or !is_hosting and ip_input.text.is_empty():
		return
	var settings: OnlineSettings = OnlineSettings.new(username_input.text, ip_input.text, is_hosting)
	proceed.emit(settings)

func _on_cancel() -> void:
	cancelled.emit()
