extends Node2D

export(Global.locations) var currentLocation
export(float) var speedLocAcceleration = 4.0


func _ready():
	Global.resetLocationData()
	Global.currentLocation = currentLocation
	Global.currentLocationIndex = Global.currentLocation


func _process(delta):
	Global.speedLoc += speedLocAcceleration * Global.multipliers["multiplierSpeedLocAcceleration"] * delta
