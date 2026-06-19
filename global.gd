extends Node

var speedLoc: float = 180.0
enum locations {forest}
export(locations) var currentLocation = locations.forest

# --- модификации значений ---
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

# --- настройки ---
var sensivityMove: float = 1.5
var sensivityAim: float = 1.5
var aimGamepadDeadZone: float = 0.2
var enableAnimations: bool = true
var enableShakeScreen: bool = true
var forceInputTypeSelect: int = -1
