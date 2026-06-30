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

# --- инвентарь ---
var inventory: Array = []
var weapons: Array = []
var maxWeapons: int = 4

# --- модификаторы ---
var multipliers: Dictionary = {
	"multiplierPlayerSpeed":                   1.0,
	"multiplierPlayerJumpVelocity":            1.0,
	"multiplierPlayerHealth":                  1.0,
	"multiplierPlayerProjectileTimerWaitTime": 1.0,
	"multiplierProjectileSpeed":               1.0,
	"multiplierProjectileRecoilForce":         1.0,
	"multiplierProjectileDamage":              1.0,
	"multiplierSpeedLocAcceleration":          1.0,
	"multiplierBlockHealth":                   1.0,
	"multiplierBlockDamagingDamage":           1.0,
	"multiplierBlockPoolBlocksBeforePortal":   1.0,
	"multiplierBlockPoolMinInterval":          1.0,
	"multiplierBlockPoolMaxInterval":          1.0,
}


# --- настройки ---
var sensivityMove: float = 2.5
var sensivityAim: float = 1.5
var aimGamepadDeadZone: float = 0.2
var enableAnimations: bool = true
var enableShakeScreen: bool = true
var forceInputTypeSelect: int = -1


func _input(event):
	if Input.is_action_just_pressed("ESC"):
		addItemToInventory("poop1")

func resetLocationData():
	speedLoc = 100.0

func addItemToInventory(id: String):
	print(ItemDataBase.ItemData)
	if !(id in ItemDataBase.ItemData):
		print("нет такого предмета")
		return
	inventory.append(id)
	calculateMultipliers()

func resetMultiplier():
	for key in multipliers.keys():
		multipliers[key] = 1.0

func calculateMultipliers():
	resetMultiplier()
	for id in inventory:
		var d = ItemDataBase.ItemData.get(id)
		if d and d.has("multipliers"):
			for key in d.multipliers:
				if multipliers.has(key):
					multipliers[key] += d.multipliers[key]
	
	printGlobalMultipliers()

func printGlobalMultipliers():
	print("--- ПРОВЕРКА МОДИФИКАТОРОВ GLOBAL ---")
	for key in multipliers:
		print("Global." + key + ": ", multipliers[key])
	print("-------------------------------------")
