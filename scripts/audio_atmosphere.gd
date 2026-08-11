extends Node

# Prototype audio layer that requires no external audio assets.
# It generates low refrigerator/fluorescent ambience, rain noise and simple
# checkout / entrance / 03:17 cues in real time. Authored audio can replace
# this later without changing Night 1 gameplay logic.

var game: Node
var ambient_player: AudioStreamPlayer
var rain_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var ambient_playback: AudioStreamGeneratorPlayback
var rain_playback: AudioStreamGeneratorPlayback
var sfx_playback: AudioStreamGeneratorPlayback

var phase: float = 0.0
var sample_rate: float = 22050.0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var last_scanned_count: int = 0
var last_customer_id: int = 0
var anomaly_fired: bool = false
var sfx_frequency: float = 0.0
var sfx_remaining: float = 0.0
var sfx_phase: float = 0.0
var sfx_volume: float = 0.0

func _ready() -> void:
	rng.randomize()
	call_deferred("_initialize")

func _initialize() -> void:
	game = get_parent()
	ambient_player = _make_generator_player("InteriorAmbience", -22.0)
	rain_player = _make_generator_player("RainAmbience", -25.0)
	sfx_player = _make_generator_player("PrototypeSFX", -8.0)
	ambient_playback = ambient_player.get_stream_playback() as AudioStreamGeneratorPlayback
	rain_playback = rain_player.get_stream_playback() as AudioStreamGeneratorPlayback
	sfx_playback = sfx_player.get_stream_playback() as AudioStreamGeneratorPlayback

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
	_fill_ambient()
	_fill_rain()
	_fill_sfx()
	if not game:
		return
	_monitor_game_state(delta)

func _fill_ambient() -> void:
	if not ambient_playback:
		return
	var frames: int = ambient_playback.get_frames_available()
	for _i: int in range(frames):
		# Low electrical/refrigerator hum with a subtle upper harmonic.
		var hum: float = sin(phase * TAU * 58.0) * 0.10
		hum += sin(phase * TAU * 116.0) * 0.025
		hum += sin(phase * TAU * 29.0) * 0.018
		ambient_playback.push_frame(Vector2(hum, hum))
		phase += 1.0 / sample_rate
		if phase > 1.0:
			phase -= 1.0

func _fill_rain() -> void:
	if not rain_playback:
		return
	var frames: int = rain_playback.get_frames_available()
	for _i: int in range(frames):
		# Soft filtered-like noise. Kept quiet so it reads as rain outside glass.
		var noise: float = rng.randf_range(-0.07, 0.07)
		if rng.randf() < 0.0025:
			noise += rng.randf_range(0.05, 0.16)
		rain_playback.push_frame(Vector2(noise * 0.72, noise))

func _fill_sfx() -> void:
	if not sfx_playback:
		return
	var frames: int = sfx_playback.get_frames_available()
	for _i: int in range(frames):
		var sample: float = 0.0
		if sfx_remaining > 0.0:
			var envelope: float = clamp(sfx_remaining * 14.0, 0.0, 1.0)
			sample = sin(sfx_phase * TAU) * sfx_volume * envelope
			sfx_phase += sfx_frequency / sample_rate
			sfx_remaining -= 1.0 / sample_rate
		sfx_playback.push_frame(Vector2(sample, sample))

func _tone(frequency: float, duration: float, volume: float = 0.45) -> void:
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

	var customer: Node = game.get("active_customer") as Node
	if customer != null and is_instance_valid(customer):
		var customer_id: int = int(customer.get_instance_id())
		if customer_id != last_customer_id:
			last_customer_id = customer_id
			# Entrance chime: first note, followed by a small second note.
			_tone(740.0, 0.16, 0.25)
			get_tree().create_timer(0.18).timeout.connect(func() -> void: _tone(988.0, 0.20, 0.22))
	else:
		last_customer_id = 0

	var minutes_value: Variant = game.get("shift_minutes")
	if typeof(minutes_value) == TYPE_FLOAT or typeof(minutes_value) == TYPE_INT:
		var minutes: float = float(minutes_value)
		# Increase the electrical presence as 03:17 approaches.
		if ambient_player:
			ambient_player.volume_db = lerp(-22.0, -14.0, clamp((minutes - 180.0) / 17.0, 0.0, 1.0))
		if minutes >= 197.0 and not anomaly_fired:
			anomaly_fired = true
			_trigger_0317_audio()

func _trigger_0317_audio() -> void:
	# A short unstable sequence rather than a loud jumpscare.
	_tone(82.0, 0.72, 0.50)
	await get_tree().create_timer(0.18).timeout
	_tone(61.0, 0.62, 0.55)
	await get_tree().create_timer(0.42).timeout
	_tone(1480.0, 0.09, 0.32)
