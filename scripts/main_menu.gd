extends Control

const GAME_SCENE := "res://scenes/main.tscn"
const NIGHT2_SCENE := "res://scenes/night2.tscn"
const NIGHT3_SCENE := "res://scenes/night3.tscn"
const LOCALIZATION := preload("res://scripts/localization.gd")

var timestamp_label: Label
var signal_label: Label
var continue_button: Button
var settings_panel: PanelContainer
var credits_panel: PanelContainer
var master_slider: HSlider
var fullscreen_check: CheckBox
var language_option: OptionButton
var vignette: ColorRect
var glitch_timer: float = 0.0
var fake_seconds: float = 52.0
var current_language: String = "en"

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	current_language = LOCALIZATION.get_language()
	build_background()
	build_menu()
	build_settings_panel()
	build_credits_panel()
	update_continue_state()
	apply_saved_settings()

func _process(delta: float) -> void:
	fake_seconds += delta * 0.72
	if fake_seconds >= 60.0:
		fake_seconds = 0.0
	var display_second: int = int(fake_seconds)
	timestamp_label.text = "%s     03:16:%02d" % [t("cam_parking"), display_second]
	glitch_timer -= delta
	if glitch_timer <= 0.0:
		glitch_timer = randf_range(1.8, 5.2)
		var signal_keys: Array[String] = ["signal_ok", "tracking", "no_motion", "event_pending"]
		signal_label.text = t(signal_keys[randi() % signal_keys.size()])
		var tween: Tween = create_tween()
		tween.tween_property(vignette, "color:a", randf_range(0.35, 0.62), 0.05)
		tween.tween_property(vignette, "color:a", 0.42, 0.12)

func t(key: String) -> String:
	return LOCALIZATION.tr_key(key, current_language)

func build_background() -> void:
	var bg := ColorRect.new(); bg.set_anchors_preset(Control.PRESET_FULL_RECT); bg.color = Color(0.018, 0.026, 0.03); add_child(bg)
	var lot := ColorRect.new(); lot.position = Vector2(0, 420); lot.size = Vector2(1280, 300); lot.color = Color(0.025, 0.032, 0.035); add_child(lot)
	var store := ColorRect.new(); store.position = Vector2(650, 165); store.size = Vector2(520, 330); store.color = Color(0.08, 0.105, 0.11); add_child(store)
	var window := ColorRect.new(); window.position = Vector2(690, 235); window.size = Vector2(440, 185); window.color = Color(0.52, 0.66, 0.64, 0.68); add_child(window)
	for i: int in range(8):
		var stripe := ColorRect.new(); stripe.position = Vector2(705 + i * 53, 245); stripe.size = Vector2(2, 165); stripe.color = Color(0.12, 0.16, 0.16, 0.45); add_child(stripe)
	var silhouette := ColorRect.new(); silhouette.position = Vector2(900, 365); silhouette.size = Vector2(18, 58); silhouette.color = Color(0.005, 0.006, 0.006, 0.92); add_child(silhouette)
	for y: int in range(0, 720, 4):
		var scanline := ColorRect.new(); scanline.position = Vector2(0, y); scanline.size = Vector2(1280, 1); scanline.color = Color(0, 0, 0, 0.10); scanline.mouse_filter = Control.MOUSE_FILTER_IGNORE; add_child(scanline)
	vignette = ColorRect.new(); vignette.set_anchors_preset(Control.PRESET_FULL_RECT); vignette.color = Color(0, 0, 0, 0.42); vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE; add_child(vignette)
	timestamp_label = Label.new(); timestamp_label.position = Vector2(32, 24); timestamp_label.add_theme_font_size_override("font_size", 18); timestamp_label.modulate = Color(0.72, 0.82, 0.78); add_child(timestamp_label)
	signal_label = Label.new(); signal_label.position = Vector2(930, 24); signal_label.size = Vector2(320, 30); signal_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT; signal_label.text = t("signal_ok"); signal_label.modulate = Color(0.65, 0.76, 0.7); add_child(signal_label)

func build_menu() -> void:
	var container := VBoxContainer.new(); container.position = Vector2(78, 125); container.size = Vector2(430, 500); container.add_theme_constant_override("separation", 10); add_child(container)
	var title := Label.new(); title.text = t("title"); title.add_theme_font_size_override("font_size", 55); title.add_theme_color_override("font_color", Color(0.88, 0.92, 0.90)); container.add_child(title)
	var subtitle := Label.new(); subtitle.text = t("subtitle"); subtitle.add_theme_font_size_override("font_size", 14); subtitle.modulate = Color(0.58, 0.68, 0.64); container.add_child(subtitle)
	var spacer := Control.new(); spacer.custom_minimum_size = Vector2(1, 28); container.add_child(spacer)
	add_menu_button(container, t("new_shift"), start_new_game)
	continue_button = add_menu_button(container, t("continue"), continue_game)
	add_menu_button(container, t("settings"), show_settings)
	add_menu_button(container, t("credits"), show_credits)
	add_menu_button(container, t("quit"), quit_game)
	var footer := Label.new(); footer.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT); footer.position = Vector2(-430, -62); footer.size = Vector2(400, 32); footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT; footer.text = t("security_footer"); footer.modulate = Color(0.42, 0.49, 0.46); footer.add_theme_font_size_override("font_size", 12); add_child(footer)

