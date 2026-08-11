extends Node

# M8 audio-quality layer. Procedural audio keeps the project self-contained
# while establishing the final mix structure and event timing.

var game: Node
var player_body: CharacterBody3D

var mechanical_player: AudioStreamPlayer
var electrical_player: AudioStreamPlayer
var foley_player: AudioStreamPlayer
var event_player: AudioStreamPlayer

var mechanical_playback: AudioStreamGeneratorPlayback
var electrical_playback: AudioStreamGeneratorPlayback
var foley_playback: AudioStreamGeneratorPlayback
var event_playback: AudioStreamGeneratorPlayback

var sample_rate: float = 22050.0
var mechanical_phase: float = 0.0
var electrical_phase: float = 0.0
var foley_phase: float = 0.0
var event_phase: float = 0.0

var footstep_remaining: float = 0.0
var footstep_strength: float = 0.0
var step_clock: float = 0.0

var event_mode: int = 0
var event_remaining: float = 0.0
var event_frequency: float = 440.0
var event_strength: float = 0.4

var last_customer_id: int = 0
var last_scanned_count: int = 0
var last_cctv_open: bool = false
var last_current_items_count: int = 0
var anomaly_event_fired: bool = false
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	call_deferred("_initialize")

func _initialize() -> void:
	game = get_parent()
	player_body = game.get_node_or_null("Player") as CharacterBody3D
	rng.randomize()
	mechanical_player = _make_player("M8Mechanical", -24.0)
	electrical_player = _make_player("M8Electrical", -28.0)
	foley_player = _make_player("M8Foley", -11.0)
	event_player = _make_player("M8Events", -7.0)
	mechanical_playback = mechanical_player.get_stream_playback() as AudioStreamGeneratorPlayback
	electrical_playback = electrical_player.get_stream_playback() as AudioStreamGeneratorPlayback
	foley_playback = foley_player.get_stream_playback() as AudioStreamGeneratorPlayback
	event_playback = event_player.get_stream_playback() as AudioStreamGeneratorPlayback
	set_process(true)

func _make_player(node_name: String, volume_db: float) -> AudioStreamPlayer:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.name = node_name
	var generator: AudioStreamGenerator = AudioStreamGenerator.new()
	generator.mix_rate = sample_rate
	generator.buffer_length = 0.30
	player.stream = generator
	player.volume_db = volume_db
	add_child(player)
	player.play()
	return player

func _process(delta: float) -> void:
	if game == null or not is_instance_valid(game):
		return
	_update_footsteps(delta)
	_update_mix()
	_monitor_events()
	_fill_mechanical()
	_fill_electrical()
	_fill_foley()
	_fill_events()

func _update_mix() -> void:
	var minutes_value: Variant = game.get("shift_minutes")
	var minutes: float = float(minutes_value) if typeof(minutes_value) in [TYPE_FLOAT, TYPE_INT] else 0.0
	var cctv_value: Variant = game.get("cctv_open")
	var cctv_open: bool = bool(cctv_value) if typeof(cctv_value) == TYPE_BOOL else false
	var tension: float = clampf((minutes - 175.0) / 22.0, 0.0, 1.0)
	mechanical_player.volume_db = lerpf(-24.0, -20.0, tension)
	electrical_player.volume_db = (-21.0 if cctv_open else -28.0) + tension * 3.0

func _monitor_events() -> void:
	var customer_value: Variant = game.get("active_customer")
	var customer_id: int = 0
	if typeof(customer_value) == TYPE_OBJECT and customer_value != null and is_instance_valid(customer_value):
		var customer_object: Object = customer_value as Object
		customer_id = int(customer_object.get_instance_id())
	if customer_id != 0 and customer_id != last_customer_id:
		last_customer_id = customer_id
		_play_chime()
	elif customer_id == 0 and last_customer_id != 0:
		last_customer_id = 0
		_play_door_close()

	var scanned_value: Variant = game.get("scanned_count")
	if typeof(scanned_value) == TYPE_INT:
		var scanned: int = int(scanned_value)
		if scanned > last_scanned_count:
			last_scanned_count = scanned
			_play_scanner()
		elif scanned < last_scanned_count:
			last_scanned_count = scanned

	var items_value: Variant = game.get("current_items")
	if typeof(items_value) == TYPE_ARRAY:
		var item_count: int = (items_value as Array).size()
		if last_current_items_count > 0 and item_count == 0:
			_play_payment()
		last_current_items_count = item_count

	var cctv_value: Variant = game.get("cctv_open")
	var cctv_open: bool = bool(cctv_value) if typeof(cctv_value) == TYPE_BOOL else false
	if cctv_open != last_cctv_open:
		last_cctv_open = cctv_open
		if cctv_open:
			_play_cctv_static()

	var minutes_value: Variant = game.get("shift_minutes")
	if typeof(minutes_value) in [TYPE_FLOAT, TYPE_INT]:
		var minutes: float = float(minutes_value)
		if minutes >= 197.0 and not anomaly_event_fired:
			anomaly_event_fired = true
			_play_0317_sting()

func _play_chime() -> void:
	event_mode = 1
	event_frequency = 880.0
	event_strength = 0.32
	event_remaining = 0.55
	event_phase = 0.0

