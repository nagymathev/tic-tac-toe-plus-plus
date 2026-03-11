class_name OnlineSettingsMenu extends Control

signal proceed(settings: OnlineSettings)
signal cancelled

func _ready() -> void:
	%OkButton.pressed.connect(_on_continue)
	%CancelButton.pressed.connect(_on_cancel)

func _process(delta: float) -> void:
	if %HostToggle.button_pressed:
		$Background/PanelContainer/MarginContainer/VBoxContainer/PanelContainer2.visible = false
	else:
		$Background/PanelContainer/MarginContainer/VBoxContainer/PanelContainer2.visible = true

func _on_continue() -> void:
	var user_input: LineEdit = %UsernameInput
	var ip_input: LineEdit = %UsernameInput
	var is_hosting: bool = %HostToggle.button_pressed
	if user_input.text.is_empty() or !is_hosting and ip_input.text.is_empty():
		return
	var settings: OnlineSettings = OnlineSettings.new(user_input.text, ip_input.text, is_hosting)
	proceed.emit(settings)

func _on_cancel() -> void:
	cancelled.emit()