func add_menu_button(parent: VBoxContainer, text: String, callable: Callable) -> Button:
	var button := Button.new(); button.text = text; button.custom_minimum_size = Vector2(360, 48); button.alignment = HORIZONTAL_ALIGNMENT_LEFT; button.add_theme_font_size_override("font_size", 18); button.pressed.connect(callable); parent.add_child(button); return button

func build_settings_panel() -> void:
	settings_panel = PanelContainer.new(); settings_panel.position = Vector2(600, 120); settings_panel.size = Vector2(520, 470); settings_panel.visible = false; add_child(settings_panel)
	var box := VBoxContainer.new(); box.add_theme_constant_override("separation", 14); settings_panel.add_child(box)
	var heading := Label.new(); heading.text = t("system_settings"); heading.add_theme_font_size_override("font_size", 26); box.add_child(heading)
	var volume_label := Label.new(); volume_label.text = t("master_volume"); box.add_child(volume_label)
	master_slider = HSlider.new(); master_slider.min_value = 0; master_slider.max_value = 100; master_slider.step = 1; master_slider.value = 80; master_slider.value_changed.connect(on_volume_changed); box.add_child(master_slider)
	fullscreen_check = CheckBox.new(); fullscreen_check.text = t("fullscreen"); fullscreen_check.toggled.connect(on_fullscreen_toggled); box.add_child(fullscreen_check)
	var language_label := Label.new(); language_label.text = t("language"); box.add_child(language_label)
	language_option = OptionButton.new(); language_option.add_item(t("english"), 0); language_option.add_item(t("russian"), 1); language_option.selected = 1 if current_language == "ru" else 0; language_option.item_selected.connect(on_language_selected); box.add_child(language_option)
	var note := Label.new(); note.text = t("settings_note"); note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; note.custom_minimum_size = Vector2(440, 70); note.modulate = Color(0.62, 0.68, 0.66); box.add_child(note)
	var back := Button.new(); back.text = t("back"); back.custom_minimum_size = Vector2(220, 44); back.pressed.connect(hide_panels); box.add_child(back)

func build_credits_panel() -> void:
	credits_panel = PanelContainer.new(); credits_panel.position = Vector2(600, 145); credits_panel.size = Vector2(520, 420); credits_panel.visible = false; add_child(credits_panel)
	var box := VBoxContainer.new(); box.add_theme_constant_override("separation", 16); credits_panel.add_child(box)
	var heading := Label.new(); heading.text = t("credits"); heading.add_theme_font_size_override("font_size", 26); box.add_child(heading)
	var text := Label.new(); text.text = t("credits_body"); text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; text.custom_minimum_size = Vector2(440, 250); box.add_child(text)
	var back := Button.new(); back.text = t("back"); back.custom_minimum_size = Vector2(220, 44); back.pressed.connect(hide_panels); box.add_child(back)

func start_new_game() -> void:
	var save := ConfigFile.new(); save.set_value("progress", "night", 1); save.set_value("progress", "started", true); save.save("user://save.cfg")
	if FileAccess.file_exists("user://save.json"):
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://save.json"))
	get_tree().change_scene_to_file(GAME_SCENE)

func continue_game() -> void:
	var night: int = _read_progress_night()
	if night >= 3:
		get_tree().change_scene_to_file(NIGHT3_SCENE)
	elif night == 2:
		get_tree().change_scene_to_file(NIGHT2_SCENE)
	else:
		get_tree().change_scene_to_file(GAME_SCENE)

func _read_progress_night() -> int:
	if FileAccess.file_exists("user://save.json"):
		var file := FileAccess.open("user://save.json", FileAccess.READ)
		if file != null:
			var parsed: Variant = JSON.parse_string(file.get_as_text())
			if typeof(parsed) == TYPE_DICTIONARY:
				return int((parsed as Dictionary).get("night", 1))
	if FileAccess.file_exists("user://save.cfg"):
		var cfg := ConfigFile.new()
		if cfg.load("user://save.cfg") == OK:
			return int(cfg.get_value("progress", "night", 1))
	return 1

func update_continue_state() -> void:
	continue_button.disabled = not FileAccess.file_exists("user://save.cfg") and not FileAccess.file_exists("user://save.json")
	continue_button.tooltip_text = t("no_save") if continue_button.disabled else t("resume_save")

func show_settings() -> void: credits_panel.visible = false; settings_panel.visible = true
func show_credits() -> void: settings_panel.visible = false; credits_panel.visible = true
func hide_panels() -> void: settings_panel.visible = false; credits_panel.visible = false
func on_volume_changed(value: float) -> void:
	var bus: int = AudioServer.get_bus_index("Master"); AudioServer.set_bus_volume_db(bus, linear_to_db(max(value / 100.0, 0.001))); save_settings()
func on_fullscreen_toggled(enabled: bool) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED); save_settings()
func on_language_selected(index: int) -> void:
	current_language = "ru" if index == 1 else "en"; LOCALIZATION.set_language(current_language); get_tree().reload_current_scene()
func save_settings() -> void:
	var config := ConfigFile.new(); config.load("user://settings.cfg"); config.set_value("audio", "master_volume", master_slider.value); config.set_value("display", "fullscreen", fullscreen_check.button_pressed); config.set_value("display", "language", current_language); config.save("user://settings.cfg")
func apply_saved_settings() -> void:
	var config := ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		master_slider.value = float(config.get_value("audio", "master_volume", 80.0)); fullscreen_check.button_pressed = bool(config.get_value("display", "fullscreen", false)); on_volume_changed(master_slider.value); DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen_check.button_pressed else DisplayServer.WINDOW_MODE_WINDOWED)
func quit_game() -> void: get_tree().quit()
