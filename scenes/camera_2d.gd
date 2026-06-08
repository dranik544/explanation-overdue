extends Camera2D

var shakeIntensity: float = 0.0   # сила тряски
var shakeTime: float = 0.0        # время тряски


func _ready() -> void:
	add_to_group("camera")

# эта функция при вызове начинает тряску
func applyShake(intensity: float, duration: float):
	shakeTime = duration
	shakeIntensity = intensity

func _process(delta: float) -> void:
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
