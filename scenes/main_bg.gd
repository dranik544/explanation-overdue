extends Node2D

onready var bg1 = $bg1   # первый спрайт
onready var bg2          # второй спрайт (должен быть с той же текстурой)
onready var bg3 = $bg3   # третий спрайт
onready var bg4          # четвёртый спрайт (должен быть с той же текстурой)

var spriteWidth1: float
var spriteWidth2: float


func _ready():
	var bg2d = bg1.duplicate()
	add_child(bg2d)
	bg2 = bg2d
	
	var bg4d = bg3.duplicate()
	add_child(bg4d)
	bg4 = bg4d
	
	
	
	spriteWidth1 = bg1.texture.get_width() * bg1.scale.x
	spriteWidth2 = bg3.texture.get_width() * bg3.scale.x
	
	bg1.position = Vector2.ZERO
	bg2.position = Vector2(spriteWidth1, 0)
	bg3.position = Vector2.ZERO
	bg4.position = Vector2(spriteWidth2, 0)

func _process(delta):
	bg1.position.x -= Global.speedLoc * delta * 0.2
	bg2.position.x -= Global.speedLoc * delta * 0.2
	bg3.position.x -= Global.speedLoc * delta * 1.6
	bg4.position.x -= Global.speedLoc * delta * 1.6
	
	if bg1.position.x + spriteWidth1 < 0:
		bg1.position.x = bg2.position.x + spriteWidth1
	elif bg2.position.x + spriteWidth1 < 0:
		bg2.position.x = bg1.position.x + spriteWidth1
	
	if bg3.position.x + spriteWidth2 < 0:
		bg3.position.x = bg4.position.x + spriteWidth2
	elif bg4.position.x + spriteWidth2 < 0:
		bg4.position.x = bg3.position.x + spriteWidth2
