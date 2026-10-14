extends CharacterBody3D
## Enemy with optional AnimationPlayer clips (Kenney) or static mesh (MMA/Arthur/Boss).

@export var max_health: int = 60
@export var move_speed: float = 4.2
@export var attack_damage: int = 12
@export var attack_range: float = 1.9
@export var attack_cooldown: float = 1.2
@export var aggro_range: float = 20.0

var health: int
var _attack_cd: float = 0.0
var _player: Node3D
var _dead: bool = false
var anim_player: AnimationPlayer

@onready var model_root: Node3D = $ModelRoot

func _ready() -> void:
	health = max_health
	add_to_group("enemies")
	anim_player = AnimUtil.find_animation_player(model_root)
	_play(["idle", "Idle", "static", "Kung Fu idle guard"])

func set_player(p: Node3D) -> void:
	_player = p

func _physics_process(delta: float) -> void:
	if _dead or GameState.is_paused or GameState.is_game_over:
		return
	_attack_cd = maxf(0.0, _attack_cd - delta)
	if _player == null or not is_instance_valid(_player):
		return
	var to_player := _player.global_position - global_position
	to_player.y = 0.0
	var dist := to_player.length()
	if dist > aggro_range:
		velocity.x = 0.0
		velocity.z = 0.0
		_play(["idle", "Idle", "static"])
	elif dist > attack_range:
		var dir := to_player.normalized()
		velocity.x = dir.x * move_speed
		velocity.z = dir.z * move_speed
		if model_root:
			model_root.rotation.y = atan2(dir.x, dir.z)
		_play(["walk", "Walk", "sprint"])
	else:
		velocity.x = 0.0
		velocity.z = 0.0
		if _attack_cd <= 0.0:
			_do_attack()
			_attack_cd = attack_cooldown
	if not is_on_floor():
		velocity.y -= 24.0 * delta
	move_and_slide()

func _do_attack() -> void:
	_play(["attack-melee-right", "attack-kick-right", "Attack", "Kung Fu sexy punch"])
	if _player and _player.has_method("take_hit"):
		if global_position.distance_to(_player.global_position) <= attack_range + 0.5:
			_player.take_hit(attack_damage)

func take_hit(amount: int) -> void:
	if _dead:
		return
	health -= amount
	_play(["die", "Hit", "hit"])
	if _player:
		var away := (global_position - _player.global_position).normalized()
		velocity += away * 5.5
	if health <= 0:
		_die()

func _die() -> void:
	_dead = true
	_play(["die", "Death", "death"])
	GameState.add_score(250, 1.0)
	GameState.add_combo()
	await get_tree().create_timer(1.4).timeout
	queue_free()

func _play(candidates: Array) -> void:
	AnimUtil.play_fuzzy(anim_player, candidates, true)
