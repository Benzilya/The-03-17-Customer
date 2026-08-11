extends Node

const CUSTOMER = preload("res://scripts/customer.gd")
const L = preload("res://scripts/localization.gd")
const SAVE_PATH := "user://save.json"

var game: Node3D
var player: CharacterBody3D
var customer: Node3D
var archive_system: Node
var hint: Label
var panel: PanelContainer
var evidence_label: Label
var serve_button: Button
var refuse_button: Button

var started: bool = false
var active: bool = false
var physical_checked: bool = false
var resolved: bool = false
var threat_level: int = 0

const RECEIPT_POSITION := Vector3(4.0, 1.18, -3.42)

func _ready() -> void:
	call_deferred("_initialize")

func _initialize() -> void:
	game = get_parent() as Node3D
	player = game.get_node_or_null("Player") as CharacterBody3D
	archive_system = game.get_node_or_null("ArchiveSystem")
	var threat_value: Variant = game.get("threat_level")
	threat_level = int(threat_value) if typeof(threat_value) == TYPE_INT else 0
	_build_receipt_prop()
	_build_ui()
	set_process(true)
	set_process_input(true)

func _process(_delta: float) -> void:
	if game == null:
		return
	var minutes_value: Variant = game.get("shift_minutes")
	var minutes: float = float(minutes_value) if typeof(minutes_value) in [TYPE_FLOAT, TYPE_INT] else 0.0
	var archive_done: bool = true
	if archive_system != null:
		var value: Variant = archive_system.get("case_resolved")
		archive_done = bool(value) if typeof(value) == TYPE_BOOL else false
	if minutes >= 145.0 and archive_done and not started:
		started = true
		_start_case()
	if active and player != null and is_instance_valid(player):
		var distance: float = Vector2(player.global_position.x - RECEIPT_POSITION.x, player.global_position.z - RECEIPT_POSITION.z).length()
		hint.visible = distance < 1.65 and not panel.visible
	else:
		hint.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and active and hint.visible:
		_check_physical_evidence()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel") and panel.visible:
		_close_panel()
		get_viewport().set_input_as_handled()

func _start_case() -> void:
	customer = CUSTOMER.new()
	game.add_child(customer)
	customer.global_position = Vector3(0.0, 0.0, -9.5)
	var customer_name: String = _t("Milk Delivery Man", "Развозчик молока")
	customer.setup(customer_name, true, Color(0.30, 0.33, 0.31), "default")
	await customer.walk_to(Vector3(3.4, 0.0, -2.8), 2.5)
	active = true
	if game.has_method("show_message"):
		game.call("show_message", customer_name + ": \"" + _t("Your cameras will say I arrived at 01:42. They always do.", "Твои камеры скажут, что я пришёл в 01:42. Они всегда так говорят.") + "\"", 5.5)
	_set_objective(_t(
		"OBJECTIVE: Both CCTV records agree. Find a physical record that the cameras cannot rewrite.",
		"ЗАДАЧА: Обе записи CCTV совпадают. Найди физическую запись, которую камеры не могут переписать."
	))

func _check_physical_evidence() -> void:
	physical_checked = true
	panel.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var clock_time: String = "02:25"
	var printed_time: String = "01:42"
	var body: String = _t(
		"PHYSICAL RECEIPT / PAPER COPY\n\nPrinted delivery time: %s\nCurrent wall clock: %s\nInk status: DRY / OLD\nRegister memory: NO SALE AT 01:42\n\nBoth CCTV feeds show an arrival at 01:42, but the physical register has no matching transaction.\nThe paper existed before the customer entered the store.",
		"ФИЗИЧЕСКИЙ ЧЕК / БУМАЖНАЯ КОПИЯ\n\nВремя доставки на бумаге: %s\nТекущее время: %s\nЧернила: СУХИЕ / СТАРЫЕ\nПамять кассы: ПРОДАЖИ В 01:42 НЕТ\n\nОбе камеры показывают вход в 01:42, но в физическом журнале кассы такой операции нет.\nБумага существовала ещё до того, как посетитель вошёл в магазин."
	) % [printed_time, clock_time]
	if threat_level >= 3:
		body += _t("\n\nThe receipt has your employee number printed on the back.", "\n\nНа обратной стороне чека напечатан твой табельный номер.")
	evidence_label.text = body
	serve_button.disabled = false
	refuse_button.disabled = false

