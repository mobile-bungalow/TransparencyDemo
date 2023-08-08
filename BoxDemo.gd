extends Node3D

@onready var area : Area3D = $"Vis"
@onready var decal : Decal = $"Decal"
var inside = []
var player_in_room = false;
# Called when the node enters the scene tree for the first time.

func body_exited(b):
	if (b is player):
		decal.show()
		player_in_room = false;
		for item in inside:
			item.hide()
			item.is_inside_hidden = true;
	if (b is NPC):
		inside.remove_at(inside.find(b))
		if (!player_in_room):
			b.show()


func body_entered(b):
	if (b is player):
		decal.hide()
		player_in_room = true;
		for item in inside:
			item.show()
			item.is_inside_hidden = false;
	if (b is NPC):
		inside.push_back(b)
		if (!player_in_room):
			b.hide()


func _ready():
	area.body_entered.connect(body_entered)
	area.body_exited.connect(body_exited)
	pass # Replace with function body.
