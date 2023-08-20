extends Control

const HEART_WIDTH = 15 # pixels

@onready var heartsFull = $HeartUIFull
@onready var heartsEmpty = $HeartUIEmpty

var hearts: int = 4:
	set(value):
		hearts = clamp(value, 0, max_hearts)
		if heartsFull != null:
			heartsFull.size.x = hearts * HEART_WIDTH
	get:
		return hearts
var max_hearts: int = 4:
	set(value):
		max_hearts = max(value, 1)
		if heartsEmpty != null:
			heartsEmpty.size.x = max_hearts * HEART_WIDTH
	get:
		return max_hearts

func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	PlayerStats.health_changed.connect(func(value): hearts = value)

