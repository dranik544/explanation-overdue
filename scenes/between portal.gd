extends Node2D


#func _ready():
#	yield(get_tree().create_timer(0.5), "timeout")
#	goToNextLocation()

func goToNextLocation():
	var randomLocationNum: int
	
	randomLocationNum = Global.currentLocationIndex
	while randomLocationNum == Global.currentLocationIndex:
		randomLocationNum = randi() % Global.locationsScenes.size()
	
	var randomLocation: String = Global.locationsScenes[randomLocationNum]
	print("cur loc num: ", str(Global.currentLocationIndex))
	print("random loc num: ", str(randomLocationNum))
	get_tree().change_scene(randomLocation)
