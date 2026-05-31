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

var moveDirection: Vector2 = Vector2.ZERO         # направление ходьбы (ПК / ГЕЙМПАД)
var aimPosition: Vector2 = Vector2.ZERO           # позиция прицела (ПК)
var lastAimGamepadActive: bool = false            # для анимации прицела (ГЕЙМПАД)

@export var maxSpeedMove: float = 300.0           # максимальная скорость передвижения игрока
@export var jumpVelocity: float = -450.0          # сила прыжка (отрицательная — вверх)
@export var accelerationMove: float = 30.0        # плавность начала ходьбы
@export var deaccelerationMove: float = 60.0      # плавность конца ходьбы
@export var enableMaxDistanceAim: bool = true     # включить ограничения прицела по растоянию
@export var maxDistanceAim: float = 75.0          # ограничения прицела по растоянию
@export var pool: Node2D                          # внешний пул проджектайлов
@export var camera: Camera2D                      # камера


func _ready() -> void:
	add_to_group("player")
	
	aimSprite.visible = false

func _physics_process(delta: float) -> void:
	InputManagement()
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	move_and_slide()

func InputManagement():
	# заготовка для нужного Velocity по X оси
	var targetVelocityX: float = 0.0
	if InputManager.getMode() == InputManager.InputMode.TOUCH:
		# если тачмод:
		targetVelocityX = clampf(touchMoveDragOffset.x, -maxSpeedMove, maxSpeedMove) if touchMoveActive else 0.0
	else:
		# если клавамышь или геймпад:
		moveDirection = Input.get_vector("LEFT", "RIGHT", "ui_up", "ui_down")
		targetVelocityX = moveDirection.x * maxSpeedMove
	
	# плавное движение
	var accelMove: float = accelerationMove if targetVelocityX != 0.0 else deaccelerationMove
	velocity.x = move_toward(velocity.x, targetVelocityX, accelMove)
	
	# прицеливание
	if InputManager.getMode() == InputManager.InputMode.TOUCH:
		if touchAimActive:
			aimSprite.position = touchAimDragOffset
	else:
		# на клавамыши прицел гуляет свободно
		if InputManager.getMode() == InputManager.InputMode.KEYBOARD_MOUSE:
			aimPosition = get_global_mouse_position() - global_position
		# на геймпаде по правому стику
		else:
			var aimX = Input.get_axis("AIMLEFT", "AIMRIGHT")
			var aimY = Input.get_axis("AIMUP", "AIMDOWN")
			aimPosition = Vector2(aimX, aimY) * maxDistanceAim
			
			# определяем, было ли последнее действие правого стика геймпада
			# тем же, если нет то запускаем анимацию прицела
			var aimGamepadActive: bool = true if aimPosition != Vector2.ZERO else false
			if lastAimGamepadActive != aimGamepadActive:
				if aimGamepadActive:
					aimFrontAnimationTween()
				else:
					aimBackAnimationTween()
			lastAimGamepadActive = aimGamepadActive
			
			# ограничиваем максимальную дистанцию прицела
			if aimPosition.length() > maxDistanceAim:
				aimPosition = aimPosition.normalized() * maxDistanceAim
		
		# обновляем спрайт прицела и направление оружия
		aimSprite.position = aimPosition
		aimSprite.visible = true
		weapon.rotation = aimPosition.angle()
	
	# прыжок
	if InputManager.getMode() != InputManager.InputMode.TOUCH:
		if Input.is_action_pressed("JUMP") and is_on_floor():
			velocity.y = jumpVelocity
	
	# стрельба
	if InputManager.getMode() == InputManager.InputMode.TOUCH:
		# автоматическая стрельба при касании
		if touchAimActive:
			shoot()
	elif InputManager.getMode() == InputManager.InputMode.KEYBOARD_MOUSE:
		# на пк ТОЛЬКО если нажата клавиша выстрела
		if Input.is_action_pressed("SHOOT"):
			shoot()
	elif InputManager.getMode() == InputManager.InputMode.GAMEPAD:
		# на геймпаде сразу хуярим
		if aimPosition != Vector2.ZERO:
			shoot()

func _input(event: InputEvent) -> void:
	# если стоит не мобильный режим, то не отслеживаем касания экрана для мобильных
	if InputManager.getMode() != InputManager.InputMode.TOUCH: return
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
	if !projectileTimer.is_stopped(): return
	
	var direction: Vector2
	if InputManager.getMode() == InputManager.InputMode.TOUCH:
		if not touchAimActive or touchAimDragOffset.length() <= maxDistanceAim / 10:
			return
		direction = touchAimDragOffset.normalized()
	else:
		direction = aimPosition.normalized()
	
	var projectile: Area2D = pool.getProjectile()
	projectile.activate(global_position, direction)
	velocity -= direction * projectile.recoilForce
	projectileTimer.start()
	
	if camera == null: camera = get_tree().get_first_node_in_group("camera")
	if camera and camera.has_method("applyShake"): camera.applyShake(projectile.recoilForce * 0.01, 0.05)

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
