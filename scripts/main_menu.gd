extends Control

const GAME_SCENE := "res://scenes/main.tscn"
const NIGHT2_SCENE := "res://scenes/night2.tscn"
const NIGHT3_SCENE := "res://scenes/night3.tscn"
const NIGHT4_SCENE := "res://scenes/night4.tscn"
const NIGHT5_SCENE := "res://scenes/night5.tscn"
const NIGHT6_SCENE := "res://scenes/night6.tscn"
const LOCALIZATION := preload("res://scripts/localization.gd")
const SAVE_SYSTEM := preload("res://scripts/save_system.gd")

var timestamp_label: Label
var signal_label: Label
var continue_button: Button
var settings_panel: PanelContainer
var credits_panel: PanelContainer
var endings_panel: PanelContainer
var endings_text: Label
var master_slider: HSlider
var sensitivity_slider: HSlider
var fullscreen_check: CheckBox
var subtitles_check: CheckBox
var reduce_flashes_check: CheckBox
var language_option: OptionButton
var text_scale_option: OptionButton
var vignette: ColorRect
var glitch_timer := 0.0
var fake_seconds := 52.0
var current_language := "en"

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	current_language = LOCALIZATION.get_language()
	build_background()
	build_menu()
	build_settings_panel()
	build_credits_panel()
	build_endings_panel()
	update_continue_state()
	apply_saved_settings()

func _process(delta: float) -> void:
	fake_seconds += delta * 0.72
	if fake_seconds >= 60.0: fake_seconds = 0.0
	timestamp_label.text = "%s     03:16:%02d" % [t("cam_parking"), int(fake_seconds)]
	glitch_timer -= delta
	if glitch_timer <= 0.0:
		glitch_timer = randf_range(1.8,5.2)
		var keys:Array[String] = ["signal_ok","tracking","no_motion","event_pending"]
		signal_label.text = t(keys[randi()%keys.size()])
		var cfg:=ConfigFile.new()
		var reduce:=false
		if cfg.load("user://settings.cfg")==OK: reduce=bool(cfg.get_value("accessibility","reduce_flashes",false))
		if not reduce:
			var tween:=create_tween()
			tween.tween_property(vignette,"color:a",randf_range(.35,.62),.05)
			tween.tween_property(vignette,"color:a",.42,.12)

func t(key:String)->String: return LOCALIZATION.tr_key(key,current_language)
func tt(en:String,ru:String)->String: return ru if current_language=="ru" else en

func build_background()->void:
	var bg:=ColorRect.new();bg.set_anchors_preset(Control.PRESET_FULL_RECT);bg.color=Color(.018,.026,.03);add_child(bg)
	var lot:=ColorRect.new();lot.position=Vector2(0,420);lot.size=Vector2(1280,300);lot.color=Color(.025,.032,.035);add_child(lot)
	var store:=ColorRect.new();store.position=Vector2(650,165);store.size=Vector2(520,330);store.color=Color(.08,.105,.11);add_child(store)
	var window:=ColorRect.new();window.position=Vector2(690,235);window.size=Vector2(440,185);window.color=Color(.52,.66,.64,.68);add_child(window)
	for i:int in range(8):
		var stripe:=ColorRect.new();stripe.position=Vector2(705+i*53,245);stripe.size=Vector2(2,165);stripe.color=Color(.12,.16,.16,.45);add_child(stripe)
	var silhouette:=ColorRect.new();silhouette.position=Vector2(900,365);silhouette.size=Vector2(18,58);silhouette.color=Color(.005,.006,.006,.92);add_child(silhouette)
	for y:int in range(0,720,4):
		var scanline:=ColorRect.new();scanline.position=Vector2(0,y);scanline.size=Vector2(1280,1);scanline.color=Color(0,0,0,.10);scanline.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(scanline)
	vignette=ColorRect.new();vignette.set_anchors_preset(Control.PRESET_FULL_RECT);vignette.color=Color(0,0,0,.42);vignette.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(vignette)
	timestamp_label=Label.new();timestamp_label.position=Vector2(32,24);timestamp_label.add_theme_font_size_override("font_size",18);timestamp_label.modulate=Color(.72,.82,.78);add_child(timestamp_label)
	signal_label=Label.new();signal_label.position=Vector2(930,24);signal_label.size=Vector2(320,30);signal_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT;signal_label.text=t("signal_ok");signal_label.modulate=Color(.65,.76,.7);add_child(signal_label)

