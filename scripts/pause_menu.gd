extends Node

const MAIN_MENU_SCENE: String = "res://scenes/main_menu.tscn"
const LOCALIZATION = preload("res://scripts/localization.gd")

var overlay: ColorRect
var panel: PanelContainer
var quality_option: OptionButton
var paused: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("pause_manager")
	_build_pause_ui()

func _t(en_text: String, ru_text: String) -> String:
	return ru_text if LOCALIZATION.get_language() == "ru" else en_text

func toggle_pause() -> void:
	if paused: _resume()
	else: _pause()

func _pause() -> void:
	paused = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	overlay.visible = true
	_sync_quality()

func _resume() -> void:
	paused = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	overlay.visible = false

func _restart_shift() -> void:
	get_tree().paused = false
	paused = false
	get_tree().reload_current_scene()

func _return_to_menu() -> void:
	get_tree().paused = false
	paused = false
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func _quit_game() -> void:
	get_tree().paused = false
	get_tree().quit()

func _quality_changed(index:int)->void:
	var value:=["low","balanced","high"][clampi(index,0,2)]
	var runtime:=get_tree().get_first_node_in_group("performance_runtime")
	if runtime!=null and runtime.has_method("apply_preset"):
		runtime.call("apply_preset",value,true)

func _sync_quality()->void:
	var cfg:=ConfigFile.new();cfg.load("user://settings.cfg")
	var value:=str(cfg.get_value("graphics","quality_preset","balanced"))
	quality_option.select(0 if value=="low" else (2 if value=="high" else 1))

func _build_pause_ui() -> void:
	var layer: CanvasLayer = CanvasLayer.new();layer.name="PauseLayer";layer.layer=100;layer.process_mode=Node.PROCESS_MODE_ALWAYS;add_child(layer)
	overlay=ColorRect.new();overlay.name="PauseOverlay";overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);overlay.color=Color(0,0,0,.82);overlay.mouse_filter=Control.MOUSE_FILTER_STOP;overlay.process_mode=Node.PROCESS_MODE_ALWAYS;overlay.visible=false;layer.add_child(overlay)
	panel=PanelContainer.new();panel.set_anchors_preset(Control.PRESET_CENTER);panel.position=Vector2(-230,-250);panel.size=Vector2(460,500);panel.process_mode=Node.PROCESS_MODE_ALWAYS;overlay.add_child(panel)
	var box:=VBoxContainer.new();box.add_theme_constant_override("separation",12);panel.add_child(box)
	var title:=Label.new();title.text=_t("SHIFT PAUSED","СМЕНА ПРИОСТАНОВЛЕНА");title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;title.add_theme_font_size_override("font_size",28);box.add_child(title)
	_add_button(box,_t("RESUME SHIFT","ПРОДОЛЖИТЬ"),_resume)
	var qlabel:=Label.new();qlabel.text=_t("GRAPHICS PRESET","ПРЕСЕТ ГРАФИКИ");box.add_child(qlabel)
	quality_option=OptionButton.new();quality_option.add_item(_t("LOW — PERFORMANCE","НИЗКИЙ — ПРОИЗВОДИТЕЛЬНОСТЬ"));quality_option.add_item(_t("BALANCED","СБАЛАНСИРОВАННЫЙ"));quality_option.add_item(_t("HIGH — QUALITY","ВЫСОКИЙ — КАЧЕСТВО"));quality_option.item_selected.connect(_quality_changed);box.add_child(quality_option)
	_add_button(box,_t("RESTART CURRENT NIGHT","ПЕРЕЗАПУСТИТЬ ТЕКУЩУЮ НОЧЬ"),_restart_shift)
	_add_button(box,_t("RETURN TO MAIN MENU","ВЕРНУТЬСЯ В ГЛАВНОЕ МЕНЮ"),_return_to_menu)
	_add_button(box,_t("QUIT GAME","ВЫЙТИ ИЗ ИГРЫ"),_quit_game)
	var hint:=Label.new();hint.text=_t("ESC — resume","ESC — продолжить");hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;hint.modulate=Color(.48,.54,.52);box.add_child(hint)

func _add_button(parent:VBoxContainer,label:String,action:Callable)->void:
	var button:=Button.new();button.text=label;button.custom_minimum_size=Vector2(420,46);button.process_mode=Node.PROCESS_MODE_ALWAYS;button.pressed.connect(action);parent.add_child(button)
