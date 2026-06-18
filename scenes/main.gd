extends Node2D

export(Global.locations) var currentLocation = Global.locations.forest
export(float) var speedLocAcceleration = 4.0


func _ready():
	Global.currentLocation = currentLocation


func _process(delta):
	Global.speedLoc += speedLocAcceleration * Global.multiplierSpeedLocAcceleration * delta
