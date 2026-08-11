extends Node

const L = preload("res://scripts/localization.gd")
const CUSTOMER = preload("res://scripts/customer.gd")
const SAVE_PATH := "user://save.json"
const MENU_SCENE := "res://scenes/main_menu.tscn"

var game: Node3D
var player: CharacterBody3D
var entity: Node3D
var choice_panel: PanelContainer
var ending_panel: PanelContainer
var title_label: Label
var body_label: Label
var result_label: Label
var final_started: bool = false
var final_resolved: bool = false
var ending_id: String = ""
var memory_ok: bool = false
var identity_ok: bool = false
var paper_choice: bool = false
var threat_level: int = 0

func _ready() -> void:
	call_deferred("_initialize")

func _initialize() -> void:
	game = get_parent() as Node3D
	player = game.get_node_or_null("Player") as CharacterBody3D
	_read_history()
	_build_ui()
	set_process(true)

func _process(_delta: float) -> void:
	if game == null or final_started:
		return
	var minutes_value: Variant = game.get("shift_minutes")
	var minutes: float = float(minutes_value) if typeof(minutes_value) in [TYPE_FLOAT, TYPE_INT] else 0.0
	if minutes >= 197.0:
		final_started = true
		_start_finale()

func _read_history() -> void:
	var data: Dictionary = _read_save()
	memory_ok = bool(data.get("night_4_memory_correct", false))
	identity_ok = bool(data.get("night_5_identity_correct", false))
	paper_choice = str(data.get("night_5_0317_choice", "system")) == "paper"
	threat_level = int(data.get("threat_level", 0))

func _start_finale() -> void:
	var shift_value: Variant = game.get("shift_minutes")
	if typeof(shift_value) in [TYPE_FLOAT, TYPE_INT]:
		game.set("shift_minutes", 197.0)
	entity = CUSTOMER.new()
	game.add_child(entity)
	entity.global_position = Vector3(0.0, 0.0, -9.5)
	entity.setup(_t("The 03:17 Customer", "Покупатель 03:17"), true, Color(0.055, 0.06, 0.075), "default")
	await entity.walk_to(Vector3(3.55, 0.0, -5.75), 3.0)
	if game.has_method("show_message"):
		game.call("show_message", _t("Every monitor goes black. The customer speaks with your voice.", "Все мониторы гаснут. Покупатель говорит твоим голосом."), 4.0)
	await get_tree().create_timer(2.5).timeout
	if game.has_method("show_message"):
		game.call("show_message", _t("'Only one version of you can leave this store.'", "«Из магазина может выйти только одна версия тебя»."), 4.5)
	await get_tree().create_timer(2.7).timeout
	_open_choice()

func _open_choice() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	choice_panel.visible = true
	var objective: Variant = game.get("objective_label")
	if objective is Label:
		(objective as Label).text = _t("FINAL CHOICE: Decide what leaves at 03:17.", "ФИНАЛЬНЫЙ ВЫБОР: Реши, что покинет магазин в 03:17.")

func _resolve_choice(choice: String) -> void:
	if final_resolved:
		return
	final_resolved = true
	choice_panel.visible = false
	ending_id = _derive_ending(choice)
	_write_ending(choice)
	if entity != null and is_instance_valid(entity):
		entity.queue_free()
	await get_tree().create_timer(0.8).timeout
	_show_ending(ending_id)

func _derive_ending(choice: String) -> String:
	if choice == "merge":
		return "ending_merge"
	if choice == "broadcast":
		if memory_ok and identity_ok:
			return "ending_witness"
		return "ending_replaced"
	# leave with the paper/self anchor
	if memory_ok and identity_ok and paper_choice and threat_level <= 1:
		return "ending_escape"
	if memory_ok and identity_ok and paper_choice:
		return "ending_witness"
	return "ending_replaced"

