extends Node

signal died
signal health_changed(value)

@export var max_health: int = 1
@onready var health = max_health:
	get:
		return health
	set(value):
		health = value
		health_changed.emit(value)
		if health <= 0:
			died.emit()
