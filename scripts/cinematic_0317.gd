extends Node

var game: Node3D
var player_camera: Camera3D
var canvas: CanvasLayer
var top_bar: ColorRect
var bottom_bar: ColorRect
var blackout: ColorRect
var warning: Label
var sequence_started := false
var impact_played := false

func _ready() -> void:
	call_deferred("_initialize")

func _process(_delta: float) -> void:
	if not game or not is_instance_valid(game):
		return
	var minutes = game.get("shift_minutes")
	if typeof(minutes) != TYPE_FLOAT and typeof(minutes) != TYPE_INT:
		return
	var t := float(minutes)
	if t >= 190.0 and not sequence_started:
		sequence_started = true
		begin_pre_0317()
	if t >= 197.0 and not impact_played:
		impact_played = true
		play_0317_impact()

func _initialize() -> void:
	game = get_parent() as Node3D
	if not game:
		return
	player_camera = game.get_node_or_null("Player/Camera3D") as Camera3D
	build_overlay()

func build_overlay() -> void:
	canvas = CanvasLayer.new()
	canvas.layer = 80
	game.add_child(canvas)

	top_bar = ColorRect.new()
	top_bar.color = Color(0, 0, 0, 1)
	top_bar.anchor_right = 1.0
	top_bar.offset_bottom = 0.0
	top_bar.custom_minimum_size.y = 0.0
	canvas.add_child(top_bar)

	bottom_bar = ColorRect.new()
	bottom_bar.color = Color(0, 0, 0, 1)
	bottom_bar.anchor_top = 1.0
	bottom_bar.anchor_right = 1.0
	bottom_bar.anchor_bottom = 1.0
	bottom_bar.offset_top = 0.0
	canvas.add_child(bottom_bar)

	blackout = ColorRect.new()
	blackout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	blackout.color = Color(0, 0, 0, 0)
	blackout.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(blackout)

	warning = Label.new()
	warning.set_anchors_preset(Control.PRESET_CENTER)
	warning.position = Vector2(-320, -55)
	warning.size = Vector2(640, 110)
	warning.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warning.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	warning.add_theme_font_size_override("font_size", 34)
	warning.modulate = Color(0.78, 0.9, 0.88, 0)
	warning.text = "03:17"
	canvas.add_child(warning)

func begin_pre_0317() -> void:
	if player_camera:
		var fov_tween := create_tween()
		fov_tween.tween_property(player_camera, "fov", 70.0, 3.5).set_trans(Tween.TRANS_SINE)

	var bars := create_tween().set_parallel(true)
	bars.tween_property(top_bar, "custom_minimum_size:y", 54.0, 2.2).set_trans(Tween.TRANS_SINE)
	bars.tween_property(bottom_bar, "offset_top", -54.0, 2.2).set_trans(Tween.TRANS_SINE)

	var pulse := create_tween()
	pulse.tween_property(blackout, "color:a", 0.10, 0.12)
	pulse.tween_property(blackout, "color:a", 0.0, 0.22)
	pulse.tween_interval(0.9)
	pulse.tween_property(blackout, "color:a", 0.16, 0.08)
	pulse.tween_property(blackout, "color:a", 0.0, 0.18)

func play_0317_impact() -> void:
	var flash := create_tween()
	flash.tween_property(blackout, "color:a", 0.92, 0.07)
	flash.tween_interval(0.18)
	flash.tween_property(blackout, "color:a", 0.0, 0.55).set_trans(Tween.TRANS_EXPO)

	warning.text = "03:17\nCAMERA MISMATCH"
	var warn := create_tween()
	warn.tween_property(warning, "modulate:a", 0.88, 0.10)
	warn.tween_interval(0.75)
	warn.tween_property(warning, "modulate:a", 0.0, 0.65)

	if player_camera:
		var camera_hit := create_tween()
		camera_hit.tween_property(player_camera, "fov", 66.5, 0.12)
		camera_hit.tween_property(player_camera, "fov", 72.0, 0.55).set_trans(Tween.TRANS_BACK)

	await get_tree().create_timer(4.5).timeout
	release_letterbox()

func release_letterbox() -> void:
	var bars := create_tween().set_parallel(true)
	bars.tween_property(top_bar, "custom_minimum_size:y", 0.0, 1.2).set_trans(Tween.TRANS_SINE)
	bars.tween_property(bottom_bar, "offset_top", 0.0, 1.2).set_trans(Tween.TRANS_SINE)
	if player_camera:
		bars.tween_property(player_camera, "fov", 75.0, 1.2).set_trans(Tween.TRANS_SINE)