func _play_door_close() -> void:
	event_mode = 2
	event_frequency = 105.0
	event_strength = 0.26
	event_remaining = 0.22
	event_phase = 0.0

func _play_scanner() -> void:
	event_mode = 3
	event_frequency = 1480.0
	event_strength = 0.44
	event_remaining = 0.09
	event_phase = 0.0

func _play_payment() -> void:
	event_mode = 4
	event_frequency = 620.0
	event_strength = 0.30
	event_remaining = 0.48
	event_phase = 0.0

func _play_cctv_static() -> void:
	event_mode = 5
	event_strength = 0.34
	event_remaining = 0.32
	event_phase = 0.0

func _play_0317_sting() -> void:
	event_mode = 6
	event_frequency = 54.0
	event_strength = 0.52
	event_remaining = 1.85
	event_phase = 0.0

func _update_footsteps(delta: float) -> void:
	if player_body == null or not is_instance_valid(player_body):
		return
	var horizontal_speed: float = Vector2(player_body.velocity.x, player_body.velocity.z).length()
	if not player_body.is_on_floor() or horizontal_speed < 0.35:
		step_clock = minf(step_clock, 0.08)
		return
	step_clock -= delta
	if step_clock <= 0.0:
		var running: bool = horizontal_speed > 5.0
		footstep_strength = 0.62 if running else 0.42
		footstep_remaining = 0.10
		foley_phase = 0.0
		step_clock = 0.31 if running else 0.48

func _fill_mechanical() -> void:
	if mechanical_playback == null:
		return
	var frames: int = mechanical_playback.get_frames_available()
	for _i: int in range(frames):
		mechanical_phase += 1.0 / sample_rate
		var load: float = 0.78 + sin(TAU * 0.115 * mechanical_phase) * 0.12
		var hum: float = sin(TAU * 47.0 * mechanical_phase) * 0.042
		hum += sin(TAU * 94.0 * mechanical_phase) * 0.017
		var vibration: float = sin(TAU * 6.5 * mechanical_phase) * 0.007
		var value: float = (hum + vibration) * load + rng.randf_range(-0.0025, 0.0025)
		mechanical_playback.push_frame(Vector2(value, value * 0.96))

func _fill_electrical() -> void:
	if electrical_playback == null:
		return
	var frames: int = electrical_playback.get_frames_available()
	for _i: int in range(frames):
		electrical_phase += 1.0 / sample_rate
		var flutter: float = 1.0 + sin(TAU * 0.43 * electrical_phase) * 0.08
		var buzz: float = sin(TAU * 120.0 * electrical_phase) * 0.018
		buzz += sin(TAU * 240.0 * electrical_phase) * 0.007
		buzz += sin(TAU * 360.0 * electrical_phase) * 0.003
		var value: float = buzz * flutter + rng.randf_range(-0.0015, 0.0015)
		electrical_playback.push_frame(Vector2(value, value))

func _fill_foley() -> void:
	if foley_playback == null:
		return
	var frames: int = foley_playback.get_frames_available()
	for _i: int in range(frames):
		var value: float = 0.0
		if footstep_remaining > 0.0:
			foley_phase += 1.0 / sample_rate
			footstep_remaining -= 1.0 / sample_rate
			var envelope: float = clampf(footstep_remaining * 14.0, 0.0, 1.0)
			var thump: float = sin(TAU * 72.0 * foley_phase) * 0.20
			var sole_noise: float = rng.randf_range(-0.18, 0.18)
			value = (thump + sole_noise) * footstep_strength * envelope
		foley_playback.push_frame(Vector2(value, value))

func _fill_events() -> void:
	if event_playback == null:
		return
	var frames: int = event_playback.get_frames_available()
	for _i: int in range(frames):
		var value: float = 0.0
		if event_remaining > 0.0:
			event_phase += 1.0 / sample_rate
			event_remaining -= 1.0 / sample_rate
			var envelope: float = clampf(event_remaining * 8.0, 0.0, 1.0)
			match event_mode:
				1:
					var bell_a: float = sin(TAU * event_frequency * event_phase)
					var bell_b: float = sin(TAU * event_frequency * 1.505 * event_phase) * 0.45
					value = (bell_a + bell_b) * event_strength * envelope
				2:
					value = (sin(TAU * event_frequency * event_phase) * 0.5 + rng.randf_range(-0.20, 0.20)) * event_strength * envelope
				3:
					value = sin(TAU * event_frequency * event_phase) * event_strength * envelope
				4:
					var receipt: float = rng.randf_range(-0.28, 0.28)
					var confirmation: float = sin(TAU * (event_frequency + event_phase * 520.0) * event_phase) * 0.32
					value = (receipt + confirmation) * event_strength * envelope
				5:
					value = rng.randf_range(-1.0, 1.0) * event_strength * envelope
				6:
					var sub: float = sin(TAU * event_frequency * event_phase) * 0.70
					var beating: float = sin(TAU * 2.2 * event_phase) * sin(TAU * 83.0 * event_phase) * 0.25
					var hiss: float = rng.randf_range(-0.08, 0.08)
					value = (sub + beating + hiss) * event_strength * envelope
		event_playback.push_frame(Vector2(value, value))
