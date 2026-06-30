extends StaticBody2D

onready var sprite2d: Sprite = $Sprite
onready var collisionShape2d: CollisionShape2D = $CollisionShape2D

var maxHealth: int                          # максимальное здоровье блока

export var health: int = 4                  # здоровье блока (блять здоровье у блока, ахуенно просто)
export(bool) var startedDeactivate = true   # стартовая деактивация

# все типы блоков
enum blockType {
	default,       # обычный
	undamaged,     # неразрушаемый
	damaging       # наносящий урон # понадобится доп Area2D
}
export(blockType) var currentBlockType                    # текущий тип блока
export(int) var damagingTypeDamage = 5                    # сколько урона игроку наносит тип блока damaging
export(bool) var damagingTypeDestroyAfterDamage = false   # уничтожение после нанесения урона игроку типа блока damaging

signal blockDeactivated
signal blockActivated


func _ready() -> void:
	maxHealth = health
	if startedDeactivate: deactivate()
	
	# модификаторы
	health *= Global.multipliers["multiplierBlockHealth"]
	maxHealth = health
	damagingTypeDamage *= Global.multipliers["multiplierBlockDamagingDamage"]

func destroy(damage: int):
	if health <= 0: return
	
	# отнимаем от здоровья кол-во урона
	health -= damage
	
	if Global.enableAnimations:
		match currentBlockType:
			blockType.default, blockType.damaging:
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
#			blockType.undamaged:   # у этого типа блока нет анимации получения урона
#
	
	# если здоровья меньше или равно нулю, то ...
	if health <= 0:
		# ... запускаем анимацию в зависимости от типа блока
		match currentBlockType:
			blockType.default, blockType.damaging:
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
		
		deactivate()

func activate():
	emit_signal("blockActivated")
	
	health = maxHealth
	returnSpriteAfterDestroyAnimation()
	set_process(true)
	collisionShape2d.set_deferred("disabled", false)

func deactivate():
	emit_signal("blockDeactivated")
	
	health = maxHealth
	set_process(false)
	collisionShape2d.set_deferred("disabled", true)

func returnSpriteAfterDestroyAnimation():
	match currentBlockType:
		blockType.default, blockType.damaging:
			sprite2d.rotation = 0.0
			sprite2d.scale = Vector2(1.0, 1.0)
			sprite2d.modulate = Color(1.0, 1.0, 1.0, 1.0)
