extends Node2D

var pool: Array = []   # список блоков


func _ready():
	# стартовое создание пула
	pool = get_children()

# получение блока из пула
func getBlock():
	for i in pool:
		if not i.visible:
			i.visible = true
			i.set_physics_process(true)
			return i

# возвращение блока обратно в пул
func returnBlock(block: Node2D):
	block.visible = false
	block.set_physics_process(false)
	block.direction = Vector2.ZERO
