extends Node

const L = preload("res://scripts/localization.gd")
const CUSTOMER = preload("res://scripts/customer.gd")
const SAVE_PATH := "user://save.json"

var game: Node3D
var player: CharacterBody3D
var panel: PanelContainer
var hint: Label
var note_text: Label
var live_text: Label
var archive_text: Label
var result_text: Label
var customer: Node3D
var active := false
var resolved := false
var route := "uncertain_memory"
var threat_level := 0

func _ready() -> void:
	call_deferred("_initialize")

func _initialize() -> void:
	game = get_parent() as Node3D
	player = game.get_node_or_null("Player") as CharacterBody3D
	route = str(game.get("route"))
	threat_level = int(game.get("threat_level"))
	_build_station()
	_build_ui()

func _process(_delta: float) -> void:
	if game == null or resolved:
		return
	var minutes := float(game.get("shift_minutes"))
	if minutes >= 105.0 and not active:
		_start_case()
	if active and player != null:
		var d := Vector2(player.global_position.x - 5.9, player.global_position.z + 3.2).length()
		hint.visible = d < 1.8 and not panel.visible
	else:
		hint.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and active and hint.visible:
		_open_panel()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel") and panel.visible:
		_close_panel()
		get_viewport().set_input_as_handled()

func _start_case() -> void:
	active = true
	customer = CUSTOMER.new()
	game.add_child(customer)
	customer.global_position = Vector3(0, 0, -9.5)
	var n := _t("The Familiar Customer", "Знакомый посетитель")
	customer.setup(n, true, Color(0.17,0.18,0.20), "default")
	await customer.walk_to(Vector3(3.4,0,-2.8), 2.5)
	game.call("show_message", n + ": \"" + _t("You served me yesterday. You wrote it down.", "Ты обслуживал меня вчера. Ты это записал.") + "\"", 5.0)
	var objective = game.get("objective_label")
	if objective is Label:
		objective.text = _t("OBJECTIVE: Compare YOUR NOTE, LIVE CCTV and ARCHIVE at the memory station.", "ЗАДАЧА: Сравни СВОЮ ЗАПИСКУ, LIVE CCTV и АРХИВ на станции памяти.")

func _open_panel() -> void:
	panel.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_update_sources()

func _close_panel() -> void:
	panel.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _update_sources() -> void:
	note_text.text = _t("YOUR NOTE / BEFORE CAMERAS\nBLUE JACKET\nNO PURCHASE\nLEFT AT 02:42", "ТВОЯ ЗАПИСКА / ДО КАМЕР\nСИНЯЯ КУРТКА\nНИЧЕГО НЕ КУПИЛ\nУШЁЛ В 02:42")
	live_text.text = _t("LIVE CCTV\nBLACK JACKET\nCLAIMS: PURCHASED MILK\nFACE MATCH: 98%", "LIVE CCTV\nЧЁРНАЯ КУРТКА\nУТВЕРЖДАЕТ: КУПИЛ МОЛОКО\nСОВПАДЕНИЕ ЛИЦА: 98%")
	archive_text.text = _t("ARCHIVE / YESTERDAY\nBLACK JACKET\nMILK PURCHASE 02:42\nFACE MATCH: 98%", "АРХИВ / ВЧЕРА\nЧЁРНАЯ КУРТКА\nПОКУПКА МОЛОКА 02:42\nСОВПАДЕНИЕ ЛИЦА: 98%")
	if route == "contaminated_memory":
		result_text.text = _t("Two digital systems agree. Your note disagrees. Which source existed BEFORE the cameras changed?", "Две цифровые системы совпадают. Твоя записка противоречит им. Какой источник существовал ДО изменения камер?")
	else:
		result_text.text = _t("The cameras agree with each other, but not with what you wrote before turning them on.", "Камеры совпадают друг с другом, но не с тем, что ты записал до их включения.")

