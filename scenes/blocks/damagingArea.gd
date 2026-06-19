extends Area2D

export(NodePath) var blockPath
onready var block: StaticBody2D = get_node(blockPath) if blockPath else null

var player: KinematicBody2D
var damage: int


func _ready():
	if player == null and get_tree().get_first_node_in_group("player") != null: player = get_tree().get_first_node_in_group("player")
	connect("body_entered", self, "bodyEntered")
	
	if block != null:
		if block.has_signal("blockDeactivated"): block.connect("blockDeactivated", self, "blockDeactivated");
		if block.has_signal("blockActivated"): block.connect("blockActivated", self, "blockActivated");
		damage = block.damagingTypeDamage

func bodyEntered(body: Node2D):
	if player == null and get_tree().get_first_node_in_group("player") != null: player = get_tree().get_first_node_in_group("player")
	
	if body == player:
		if body.has_method("damage"):
			body.damage(damage)
			
			if block.damagingTypeDestroyAfterDamage: block.destroy(9999)

func blockActivated():
	set_deferred("monitorable", true)
	set_deferred("monitoring", true)

func blockDeactivated():
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)

