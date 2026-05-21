extends CharacterBody2D

var touchActive: bool = false
var touchStartX: float = 0.0
var touchDragOffsetX: float = 0.0

@export var maxSpeedMove: float = 300.0
@export var accelerationMove: float = 20.0
@export var deaccelerationMove: float = 40.0


func _physics_process(delta: float) -> void:
	var targetVelocityX: float = clampf(touchDragOffsetX, -maxSpeedMove, maxSpeedMove) if touchActive else 0.0
	var accelMove: float = accelerationMove if targetVelocityX != 0.0 else deaccelerationMove
	
	velocity.x = move_toward(velocity.x, targetVelocityX, accelMove)
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	move_and_slide()
 
func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		if event.position.x < get_viewport_rect().size.x / 2:
			leftTouch(event)

func leftTouch(event: InputEvent):
	if event is InputEventScreenTouch:
		if event.pressed:
			touchActive = true
			touchStartX = event.position.x
			touchDragOffsetX = 0.0
		else:
			touchActive = false
			touchDragOffsetX = 0.0
	elif event is InputEventScreenDrag and touchActive:
		touchDragOffsetX = (event.position.x - touchStartX) * Global.sensivityMove
