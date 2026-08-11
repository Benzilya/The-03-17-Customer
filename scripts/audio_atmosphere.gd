extends Node

var game: Node
var ambient_player: AudioStreamPlayer
var rain_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var ambient_playback: AudioStreamGeneratorPlayback
var rain_playback: AudioStreamGeneratorPlayback
var sfx_playback: AudioStreamGeneratorPlayback
var ambient_phase: float = 0.0
var rain_phase: float = 0.0
var sfx_phase: float = 0.0
var sfx_frequency: float = 440.0
var sfx_remaining: float = 0.0
var sfx_volume: float = 0.25
var sample_rate: float = 22050.0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var last_scanned_count: int = 0
var last_customer_id: int = 0
var anomaly_fired: bool = false

func _ready() -> void:
	call_deferred("_initialize")

func _initialize() -> void:
	game = get_parent()
	rng.randomize()
	ambient_player = _make_generator_player("Ambient", -22.0)
	rain_player = _make_generator_player("Rain", -25.0)
	sfx_player = _make_generator_player("SFX", -5.0)
	ambient_playback = ambient_player.get_stream_playback() as AudioStreamGeneratorPlayback
	rain_playback = rain_player.get_stream_playback() as AudioStreamGeneratorPlayback
	sfx_playback = sfx_player.get_stream_playback() as AudioStreamGeneratorPlayback
	set_process(true)

func _make_generator_player(node_name: String, volume_db: float) -> AudioStreamPlayer:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.name = node_name
	var generator: AudioStreamGenerator = AudioStreamGenerator.new()
	generator.mix_rate = sample_rate
	generator.buffer_length = 0.35
	player.stream = generator
	player.volume_db = volume_db
	add_child(player)
	player.play()
	return player

func _process(delta: float) -> void:
	if game == null or not is_instance_valid(game):
		return
	_fill_ambient()
	_fill_rain()
	_fill_sfx()
	_monitor_game_state(delta)

func _fill_ambient() -> void:
	if ambient_playback == null:
		return
	var frames: int = ambient_playback.get_frames_available()
	for _i: int in range(frames):
		ambient_phase += 1.0 / sample_rate
		var hum: float = sin(TAU * 60.0 * ambient_phase) * 0.035 + sin(TAU * 120.0 * ambient_phase) * 0.012
		var value: float = hum + rng.randf_range(-0.006, 0.006)
		ambient_playback.push_frame(Vector2(value, value))

func _fill_rain() -> void:
	if rain_playback == null:
		return
	var frames: int = rain_playback.get_frames_available()
	for _i: int in range(frames):
		rain_phase += 1.0 / sample_rate
		var noise: float = rng.randf_range(-1.0, 1.0) * 0.032
		var pulse: float = sin(TAU * 0.7 * rain_phase) * 0.006
		var value: float = noise + pulse
		rain_playback.push_frame(Vector2(value, value))

func _fill_sfx() -> void:
	if sfx_playback == null:
		return
	var frames: int = sfx_playback.get_frames_available()
	for _i: int in range(frames):
		var value: float = 0.0
		if sfx_remaining > 0.0:
			sfx_phase += 1.0 / sample_rate
			sfx_remaining -= 1.0 / sample_rate
			var envelope: float = clampf(sfx_remaining * 12.0, 0.0, 1.0)
			value = sin(TAU * sfx_frequency * sfx_phase) * sfx_volume * envelope
		sfx_playback.push_frame(Vector2(value, value))

func _tone(frequency: float, duration: float, volume: float) -> void:
	sfx_frequency = frequency
	sfx_remaining = duration
	sfx_volume = volume
	sfx_phase = 0.0

func _monitor_game_state(_delta: float) -> void:
	var scanned_value: Variant = game.get("scanned_count")
	if typeof(scanned_value) == TYPE_INT:
		var scanned: int = int(scanned_value)
		if scanned > last_scanned_count:
			last_scanned_count = scanned
			_tone(1320.0, 0.075, 0.38)
		elif scanned < last_scanned_count:
			last_scanned_count = scanned

	# game.active_customer can temporarily point at an object that was queued for
	# deletion while the next customer is spawned. Never cast that Variant before
	# checking validity: Godot 4.7 reports "Trying to cast a freed object".
	var customer_value: Variant = game.get("active_customer")
	if typeof(customer_value) == TYPE_OBJECT and customer_value != null and is_instance_valid(customer_value):
		var customer_object: Object = customer_value as Object
		var customer_id: int = int(customer_object.get_instance_id())
		if customer_id != last_customer_id:
			last_customer_id = customer_id
			_tone(740.0, 0.16, 0.25)
			get_tree().create_timer(0.18).timeout.connect(func() -> void: _tone(988.0, 0.20, 0.22))
	else:
		last_customer_id = 0

	var minutes_value: Variant = game.get("shift_minutes")
	if typeof(minutes_value) == TYPE_FLOAT or typeof(minutes_value) == TYPE_INT:
		var minutes: float = float(minutes_value)
		if ambient_player:
			ambient_player.volume_db = lerp(-22.0, -14.0, clamp((minutes - 180.0) / 17.0, 0.0, 1.0))
		if minutes >= 197.0 and not anomaly_fired:
			anomaly_fired = true
			_trigger_0317_audio()

func _trigger_0317_audio() -> void:
	_tone(82.0, 0.72, 0.50)
	await get_tree().create_timer(0.18).timeout
	_tone(61.0, 0.62, 0.55)
	await get_tree().create_timer(0.42).timeout
	_tone(49.0, 1.15, 0.45)
