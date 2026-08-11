extends Node

var game: Node = null
var overlay_label: Label = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_initialize")

func _initialize() -> void:
	game = get_parent()
	_build_overlay()

func _build_overlay() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 50
	add_child(layer)

	overlay_label = Label.new()
	overlay_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	overlay_label.position = Vector2(-330.0, 14.0)
	overlay_label.size = Vector2(310.0, 70.0)
	overlay_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	overlay_label.text = "QA BUILD\nF8 02:30  ·  F9 03:10  ·  F10 03:16"
	overlay_label.modulate = Color(0.62, 0.72, 0.68, 0.72)
	overlay_label.add_theme_font_size_override("font_size", 12)
	layer.add_child(overlay_label)

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	var key_event: InputEventKey = event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return

	match key_event.physical_keycode:
		KEY_F8:
			_jump_to_minute(150.0, "QA JUMP: 02:30")
		KEY_F9:
			_jump_to_minute(190.0, "QA JUMP: 03:10")
		KEY_F10:
			_jump_to_minute(196.0, "QA JUMP: 03:16")

func _jump_to_minute(target_minutes: float, message: String) -> void:
	if game == null or not is_instance_valid(game):
		return
	if not _has_property(game, "shift_minutes"):
		return

	game.set("shift_minutes", target_minutes)
	if _has_property(game, "night_locked"):
		game.set("night_locked", false)

	if game.has_method("show_message"):
		game.call("show_message", message, 2.0)

func _has_property(object: Object, property_name: String) -> bool:
	for property_info: Dictionary in object.get_property_list():
		if String(property_info.get("name", "")) == property_name:
			return true
	return false
