extends Node

const L = preload("res://scripts/localization.gd")

var game: Node3D
var player: CharacterBody3D
var hint: Label
var cctv_overlay: PanelContainer
var cctv_text: Label
var current_station: int = -1
var station_nodes: Array[Node3D] = []
var last_case_index: int = -1

const STATION_POSITIONS := [
	Vector3(6.75, 1.35, -3.55),
	Vector3(4.55, 1.15, -3.25),
	Vector3(-5.5, 1.25, 5.85)
]

func _ready() -> void:
	call_deferred("_initialize")

func _initialize() -> void:
	game = get_parent() as Node3D
	player = game.get_node_or_null("Player") as CharacterBody3D
	_build_stations()
	_build_ui()
	set_process(true)
	set_process_input(true)

func _process(_delta: float) -> void:
	if game == null or player == null or not is_instance_valid(player):
		return
	var case_value: Variant = game.get("case_index")
	var case_index: int = int(case_value) if typeof(case_value) == TYPE_INT else -1
	if case_index != last_case_index:
		last_case_index = case_index
		cctv_overlay.visible = false
	current_station = _nearest_station()
	if current_station >= 0 and _case_active():
		hint.visible = true
		hint.text = _station_hint(current_station)
	else:
		hint.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and current_station >= 0 and _case_active():
		inspect_station(current_station)
	if event.is_action_pressed("ui_cancel") and cctv_overlay.visible:
		cctv_overlay.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_viewport().set_input_as_handled()

func inspect_station(index: int) -> void:
	if game == null:
		return
	if game.has_method("_inspect_source"):
		game.call("_inspect_source", index)
	if index == 0:
		_show_cctv_check()
	elif index == 1:
		_show_world_message(
			"REGISTER LOG CHECKED. Compare its time with the wall clock.",
			"ЖУРНАЛ КАССЫ ПРОВЕРЕН. Сравни время с настенными часами."
		)
	else:
		_show_world_message(
			"REFLECTION CHECKED. Watch whether the customer appears in the glass.",
			"ОТРАЖЕНИЕ ПРОВЕРЕНО. Посмотри, появляется ли посетитель в стекле."
		)

func _nearest_station() -> int:
	var best_index: int = -1
	var best_distance: float = 1.75
	for i: int in range(STATION_POSITIONS.size()):
		var p: Vector3 = STATION_POSITIONS[i]
		var d: float = Vector2(player.global_position.x - p.x, player.global_position.z - p.z).length()
		if d < best_distance:
			best_distance = d
			best_index = i
	return best_index

func _case_active() -> bool:
	var current_case: Variant = game.get("current_case")
	return typeof(current_case) == TYPE_DICTIONARY and not (current_case as Dictionary).is_empty()

func _station_hint(index: int) -> String:
	if L.get_language() == "ru":
		return ["E — ПРОВЕРИТЬ CCTV", "E — ПРОВЕРИТЬ КАССУ", "E — ПРОВЕРИТЬ ОТРАЖЕНИЕ"][index]
	return ["E — CHECK CCTV", "E — CHECK REGISTER", "E — CHECK REFLECTION"][index]

func _show_cctv_check() -> void:
	var data_value: Variant = game.get("current_case")
	if typeof(data_value) != TYPE_DICTIONARY:
		return
	var data: Dictionary = data_value as Dictionary
	var anomaly: bool = bool(data.get("anomaly", false))
	var name_key: String = "name_ru" if L.get_language() == "ru" else "name_en"
	var customer_name: String = str(data.get(name_key, "UNKNOWN"))
	if L.get_language() == "ru":
		if anomaly:
			cctv_text.text = "КАМ 03 / ВХОД\n\nДВЕРЬ: ОТКРЫТА\nСЧЁТЧИК ЛЮДЕЙ: 0\nСУБЪЕКТ: НЕ ОБНАРУЖЕН\n\nПеред кассой стоит: %s\n\nПРОТИВОРЕЧИЕ ЗАФИКСИРОВАНО" % customer_name
		else:
			cctv_text.text = "КАМ 03 / ВХОД\n\nДВЕРЬ: ОТКРЫТА\nСЧЁТЧИК ЛЮДЕЙ: 1\nСУБЪЕКТ: ОБНАРУЖЕН\n\n%s зарегистрирован нормально." % customer_name
	else:
		if anomaly:
			cctv_text.text = "CAM 03 / ENTRANCE\n\nDOOR: OPEN\nPERSON COUNT: 0\nSUBJECT: NOT DETECTED\n\nStanding at register: %s\n\nCONTRADICTION LOGGED" % customer_name
		else:
			cctv_text.text = "CAM 03 / ENTRANCE\n\nDOOR: OPEN\nPERSON COUNT: 1\nSUBJECT: DETECTED\n\n%s recorded normally." % customer_name
	cctv_overlay.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _show_world_message(en: String, ru: String) -> void:
	if game.has_method("show_message"):
		game.call("show_message", ru if L.get_language() == "ru" else en, 3.0)

func _build_stations() -> void:
	station_nodes.append(_station("EvidenceCCTV", STATION_POSITIONS[0], Color(0.035, 0.08, 0.07), Vector3(1.1, 0.72, 0.45)))
	station_nodes.append(_station("EvidenceRegister", STATION_POSITIONS[1], Color(0.11, 0.11, 0.10), Vector3(0.72, 0.10, 0.50)))
	station_nodes.append(_station("EvidenceReflection", STATION_POSITIONS[2], Color(0.15, 0.22, 0.24), Vector3(1.55, 2.6, 0.08)))

func _station(node_name: String, pos: Vector3, color: Color, size: Vector3) -> Node3D:
	var root := Node3D.new()
	root.name = node_name
	root.position = pos
	game.add_child(root)
	var mesh_i := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.38
	if node_name == "EvidenceReflection":
		mat.metallic = 0.55
	mesh.material = mat
	mesh_i.mesh = mesh
	root.add_child(mesh_i)
	var light := OmniLight3D.new()
	light.position = Vector3(0, 0.15, -0.25)
	light.light_color = Color(0.38, 0.72, 0.62)
	light.light_energy = 0.18 if node_name != "EvidenceReflection" else 0.08
	light.omni_range = 2.2
	root.add_child(light)
	return root

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 40
	add_child(layer)
	hint = Label.new()
	hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	hint.position = Vector2(-180, -78)
	hint.size = Vector2(360, 34)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 16)
	hint.visible = false
	layer.add_child(hint)

	cctv_overlay = PanelContainer.new()
	cctv_overlay.set_anchors_preset(Control.PRESET_CENTER)
	cctv_overlay.position = Vector2(-330, -220)
	cctv_overlay.size = Vector2(660, 440)
	cctv_overlay.visible = false
	layer.add_child(cctv_overlay)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	cctv_overlay.add_child(box)
	cctv_text = Label.new()
	cctv_text.custom_minimum_size = Vector2(610, 335)
	cctv_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cctv_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cctv_text.add_theme_font_size_override("font_size", 20)
	cctv_text.modulate = Color(0.50, 0.90, 0.65)
	box.add_child(cctv_text)
	var close := Button.new()
	close.text = "ЗАКРЫТЬ / CLOSE"
	close.custom_minimum_size.y = 44
	close.pressed.connect(func() -> void:
		cctv_overlay.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	)
	box.add_child(close)
