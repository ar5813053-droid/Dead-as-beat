extends Node
## Frame-rate independent beat clock driven by BPM.
## Emits signals for beat, subdivision and timing windows.

signal beat(beat_index: int)
signal subdivision(sub_index: int, beat_index: int)
signal timing_window(quality: String)  # "perfect", "early", "late", "miss"

@export var bpm: float = 120.0:
	set(value):
		bpm = maxf(value, 30.0)
		_seconds_per_beat = 60.0 / bpm
		_seconds_per_sub = _seconds_per_beat / float(subdivisions)

@export var subdivisions: int = 4  # 4 = 16th notes
@export var perfect_window: float = 0.06  # seconds
@export var good_window: float = 0.12

var _seconds_per_beat: float = 0.5
var _seconds_per_sub: float = 0.125
var _elapsed: float = 0.0
var _beat_index: int = 0
var _sub_index: int = 0
var _running: bool = false
var _last_input_time: float = -999.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_seconds_per_beat = 60.0 / bpm
	_seconds_per_sub = _seconds_per_beat / float(subdivisions)

func start(from_beat: int = 0) -> void:
	_beat_index = from_beat
	_sub_index = 0
	_elapsed = 0.0
	_running = true

func stop() -> void:
	_running = false

func reset() -> void:
	stop()
	_beat_index = 0
	_sub_index = 0
	_elapsed = 0.0

func _process(delta: float) -> void:
	if not _running:
		return
	_elapsed += delta

	while _elapsed >= _seconds_per_sub:
		_elapsed -= _seconds_per_sub
		_sub_index += 1
		if _sub_index >= subdivisions:
			_sub_index = 0
			_beat_index += 1
			beat.emit(_beat_index)
			AudioManager.play_metronome_click()
		subdivision.emit(_sub_index, _beat_index)

## Call this when the player presses attack. Returns timing quality string.
func evaluate_input() -> String:
	if not _running:
		return "miss"
	# Distance to nearest subdivision boundary (0 or next)
	var time_to_prev := _elapsed
	var time_to_next := _seconds_per_sub - _elapsed
	var closest := minf(time_to_prev, time_to_next)

	var quality: String
	if closest <= perfect_window:
		quality = "perfect"
	elif closest <= good_window:
		quality = "early" if time_to_prev < time_to_next else "late"
	else:
		quality = "miss"

	timing_window.emit(quality)
	return quality

func get_beat_progress() -> float:
	## 0.0 at start of beat, 1.0 just before next beat
	return (_sub_index + (_elapsed / _seconds_per_sub)) / float(subdivisions)

func get_time_to_next_beat() -> float:
	var remaining_subs := subdivisions - _sub_index - 1
	return remaining_subs * _seconds_per_sub + (_seconds_per_sub - _elapsed)

func is_running() -> bool:
	return _running
