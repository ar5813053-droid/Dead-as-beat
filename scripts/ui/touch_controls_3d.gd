extends CanvasLayer
## Virtual joystick + action buttons for landscape Android.

@onready var stick_base: Control = $StickBase
@onready var stick_knob: Control = $StickBase/Knob
@onready var btn_attack: TouchScreenButton = $Buttons/Attack
@onready var btn_dodge: TouchScreenButton = $Buttons/Dodge
@onready var btn_jump: TouchScreenButton = $Buttons/Jump
@onready var btn_pause: Button = $Buttons/Pause

var player: Node = null
var _dragging := false
var _origin := Vector2.ZERO
const MAX_RADIUS := 72.0

func _ready() -> void:
	visible = true
	if btn_attack:
		btn_attack.pressed.connect(func(): _act("attack", true))
		btn_attack.released.connect(func(): _act("attack", false))
	if btn_dodge:
		btn_dodge.pressed.connect(func(): _act("dodge", true))
		btn_dodge.released.connect(func(): _act("dodge", false))
	if btn_jump:
		btn_jump.pressed.connect(func(): _act("jump", true))
		btn_jump.released.connect(func(): _act("jump", false))
	if btn_pause:
		btn_pause.pressed.connect(_on_pause)

func bind_player(p: Node) -> void:
	player = p

func _act(action: String, pressed: bool) -> void:
	if player == null or not is_instance_valid(player):
		return
	match action:
		"attack":
			if player.has_method("set_touch_attack"):
				player.set_touch_attack(pressed)
		"dodge":
			if player.has_method("set_touch_dodge"):
				player.set_touch_dodge(pressed)
		"jump":
			if player.has_method("set_touch_jump"):
				player.set_touch_jump(pressed)

func _on_pause() -> void:
	GameState.is_paused = not GameState.is_paused
	get_tree().paused = GameState.is_paused
	GameState.paused_changed.emit(GameState.is_paused)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var e := event as InputEventScreenTouch
		if e.pressed and stick_base and stick_base.get_global_rect().has_point(e.position):
			_dragging = true
			_origin = stick_base.global_position + stick_base.size * 0.5
			_update_stick(e.position)
		elif not e.pressed:
			_dragging = false
			_reset_stick()
	elif event is InputEventScreenDrag and _dragging:
		_update_stick((event as InputEventScreenDrag).position)

func _update_stick(pos: Vector2) -> void:
	var delta := pos - _origin
	if delta.length() > MAX_RADIUS:
		delta = delta.normalized() * MAX_RADIUS
	if stick_knob:
		stick_knob.position = (stick_base.size * 0.5) + delta - stick_knob.size * 0.5
	var v := delta / MAX_RADIUS
	# Convert to game input: x right, y forward/back
	if player and player.has_method("set_touch_move"):
		player.set_touch_move(Vector2(v.x, v.y))

func _reset_stick() -> void:
	if stick_knob and stick_base:
		stick_knob.position = stick_base.size * 0.5 - stick_knob.size * 0.5
	if player and player.has_method("set_touch_move"):
		player.set_touch_move(Vector2.ZERO)
