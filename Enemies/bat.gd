extends CharacterBody2D

const DECELERATION = 100
const ACCELERATION = 325
const KNOCKBACK_ACCELERATION = 110
const CHASE_SPEED = 55
const DETECTION_RADIUS = 50
const CHASE_DETECTION_RADIUS = 80

enum {
	IDLE,
	WANDER,
	CHASE
}

@onready var stats = $Stats
@onready var sprite = $Sprite2D
@onready var shadow = $Shadow
@onready var deathEffect = $DeathEffect
@onready var hitEffect = $HitEffect

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
		WANDER:
			pass
		CHASE:
			if player != null:
				var direction: Vector2 = player.global_position - self.global_position
				direction = direction.normalized() * CHASE_SPEED
				velocity = velocity.move_toward(direction, ACCELERATION * delta)
			else:
				state = IDLE
	move_and_slide()

func _on_damaged(area):
	knockback = area.knockback_vector * KNOCKBACK_ACCELERATION
	stats.health -= 1
	hitEffect.visible = true
	hitEffect.frame = 0
	hitEffect.play("default")
	# Keep the hitEffect from moving
	self.remove_child(hitEffect)
	self.add_sibling(hitEffect)
	hitEffect.global_position = self.global_position

func _on_died():
	sprite.visible = false
	shadow.visible = false
	deathEffect.frame = 0
	deathEffect.play("default")
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
