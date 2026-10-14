extends Node
## Simple audio manager. Uses placeholder metronome clicks until real music is added.

signal beat_played(beat_index: int)

var _metronome_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
const SFX_POOL_SIZE := 8

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_metronome_player = AudioStreamPlayer.new()
	_metronome_player.bus = "Master"
	add_child(_metronome_player)

	for i in SFX_POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_sfx_players.append(p)

func play_metronome_click() -> void:
	# Placeholder: generate a short click procedurally if no stream is set.
	# In a real build replace with a short WAV/OGG.
	if _metronome_player.stream == null:
		# Silent fallback - visual beat feedback is primary.
		pass
	else:
		_metronome_player.play()

func play_sfx(stream: AudioStream, volume_db: float = 0.0) -> void:
	if stream == null:
		return
	for p in _sfx_players:
		if not p.playing:
			p.stream = stream
			p.volume_db = volume_db
			p.play()
			return
	# All busy - reuse first
	_sfx_players[0].stream = stream
	_sfx_players[0].volume_db = volume_db
	_sfx_players[0].play()

func set_master_volume(linear: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(clampf(linear, 0.0, 1.0)))
