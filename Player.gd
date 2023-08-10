extends CharacterBody3D
class_name player

const SPEED = 20.0
const DRAG_SENSITIVITY = 0.005
const MOUSE_BIAS = 2.2
const CAMERA_DISTANCE = 17.0
const SIGHT_RADIUS = 4.0
const NINETY_DEGREES = PI / 2.0

var cam_x_ortho = Vector3.ZERO
var cam_y_ortho = Vector3.ZERO
var drag_dir = Vector2.ZERO
var mouse_down = false;
var prev_mouse_pos = Vector2.ZERO;

@onready var camera_world : Camera3D = $"%Camera3D"

func _ready():
	update_player_move_vectors()

func _process(_delta):
	adjust_camera_to_mouse_position()

func _physics_process(_delta):
	var dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = (cam_y_ortho * dir.y + cam_x_ortho * dir.x) * SPEED
	move_and_slide()

func _input(event):
	var new_state = mouse_down

	if (event.is_action_pressed("click")): new_state = true
	if (event.is_action_released("click")): new_state = false

	if (new_state != mouse_down):
		drag_dir = Vector2.ZERO
		prev_mouse_pos = get_viewport().get_mouse_position()
		update_player_move_vectors()

	if (mouse_down && event is InputEventMouseMotion):
		drag_dir = prev_mouse_pos - event.position 
		prev_mouse_pos = event.position 
		update_player_move_vectors()
		
	mouse_down = new_state

func update_player_move_vectors():
		var cam_direction = camera_world.get_camera_transform().basis.z;
		# project the camera direction onto the floor plane
		var floor_proj = cam_direction - (cam_direction.dot(Vector3.UP) * Vector3.UP);
		cam_y_ortho = floor_proj.normalized();
		cam_x_ortho = floor_proj.rotated(Vector3.UP, NINETY_DEGREES).normalized();

func adjust_camera_to_mouse_position():
	var player_pos = global_position
	var cam_direction = camera_world.get_camera_transform().basis.z;
	var new_cam_pos = (cam_direction.normalized() * CAMERA_DISTANCE) + player_pos;

	var mouse = get_viewport().get_mouse_position();
	var vp_size = get_viewport().get_visible_rect().size;
	var polar_coors = Vector2((mouse.x * 2 - vp_size.x) / vp_size.x, 
							 -(mouse.y * 2 - vp_size.y) / vp_size.y)

	polar_coors *= MOUSE_BIAS

	new_cam_pos += polar_coors.x * cam_x_ortho;
	new_cam_pos -= polar_coors.y * cam_y_ortho;

	player_pos += polar_coors.x * cam_x_ortho;
	player_pos -= polar_coors.y * cam_y_ortho;

	var from_origin = new_cam_pos - player_pos
	from_origin = from_origin.rotated(Vector3.UP, Vector2.UP.cross(drag_dir) * DRAG_SENSITIVITY)
	new_cam_pos = from_origin + player_pos
	drag_dir = Vector2.ZERO;

	camera_world.look_at_from_position(new_cam_pos, player_pos, Vector3.UP)
