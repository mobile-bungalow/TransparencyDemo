extends CharacterBody3D
class_name NPC

@onready var camera_world : Camera3D = $"%Camera3D"
@onready var noti : VisibleOnScreenNotifier3D = $"VisibleOnScreenNotifier3D"
@onready var pf : PathFollow3D = get_parent() 
var is_inside_hidden = false;

func _physics_process(_delta):
		pf.progress += 0.1;

