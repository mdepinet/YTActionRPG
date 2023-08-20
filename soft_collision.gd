extends Area2D

@export var collisionShape: Shape2D = null

func _ready():
	$CollisionShape2D.shape = collisionShape

func is_colliding():
	var areas = get_overlapping_areas()
	return not areas.is_empty()

func get_push_vector():
	if not is_colliding():
		return Vector2.ZERO
	# Performance optimization: Only move away from one overlapping area at a time
	var area = get_overlapping_areas()[0]
	return area.global_position.direction_to(global_position).normalized()
