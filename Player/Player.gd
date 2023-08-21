extends CharacterBody2D

const PlayerHurtAudio = preload("res://Player/player_hurt.tscn")

const ACCELERATION = 500
const DECELERATION = 500
const MAX_SPEED = 80
const ROLL_SPEED = 125
const INVINCIBILITY_DURATION = 0.8 # seconds
const CAMERA_DEADZONE_RADIUS = 0.5

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var target_velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var stats = PlayerStats
var invincible = false

@onready
var animationTree = $AnimationTree
@onready
var animationState = animationTree.get("parameters/playback")
@onready
var attackBox = $AttackBoxPivot/AttackBox
@onready
var invicibilityTimer = $InvincibilityTimer
@onready
var hitBox = $HitBox
@onready
var blinkAnimationPlayer = $BlinkAnimationPlayer

var camera = null

func _ready():
	stats.died.connect(self.queue_free)
	animationTree.active = true

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)
			
	if camera == null:
		camera = get_tree().get_first_node_in_group("camera")
	else:
		var cam_pos = camera.global_position.lerp(self.global_position, 0.05)
		# Avoid camera jitter when approaching player by simply not moving
		# the camera when the player is close to centered anyway.
		if camera.global_position.distance_to(cam_pos) >= CAMERA_DEADZONE_RADIUS:
			camera.global_position = cam_pos

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		attackBox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		target_velocity = target_velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		target_velocity = target_velocity.move_toward(Vector2.ZERO, DECELERATION * delta)
	
	velocity = target_velocity
	move_and_slide()
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
	elif Input.is_action_just_pressed("dodge"):
		state = ROLL

func attack_state(delta):
	target_velocity = target_velocity.move_toward(Vector2.ZERO, DECELERATION * delta)
	velocity = target_velocity
	move_and_slide()
	animationState.travel("Attack")

func roll_state(delta):
	velocity = roll_vector * ROLL_SPEED
	move_and_slide()
	animationState.travel("Roll")

func animation_finished(animation_name):
	if animation_name.contains("Roll"):
		velocity *= 0.7
	state = MOVE

func _on_damaged(area):
	if not invincible:
		stats.health -= 1
		invincible = true
		blinkAnimationPlayer.play("Start")
		invicibilityTimer.start(INVINCIBILITY_DURATION)
		hitBox.set_deferred("monitoring", false)
		get_tree().current_scene.add_child(PlayerHurtAudio.instantiate())

func _on_invincibility_timeout():
	invincible = false
	blinkAnimationPlayer.play("Stop")
	hitBox.monitoring = true
