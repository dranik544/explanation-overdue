extends Area2D

@export var speed: float = 500.0                # скорость проджектайла
@export var direction: Vector2 = Vector2.ZERO   # направление проджектайла
@export var pool: Node2D                        # объект пула, где находятся заготовки проджектайлов
@export var recoilForce: float = 95.0           # сила отдачи игрока от проджектайла, в случае касания с объектом


func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	# движение проджектайла по направлению, с учётом скорости и фпс
	position += direction * speed * delta

# активация проджектайла
func activate(startpos: Vector2, dir: Vector2):
	global_position = startpos
	direction = dir.normalized()
	visible = true
	set_physics_process(true)

# уничтожение проджектайла при касании
func _on_body_entered(body):
	if body.is_in_group("player"): return
	
	pool.returnProjectile(self)
