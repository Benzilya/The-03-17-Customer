extends Control

const GAME_SCENE := "res://scenes/main.tscn"

var timestamp_label: Label
var signal_label: Label
var continue_button: Button
var settings_panel: PanelContainer
var credits_panel: PanelContainer
var master_slider: HSlider
var fullscreen_check: CheckBox
var vignette: ColorRect
var glitch_timer := 0.0
var fake_seconds := 52.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
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
	var display_second := int(fake_seconds)
	timestamp_label.text = "CAM 05 / PARKING LOT     03:16:%02d" % display_second

	glitch_timer -= delta
	if glitch_timer <= 0.0:
		glitch_timer = randf_range(1.8, 5.2)
		signal_label.visible = true
		signal_label.text = ["SIGNAL OK", "TRACKING...", "NO MOTION", "03:17 EVENT PENDING"][randi() % 4]
		var tween := create_tween()
		tween.tween_property(vignette, "color:a", randf_range(0.35, 0.62), 0.05)
		tween.tween_property(vignette, "color:a", 0.42, 0.12)

func build_background() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.018, 0.026, 0.03)
	add_child(bg)

	# Stylized CCTV view: wet parking lot, glowing store window, distant silhouette.
	var lot := ColorRect.new()
	lot.position = Vector2(0, 420)
	lot.size = Vector2(1280, 300)
	lot.color = Color(0.025, 0.032, 0.035)
	add_child(lot)

	var store := ColorRect.new()
	store.position = Vector2(650, 165)
	store.size = Vector2(520, 330)
	store.color = Color(0.08, 0.105, 0.11)
	add_child(store)

	var window := ColorRect.new()
	window.position = Vector2(690, 235)
	window.size = Vector2(440, 185)
	window.color = Color(0.52, 0.66, 0.64, 0.68)
	add_child(window)

	for i in range(8):
		var stripe := ColorRect.new()
		stripe.position = Vector2(705 + i * 53, 245)
		stripe.size = Vector2(2, 165)
		stripe.color = Color(0.12, 0.16, 0.16, 0.45)
		add_child(stripe)

	var silhouette := ColorRect.new()
	silhouette.position = Vector2(900, 365)
	silhouette.size = Vector2(18, 58)
	silhouette.color = Color(0.005, 0.006, 0.006, 0.92)
	add_child(silhouette)

	for y in range(0, 720, 4):
		var scanline := ColorRect.new()
		scanline.position = Vector2(0, y)
		scanline.size = Vector2(1280, 1)
		scanline.color = Color(0, 0, 0, 0.10)
		scanline.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(scanline)

	vignette = ColorRect.new()
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.color = Color(0, 0, 0, 0.42)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vignette)

	timestamp_label = Label.new()
	timestamp_label.position = Vector2(32, 24)
	timestamp_label.text = "CAM 05 / PARKING LOT     03:16:52"
	timestamp_label.add_theme_font_size_override("font_size", 18)
	timestamp_label.modulate = Color(0.72, 0.82, 0.78)
	add_child(timestamp_label)

	signal_label = Label.new()
	signal_label.position = Vector2(1030, 24)
	signal_label.size = Vector2(220, 30)
	signal_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	signal_label.text = "SIGNAL OK"
	signal_label.modulate = Color(0.65, 0.76, 0.7)
	add_child(signal_label)

func build_menu() -> void:
	var container := VBoxContainer.new()
	container.position = Vector2(78, 125)
	container.size = Vector2(430, 500)
	container.add_theme_constant_override("separation", 10)
	add_child(container)

	var title := Label.new()
	title.text = "THE 03:17\nCUSTOMER"
	title.add_theme_font_size_override("font_size", 55)
	title.add_theme_color_override("font_color", Color(0.88, 0.92, 0.90))
	container.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "EVERY CUSTOMER LOOKS HUMAN.\nNOT EVERY CUSTOMER IS."
	subtitle.add_theme_font_size_override("font_size", 14)
	subtitle.modulate = Color(0.58, 0.68, 0.64)
	container.add_child(subtitle)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(1, 28)
	container.add_child(spacer)

	add_menu_button(container, "NEW SHIFT", start_new_game)
	continue_button = add_menu_button(container, "CONTINUE", continue_game)
	add_menu_button(container, "SETTINGS", show_settings)
	add_menu_button(container, "CREDITS", show_credits)
	add_menu_button(container, "QUIT", quit_game)

	var footer := Label.new()
	footer.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	footer.position = Vector2(-330, -62)
	footer.size = Vector2(300, 32)
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	footer.text = "MORROW MARKET SECURITY SYSTEM / BUILD 0.1"
	footer.modulate = Color(0.42, 0.49, 0.46)
	footer.add_theme_font_size_override("font_size", 12)
	add_child(footer)

