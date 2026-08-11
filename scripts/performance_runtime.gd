extends Node

const SETTINGS_PATH := "user://settings.cfg"

var preset: String = "balanced"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_and_apply()

func load_and_apply() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SETTINGS_PATH)
	preset = str(cfg.get_value("graphics", "quality_preset", "balanced"))
	if preset not in ["low", "balanced", "high"]:
		preset = "balanced"
	apply_preset(preset, false)

func apply_preset(value: String, persist: bool = true) -> void:
	preset = value if value in ["low", "balanced", "high"] else "balanced"
	var viewport := get_viewport()
	if viewport != null:
		match preset:
			"low":
				viewport.scaling_3d_scale = 0.75
				viewport.msaa_3d = Viewport.MSAA_DISABLED
			"high":
				viewport.scaling_3d_scale = 1.0
				viewport.msaa_3d = Viewport.MSAA_4X
			_:
				viewport.scaling_3d_scale = 0.90
				viewport.msaa_3d = Viewport.MSAA_2X
	Engine.max_fps = 60
	if persist:
		var cfg := ConfigFile.new()
		cfg.load(SETTINGS_PATH)
		cfg.set_value("graphics", "quality_preset", preset)
		cfg.save(SETTINGS_PATH)

func get_preset() -> String:
	return preset
