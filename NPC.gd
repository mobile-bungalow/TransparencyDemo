extends CharacterBody3D
class_name NPC

@onready var camera_world : Camera3D = $"%Camera3D"
@onready var noti : VisibleOnScreenNotifier3D = $"VisibleOnScreenNotifier3D"
@onready var pf : PathFollow3D = get_parent() 
var is_inside_hidden = false;

func _process(_delta):
	ray_cast()

func _physics_process(_delta):
		pf.progress += 0.1;

func ray_cast():
	if (is_inside_hidden || !noti.is_on_screen()) : return;

	var space = get_world_3d().direct_space_state
	var rid = get_rid()

	var rq = PhysicsRayQueryParameters3D.new();
	rq.from = camera_world.global_position
	rq.to = global_position; 
	rq.collide_with_areas = true;
	collision_mask = 2;
	while(true):
		var res = space.intersect_ray(rq)
		if (res.keys().size() == 0): break;
		if (res.rid == rid): break;
		var e = rq.exclude;
		e.push_front(res.rid);
		rq.exclude = e;
		if (res.collider is Obstacle):
			res.collider.dissolve();

