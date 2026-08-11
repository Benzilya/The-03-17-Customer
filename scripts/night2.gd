extends Node3D

const CUSTOMER = preload("res://scripts/customer.gd")
const L = preload("res://scripts/localization.gd")

var clock_label: Label
var objective_label: Label
var message_label: Label
var evidence_panel: PanelContainer
var decision_panel: PanelContainer
var evidence_text: Label
var serve_button: Button
var refuse_button: Button
var message_timer: Timer
var active_customer: Node3D
var shift_minutes: float = 0.0
var shift_speed: float = 13.0
var event_flags: Dictionary = {}
var current_case: Dictionary = {}
var evidence: Array[String] = []
var case_index: int = 0
var correct_decisions: int = 0
var total_decisions: int = 0
var night_locked: bool = false

var cases: Array[Dictionary] = [
	{
		"name_en":"Warehouse Worker", "name_ru":"Работник склада", "line_en":"Energy drink. Nothing else.", "line_ru":"Энергетик. Больше ничего.",
		"anomaly":false, "style":"default", "color":Color(0.24,0.31,0.28),
		"evidence_en":["CAM 03: entrance recorded normally", "Receipt terminal: valid customer timestamp", "Reflection visible in refrigerator glass"],
		"evidence_ru":["КАМ 03: вход зафиксирован нормально", "Касса: корректная метка времени", "Отражение видно в стекле холодильника"]
	},
	{
		"name_en":"Woman in Red", "name_ru":"Женщина в красном", "line_en":"Do you always check the cameras?", "line_ru":"Ты всегда проверяешь камеры?",
		"anomaly":true, "style":"default", "color":Color(0.42,0.08,0.07),
		"evidence_en":["CAM 03: door opened, person count stayed 0", "CAM 01: customer visible, face tracking failed", "Refrigerator reflection: EMPTY"],
		"evidence_ru":["КАМ 03: дверь открылась, счётчик людей остался 0", "КАМ 01: фигура видна, лицо не распознано", "Отражение в холодильнике: ПУСТО"]
	},
	{
		"name_en":"Taxi Driver", "name_ru":"Таксист", "line_en":"Coffee and cigarettes— ah, you don't sell those?", "line_ru":"Кофе и сигареты... а, вы их не продаёте?",
		"anomaly":false, "style":"default", "color":Color(0.19,0.24,0.38),
		"evidence_en":["CAM 03: normal entry", "Parking camera: taxi plate recorded", "Reflection visible"],
		"evidence_ru":["КАМ 03: обычный вход", "Камера парковки: номер такси зафиксирован", "Отражение присутствует"]
	},
	{
		"name_en":"The Repeater", "name_ru":"Повторитель", "line_en":"Long night? Long night? Long night?", "line_ru":"Долгая ночь? Долгая ночь? Долгая ночь?",
		"anomaly":true, "style":"default", "color":Color(0.12,0.12,0.13),
		"evidence_en":["CAM 03: same entrance frame repeated 4 times", "Audio: footsteps continue while customer is standing still", "Register camera timestamp: 03:17:17"],
		"evidence_ru":["КАМ 03: один кадр входа повторился 4 раза", "Аудио: шаги продолжаются, хотя посетитель стоит", "Время камеры кассы: 03:17:17"]
	}
]

func _ready() -> void:
	add_to_group("game")
	_build_environment()
	_build_store()
	_build_ui()
	show_message(_t("NIGHT 2 — 00:00\nThe manager left a new rule: verify suspicious customers.", "НОЧЬ 2 — 00:00\nМенеджер оставил новое правило: проверяй подозрительных посетителей."), 6.0)
	objective_label.text = _t("OBJECTIVE: Wait for the first customer.", "ЗАДАЧА: Дождись первого посетителя.")

func _process(delta: float) -> void:
	if not night_locked:
		shift_minutes += delta * shift_speed
	var total: int = int(shift_minutes) % 360
	clock_label.text = "%02d:%02d" % [int(total / 60), total % 60]
	_run_events(total)

func _run_events(minutes: int) -> void:
	var times: Array[int] = [10, 65, 126, 190]
	if case_index < cases.size() and minutes >= times[case_index] and not event_flags.has("case_%d" % case_index):
		event_flags["case_%d" % case_index] = true
		_start_case(cases[case_index])

