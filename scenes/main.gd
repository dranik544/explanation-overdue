extends Node2D

export(Global.locations) var currentLocation = Global.locations.forest


func _ready():
	Global.currentLocation = currentLocation
