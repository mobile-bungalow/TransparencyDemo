using Godot;

public partial class Obstacle : StaticBody3D
{

	[Export]
	public float FadeState = 1.0f;

	private MeshInstance3D mesh;
	private AnimationPlayer player;

	enum DissolveState
	{
		Dissolving,
		Dissolved,
		Solid,
	}

	private DissolveState DState = DissolveState.Solid;

	public void Dissolve()
	{
		switch (DState)
		{
			case DissolveState.Solid:
				player.Play("burn");
				player.Queue("reassemble");
				DState = DissolveState.Dissolving;
				break;
			case DissolveState.Dissolving:
				DState = FadeState == 0.0 ? DissolveState.Dissolved : DState;
				break;
			case DissolveState.Dissolved:
				// repeatedly start the reassemble animation, which is empty for two seconds; 
				// you **should** do this with a timer node
				player.Stop();
				FadeState = 0.0f;
				player.ClearQueue();
				player.Queue("reassemble");
				break;
		}


	}

	public override void _Ready()
	{
		mesh = GetNode<MeshInstance3D>("MeshInstance3D");
		player = GetNode<AnimationPlayer>("AnimationPlayer");
		FadeState = 1;
	}

	private float prev = 1.0f;
	public override void _Process(double delta)
	{
		if (prev != FadeState)
		{
			mesh.SetInstanceShaderParameter("fade", FadeState);
			prev = FadeState;
			DState = FadeState == 1.0 ? DissolveState.Solid : DState;
		}
	}
}
