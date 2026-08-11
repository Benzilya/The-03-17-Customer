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
	var torso := MeshInstance3D.new()
	var torso_mesh := CapsuleMesh.new()
	torso_mesh.radius = 0.36
	torso_mesh.height = 1.28
	var clothes := StandardMaterial3D.new()
	clothes.albedo_color = color
	clothes.roughness = 0.8
	torso_mesh.material = clothes
	torso.mesh = torso_mesh
	torso.position.y = 1.0
	add_child(torso)

	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.275
	head_mesh.height = 0.55
	var skin := StandardMaterial3D.new()
	skin.albedo_color = Color(0.64, 0.53, 0.46) if not anomalous else Color(0.49, 0.50, 0.49)
	skin.roughness = 0.88
	head_mesh.material = skin
	head.mesh = head_mesh
	head.position.y = 1.86
	add_child(head)

	for side in [-1.0, 1.0]:
		var eye := MeshInstance3D.new()
		var eye_mesh := SphereMesh.new()
		eye_mesh.radius = 0.028 if not anomalous else 0.034
		eye_mesh.height = eye_mesh.radius * 2.0
		var eye_mat := StandardMaterial3D.new()
		eye_mat.albedo_color = Color(0.03, 0.035, 0.04)
		eye_mat.roughness = 0.35
		eye_mesh.material = eye_mat
		eye.mesh = eye_mesh
		eye.position = Vector3(0.105 * side, 1.91, -0.245)
		add_child(eye)

	var mouth := MeshInstance3D.new()
	var mouth_mesh := BoxMesh.new()
	mouth_mesh.size = Vector3(0.13 if not anomalous else 0.21, 0.018, 0.018)
	var mouth_mat := StandardMaterial3D.new()
	mouth_mat.albedo_color = Color(0.12, 0.055, 0.05)
	mouth_mesh.material = mouth_mat
	mouth.mesh = mouth_mesh
	mouth.position = Vector3(0, 1.76, -0.267)
	add_child(mouth)

	for side in [-1.0, 1.0]:
		var arm := MeshInstance3D.new()
		var arm_mesh := CapsuleMesh.new()
		arm_mesh.radius = 0.09
		arm_mesh.height = 0.78
		arm_mesh.material = clothes
		arm.mesh = arm_mesh
		arm.position = Vector3(0.43 * side, 1.06, 0)
		arm.rotation_degrees.z = 7.0 * side
		add_child(arm)

	if anomalous:
		var halo := OmniLight3D.new()
		halo.position = Vector3(0, 1.7, 0.15)
		halo.light_color = Color(0.48, 0.55, 0.62)
		halo.light_energy = 0.16
		halo.omni_range = 1.6
		add_child(halo)

func walk_to(target: Vector3, duration := 2.5) -> Signal:
	look_at(Vector3(target.x, global_position.y + 1.0, target.z), Vector3.UP)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position", target, duration)
	return tween.finished
