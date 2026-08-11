extends CharacterBody3D

@export var walk_speed: float = 4.2
@export var sprint_speed: float = 6.8
@export var crouch_speed: float = 2.4
@export var jump_velocity: float = 4.8
@export var mouse_sensitivity: float = 0.0022
@export var interaction_distance: float = 3.0
@export var standing_camera_height: float = 0.65
@export var crouching_camera_height: float = 0.18
@export var crouch_transition_speed: float = 10.0

@onready var camera: Camera3D = $Camera3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var gravity: float = float(ProjectSettings.get_setting("physics/3d/default_gravity", 9.8))
var is_crouching: bool = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var mouse_event: InputEventMouseMotion = event as InputEventMouseMotion
		rotate_y(-mouse_event.relative.x * mouse_sensitivity)
		camera.rotation.x = clampf(
			camera.rotation.x - mouse_event.relative.y * mouse_sensitivity,
			deg_to_rad(-80.0),
			deg_to_rad(80.0)
		)

	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.pressed and not key_event.echo:
			if key_event.physical_keycode == KEY_ESCAPE:
				var pause_manager: Node = get_tree().get_first_node_in_group("pause_manager")
				if pause_manager and pause_manager.has_method("toggle_pause"):
					pause_manager.call("toggle_pause")
				else:
					Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED
			elif key_event.physical_keycode == KEY_E and not get_tree().paused:
				try_interact()

func _physics_process(delta: float) -> void:
	if get_tree().paused:
		return

	is_crouching = Input.is_physical_key_pressed(KEY_CTRL)
	_update_crouch(delta)

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if Input.is_physical_key_pressed(KEY_SPACE) and not is_crouching:
			velocity.y = jump_velocity
		else:
			velocity.y = 0.0

	var input_vector: Vector2 = Vector2(
		float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)),
		float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W))
	).normalized()
	var direction: Vector3 = (transform.basis * Vector3(input_vector.x, 0.0, input_vector.y)).normalized()

	var target_speed: float = walk_speed
	if is_crouching:
		target_speed = crouch_speed
	elif Input.is_physical_key_pressed(KEY_SHIFT):
		target_speed = sprint_speed

	if direction.length_squared() > 0.0:
		velocity.x = direction.x * target_speed
		velocity.z = direction.z * target_speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, target_speed * 8.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, target_speed * 8.0 * delta)

	move_and_slide()

func _update_crouch(delta: float) -> void:
	var target_height: float = crouching_camera_height if is_crouching else standing_camera_height
	camera.position.y = move_toward(camera.position.y, target_height, crouch_transition_speed * delta)
	var capsule: CapsuleShape3D = collision_shape.shape as CapsuleShape3D
	if capsule != null:
		var target_capsule_height: float = 1.25 if is_crouching else 1.8
		capsule.height = move_toward(capsule.height, target_capsule_height, crouch_transition_speed * delta)

func try_interact() -> void:
	var from: Vector3 = camera.global_position
	var to: Vector3 = from + (-camera.global_transform.basis.z * interaction_distance)
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)

	if hit.is_empty():
		return

	var collider_value: Variant = hit.get("collider")
	var collider: Object = collider_value as Object
	if collider and collider.has_method("interact"):
		collider.call("interact", self)
