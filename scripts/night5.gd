extends Node3D

const L = preload("res://scripts/localization.gd")
const SAVE_PATH := "user://save.json"

var clock_label: Label
var objective_label: Label
var message_label: Label
var message_timer: Timer
var shift_minutes: float = 0.0
var shift_speed: float = 15.0
var route: String = "uncertain_identity"
var threat_level: int = 0

func _ready() -> void:
	add_to_group("game")
	_read_progress()
	_build_environment()
	_build_store()
	_build_ui()
	_show_opening()

func _process(delta: float) -> void:
	shift_minutes += delta * shift_speed
	var total: int = int(shift_minutes) % 360
	clock_label.text = "%02d:%02d" % [int(total / 60), total % 60]

func _read_progress() -> void:
	var data: Dictionary = _read_save()
	route = str(data.get("night_5_route", "uncertain_identity"))
	threat_level = int(data.get("threat_level", 0))

func _show_opening() -> void:
	var text: String
	match route:
		"anchored_identity":
			text = _t("NIGHT 5 — Your handwritten note is still in your pocket. Every camera says it never existed.", "НОЧЬ 5 — Твоя рукописная записка всё ещё в кармане. Все камеры утверждают, что её никогда не существовало.")
		"fractured_identity":
			text = _t("NIGHT 5 — Your employee badge displays a photograph of someone else.", "НОЧЬ 5 — На твоём рабочем бейдже фотография другого человека.")
		_:
			text = _t("NIGHT 5 — The time clock accepts your fingerprint, but the employee database cannot find your name.", "НОЧЬ 5 — Терминал принимает твой отпечаток, но база сотрудников не находит твоего имени.")
	show_message(text, 7.0)
	objective_label.text = _t("OBJECTIVE: Determine which records still belong to you.", "ЗАДАЧА: Определи, какие записи всё ещё принадлежат тебе.")

func _build_environment() -> void:
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.002,0.004,0.007)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.10,0.12,0.16)
	env.ambient_light_energy = maxf(0.22,0.36-float(threat_level)*0.025)
	world.environment = env
	add_child(world)

func _build_store() -> void:
	_box(Vector3(18,0.2,14),Vector3(0,-0.1,0),Color(0.10,0.11,0.12))
	_box(Vector3(18,0.2,14),Vector3(0,4.2,0),Color(0.06,0.07,0.08))
	_box(Vector3(18,4.2,0.25),Vector3(0,2.1,7),Color(0.17,0.18,0.19))
	_box(Vector3(0.25,4.2,14),Vector3(-9,2.1,0),Color(0.15,0.16,0.17))
	_box(Vector3(0.25,4.2,14),Vector3(9,2.1,0),Color(0.15,0.16,0.17))
	for z: float in [-1.2,1.2,3.6]:
		_box(Vector3(6,1.8,0.65),Vector3(-1.8,0.9,z),Color(0.21,0.19,0.18))
	for x: float in [-5.5,0.0,5.5]:
		for z: float in [-3.5,1.0,5.0]:
			var light := OmniLight3D.new()
			light.position = Vector3(x,3.7,z)
			light.light_color = Color(0.58,0.68,0.80)
			light.light_energy = maxf(0.62,1.0-float(threat_level)*0.06)
			light.omni_range = 5.0
			add_child(light)

func _box(size: Vector3,pos: Vector3,color: Color) -> void:
	var body := StaticBody3D.new(); body.position=pos; add_child(body)
	var mi := MeshInstance3D.new(); var mesh := BoxMesh.new(); mesh.size=size
	var mat := StandardMaterial3D.new(); mat.albedo_color=color; mat.roughness=0.84; mesh.material=mat; mi.mesh=mesh; body.add_child(mi)
	var cs := CollisionShape3D.new(); var sh := BoxShape3D.new(); sh.size=size; cs.shape=sh; body.add_child(cs)

func _build_ui() -> void:
	var layer := CanvasLayer.new(); add_child(layer)
	clock_label = Label.new(); clock_label.position=Vector2(28,22); clock_label.add_theme_font_size_override("font_size",30); layer.add_child(clock_label)
	var title := Label.new(); title.position=Vector2(28,58); title.text=_t("MORROW MARKET — NIGHT 5","MORROW MARKET — НОЧЬ 5"); layer.add_child(title)
	objective_label = Label.new(); objective_label.position=Vector2(28,90); objective_label.size=Vector2(950,55); objective_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; layer.add_child(objective_label)
	message_label = Label.new(); message_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM); message_label.position=Vector2(-360,-185); message_label.size=Vector2(720,105); message_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; message_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER; message_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; message_label.visible=false; layer.add_child(message_label)
	message_timer=Timer.new(); message_timer.one_shot=true; message_timer.timeout.connect(func()->void: message_label.visible=false); add_child(message_timer)

func show_message(text: String, seconds: float = 4.0) -> void:
	message_label.text=text; message_label.visible=true; message_timer.wait_time=seconds; message_timer.start()

func _read_save() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH): return {}
	var f := FileAccess.open(SAVE_PATH,FileAccess.READ)
	if f == null: return {}
	var p := JSON.parse_string(f.get_as_text())
	return p as Dictionary if typeof(p)==TYPE_DICTIONARY else {}

func _t(en:String,ru:String)->String:
	return ru if L.get_language()=="ru" else en
