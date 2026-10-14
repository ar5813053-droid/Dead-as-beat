extends CharacterBody3D
## Third-person neon rhythm fighter — Kenney soldier (CC0) or procedural fallback.

signal attack_performed(quality: String)
signal player_died

@export var move_speed: float = 7.0
@export var sprint_speed: float = 11.0
@export var jump_velocity: float = 8.0
@export var dodge_speed: float = 16.0
@export var dodge_duration: float = 0.28
@export var attack_cooldown: float = 0.32
@export var max_health: int = 100
@export var turn_speed: float = 12.0
@export var gravity: float = 24.0

@onready var model_root: Node3D = $ModelRoot
@onready var anim_player: AnimationPlayer = $ModelRoot/AnimationPlayer if has_node("ModelRoot/AnimationPlayer") else null
@onready var hitbox: Area3D = $Hitbox
@onready var attack_timer: Timer = $AttackTimer
@onready var dodge_timer: Timer = $DodgeTimer
@onready var invuln_timer: Timer = $InvulnTimer

var facing_yaw: float = 0.0
var is_attacking: bool = false
var is_dodging: bool = false
var is_invulnerable: bool = false
var _input_dir: Vector2 = Vector2.ZERO
var _touch_move: Vector2 = Vector2.ZERO
var _touch_attack: bool = false
var _touch_dodge: bool = false
var _touch_jump: bool = false
var _camera: Camera3D

func _ready() -> void:
	GameState.player_max_health = max_health
	GameState.player_health = max_health
	if hitbox:
		hitbox.monitoring = false
		hitbox.body_entered.connect(_on_hitbox_body_entered)
		hitbox.area_entered.connect(_on_hitbox_area_entered)
	attack_timer.one_shot = true
	dodge_timer.one_shot = true
	invuln_timer.one_shot = true
	attack_timer.timeout.connect(_on_attack_finished)
	dodge_timer.timeout.connect(_on_dodge_finished)
	invuln_timer.timeout.connect(_on_invuln_finished)
	_play_anim("Idle")

func set_camera(cam: Camera3D) -> void:
	_camera = cam

func _physics_process(delta: float) -> void:
	if GameState.is_game_over or GameState.is_paused:
		return
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if velocity.y < 0.0:
			velocity.y = 0.0

	var move := _get_move_input()
	if not is_attacking and not is_dodging:
		var target_speed := sprint_speed if move.length() > 0.85 else move_speed
		var dir3 := Vector3(move.x, 0.0, move.y)
		if dir3.length() > 0.05:
			dir3 = dir3.normalized()
			# Camera-relative movement
			if _camera:
				var basis := _camera.global_transform.basis
				var forward := -basis.z
				forward.y = 0.0
				forward = forward.normalized()
				var right := basis.x
				right.y = 0.0
				right = right.normalized()
				dir3 = (right * move.x + forward * -move.y).normalized()
			velocity.x = dir3.x * target_speed
			velocity.z = dir3.z * target_speed
			facing_yaw = lerp_angle(facing_yaw, atan2(dir3.x, dir3.z), turn_speed * delta)
			if model_root:
				model_root.rotation.y = facing_yaw
			_play_anim("Walk" if target_speed <= move_speed + 0.1 else "Run")
		else:
			velocity.x = move_toward(velocity.x, 0.0, move_speed * 8.0 * delta)
			velocity.z = move_toward(velocity.z, 0.0, move_speed * 8.0 * delta)
			if is_on_floor() and not is_attacking:
				_play_anim("Idle")
	elif is_dodging:
		var d := Vector3(sin(facing_yaw), 0.0, cos(facing_yaw))
		velocity.x = d.x * dodge_speed
		velocity.z = d.z * dodge_speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, move_speed * 10.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, move_speed * 10.0 * delta)

	move_and_slide()

	if _wants_jump() and is_on_floor() and not is_attacking and not is_dodging:
		velocity.y = jump_velocity
		_play_anim("Jump")
	if _wants_attack() and not is_attacking and not is_dodging and attack_timer.is_stopped():
		_perform_attack()
	if _wants_dodge() and not is_dodging and not is_attacking and dodge_timer.is_stopped():
		_perform_dodge()

func _get_move_input() -> Vector2:
	var v := Vector2.ZERO
	v.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	v.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	if _touch_move.length() > 0.05:
		v = _touch_move
	return v.limit_length(1.0)

func _wants_jump() -> bool:
	return Input.is_action_just_pressed("jump") or _touch_jump

func _wants_attack() -> bool:
	return Input.is_action_just_pressed("attack") or _touch_attack

func _wants_dodge() -> bool:
	return Input.is_action_just_pressed("dodge") or _touch_dodge

# Touch API
func set_touch_move(v: Vector2) -> void:
	_touch_move = v

func set_touch_attack(pressed: bool) -> void:
	_touch_attack = pressed

func set_touch_dodge(pressed: bool) -> void:
	_touch_dodge = pressed

func set_touch_jump(pressed: bool) -> void:
	_touch_jump = pressed

func clear_touch_momentary() -> void:
	_touch_attack = false
	_touch_dodge = false
	_touch_jump = false

func _perform_attack() -> void:
	is_attacking = true
	if hitbox:
		hitbox.monitoring = true
	attack_timer.start(attack_cooldown)
	var quality := BeatClock.evaluate_input()
	attack_performed.emit(quality)
	if quality == "perfect" or quality in ["early", "late"]:
		GameState.add_combo()
		GameState.add_score(100, 1.5 if quality == "perfect" else 1.0)
	else:
		GameState.break_combo()
		GameState.add_score(40, 0.5)
	_play_anim("Attack")
	# Neon flash
	if model_root:
		var meshes := model_root.find_children("*", "MeshInstance3D", true, false)
		for m in meshes:
			if m is MeshInstance3D and m.material_override == null:
				pass

func _on_attack_finished() -> void:
	is_attacking = false
	if hitbox:
		hitbox.monitoring = false
	_play_anim("Idle")

func _perform_dodge() -> void:
	is_dodging = true
	is_invulnerable = true
	dodge_timer.start(dodge_duration)
	invuln_timer.start(dodge_duration + 0.12)
	_play_anim("Dodge")

func _on_dodge_finished() -> void:
	is_dodging = false
	velocity.x = 0.0
	velocity.z = 0.0

func _on_invuln_finished() -> void:
	is_invulnerable = false

func take_hit(amount: int) -> void:
	if is_invulnerable or is_dodging:
		return
	GameState.apply_damage_to_player(amount)
	_play_anim("Hit")
	if GameState.player_health <= 0:
		player_died.emit()
		_play_anim("Death")

func _on_hitbox_body_entered(body: Node3D) -> void:
	if body.has_method("take_hit"):
		var q := BeatClock.evaluate_input()
		var dmg := 25 if q == "perfect" else (18 if q in ["early", "late"] else 10)
		body.take_hit(dmg)

func _on_hitbox_area_entered(area: Area3D) -> void:
	var p := area.get_parent()
	if p and p.has_method("take_hit"):
		var q := BeatClock.evaluate_input()
		var dmg := 25 if q == "perfect" else (18 if q in ["early", "late"] else 10)
		p.take_hit(dmg)

func _play_anim(name: String) -> void:
	if anim_player == null:
		return
	if anim_player.has_animation(name):
		if anim_player.current_animation != name:
			anim_player.play(name)
	else:
		# Try lowercase / common aliases from Kenney packs
		for alt in [name.to_lower(), "idle", "Idle", "walk", "Walk"]:
			if anim_player.has_animation(alt):
				anim_player.play(alt)
				return
