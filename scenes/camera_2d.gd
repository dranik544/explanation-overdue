extends Camera2D

var shakeIntensity: float = 0.0   # сила тряски
var shakeTime: float = 0.0        # время тряски
var basePosition: Vector2 = Vector2.ZERO

export(NodePath) var playerPath   #
onready var player: KinematicBody2D = get_node(playerPath) if playerPath else null


func _ready() -> void:
	add_to_group("camera")
	basePosition = global_position

# эта функция при вызове начинает тряску
func applyShake(intensity: float, duration: float):
	shakeTime = duration
	shakeIntensity = intensity
	shakeIntensity = intensity

func _process(delta: float) -> void:
	if player:
		position = basePosition + (player.global_position * 0.05)
	
	# если время тряски не истекло
	if shakeTime > 0:
		# убавляем время и трясём экран
		shakeTime -= delta
		offset = Vector2(
			rand_range(-shakeIntensity, shakeIntensity),
			rand_range(-shakeIntensity, shakeIntensity)
		)
		rotation = rand_range(-shakeIntensity, shakeIntensity) * 0.01
		# если время закончилось, то возвращаем оффсет
		if shakeTime <= 0:
			offset = Vector2.ZERO
			rotation = 0.0
