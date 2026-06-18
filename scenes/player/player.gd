extends KinematicBody2D

onready var sprite: AnimatedSprite = $Sprite
onready var spriteEyes: AnimatedSprite = $eyes
onready var aimSprite: Sprite = $aimSprite
onready var weapon: Sprite = $weapon
onready var projectileTimer: Timer = $projectileTimer
onready var damageSplash = $GUI/damageSplash

var velocity: Vector2 = Vector2.ZERO              # просто velocity
var gravity: float = ProjectSettings.get_setting(
	"physics/2d/default_gravity"                  # гравитация (берётся из настроек)
) * 10
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

export(float) var maxSpeedMove = 300.0            # максимальная скорость передвижения игрока
export(float) var jumpVelocity = -350.0           # сила прыжка (отрицательная — вверх)
export(float) var accelerationMove = 30.0         # плавность начала ходьбы
export(float) var deaccelerationMove = 60.0       # плавность конца ходьбы
export(bool) var enableMaxDistanceAim = true      # включить ограничения прицела по растоянию
export(float) var maxDistanceAim = 75.0           # ограничения прицела по растоянию                     
export(int) var health = 100                      # здоровье игрока
var maxHealth: int                                # максимальное возможное здоровье

export(NodePath) var poolPath                                                 # ПУТЬ К внешний пул проджектайлов
onready var pool: Node2D = get_node(poolPath) if poolPath else null           # внешний пул проджектайлов
export(NodePath) var cameraPath                                               # ПУТЬ К камера
onready var camera: Camera2D = get_node(cameraPath) if cameraPath else null   # камера


func _ready() -> void:
	add_to_group("player")
	
	aimSprite.visible = false
	
	# применения модификаций
	health *= Global.multiplierPlayerHealth
	maxHealth = health
	maxSpeedMove *= Global.multiplierPlayerSpeed
	jumpVelocity *= Global.multiplierPlayerJumpVelocity

func _physics_process(delta: float) -> void:
	InputManagement()
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	velocity = move_and_slide(velocity, Vector2.UP)

func _process(delta):
	sprite.speed_scale = (Global.speedLoc + abs(velocity.x)) * 0.008

func InputManagement():
	# заготовка для нужного Velocity по X оси
	var targetVelocityX: float = 0.0
	if InputManager.getMode() == InputManager.InputMode.TOUCH:
		# если тачмод:
		targetVelocityX = clamp(touchMoveDragOffset.x, -maxSpeedMove, maxSpeedMove) if touchMoveActive else 0.0
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
			# определяем сторону и силу передвижения стика
			var aimX = Input.get_joy_axis(0, JOY_AXIS_2)
			var aimY = Input.get_joy_axis(0, JOY_AXIS_3)
			var rawAim = Vector2(aimX, aimY)
			# нормализуем сторону стрельбы со стика
			if rawAim.length() < Global.aimGamepadDeadZone:
				rawAim = Vector2.ZERO
			else:
				rawAim = rawAim.normalized() * ((rawAim.length() - Global.aimGamepadDeadZone) / (1.0 - Global.aimGamepadDeadZone))
			
			# задаём позицию прицела
			aimPosition = rawAim * maxDistanceAim
			
			# если геймпад активен, то активируем анимацию, в ином случае другую
			var aimGamepadActive: bool = rawAim.length() > 0.1
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
		
		if touchMoveStart.y - event.position.y > get_viewport_rect().size.y / 4 / Global.sensivityMove and is_on_floor():
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
	if !Global.enableAnimations: return
	
	aimSprite.modulate.a = 1.0 
	
	var tween: Tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(aimSprite, "position", aimSprite.position, Vector2.ZERO, 0.2, Tween.TRANS_BACK, Tween.EASE_IN)
	tween.interpolate_property(aimSprite, "modulate:a", aimSprite.modulate.a, 0.0, 0.2)
	tween.start()
	
	yield(tween, "tween_completed")
	tween.queue_free()
	
	if not touchAimActive:
		aimSprite.visible = false

func aimFrontAnimationTween():
	if !Global.enableAnimations: return
	
	aimSprite.visible = true
	aimSprite.modulate.a = 0.0
	aimSprite.scale = Vector2(4.0, 4.0)
	
	var tween: Tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(aimSprite, "scale", aimSprite.scale, Vector2(1.0, 1.0), 0.2, Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.interpolate_property(aimSprite, "scale", aimSprite.scale, Vector2(1.0, 1.0), 0.2, Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.interpolate_property(aimSprite, "modulate:a", aimSprite.modulate.a, 1.0, 0.3, Tween.TRANS_LINEAR)
	tween.start()
	
	yield(tween, "tween_completed")
	tween.queue_free()
	
	if not touchAimActive:
		aimSprite.visible = false

func damage(count: int):
	if health <= 0: return
	
	health -= count
	Global.speedLoc = max(Global.speedLoc - (maxHealth - health), 120.0)   # скорость локации упадёт, но не ниже 120
	
	if health <= 0: death()
	
	if Global.enableAnimations:
		var tween: Tween = Tween.new()
		add_child(tween)
		
		spriteEyes.animation = "damageEyes_" + str(sprite.animation)
		
		var tweenDS: Tween = Tween.new()
		add_child(tweenDS)
		tweenDS.interpolate_property(damageSplash, "modulate:a", 1.0, 0.0, 1.0, Tween.TRANS_CIRC, Tween.EASE_IN)
		tweenDS.start()
		
		tween.interpolate_property(sprite, "modulate", sprite.modulate, Color(1.0, 0.0, 0.0, 1.0), 0.1, Tween.TRANS_CIRC, Tween.EASE_IN)
		tween.start()
		yield(tween, "tween_completed")
		
		tween.interpolate_property(sprite, "modulate", sprite.modulate, Color(1.0, 1.0, 1.0, 1.0), 2.0, Tween.TRANS_CIRC, Tween.EASE_OUT)
		yield(tween, "tween_completed")
		
		spriteEyes.animation = "none"
		
		tween.queue_free()

func death():
	pass
	# будет сделано позже
