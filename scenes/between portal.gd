extends Node2D

onready var button1 = $CanvasLayer/vbox/hboxbuttons/Button1
onready var button2 = $CanvasLayer/vbox/hboxbuttons/Button2
onready var buttonText1 = $CanvasLayer/vbox/hboxbuttons/Button1/RichTextLabel
onready var buttonText2 = $CanvasLayer/vbox/hboxbuttons/Button2/RichTextLabel



func _ready():
	Global.printGlobalMultipliers()
	
	button1.connect("pressed", self, "button1pressed")
	button2.connect("pressed", self, "button2pressed")
	
	randomEnhancementButtons()
	
#	yield(get_tree().create_timer(0.5), "timeout")
#	goToNextLocation()

func button1pressed():
	var btn1index: int = button1.get_meta("index")
	Global.updateMultipliers(btn1index)
	Global.printGlobalMultipliers()
	goToNextLocation()

func button2pressed():
	var btn2index: int = button2.get_meta("index")
	Global.updateMultipliers(btn2index)
	Global.printGlobalMultipliers()
	goToNextLocation()


func randomEnhancementButtons():
	var randomIndex1: int
	var randomIndex2: int
	
	randomize()
	
	randomIndex1 = randi() % Global.enhancesData.size()
	randomIndex2 = randi() % Global.enhancesData.size()
	while randomIndex2 == randomIndex1:
		randomIndex2 = randi() % Global.enhancesData.size()
	
	
	buttonText1.bbcode_text = (
		"[font=res://themes/large_font.tres]" + Global.enhancesData[randomIndex1]["name"] + "[/font]" +
		"[font=res://themes/normal_font.tres]" + "\n" + Global.enhancesData[randomIndex1]["desc"] + "[/font]"
	)
	buttonText2.bbcode_text = (
		"[font=res://themes/large_font.tres]" + Global.enhancesData[randomIndex2]["name"] + "[/font]" +
		"[font=res://themes/normal_font.tres]" + "\n" + Global.enhancesData[randomIndex2]["desc"] + "[/font]"
	)
	button1.set_meta("index", randomIndex1)
	button2.set_meta("index", randomIndex2)


func goToNextLocation():
	var randomLocationNum: int
	
	randomLocationNum = Global.currentLocationIndex
	while randomLocationNum == Global.currentLocationIndex:
		randomLocationNum = randi() % Global.locationsScenes.size()
	
	var randomLocation: String = Global.locationsScenes[randomLocationNum]
	print("cur loc num: ", str(Global.currentLocationIndex))
	print("random loc num: ", str(randomLocationNum))
	get_tree().change_scene(randomLocation)
