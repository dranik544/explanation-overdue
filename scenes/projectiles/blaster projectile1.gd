extends Area2D

onready var sprite2d: Sprite = $Sprite

export var speed: float = 500.0                # скорость проджектайла
export var direction: Vector2 = Vector2.ZERO   # направление проджектайла
export var recoilForce: float = 80.0           # сила отдачи игрока от проджектайла, в случае касания с объектом
export var damage: int = 1                     # урон по блокам и противникам
export(NodePath) var poolPath                                                 # ПУТЬ К внешний пул проджектайлов
onready var pool: Node2D = get_node(poolPath) if poolPath else null           # внешний пул проджектайлов
export(NodePath) var cameraPath                                               # ПУТЬ К камера
onready var camera: Camera2D = get_node(cameraPath) if cameraPath else null   # камера


var baseScaleSprite: Vector2 = Vector2.ZERO


func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")
	baseScaleSprite = sprite2d.scale
	
	# модификаторы
	speed *= Global.multiplierProjectileSpeed
	recoilForce *= Global.multiplierProjectileRecoilForce
	damage *= Global.multiplierProjectileDamage

func _physics_process(delta):
	# движение проджектайла по направлению, с учётом скорости и фпс
	position += direction * speed * delta

# активация проджектайла
func activate(startpos: Vector2, dir: Vector2):
	direction = dir.normalized()
	global_position = startpos + direction * 24.0 # <- это создаёт проджектайл не прямо в точке, а 
	visible = true                                #    чутка дальше чем надо.
	sprite2d.modulate.a = 1.0
	sprite2d.scale = baseScaleSprite
	set_physics_process(true)
	monitorable = true
	monitoring = true
	
	if Global.enableAnimations:
		var tween: Tween = Tween.new()
		add_child(tween)
		tween.interpolate_property(sprite2d, "scale", Vector2.ZERO, baseScaleSprite, 0.05)
		tween.start()
		yield(tween, "tween_completed")
		tween.queue_free()

# уничтожение проджектайла при касании
func _on_body_entered(body: Node2D):
	# проверяем, не игрок ли это
	if body.is_in_group("player"): return
	
	# отключение движения и отслеживания столкновений с другими проджектайлами
	set_physics_process(false)
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	
	if body.has_method("destroy"): body.destroy(damage)
	
	# тряска экрана при уничтожении
	if camera == null: camera = get_tree().get_first_node_in_group("camera")
	if camera and camera.has_method("applyShake"): camera.applyShake(recoilForce * 0.01, 0.2)
	
	# анимация уничтожения
	if Global.enableAnimations:
		var tween: Tween = Tween.new()
		add_child(tween)
		tween.interpolate_property(sprite2d, "scale", sprite2d.scale, baseScaleSprite * 2, 0.2, Tween.TRANS_CIRC, Tween.EASE_OUT)
		tween.interpolate_property(sprite2d, "modulate:a", sprite2d.modulate.a, 0.0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.start()
		yield(tween, "tween_completed")
		tween.queue_free()
	
	# возвращение обычных характеристик внешнего вида
	sprite2d.modulate.a = 1.0
	sprite2d.scale = baseScaleSprite
	
	# возвращение обратно в пул
	if pool == null: pool = get_tree().get_first_node_in_group("projectile pool")
	pool.returnProjectile(self)
