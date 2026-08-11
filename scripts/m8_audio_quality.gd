extends Node

# M8 audio-quality layer. Procedural placeholders keep the repository self-
# contained while establishing the final mix structure: mechanical ambience,
# fluorescent electricity, movement foley and CCTV tension.

var game: Node
var player_body: CharacterBody3D
var mechanical_player: AudioStreamPlayer
var electrical_player: AudioStreamPlayer
var foley_player: AudioStreamPlayer
var mechanical_playback: AudioStreamGeneratorPlayback
var electrical_playback: AudioStreamGeneratorPlayback
var foley_playback: AudioStreamGeneratorPlayback

var sample_rate: float = 22050.0
var mechanical_phase: float = 0.0
var electrical_phase: float = 0.0
var foley_phase: float = 0.0
var footstep_remaining: float = 0.0
var footstep_strength: float = 0.0
var step_clock: float = 0.0
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
	mechanical_playback = mechanical_player.get_stream_playback() as AudioStreamGeneratorPlayback
	electrical_playback = electrical_player.get_stream_playback() as AudioStreamGeneratorPlayback
	foley_playback = foley_player.get_stream_playback() as AudioStreamGeneratorPlayback
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
	_fill_mechanical()
	_fill_electrical()
	_fill_foley()

func _update_mix() -> void:
	var minutes_value: Variant = game.get("shift_minutes")
	var minutes: float = float(minutes_value) if typeof(minutes_value) in [TYPE_FLOAT, TYPE_INT] else 0.0
	var cctv_value: Variant = game.get("cctv_open")
	var cctv_open: bool = bool(cctv_value) if typeof(cctv_value) == TYPE_BOOL else false
	var tension: float = clampf((minutes - 175.0) / 22.0, 0.0, 1.0)
	mechanical_player.volume_db = lerpf(-24.0, -20.0, tension)
	electrical_player.volume_db = (-21.0 if cctv_open else -28.0) + tension * 3.0

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
		# Refrigerator compressor: low fundamental plus slow load modulation.
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
		# Fluorescent ballast: thin 120 Hz buzz with subtle unstable harmonics.
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
