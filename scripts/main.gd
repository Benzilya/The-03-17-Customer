extends Node3D

const INTERACTABLE := preload("res://scripts/interactable.gd")

var message_label: Label
var clock_label: Label
var message_timer: Timer
var shift_minutes := 0.0
var shift_speed := 1.5

func _ready() -> void:
	add_to_group("game")
	build_environment()
	build_store()
	build_ui()

func _process(delta: float) -> void:
	shift_minutes += delta * shift_speed
	var total_minutes := int(shift_minutes) % 360
	var hour := total_minutes / 60
	var minute := total_minutes % 60
	clock_label.text = "%02d:%02d" % [hour, minute]
	if hour == 3 and minute == 17:
		clock_label.text = "03:17"

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

	# Front wall leaves a central opening suggesting the glass entrance.
	make_box("FrontWallL", Vector3(7.0, 4.2, 0.25), Vector3(-5.5, 2.1, -7), Color(0.20, 0.22, 0.23))
	make_box("FrontWallR", Vector3(7.0, 4.2, 0.25), Vector3(5.5, 2.1, -7), Color(0.20, 0.22, 0.23))
	make_box("DoorHeader", Vector3(4.0, 0.9, 0.25), Vector3(0, 3.75, -7), Color(0.20, 0.22, 0.23))

	# Register counter.
	make_interactable_box(
		"Register",
		Vector3(4.2, 1.05, 1.25),
		Vector3(4.6, 0.525, -3.8),
		Color(0.13, 0.20, 0.18),
		"REGISTER 01\nTerminal online. Shift begins at 00:00."
	)
	make_box("RegisterTop", Vector3(4.35, 0.08, 1.38), Vector3(4.6, 1.09, -3.8), Color(0.08, 0.09, 0.09))

	# Shelves create three narrow retail aisles.
	for z in [-1.2, 1.2, 3.6]:
		make_box("Shelf_%s" % z, Vector3(6.0, 1.8, 0.65), Vector3(-1.8, 0.9, z), Color(0.34, 0.31, 0.25))
		make_box("ShelfTop_%s" % z, Vector3(6.1, 0.08, 0.72), Vector3(-1.8, 1.84, z), Color(0.10, 0.11, 0.11))

	# Refrigerated wall.
	for i in range(5):
		var x := -6.5 + i * 2.15
		make_box("Fridge_%d" % i, Vector3(1.9, 3.0, 0.65), Vector3(x, 1.5, 6.55), Color(0.12, 0.18, 0.20))
		var fridge_light := OmniLight3D.new()
		fridge_light.position = Vector3(x, 2.0, 5.8)
		fridge_light.light_color = Color(0.65, 0.82, 1.0)
		fridge_light.light_energy = 1.2
		fridge_light.omni_range = 4.5
		add_child(fridge_light)

	# CCTV terminal prototype.
	make_interactable_box(
		"CCTV",
		Vector3(1.15, 0.75, 0.6),
		Vector3(6.8, 1.45, -3.75),
		Color(0.04, 0.05, 0.055),
		"CAM 01 / REGISTER\nCAM 02 / AISLES\nCAM 03 / ENTRANCE\nCAM 04 / STOCKROOM\n\nNo anomalies detected."
	)

	# Fluorescent fixtures.
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

	# Exterior parking surface visible through the entrance.
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
	title.text = "MORROW MARKET — NIGHT SHIFT"
	title.modulate = Color(0.72, 0.78, 0.82)
	layer.add_child(title)

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
	message_label.position = Vector2(-260, -145)
	message_label.size = Vector2(520, 100)
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

func show_message(text: String) -> void:
	message_label.text = text
	message_label.visible = true
	message_timer.start()
