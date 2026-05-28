extends StaticBody2D

@onready var sprite2d: Sprite2D = $Sprite2D
@onready var collisionShape2d: CollisionShape2D = $CollisionShape2D

@export var health: int = 4               # здоровье блока (блять здоровье у блока, ахуенно просто)
enum blockType {default}                  # все типы блоков
@export var currentBlockType: blockType   # текущий тип блока


func destroy(damage: int):
	if health <= 0: return
	
	# отнимаем от здоровья кол-во урона
	health -= damage
	
	# если здоровья меньше или равно нулю, то ...
	if health <= 0:
		# отключаем обработку блока и коллизии
		collisionShape2d.set_deferred("disabled", true)
		set_physics_process(false)
		
		var tween: Tween = create_tween()
		
		# ... запускаем анимацию в зависимости от типа блока
		match currentBlockType:
			0:
				tween.set_ease(Tween.EASE_IN)
				tween.set_trans(Tween.TRANS_BACK)
				tween.set_parallel(true)
				tween.tween_property(sprite2d, "scale", Vector2.ZERO, 0.2)
				tween.tween_property(sprite2d, "rotation", rotation + 1.0, 0.2)
