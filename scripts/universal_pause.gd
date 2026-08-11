extends Node

const L = preload("res://scripts/localization.gd")
const MENU_SCENE := "res://scenes/main_menu.tscn"

var overlay: ColorRect
var quality_option: OptionButton
var paused := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("pause_manager")
	_build_ui()

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

func _restart() -> void:
	get_tree().paused = false
	paused = false
	get_tree().reload_current_scene()

func _menu() -> void:
	get_tree().paused = false
	paused = false
	get_tree().change_scene_to_file(MENU_SCENE)

func _quality_changed(index: int) -> void:
	var value := ["low", "balanced", "high"][clampi(index,0,2)]
	var runtime := get_tree().get_first_node_in_group("performance_runtime")
	if runtime != null and runtime.has_method("apply_preset"):
		runtime.call("apply_preset", value, true)

func _sync_quality() -> void:
	var cfg := ConfigFile.new(); cfg.load("user://settings.cfg")
	var value := str(cfg.get_value("graphics","quality_preset","balanced"))
	quality_option.select(0 if value=="low" else (2 if value=="high" else 1))

func _build_ui() -> void:
	var layer := CanvasLayer.new(); layer.layer = 110; layer.process_mode = Node.PROCESS_MODE_ALWAYS; add_child(layer)
	overlay = ColorRect.new(); overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); overlay.color=Color(0,0,0,.84); overlay.visible=false; overlay.process_mode=Node.PROCESS_MODE_ALWAYS; layer.add_child(overlay)
	var panel:=PanelContainer.new(); panel.set_anchors_preset(Control.PRESET_CENTER); panel.position=Vector2(-230,-250); panel.size=Vector2(460,500); panel.process_mode=Node.PROCESS_MODE_ALWAYS; overlay.add_child(panel)
	var box:=VBoxContainer.new(); box.add_theme_constant_override("separation",12); panel.add_child(box)
	var title:=Label.new(); title.text=_t("SHIFT PAUSED","СМЕНА ПРИОСТАНОВЛЕНА"); title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; title.add_theme_font_size_override("font_size",28); box.add_child(title)
	_add_button(box,_t("RESUME","ПРОДОЛЖИТЬ"),_resume)
	var qlabel:=Label.new(); qlabel.text=_t("GRAPHICS PRESET","ПРЕСЕТ ГРАФИКИ"); box.add_child(qlabel)
	quality_option=OptionButton.new(); quality_option.add_item(_t("LOW — PERFORMANCE","НИЗКИЙ — ПРОИЗВОДИТЕЛЬНОСТЬ")); quality_option.add_item(_t("BALANCED","СБАЛАНСИРОВАННЫЙ")); quality_option.add_item(_t("HIGH — QUALITY","ВЫСОКИЙ — КАЧЕСТВО")); quality_option.item_selected.connect(_quality_changed); box.add_child(quality_option)
	_add_button(box,_t("RESTART CURRENT NIGHT","ПЕРЕЗАПУСТИТЬ ТЕКУЩУЮ НОЧЬ"),_restart)
	_add_button(box,_t("MAIN MENU","ГЛАВНОЕ МЕНЮ"),_menu)
	var hint:=Label.new(); hint.text=_t("ESC — resume","ESC — продолжить"); hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; box.add_child(hint)

func _add_button(parent:VBoxContainer,text:String,action:Callable)->void:
	var b:=Button.new(); b.text=text; b.custom_minimum_size=Vector2(420,48); b.process_mode=Node.PROCESS_MODE_ALWAYS; b.pressed.connect(action); parent.add_child(b)

func _t(en:String,ru:String)->String:
	return ru if L.get_language()=="ru" else en