func add_menu_button(parent: VBoxContainer, text: String, callable: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(360, 48)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_font_size_override("font_size", 18)
	button.pressed.connect(callable)
	parent.add_child(button)
	return button

func build_settings_panel() -> void:
	settings_panel = PanelContainer.new()
	settings_panel.position = Vector2(600, 145)
	settings_panel.size = Vector2(520, 420)
	settings_panel.visible = false
	add_child(settings_panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	settings_panel.add_child(box)

	var heading := Label.new()
	heading.text = "SYSTEM SETTINGS"
	heading.add_theme_font_size_override("font_size", 26)
	box.add_child(heading)

	var volume_label := Label.new()
	volume_label.text = "MASTER VOLUME"
	box.add_child(volume_label)

	master_slider = HSlider.new()
	master_slider.min_value = 0
	master_slider.max_value = 100
	master_slider.step = 1
	master_slider.value = 80
	master_slider.value_changed.connect(on_volume_changed)
	box.add_child(master_slider)

	fullscreen_check = CheckBox.new()
	fullscreen_check.text = "FULLSCREEN"
	fullscreen_check.toggled.connect(on_fullscreen_toggled)
	box.add_child(fullscreen_check)

	var note := Label.new()
	note.text = "More graphics, controls and accessibility settings will be added as the vertical slice grows."
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.custom_minimum_size = Vector2(440, 80)
	note.modulate = Color(0.62, 0.68, 0.66)
	box.add_child(note)

	var back := Button.new()
	back.text = "BACK"
	back.custom_minimum_size = Vector2(220, 44)
	back.pressed.connect(hide_panels)
	box.add_child(back)

func build_credits_panel() -> void:
	credits_panel = PanelContainer.new()
	credits_panel.position = Vector2(600, 145)
	credits_panel.size = Vector2(520, 420)
	credits_panel.visible = false
	add_child(credits_panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	credits_panel.add_child(box)

	var heading := Label.new()
	heading.text = "CREDITS"
	heading.add_theme_font_size_override("font_size", 26)
	box.add_child(heading)

	var text := Label.new()
	text.text = "THE 03:17 CUSTOMER\n\nCreated by Benzilya\n\nPrototype development\nOpenAI / ChatGPT collaboration\n\nEngine\nGodot 4\n\nAll art and audio used in release builds will be original, licensed, or properly attributed."
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.custom_minimum_size = Vector2(440, 250)
	box.add_child(text)

	var back := Button.new()
	back.text = "BACK"
	back.custom_minimum_size = Vector2(220, 44)
	back.pressed.connect(hide_panels)
	box.add_child(back)

func start_new_game() -> void:
	var save := ConfigFile.new()
	save.set_value("progress", "night", 1)
	save.set_value("progress", "started", true)
	save.save("user://save.cfg")
	get_tree().change_scene_to_file(GAME_SCENE)

func continue_game() -> void:
	if FileAccess.file_exists("user://save.cfg"):
		get_tree().change_scene_to_file(GAME_SCENE)

func update_continue_state() -> void:
	continue_button.disabled = not FileAccess.file_exists("user://save.cfg")
	continue_button.tooltip_text = "No saved shift found." if continue_button.disabled else "Resume your last shift."

func show_settings() -> void:
	credits_panel.visible = false
	settings_panel.visible = true

func show_credits() -> void:
	settings_panel.visible = false
	credits_panel.visible = true

func hide_panels() -> void:
	settings_panel.visible = false
	credits_panel.visible = false

func on_volume_changed(value: float) -> void:
	var bus := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus, linear_to_db(max(value / 100.0, 0.001)))
	save_settings()

func on_fullscreen_toggled(enabled: bool) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED)
	save_settings()

func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "master_volume", master_slider.value)
	config.set_value("display", "fullscreen", fullscreen_check.button_pressed)
	config.save("user://settings.cfg")

func apply_saved_settings() -> void:
	var config := ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		master_slider.value = float(config.get_value("audio", "master_volume", 80.0))
		fullscreen_check.button_pressed = bool(config.get_value("display", "fullscreen", false))
		on_volume_changed(master_slider.value)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen_check.button_pressed else DisplayServer.WINDOW_MODE_WINDOWED)

func quit_game() -> void:
	get_tree().quit()
