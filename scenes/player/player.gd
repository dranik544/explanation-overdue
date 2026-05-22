extends CharacterBody2D

@onready var aimSprite: Sprite2D = $aimSprite

var touchMoveActive: bool = false     # срабатывает, когда касание части экрана для ходьбы активно
var touchMoveStartX: float = 0.0      # расчёт начальной точки касания
var touchMoveDragOffsetX: float = 0.0 # финальный расчёт движения

var touchAimActive: bool = false               # срабатывает, когда касание части экрана для прицеливания активно
var touchAimStart: Vector2 = Vector2.ZERO      # расчёт начальной точки касания
var touchAimDragOffset: Vector2 = Vector2.ZERO # финальный расчёт расположения прицела

@export var maxSpeedMove: float = 300.0              # максимальная скорость передвижения игрока
@export var accelerationMove: float = 20.0           # плавность начала ходьбы
@export var deaccelerationMove: float = 40.0         # плавность конца ходьбы


func _ready() -> void:
	aimSprite.visible = false

func _physics_process(delta: float) -> void:
	# расчёт силы ходьбы и плавности
	var targetVelocityX: float = clampf(touchMoveDragOffsetX, -maxSpeedMove, maxSpeedMove) if touchMoveActive else 0.0
	var accelMove: float = accelerationMove if targetVelocityX != 0.0 else deaccelerationMove
	
	# плавное движение игрока
	velocity.x = move_toward(velocity.x, targetVelocityX, accelMove)
	
	# если касание для прицела активно, то срабатывает перемещение на позиции, иначе скрытие
	if touchAimActive: aimSprite.position = touchAimDragOffset
	else: aimSprite.visible = false
	
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
			touchMoveStartX = event.position.x
			touchMoveDragOffsetX = 0.0
		else:
			touchMoveActive = false
			touchMoveDragOffsetX = 0.0
	elif event is InputEventScreenDrag and touchMoveActive:
		touchMoveDragOffsetX = (event.position.x - touchMoveStartX) * Global.sensivityMove

func rightTouch(event: InputEvent):
	if event is InputEventScreenTouch:
		if event.pressed:
			touchAimActive = true
			touchAimStart = event.position
			touchAimDragOffset = Vector2.ZERO
			aimSprite.visible = true
		else:
			touchAimActive = false
			touchAimDragOffset = Vector2.ZERO
			aimSprite.visible = false
	elif event is InputEventScreenDrag and touchAimActive:
		touchAimDragOffset = (event.position - touchAimStart) * Global.sensivityAim
