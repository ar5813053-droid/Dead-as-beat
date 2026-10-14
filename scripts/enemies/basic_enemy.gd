extends CharacterBody2D
## Simple side-view enemy with patrol, chase and attack behavior.

signal died(enemy: Node)

@export var max_health: int = 40
@export var move_speed: float = 90.0
@export var attack_damage: int = 10
@export var attack_range: float = 60.0
@export var detect_range: float = 280.0
@export var attack_cooldown: float = 1.1
@export var gravity: float = 980.0

@onready var sprite: Node2D = $Visual
@onready var hurtbox: Area2D = $Hurtbox
@onready var attack_area: Area2D = $AttackArea
@onready var attack_timer: Timer = $AttackTimer
@onready var health_bar: ProgressBar = $HealthBar

var health: int
var player: Node2D = null
var state: String = "idle"  # idle, chase, attack, hurt, dead
var facing: int = -1
var _attack_ready: bool = true

func _ready() -> void:
	health = max_health
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health
	attack_timer.one_shot = true
	attack_timer.timeout.connect(func(): _attack_ready = true)
	# Find player later via group
	call_deferred("_find_player")

func _find_player() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _physics_process(delta: float) -> void:
	if state == "dead" or GameState.is_game_over or GameState.is_paused:
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	if player == null or not is_instance_valid(player):
		_find_player()
		velocity.x = 0
		move_and_slide()
		return

	var dist := global_position.distance_to(player.global_position)
	var dir_to_player := signf(player.global_position.x - global_position.x)

	match state:
		"idle":
			velocity.x = 0
			if dist < detect_range:
				state = "chase"
		"chase":
			facing = int(dir_to_player)
			if sprite:
				sprite.scale.x = facing
			velocity.x = dir_to_player * move_speed
			if dist <= attack_range and _attack_ready:
				state = "attack"
				_start_attack()
			elif dist > detect_range * 1.4:
				state = "idle"
		"attack":
			velocity.x = 0
		"hurt":
			velocity.x = move_toward(velocity.x, 0, 600 * delta)

	move_and_slide()

func _start_attack() -> void:
	_attack_ready = false
	attack_timer.start(attack_cooldown)
	# Brief wind-up then damage check
	await get_tree().create_timer(0.25).timeout
	if state != "attack" or not is_instance_valid(player):
		state = "chase"
		return
	if global_position.distance_to(player.global_position) <= attack_range * 1.2:
		if player.has_method("take_damage"):
			player.take_damage(attack_damage, global_position)
	state = "chase"

func take_damage(amount: int, from_pos: Vector2 = Vector2.ZERO) -> void:
	if state == "dead":
		return
	health = maxi(0, health - amount)
	if health_bar:
		health_bar.value = health
	state = "hurt"
	# Knockback
	var kb_dir := signf(global_position.x - from_pos.x)
	velocity.x = kb_dir * 180.0
	velocity.y = -80.0
	if sprite:
		sprite.modulate = Color(1.8, 0.4, 0.4)
	await get_tree().create_timer(0.2).timeout
	if sprite:
		sprite.modulate = Color.WHITE
	if health <= 0:
		_die()
	else:
		state = "chase"

func _die() -> void:
	state = "dead"
	velocity = Vector2.ZERO
	# Award score
	GameState.add_score(100)
	GameState.add_combo()
	died.emit(self)
	# Simple death effect
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.35)
	tween.tween_callback(queue_free)
