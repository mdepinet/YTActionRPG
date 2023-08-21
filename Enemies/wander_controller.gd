extends Node2D

@export var wander_range: int = 32

@onready var start_position = global_position
@onready var target_position = global_position
@onready var timer = $Timer

func update_target_position():
	var target_vector = Vector2.UP.rotated(randf_range(-PI, PI)) * wander_range
	target_position = start_position + target_vector

func get_time_left():
	return timer.time_left

func start_timer(duration):
	timer.start(duration)

func _on_timer_timeout():
	update_target_position()
