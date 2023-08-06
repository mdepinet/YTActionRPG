extends CharacterBody2D

const ACCELERATION = 500
const DECELERATION = 500
const MAX_SPEED = 80

var target_velocity = Vector2.ZERO

@onready
var animationTree = $AnimationTree
@onready
var animationState = animationTree.get("parameters/playback")

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationState.travel("Run")
		target_velocity = target_velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		target_velocity = target_velocity.move_toward(Vector2.ZERO, DECELERATION * delta)
	
	velocity = target_velocity
	move_and_slide()
	
	