func _show_ending(id: String) -> void:
	ending_panel.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	match id:
		"ending_escape":
			title_label.text = _t("ENDING I — OUTSIDE 03:17", "КОНЦОВКА I — ЗА ПРЕДЕЛАМИ 03:17")
			body_label.text = _t(
				"You walk through the staff door carrying the paper record. Behind you, every camera deletes the last six nights. At 06:04 the sun rises. Your phone has no photos from Morrow Market, but your name is still written in your own hand.\n\nWeeks later, the store closes without explanation. At 03:17 each morning, an unknown number calls once and hangs up.",
				"Ты выходишь через служебную дверь, держа бумажную запись. Позади камеры удаляют последние шесть ночей. В 06:04 восходит солнце. В телефоне нет ни одной фотографии из Morrow Market, но твоё имя всё ещё написано твоей рукой.\n\nЧерез несколько недель магазин закрывается без объяснений. Каждое утро в 03:17 неизвестный номер звонит один раз и сбрасывает."
			)
		"ending_witness":
			title_label.text = _t("ENDING II — THE WITNESS", "КОНЦОВКА II — СВИДЕТЕЛЬ")
			body_label.text = _t(
				"You transmit the paper log, corrupted footage and your testimony before the system can rewrite them. The store keeps you inside until sunrise, but the files escape.\n\nMonths later, strangers begin sending you recordings stamped 03:17 from stores you have never visited. You survived, but now you are the person everyone asks to believe them.",
				"Ты отправляешь наружу бумажный журнал, повреждённые записи и своё свидетельство до того, как система успевает их переписать. Магазин удерживает тебя до рассвета, но файлы успевают уйти.\n\nЧерез несколько месяцев незнакомцы начинают присылать тебе записи с отметкой 03:17 из магазинов, где ты никогда не был. Ты выжил, но теперь именно тебя все просят поверить им."
			)
		"ending_merge":
			title_label.text = _t("ENDING III — ALWAYS ON SHIFT", "КОНЦОВКА III — ВЕЧНАЯ СМЕНА")
			body_label.text = _t(
				"You accept the system's version of you. For one second every camera shows the same face. Then the customer is gone.\n\nThe next employee arrives at midnight. You are already behind the register, smiling, wearing a clean uniform. The database says you have worked here for 417 days. You remember all of them.",
				"Ты принимаешь версию себя, созданную системой. На одну секунду все камеры показывают одно и то же лицо. Затем покупатель исчезает.\n\nСледующий сотрудник приходит в полночь. Ты уже стоишь за кассой, улыбаешься и носишь чистую форму. База говорит, что ты работаешь здесь 417 дней. Ты помнишь каждый из них."
			)
		_:
			title_label.text = _t("ENDING IV — REPLACED", "КОНЦОВКА IV — ЗАМЕНЁН")
			body_label.text = _t(
				"You reach the exit. The door unlocks. The employee terminal thanks someone else by name.\n\nOutside, your reflection in the glass stays behind the counter. By morning nobody can find a record that you were ever employed here. At midnight, the reflection starts another shift.",
				"Ты доходишь до выхода. Дверь открывается. Терминал сотрудников благодарит другого человека по имени.\n\nСнаружи твоё отражение в стекле остаётся за кассой. К утру никто не может найти записи о том, что ты когда-либо здесь работал. В полночь отражение начинает новую смену."
			)
	result_label.text = _t("Ending saved.", "Концовка сохранена.")

func _write_ending(choice: String) -> void:
	var data: Dictionary = _read_save()
	data["night"] = 6
	data["game_complete"] = true
	data["final_choice"] = choice
	data["ending_id"] = ending_id
	var unlocked_value: Variant = data.get("unlocked_endings", [])
	var unlocked: Array = unlocked_value as Array if typeof(unlocked_value) == TYPE_ARRAY else []
	if not unlocked.has(ending_id):
		unlocked.append(ending_id)
	data["unlocked_endings"] = unlocked
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))