func build_menu()->void:
	var box:=VBoxContainer.new();box.position=Vector2(78,105);box.size=Vector2(430,570);box.add_theme_constant_override("separation",8);add_child(box)
	var title:=Label.new();title.text=t("title");title.add_theme_font_size_override("font_size",55);box.add_child(title)
	var subtitle:=Label.new();subtitle.text=t("subtitle");subtitle.add_theme_font_size_override("font_size",14);subtitle.modulate=Color(.58,.68,.64);box.add_child(subtitle)
	var spacer:=Control.new();spacer.custom_minimum_size=Vector2(1,20);box.add_child(spacer)
	add_menu_button(box,t("new_shift"),start_new_game)
	continue_button=add_menu_button(box,t("continue"),continue_game)
	add_menu_button(box,t("settings"),show_settings)
	add_menu_button(box,tt("ENDINGS","КОНЦОВКИ"),show_endings)
	add_menu_button(box,t("credits"),show_credits)
	add_menu_button(box,t("quit"),quit_game)

func add_menu_button(parent:VBoxContainer,text:String,callable:Callable)->Button:
	var b:=Button.new();b.text=text;b.custom_minimum_size=Vector2(360,44);b.alignment=HORIZONTAL_ALIGNMENT_LEFT;b.add_theme_font_size_override("font_size",18);b.pressed.connect(callable);parent.add_child(b);return b

func build_settings_panel()->void:
	settings_panel=PanelContainer.new();settings_panel.position=Vector2(575,55);settings_panel.size=Vector2(590,610);settings_panel.visible=false;add_child(settings_panel)
	var box:=VBoxContainer.new();box.add_theme_constant_override("separation",7);settings_panel.add_child(box)
	var heading:=Label.new();heading.text=t("system_settings");heading.add_theme_font_size_override("font_size",25);box.add_child(heading)
	_add_label(box,t("master_volume"));master_slider=HSlider.new();master_slider.min_value=0;master_slider.max_value=100;master_slider.step=1;master_slider.value_changed.connect(on_volume_changed);box.add_child(master_slider)
	_add_label(box,tt("MOUSE SENSITIVITY","ЧУВСТВИТЕЛЬНОСТЬ МЫШИ"));sensitivity_slider=HSlider.new();sensitivity_slider.min_value=35;sensitivity_slider.max_value=200;sensitivity_slider.step=5;sensitivity_slider.value_changed.connect(_settings_changed);box.add_child(sensitivity_slider)
	fullscreen_check=CheckBox.new();fullscreen_check.text=t("fullscreen");fullscreen_check.toggled.connect(on_fullscreen_toggled);box.add_child(fullscreen_check)
	subtitles_check=CheckBox.new();subtitles_check.text=tt("SHOW TRANSIENT SUBTITLES / MESSAGES","ПОКАЗЫВАТЬ СУБТИТРЫ / СООБЩЕНИЯ");subtitles_check.toggled.connect(_settings_changed);box.add_child(subtitles_check)
	reduce_flashes_check=CheckBox.new();reduce_flashes_check.text=tt("REDUCE FLASHING EFFECTS","УМЕНЬШИТЬ МИГАЮЩИЕ ЭФФЕКТЫ");reduce_flashes_check.toggled.connect(_settings_changed);box.add_child(reduce_flashes_check)
	_add_label(box,tt("TEXT SIZE","РАЗМЕР ТЕКСТА"));text_scale_option=OptionButton.new();text_scale_option.add_item(tt("SMALL","МАЛЕНЬКИЙ"),0);text_scale_option.add_item(tt("NORMAL","ОБЫЧНЫЙ"),1);text_scale_option.add_item(tt("LARGE","КРУПНЫЙ"),2);text_scale_option.item_selected.connect(_settings_changed);box.add_child(text_scale_option)
	_add_label(box,t("language"));language_option=OptionButton.new();language_option.add_item(t("english"),0);language_option.add_item(t("russian"),1);language_option.item_selected.connect(on_language_selected);box.add_child(language_option)
	var reset:=Button.new();reset.text=tt("RESET SETTINGS","СБРОСИТЬ НАСТРОЙКИ");reset.pressed.connect(reset_settings);box.add_child(reset)
	var back:=Button.new();back.text=t("back");back.pressed.connect(hide_panels);box.add_child(back)

