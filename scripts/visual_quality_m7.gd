extends Node

# M7 visual-quality layer. Keeps the stable Night 1 gameplay untouched while
# adding authored-looking procedural dressing that can later be replaced by
# production meshes/textures without changing gameplay code.

var game: Node3D

func _ready() -> void:
	call_deferred("_initialize")

func _initialize() -> void:
	game = get_parent() as Node3D
	if game == null:
		return
	_build_ceiling_grid()
	_build_register_detail()
	_build_front_window_dressing()
	_build_store_clutter()
	_build_night_lighting()

func _mat(color: Color, roughness: float = 0.65, metallic: float = 0.0, emission: Color = Color(0,0,0,1), emission_energy: float = 0.0) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	if emission_energy > 0.0:
		material.emission_enabled = true
		material.emission = emission
		material.emission_energy_multiplier = emission_energy
	return material

func _box(name_value: String, size: Vector3, pos: Vector3, material: StandardMaterial3D) -> MeshInstance3D:
	var node: MeshInstance3D = MeshInstance3D.new()
	node.name = name_value
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	mesh.material = material
	node.mesh = mesh
	node.position = pos
	game.add_child(node)
	return node

func _build_ceiling_grid() -> void:
	var rail_mat: StandardMaterial3D = _mat(Color(0.075, 0.085, 0.09), 0.72, 0.12)
	var panel_mat: StandardMaterial3D = _mat(Color(0.72, 0.77, 0.73), 0.38, 0.0, Color(0.70, 0.86, 0.78), 1.35)
	for x: float in [-6.0, -2.0, 2.0, 6.0]:
		_box("CeilingRail", Vector3(0.045, 0.05, 11.8), Vector3(x, 4.12, 0.0), rail_mat)
	for z: float in [-4.7, -1.7, 1.3, 4.3]:
		_box("CeilingRailCross", Vector3(16.5, 0.05, 0.045), Vector3(0.0, 4.12, z), rail_mat)
	for z: float in [-4.1, -0.9, 2.3]:
		for x: float in [-4.8, 0.0, 4.8]:
			_box("FluorescentHousing", Vector3(2.25, 0.10, 0.52), Vector3(x, 4.02, z), rail_mat)
			_box("FluorescentPanel", Vector3(2.05, 0.035, 0.38), Vector3(x, 3.955, z), panel_mat)

func _build_register_detail() -> void:
	var dark: StandardMaterial3D = _mat(Color(0.035, 0.045, 0.048), 0.48, 0.20)
	var rubber: StandardMaterial3D = _mat(Color(0.025, 0.028, 0.03), 0.90)
	var metal: StandardMaterial3D = _mat(Color(0.23, 0.26, 0.27), 0.32, 0.58)
	var glow: StandardMaterial3D = _mat(Color(0.05, 0.10, 0.08), 0.25, 0.0, Color(0.18, 0.82, 0.48), 1.8)
	_box("ScannerBed", Vector3(0.78, 0.035, 0.52), Vector3(4.15, 1.205, -3.57), dark)
	_box("ScannerGlass", Vector3(0.58, 0.012, 0.34), Vector3(4.15, 1.226, -3.57), glow)
	_box("CounterEdge", Vector3(3.75, 0.08, 0.08), Vector3(4.55, 1.17, -3.93), metal)
	_box("BagWell", Vector3(0.92, 0.08, 0.70), Vector3(6.05, 1.17, -3.48), rubber)
	for i: int in range(3):
		_box("ReceiptPaper", Vector3(0.18, 0.012, 0.30), Vector3(5.84 + float(i) * 0.035, 1.43 + float(i) * 0.008, -3.62), _mat(Color(0.82, 0.80, 0.70), 0.92))

func _build_front_window_dressing() -> void:
	var poster_back: StandardMaterial3D = _mat(Color(0.055, 0.065, 0.07), 0.76)
	var poster_red: StandardMaterial3D = _mat(Color(0.46, 0.08, 0.06), 0.68)
	var poster_cream: StandardMaterial3D = _mat(Color(0.72, 0.64, 0.43), 0.76)
	_box("WindowPosterA", Vector3(1.15, 1.55, 0.025), Vector3(-7.35, 2.05, -6.72), poster_back)
	_box("WindowPosterABand", Vector3(0.92, 0.30, 0.018), Vector3(-7.35, 2.30, -6.70), poster_red)
	_box("WindowPosterB", Vector3(0.92, 1.20, 0.025), Vector3(7.50, 1.85, -6.72), poster_cream)
	_box("DoorKickPlateL", Vector3(1.45, 0.34, 0.025), Vector3(-0.90, 0.42, -6.76), _mat(Color(0.18,0.20,0.20),0.30,0.55))
	_box("DoorKickPlateR", Vector3(1.45, 0.34, 0.025), Vector3(0.90, 0.42, -6.76), _mat(Color(0.18,0.20,0.20),0.30,0.55))

func _build_store_clutter() -> void:
	var cardboard: StandardMaterial3D = _mat(Color(0.39, 0.27, 0.15), 0.94)
	var tape: StandardMaterial3D = _mat(Color(0.58, 0.48, 0.28), 0.72)
	var positions: Array[Vector3] = [Vector3(-7.0,0.26,5.3), Vector3(-6.35,0.22,5.5), Vector3(7.0,0.32,4.9)]
	for i: int in range(positions.size()):
		var p: Vector3 = positions[i]
		var h: float = 0.42 + float(i) * 0.10
		_box("StockBox", Vector3(0.72, h, 0.62), Vector3(p.x, h * 0.5, p.z), cardboard)
		_box("StockBoxTape", Vector3(0.10, h + 0.008, 0.63), Vector3(p.x, h * 0.5, p.z), tape)
	var mat: StandardMaterial3D = _mat(Color(0.11,0.13,0.13),0.55,0.25)
	for x: float in [-6.8, 6.8]:
		_box("FloorMat", Vector3(1.4,0.025,0.72), Vector3(x,0.02,-5.9), mat)

func _build_night_lighting() -> void:
	var fill: OmniLight3D = OmniLight3D.new()
	fill.name = "M7RegisterFill"
	fill.position = Vector3(4.4, 2.9, -2.6)
	fill.light_color = Color(0.60, 0.78, 0.72)
	fill.light_energy = 0.55
	fill.omni_range = 4.8
	fill.shadow_enabled = true
	game.add_child(fill)
	var entrance: OmniLight3D = OmniLight3D.new()
	entrance.name = "M7EntranceColdFill"
	entrance.position = Vector3(0.0, 2.7, -5.9)
	entrance.light_color = Color(0.38, 0.55, 0.70)
	entrance.light_energy = 0.42
	entrance.omni_range = 5.2
	entrance.shadow_enabled = true
	game.add_child(entrance)
