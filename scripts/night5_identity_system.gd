extends Node

const L = preload("res://scripts/localization.gd")
const SAVE_PATH := "user://save.json"

var game: Node3D
var player: CharacterBody3D
var panel: PanelContainer
var hint: Label
var source_text: Label
var result_text: Label
var checked: Dictionary = {}
var route := "uncertain_identity"
var active := false
var resolved := false

func _ready() -> void:
	call_deferred("_initialize")

func _initialize() -> void:
	game = get_parent() as Node3D
	player = game.get_node_or_null("Player") as CharacterBody3D
	route = str(game.get("route"))
	_build_station()
	_build_ui()

func _process(_delta: float) -> void:
	if game == null or resolved: return
	if float(game.get("shift_minutes")) >= 70.0 and not active:
		active = true
		game.call("show_message", _t("The employee terminal requests identity re-verification.", "Терминал сотрудников требует повторной проверки личности."), 5.0)
		var objective = game.get("objective_label")
		if objective is Label: objective.text = _t("OBJECTIVE: Verify badge, biometric record and manager log.", "ЗАДАЧА: Проверь бейдж, биометрию и журнал менеджера.")
	if active and player != null:
		var d := Vector2(player.global_position.x - 5.8, player.global_position.z + 3.0).length()
		hint.visible = d < 1.8 and not panel.visible

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and active and hint.visible:
		panel.visible = true; Input.mouse_mode = Input.MOUSE_MODE_VISIBLE; _refresh(); get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel") and panel.visible:
		panel.visible = false; Input.mouse_mode = Input.MOUSE_MODE_CAPTURED; get_viewport().set_input_as_handled()

func _inspect(key: String) -> void:
	checked[key] = true
	_refresh()

func _refresh() -> void:
	var lines := _t("IDENTITY VERIFICATION\n\n", "ПРОВЕРКА ЛИЧНОСТИ\n\n")
	lines += _entry("badge", _t("BADGE", "БЕЙДЖ"), _badge_result())
	lines += _entry("bio", _t("BIOMETRIC", "БИОМЕТРИЯ"), _bio_result())
	lines += _entry("manager", _t("MANAGER LOG", "ЖУРНАЛ МЕНЕДЖЕРА"), _manager_result())
	source_text.text = lines
	result_text.text = _t("Three records must be checked before choosing what defines you.", "Нужно проверить три записи, прежде чем решить, что определяет твою личность.") if checked.size() < 3 else _t("All records checked. Choose the record you trust.", "Все записи проверены. Выбери запись, которой доверяешь.")

func _entry(key:String,title:String,value:String)->String:
	return ("[✓] " if checked.has(key) else "[ ] ") + title + ("\n    "+value if checked.has(key) else "") + "\n\n"

func _badge_result()->String:
	if route == "fractured_identity": return _t("Photo: UNKNOWN EMPLOYEE. Name field contains your name.", "Фото: НЕИЗВЕСТНЫЙ СОТРУДНИК. В поле имени указано твоё имя.")
	return _t("Photo and name match you. Issue date changed to tomorrow.", "Фото и имя совпадают. Дата выдачи изменилась на завтрашнюю.")
func _bio_result()->String:
	return _t("Fingerprint accepted. Employee ID: NULL-0317.", "Отпечаток принят. ID сотрудника: NULL-0317.")
func _manager_result()->String:
	return _t("Handwritten log: 'Night clerk hired before camera system. Do not overwrite paper record.'", "Рукописный журнал: «Ночной кассир принят до установки камер. Не перезаписывать бумажную запись». ")

func _choose(source:String)->void:
	if checked.size() < 3 or resolved: return
	resolved = true
	var correct := source == "manager"
	result_text.text = _t("IDENTITY ANCHOR PRESERVED", "ЯКОРЬ ЛИЧНОСТИ СОХРАНЁН") if correct else _t("IDENTITY ACCEPTED FROM CORRUPTED SYSTEM", "ЛИЧНОСТЬ ПРИНЯТА ИЗ ИСКАЖЁННОЙ СИСТЕМЫ")
	var data := _read_save(); data["night_5_identity_correct"] = correct; data["night_5_identity_source"] = source; data["identity_integrity"] = 2 if correct else 0
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE); if f != null: f.store_string(JSON.stringify(data))
	await get_tree().create_timer(2.0).timeout
	panel.visible=false; Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	var objective = game.get("objective_label"); if objective is Label: objective.text=_t("OBJECTIVE: Keep working. Do not let the system rename you.","ЗАДАЧА: Продолжай смену. Не позволяй системе переименовать тебя.")

func _build_station()->void:
	var body:=StaticBody3D.new();body.position=Vector3(5.8,.75,-3.0);game.add_child(body);var mi:=MeshInstance3D.new();var mesh:=BoxMesh.new();mesh.size=Vector3(1.4,1.5,.6);var mat:=StandardMaterial3D.new();mat.albedo_color=Color(.06,.08,.11);mat.emission_enabled=true;mat.emission=Color(.05,.09,.16);mat.emission_energy_multiplier=1.3;mesh.material=mat;mi.mesh=mesh;body.add_child(mi);var cs:=CollisionShape3D.new();var sh:=BoxShape3D.new();sh.size=mesh.size;cs.shape=sh;body.add_child(cs)
func _build_ui()->void:
	var layer:=CanvasLayer.new();layer.layer=45;add_child(layer);hint=Label.new();hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM);hint.position=Vector2(-250,-75);hint.size=Vector2(500,32);hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;hint.text=_t("E — IDENTITY TERMINAL","E — ТЕРМИНАЛ ЛИЧНОСТИ");hint.visible=false;layer.add_child(hint);panel=PanelContainer.new();panel.set_anchors_preset(Control.PRESET_CENTER);panel.position=Vector2(-410,-280);panel.size=Vector2(820,560);panel.visible=false;layer.add_child(panel);var root:=VBoxContainer.new();root.add_theme_constant_override("separation",8);panel.add_child(root);source_text=Label.new();source_text.custom_minimum_size=Vector2(770,310);source_text.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;root.add_child(source_text)
	for pair in [["badge",_t("CHECK BADGE","ПРОВЕРИТЬ БЕЙДЖ")],["bio",_t("CHECK BIOMETRIC","ПРОВЕРИТЬ БИОМЕТРИЮ")],["manager",_t("CHECK MANAGER LOG","ПРОВЕРИТЬ ЖУРНАЛ МЕНЕДЖЕРА")]]:
		var b:=Button.new();b.text=pair[1];b.pressed.connect(_inspect.bind(pair[0]));root.add_child(b)
	var row:=HBoxContainer.new();root.add_child(row)
	for pair in [["badge",_t("TRUST BADGE","ДОВЕРИТЬСЯ БЕЙДЖУ")],["bio",_t("TRUST BIOMETRIC","ДОВЕРИТЬСЯ БИОМЕТРИИ")],["manager",_t("TRUST PAPER LOG","ДОВЕРИТЬСЯ БУМАЖНОМУ ЖУРНАЛУ")]]:
		var b:=Button.new();b.text=pair[1];b.pressed.connect(_choose.bind(pair[0]));row.add_child(b)
	result_text=Label.new();result_text.custom_minimum_size=Vector2(770,55);result_text.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;root.add_child(result_text)
func _read_save()->Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):return {}
	var f:=FileAccess.open(SAVE_PATH,FileAccess.READ);if f==null:return {};var p:=JSON.parse_string(f.get_as_text());return p as Dictionary if typeof(p)==TYPE_DICTIONARY else {}
func _t(en:String,ru:String)->String:return ru if L.get_language()=="ru" else en
