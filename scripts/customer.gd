extends Node3D

var display_name := "Customer"
var anomalous := false
var color := Color(0.45, 0.48, 0.52)

func setup(customer_name: String, is_anomalous: bool, body_color: Color) -> void:
	display_name = customer_name
	anomalous = is_anomalous
	color = body_color
	_build_body()

func _build_body() -> void:
	var body := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.38
	capsule.height = 1.35
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.82
	capsule.material = mat
	body.mesh = capsule
	body.position.y = 0.95
	add_child(body)

	var head := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.28
	sphere.height = 0.56
	var skin := StandardMaterial3D.new()
	skin.albedo_color = Color(0.62, 0.52, 0.46) if not anomalous else Color(0.55, 0.56, 0.55)
	skin.roughness = 0.9
	sphere.material = skin
	head.mesh = sphere
	head.position.y = 1.85
	add_child(head)

	var shadow := Decal.new()
	shadow.size = Vector3(1.2, 1.2, 1.2)

func walk_to(target: Vector3, duration := 2.5) -> Signal:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position", target, duration)
	return tween.finished
