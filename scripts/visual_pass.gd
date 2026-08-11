extends Node

var game: Node3D
var cctv_viewport: SubViewport
var cctv_texture: TextureRect
var cctv_camera: Camera3D
var camera_transforms := {
	1: {"position": Vector3(7.7, 3.55, -1.7), "target": Vector3(3.6, 1.0, -3.0)},
	2: {"position": Vector3(-7.8, 3.65, 4.8), "target": Vector3(-1.5, 1.0, 1.2)},
	3: {"position": Vector3(0.0, 3.8, -5.8), "target": Vector3(0.0, 1.0, -12.0)},
	4: {"position": Vector3(7.8, 3.5, 5.8), "target": Vector3(4.5, 1.0, 4.4)}
}
var last_camera := -1

func _ready() -> void:
	call_deferred("_initialize")

func _process(_delta: float) -> void:
	if not game or not is_instance_valid(game):
		return
	var selected = game.get("cctv_camera")
	if typeof(selected) == TYPE_INT and selected != last_camera:
		last_camera = selected
		_apply_cctv_camera(selected)

func _initialize() -> void:
	game = get_parent() as Node3D
	if not game:
		return
	_build_facade()
	_build_parking_details()
	_build_store_details()
	_build_rendered_cctv()

func _build_facade() -> void:
	# Glass storefront fills the previously open entrance while preserving a central doorway.
	_make_glass_panel("FrontGlassLeft", Vector3(6.6, 3.0, 0.045), Vector3(-5.6, 1.7, -6.83))
	_make_glass_panel("FrontGlassRight", Vector3(6.6, 3.0, 0.045), Vector3(5.6, 1.7, -6.83))
	_make_glass_panel("EntryDoorLeft", Vector3(1.72, 2.75, 0.04), Vector3(-0.9, 1.55, -6.80))
	_make_glass_panel("EntryDoorRight", Vector3(1.72, 2.75, 0.04), Vector3(0.9, 1.55, -6.80))

	# Metal frames around the glass make the front read as a real convenience-store facade.
	for x in [-8.75, -2.25, -1.78, 0.0, 1.78, 2.25, 8.75]:
		_make_box("FacadeFrame", Vector3(0.09, 3.25, 0.11), Vector3(x, 1.65, -6.76), Color(0.055, 0.065, 0.07), false)
	_make_box("FacadeSill", Vector3(17.6, 0.10, 0.13), Vector3(0, 0.14, -6.75), Color(0.055, 0.065, 0.07), false)

	# Backlit brand sign.
	_make_box("SignHousing", Vector3(7.0, 0.92, 0.20), Vector3(0, 3.55, -7.02), Color(0.035, 0.10, 0.085), false)
	var sign := Label3D.new()
	sign.text = "MORROW MARKET"
	sign.position = Vector3(0, 3.55, -7.14)
	sign.rotation_degrees.y = 180.0
	sign.font_size = 72
	sign.modulate = Color(0.72, 1.0, 0.88)
	sign.outline_size = 8
	sign.outline_modulate = Color(0.02, 0.06, 0.05)
	game.add_child(sign)

	var sign_light := OmniLight3D.new()
	sign_light.position = Vector3(0, 3.35, -8.0)
	sign_light.light_color = Color(0.42, 0.95, 0.72)
	sign_light.light_energy = 2.0
	sign_light.omni_range = 6.0
	game.add_child(sign_light)

	var hours := Label3D.new()
	hours.text = "OPEN 24 HOURS"
	hours.position = Vector3(5.7, 2.6, -6.93)
	hours.rotation_degrees.y = 180.0
	hours.font_size = 38
	hours.modulate = Color(1.0, 0.35, 0.28)
	game.add_child(hours)

func _build_parking_details() -> void:
	# Concrete curb and parking-stop silhouettes add depth outside the windows.
	_make_box("Curb", Vector3(18.0, 0.22, 0.55), Vector3(0, 0.02, -7.45), Color(0.16, 0.17, 0.17), false)
	for x in [-6.2, -2.1, 2.1, 6.2]:
		_make_box("ParkingStop", Vector3(2.2, 0.18, 0.32), Vector3(x, 0.03, -13.2), Color(0.22, 0.23, 0.22), false)
		_make_box("ParkingStripe", Vector3(0.10, 0.025, 5.0), Vector3(x + 1.4, -0.02, -13.8), Color(0.58, 0.55, 0.39), false)

	# Bollards protecting the storefront.
	for x in [-2.8, 2.8]:
		var bollard := MeshInstance3D.new()
		var cylinder := CylinderMesh.new()
		cylinder.top_radius = 0.12
		cylinder.bottom_radius = 0.12
		cylinder.height = 1.05
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.60, 0.48, 0.10)
		mat.roughness = 0.75
		cylinder.material = mat
		bollard.mesh = cylinder
		bollard.position = Vector3(x, 0.52, -7.75)
		game.add_child(bollard)

	# Two exterior sodium-like lamps keep the lot readable but still isolated.
	for x in [-6.0, 6.0]:
		var lamp := OmniLight3D.new()
		lamp.position = Vector3(x, 3.1, -9.0)
		lamp.light_color = Color(1.0, 0.72, 0.42)
		lamp.light_energy = 1.45
		lamp.omni_range = 7.0
		lamp.shadow_enabled = true
		game.add_child(lamp)

	# A lonely trash bin near the entrance.
	_make_box("ExteriorBin", Vector3(0.72, 0.95, 0.72), Vector3(-7.7, 0.47, -8.0), Color(0.07, 0.09, 0.085), false)
	_make_box("ExteriorBinLid", Vector3(0.82, 0.12, 0.82), Vector3(-7.7, 0.99, -8.0), Color(0.04, 0.05, 0.05), false)

