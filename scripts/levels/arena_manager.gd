extends Node2D
## Controls the vertical-slice arena: spawns enemies, starts beat clock, win condition.

@export var bpm: float = 120.0
@export var enemies_to_spawn: int = 4
@export var spawn_interval: float = 3.5

@onready var player: CharacterBody2D = $Player
@onready var spawn_points: Node2D = $SpawnPoints
@onready var enemy_container: Node2D = $Enemies
@onready var touch_controls: Control = $UI/TouchControls
@onready var hud: CanvasLayer = $UI/HUD
@onready var pause_menu: CanvasLayer = $UI/PauseMenu
@onready var result_screen: CanvasLayer = $UI/ResultScreen

var _enemies_alive: int = 0
var _spawned: int = 0
var _spawn_timer: float = 0.0
var _enemy_scene: PackedScene

func _ready() -> void:
	_enemy_scene = load("res://scenes/enemies/basic_enemy.tscn")
	GameState.bpm = bpm
	BeatClock.bpm = bpm
	BeatClock.reset()
	BeatClock.start()
	if touch_controls and player:
		touch_controls.bind_player(player)
	player.add_to_group("player")
	player.player_died.connect(_on_player_died)
	_spawn_timer = 1.0  # first enemy soon
	# Win when all enemies defeated
	# Also listen for pause key
	set_process(true)

func _process(delta: float) -> void:
	if GameState.is_game_over or GameState.is_paused:
		return
	if Input.is_action_just_pressed("pause"):
		GameState.toggle_pause()

	# Clear momentary touch flags each frame after input processed
	if player and player.has_method("clear_touch_momentary"):
		player.clear_touch_momentary()

	if _spawned < enemies_to_spawn:
		_spawn_timer -= delta
		if _spawn_timer <= 0.0:
			_spawn_enemy()
			_spawn_timer = spawn_interval

func _spawn_enemy() -> void:
	if _enemy_scene == null:
		return
	var pts := spawn_points.get_children()
	if pts.is_empty():
		return
	var pt: Node2D = pts[_spawned % pts.size()]
	var enemy: Node2D = _enemy_scene.instantiate()
	enemy.global_position = pt.global_position
	enemy_container.add_child(enemy)
	if enemy.has_signal("died"):
		enemy.died.connect(_on_enemy_died)
	_enemies_alive += 1
	_spawned += 1

func _on_enemy_died(_e: Node) -> void:
	_enemies_alive = maxi(0, _enemies_alive - 1)
	if _spawned >= enemies_to_spawn and _enemies_alive <= 0:
		# Victory
		await get_tree().create_timer(0.8).timeout
		GameState.trigger_game_over(true)

func _on_player_died() -> void:
	BeatClock.stop()
	GameState.trigger_game_over(false)
