extends Node

const CUSTOMER = preload("res://scripts/customer.gd")
const L = preload("res://scripts/localization.gd")
const SAVE_PATH := "user://save.json"

var game: Node3D
var customer: Node3D
var panel: PanelContainer
var prompt: Label
var started := false
var resolved := false

func _ready() -> void:
	call_deferred("_initialize")

func _initialize() -> void:
	game = get_parent() as Node3D
	_build_ui()
	set_process(true)

func _process(_delta: float) -> void:
	if game == null or resolved:
		return
	var minutes := float(game.get("shift_minutes"))
	if minutes >= 197.0 and not started:
		started = true
		_start_0317()

func _start_0317() -> void:
	customer = CUSTOMER.new()
	game.add_child(customer)
	customer.global_position = Vector3(0,0,-9.5)
	customer.setup(_t("The Namekeeper","Хранитель имени"), true, Color(0.08,0.09,0.11), "default")
	await customer.walk_to(Vector3(3.4,0,-2.8), 3.0)
	game.call("show_message", _t("He says your name before you tell him anything.", "Он произносит твоё имя раньше, чем ты успеваешь что-либо сказать."), 5.0)
	await get_tree().create_timer(1.0).timeout
	prompt.text = _t("03:17 — He offers to restore your identity to the system.\n\nDo you let the system define you, or keep the paper record?", "03:17 — Он предлагает восстановить твою личность в системе.\n\nПозволить системе определить тебя или сохранить бумажную запись?")
	panel.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _choose(system_choice: bool) -> void:
	if resolved: return
	resolved = true
	panel.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var data := _read_save()
	var identity_ok := bool(data.get("night_5_identity_correct", false))
	data["night_5_0317_choice"] = "system" if system_choice else "paper"
	data["night_5_0317_correct"] = (not system_choice) and identity_ok
	data["night"] = 6
	if not system_choice and identity_ok:
		data["night_6_route"] = "anchored_self"
	elif system_choice and identity_ok:
		data["night_6_route"] = "voluntary_merge"
	elif not system_choice:
		data["night_6_route"] = "damaged_resistance"
	else:
		data["night_6_route"] = "lost_identity"
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f != null: f.store_string(JSON.stringify(data))
	game.call("show_message", _t("NIGHT 5 COMPLETE — The final shift is waiting.", "НОЧЬ 5 ЗАВЕРШЕНА — Последняя смена ждёт тебя."), 6.0)
	var objective = game.get("objective_label")
	if objective is Label: objective.text = _t("Night 6 unlocked.", "Ночь 6 открыта.")
	if customer != null and is_instance_valid(customer): customer.queue_free()

func _read_save() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH): return {}
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null: return {}
	var p := JSON.parse_string(f.get_as_text())
	return p as Dictionary if typeof(p) == TYPE_DICTIONARY else {}

func _build_ui() -> void:
	var layer := CanvasLayer.new(); layer.layer = 60; add_child(layer)
	panel = PanelContainer.new(); panel.set_anchors_preset(Control.PRESET_CENTER); panel.position = Vector2(-330,-160); panel.size = Vector2(660,320); panel.visible = false; layer.add_child(panel)
	var box := VBoxContainer.new(); box.add_theme_constant_override("separation",12); panel.add_child(box)
	prompt = Label.new(); prompt.custom_minimum_size = Vector2(620,180); prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; prompt.vertical_alignment = VERTICAL_ALIGNMENT_CENTER; prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; prompt.add_theme_font_size_override("font_size",19); box.add_child(prompt)
	var paper := Button.new(); paper.text = _t("KEEP PAPER RECORD","СОХРАНИТЬ БУМАЖНУЮ ЗАПИСЬ"); paper.pressed.connect(func()->void:_choose(false)); box.add_child(paper)
	var system := Button.new(); system.text = _t("LET SYSTEM RESTORE ME","ПОЗВОЛИТЬ СИСТЕМЕ ВОССТАНОВИТЬ МЕНЯ"); system.pressed.connect(func()->void:_choose(true)); box.add_child(system)

func _t(en:String,ru:String)->String:
	return ru if L.get_language()=="ru" else en
