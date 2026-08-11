extends Node

var game: Node3D
var counter_items: Array[Node3D] = []
var last_signature := ""
var last_scanned := -1

func _ready() -> void:
	call_deferred("_initialize")

func _initialize() -> void:
	game = get_parent() as Node3D

func _process(_delta: float) -> void:
	if not game or not is_instance_valid(game):
		return
	var items = game.get("current_items")
	var scanned = game.get("scanned_count")
	if typeof(items) != TYPE_ARRAY or typeof(scanned) != TYPE_INT:
		return
	var signature := str(items)
	if signature != last_signature:
		last_signature = signature
		last_scanned = -1
		_rebuild_items(items)
	if scanned != last_scanned:
		last_scanned = scanned
		_update_scanned_state(scanned)

func _rebuild_items(items: Array) -> void:
	for item in counter_items:
		if is_instance_valid(item):
			item.queue_free()
	counter_items.clear()
	if items.is_empty():
		return
	for i in range(items.size()):
		var item_data = items[i]
		var visual := _make_item(str(item_data.get("name", "Item")), i)
		visual.position = Vector3(3.35 + i * 0.36, 1.22, -3.24)
		game.add_child(visual)
		counter_items.append(visual)

func _make_item(item_name: String, index: int) -> Node3D:
	var root := Node3D.new()
	root.name = "CheckoutItem_%d" % index
	var lower := item_name.to_lower()
	if "water" in lower:
		var body := MeshInstance3D.new()
		var cylinder := CylinderMesh.new()
		cylinder.top_radius = 0.075
		cylinder.bottom_radius = 0.09
		cylinder.height = 0.30
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.22, 0.52, 0.68, 0.52)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.roughness = 0.16
		cylinder.material = mat
		body.mesh = cylinder
		body.position.y = 0.15
		root.add_child(body)
	elif "coffee" in lower:
		var cup := MeshInstance3D.new()
		var cylinder := CylinderMesh.new()
		cylinder.top_radius = 0.11
		cylinder.bottom_radius = 0.09
		cylinder.height = 0.24
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.20, 0.12, 0.08)
		mat.roughness = 0.72
		cylinder.material = mat
		cup.mesh = cylinder
		cup.position.y = 0.12
		root.add_child(cup)
	else:
		var box := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.22, 0.30, 0.12)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.58, 0.20 + index * 0.08, 0.12)
		mat.roughness = 0.64
		mesh.material = mat
		box.mesh = mesh
		box.position.y = 0.15
		root.add_child(box)
	var label := Label3D.new()
	label.text = item_name.to_upper()
	label.font_size = 16
	label.position = Vector3(0, 0.38, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = Color(0.85, 0.88, 0.88)
	root.add_child(label)
	return root

func _update_scanned_state(scanned: int) -> void:
	for i in range(counter_items.size()):
		var item := counter_items[i]
		if not is_instance_valid(item):
			continue
		var target_x := 4.35 + i * 0.20 if i < scanned else 3.35 + i * 0.36
		var target_z := -3.47 if i < scanned else -3.24
		var tween := create_tween().set_parallel(true)
		tween.tween_property(item, "position:x", target_x, 0.20).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(item, "position:z", target_z, 0.20).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		if i < scanned:
			tween.tween_property(item, "rotation:y", deg_to_rad(8.0), 0.20)
