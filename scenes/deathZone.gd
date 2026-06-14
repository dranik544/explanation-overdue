extends Area2D

export(Vector2) var defaultPlayerPosition = Vector2(-100, 90)


func _ready():
	connect("body_entered", self, "bodyEntered")

func bodyEntered(body: Node2D):
	if body.is_in_group("player"):
		body.global_position = defaultPlayerPosition
		if body.has_method("damage"): body.damage(10)
