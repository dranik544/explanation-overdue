extends Node

enum InputMode {
	TOUCH,
	KEYBOARD_MOUSE,
	GAMEPAD
}
var currentMode = InputMode.TOUCH


func _input(event):
	# касание или свайп экрана = тачскрин
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		currentMode = InputMode.TOUCH
		#print("touch mode")
	# мышь или клавиатура = клавамышь
	elif event is InputEventMouseButton or event is InputEventMouseMotion or event is InputEventKey:
		currentMode = InputMode.KEYBOARD_MOUSE
		#print("keyboard/mouse mode")
	# кнопки геймпада = консольное
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		currentMode = InputMode.GAMEPAD
		#print("gamepad mode")

func getMode():
	return currentMode
