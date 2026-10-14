extends Node3D
## Arena runtime: Geonosis map + Kenney floor collision, wave spawns, beat lights.

@onready var player_spawn: Marker3D = $PlayerSpawn
@onready var enemy_spawns: Node3D = $EnemySpawns
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var camera_pivot: Node3D = $CameraPivot
@onready var beat_lights: Node3D = $BeatLights
@onready var touch: CanvasLayer = $TouchControls

var player: CharacterBody3D
var _wave: int = 0
var _enemies_alive: int = 0

const ENEMY_SCENES := [
	"res://scenes/enemies/enemy_3d.tscn",
	"res://scenes/enemies/enemy_mma.tscn",
]

func _ready() -> void:
	GameState.reset_run()
	BeatClock.bpm = GameState.bpm
	BeatClock.start()
	BeatClock.beat.connect(_on_beat)
	_spawn_player()
	_spawn_wave()
	if touch and touch.has_method("bind_player"):
		touch.bind_player(player)

func _process(delta: float) -> void:
	if player and is_instance_valid(player) and camera_pivot:
		var target := player.global_position + Vector3(0, 1.5, 0)
		camera_pivot.global_position = camera_pivot.global_position.lerp(target, 5.5 * delta)
	if player and player.has_method("clear_touch_momentary"):
		player.clear_touch_momentary()

func _spawn_player() -> void:
	var scene := preload("res://scenes/player/player_3d.tscn")
	player = scene.instantiate()
	add_child(player)
	player.global_position = player_spawn.global_position if player_spawn else Vector3(0, 1, 4)
	if player.has_method("set_camera"):
		player.set_camera(camera)

func _spawn_wave() -> void:
	_wave += 1
	var count := mini(2 + _wave, 5)
	var markers: Array = enemy_spawns.get_children() if enemy_spawns else []
	for i in count:
		var path: String = ENEMY_SCENES[i % ENEMY_SCENES.size()]
		# Boss every 4th wave
		if _wave % 4 == 0 and i == 0:
			path = "res://scenes/enemies/enemy_boss.tscn"
		var e = load(path).instantiate()
		add_child(e)
		if markers.size() > 0:
			var m = markers[i % markers.size()]
			e.global_position = m.global_position + Vector3(randf_range(-1.2, 1.2), 0, randf_range(-1.2, 1.2))
		else:
			e.global_position = Vector3(randf_range(-8, 8), 1.0, randf_range(-8, 8))
		if e.has_method("set_player"):
			e.set_player(player)
		_enemies_alive += 1
		e.tree_exited.connect(_on_enemy_gone)

func _on_enemy_gone() -> void:
	_enemies_alive = maxi(0, _enemies_alive - 1)
	if _enemies_alive <= 0 and not GameState.is_game_over:
		await get_tree().create_timer(1.6).timeout
		if not GameState.is_game_over:
			_spawn_wave()

func _on_beat(_idx: int) -> void:
	if beat_lights == null:
		return
	for c in beat_lights.get_children():
		if c is OmniLight3D:
			var L: OmniLight3D = c
			L.light_energy = 2.2
			var tw := create_tween()
			tw.tween_property(L, "light_energy", 0.55, 0.22)
