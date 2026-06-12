extends Node

var sensivityMove: float = 1.5
var sensivityAim: float = 1.5
var speedLoc: float = 180.0
var aimGamepadDeadZone: float = 0.2
enum locations {forest}
export(locations) var currentLocation = locations.forest