func _choose(source: String) -> void:
	if resolved:
		return
	resolved = true
	var correct := source == "note"
	result_text.text = _t("MEMORY ANCHOR ACCEPTED", "ЯКОРЬ ПАМЯТИ ПРИНЯТ") if correct else _t("DIGITAL RECORD ACCEPTED — YOUR HANDWRITING FADES", "ЦИФРОВАЯ ЗАПИСЬ ПРИНЯТА — ТВОЙ ПОЧЕРК ИСЧЕЗАЕТ")
	_write_result(correct, source)
	await get_tree().create_timer(2.2).timeout
	_close_panel()
	active = false
	if customer != null and is_instance_valid(customer):
		await customer.walk_to(Vector3(0,0,-9.5), 2.0)
		if is_instance_valid(customer): customer.queue_free()
	var objective = game.get("objective_label")
	if objective is Label:
		objective.text = _t("OBJECTIVE: Keep the memory anchor. Survive until 03:17.", "ЗАДАЧА: Сохрани якорь памяти. Продержись до 03:17.")

func _write_result(correct: bool, source: String) -> void:
	var data := _read_save()
	data["night_4_memory_checked"] = true
	data["night_4_memory_correct"] = correct
	data["night_4_trusted_source"] = source
	data["memory_integrity"] = 2 if correct else 0
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null: file.store_string(JSON.stringify(data))

func _read_save() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH): return {}
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null: return {}
	var p := JSON.parse_string(f.get_as_text())
	return p as Dictionary if typeof(p) == TYPE_DICTIONARY else {}

func _build_station() -> void:
	var body := StaticBody3D.new(); body.position = Vector3(5.9,0.75,-3.2); game.add_child(body)
	var mesh_i := MeshInstance3D.new(); var mesh := BoxMesh.new(); mesh.size = Vector3(1.35,1.5,0.55); var mat := StandardMaterial3D.new(); mat.albedo_color = Color(0.07,0.10,0.12); mat.emission_enabled = true; mat.emission = Color(0.03,0.12,0.13); mat.emission_energy_multiplier = 1.4; mesh.material = mat; mesh_i.mesh = mesh; body.add_child(mesh_i)
	var cs := CollisionShape3D.new(); var shape := BoxShape3D.new(); shape.size = mesh.size; cs.shape = shape; body.add_child(cs)

func _build_ui() -> void:
	var layer := CanvasLayer.new(); layer.layer = 40; add_child(layer)
	hint = Label.new(); hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM); hint.position = Vector2(-250,-75); hint.size = Vector2(500,32); hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; hint.text = _t("E — MEMORY VERIFICATION", "E — ПРОВЕРКА ПАМЯТИ"); hint.visible = false; layer.add_child(hint)
	panel = PanelContainer.new(); panel.set_anchors_preset(Control.PRESET_CENTER); panel.position = Vector2(-540,-285); panel.size = Vector2(1080,570); panel.visible = false; layer.add_child(panel)
	var root := VBoxContainer.new(); root.add_theme_constant_override("separation",12); panel.add_child(root)
	var title := Label.new(); title.text = _t("MEMORY ANCHOR — THREE SOURCES", "ЯКОРЬ ПАМЯТИ — ТРИ ИСТОЧНИКА"); title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; title.add_theme_font_size_override("font_size",22); root.add_child(title)
	var row := HBoxContainer.new(); row.add_theme_constant_override("separation",12); root.add_child(row)
	for key in ["note","live","archive"]:
		var box := VBoxContainer.new(); box.custom_minimum_size = Vector2(344,330); row.add_child(box)
		var label := Label.new(); label.custom_minimum_size = Vector2(344,250); label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER; label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; box.add_child(label)
		if key == "note": note_text = label
		elif key == "live": live_text = label
		else: archive_text = label
		var button := Button.new(); button.text = _t("TRUST THIS SOURCE", "ДОВЕРИТЬСЯ ИСТОЧНИКУ"); button.custom_minimum_size.y = 46; button.pressed.connect(_choose.bind(key)); box.add_child(button)
	result_text = Label.new(); result_text.custom_minimum_size = Vector2(1040,70); result_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; result_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; root.add_child(result_text)

func _t(en: String, ru: String) -> String:
	return ru if L.get_language() == "ru" else en