func _add_label(parent:VBoxContainer,text:String)->void:
	var l:=Label.new();l.text=text;parent.add_child(l)

func build_credits_panel()->void:
	credits_panel=PanelContainer.new();credits_panel.position=Vector2(600,145);credits_panel.size=Vector2(520,420);credits_panel.visible=false;add_child(credits_panel)
	var box:=VBoxContainer.new();box.add_theme_constant_override("separation",16);credits_panel.add_child(box)
	var heading:=Label.new();heading.text=t("credits");heading.add_theme_font_size_override("font_size",26);box.add_child(heading)
	var text:=Label.new();text.text=t("credits_body");text.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;text.custom_minimum_size=Vector2(440,250);box.add_child(text)
	var back:=Button.new();back.text=t("back");back.pressed.connect(hide_panels);box.add_child(back)

func build_endings_panel()->void:
	endings_panel=PanelContainer.new();endings_panel.position=Vector2(570,105);endings_panel.size=Vector2(610,510);endings_panel.visible=false;add_child(endings_panel)
	var box:=VBoxContainer.new();box.add_theme_constant_override("separation",12);endings_panel.add_child(box)
	var heading:=Label.new();heading.text=tt("ENDING ARCHIVE","АРХИВ КОНЦОВОК");heading.add_theme_font_size_override("font_size",26);box.add_child(heading)
	endings_text=Label.new();endings_text.custom_minimum_size=Vector2(550,350);endings_text.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;box.add_child(endings_text)
	var back:=Button.new();back.text=t("back");back.pressed.connect(hide_panels);box.add_child(back)

func show_endings()->void:
	hide_panels();endings_panel.visible=true
	var data:=SAVE_SYSTEM.load_save();var unlocked:Array=data.get("unlocked_endings",[])
	var defs={"ending_escape":tt("ENDING I — OUTSIDE 03:17","КОНЦОВКА I — ЗА ПРЕДЕЛАМИ 03:17"),"ending_witness":tt("ENDING II — THE WITNESS","КОНЦОВКА II — СВИДЕТЕЛЬ"),"ending_merge":tt("ENDING III — ALWAYS ON SHIFT","КОНЦОВКА III — ВЕЧНАЯ СМЕНА"),"ending_replaced":tt("ENDING IV — REPLACED","КОНЦОВКА IV — ЗАМЕНЁН")}
	var out:=tt("Unlocked endings: %d / 4\n\n","Открыто концовок: %d / 4\n\n") % unlocked.size()
	for key in defs.keys():out += ("[✓] " if unlocked.has(key) else "[?] ") + (str(defs[key]) if unlocked.has(key) else tt("UNKNOWN ENDING","НЕИЗВЕСТНАЯ КОНЦОВКА")) + "\n\n"
	endings_text.text=out

func start_new_game()->void:
	SAVE_SYSTEM.reset_progress()
	var cfg:=ConfigFile.new();cfg.set_value("progress","night",1);cfg.set_value("progress","started",true);cfg.save("user://save.cfg")
	get_tree().change_scene_to_file(GAME_SCENE)

