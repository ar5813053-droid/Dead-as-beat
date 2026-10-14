extends CharacterBody3D
## Third-person rhythm combat player.
## Primary model: mr_sexy_man_fighter (13 Kung Fu clips). Locomotion is controller-driven.

signal attack_performed(quality: String)
signal player_died

@export var move_speed: float = 6.5
@export var sprint_speed: float = 10.0
@export var jump_velocity: float = 8.0
@export var dodge_speed: float = 15.0
@export var dodge_duration: float = 0.32
@export var attack_cooldown: float = 0.45
@export var max_health: int = 100
@export var turn_speed: float = 14.0
@export var gravity: float = 24.0
@export var model_scale: float = 1.0

@onready var model_root: Node3D = $ModelRoot
@onready var hitbox: Area3D = $Hitbox
@onready var attack_timer: Timer = $AttackTimer
@onready var dodge_timer: Timer = $DodgeTimer
@onready var invuln_timer: Timer = $InvulnTimer

var anim_player: AnimationPlayer
var facing_yaw: float = 0.0
var is_attacking: bool = false
var is_dodging: bool = false
var is_invulnerable: bool = false
var combo_index: int = 0
var _touch_move: Vector2 = Vector2.ZERO
var _touch_attack: bool = false
var _touch_dodge: bool = false
var _touch_jump: bool = false
var _camera: Camera3D

# Clip name candidates for Sexy Man + Kenney fallbacks
const IDLE_CLIPS := ["Kung Fu idle guard", "Kung Fu idle guard2", "Kung Fu idle guard 3", "idle", "Idle", "static"]
const WALK_CLIPS := ["walk", "Walk", "sprint"]
const ATTACK_CLIPS := [
	"Kung Fu sexy punch",
	"Kung Fu sexy no look punch",
	"Kung Fu double push punch",
	"Kung Fu phantom punch",
	"Kung Fu sexy kick",
	"Kung Fu spinning elbow",
	"attack-melee-right",
	"attack-kick-right",
	"Attack",
]
const HEAVY_CLIPS := ["Kung Fu double head slam", "Kung Fu the misleader", "Kung Fu fake headbutt push"]
const HIT_CLIPS := ["Hit", "hit", "die", "Death"]
const DODGE_CLIPS := ["Dodge", "dodge", "jump", "Jump"]
const DEATH_CLIPS := ["die", "Death", "death"]

func _ready() -> void:
	GameState.player_max_health = max_health
	GameState.player_health = max_health
	anim_player = AnimUtil.find_animation_player(model_root)
	if anim_player:
		print("[Player] clips: ", AnimUtil.list_clips(anim_player))
	if hitbox:
		hitbox.monitoring = false
		hitbox.body_entered.connect(_on_hitbox_body_entered)
		hitbox.area_entered.connect(_on_hitbox_area_entered)
	attack_timer.one_shot = true
	dodge_timer.one_shot = true
	invuln_timer.one_shot = true
	attack_timer.timeout.connect(_on_attack_finished)
	dodge_timer.timeout.connect(_on_dodge_finished)
	invuln_timer.timeout.connect(func(): is_invulnerable = false)
	_play(IDLE_CLIPS)

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
		var spd := sprint_speed if move.length() > 0.85 else move_speed
		var dir3 := Vector3(move.x, 0.0, move.y)
		if dir3.length() > 0.05:
			dir3 = dir3.normalized()
			if _camera:
				var basis := _camera.global_transform.basis
				var forward := -basis.z
				forward.y = 0.0
				forward = forward.normalized()
				var right := basis.x
				right.y = 0.0
				right = right.normalized()
				dir3 = (right * move.x + forward * -move.y).normalized()
			velocity.x = dir3.x * spd
			velocity.z = dir3.z * spd
			facing_yaw = lerp_angle(facing_yaw, atan2(dir3.x, dir3.z), turn_speed * delta)
			if model_root:
				model_root.rotation.y = facing_yaw
			# Sexy Man has no walk clip — keep idle/guard while moving, or walk if Kenney
			if not _play(WALK_CLIPS, false):
				_play(IDLE_CLIPS, false)
		else:
			velocity.x = move_toward(velocity.x, 0.0, move_speed * 8.0 * delta)
			velocity.z = move_toward(velocity.z, 0.0, move_speed * 8.0 * delta)
			if is_on_floor() and not is_attacking:
				_play(IDLE_CLIPS, false)
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
		_play(DODGE_CLIPS, true)
	if _wants_attack() and not is_attacking and not is_dodging and attack_timer.is_stopped():
		_perform_attack(false)
	if _wants_dodge() and not is_dodging and not is_attacking and dodge_timer.is_stopped():
		_perform_dodge()

func _get_move_input() -> Vector2:
	var v := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	if _touch_move.length() > 0.05:
		v = _touch_move
	return v.limit_length(1.0)

func _wants_jump() -> bool:
	return Input.is_action_just_pressed("jump") or _touch_jump

func _wants_attack() -> bool:
	return Input.is_action_just_pressed("attack") or _touch_attack

func _wants_dodge() -> bool:
	return Input.is_action_just_pressed("dodge") or _touch_dodge

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

func _perform_attack(heavy: bool) -> void:
	is_attacking = true
	if hitbox:
		hitbox.monitoring = true
	attack_timer.start(attack_cooldown if not heavy else attack_cooldown * 1.4)
	var quality := BeatClock.evaluate_input()
	attack_performed.emit(quality)
	if quality == "perfect" or quality in ["early", "late"]:
		GameState.add_combo()
		GameState.add_score(120 if heavy else 100, 1.5 if quality == "perfect" else 1.0)
	else:
		GameState.break_combo()
		GameState.add_score(40, 0.5)
	combo_index = (combo_index + 1) % 3
	if heavy:
		_play(HEAVY_CLIPS, true)
	else:
		# cycle light combo through punch clips
		var clip_set := ATTACK_CLIPS.slice(combo_index, combo_index + 3)
		if clip_set.is_empty():
			clip_set = ATTACK_CLIPS
		_play(clip_set, true)

func _on_attack_finished() -> void:
	is_attacking = false
	if hitbox:
		hitbox.monitoring = false
	_play(IDLE_CLIPS, true)

func _perform_dodge() -> void:
	is_dodging = true
	is_invulnerable = true
	dodge_timer.start(dodge_duration)
	invuln_timer.start(dodge_duration + 0.1)
	_play(DODGE_CLIPS, true)

func _on_dodge_finished() -> void:
	is_dodging = false
	velocity.x = 0.0
	velocity.z = 0.0

func take_hit(amount: int) -> void:
	if is_invulnerable or is_dodging:
		return
	GameState.apply_damage_to_player(amount)
	_play(HIT_CLIPS, true)
	if GameState.player_health <= 0:
		player_died.emit()
		_play(DEATH_CLIPS, true)

func _on_hitbox_body_entered(body: Node3D) -> void:
	if body.has_method("take_hit"):
		var q := BeatClock.evaluate_input()
		var dmg := 28 if q == "perfect" else (20 if q in ["early", "late"] else 12)
		body.take_hit(dmg)

func _on_hitbox_area_entered(area: Area3D) -> void:
	var p := area.get_parent()
	if p and p.has_method("take_hit"):
		var q := BeatClock.evaluate_input()
		var dmg := 28 if q == "perfect" else (20 if q in ["early", "late"] else 12)
		p.take_hit(dmg)

func _play(candidates: Array, force: bool = true) -> bool:
	var name := AnimUtil.play_fuzzy(anim_player, candidates, force)
	return name != ""
