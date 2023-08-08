using Godot;
using System;

public partial class NPC : Godot.CharacterBody3D
{
	public const float Speed = 5.0f;

	private PathFollow3D pf;
	public Camera3D CameraWorld;
	public bool InsideHidden = false;
	public VisibleOnScreenNotifier3D Noti;

	public override void _Ready()
	{
		// For demo purposes
		CameraWorld = GetNode<Camera3D>("%Camera3D");
		Noti = GetNode<VisibleOnScreenNotifier3D>("VisibleOnScreenNotifier3D");
		pf = GetParent<PathFollow3D>();
	}

	public override void _Process(double delta)
	{
		RayCast();
	}

	public override void _PhysicsProcess(double delta)
	{
		pf.Progress += 0.1f;
	}

	private void RayCast()
	{
		if (!Noti.IsOnScreen() || InsideHidden)
		{
			return;
		}
		var space = GetWorld3D().DirectSpaceState;
		var rid = GetRid();

		var rq = new PhysicsRayQueryParameters3D
		{
			From = CameraWorld.GlobalPosition,
			To = GlobalPosition,
			CollideWithAreas = true,
			CollisionMask = 0b010,
		};

		while (true)
		{
			var res = space.IntersectRay(rq);
			if (res.Keys.Count == 0) break;
			var rid_hit = res["rid"].As<Rid>();
			if (rid_hit == rid) break;
			var e = rq.Exclude;
			e.Add(rid_hit);
			rq.Exclude = e;
			if (res["collider"].AsGodotObject() is Obstacle o)
			{
				o.Dissolve();
			}
		}
	}


}
