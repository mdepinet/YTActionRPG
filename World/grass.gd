extends Node2D

@onready
var sprite = $Sprite2D
@onready
var animation = $AnimatedSprite2D


func _on_animation_finished():
	queue_free()


func _on_damaged(area):
	if sprite.visible:
		sprite.visible = false
		animation.visible = true
		animation.frame = 0
		animation.play("default")
