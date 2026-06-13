extends StaticBody2D

onready var sprite2d: Sprite = $Sprite
onready var collisionShape2d: CollisionShape2D = $CollisionShape2D

var maxHealth: int                          # максимальное здоровье блока

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
	
	if Global.enableAnimations:
		match currentBlockType:
			0:
				var tweenDamage: Tween = Tween.new()
				add_child(tweenDamage)
				
				tweenDamage.interpolate_property(sprite2d, "rotation", sprite2d.rotation, sprite2d.rotation + rand_range(-0.1, 0.1), 0.01)
				tweenDamage.interpolate_property(sprite2d, "modulate", sprite2d.modulate, Color(0.5, 0.5, 0.5, 1.0), 0.01)
				tweenDamage.start()
				yield(tweenDamage, "tween_completed")
				
				tweenDamage.queue_free()
				var tweenDamageR: Tween = Tween.new()
				add_child(tweenDamageR)
				
				tweenDamageR.interpolate_property(sprite2d, "rotation", sprite2d.rotation, 0.0, 0.2, Tween.TRANS_CIRC, Tween.EASE_IN)
				tweenDamageR.interpolate_property(sprite2d, "modulate", sprite2d.modulate, Color(1.0, 1.0, 1.0, 1.0), 0.2, Tween.TRANS_CIRC, Tween.EASE_IN)
				tweenDamageR.start()
				yield(tweenDamageR, "tween_completed")
				
				tweenDamageR.queue_free()
	
	# если здоровья меньше или равно нулю, то ...
	if health <= 0:
		# отключаем обработку блока и коллизии
		collisionShape2d.set_deferred("disabled", true)
		set_process(false)
		
		# ... запускаем анимацию в зависимости от типа блока
		match currentBlockType:
			0:
				if Global.enableAnimations:
					var tween: Tween = Tween.new()
					add_child(tween)
					tween.interpolate_property(sprite2d, "scale", sprite2d.scale, Vector2.ZERO, 0.2, Tween.TRANS_BACK, Tween.EASE_IN)
					tween.interpolate_property(sprite2d, "rotation", sprite2d.rotation, sprite2d.rotation + 1.0, 0.2, Tween.TRANS_BACK, Tween.EASE_IN)
					tween.start()
					yield(tween, "tween_completed")
					tween.queue_free()
				else:
					sprite2d.scale = Vector2.ZERO

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
			sprite2d.modulate = Color(1.0, 1.0, 1.0, 1.0)
