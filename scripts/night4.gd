extends Node3D

const L = preload("res://scripts/localization.gd")
const SAVE_PATH := "user://save.json"

var clock_label: Label
var objective_label: Label
var message_label: Label
var message_timer: Timer
var shift_minutes: float = 0.0
var shift_speed: float = 14.5
var route: String = "uncertain_memory"
var threat_level: int = 0
var event_flags: Dictionary = {}
var night_locked: bool = false

func _ready() -> void:
	add_to_group("game")
	_read_progress()
	_build_environment()
	_build_store()
	_build_ui()
	_show_opening()

func _process(delta: float) -> void:
	if not night_locked:
		shift_minutes += delta * shift_speed
	var total: int = int(shift_minutes) % 360
	clock_label.text = "%02d:%02d" % [int(total / 60), total % 60]
	_run_events(total)

func _read_progress() -> void:
	var data: Dictionary = _read_save()
	route = str(data.get("night_4_route", "uncertain_memory"))
	threat_level = int(data.get("threat_level", 0))

func _show_opening() -> void:
	var text: String
	match route:
		"stable_memory":
			text = _t("NIGHT 4 — The manager asks you to write down three things you remember before turning on CCTV.", "НОЧЬ 4 — Менеджер просит записать три вещи, которые ты помнишь, прежде чем включать CCTV.")
		"contaminated_memory":
			text = _t("NIGHT 4 — Your handwritten notes are already on the counter. You do not remember writing them.", "НОЧЬ 4 — Твои рукописные заметки уже лежат на стойке. Ты не помнишь, чтобы писал их.")
		_:
			text = _t("NIGHT 4 — The store looks familiar, but one aisle is in the wrong place.", "НОЧЬ 4 — Магазин выглядит знакомо, но один проход стоит не на своём месте.")
	show_message(text, 6.0)
	objective_label.text = _t("OBJECTIVE: Record what you see before the cameras tell you what happened.", "ЗАДАЧА: Запиши, что видишь, прежде чем камеры расскажут тебе, что произошло.")

func _run_events(minutes: int) -> void:
	if minutes >= 35 and not event_flags.has("memory_note"):
		event_flags["memory_note"] = true
		show_message(_t("A paper note appears under the register: 'CAM 02 was never installed.'", "Под кассой появляется записка: «КАМ 02 никогда не устанавливали»."), 5.0)
	if minutes >= 90 and not event_flags.has("camera_claim"):
		event_flags["camera_claim"] = true
		show_message(_t("Security system: CAM 02 has recorded continuously for 417 days.", "Система безопасности: КАМ 02 непрерывно записывает уже 417 дней."), 5.0)
	if minutes >= 150 and not event_flags.has("future_memory"):
		event_flags["future_memory"] = true
		show_message(_t("Your own handwriting appears on a fresh receipt: 'Do not believe the customer at 03:17.'", "На свежем чеке появляется твой почерк: «Не верь покупателю в 03:17»."), 6.0)
	if minutes >= 197 and not event_flags.has("night4_0317"):
		event_flags["night4_0317"] = true
		shift_minutes = 197.0
		night_locked = true
		_start_0317_event()

func _start_0317_event() -> void:
	clock_label.text = "03:17"
	var data: Dictionary = _read_save()
	var memory_checked: bool = bool(data.get("night_4_memory_checked", false))
	var memory_correct: bool = bool(data.get("night_4_memory_correct", false))
	var trusted_source: String = str(data.get("night_4_trusted_source", "none"))
	if not memory_checked:
		show_message(_t("03:17\nEvery monitor shows your own face looking back from behind the register.", "03:17\nНа каждом мониторе твоё лицо смотрит на тебя из-за кассы."), 6.0)
		objective_label.text = _t("OBJECTIVE: You reached 03:17 without choosing a memory anchor.", "ЗАДАЧА: Ты дошёл до 03:17, не выбрав якорь памяти.")
	elif memory_correct:
		show_message(_t("03:17\nThe cameras rewrite the store. Your handwritten note does not change.", "03:17\nКамеры переписывают магазин. Твоя рукописная записка не меняется."), 6.0)
		objective_label.text = _t("OBJECTIVE: Hold onto the version you wrote before the cameras changed.", "ЗАДАЧА: Держись версии, которую записал до изменения камер.")
	else:
		show_message(_t("03:17\nThe source you trusted updates itself. It now says you were never employed here.", "03:17\nИсточник, которому ты поверил, обновляется. Теперь он утверждает, что ты здесь никогда не работал."), 6.0)
		objective_label.text = _t("OBJECTIVE: Your memory anchor is compromised.", "ЗАДАЧА: Твой якорь памяти скомпрометирован.")
	await get_tree().create_timer(6.0).timeout
	_finish_night(memory_checked, memory_correct, trusted_source)