func _start_case(data: Dictionary) -> void:
	current_case = data
	evidence.clear()
	if active_customer != null and is_instance_valid(active_customer):
		active_customer.queue_free()
	active_customer = CUSTOMER.new()
	add_child(active_customer)
	active_customer.global_position = Vector3(0,0,-9.5)
	var name: String = _case_text(data,"name")
	active_customer.setup(name, bool(data["anomaly"]), data["color"], str(data["style"]))
	await active_customer.walk_to(Vector3(3.4,0,-2.8),2.4)
	show_message(name + ": \"" + _case_text(data,"line") + "\"",4.0)
	objective_label.text = _t("OBJECTIVE: Inspect evidence before deciding.", "ЗАДАЧА: Проверь улики перед решением.")
	_open_evidence()

func _open_evidence() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	evidence_panel.visible = true
	var source: Array = current_case["evidence_ru"] if L.get_language()=="ru" else current_case["evidence_en"]
	evidence = []
	for item: Variant in source:
		evidence.append(str(item))
	_update_evidence_text()

func _update_evidence_text() -> void:
	var body: String = _t("EVIDENCE TERMINAL\n\n", "ТЕРМИНАЛ УЛИК\n\n")
	for i: int in range(evidence.size()):
		body += "%d. %s\n\n" % [i+1,evidence[i]]
	body += _t("Compare the camera, physical evidence and the customer's behavior.", "Сравни камеры, физические улики и поведение посетителя.")
	evidence_text.text = body

func _show_decision() -> void:
	evidence_panel.visible = false
	decision_panel.visible = true

func _resolve_case(serve: bool) -> void:
	decision_panel.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var anomalous: bool = bool(current_case.get("anomaly",false))
	var correct: bool = (not anomalous and serve) or (anomalous and not serve)
	total_decisions += 1
	if correct:
		correct_decisions += 1
		show_message(_t("Decision logged: consistent with evidence.", "Решение записано: соответствует уликам."),3.0)
	else:
		show_message(_t("Decision logged. Something feels wrong.", "Решение записано. Что-то не так."),3.0)
	if active_customer != null and is_instance_valid(active_customer):
		await active_customer.walk_to(Vector3(0,0,-9.5),1.8)
		if active_customer != null and is_instance_valid(active_customer): active_customer.queue_free()
	case_index += 1
	if case_index >= cases.size():
		_finish_night()
	else:
		objective_label.text = _t("OBJECTIVE: Continue the shift.", "ЗАДАЧА: Продолжай смену.")

func _finish_night() -> void:
	night_locked = true
	var result: String = _t("NIGHT 2 COMPLETE\nCorrect calls: %d / %d", "НОЧЬ 2 ЗАВЕРШЕНА\nВерных решений: %d / %d") % [correct_decisions,total_decisions]
	show_message(result,7.0)
	objective_label.text = _t("The cameras are becoming evidence, not just surveillance.", "Камеры становятся уликами, а не просто наблюдением.")
	var file: FileAccess = FileAccess.open("user://save.json",FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify({"night":3,"night_2_correct":correct_decisions,"night_2_total":total_decisions}))

func _case_text(data: Dictionary,key:String)->String:
	return str(data[key+"_ru"] if L.get_language()=="ru" else data[key+"_en"])

func _t(en:String,ru:String)->String:
	return ru if L.get_language()=="ru" else en

func _build_environment()->void:
	var world:=WorldEnvironment.new(); var env:=Environment.new(); env.background_mode=Environment.BG_COLOR; env.background_color=Color(0.005,0.007,0.011); env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR; env.ambient_light_color=Color(0.16,0.19,0.23); env.ambient_light_energy=0.48; env.tonemap_mode=Environment.TONE_MAPPER_FILMIC; world.environment=env; add_child(world)
	var moon:=DirectionalLight3D.new(); moon.rotation_degrees=Vector3(-55,-25,0); moon.light_color=Color(0.42,0.52,0.72); moon.light_energy=0.22; add_child(moon)

func _build_store()->void:
	_make_box(Vector3(18,.2,14),Vector3(0,-.1,0),Color(.15,.16,.17)); _make_box(Vector3(18,.2,14),Vector3(0,4.2,0),Color(.1,.11,.12)); _make_box(Vector3(18,4.2,.25),Vector3(0,2.1,7),Color(.24,.25,.26)); _make_box(Vector3(.25,4.2,14),Vector3(-9,2.1,0),Color(.22,.23,.24)); _make_box(Vector3(.25,4.2,14),Vector3(9,2.1,0),Color(.22,.23,.24)); _make_box(Vector3(7,4.2,.25),Vector3(-5.5,2.1,-7),Color(.18,.20,.21)); _make_box(Vector3(7,4.2,.25),Vector3(5.5,2.1,-7),Color(.18,.20,.21)); _make_box(Vector3(4,.9,.25),Vector3(0,3.75,-7),Color(.18,.20,.21)); _make_box(Vector3(4.2,1.05,1.25),Vector3(4.6,.525,-3.8),Color(.11,.17,.15))
	for z:float in [-1.2,1.2,3.6]: _make_box(Vector3(6,1.8,.65),Vector3(-1.8,.9,z),Color(.29,.27,.22))
	for x:float in [-5.5,0.0,5.5]:
		for z:float in [-3.5,1.0,5.0]:
			var light:=OmniLight3D.new(); light.position=Vector3(x,3.7,z); light.light_color=Color(.72,.80,.88); light.light_energy=1.45; light.omni_range=5.4; add_child(light)

