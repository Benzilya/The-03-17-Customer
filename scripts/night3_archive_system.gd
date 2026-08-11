extends Node

const CUSTOMER = preload("res://scripts/customer.gd")
const L = preload("res://scripts/localization.gd")

var game: Node3D
var player: CharacterBody3D
var panel: PanelContainer
var live_text: Label
var archive_text: Label
var result_label: Label
var choose_live: Button
var choose_archive: Button
var hint: Label
var active_case: bool = false
var case_started: bool = false
var case_resolved: bool = false
var customer: Node3D
var threat_level: int = 0
var correct_choices: int = 0
var total_choices: int = 0

func _ready() -> void:
	call_deferred("_initialize")

func _initialize() -> void:
	game = get_parent() as Node3D
	player = game.get_node_or_null("Player") as CharacterBody3D
	var threat_value: Variant = game.get("threat_level")
	threat_level = int(threat_value) if typeof(threat_value) == TYPE_INT else 0
	_build_ui()
	set_process(true)
	set_process_input(true)

func _process(_delta: float) -> void:
	if game == null:
		return
	var minutes_value: Variant = game.get("shift_minutes")
	var minutes: float = float(minutes_value) if typeof(minutes_value) in [TYPE_FLOAT, TYPE_INT] else 0.0
	if minutes >= 72.0 and not case_started:
		case_started = true
		_start_case()
	if active_case and player != null and is_instance_valid(player):
		var distance: float = Vector2(player.global_position.x - 6.65, player.global_position.z + 3.55).length()
		hint.visible = distance < 1.9 and not panel.visible
	else:
		hint.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and active_case and hint.visible:
		_open_console()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel") and panel.visible:
		_close_console()
		get_viewport().set_input_as_handled()

func _start_case() -> void:
	customer = CUSTOMER.new()
	game.add_child(customer)
	customer.global_position = Vector3(0.0, 0.0, -9.5)
	var customer_name: String = _t("Archive Clerk", "Архивист")
	customer.setup(customer_name, false, Color(0.22, 0.20, 0.18), "default")
	await customer.walk_to(Vector3(3.4, 0.0, -2.8), 2.6)
	active_case = true
	if game.has_method("show_message"):
		game.call("show_message", customer_name + ": \"" + _t("I was here yesterday. Check your records.", "Я был здесь вчера. Проверь свои записи.") + "\"", 5.0)
	var objective: Variant = game.get("objective_label")
	if typeof(objective) == TYPE_OBJECT and objective is Label:
		(objective as Label).text = _t("OBJECTIVE: Compare LIVE CCTV with the ARCHIVE before deciding which record is real.", "ЗАДАЧА: Сравни LIVE CCTV с АРХИВОМ и реши, какая запись настоящая.")

func _open_console() -> void:
	panel.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_update_console()

func _close_console() -> void:
	panel.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _update_console() -> void:
	var live: String = ""
	var archive: String = ""
	if threat_level <= 0:
		live = _t("LIVE / CAM 01\n02:11:08\nSUBJECT: ARCHIVE CLERK\nPERSON COUNT: 1\nMOVEMENT: NORMAL", "LIVE / КАМ 01\n02:11:08\nСУБЪЕКТ: АРХИВИСТ\nЛЮДЕЙ: 1\nДВИЖЕНИЕ: НОРМА")
		archive = _t("ARCHIVE / YESTERDAY\n02:11:08\nNO ENTRY RECORDED\nREGISTER: CLOSED", "АРХИВ / ВЧЕРА\n02:11:08\nВХОД НЕ ЗАФИКСИРОВАН\nКАССА: ЗАКРЫТА")
	elif threat_level <= 2:
		live = _t("LIVE / CAM 01\n02:11:08\nSUBJECT: ARCHIVE CLERK\nPERSON COUNT: 1\nFRAME DELAY: 11 SEC", "LIVE / КАМ 01\n02:11:08\nСУБЪЕКТ: АРХИВИСТ\nЛЮДЕЙ: 1\nЗАДЕРЖКА: 11 СЕК")
		archive = _t("ARCHIVE / YESTERDAY\n02:11:08\nSUBJECT: ARCHIVE CLERK\nPERSON COUNT: 1\nNOTE: FILE MODIFIED 03:17", "АРХИВ / ВЧЕРА\n02:11:08\nСУБЪЕКТ: АРХИВИСТ\nЛЮДЕЙ: 1\nПРИМЕЧАНИЕ: ФАЙЛ ИЗМЕНЁН В 03:17")
	else:
		live = _t("LIVE / CAM 01\n02:11:08\nSUBJECT: ARCHIVE CLERK\nPERSON COUNT: 1\nCHECKSUM: INVALID", "LIVE / КАМ 01\n02:11:08\nСУБЪЕКТ: АРХИВИСТ\nЛЮДЕЙ: 1\nКОНТРОЛЬНАЯ СУММА: ОШИБКА")
		archive = _t("ARCHIVE / YESTERDAY\n02:11:08\nSUBJECT: ARCHIVE CLERK\nPERSON COUNT: 1\nCHECKSUM: VALID\nRECORDED BEFORE SHIFT", "АРХИВ / ВЧЕРА\n02:11:08\nСУБЪЕКТ: АРХИВИСТ\nЛЮДЕЙ: 1\nКОНТРОЛЬНАЯ СУММА: ВЕРНА\nЗАПИСАНО ДО СМЕНЫ")
	live_text.text = live
	archive_text.text = archive
	result_label.text = _t("One source has been altered. Which record do you trust?", "Один источник был изменён. Какой записи ты доверяешь?")