func _resolve(serve: bool) -> void:
	if resolved or not physical_checked:
		return
	resolved = true
	panel.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var correct: bool = not serve
	if correct:
		if game.has_method("show_message"):
			game.call("show_message", _t("You refuse service. The customer smiles before you finish speaking.", "Ты отказываешь в обслуживании. Посетитель улыбается ещё до того, как ты заканчиваешь фразу."), 5.0)
	else:
		if game.has_method("show_message"):
			game.call("show_message", _t("You accept the camera record. The paper receipt turns blank.", "Ты доверяешь записи камеры. Бумажный чек становится чистым."), 5.0)
	await get_tree().create_timer(1.2).timeout
	if customer != null and is_instance_valid(customer):
		await customer.walk_to(Vector3(0.0, 0.0, -9.5), 2.0)
		if is_instance_valid(customer):
			customer.queue_free()
	active = false
	_set_objective(_t("OBJECTIVE: Cameras can agree and still be wrong.", "ЗАДАЧА: Камеры могут совпадать и всё равно лгать."))
	_write_result(correct)

func _write_result(correct: bool) -> void:
	var data: Dictionary = _read_save()
	data["night_3_physical_checked"] = true
	data["night_3_physical_correct"] = correct
	var archive_correct: bool = bool(data.get("night_3_archive_correct", false))
	data["night_3_correct_total"] = int(archive_correct) + int(correct)
	data["night_3_ready_for_finale"] = true
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))

func _read_save() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed as Dictionary if typeof(parsed) == TYPE_DICTIONARY else {}

func _set_objective(text: String) -> void:
	var objective_value: Variant = game.get("objective_label")
	if typeof(objective_value) == TYPE_OBJECT and objective_value is Label:
		(objective_value as Label).text = text

func _build_receipt_prop() -> void:
	var root: Node3D = Node3D.new()
	root.name = "PhysicalReceiptEvidence"
	root.position = RECEIPT_POSITION
	game.add_child(root)
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = Vector3(0.40, 0.018, 0.62)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.72, 0.67, 0.50)
	material.roughness = 0.94
	mesh.material = material
	mesh_instance.mesh = mesh
	root.add_child(mesh_instance)
	var light: OmniLight3D = OmniLight3D.new()
	light.position = Vector3(0.0, 0.18, 0.0)
	light.light_color = Color(0.82, 0.70, 0.44)
	light.light_energy = 0.10
	light.omni_range = 1.4
	root.add_child(light)

func _build_ui() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 36
	add_child(layer)
	hint = Label.new()
	hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	hint.position = Vector2(-230, -75)
	hint.size = Vector2(460, 32)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.text = _t("E — INSPECT PAPER RECEIPT", "E — ПРОВЕРИТЬ БУМАЖНЫЙ ЧЕК")
	hint.visible = false
	layer.add_child(hint)
	panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-360, -260)
	panel.size = Vector2(720, 520)
	panel.visible = false
	layer.add_child(panel)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)
	var heading: Label = Label.new()
	heading.text = _t("PHYSICAL RECORD CHECK", "ПРОВЕРКА ФИЗИЧЕСКОЙ ЗАПИСИ")
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 22)
	box.add_child(heading)
	evidence_label = Label.new()
	evidence_label.custom_minimum_size = Vector2(670, 340)
	evidence_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	evidence_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	evidence_label.add_theme_font_size_override("font_size", 17)
	box.add_child(evidence_label)
	serve_button = Button.new()
	serve_button.text = _t("TRUST CCTV — SERVE", "ДОВЕРИТЬСЯ CCTV — ОБСЛУЖИТЬ")
	serve_button.disabled = true
	serve_button.pressed.connect(func() -> void: _resolve(true))
	box.add_child(serve_button)
	refuse_button = Button.new()
	refuse_button.text = _t("TRUST PHYSICAL RECORD — REFUSE", "ДОВЕРИТЬСЯ БУМАГЕ — ОТКАЗАТЬ")
	refuse_button.disabled = true
	refuse_button.pressed.connect(func() -> void: _resolve(false))
	box.add_child(refuse_button)

func _close_panel() -> void:
	panel.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _t(en: String, ru: String) -> String:
	return ru if L.get_language() == "ru" else en
