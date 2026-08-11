extends Node

const L = preload("res://scripts/localization.gd")
const SAVE_SYSTEM = preload("res://scripts/save_system.gd")

var game: Node3D
var player: CharacterBody3D
var current_night: int = 1
var bed_position := Vector3(6.35, 0.45, 4.65)
var hint: Label
var fade: ColorRect
var transitioning := false

func _ready() -> void:
	call_deferred("_initialize")

func _initialize() -> void:
	game = get_parent() as Node3D
	player = game.get_node_or_null("Player") as CharacterBody3D
	current_night = _night_from_name(game.name)
	_build_room()
	_build_ui()
	set_process(true)
	set_process_input(true)

func _process(_delta: float) -> void:
	if transitioning or player == null or not is_instance_valid(player):
		hint.visible = false
		return
	var d := Vector2(player.global_position.x - bed_position.x, player.global_position.z - bed_position.z).length()
	if d < 1.65:
		hint.visible = true
		hint.text = _t("E — SLEEP UNTIL NEXT SHIFT", "E — ЛЕЧЬ СПАТЬ ДО СЛЕДУЮЩЕЙ СМЕНЫ") if _next_night_unlocked() else _t("E — BED (finish the shift first)", "E — КРОВАТЬ (сначала закончи смену)")
	else:
		hint.visible = false

func _input(event: InputEvent) -> void:
	if transitioning or not event.is_action_pressed("interact") or not hint.visible:return
	get_viewport().set_input_as_handled()
	if not _next_night_unlocked():
		_message(_t("You cannot sleep while the shift is still active.", "Нельзя ложиться спать, пока смена не закончена."), 3.0)
		return
	_transition_to_next_night()

func _transition_to_next_night() -> void:
	transitioning = true
	hint.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# M12 checkpoint: validate current save and create a recoverable backup before scene change.
	SAVE_SYSTEM.write_save(SAVE_SYSTEM.load_save())
	_message(_t("You lie down. The fluorescent hum continues through the wall...", "Ты ложишься. Гул ламп продолжает доноситься сквозь стену..."), 3.0)
	var tween := create_tween()
	tween.tween_property(fade, "color:a", 1.0, 1.35)
	await tween.finished
	await get_tree().create_timer(0.65).timeout
	var next_scene := _scene_for_night(current_night + 1)
	if next_scene != "": get_tree().change_scene_to_file(next_scene)
	else: transitioning = false

func _next_night_unlocked() -> bool:
	return int(SAVE_SYSTEM.load_save().get("night", current_night)) >= current_night + 1

func _night_from_name(node_name: String) -> int:
	match node_name:
		"Night2": return 2
		"Night3": return 3
		"Night4": return 4
		"Night5": return 5
		_: return 1

func _scene_for_night(night: int) -> String:
	match night:
		2: return "res://scenes/night2.tscn"
		3: return "res://scenes/night3.tscn"
		4: return "res://scenes/night4.tscn"
		5: return "res://scenes/night5.tscn"
		6: return "res://scenes/night6.tscn"
		_: return ""

func _build_room() -> void:
	_static_box("RestRoomBack", Vector3(4.2, 3.1, 0.18), Vector3(6.75, 1.55, 6.15), Color(0.14,0.15,0.16))
	_static_box("RestRoomSide", Vector3(0.18, 3.1, 3.8), Vector3(8.65, 1.55, 4.25), Color(0.14,0.15,0.16))
	_static_box("RestRoomPartitionA", Vector3(1.25, 3.1, 0.18), Vector3(5.15,1.55,2.35), Color(0.15,0.16,0.17))
	_static_box("RestRoomPartitionB", Vector3(1.20, 3.1, 0.18), Vector3(8.05,1.55,2.35), Color(0.15,0.16,0.17))
	_static_box("BedFrame", Vector3(2.25,0.28,1.25), bed_position + Vector3(0,-0.20,0), Color(0.15,0.10,0.07))
	_static_box("Mattress", Vector3(2.12,0.24,1.13), bed_position + Vector3(0,0.05,0), Color(0.42,0.44,0.43), false)
	_static_box("Blanket", Vector3(1.25,0.08,1.05), bed_position + Vector3(0.35,0.20,0), Color(0.20,0.25,0.28), false)
	_static_box("Pillow", Vector3(0.48,0.14,0.82), bed_position + Vector3(-0.72,0.22,0), Color(0.62,0.61,0.56), false)
	_static_box("Locker", Vector3(0.75,1.8,0.65), Vector3(7.9,0.9,5.55), Color(0.18,0.21,0.22))
	var lamp := OmniLight3D.new();lamp.position = Vector3(6.7,2.65,4.25);lamp.light_color = Color(0.72,0.70,0.58);lamp.light_energy = 0.55;lamp.omni_range = 3.2;game.add_child(lamp)

func _static_box(node_name:String,size:Vector3,pos:Vector3,color:Color,collision_enabled:bool=true) -> void:
	var body := StaticBody3D.new();body.name = node_name;body.position = pos;game.add_child(body)
	var mi := MeshInstance3D.new();var mesh := BoxMesh.new();mesh.size = size;var mat := StandardMaterial3D.new();mat.albedo_color = color;mat.roughness = 0.86;mesh.material = mat;mi.mesh = mesh;body.add_child(mi)
	if collision_enabled:
		var cs := CollisionShape3D.new();var shape := BoxShape3D.new();shape.size = size;cs.shape = shape;body.add_child(cs)

func _build_ui() -> void:
	var layer := CanvasLayer.new();layer.layer = 90;add_child(layer)
	hint = Label.new();hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM);hint.position = Vector2(-240,-74);hint.size = Vector2(480,34);hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;hint.add_theme_font_size_override("font_size",16);hint.visible = false;layer.add_child(hint)
	fade = ColorRect.new();fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);fade.color = Color(0,0,0,0);fade.mouse_filter = Control.MOUSE_FILTER_IGNORE;layer.add_child(fade)

func _message(text:String,seconds:float) -> void:
	if game.has_method("show_message"):game.call("show_message", text, seconds)
func _t(en:String,ru:String) -> String:return ru if L.get_language() == "ru" else en
