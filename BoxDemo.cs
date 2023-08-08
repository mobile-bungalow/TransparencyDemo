using Godot;

// This demo shows how to add a room which hides bodies inside it
// unless the player is inside.
public partial class BoxDemo : Node3D
{
	public Area3D Area;

	private bool PlayerInRoom = false;
	private Godot.Collections.Array<NPC> inside = new Godot.Collections.Array<NPC>();

	public override void _Ready()
	{
		Area = GetNode<Area3D>("Vis");
		var Decal = GetNode<Decal>("Decal");
		Area.BodyEntered += (b) =>
		{
			if (b is CharacterBody3D c)
			{
				Decal.Hide();
				PlayerInRoom = true;
				foreach (var item in inside)
				{
					item.Show();
					item.InsideHidden = false;
				}
			}
			else if (b is NPC n)
			{
				inside.Add(n);
			}

			if (!PlayerInRoom)
			{
				b.Hide();
			}
		};
		Area.BodyExited += (b) =>
		{
			if (b is CharacterBody3D c)
			{
				Decal.Show();
				PlayerInRoom = false;
				foreach (var item in inside)
				{
					item.Show();
					item.InsideHidden = true;
				}
			}
			else if (b is NPC n)
			{
				inside.Remove(n);
				n.Show();
			}
		};
	}

}
