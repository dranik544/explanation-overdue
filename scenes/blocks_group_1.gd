extends Node2D

func _process(delta):
	# двигаем блоки влево
	position.x -= Global.speedLoc * delta
	
	# возврат в пул если зашло за границы экрана
	if position.x < -350:
		get_parent().returnBlock(self)

func activate():
	set_process(true)
	for i in get_children():
		if i.has_method("activate"): i.activate()

func deactivate():
	set_process(false)
	for i in get_children():
		if i.has_method("deactivate"): i.deactivate()
