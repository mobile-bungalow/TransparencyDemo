using Godot;
using System;
public partial class CharacterBody3D : Godot.CharacterBody3D
{
	public const float SPEED = 10.0f;
	public const float DRAG_SENSITIVITY = 0.01f;
	public const float MOUSE_BIAS = 2.2f;
	public const float CAMERA_DISTANCE = 17.0f;
	const float NINETY_DEGREES = MathF.PI / 2.0f;

	public Vector3 CamXOrtho = Vector3.Zero;
	public Vector3 CamYOrtho = Vector3.Zero;
	public Vector2 DragDir = Vector2.Zero;
	public ShapeCast3D Sight;
	public Camera3D CameraWorld;

	public override void _Ready()
	{
		CameraWorld = GetNode<Camera3D>("%Camera3D");
		UpdatePlayerMoveVectors();
	}

	public override void _Process(double delta)
	{
		AdjustCameraToMousePosition();
	}

	public override void _PhysicsProcess(double delta)
	{

		var Dir = Input.GetVector("ui_left", "ui_right", "ui_up", "ui_down");
		Velocity = (CamYOrtho * Dir.Y + CamXOrtho * Dir.X) * SPEED;
		MoveAndSlide();
	}


	private void UpdatePlayerMoveVectors()
	{
		Vector3 cam_direction = CameraWorld.GetCameraTransform().Basis.Z;
		// project the camera direction onto the floor plane
		Vector3 floor_proj = cam_direction - (cam_direction.Dot(Vector3.Up) * Vector3.Up);
		CamYOrtho = floor_proj.Normalized();
		CamXOrtho = floor_proj.Rotated(Vector3.Up, NINETY_DEGREES).Normalized();
	}

	private void AdjustCameraToMousePosition()
	{
		// adjust camera to track player movement with mouse biasing
		Vector3 player_pos = GlobalTransform.Origin;
		Vector3 cam_direction = CameraWorld.GetCameraTransform().Basis.Z;
		Vector3 new_cam_pos = (cam_direction.Normalized() * CAMERA_DISTANCE) + player_pos;

		// bias with squared distance from center of mouse position;
		Vector2 mouse = GetViewport().GetMousePosition();
		Vector2 VpSize = GetViewport().GetVisibleRect().Size;
		Vector2 PolarCoords = new((mouse.X * 2.0f - VpSize.X) / VpSize.X,
										 -(mouse.Y * 2.0f - VpSize.Y) / VpSize.Y);

		PolarCoords *= MOUSE_BIAS;

		// bias lookfrom
		new_cam_pos += PolarCoords.X * CamXOrtho;
		new_cam_pos -= PolarCoords.Y * CamYOrtho;
		// bias lookat
		player_pos += PolarCoords.X * CamXOrtho;
		player_pos -= PolarCoords.Y * CamYOrtho;

		// rotate current mouse drag
		var from_origin = new_cam_pos - player_pos;
		from_origin = from_origin.Rotated(Vector3.Up, Vector2.Up.Cross(DragDir) * DRAG_SENSITIVITY);
		new_cam_pos = from_origin + player_pos;

		CameraWorld.LookAtFromPosition(new_cam_pos, player_pos, Vector3.Up);
	}

	private bool MouseDown = false;
	private Vector2 previous = Vector2.Up;
	public override void _Input(InputEvent @event)
	{
		if (@event is InputEventMouseButton m)
		{
			if (@event.IsActionPressed("click"))
			{
				previous = m.Position;
				MouseDown = true;
			}
		}

		// you are going to have to add this you your
		// input map if you reuse this controller.
		if (@event.IsActionReleased("click"))
		{
			MouseDown = false;
		}

		if (MouseDown && @event is InputEventMouseMotion ev)
		{
			DragDir = previous - ev.Position;
			previous = ev.Position;
			UpdatePlayerMoveVectors();
		}

		if (!MouseDown)
		{
			DragDir = Vector2.Zero;
		}

		base._Input(@event);
	}


}
