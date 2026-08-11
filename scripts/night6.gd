extends Node3D

const L = preload("res://scripts/localization.gd")
const SAVE_PATH := "user://save.json"

var clock_label: Label
var objective_label: Label
var message_label: Label
var message_timer: Timer
var shift_minutes := 0.0
var shift_speed := 15.5
var route := "lost_identity"
var ending_route := "ending_unknown"

func _ready() -> void:
	add_to_group("game")
	_read_progress()
	_build_environment()
	_build_store()
	_build_ui()
	_show_opening()

func _process(delta: float) -> void:
	shift_minutes += delta * shift_speed
	var total := int(shift_minutes) % 360
	clock_label.text = "%02d:%02d" % [int(total/60), total%60]

func _read_progress() -> void:
	var data := _read_save()
	route = str(data.get("night_6_route", "lost_identity"))
	ending_route = _derive_ending(data)

func _derive_ending(data: Dictionary) -> String:
	var memory_ok := bool(data.get("night_4_memory_correct", false))
	var identity_ok := bool(data.get("night_5_identity_correct", false))
	var paper_choice := str(data.get("night_5_0317_choice", "system")) == "paper"
	var threat := int(data.get("threat_level", 0))
	if memory_ok and identity_ok and paper_choice and threat <= 1:
		return "ending_escape"
	if memory_ok and identity_ok and paper_choice:
		return "ending_witness"
	if identity_ok and not paper_choice:
		return "ending_merge"
	return "ending_replaced"

func _show_opening() -> void:
	var text := ""
	match route:
		"anchored_self": text = _t("NIGHT 6 — Your name survives only on paper. The store has stopped recognizing you.","НОЧЬ 6 — Твоё имя осталось только на бумаге. Магазин больше тебя не узнаёт.")
		"voluntary_merge": text = _t("NIGHT 6 — Every camera recognizes you instantly. None of them show your reflection.","НОЧЬ 6 — Все камеры мгновенно узнают тебя. Ни одна не показывает твоё отражение.")
		"damaged_resistance": text = _t("NIGHT 6 — Your note is torn, but one line remains readable: DO NOT ANSWER AT 03:17.","НОЧЬ 6 — Записка порвана, но одна строка читается: НЕ ОТВЕЧАЙ В 03:17.")
		_: text = _t("NIGHT 6 — The employee database welcomes you under a name you have never seen.","НОЧЬ 6 — База сотрудников приветствует тебя именем, которого ты никогда не видел.")
	show_message(text, 7.0)
	objective_label.text = _t("OBJECTIVE: Reach 03:17 and decide what leaves the store.","ЗАДАЧА: Доживи до 03:17 и реши, что покинет магазин.")

func _build_environment() -> void:
	var world:=WorldEnvironment.new();var env:=Environment.new();env.background_mode=Environment.BG_COLOR;env.background_color=Color(.001,.002,.004);env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;env.ambient_light_color=Color(.08,.09,.12);env.ambient_light_energy=.25;world.environment=env;add_child(world)
func _build_store() -> void:
	_box(Vector3(18,.2,14),Vector3(0,-.1,0),Color(.08,.09,.10));_box(Vector3(18,.2,14),Vector3(0,4.2,0),Color(.04,.05,.06));_box(Vector3(18,4.2,.25),Vector3(0,2.1,7),Color(.14,.15,.16));_box(Vector3(.25,4.2,14),Vector3(-9,2.1,0),Color(.12,.13,.14));_box(Vector3(.25,4.2,14),Vector3(9,2.1,0),Color(.12,.13,.14))
	for z:float in [-1.2,1.2,3.6]:_box(Vector3(6,1.8,.65),Vector3(-1.8,.9,z),Color(.17,.16,.15))
func _box(size:Vector3,pos:Vector3,color:Color)->void:
	var body:=StaticBody3D.new();body.position=pos;add_child(body);var mi:=MeshInstance3D.new();var mesh:=BoxMesh.new();mesh.size=size;var mat:=StandardMaterial3D.new();mat.albedo_color=color;mesh.material=mat;mi.mesh=mesh;body.add_child(mi);var cs:=CollisionShape3D.new();var sh:=BoxShape3D.new();sh.size=size;cs.shape=sh;body.add_child(cs)
func _build_ui()->void:
	var layer:=CanvasLayer.new();add_child(layer);clock_label=Label.new();clock_label.position=Vector2(28,22);clock_label.add_theme_font_size_override("font_size",30);layer.add_child(clock_label);var title:=Label.new();title.position=Vector2(28,58);title.text=_t("MORROW MARKET — NIGHT 6","MORROW MARKET — НОЧЬ 6");layer.add_child(title);objective_label=Label.new();objective_label.position=Vector2(28,90);objective_label.size=Vector2(980,55);layer.add_child(objective_label);message_label=Label.new();message_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM);message_label.position=Vector2(-370,-190);message_label.size=Vector2(740,110);message_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;message_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;message_label.visible=false;layer.add_child(message_label);message_timer=Timer.new();message_timer.one_shot=true;message_timer.timeout.connect(func()->void:message_label.visible=false);add_child(message_timer)
func show_message(text:String,seconds:float=4)->void:message_label.text=text;message_label.visible=true;message_timer.wait_time=seconds;message_timer.start()
func _read_save()->Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):return {}
	var f:=FileAccess.open(SAVE_PATH,FileAccess.READ);if f==null:return {};var p:=JSON.parse_string(f.get_as_text());return p as Dictionary if typeof(p)==TYPE_DICTIONARY else {}
func _t(en:String,ru:String)->String:return ru if L.get_language()=="ru" else en