func _build_store_details() -> void:
	# Register monitor, receipt printer and counter clutter.
	_make_box("RegisterMonitorStand", Vector3(0.10, 0.38, 0.10), Vector3(5.15, 1.34, -3.78), Color(0.05, 0.055, 0.06), false)
	_make_box("RegisterMonitor", Vector3(0.82, 0.50, 0.12), Vector3(5.15, 1.64, -3.78), Color(0.025, 0.045, 0.05), false)
	_make_box("ReceiptPrinter", Vector3(0.48, 0.28, 0.42), Vector3(5.85, 1.27, -3.62), Color(0.14, 0.15, 0.15), false)
	_make_box("CardTerminal", Vector3(0.28, 0.12, 0.46), Vector3(3.3, 1.22, -3.62), Color(0.04, 0.07, 0.075), false)

	# Product rows make shelves look stocked from a distance, without external assets yet.
	var product_colors := [
		Color(0.62, 0.16, 0.12), Color(0.16, 0.34, 0.58), Color(0.72, 0.50, 0.12),
		Color(0.20, 0.46, 0.26), Color(0.52, 0.19, 0.47), Color(0.78, 0.72, 0.55)
	]
	for z in [-1.2, 1.2, 3.6]:
		for row in range(2):
			for i in range(7):
				var h := 0.34 + float((i + row) % 3) * 0.08
				_make_box(
					"ShelfProductDetail",
					Vector3(0.36, h, 0.24),
					Vector3(-4.3 + i * 0.78, 0.45 + row * 0.78, z + 0.34),
					product_colors[(i + row) % product_colors.size()],
					false
				)

	# Ceiling security domes indicate physical CCTV camera positions.
	for p in [Vector3(7.5, 3.85, -1.5), Vector3(-7.4, 3.85, 4.7), Vector3(0, 3.9, -5.7), Vector3(7.3, 3.85, 5.6)]:
		var dome := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = 0.18
		sphere.height = 0.26
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.035, 0.04, 0.045)
		mat.metallic = 0.35
		mat.roughness = 0.28
		sphere.material = mat
		dome.mesh = sphere
		dome.position = p
		game.add_child(dome)

func _build_rendered_cctv() -> void:
	var overlay = game.get("cctv_overlay")
	if not overlay or not is_instance_valid(overlay):
		return

	cctv_viewport = SubViewport.new()
	cctv_viewport.name = "RenderedCCTVViewport"
	cctv_viewport.size = Vector2i(960, 540)
	cctv_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	cctv_viewport.transparent_bg = false
	cctv_viewport.world_3d = game.get_viewport().world_3d
	game.add_child(cctv_viewport)

	cctv_camera = Camera3D.new()
	cctv_camera.fov = 72.0
	cctv_camera.current = true
	cctv_viewport.add_child(cctv_camera)
	_apply_cctv_camera(1)

	cctv_texture = TextureRect.new()
	cctv_texture.name = "RenderedFeed"
	cctv_texture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cctv_texture.offset_left = 58
	cctv_texture.offset_top = 82
	cctv_texture.offset_right = -58
	cctv_texture.offset_bottom = -118
	cctv_texture.texture = cctv_viewport.get_texture()
	cctv_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cctv_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	cctv_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(cctv_texture)
	overlay.move_child(cctv_texture, 0)

	# Dark translucent monitor glass keeps the feed feeling like old security hardware.
	var tint := ColorRect.new()
	tint.name = "CCTVGlassTint"
	tint.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tint.color = Color(0.06, 0.18, 0.11, 0.16)
	tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cctv_texture.add_child(tint)

	var feed_label = game.get("cctv_feed_label")
	if feed_label and is_instance_valid(feed_label):
		feed_label.position = Vector2(-300, 160)
		feed_label.size = Vector2(600, 95)
		feed_label.add_theme_font_size_override("font_size", 18)

func _apply_cctv_camera(index: int) -> void:
	if not cctv_camera or not camera_transforms.has(index):
		return
	var config: Dictionary = camera_transforms[index]
	cctv_camera.global_position = config["position"]
	cctv_camera.look_at(config["target"], Vector3.UP)

func _make_glass_panel(node_name: String, size: Vector3, position: Vector3) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	var box := BoxMesh.new()
	box.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.18, 0.30, 0.34, 0.28)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.roughness = 0.18
	mat.metallic = 0.05
	box.material = mat
	mesh_instance.mesh = box
	mesh_instance.position = position
	game.add_child(mesh_instance)

func _make_box(node_name: String, size: Vector3, position: Vector3, color: Color, collision := false) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = node_name
	body.position = position
	game.add_child(body)
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
