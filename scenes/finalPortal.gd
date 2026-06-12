extends Area2D

var movePortal: bool = false

onready var sprite = $Sprite


func _ready():
	position = Vector2(
		get_viewport_rect().size.x + 100,
		0
	)

func activate():
	movePortal = true

func _physics_process(delta):
	# двигаем портал влево
	if movePortal: position.x -= Global.speedLoc * delta
