extends Node

signal died

@export var max_health: int = 1
@onready var health = max_health:
	get:
		return health
	set(value):
		health = value
		if health <= 0:
			died.emit()
