extends Area2D

export(Vector2) var defaultPlayerPosition = Vector2(-155, 100)


func _ready():
	connect("body_entered", self, "bodyEntered")

func bodyEntered(body: Node2D):
	if body.is_in_group("player"):
		body.global_position = defaultPlayerPosition