func _choose(use_live: bool) -> void:
	if case_resolved:
		return
	case_resolved = true
	total_choices += 1
	# Clean/minor threat: live feed is trustworthy. High threat: archive is the only valid checksum.
	var correct: bool = use_live if threat_level <= 2 else not use_live
	if correct:
		correct_choices += 1
		result_label.text = _t("CONSISTENT RECORD SELECTED", "ВЫБРАНА СОГЛАСОВАННАЯ ЗАПИСЬ")
	else:
		result_label.text = _t("RECORD ACCEPTED — BUT THE OTHER FEED JUST CHANGED", "ЗАПИСЬ ПРИНЯТА — НО ДРУГОЙ ИСТОЧНИК ТОЛЬКО ЧТО ИЗМЕНИЛСЯ")
	choose_live.disabled = true
	choose_archive.disabled = true
	await get_tree().create_timer(2.0).timeout
	_close_console()
	active_case = false
	if customer != null and is_instance_valid(customer):
		await customer.walk_to(Vector3(0.0, 0.0, -9.5), 2.0)
		if is_instance_valid(customer):
			customer.queue_free()
	var objective: Variant = game.get("objective_label")
	if typeof(objective) == TYPE_OBJECT and objective is Label:
		(objective as Label).text = _t("OBJECTIVE: The archive can lie. Watch for another contradiction.", "ЗАДАЧА: Архив может лгать. Жди следующего противоречия.")
	_write_partial_result(correct)

func _write_partial_result(correct: bool) -> void:
	const SAVE_PATH := "user://save.json"
	var data: Dictionary = {}
	if FileAccess.file_exists(SAVE_PATH):
		var file_read: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file_read != null:
			var parsed: Variant = JSON.parse_string(file_read.get_as_text())
			if typeof(parsed) == TYPE_DICTIONARY:
				data = parsed as Dictionary
	data["night_3_archive_checked"] = true
	data["night_3_archive_correct"] = correct
	data["night_3_archive_choices"] = total_choices
	var file_write: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file_write != null:
		file_write.store_string(JSON.stringify(data))

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 35
	add_child(layer)
	hint = Label.new()
	hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	hint.position = Vector2(-220, -75)
	hint.size = Vector2(440, 32)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.text = _t("E — COMPARE LIVE / ARCHIVE", "E — СРАВНИТЬ LIVE / АРХИВ")
	hint.visible = false
	layer.add_child(hint)
	panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-500, -280)
	panel.size = Vector2(1000, 560)
	panel.visible = false
	layer.add_child(panel)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 14)
	panel.add_child(root)
	var heading := Label.new()
	heading.text = _t("MORROW SECURITY — LIVE / ARCHIVE COMPARISON", "MORROW SECURITY — СРАВНЕНИЕ LIVE / АРХИВА")
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 22)
	root.add_child(heading)
	var feeds := HBoxContainer.new()
	feeds.add_theme_constant_override("separation", 18)
	root.add_child(feeds)
	live_text = Label.new()
	live_text.custom_minimum_size = Vector2(470, 300)
	live_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	live_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	live_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feeds.add_child(live_text)
	archive_text = Label.new()
	archive_text.custom_minimum_size = Vector2(470, 300)
	archive_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	archive_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	archive_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feeds.add_child(archive_text)
	result_label = Label.new()
	result_label.custom_minimum_size = Vector2(950, 55)
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(result_label)
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 16)
	root.add_child(buttons)
	choose_live = Button.new()
	choose_live.text = _t("TRUST LIVE CCTV", "ДОВЕРИТЬСЯ LIVE CCTV")
	choose_live.custom_minimum_size = Vector2(470, 46)
	choose_live.pressed.connect(func() -> void: _choose(true))
	buttons.add_child(choose_live)
	choose_archive = Button.new()
	choose_archive.text = _t("TRUST ARCHIVE", "ДОВЕРИТЬСЯ АРХИВУ")
	choose_archive.custom_minimum_size = Vector2(470, 46)
	choose_archive.pressed.connect(func() -> void: _choose(false))
	buttons.add_child(choose_archive)

func _t(en: String, ru: String) -> String:
	return ru if L.get_language() == "ru" else en
