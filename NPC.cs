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
	}

	public override void _PhysicsProcess(double delta)
	{
		pf.Progress += 0.1f;
	}



}
