extends Node

# M9 consequence/atmosphere layer. Watches Night 2 decisions and makes mistakes
# visible in the environment instead of only affecting the final score.

var game: Node
var world_environment: WorldEnvironment
var base_ambient_energy: float = 0.48
var last_total_decisions: int = 0
var last_correct_decisions: int = 0
var warning_overlay: ColorRect
var warning_label: Label
var consequence_timer: float = 0.0
var flicker_timer: float = 0.0
var wrong_calls: int = 0

func _ready() -> void:
	call_deferred("_initialize")

func _initialize() -> void:
	game = get_parent()
	world_environment = _find_world_environment()
	_build_overlay()
	set_process(true)

func _find_world_environment() -> WorldEnvironment:
	for child: Node in game.get_children():
		if child is WorldEnvironment:
			return child as WorldEnvironment
	return null

func _process(delta: float) -> void:
	if game == null or not is_instance_valid(game):
		return
	_monitor_decisions()
	_update_consequence(delta)
	_update_ambient_flicker(delta)

func _monitor_decisions() -> void:
	var total_value: Variant = game.get("total_decisions")
	var correct_value: Variant = game.get("correct_decisions")
	if typeof(total_value) != TYPE_INT or typeof(correct_value) != TYPE_INT:
		return
	var total: int = int(total_value)
	var correct: int = int(correct_value)
	if total <= last_total_decisions:
		return
	var new_wrong: bool = correct <= last_correct_decisions
	last_total_decisions = total
	last_correct_decisions = correct
	if new_wrong:
		wrong_calls += 1
		_trigger_wrong_call()
	else:
		_trigger_correct_call()

func _trigger_wrong_call() -> void:
	consequence_timer = 4.0
	warning_overlay.visible = true
	warning_overlay.color = Color(0.20, 0.01, 0.015, 0.16 + minf(float(wrong_calls) * 0.035, 0.12))
	warning_label.visible = true
	warning_label.text = _t("VERIFICATION ERROR\nA contradiction was ignored.", "ОШИБКА ПРОВЕРКИ\nПротиворечие было проигнорировано.")
	warning_label.modulate = Color(0.95, 0.55, 0.50)
	flicker_timer = 1.25

func _trigger_correct_call() -> void:
	consequence_timer = 1.4
	warning_overlay.visible = true
	warning_overlay.color = Color(0.02, 0.12, 0.08, 0.07)
	warning_label.visible = true
	warning_label.text = _t("VERIFICATION ACCEPTED", "ПРОВЕРКА ПРИНЯТА")
	warning_label.modulate = Color(0.55, 0.88, 0.68)

func _update_consequence(delta: float) -> void:
	if consequence_timer <= 0.0:
		return
	consequence_timer -= delta
	if consequence_timer <= 0.0:
		warning_overlay.visible = false
		warning_label.visible = false

func _update_ambient_flicker(delta: float) -> void:
	if flicker_timer > 0.0:
		flicker_timer -= delta
		if world_environment != null and world_environment.environment != null:
			var pulse: float = 0.20 if int(Time.get_ticks_msec() / 90) % 2 == 0 else 0.52
			world_environment.environment.ambient_light_energy = pulse
		for child: Node in game.get_children():
			if child is OmniLight3D:
				(child as OmniLight3D).light_energy = 0.35 if int(Time.get_ticks_msec() / 80) % 2 == 0 else 1.45
	elif world_environment != null and world_environment.environment != null:
		world_environment.environment.ambient_light_energy = maxf(0.34, base_ambient_energy - float(wrong_calls) * 0.035)
		for child: Node in game.get_children():
			if child is OmniLight3D:
				(child as OmniLight3D).light_energy = maxf(0.85, 1.45 - float(wrong_calls) * 0.10)

func _build_overlay() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 20
	add_child(layer)
	warning_overlay = ColorRect.new()
	warning_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	warning_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	warning_overlay.visible = false
	layer.add_child(warning_overlay)
	warning_label = Label.new()
	warning_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	warning_label.position = Vector2(-260, 145)
	warning_label.size = Vector2(520, 90)
	warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warning_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	warning_label.add_theme_font_size_override("font_size", 20)
	warning_label.visible = false
	layer.add_child(warning_label)

func _t(en: String, ru: String) -> String:
	var localization: Script = load("res://scripts/localization.gd")
	return ru if localization.get_language() == "ru" else en
