extends Node3D

var OnScreenActors: int = 3;
var ActorImage: Image;
var ActorCoordsTex: ImageTexture
@onready var CameraWorld =$"%Camera3D"

const NINETYDEGREES = PI / 2.0;
const TEXWIDTH : int = 255;

func _ready():
	ActorImage = Image.create(TEXWIDTH, 1, false, Image.FORMAT_RGBAF)
	ActorCoordsTex = ImageTexture.new()
	ActorCoordsTex.set_image(ActorImage)
	RenderingServer.global_shader_parameter_set("max_actors_on_screen", TEXWIDTH)

func _update_shader_params():
	var actors = get_tree().get_nodes_in_group("actors")	
	OnScreenActors = actors.size();
	var skipped = 0;
	for i in actors.size():
		var body = actors[i]
		if (body is NPC && body.is_inside_hidden):
			skipped += 1
			continue;
		var sp = CameraWorld.unproject_position(body.global_position)
		ActorImage.set_pixel(i - skipped, 0, Color(sp.x, sp.y, 0))
	
	ActorCoordsTex.update(ActorImage)
	RenderingServer.global_shader_parameter_set("screen_fade_coords", ActorCoordsTex)
	RenderingServer.global_shader_parameter_set("run_length", OnScreenActors - skipped)

func _process(_delta):
	_update_shader_params()