func _make_box(size:Vector3,pos:Vector3,color:Color)->void:
	var body:=StaticBody3D.new(); body.position=pos; add_child(body); var mesh_i:=MeshInstance3D.new(); var mesh:=BoxMesh.new(); mesh.size=size; var mat:=StandardMaterial3D.new(); mat.albedo_color=color; mat.roughness=.76; mesh.material=mat; mesh_i.mesh=mesh; body.add_child(mesh_i); var cs:=CollisionShape3D.new(); var shape:=BoxShape3D.new(); shape.size=size; cs.shape=shape; body.add_child(cs)

func _build_ui()->void:
	var layer:=CanvasLayer.new(); add_child(layer)
	clock_label=Label.new(); clock_label.position=Vector2(28,22); clock_label.add_theme_font_size_override("font_size",30); layer.add_child(clock_label)
	var title:=Label.new(); title.position=Vector2(28,58); title.text=_t("MORROW MARKET — NIGHT 2","MORROW MARKET — НОЧЬ 2"); title.modulate=Color(.72,.78,.82); layer.add_child(title)
	objective_label=Label.new(); objective_label.position=Vector2(28,90); objective_label.size=Vector2(900,45); objective_label.modulate=Color(.82,.79,.63); layer.add_child(objective_label)
	message_label=Label.new(); message_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM); message_label.position=Vector2(-340,-180); message_label.size=Vector2(680,90); message_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; message_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER; message_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; message_label.visible=false; layer.add_child(message_label)
	message_timer=Timer.new(); message_timer.one_shot=true; message_timer.timeout.connect(func()->void:message_label.visible=false); add_child(message_timer)
	_build_evidence_ui(layer); _build_decision_ui(layer)

func _build_evidence_ui(layer:CanvasLayer)->void:
	evidence_panel=PanelContainer.new(); evidence_panel.set_anchors_preset(Control.PRESET_CENTER); evidence_panel.position=Vector2(-320,-245); evidence_panel.size=Vector2(640,490); evidence_panel.visible=false; layer.add_child(evidence_panel)
	var box:=VBoxContainer.new(); box.add_theme_constant_override("separation",14); evidence_panel.add_child(box); evidence_text=Label.new(); evidence_text.custom_minimum_size=Vector2(590,380); evidence_text.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; evidence_text.add_theme_font_size_override("font_size",18); box.add_child(evidence_text); var decide:=Button.new(); decide.text=_t("MAKE DECISION","ПРИНЯТЬ РЕШЕНИЕ"); decide.custom_minimum_size.y=46; decide.pressed.connect(_show_decision); box.add_child(decide)

func _build_decision_ui(layer:CanvasLayer)->void:
	decision_panel=PanelContainer.new(); decision_panel.set_anchors_preset(Control.PRESET_CENTER); decision_panel.position=Vector2(-270,-125); decision_panel.size=Vector2(540,250); decision_panel.visible=false; layer.add_child(decision_panel); var box:=VBoxContainer.new(); box.add_theme_constant_override("separation",12); decision_panel.add_child(box); var label:=Label.new(); label.text=_t("Based on the evidence, what do you do?","Что делать, исходя из улик?"); label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; label.custom_minimum_size.y=80; label.add_theme_font_size_override("font_size",20); box.add_child(label); serve_button=Button.new(); serve_button.text=_t("SERVE","ОБСЛУЖИТЬ"); serve_button.pressed.connect(func()->void:_resolve_case(true)); box.add_child(serve_button); refuse_button=Button.new(); refuse_button.text=_t("REFUSE SERVICE","ОТКАЗАТЬ В ОБСЛУЖИВАНИИ"); refuse_button.pressed.connect(func()->void:_resolve_case(false)); box.add_child(refuse_button)

func show_message(text:String,seconds:float)->void:
	message_label.text=text; message_label.visible=true; message_timer.wait_time=seconds; message_timer.start()
