extends StaticBody3D
class_name  Obstacle

enum DissolveState { Dissolving, Dissolved, Solid }

@onready var mesh = $"MeshInstance3D"
@onready var player = $"AnimationPlayer"
var dstate = DissolveState.Solid

@export var FadeState = 1.0
var prev = 1.0

func _ready():
	FadeState = 1.0;
	pass # Replace with function body.

func dissolve():
	match dstate:
		DissolveState.Solid:
			player.play("burn")
			player.queue("reassemble")
			dstate = DissolveState.Dissolving
		DissolveState.Dissolving:
			dstate = DissolveState.Dissolved if FadeState == 0 else dstate
		DissolveState.Dissolved:
			player.stop()
			FadeState = 0
			player.clear_queue()
			player.queue("reassemble")

func _process(_delta):
	if prev != FadeState:
		mesh.set_instance_shader_parameter("fade", FadeState);
		prev = FadeState
		dstate = DissolveState.Solid if FadeState == 1.0 else dstate;
