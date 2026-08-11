extends Node

# M8 final procedural audio layer. It owns store machinery, electricity,
# movement foley and event SFX; audio_atmosphere.gd supplies rain only.

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
var last_customer_position: Vector3 = Vector3.ZERO
var last_scanned_count: int = 0
var last_cctv_open: bool = false
var last_current_items_count: int = 0
var anomaly_event_fired: bool = false
var cctv_noise_clock: float = 1.8
var anomaly_dropout: float = 0.0
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
	event_player = _make_player("M8Events", -8.0)
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
	if anomaly_dropout > 0.0:
		anomaly_dropout = maxf(0.0, anomaly_dropout - delta)
	_update_footsteps(delta)
	_update_mix(delta)
	_monitor_events()
	_fill_mechanical()
	_fill_electrical()
	_fill_foley()
	_fill_events()

func _update_mix(delta: float) -> void:
	var minutes_value: Variant = game.get("shift_minutes")
	var minutes: float = float(minutes_value) if typeof(minutes_value) in [TYPE_FLOAT, TYPE_INT] else 0.0
	var cctv_value: Variant = game.get("cctv_open")
	var cctv_open: bool = bool(cctv_value) if typeof(cctv_value) == TYPE_BOOL else false
	var tension: float = clampf((minutes - 175.0) / 22.0, 0.0, 1.0)
	var dropout_db: float = -13.0 if anomaly_dropout > 0.0 else 0.0
	mechanical_player.volume_db = lerpf(-25.0, -21.0, tension) + dropout_db
	electrical_player.volume_db = (-22.0 if cctv_open else -29.0) + tension * 3.0 + dropout_db
	if cctv_open:
		cctv_noise_clock -= delta
		if cctv_noise_clock <= 0.0:
			_play_cctv_static(0.10, 0.13)
			cctv_noise_clock = rng.randf_range(2.2, 4.8)
	else:
		cctv_noise_clock = minf(cctv_noise_clock, 1.4)

func _monitor_events() -> void:
	var customer_value: Variant = game.get("active_customer")
	var customer_id: int = 0
	if typeof(customer_value) == TYPE_OBJECT and customer_value != null and is_instance_valid(customer_value):
		var customer_object: Object = customer_value as Object
		customer_id = int(customer_object.get_instance_id())
		if customer_object is Node3D:
			last_customer_position = (customer_object as Node3D).global_position
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
			_play_cctv_static(0.32, 0.30)

	var minutes_value: Variant = game.get("shift_minutes")
	if typeof(minutes_value) in [TYPE_FLOAT, TYPE_INT]:
		var minutes: float = float(minutes_value)
		if minutes >= 197.0 and not anomaly_event_fired:
			anomaly_event_fired = true
			_start_0317_sequence()

func _start_0317_sequence() -> void:
	anomaly_dropout = 1.35
	_play_event(6, 54.0, 0.50, 1.75)
	var timer_a: SceneTreeTimer = get_tree().create_timer(0.62)
	timer_a.timeout.connect(_0317_false_chime)
	var timer_b: SceneTreeTimer = get_tree().create_timer(1.28)
	timer_b.timeout.connect(_0317_return_pressure)

func _0317_false_chime() -> void:
	# A wrong, lower door chime while CCTV insists nobody arrived.
	_play_event(7, 415.0, 0.20, 0.48)

func _0317_return_pressure() -> void:
	_play_event(6, 43.0, 0.34, 1.10)

func _play_event(mode: int, frequency: float, strength: float, duration: float) -> void:
	event_mode = mode
	event_frequency = frequency
	event_strength = strength
	event_remaining = duration
	event_phase = 0.0

func _play_chime() -> void:
	_play_event(1, 880.0, 0.28, 0.55)

func _play_door_close() -> void:
	_play_event(2, 105.0, 0.22, 0.22)

func _play_scanner() -> void:
	_play_event(3, 1480.0, 0.38, 0.09)

func _play_payment() -> void:
	_play_event(4, 620.0, 0.26, 0.48)

func _play_cctv_static(duration: float, strength: float) -> void:
	# Do not overwrite the main 03:17 pressure sting with routine static.
	if event_mode == 6 and event_remaining > 0.0:
		return
	_play_event(5, 0.0, strength, duration)

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
		footstep_strength = 0.55 if running else 0.36
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
				7:
					var wrong_bell: float = sin(TAU * event_frequency * event_phase)
					wrong_bell += sin(TAU * event_frequency * 1.37 * event_phase) * 0.32
					value = wrong_bell * event_strength * envelope
		event_playback.push_frame(Vector2(value, value))
