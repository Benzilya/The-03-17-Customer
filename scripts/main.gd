extends Node3D

const INTERACTABLE := preload("res://scripts/interactable.gd")
const CUSTOMER := preload("res://scripts/customer.gd")

var message_label: Label
var clock_label: Label
var objective_label: Label
var message_timer: Timer
var shift_minutes := 0.0
var shift_speed := 12.0
var event_flags := {}
var active_customer: Node3D
var decision_panel: PanelContainer
var cctv_status := "No anomalies detected."
var note_read := false

func _ready() -> void:
	add_to_group("game")
	build_environment()
	build_store()
	build_ui()
	show_message("NIGHT 1 — 00:00\nYour first shift at Morrow Market.", 5.0)
	objective_label.text = "OBJECTIVE: Read the manager's note beside the register."

func _process(delta: float) -> void:
	shift_minutes += delta * shift_speed
	var total_minutes := int(shift_minutes) % 360
	var hour := total_minutes / 60
	var minute := total_minutes % 60
	clock_label.text = "%02d:%02d" % [hour, minute]
	run_night_events(total_minutes)

func run_night_events(total_minutes: int) -> void:
	if total_minutes >= 8 and not event_flags.has("customer_1"):
		event_flags["customer_1"] = true
		spawn_customer("Late Driver", false, Color(0.25, 0.34, 0.46), "Coffee. Black. Long road ahead.")

	if total_minutes >= 72 and not event_flags.has("customer_2"):
		event_flags["customer_2"] = true
		spawn_customer("Nurse", false, Color(0.36, 0.42, 0.38), "Just water, please. Night shift too?")

	if total_minutes >= 150 and not event_flags.has("warning"):
		event_flags["warning"] = true
		show_message("02:30\nThe fluorescent lights buzz louder than before.", 4.0)
		cctv_status = "CAM 03 / ENTRANCE\nSignal noise increasing."

	if total_minutes >= 190 and not event_flags.has("pre_317"):
		event_flags["pre_317"] = true
		objective_label.text = "OBJECTIVE: Keep an eye on the entrance and CCTV."
		show_message("03:10\nThe parking lot has gone completely quiet.", 4.0)

	if total_minutes >= 197 and not event_flags.has("customer_317"):
		event_flags["customer_317"] = true
		clock_label.text = "03:17"
		spawn_317_customer()

func spawn_customer(customer_name: String, anomalous: bool, body_color: Color, line: String) -> void:
	if active_customer and is_instance_valid(active_customer):
		active_customer.queue_free()
	active_customer = CUSTOMER.new()
	add_child(active_customer)
	active_customer.global_position = Vector3(0, 0, -9.5)
	active_customer.setup(customer_name, anomalous, body_color)
	await active_customer.walk_to(Vector3(3.4, 0, -2.8), 2.2)
	show_message(customer_name + ": \"" + line + "\"\n\nThe transaction completes normally.", 5.0)
	await get_tree().create_timer(4.0).timeout
	if active_customer and is_instance_valid(active_customer):
		await active_customer.walk_to(Vector3(0, 0, -9.5), 2.0)
		active_customer.queue_free()

func spawn_317_customer() -> void:
	if active_customer and is_instance_valid(active_customer):
		active_customer.queue_free()
	active_customer = CUSTOMER.new()
	add_child(active_customer)
	active_customer.global_position = Vector3(0, 0, -9.5)
	active_customer.setup("Unknown Customer", true, Color(0.12, 0.13, 0.15))
	cctv_status = "CAM 01 / REGISTER: MOVEMENT DETECTED\nCAM 03 / ENTRANCE: EMPTY\n\nWARNING: CAMERA MISMATCH"
	show_message("03:17\nThe entrance chime rings.\nThe CCTV feed shows no one entering.", 5.0)
	await active_customer.walk_to(Vector3(3.4, 0, -2.8), 3.0)
	objective_label.text = "OBJECTIVE: Decide whether to serve the 03:17 customer."
	show_message("Unknown Customer: \"Long night?\"\n\nHe places a bottle of water on the counter.", 5.0)
	await get_tree().create_timer(2.0).timeout
	show_decision()

func show_decision() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	decision_panel.visible = true

