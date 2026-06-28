extends Node

var speedLoc: float = 100.0
enum locations {city, forest, hell}
export(locations) var currentLocation = locations.city
export(int) var currentLocationIndex = 0
var playerHealth: float

# --- пути к сценам локаций ---
var locationsScenes: Array = [
	"res://scenes/main.tscn",       # city
	"res://scenes/main.tscn",       # forest
	"res://scenes/main.tscn"        # hell
]

# --- улучшения ---
var enhancesData: Array = [
	{   # 0
		"name": "Мощные сиськэ",
		"desc": "Улучшит ваше тело, но снаряды станут слабее"
	},
	{   # 1
		"name": "Мощные ношкэ",
		"desc": "Скорость и прыжки будут прокачаны, но скорость локации станет выше"
	},
	{   # 2
		"name": "Мощные пулькэ",
		"desc": "Улучшит снаряды, но блоки станут мощнее"
	},
	{   # 3
		"name": "АНАЛЬНАЯ ПРОБКА",
		"desc": "ПРОБКА ПРОБЧИТ ВАШ АНАЛ"
	},
	{   # 4
		"name": "ИШаК",
		"desc": "БЕСПЛАТНЫЙ ОТСОС"
	},
	{   # 5
		"name": "Мопулщ ьныекэ",
		"desc": "Улу слокинарнстанут чщншитояды,  б моее"
	},
]

# --- модификаторы ---
# игрок
var multiplierPlayerSpeed: float =                    1.0
var multiplierPlayerJumpVelocity: float =             1.0
var multiplierPlayerHealth: float =                   1.0
var multiplierPlayerProjectileTimerWaitTime: float =  1.0
# проджектайл
var multiplierProjectileSpeed: float =                1.0
var multiplierProjectileRecoilForce: float =          1.0
var multiplierProjectileDamage: float =               1.0
# локация
var multiplierSpeedLocAcceleration: float =           1.0
# блок
var multiplierBlockHealth: float =                    1.0
var multiplierBlockDamagingDamage: float =            1.0
var multiplierBlockPoolBlocksBeforePortal: float =    1.0
var multiplierBlockPoolMinInterval: float =           1.0
var multiplierBlockPoolMaxInterval: float =           1.0

# --- настройки ---
var sensivityMove: float = 2.5
var sensivityAim: float = 1.5
var aimGamepadDeadZone: float = 0.2
var enableAnimations: bool = true
var enableShakeScreen: bool = true
var forceInputTypeSelect: int = -1


func resetLocationData():
	speedLoc = 100.0

# здесь будет список всех улучшений
func updateMultipliers(index: int):
	match index:
		0:
			multiplierPlayerJumpVelocity += 0.2
			multiplierPlayerSpeed += 0.2
			multiplierPlayerHealth += 0.2
			multiplierProjectileRecoilForce -= 0.4
			multiplierProjectileDamage -= 0.2
		1:
			multiplierPlayerJumpVelocity += 0.4
			multiplierPlayerSpeed += 0.4
			multiplierSpeedLocAcceleration += 1.5
		2:
			multiplierProjectileDamage += 0.5
			multiplierProjectileRecoilForce += 0.2
			multiplierProjectileSpeed += 1.0
			multiplierBlockHealth += 1.0
			multiplierBlockDamagingDamage += 0.5
		3:
			multiplierPlayerJumpVelocity += 0.2
			multiplierPlayerSpeed += 0.2
			multiplierPlayerHealth += 0.2
			multiplierProjectileRecoilForce -= 0.4
			multiplierProjectileDamage -= 0.2
		4:
			multiplierPlayerJumpVelocity += 0.4
			multiplierPlayerSpeed += 0.4
			multiplierSpeedLocAcceleration += 1.5
		5:
			multiplierProjectileDamage += 0.5
			multiplierProjectileRecoilForce += 0.2
			multiplierProjectileSpeed += 1.0
			multiplierBlockHealth += 1.0
			multiplierBlockDamagingDamage += 0.5

func printGlobalMultipliers():
	print("--- ПРОВЕРКА МОДИФИКАТОРОВ GLOBAL ---")
	# Игрок
	print("Global.multiplierPlayerSpeed: ", Global.multiplierPlayerSpeed)
	print("Global.multiplierPlayerJumpVelocity: ", Global.multiplierPlayerJumpVelocity)
	print("Global.multiplierPlayerHealth: ", Global.multiplierPlayerHealth)
	print("Global.multiplierPlayerProjectileTimerWaitTime: ", Global.multiplierPlayerProjectileTimerWaitTime)
	
	# Проджектайл
	print("Global.multiplierProjectileSpeed: ", Global.multiplierProjectileSpeed)
	print("Global.multiplierProjectileRecoilForce: ", Global.multiplierProjectileRecoilForce)
	print("Global.multiplierProjectileDamage: ", Global.multiplierProjectileDamage)
	
	# Локация
	print("Global.multiplierSpeedLocAcceleration: ", Global.multiplierSpeedLocAcceleration)
	
	# Блок
	print("Global.multiplierBlockHealth: ", Global.multiplierBlockHealth)
	print("Global.multiplierBlockDamagingDamage: ", Global.multiplierBlockDamagingDamage)
	print("Global.multiplierBlockPoolBlocksBeforePortal: ", Global.multiplierBlockPoolBlocksBeforePortal)
	print("Global.multiplierBlockPoolMinInterval: ", Global.multiplierBlockPoolMinInterval)
	print("Global.multiplierBlockPoolMaxInterval: ", Global.multiplierBlockPoolMaxInterval)
	print("-------------------------------------")