func _return_to_menu() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)

func _replay_final_night() -> void:
	get_tree().reload_current_scene()

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 90
	add_child(layer)

	choice_panel = PanelContainer.new()
	choice_panel.set_anchors_preset(Control.PRESET_CENTER)
	choice_panel.position = Vector2(-390, -245)
	choice_panel.size = Vector2(780, 490)
	choice_panel.visible = false
	layer.add_child(choice_panel)
	var choice_box := VBoxContainer.new()
	choice_box.add_theme_constant_override("separation", 14)
	choice_panel.add_child(choice_box)
	var choice_title := Label.new()
	choice_title.text = _t("03:17 — WHAT LEAVES THE STORE?", "03:17 — ЧТО ПОКИНЕТ МАГАЗИН?")
	choice_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	choice_title.add_theme_font_size_override("font_size", 24)
	choice_box.add_child(choice_title)
	var choice_body := Label.new()
	choice_body.text = _t("The system, the paper record and the thing at the register all claim to be the true version of events.", "Система, бумажная запись и существо у кассы — все утверждают, что именно их версия событий настоящая.")
	choice_body.custom_minimum_size = Vector2(720, 120)
	choice_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	choice_body.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	choice_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	choice_box.add_child(choice_body)
	var leave_button := Button.new()
	leave_button.text = _t("LEAVE WITH THE PAPER RECORD", "УЙТИ С БУМАЖНОЙ ЗАПИСЬЮ")
	leave_button.custom_minimum_size.y = 50
	leave_button.pressed.connect(_resolve_choice.bind("leave"))
	choice_box.add_child(leave_button)
	var broadcast_button := Button.new()
	broadcast_button.text = _t("SEND ALL EVIDENCE OUTSIDE", "ОТПРАВИТЬ ВСЕ ДОКАЗАТЕЛЬСТВА НАРУЖУ")
	broadcast_button.custom_minimum_size.y = 50
	broadcast_button.pressed.connect(_resolve_choice.bind("broadcast"))
	choice_box.add_child(broadcast_button)
	var merge_button := Button.new()
	merge_button.text = _t("ACCEPT THE SYSTEM'S VERSION", "ПРИНЯТЬ ВЕРСИЮ СИСТЕМЫ")
	merge_button.custom_minimum_size.y = 50
	merge_button.pressed.connect(_resolve_choice.bind("merge"))
	choice_box.add_child(merge_button)

	ending_panel = PanelContainer.new()
	ending_panel.set_anchors_preset(Control.PRESET_CENTER)
	ending_panel.position = Vector2(-470, -295)
	ending_panel.size = Vector2(940, 590)
	ending_panel.visible = false
	layer.add_child(ending_panel)
	var ending_box := VBoxContainer.new()
	ending_box.add_theme_constant_override("separation", 16)
	ending_panel.add_child(ending_box)
	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 28)
	ending_box.add_child(title_label)
	body_label = Label.new()
	body_label.custom_minimum_size = Vector2(880, 360)
	body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.add_theme_font_size_override("font_size", 18)
	ending_box.add_child(body_label)
	result_label = Label.new()
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ending_box.add_child(result_label)
	var button_row := HBoxContainer.new()
	button_row.add_theme_constant_override("separation", 16)
	ending_box.add_child(button_row)
	var replay := Button.new()
	replay.text = _t("REPLAY NIGHT 6", "ПЕРЕИГРАТЬ НОЧЬ 6")
	replay.custom_minimum_size = Vector2(430, 48)
	replay.pressed.connect(_replay_final_night)
	button_row.add_child(replay)
	var menu := Button.new()
	menu.text = _t("RETURN TO MAIN MENU", "В ГЛАВНОЕ МЕНЮ")
	menu.custom_minimum_size = Vector2(430, 48)
	menu.pressed.connect(_return_to_menu)
	button_row.add_child(menu)

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
