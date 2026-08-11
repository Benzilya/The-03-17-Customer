extends Node3D

const L = preload("res://scripts/localization.gd")
const SAVE_PATH := "user://save.json"

var clock_label: Label
var objective_label: Label
var message_label: Label
var message_timer: Timer
var shift_minutes: float = 0.0
var shift_speed: float = 14.0
var threat_level: int = 0
var opening_key: String = "clean_shift"
var event_flags: Dictionary = {}

func _ready() -> void:
	add_to_group("game")
	_read_carryover()
	_build_environment()
	_build_store()
	_build_ui()
	_show_opening()

func _process(delta: float) -> void:
	shift_minutes += delta * shift_speed
	var total: int = int(shift_minutes) % 360
	clock_label.text = "%02d:%02d" % [int(total / 60), total % 60]
	_run_events(total)

func _read_carryover() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var data: Dictionary = parsed as Dictionary
	threat_level = int(data.get("threat_level", 0))
	opening_key = str(data.get("night_3_opening", "clean_shift"))

func _show_opening() -> void:
	var text: String
	match opening_key:
		"minor_breach":
			text = _t("NIGHT 3 — One camera was replaced overnight. Nobody signed the work order.", "НОЧЬ 3 — Ночью заменили одну камеру. В журнале работ нет подписи.")
		"active_breach":
			text = _t("NIGHT 3 — Two cameras are already recording before your shift starts.", "НОЧЬ 3 — Две камеры уже ведут запись до начала твоей смены.")
		"critical_breach":
			text = _t("NIGHT 3 — The security system greets you by name.", "НОЧЬ 3 — Система безопасности приветствует тебя по имени.")
		_:
			text = _t("NIGHT 3 — The store is quiet. Too quiet.", "НОЧЬ 3 — В магазине тихо. Слишком тихо.")
	show_message(text, 6.0)
	objective_label.text = _t("OBJECTIVE: Compare live CCTV with the incident archive.", "ЗАДАЧА: Сравни прямой эфир CCTV с архивом происшествий.")

func _run_events(minutes: int) -> void:
	if minutes >= 45 and not event_flags.has("archive_warning"):
		event_flags["archive_warning"] = true
		show_message(_t("ARCHIVE ALERT: Yesterday's entrance footage has changed.", "АРХИВ: Вчерашняя запись со входа изменилась."), 5.0)
	if minutes >= 105 and not event_flags.has("camera_lag"):
		event_flags["camera_lag"] = true
		show_message(_t("CAM 02 is now 11 seconds behind real time.", "КАМ 02 теперь отстаёт от реального времени на 11 секунд."), 5.0)
	if minutes >= 175 and not event_flags.has("name_event"):
		event_flags["name_event"] = true
		show_message(_t("The register prints: WE REMEMBER YOUR LAST DECISION.", "Касса печатает: МЫ ПОМНИМ ТВОЁ ПРОШЛОЕ РЕШЕНИЕ."), 6.0)

func _build_environment() -> void:
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.004, 0.006, 0.009)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.13, 0.16, 0.20)
	env.ambient_light_energy = maxf(0.28, 0.44 - float(threat_level) * 0.03)
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world.environment = env
	add_child(world)

func _build_store() -> void:
	_box(Vector3(18,0.2,14), Vector3(0,-0.1,0), Color(0.13,0.14,0.15))
	_box(Vector3(18,0.2,14), Vector3(0,4.2,0), Color(0.08,0.09,0.10))
	_box(Vector3(18,4.2,0.25), Vector3(0,2.1,7), Color(0.21,0.22,0.23))
	_box(Vector3(0.25,4.2,14), Vector3(-9,2.1,0), Color(0.19,0.20,0.21))
	_box(Vector3(0.25,4.2,14), Vector3(9,2.1,0), Color(0.19,0.20,0.21))
	for z: float in [-1.2,1.2,3.6]:
		_box(Vector3(6,1.8,0.65), Vector3(-1.8,0.9,z), Color(0.25,0.23,0.20))
	for x: float in [-5.5,0.0,5.5]:
		for z: float in [-3.5,1.0,5.0]:
			var light := OmniLight3D.new()
			light.position = Vector3(x,3.7,z)
			light.light_color = Color(0.68,0.76,0.84)
			light.light_energy = maxf(0.75, 1.25 - float(threat_level) * 0.08)
			light.omni_range = 5.2
			add_child(light)

func _box(size: Vector3, pos: Vector3, color: Color) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	add_child(body)
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.8
	mesh.material = mat
	mi.mesh = mesh
	body.add_child(mi)
	var cs := CollisionShape3D.new()
	var sh := BoxShape3D.new()
	sh.size = size
	cs.shape = sh
	body.add_child(cs)

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	clock_label = Label.new()
	clock_label.position = Vector2(28,22)
	clock_label.add_theme_font_size_override("font_size",30)
	layer.add_child(clock_label)
	var title := Label.new()
	title.position = Vector2(28,58)
	title.text = _t("MORROW MARKET — NIGHT 3", "MORROW MARKET — НОЧЬ 3")
	layer.add_child(title)
	objective_label = Label.new()
	objective_label.position = Vector2(28,90)
	objective_label.size = Vector2(940,50)
	objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layer.add_child(objective_label)
	message_label = Label.new()
	message_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	message_label.position = Vector2(-340,-180)
	message_label.size = Vector2(680,100)
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

func _t(en: String, ru: String) -> String:
	return ru if L.get_language() == "ru" else en