func continue_game()->void:
	var night:=int(SAVE_SYSTEM.load_save().get("night",1)) if SAVE_SYSTEM.has_progress() else _read_legacy_night()
	var path:=GAME_SCENE
	if night>=6:path=NIGHT6_SCENE
	elif night==5:path=NIGHT5_SCENE
	elif night==4:path=NIGHT4_SCENE
	elif night==3:path=NIGHT3_SCENE
	elif night==2:path=NIGHT2_SCENE
	get_tree().change_scene_to_file(path)

func _read_legacy_night()->int:
	var cfg:=ConfigFile.new()
	if cfg.load("user://save.cfg")==OK:return clampi(int(cfg.get_value("progress","night",1)),1,6)
	return 1

func update_continue_state()->void:
	continue_button.disabled=not SAVE_SYSTEM.has_progress() and not FileAccess.file_exists("user://save.cfg")
	continue_button.tooltip_text=t("no_save") if continue_button.disabled else t("resume_save")

func show_settings()->void:hide_panels();settings_panel.visible=true
func show_credits()->void:hide_panels();credits_panel.visible=true
func hide_panels()->void:
	settings_panel.visible=false;credits_panel.visible=false;endings_panel.visible=false

func on_volume_changed(value:float)->void:
	var bus:=AudioServer.get_bus_index("Master");AudioServer.set_bus_volume_db(bus,linear_to_db(max(value/100.0,.001)));save_settings()
func on_fullscreen_toggled(enabled:bool)->void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED);save_settings()
func on_language_selected(index:int)->void:
	current_language="ru" if index==1 else "en";LOCALIZATION.set_language(current_language);save_settings();get_tree().reload_current_scene()
func _settings_changed(_value:Variant=null)->void:save_settings()

func save_settings()->void:
	if master_slider==null:return
	var config:=ConfigFile.new();config.load("user://settings.cfg")
	config.set_value("audio","master_volume",master_slider.value)
	config.set_value("display","fullscreen",fullscreen_check.button_pressed)
	config.set_value("display","language",current_language)
	config.set_value("controls","mouse_sensitivity",sensitivity_slider.value)
	config.set_value("accessibility","subtitles",subtitles_check.button_pressed)
	config.set_value("accessibility","reduce_flashes",reduce_flashes_check.button_pressed)
	var scales:=[0.85,1.0,1.25];config.set_value("accessibility","text_scale",scales[text_scale_option.selected])
	config.save("user://settings.cfg")

func apply_saved_settings()->void:
	var config:=ConfigFile.new();config.load("user://settings.cfg")
	master_slider.set_value_no_signal(float(config.get_value("audio","master_volume",70.0)))
	fullscreen_check.set_pressed_no_signal(bool(config.get_value("display","fullscreen",false)))
	sensitivity_slider.set_value_no_signal(float(config.get_value("controls","mouse_sensitivity",100.0)))
	subtitles_check.set_pressed_no_signal(bool(config.get_value("accessibility","subtitles",true)))
	reduce_flashes_check.set_pressed_no_signal(bool(config.get_value("accessibility","reduce_flashes",false)))
	var scale:=float(config.get_value("accessibility","text_scale",1.0));text_scale_option.select(0 if scale<.95 else (2 if scale>1.1 else 1))
	language_option.select(1 if current_language=="ru" else 0)
	var bus:=AudioServer.get_bus_index("Master");AudioServer.set_bus_volume_db(bus,linear_to_db(max(master_slider.value/100.0,.001)))
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen_check.button_pressed else DisplayServer.WINDOW_MODE_WINDOWED)

func reset_settings()->void:
	var config:=ConfigFile.new();config.set_value("audio","master_volume",70.0);config.set_value("display","fullscreen",false);config.set_value("display","language",current_language);config.set_value("controls","mouse_sensitivity",100.0);config.set_value("accessibility","subtitles",true);config.set_value("accessibility","reduce_flashes",false);config.set_value("accessibility","text_scale",1.0);config.save("user://settings.cfg");apply_saved_settings()
func quit_game()->void:get_tree().quit()
