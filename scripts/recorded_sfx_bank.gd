extends Node

# Recorded SFX bank for M8. The game prefers real CC0 recordings when files
# exist in res://assets/audio/cc0/. Missing files are simply ignored, allowing
# the current procedural layer to remain a temporary fallback during asset
# replacement without breaking Night 1.

const AUDIO_ROOT := "res://assets/audio/cc0/"
const PATHS := {
	"footsteps": [
		AUDIO_ROOT + "kenney_rpg/footstep00.ogg",
		AUDIO_ROOT + "kenney_rpg/footstep01.ogg",
		AUDIO_ROOT + "kenney_rpg/footstep02.ogg",
		AUDIO_ROOT + "kenney_rpg/footstep03.ogg"
	],
	"door_open": AUDIO_ROOT + "kenney_rpg/doorOpen_1.ogg",
	"door_close": AUDIO_ROOT + "kenney_rpg/doorClose_1.ogg",
	"scanner": AUDIO_ROOT + "kenney_interface/confirmation_001.ogg",
	"payment": AUDIO_ROOT + "kenney_interface/confirmation_002.ogg",
	"cctv": AUDIO_ROOT + "kenney_interface/glitch_001.ogg"
}

var game: Node
var player_body: CharacterBody3D
var one_shot: AudioStreamPlayer
var footstep_player: AudioStreamPlayer
var footstep_streams: Array[AudioStream] = []
var loaded: Dictionary = {}
var rng := RandomNumberGenerator.new()
var step_clock := 0.0
var last_customer_id := 0
var last_scanned_count := 0
var last_items_count := 0
var last_cctv_open := false

func _ready() -> void:
	call_deferred("_initialize")

func _initialize() -> void:
	game = get_parent()
	player_body = game.get_node_or_null("Player") as CharacterBody3D
	rng.randomize()
	one_shot = AudioStreamPlayer.new()
	one_shot.name = "RecordedOneShot"
	one_shot.volume_db = -16.0
	add_child(one_shot)
	footstep_player = AudioStreamPlayer.new()
	footstep_player.name = "RecordedFootsteps"
	footstep_player.volume_db = -20.0
	add_child(footstep_player)
	_load_bank()
	set_process(true)

func _load_bank() -> void:
	for path: String in PATHS["footsteps"]:
		if ResourceLoader.exists(path):
			var stream := load(path) as AudioStream
			if stream != null:
				footstep_streams.append(stream)
	for key: String in ["door_open", "door_close", "scanner", "payment", "cctv"]:
		var path: String = PATHS[key]
		if ResourceLoader.exists(path):
			var stream := load(path) as AudioStream
			if stream != null:
				loaded[key] = stream

func _process(delta: float) -> void:
	if game == null or not is_instance_valid(game):
		return
	_update_footsteps(delta)
	_monitor_events()

func _update_footsteps(delta: float) -> void:
	if footstep_streams.is_empty() or player_body == null or not is_instance_valid(player_body):
		return
	var speed := Vector2(player_body.velocity.x, player_body.velocity.z).length()
	if not player_body.is_on_floor() or speed < 0.35:
		step_clock = minf(step_clock, 0.08)
		return
	step_clock -= delta
	if step_clock <= 0.0:
		footstep_player.stream = footstep_streams[rng.randi_range(0, footstep_streams.size() - 1)]
		footstep_player.pitch_scale = rng.randf_range(0.96, 1.04)
		footstep_player.volume_db = -17.0 if speed > 5.0 else -21.0
		footstep_player.play()
		step_clock = 0.32 if speed > 5.0 else 0.49

func _monitor_events() -> void:
	var customer_value: Variant = game.get("active_customer")
	var customer_id := 0
	if typeof(customer_value) == TYPE_OBJECT and customer_value != null and is_instance_valid(customer_value):
		customer_id = int((customer_value as Object).get_instance_id())
	if customer_id != 0 and customer_id != last_customer_id:
		last_customer_id = customer_id
		_play("door_open")
	elif customer_id == 0 and last_customer_id != 0:
		last_customer_id = 0
		_play("door_close")

	var scanned_value: Variant = game.get("scanned_count")
	if typeof(scanned_value) == TYPE_INT:
		var scanned := int(scanned_value)
		if scanned > last_scanned_count:
			_play("scanner")
		last_scanned_count = scanned

	var items_value: Variant = game.get("current_items")
	if typeof(items_value) == TYPE_ARRAY:
		var count := (items_value as Array).size()
		if last_items_count > 0 and count == 0:
			_play("payment")
		last_items_count = count

	var cctv_value: Variant = game.get("cctv_open")
	if typeof(cctv_value) == TYPE_BOOL:
		var open := bool(cctv_value)
		if open and not last_cctv_open:
			_play("cctv")
		last_cctv_open = open

func _play(key: String) -> void:
	if not loaded.has(key):
		return
	one_shot.stream = loaded[key]
	one_shot.pitch_scale = rng.randf_range(0.98, 1.02)
	one_shot.play()
