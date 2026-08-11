extends Node3D

# Procedural customer used by the Night 1 vertical slice. M7 improves the
# silhouette and clothing read while keeping the gameplay API stable.

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

func _material(c: Color, roughness: float = 0.78, metallic: float = 0.0) -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = c
	mat.roughness = roughness
	mat.metallic = metallic
	return mat

func _build_body() -> void:
	var clothes: StandardMaterial3D = _material(color, 0.86)
	var dark_cloth: StandardMaterial3D = _material(color.darkened(0.28), 0.90)
	var skin_color: Color = Color(0.64, 0.53, 0.46) if not anomalous else Color(0.49, 0.50, 0.49)
	var skin: StandardMaterial3D = _material(skin_color, 0.88)
	var shoe_mat: StandardMaterial3D = _material(Color(0.035, 0.038, 0.04), 0.72, 0.08)

	# Torso with separate shoulder/chest masses reads less like a single capsule.
	var torso: MeshInstance3D = MeshInstance3D.new()
	var torso_mesh: CapsuleMesh = CapsuleMesh.new()
	torso_mesh.radius = 0.32
	torso_mesh.height = 1.08
	torso_mesh.material = clothes
	torso.mesh = torso_mesh
	torso.position.y = 1.08
	add_child(torso)

	var shoulders: MeshInstance3D = MeshInstance3D.new()
	var shoulders_mesh: BoxMesh = BoxMesh.new()
	shoulders_mesh.size = Vector3(0.78, 0.18, 0.34)
	shoulders_mesh.material = clothes
	shoulders.mesh = shoulders_mesh
	shoulders.position = Vector3(0.0, 1.45, 0.0)
	add_child(shoulders)

	# Jacket / shirt panel gives the front a readable clothing layer.
	var chest: MeshInstance3D = MeshInstance3D.new()
	var chest_mesh: BoxMesh = BoxMesh.new()
	chest_mesh.size = Vector3(0.50, 0.55, 0.06)
	chest_mesh.material = dark_cloth
	chest.mesh = chest_mesh
	chest.position = Vector3(0.0, 1.22, -0.285)
	add_child(chest)

	# Neck.
	var neck: MeshInstance3D = MeshInstance3D.new()
	var neck_mesh: CylinderMesh = CylinderMesh.new()
	neck_mesh.top_radius = 0.09
	neck_mesh.bottom_radius = 0.10
	neck_mesh.height = 0.18
	neck_mesh.material = skin
	neck.mesh = neck_mesh
	neck.position = Vector3(0.0, 1.62, 0.0)
	add_child(neck)

	var head: MeshInstance3D = MeshInstance3D.new()
	var head_mesh: SphereMesh = SphereMesh.new()
	head_mesh.radius = 0.235
	head_mesh.height = 0.47
	head_mesh.material = skin
	head.mesh = head_mesh
	head.position.y = 1.86
	if anomalous:
		head.scale = Vector3(0.94, 1.10, 0.90)
	add_child(head)

	# Hair cap: subtle on normal customers, unnaturally flat/dark on anomaly.
	var hair: MeshInstance3D = MeshInstance3D.new()
	var hair_mesh: SphereMesh = SphereMesh.new()
	hair_mesh.radius = 0.238
	hair_mesh.height = 0.26
	hair_mesh.material = _material(Color(0.045, 0.038, 0.032) if not anomalous else Color(0.015,0.018,0.02), 0.78)
	hair.mesh = hair_mesh
	hair.position = Vector3(0.0, 1.985, 0.015)
	hair.scale = Vector3(1.0, 0.42, 1.0)
	add_child(hair)

	for side_value: float in [-1.0, 1.0]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var eye_mesh: SphereMesh = SphereMesh.new()
		eye_mesh.radius = 0.022 if not anomalous else 0.029
		eye_mesh.height = eye_mesh.radius * 2.0
		eye_mesh.material = _material(Color(0.015, 0.018, 0.02), 0.24)
		eye.mesh = eye_mesh
		eye.position = Vector3(0.087 * side_value, 1.89, -0.218)
		add_child(eye)

	var nose: MeshInstance3D = MeshInstance3D.new()
	var nose_mesh: BoxMesh = BoxMesh.new()
	nose_mesh.size = Vector3(0.045, 0.10, 0.055)
	nose_mesh.material = skin
	nose.mesh = nose_mesh
	nose.position = Vector3(0.0, 1.82, -0.235)
	add_child(nose)

	var mouth: MeshInstance3D = MeshInstance3D.new()
	var mouth_mesh: BoxMesh = BoxMesh.new()
	mouth_mesh.size = Vector3(0.10 if not anomalous else 0.17, 0.012, 0.012)
	mouth_mesh.material = _material(Color(0.11, 0.045, 0.04), 0.70)
	mouth.mesh = mouth_mesh
	mouth.position = Vector3(0.0, 1.72, -0.237)
	add_child(mouth)

	# Arms, hands, legs and shoes create a more human full-body silhouette.
	for side_value: float in [-1.0, 1.0]:
		var arm: MeshInstance3D = MeshInstance3D.new()
		var arm_mesh: CapsuleMesh = CapsuleMesh.new()
		arm_mesh.radius = 0.078
		arm_mesh.height = 0.70
		arm_mesh.material = clothes
		arm.mesh = arm_mesh
		arm.position = Vector3(0.39 * side_value, 1.06, 0.0)
		arm.rotation_degrees.z = 6.0 * side_value
		add_child(arm)

		var hand: MeshInstance3D = MeshInstance3D.new()
		var hand_mesh: SphereMesh = SphereMesh.new()
		hand_mesh.radius = 0.085
		hand_mesh.height = 0.17
		hand_mesh.material = skin
		hand.mesh = hand_mesh
		hand.position = Vector3(0.43 * side_value, 0.69, -0.015)
		add_child(hand)

		var leg: MeshInstance3D = MeshInstance3D.new()
		var leg_mesh: CapsuleMesh = CapsuleMesh.new()
		leg_mesh.radius = 0.105
		leg_mesh.height = 0.72
		leg_mesh.material = dark_cloth
		leg.mesh = leg_mesh
		leg.position = Vector3(0.15 * side_value, 0.43, 0.0)
		add_child(leg)

		var shoe: MeshInstance3D = MeshInstance3D.new()
		var shoe_mesh: BoxMesh = BoxMesh.new()
		shoe_mesh.size = Vector3(0.20, 0.13, 0.34)
		shoe_mesh.material = shoe_mat
		shoe.mesh = shoe_mesh
		shoe.position = Vector3(0.15 * side_value, 0.10, -0.08)
		add_child(shoe)

	if anomalous:
		var halo: OmniLight3D = OmniLight3D.new()
		halo.position = Vector3(0.0, 1.72, 0.10)
		halo.light_color = Color(0.40, 0.50, 0.62)
		halo.light_energy = 0.075
		halo.omni_range = 1.25
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
