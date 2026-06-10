extends StaticBody2D

onready var sprite2d: Sprite = $Sprite
onready var collisionShape2d: CollisionShape2D = $CollisionShape2D

var maxHealth: int                              # максимальное здоровье блока

export var health: int = 4                  # здоровье блока (блять здоровье у блока, ахуенно просто)
enum blockType {default}                    # все типы блоков
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
		
		var tween: Tween = Tween.new()
		add_child(tween)
		
		# ... запускаем анимацию в зависимости от типа блока
		match currentBlockType:
			0:
				tween.interpolate_property(sprite2d, "scale", sprite2d.scale, Vector2.ZERO, 0.2, Tween.TRANS_BACK, Tween.EASE_IN)
				tween.interpolate_property(sprite2d, "rotation", sprite2d.rotation, sprite2d.rotation + 1.0, 0.2, Tween.TRANS_BACK, Tween.EASE_IN)
				tween.start()
				yield(tween, "tween_completed")
				tween.queue_free()

func activate():
	health = maxHealth
	returnSpriteAfterDestroyAnimation()
	set_process(true)
	collisionShape2d.set_deferred("disabled", false)

func deactivate():
	health = maxHealth
	set_process(false)
	collisionShape2d.set_deferred("disabled", true)

func returnSpriteAfterDestroyAnimation():
	match currentBlockType:
		0:
			sprite2d.rotation = 0.0
			sprite2d.scale = Vector2(1.0, 1.0)
