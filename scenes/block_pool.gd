extends Node2D

export(float) var minInterval = 1.0    # минимальное время появления
export(float) var maxInterval = 2.0    # максимальное время появления
export(NodePath) var finalPortalPath   # путь к финальному порталу
onready var finalPortal: Node2D = get_node(finalPortalPath) if finalPortalPath else null
export(int) var neededBlocksSpawnForSpawnFinalPortal = 25   # нужное кол-во выпущеных блоков для спавна портала

var pool: Array = []           # пул блоков
var BlockSpawnCount: int = 0   # кол-во созданных блоков


func _ready():
	# получаем всех ДЕТЕЙ
	pool = get_children()
	for i in pool:
		i.visible = false
	
	# запускаем спавн
	scheduleNextSpawn()

func scheduleNextSpawn():
	# ждём случайное время и выпускаем блок
	yield(get_tree().create_timer(rand_range(minInterval, maxInterval)), "timeout")
	spawnBlock()
	scheduleNextSpawn()

func spawnBlock():
	# берём рандомный блок
	pool.shuffle()
	BlockSpawnCount += 1
	
	if BlockSpawnCount >= neededBlocksSpawnForSpawnFinalPortal:
		activatePortal()
		return
	
	for i in pool:
		if not i.visible:
			# ставим за экраном
			i.position = Vector2(
				get_viewport_rect().size.x + 100,
				0
			)
			i.visible = true
			if i.has_method("activate"): i.activate()
			return
	# если все заняты то похуй, ждём пополнения пула

func returnBlock(block: Node2D):
	block.visible = false
	if block.has_method("deactivate"): block.deactivate()

func activatePortal():
	if finalPortal == null: return
	finalPortal.activate()
