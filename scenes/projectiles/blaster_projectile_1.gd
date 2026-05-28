extends Area2D

@onready var sprite2d: Sprite2D = $Sprite2D

@export var speed: float = 500.0                # скорость проджектайла
@export var direction: Vector2 = Vector2.ZERO   # направление проджектайла
@export var pool: Node2D                        # объект пула, где находятся заготовки проджектайлов
@export var recoilForce: float = 95.0           # сила отдачи игрока от проджектайла, в случае касания с объектом
@export var damage: int = 1                     # урон по блокам и противникам


func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	# движение проджектайла по направлению, с учётом скорости и фпс
	position += direction * speed * delta

# активация проджектайла
func activate(startpos: Vector2, dir: Vector2):
	direction = dir.normalized()
	global_position = startpos + direction * 24.0 # <- это создаёт проджектайл не прямо в точке, а 
	visible = true                                #    чутка дальше чем надо.
	set_physics_process(true)
	monitorable = true
	monitoring = true

# уничтожение проджектайла при касании
func _on_body_entered(body: Node2D):
	# проверяем, не игрок ли это
	if body.is_in_group("player"): return
	
	# отключение движения и отслеживания столкновений с другими проджектайлами
	set_physics_process(false)
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	
	if body.has_method("destroy"): body.destroy(damage)
	
	# анимация уничтожения
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CIRC)
	tween.set_parallel(true)
	tween.tween_property(sprite2d, "scale", Vector2(2.0, 2.0), 0.2)
	tween.tween_property(sprite2d, "modulate:a", 0.0, 0.2)
	await tween.finished
	
	# возвращение обратно в пул
	pool.returnProjectile(self)
	
	# возвращение обычных характеристик внешнего вида
	sprite2d.modulate.a = 1.0
	sprite2d.scale = Vector2(1.0, 1.0)
