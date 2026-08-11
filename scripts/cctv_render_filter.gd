extends Node

# CCTV renders the same World3D as the player, but it must not see entities on
# visual layer 2. The 03:17 customer uses layer 2; ordinary store geometry and
# regular customers stay on layer 1.

var configured: bool = false

func _ready() -> void:
	set_process(true)

func _process(_delta: float) -> void:
	if configured:
		set_process(false)
		return

	var viewport: Node = get_tree().root.find_child("RenderedCCTVViewport", true, false)
	if viewport == null or not is_instance_valid(viewport):
		return

	var camera: Camera3D = viewport.find_child("Camera3D", true, false) as Camera3D
	if camera == null:
		for child: Node in viewport.get_children():
			if child is Camera3D:
				camera = child as Camera3D
				break

	if camera == null:
		return

	# Layer 1 only. The player's camera keeps layers 1+2, so the anomaly remains
	# physically present and visible in first person while CCTV shows empty space.
	camera.cull_mask = 1
	configured = true