func _finish_night(memory_checked: bool, memory_correct: bool, trusted_source: String) -> void:
	var data: Dictionary = _read_save()
	var integrity: int = int(data.get("memory_integrity", 0))
	var night5_route: String = "fractured_identity"
	if memory_checked and memory_correct and integrity >= 2:
		night5_route = "anchored_identity"
	elif memory_checked:
		night5_route = "uncertain_identity"
	data["night"] = 5
	data["night_4_complete"] = true
	data["night_4_0317_survived"] = true
	data["night_4_final_memory_correct"] = memory_correct
	data["night_4_final_trusted_source"] = trusted_source
	data["night_5_route"] = night5_route
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))
	show_message(_t("NIGHT 4 COMPLETE\nAt 03:17 the cameras stopped documenting reality. They started editing it.", "НОЧЬ 4 ЗАВЕРШЕНА\nВ 03:17 камеры перестали фиксировать реальность. Они начали её редактировать."), 7.0)
	objective_label.text = _t("Night 5 unlocked.", "Ночь 5 разблокирована.")

func _build_environment() -> void:
	var world: WorldEnvironment = WorldEnvironment.new()
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.003, 0.005, 0.008)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.12, 0.14, 0.18)
	env.ambient_light_energy = maxf(0.25, 0.40 - float(threat_level) * 0.025)
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world.environment = env
	add_child(world)

func _build_store() -> void:
	_box(Vector3(18,0.2,14), Vector3(0,-0.1,0), Color(0.12,0.13,0.14))
	_box(Vector3(18,0.2,14), Vector3(0,4.2,0), Color(0.07,0.08,0.09))
	_box(Vector3(18,4.2,0.25), Vector3(0,2.1,7), Color(0.19,0.20,0.21))
	_box(Vector3(0.25,4.2,14), Vector3(-9,2.1,0), Color(0.17,0.18,0.19))
	_box(Vector3(0.25,4.2,14), Vector3(9,2.1,0), Color(0.17,0.18,0.19))
	var shifted_z: float = 2.8 if route == "uncertain_memory" else 3.6
	for z: float in [-1.2,1.2,shifted_z]:
		_box(Vector3(6,1.8,0.65), Vector3(-1.8,0.9,z), Color(0.23,0.21,0.19))
	for x: float in [-5.5,0.0,5.5]:
		for z: float in [-3.5,1.0,5.0]:
			var light: OmniLight3D = OmniLight3D.new()
			light.position = Vector3(x,3.7,z)
			light.light_color = Color(0.64,0.72,0.82)
			light.light_energy = maxf(0.70,1.15-float(threat_level)*0.07)
			light.omni_range = 5.1
			add_child(light)

func _box(size: Vector3, pos: Vector3, color: Color) -> void:
	var body: StaticBody3D = StaticBody3D.new()
	body.position = pos
	add_child(body)
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.82
	mesh.material = material
	mesh_instance.mesh = mesh
	body.add_child(mesh_instance)
	var collision: CollisionShape3D = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)

func _build_ui() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	add_child(layer)
	clock_label = Label.new()
	clock_label.position = Vector2(28,22)
	clock_label.add_theme_font_size_override("font_size",30)
	layer.add_child(clock_label)
	var title: Label = Label.new()
	title.position = Vector2(28,58)
	title.text = _t("MORROW MARKET — NIGHT 4", "MORROW MARKET — НОЧЬ 4")
	layer.add_child(title)
	objective_label = Label.new()
	objective_label.position = Vector2(28,90)
	objective_label.size = Vector2(950,55)
	objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layer.add_child(objective_label)
	message_label = Label.new()
	message_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	message_label.position = Vector2(-350,-180)
	message_label.size = Vector2(700,100)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.visible = false
	layer.add_child(message_label)
	message_timer = Timer.new()
	message_timer.one_shot = true
	message_timer.timeout.connect(func() -> void: message_label.visible = false)
	add_child(message_timer)

func show_message(text: String, seconds: float = 4.0) -> void:
	message_label.text = text
	message_label.visible = true
	message_timer.wait_time = seconds
	message_timer.start()

func _read_save() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed as Dictionary if typeof(parsed) == TYPE_DICTIONARY else {}

func _t(en: String, ru: String) -> String:
	return ru if L.get_language() == "ru" else en