func resolve_decision(served: bool) -> void:
	decision_panel.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if served:
		show_message("BEEP.\n\nThe receipt prints by itself:\nTHANK YOU, ALEX.", 7.0)
		objective_label.text = "NIGHT 1 RESULT: You served the 03:17 customer."
		cctv_status = "CAM 01 / REGISTER\nCUSTOMER: NOT DETECTED\nCASHIER: DETECTED"
	else:
		show_message("You refuse the sale.\n\nThe customer stares at you for several seconds... then leaves without the bottle.", 7.0)
		objective_label.text = "NIGHT 1 RESULT: You followed the rule."
		cctv_status = "CAM 03 / ENTRANCE\nNo person detected. Door opened at 03:17."
	if active_customer and is_instance_valid(active_customer):
		active_customer.queue_free()
	await get_tree().create_timer(7.0).timeout
	show_message("NIGHT 1 COMPLETE\nSomething is wrong with Morrow Market.", 6.0)
	write_night_one_save(served)

func write_night_one_save(served: bool) -> void:
	var file := FileAccess.open("user://save.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"night": 2, "night_1_served_0317": served}))

func build_environment() -> void:
	var world_environment := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.006, 0.008, 0.012)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.18, 0.21, 0.26)
	environment.ambient_light_energy = 0.55
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world_environment.environment = environment
	add_child(world_environment)

	var moon := DirectionalLight3D.new()
	moon.rotation_degrees = Vector3(-55, -25, 0)
	moon.light_color = Color(0.45, 0.55, 0.75)
	moon.light_energy = 0.25
	moon.shadow_enabled = true
	add_child(moon)

func build_store() -> void:
	make_box("Floor", Vector3(18, 0.2, 14), Vector3(0, -0.1, 0), Color(0.18, 0.19, 0.20))
	make_box("Ceiling", Vector3(18, 0.2, 14), Vector3(0, 4.2, 0), Color(0.12, 0.13, 0.14))
	make_box("BackWall", Vector3(18, 4.2, 0.25), Vector3(0, 2.1, 7), Color(0.28, 0.29, 0.30))
	make_box("LeftWall", Vector3(0.25, 4.2, 14), Vector3(-9, 2.1, 0), Color(0.26, 0.27, 0.28))
	make_box("RightWall", Vector3(0.25, 4.2, 14), Vector3(9, 2.1, 0), Color(0.26, 0.27, 0.28))
	make_box("FrontWallL", Vector3(7.0, 4.2, 0.25), Vector3(-5.5, 2.1, -7), Color(0.20, 0.22, 0.23))
	make_box("FrontWallR", Vector3(7.0, 4.2, 0.25), Vector3(5.5, 2.1, -7), Color(0.20, 0.22, 0.23))
	make_box("DoorHeader", Vector3(4.0, 0.9, 0.25), Vector3(0, 3.75, -7), Color(0.20, 0.22, 0.23))

	make_interactable_box("Register", Vector3(4.2, 1.05, 1.25), Vector3(4.6, 0.525, -3.8), Color(0.13, 0.20, 0.18), "REGISTER 01\nTerminal online. Shift begins at 00:00.")
	make_box("RegisterTop", Vector3(4.35, 0.08, 1.38), Vector3(4.6, 1.09, -3.8), Color(0.08, 0.09, 0.09))

	var note := make_interactable_box("ManagerNote", Vector3(0.55, 0.035, 0.75), Vector3(3.6, 1.15, -3.55), Color(0.74, 0.70, 0.52), "MANAGER'S NOTE\n\nDo the normal closing tasks.\nLock the stockroom after 02:00.\nIf the cameras cut out, stay inside.\n\nIf a customer arrives at 03:17 — DO NOT SERVE THEM.")
	note.set_meta("manager_note", true)

	for z in [-1.2, 1.2, 3.6]:
		make_box("Shelf_%s" % z, Vector3(6.0, 1.8, 0.65), Vector3(-1.8, 0.9, z), Color(0.34, 0.31, 0.25))
		make_box("ShelfTop_%s" % z, Vector3(6.1, 0.08, 0.72), Vector3(-1.8, 1.84, z), Color(0.10, 0.11, 0.11))

	for i in range(5):
		var x := -6.5 + i * 2.15
		make_box("Fridge_%d" % i, Vector3(1.9, 3.0, 0.65), Vector3(x, 1.5, 6.55), Color(0.12, 0.18, 0.20))
		var fridge_light := OmniLight3D.new()
		fridge_light.position = Vector3(x, 2.0, 5.8)
		fridge_light.light_color = Color(0.65, 0.82, 1.0)
		fridge_light.light_energy = 1.2
		fridge_light.omni_range = 4.5
		add_child(fridge_light)

	make_interactable_box("CCTV", Vector3(1.15, 0.75, 0.6), Vector3(6.8, 1.45, -3.75), Color(0.04, 0.05, 0.055), "CCTV_DYNAMIC")

	for x in [-5.5, 0.0, 5.5]:
		for z in [-3.5, 1.0, 5.0]:
			var light := OmniLight3D.new()
			light.position = Vector3(x, 3.7, z)
			light.light_color = Color(0.76, 0.84, 0.90)
			light.light_energy = 2.0
			light.omni_range = 5.5
			light.shadow_enabled = true
			add_child(light)
			make_box("Fixture", Vector3(2.0, 0.05, 0.25), Vector3(x, 4.0, z), Color(0.85, 0.88, 0.88), false)

	make_box("Parking", Vector3(28, 0.15, 16), Vector3(0, -0.12, -14.8), Color(0.025, 0.028, 0.032))

