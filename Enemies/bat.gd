extends CharacterBody2D

const DECELERATION = 100
const ACCELERATION = 325
const KNOCKBACK_ACCELERATION = 110
const WANDER_SPEED = 30
const CHASE_SPEED = 55
const DETECTION_RADIUS = 50
const CHASE_DETECTION_RADIUS = 80

enum {
	IDLE,
	WANDER,
	CHASE
}
const WANDER_STATES = [IDLE, WANDER]

@onready var sprite = $Sprite2D
@onready var stats = $Stats
@onready var deathEffect = $DeathEffect
@onready var deathSound = $DeathEffect/AudioStreamPlayer
@onready var hitEffect = $HitEffect
@onready var hitSound = $HitEffect/AudioStreamPlayer
@onready var softCollision = $SoftCollision
@onready var wander = $WanderController

var knockback = Vector2.ZERO
var state = IDLE
var player = null

func _physics_process(delta):
	if knockback != Vector2.ZERO:
		knockback = knockback.move_toward(Vector2.ZERO, DECELERATION * delta)
		velocity = knockback
		move_and_slide()
		return
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, DECELERATION * delta)
			maybe_switch_state()

		WANDER:
			var direction = self.global_position.direction_to(wander.target_position).normalized() * WANDER_SPEED
			velocity = velocity.move_toward(direction, ACCELERATION * delta)
			if self.global_position.distance_to(wander.target_position) <= WANDER_SPEED * delta:
				state = IDLE
			else:
				maybe_switch_state()


		CHASE:
			if player != null:
				var direction: Vector2 = player.global_position - self.global_position
				direction = direction.normalized() * CHASE_SPEED
				velocity = velocity.move_toward(direction, ACCELERATION * delta)
			else:
				state = IDLE

	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * ACCELERATION

	sprite.flip_h = velocity.x < 0
	move_and_slide()

func maybe_switch_state():
	if wander.get_time_left() <= 0:
		state = WANDER_STATES[randi_range(0, len(WANDER_STATES) - 1)]
		wander.start_timer(randf_range(1, 3))
		

func _on_damaged(area):
	knockback = area.knockback_vector * KNOCKBACK_ACCELERATION
	stats.health -= 1
	hitEffect.visible = true
	hitEffect.frame = 0
	hitEffect.play("default")
	hitSound.play()
	# Keep the hitEffect from moving
	self.remove_child(hitEffect)
	self.add_sibling(hitEffect)
	hitEffect.global_position = self.global_position

func _on_died():
	self.visible = false
	deathEffect.frame = 0
	deathEffect.play("default")
	deathSound.play()
	deathEffect.visible = true
	# Keep the deathEffect from moving
	self.remove_child(deathEffect)
	self.add_sibling(deathEffect)
	deathEffect.global_position = self.global_position

func _on_death_effect_animation_finished():
	queue_free()
	deathEffect.queue_free()


func _on_hit_effect_animation_finished():
	hitEffect.visible = false
	# Reattach hitEffect for next time
	hitEffect.get_parent().remove_child(hitEffect)
	self.add_child(hitEffect)


func _on_player_detected(body):
	player = body
	state = CHASE
	$PlayerDetectionZone/CollisionShape2D.shape.radius = CHASE_DETECTION_RADIUS


func _on_player_escaped(body):
	player = null
	$PlayerDetectionZone/CollisionShape2D.shape.radius = DETECTION_RADIUS
