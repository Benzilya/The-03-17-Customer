extends Node3D

# Procedural prototype customer used by the Night 1 vertical slice.
# Customers stop on the public side of REGISTER 01 instead of walking into
# the cashier/player space.

const LEGACY_REGISTER_TARGET := Vector3(3.4, 0.0, -2.8)
const REGISTER_WAIT_POSITION := Vector3(3.55, 0.0, -5.75)
const REGISTER_TARGET_EPSILON: float = 0.35

var display_name: String = "Customer"
var anomalous: bool = false
var color: Color = Color(0.45, 0.48, 0.52)

func setup(customer_name: String, is_anomalous: bool, body_color: Color) -> void:
	display_name = customer_name
	anomalous = is_anomalous
	color = body_color
	_build_body()

func _build_body() -> void:
	var torso: MeshInstance3D = MeshInstance3D.new()
	var torso_mesh: CapsuleMesh = CapsuleMesh.new()
	torso_mesh.radius = 0.34
	torso_mesh.height = 1.24
	var clothes: StandardMaterial3D = StandardMaterial3D.new()
	clothes.albedo_color = color
	clothes.roughness = 0.8
	torso_mesh.material = clothes
	torso.mesh = torso_mesh
	torso.position.y = 1.0
	add_child(torso)

	var head: MeshInstance3D = MeshInstance3D.new()
	var head_mesh: SphereMesh = SphereMesh.new()
	head_mesh.radius = 0.25
	head_mesh.height = 0.50
	var skin: StandardMaterial3D = StandardMaterial3D.new()
	skin.albedo_color = Color(0.64, 0.53, 0.46) if not anomalous else Color(0.49, 0.50, 0.49)
	skin.roughness = 0.88
	head_mesh.material = skin
	head.mesh = head_mesh
	head.position.y = 1.82
	add_child(head)

	for side_value: float in [-1.0, 1.0]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var eye_mesh: SphereMesh = SphereMesh.new()
		eye_mesh.radius = 0.026 if not anomalous else 0.031
		eye_mesh.height = eye_mesh.radius * 2.0
		var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
		eye_mat.albedo_color = Color(0.03, 0.035, 0.04)
		eye_mat.roughness = 0.35
		eye_mesh.material = eye_mat
		eye.mesh = eye_mesh
		eye.position = Vector3(0.095 * side_value, 1.86, -0.225)
		add_child(eye)

	var mouth: MeshInstance3D = MeshInstance3D.new()
	var mouth_mesh: BoxMesh = BoxMesh.new()
	mouth_mesh.size = Vector3(0.12 if not anomalous else 0.18, 0.016, 0.016)
	var mouth_mat: StandardMaterial3D = StandardMaterial3D.new()
	mouth_mat.albedo_color = Color(0.12, 0.055, 0.05)
	mouth_mesh.material = mouth_mat
	mouth.mesh = mouth_mesh
	mouth.position = Vector3(0.0, 1.73, -0.245)
	add_child(mouth)

	for side_value: float in [-1.0, 1.0]:
		var arm: MeshInstance3D = MeshInstance3D.new()
		var arm_mesh: CapsuleMesh = CapsuleMesh.new()
		arm_mesh.radius = 0.085
		arm_mesh.height = 0.74
		arm_mesh.material = clothes
		arm.mesh = arm_mesh
		arm.position = Vector3(0.40 * side_value, 1.05, 0.0)
		arm.rotation_degrees.z = 7.0 * side_value
		add_child(arm)

	if anomalous:
		var halo: OmniLight3D = OmniLight3D.new()
		halo.position = Vector3(0.0, 1.7, 0.15)
		halo.light_color = Color(0.48, 0.55, 0.62)
		halo.light_energy = 0.11
		halo.omni_range = 1.4
		add_child(halo)

func walk_to(target: Vector3, duration: float = 2.5) -> Signal:
	var resolved_target: Vector3 = _resolve_target(target)
	look_at(Vector3(resolved_target.x, global_position.y + 1.0, resolved_target.z), Vector3.UP)
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position", resolved_target, duration)
	return tween.finished

func _resolve_target(requested_target: Vector3) -> Vector3:
	if requested_target.distance_to(LEGACY_REGISTER_TARGET) <= REGISTER_TARGET_EPSILON:
		return REGISTER_WAIT_POSITION
	return requested_target
