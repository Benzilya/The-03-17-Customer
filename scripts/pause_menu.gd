extends Node

const MAIN_MENU_SCENE: String = "res://scenes/main_menu.tscn"
const GAME_SCENE: String = "res://scenes/main.tscn"

var overlay: ColorRect
var panel: PanelContainer
var paused: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("pause_manager")
	_build_pause_ui()

func toggle_pause() -> void:
	if paused:
		_resume()
	else:
		_pause()

func _pause() -> void:
	paused = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	overlay.visible = true

func _resume() -> void:
	paused = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	overlay.visible = false

func _restart_shift() -> void:
	get_tree().paused = false
	paused = false
	get_tree().change_scene_to_file(GAME_SCENE)

func _return_to_menu() -> void:
	get_tree().paused = false
	paused = false
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func _quit_game() -> void:
	get_tree().paused = false
	get_tree().quit()

func _build_pause_ui() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.name = "PauseLayer"
	layer.layer = 100
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(layer)

	overlay = ColorRect.new()
	overlay.name = "PauseOverlay"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.0, 0.0, 0.0, 0.82)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.visible = false
	layer.add_child(overlay)

	panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-210, -210)
	panel.size = Vector2(420, 420)
	panel.process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.add_child(panel)

	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)

	var title: Label = Label.new()
	title.text = "SHIFT PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	box.add_child(title)

	var subtitle: Label = Label.new()
	subtitle.text = "MORROW MARKET / NIGHT 1"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.modulate = Color(0.62, 0.68, 0.66)
	box.add_child(subtitle)

	var divider: HSeparator = HSeparator.new()
	box.add_child(divider)

	_add_button(box, "RESUME SHIFT", _resume)
	_add_button(box, "RESTART NIGHT 1", _restart_shift)
	_add_button(box, "RETURN TO MAIN MENU", _return_to_menu)
	_add_button(box, "QUIT GAME", _quit_game)

	var hint: Label = Label.new()
	hint.text = "ESC — resume"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.modulate = Color(0.48, 0.54, 0.52)
	box.add_child(hint)

func _add_button(parent: VBoxContainer, label: String, action: Callable) -> void:
	var button: Button = Button.new()
	button.text = label
	button.custom_minimum_size = Vector2(380, 50)
	button.process_mode = Node.PROCESS_MODE_ALWAYS
	button.pressed.connect(action)
	parent.add_child(button)
