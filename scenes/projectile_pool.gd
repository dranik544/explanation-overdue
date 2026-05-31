extends Node2D

var pool: Array = []                       # список проджектайлов

@export var projectileScene: PackedScene   # сцена проджектайла
@export var poolSize: int = 15             # кол-во заготовленных проджектайлов


func _ready():
	# стартовое создание пула
	for i in range(poolSize):
		var bullet: Area2D = projectileScene.instantiate()
		# отключение физической обработки и видимости
		bullet.visible = false
		bullet.set_physics_process(false)
		bullet.pool = self
		
		add_child(bullet)
		
		# добавление в список
		pool.append(bullet)

# получение проджектайла из пула
func getProjectile() -> Node2D:
	for i in pool:
		if not i.visible:
			return i
	
	# если проджектайлов не хватает, то надо создать ещё
	var newProjectile: Area2D = projectileScene.instantiate()
	newProjectile.pool = self
	add_child(newProjectile)
	
	pool.append(newProjectile)
	
	print("new created")
	return newProjectile

# возвращение проджектайла обратно в пул
func returnProjectile(bullet: Node2D):
	bullet.visible = false
	bullet.set_physics_process(false)
	bullet.direction = Vector2.ZERO
