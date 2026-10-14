extends CharacterBody2D
## Side-view player controller with touch + keyboard support, attacks and dodge.
## Visual representation is a child ColorRect / Sprite placeholder.

signal attack_performed(quality: String)
signal player_died

@export var move_speed: float = 280.0
@export var jump_velocity: float = -420.0
@export var gravity: float = 980.0
@export var dodge_speed: float = 520.0
@export var dodge_duration: float = 0.25
@export var attack_cooldown: float = 0.28
@export var max_health: int = 100

@onready var sprite: Node2D = $Visual
@onready var hitbox: Area2D = $Hitbox
@onready var hurtbox: Area2D = $Hurtbox
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var attack_timer: Timer = $AttackTimer
@onready var dodge_timer: Timer = $DodgeTimer
@onready var invuln_timer: Timer = $InvulnTimer

var facing: int = 1  # 1 = right, -1 = left
var is_attacking: bool = false
var is_dodging: bool = false
var is_invulnerable: bool = false
var _input_dir: float = 0.0
var _touch_left: bool = false
var _touch_right: bool = false
var _touch_jump: bool = false
var _touch_attack: bool = false
var _touch_dodge: bool = false
var _last_timing_quality: String = "miss"

func _ready() -> void:
	hitbox.monitoring = false
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	# hurtbox reserved for future enemy attack areas
	attack_timer.one_shot = true
	dodge_timer.one_shot = true
	invuln_timer.one_shot = true
	attack_timer.timeout.connect(_on_attack_finished)
	dodge_timer.timeout.connect(_on_dodge_finished)
	invuln_timer.timeout.connect(_on_invuln_finished)
	GameState.player_max_health = max_health
	GameState.player_health = max_health

func _physics_process(delta: float) -> void:
	if GameState.is_game_over or GameState.is_paused:
		return

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Horizontal movement (skip while attacking or dodging)
	if not is_attacking and not is_dodging:
		_input_dir = _get_horizontal_input()
		velocity.x = _input_dir * move_speed
		if absf(_input_dir) > 0.1:
			facing = 1 if _input_dir > 0 else -1
			sprite.scale.x = facing
	elif is_dodging:
		velocity.x = facing * dodge_speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, move_speed * 4.0 * delta)

	move_and_slide()

	# Jump
	if _wants_jump() and is_on_floor() and not is_attacking and not is_dodging:
		velocity.y = jump_velocity

	# Attack
	if _wants_attack() and not is_attacking and not is_dodging and attack_timer.is_stopped():
		_perform_attack()

	# Dodge
	if _wants_dodge() and not is_dodging and not is_attacking and dodge_timer.is_stopped():
		_perform_dodge()

func _get_horizontal_input() -> float:
	var dir := 0.0
	if Input.is_action_pressed("move_left") or _touch_left:
		dir -= 1.0
	if Input.is_action_pressed("move_right") or _touch_right:
		dir += 1.0
	return dir

func _wants_jump() -> bool:
	return Input.is_action_just_pressed("jump") or _touch_jump

func _wants_attack() -> bool:
	return Input.is_action_just_pressed("attack") or _touch_attack

func _wants_dodge() -> bool:
	return Input.is_action_just_pressed("dodge") or _touch_dodge

# ---- Touch API (called by UI) ----
func set_touch_left(pressed: bool) -> void:
	_touch_left = pressed

func set_touch_right(pressed: bool) -> void:
	_touch_right = pressed

func set_touch_jump(pressed: bool) -> void:
	_touch_jump = pressed
	if not pressed:
		pass  # edge handled by just_pressed simulation via flag clear

func set_touch_attack(pressed: bool) -> void:
	_touch_attack = pressed

func set_touch_dodge(pressed: bool) -> void:
	_touch_dodge = pressed

func clear_touch_momentary() -> void:
	# Call after processing so "just pressed" works for touch
	_touch_jump = false
	_touch_attack = false
	_touch_dodge = false

# ---- Combat ----
func _perform_attack() -> void:
	is_attacking = true
	hitbox.monitoring = true
	attack_timer.start(attack_cooldown)
	var quality := BeatClock.evaluate_input()
	_last_timing_quality = quality
	attack_performed.emit(quality)
	if quality == "perfect":
		GameState.add_combo()
	elif quality in ("early", "late"):
		GameState.add_combo()
	else:
		GameState.break_combo()
	# Visual feedback via animation or modulate
	if sprite:
		sprite.modulate = Color(1.5, 1.5, 2.0) if quality == "perfect" else Color(1.2, 1.2, 1.4)
	# Simple scale punch
	var tween := create_tween()
	tween.tween_property(sprite, "scale", Vector2(facing * 1.2, 1.2), 0.05)
	tween.tween_property(sprite, "scale", Vector2(facing, 1.0), 0.1)

func _on_attack_finished() -> void:
	is_attacking = false
	hitbox.monitoring = false
	if sprite:
		sprite.modulate = Color.WHITE

func _perform_dodge() -> void:
	is_dodging = true
	is_invulnerable = true
	dodge_timer.start(dodge_duration)
	invuln_timer.start(dodge_duration + 0.1)
	if sprite:
		sprite.modulate = Color(0.6, 0.9, 1.5, 0.7)

func _on_dodge_finished() -> void:
	is_dodging = false
	velocity.x = 0.0

func _on_invuln_finished() -> void:
	is_invulnerable = false
	if sprite:
		sprite.modulate = Color.WHITE

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		var dmg := 10
		match _last_timing_quality:
			"perfect":
				dmg = 20
			"early", "late":
				dmg = 14
			_:
				dmg = 8
		body.take_damage(dmg, global_position)
		var mult := 1.5 if _last_timing_quality == "perfect" else 1.0
		GameState.add_score(25, mult)

func take_damage(amount: int, _from: Vector2 = Vector2.ZERO) -> void:
	if is_invulnerable or is_dodging or GameState.is_game_over:
		return
	GameState.apply_damage_to_player(amount)
	is_invulnerable = true
	invuln_timer.start(0.6)
	if sprite:
		sprite.modulate = Color(1.5, 0.3, 0.3)
	if GameState.player_health <= 0:
		player_died.emit()

func heal(amount: int) -> void:
	GameState.heal_player(amount)
