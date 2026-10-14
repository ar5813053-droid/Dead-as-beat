extends Node3D
## Arena runtime with scale-safe camera and diagnostic logs.

@onready var player_spawn: Marker3D = $PlayerSpawn
@onready var enemy_spawns: Node3D = $EnemySpawns
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var camera_pivot: Node3D = $CameraPivot
@onready var beat_lights: Node3D = $BeatLights
@onready var touch: CanvasLayer = $TouchControls
@onready var geonosis: Node3D = $Geonosis

var player: CharacterBody3D
var _wave: int = 0
var _enemies_alive: int = 0

const ENEMY_SCENES := [
	"res://scenes/enemies/enemy_3d.tscn",
	"res://scenes/enemies/enemy_mma.tscn",
]

func _ready() -> void:
	print("[Arena] ready — mobile 3D combat")
	GameState.reset_run()
	BeatClock.bpm = GameState.bpm
	BeatClock.start()
	BeatClock.beat.connect(_on_beat)
	if geonosis:
		print("[Arena] Geonosis transform: ", geonosis.global_transform)
		print("[Arena] Geonosis children: ", geonosis.get_child_count())
	_spawn_player()
	_spawn_wave()
	if touch and touch.has_method("bind_player"):
		touch.bind_player(player)
	if camera:
		print("[Arena] Camera global: ", camera.global_position, " current=", camera.current, " far=", camera.far)
	if player:
		print("[Arena] Player global: ", player.global_position)

func _process(delta: float) -> void:
	if player and is_instance_valid(player) and camera_pivot:
		var target := player.global_position + Vector3(0, 1.6, 0)
		camera_pivot.global_position = camera_pivot.global_position.lerp(target, 6.0 * delta)
	if player and player.has_method("clear_touch_momentary"):
		player.clear_touch_momentary()

func _spawn_player() -> void:
	var scene: PackedScene = load("res://scenes/player/player_3d.tscn")
	if scene == null:
		push_error("[Arena] Failed to load player_3d.tscn")
		return
	player = scene.instantiate()
	add_child(player)
	var spawn := player_spawn.global_position if player_spawn else Vector3(0, 1, 8)
	player.global_position = spawn
	if player.has_method("set_camera"):
		player.set_camera(camera)
	print("[Arena] Player spawned at ", player.global_position, " children=", player.get_child_count())
	# Log model mesh presence
	var meshes := player.find_children("*", "MeshInstance3D", true, false)
	print("[Arena] Player MeshInstance3D count: ", meshes.size())
	for m in meshes.slice(0, 3):
		print("[Arena]  mesh ", m.name, " visible=", m.visible, " pos=", m.global_position)

func _spawn_wave() -> void:
	_wave += 1
	var count := mini(2 + _wave, 5)
	var markers: Array = enemy_spawns.get_children() if enemy_spawns else []
	print("[Arena] Wave ", _wave, " spawning ", count)
	for i in count:
		var path: String = ENEMY_SCENES[i % ENEMY_SCENES.size()]
		if _wave % 4 == 0 and i == 0:
			path = "res://scenes/enemies/enemy_boss.tscn"
		var packed: PackedScene = load(path)
		if packed == null:
			push_error("[Arena] Failed to load " + path)
			continue
		var e = packed.instantiate()
		add_child(e)
		if markers.size() > 0:
			var m = markers[i % markers.size()]
			e.global_position = m.global_position + Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0))
		else:
			e.global_position = Vector3(randf_range(-6, 6), 1.0, randf_range(-6, 6))
		if e.has_method("set_player"):
			e.set_player(player)
		_enemies_alive += 1
		e.tree_exited.connect(_on_enemy_gone)
	print("[Arena] Enemies alive: ", _enemies_alive)

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
			L.light_energy = 2.0
			var tw := create_tween()
			tw.tween_property(L, "light_energy", 0.8, 0.22)