func make_box(node_name: String, size: Vector3, position: Vector3, color: Color, collision := true) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = node_name
	body.position = position
	add_child(body)
	var mesh_instance := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.72
	box_mesh.material = material
	mesh_instance.mesh = box_mesh
	body.add_child(mesh_instance)
	if collision:
		var collision_shape := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		collision_shape.shape = shape
		body.add_child(collision_shape)
	return body

func make_interactable_box(node_name: String, size: Vector3, position: Vector3, color: Color, text: String) -> StaticBody3D:
	var body := make_box(node_name, size, position, color, true)
	body.set_script(INTERACTABLE)
	body.set("message", text)
	return body

func build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	clock_label = Label.new()
	clock_label.position = Vector2(28, 22)
	clock_label.add_theme_font_size_override("font_size", 30)
	clock_label.text = "00:00"
	layer.add_child(clock_label)

	var title := Label.new()
	title.position = Vector2(28, 58)
	title.text = "MORROW MARKET — NIGHT 1"
	title.modulate = Color(0.72, 0.78, 0.82)
	layer.add_child(title)

	objective_label = Label.new()
	objective_label.position = Vector2(28, 90)
	objective_label.size = Vector2(740, 50)
	objective_label.modulate = Color(0.82, 0.79, 0.63)
	layer.add_child(objective_label)

	var crosshair := Label.new()
	crosshair.set_anchors_preset(Control.PRESET_CENTER)
	crosshair.position = Vector2(-4, -10)
	crosshair.text = "+"
	crosshair.add_theme_font_size_override("font_size", 20)
	layer.add_child(crosshair)

	var controls := Label.new()
	controls.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	controls.position = Vector2(28, -72)
	controls.text = "WASD — move    Mouse — look    E — interact    Esc — release mouse"
	controls.modulate = Color(0.62, 0.66, 0.70)
	layer.add_child(controls)

	message_label = Label.new()
	message_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	message_label.position = Vector2(-300, -180)
	message_label.size = Vector2(600, 130)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.add_theme_font_size_override("font_size", 18)
	message_label.visible = false
	layer.add_child(message_label)

	message_timer = Timer.new()
	message_timer.one_shot = true
	message_timer.wait_time = 4.0
	message_timer.timeout.connect(func(): message_label.visible = false)
	add_child(message_timer)

	decision_panel = PanelContainer.new()
	decision_panel.set_anchors_preset(Control.PRESET_CENTER)
	decision_panel.position = Vector2(-220, -100)
	decision_panel.size = Vector2(440, 200)
	decision_panel.visible = false
	layer.add_child(decision_panel)
	var decision_box := VBoxContainer.new()
	decision_panel.add_child(decision_box)
	var prompt := Label.new()
	prompt.text = "03:17 CUSTOMER\nThe cameras say nobody is there."
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.add_theme_font_size_override("font_size", 21)
	decision_box.add_child(prompt)
	var serve := Button.new()
	serve.text = "SERVE CUSTOMER"
	serve.pressed.connect(func(): resolve_decision(true))
	decision_box.add_child(serve)
	var refuse := Button.new()
	refuse.text = "REFUSE SERVICE"
	refuse.pressed.connect(func(): resolve_decision(false))
	decision_box.add_child(refuse)

func show_message(text: String, seconds := 4.0) -> void:
	if text == "CCTV_DYNAMIC":
		text = cctv_status
	message_label.text = text
	message_label.visible = true
	message_timer.wait_time = seconds
	message_timer.start()

func on_interaction(body: Node) -> void:
	if body.has_meta("manager_note") and not note_read:
		note_read = true
		objective_label.text = "OBJECTIVE: Work the shift. Check CCTV if anything feels wrong."
