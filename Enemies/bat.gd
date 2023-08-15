extends CharacterBody2D

const DECELERATION = 100
const KNOCKBACK_ACCELERATION = 120

@onready var stats = $Stats
@onready var sprite = $Sprite2D
@onready var deathEffect = $DeathEffect

var knockback = Vector2.ZERO

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, DECELERATION * delta)
	velocity = knockback
	move_and_slide()

func _on_damaged(area):
	knockback = area.knockback_vector * KNOCKBACK_ACCELERATION
	stats.health -= 1

func _on_died():
	sprite.visible = false
	deathEffect.frame = 0
	deathEffect.play("default")
	deathEffect.visible = true

func _on_death_effect_animation_finished():
	if deathEffect.visible:
		queue_free()
