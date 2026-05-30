extends Node2D

@export var minInterval: float = 1.0   # минимальное время появления
@export var maxInterval: float = 2.0   # максимальное время появления

var pool: Array = []   # пул блоков

func _ready():
	# получаем всех ДЕТЕЙ
	pool = get_children()
	for i in pool:
		i.visible = false
		print(i)
	
	# запускаем спавн
	scheduleNextSpawn()

func scheduleNextSpawn():
	# ждём случайное время и выпускаем блок
	await get_tree().create_timer(randf_range(minInterval, maxInterval)).timeout
	spawnBlock()
	scheduleNextSpawn()

func spawnBlock():
	# берём рандомный блок
	pool.shuffle()
	for i in pool:
		if not i.visible:
			print("spawn block")
			# ставим за экраном
			i.position = Vector2(
				get_viewport_rect().size.x + 100,
				0,
			)
			i.visible = true
			if i.has_method("activate"): i.activate()
			return
	# если все заняты то похуй, ждём пополнения пула

func returnBlock(block: Node2D):
	block.visible = false
	if block.has_method("deactivate"): block.deactivate()
