extends Control
## On-screen touch controls for Android. Buttons call into the player controller.

@onready var btn_left: TouchScreenButton = $Left
@onready var btn_right: TouchScreenButton = $Right
@onready var btn_jump: TouchScreenButton = $Jump
@onready var btn_attack: TouchScreenButton = $Attack
@onready var btn_dodge: TouchScreenButton = $Dodge

var player: Node = null

func _ready() -> void:
	visible = true
	# Scale based on settings
	scale = Vector2.ONE * GameState.touch_controls_scale
	# Connect buttons
	if btn_left:
		btn_left.pressed.connect(func(): _set("left", true))
		btn_left.released.connect(func(): _set("left", false))
	if btn_right:
		btn_right.pressed.connect(func(): _set("right", true))
		btn_right.released.connect(func(): _set("right", false))
	if btn_jump:
		btn_jump.pressed.connect(func(): _set("jump", true))
		btn_jump.released.connect(func(): _set("jump", false))
	if btn_attack:
		btn_attack.pressed.connect(func(): _set("attack", true))
		btn_attack.released.connect(func(): _set("attack", false))
	if btn_dodge:
		btn_dodge.pressed.connect(func(): _set("dodge", true))
		btn_dodge.released.connect(func(): _set("dodge", false))

func bind_player(p: Node) -> void:
	player = p

func _set(action: String, pressed: bool) -> void:
	if player == null or not is_instance_valid(player):
		return
	match action:
		"left":
			player.set_touch_left(pressed)
		"right":
			player.set_touch_right(pressed)
		"jump":
			player.set_touch_jump(pressed)
		"attack":
			player.set_touch_attack(pressed)
		"dodge":
			player.set_touch_dodge(pressed)
