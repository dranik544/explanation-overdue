extends Node

var ItemData: Array = [
		# item index
	{   # 0
		"name": "Кусок говна",
		"desc": "Уменьшает некоторые модификаторы игрока на 0.5, но повышает их с каждым уровнем на 10%",
		"icon": "res://sprites/theme/button1.png", # тестовый спрайт
		
		"tags": ["none"],
		"multipliers": {
			"multiplierPlayerSpeed": -0.5,
			"multiplierPlayerHealth": -0.5,
		},
		"funcplay": false
	}
]
