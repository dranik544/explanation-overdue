extends StaticBody2D

onready var sprite2d: Sprite = $Sprite
onready var collisionShape2d: CollisionShape2D = $CollisionShape2D

var maxHealth: int        # максимальное здоровье блока
var destroyTween: Tween   # tween для анимации уничтожения

export var health: int = 4                  # здоровье блока (блять здоровье у блока, ахуенно просто)
enum blockType {default}                     # все типы блоков
export(blockType) var currentBlockType      # текущий тип блока
export(bool) var startedDeactivate = true   # стартовая деактивация


func _ready() -> void:
	maxHealth = health
	if startedDeactivate: deactivate()

func destroy(damage: int):
	if health <= 0: return
	
	# отнимаем от здоровья кол-во урона
	health -= damage
	
	# если здоровья меньше или равно нулю, то ...
	if health <= 0:
		# отключаем обработку блока и коллизии
		collisionShape2d.set_deferred("disabled", true)
		set_process(false)
		
		destroyTween = Tween.new()
		
		# ... запускаем анимацию в зависимости от типа блока
		match currentBlockType:
			0:
				destroyTween.set_ease(Tween.EASE_IN)
				destroyTween.set_trans(Tween.TRANS_BACK)
				destroyTween.set_parallel(true)
				destroyTween.tween_property(sprite2d, "scale", Vector2.ZERO, 0.2)
				destroyTween.tween_property(sprite2d, "rotation", rotation + 1.0, 0.2)

func activate():
	health = maxHealth
	returnSpriteAfterDestroyAnimation()
	set_process(true)
	collisionShape2d.set_deferred("disabled", false)

func deactivate():
	health = maxHealth
	returnSpriteAfterDestroyAnimation()
	set_process(false)
	collisionShape2d.set_deferred("disabled", true)

func returnSpriteAfterDestroyAnimation():
	if destroyTween: destroyTween.kill()
	match currentBlockType:
		0:
			sprite2d.rotation = 0.0
			sprite2d.scale = Vector2(1.0, 1.0)
