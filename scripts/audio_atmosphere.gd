extends Node

# Legacy atmosphere bed retained only for rain. M8 owns mechanical ambience,
# fluorescent buzz, footsteps and gameplay/event SFX so sounds are not doubled.

var game: Node
var rain_player: AudioStreamPlayer
var rain_playback: AudioStreamGeneratorPlayback
var rain_phase: float = 0.0
var sample_rate: float = 22050.0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	call_deferred("_initialize")

func _initialize() -> void:
	game = get_parent()
	rng.randomize()
	rain_player = _make_generator_player("Rain", -31.0)
	rain_playback = rain_player.get_stream_playback() as AudioStreamGeneratorPlayback
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

func _process(_delta: float) -> void:
	if game == null or not is_instance_valid(game):
		return
	_fill_rain()

func _fill_rain() -> void:
	if rain_playback == null:
		return
	var frames: int = rain_playback.get_frames_available()
	for _i: int in range(frames):
		rain_phase += 1.0 / sample_rate
		var gust: float = 0.78 + sin(TAU * 0.11 * rain_phase) * 0.18
		var noise: float = rng.randf_range(-1.0, 1.0) * 0.029 * gust
		var glass_texture: float = sin(TAU * 3.7 * rain_phase) * 0.0025
		var value: float = noise + glass_texture
		rain_playback.push_frame(Vector2(value * 0.96, value))
