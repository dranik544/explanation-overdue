extends Node

var speedLoc: float = 180.0
enum locations {forest}
export(locations) var currentLocation = locations.forest

# настройки
var sensivityMove: float = 1.5
var sensivityAim: float = 1.5
var aimGamepadDeadZone: float = 0.2
var enableAnimations: bool = true
var enableShakeScreen: bool = true
