extends Control

@onready var music_slider: HSlider = $VBoxContainer4/SliderContainer/MusicSlider
@onready var sfx_slider: HSlider = $VBoxContainer4/SliderContainer/sfxSlider

@onready var jump_button: TextureButton = $VBoxContainer4/HBoxContainer/ButtonContainer/JumpButton
@onready var left_button: TextureButton = $VBoxContainer4/HBoxContainer/ButtonContainer/LeftButton
@onready var right_button: TextureButton = $VBoxContainer4/HBoxContainer/ButtonContainer/RightButton
@onready var attack_button: TextureButton = $VBoxContainer4/HBoxContainer/ButtonContainer/AttackButton

@onready var jump_label: Label = $VBoxContainer4/HBoxContainer/ButtonContainer/JumpButton/JumpLabel
@onready var left_label: Label = $VBoxContainer4/HBoxContainer/ButtonContainer/LeftButton/LeftLabel
@onready var right_label: Label = $VBoxContainer4/HBoxContainer/ButtonContainer/RightButton/RightLabel
@onready var attack_label: Label = $VBoxContainer4/HBoxContainer/ButtonContainer/AttackButton/AttackLabel

var waiting_for_key: String = ""   # which action is being rebound

func _ready() -> void:
	# Initialize sliders from bus volumes
	music_slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	sfx_slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))

	music_slider.connect("value_changed", _on_music_slider_changed)
	sfx_slider.connect("value_changed", _on_sfx_slider_changed)

	# Connect keybind buttons
	jump_button.connect("pressed", func(): _start_rebind("jump"))
	left_button.connect("pressed", func(): _start_rebind("move_left"))
	right_button.connect("pressed", func(): _start_rebind("move_right"))
	attack_button.connect("pressed", func(): _start_rebind("attack"))
	


# ─────────────────────────────────────────────
#   AUDIO CONTROL
# ─────────────────────────────────────────────

func _on_music_slider_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)

func _on_sfx_slider_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), value)


# ─────────────────────────────────────────────
#   REBINDING SYSTEM
# ─────────────────────────────────────────────

func _start_rebind(action_name: String) -> void:
	waiting_for_key = action_name
	print("Press any key to rebind action:", action_name)


func _input(event: InputEvent) -> void:
	if waiting_for_key == "":
		return

	if event is InputEventKey and event.pressed:
		var new_keycode = event.physical_keycode

		# Clear previous bindings
		InputMap.action_erase_events(waiting_for_key)

		# Assign new binding
		var new_event := InputEventKey.new()
		new_event.physical_keycode = new_keycode
		InputMap.action_add_event(waiting_for_key, new_event)

		print(waiting_for_key, "rebound to:", OS.get_keycode_string(new_keycode))

		# Update the button text
		_update_button_text(waiting_for_key, OS.get_keycode_string(new_keycode))

		waiting_for_key = ""


func _update_button_text(action_name: String, new_text: String) -> void:
	match action_name:
		"jump":
			jump_label.text = new_text
		"move_left":
			left_label.text = new_text
		"move_right":
			right_label.text = new_text
		"attack":
			attack_label.text = new_text


func _on_settings_button_pressed() -> void:
	var Settings2 = get_parent().get_node("Settings2")
	Settings2.visible = not Settings2.visible


func _on_exit_button_pressed() -> void:
	var Settings2 = get_parent().get_node("Settings2")
	Settings2.visible = not Settings2.visible
