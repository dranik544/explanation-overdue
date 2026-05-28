extends CharacterBody2D

@onready var aimSprite: Sprite2D = $aimSprite
@onready var weapon: Sprite2D = $weapon
@onready var projectileTimer: Timer = $projectileTimer

var touchMoveActive: bool = false                 # срабатывает, когда касание части экрана для ходьбы активно
var touchMoveStart: Vector2 = Vector2.ZERO        # расчёт начальной точки касания
var touchMoveDragOffset: Vector2 = Vector2.ZERO   # финальный расчёт конечной точки движения

var touchAimActive: bool = false                  # срабатывает, когда касание части экрана для прицеливания активно
var touchAimStart: Vector2 = Vector2.ZERO         # расчёт начальной точки касания
var touchAimDragOffset: Vector2 = Vector2.ZERO    # финальный расчёт расположения прицела
var lastTouchAimPos: Vector2 = Vector2.ZERO       # последнее касание части экрана для прицеливания

@export var maxSpeedMove: float = 300.0           # максимальная скорость передвижения игрока
@export var jumpVelocity: float = -450.0          # сила прыжка (отрицательная — вверх)
@export var accelerationMove: float = 20.0        # плавность начала ходьбы
@export var deaccelerationMove: float = 40.0      # плавность конца ходьбы
@export var enableMaxDistanceAim: bool = true     # включить ограничения прицела по растоянию
@export var maxDistanceAim: float = 75.0          # ограничения прицела по растоянию
@export var pool: Node2D                          # внешний пул проджектайлов


func _ready() -> void:
	add_to_group("player")
	
	aimSprite.visible = false

func _physics_process(delta: float) -> void:
	# расчёт силы ходьбы и плавности
	var targetVelocityX: float = clampf(touchMoveDragOffset.x, -maxSpeedMove, maxSpeedMove) if touchMoveActive else 0.0
	var accelMove: float = accelerationMove if targetVelocityX != 0.0 else deaccelerationMove
	
	# плавное движение игрока
	velocity.x = move_toward(velocity.x, targetVelocityX, accelMove)
	
	# если касание для прицела активно, то срабатывает перемещение на позиции, иначе скрытие
	if touchAimActive:
		aimSprite.position = touchAimDragOffset
		shoot()
	
	# гравитация и проверка касания пола
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# перемещение игрока
	move_and_slide()
 
func _input(event: InputEvent) -> void:
	# если игрок как-то касается экрана
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		if event.position.x < get_viewport_rect().size.x / 2: # если касание экрана было в левой части
			leftTouch(event)
		else:                                                 # если касание экрана было в правой части
			rightTouch(event)

# ну тут итак вроде понятно что происходит (нет)
func leftTouch(event: InputEvent):
	if event is InputEventScreenTouch:
		if event.pressed:
			touchMoveActive = true
			touchMoveStart = event.position
			touchMoveDragOffset = Vector2.ZERO
		else:
			# если игрок сделал свайп вверх и он на полу, то можно ебануть вверх
			if touchMoveStart.y - event.position.y > 50.0 and is_on_floor():
				velocity.y = jumpVelocity
			
			touchMoveActive = false
			touchMoveDragOffset = Vector2.ZERO
	elif event is InputEventScreenDrag and touchMoveActive:
		touchMoveDragOffset.x = (event.position.x - touchMoveStart.x) * Global.sensivityMove
		
		if touchMoveStart.y - event.position.y > 80.0 and is_on_floor():
			velocity.y = jumpVelocity
			touchMoveStart.y = event.position.y

func rightTouch(event: InputEvent):
	if event is InputEventScreenTouch:
		if event.pressed:
			touchAimActive = true
			lastTouchAimPos = event.position
			touchAimDragOffset = Vector2.ZERO
			aimFrontAnimationTween()
		else:
			touchAimActive = false
			touchAimDragOffset = Vector2.ZERO
			aimBackAnimationTween()
	elif event is InputEventScreenDrag and touchAimActive:
		# так как я долбоёб, тут надо подробнее выписать:
		# производим запоминание последнего места касания, ведь позже lastRightTouchPos будет изменён
		var lastTouch: Vector2 = event.position - lastTouchAimPos
		lastTouchAimPos = event.position                            # <- вот он меняется
		
		# теперь двигаем прицел в нужное место
		touchAimDragOffset += lastTouch * Global.sensivityAim
		# поворот оружия в сторону прицела
		weapon.rotation = touchAimDragOffset.angle()
		
		# тут проверка, насколько далеко прицел от игрока. если далеко тооооооооо
		if touchAimDragOffset.length() > maxDistanceAim:
			touchAimDragOffset = touchAimDragOffset.normalized() * maxDistanceAim # мы хуярим его :)

# выстрел
func shoot():
	# если таймер ещё не закончил, то возвращаемся обратно
	if !projectileTimer.is_stopped(): return
	if !touchAimActive or touchAimDragOffset.length() <= maxDistanceAim / 10: return
	
	# создаём и активируем проджектайл
	var projectile: Area2D = pool.getProjectile()
	projectile.activate(global_position, touchAimDragOffset.normalized())
	
	# НЕАКТИВНО # отдача игрока от проджектайла, ТОЛЬКО если он в воздухе
	# if !is_on_floor(): velocity -= touchAimDragOffset.normalized() * projectile.recoilForce
	
	# отдача игрока от проджектайла
	velocity -= touchAimDragOffset.normalized() * projectile.recoilForce
	
	# стартуем таймер, дабы избежать спама проджектайлами
	projectileTimer.start()

func aimBackAnimationTween():
	aimSprite.modulate.a = 1.0 
	
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CIRC)
	
	tween.tween_property(aimSprite, "position", Vector2.ZERO, 0.2)
	tween.tween_property(aimSprite, "modulate:a", 0.0, 0.2)
	
	await tween.finished
	if not touchAimActive:
		aimSprite.visible = false

func aimFrontAnimationTween():
	aimSprite.visible = true
	aimSprite.modulate.a = 0.0
	aimSprite.scale = Vector2(4.0, 4.0)
	
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	
	tween.tween_property(aimSprite, "scale", Vector2(1.0, 1.0), 0.5)
	tween.tween_property(aimSprite, "modulate:a", 1.0, 0.3)
	
	await tween.finished
	if not touchAimActive:
		aimSprite.visible = false
