using Godot;
using System;
using System.Linq;

[GlobalClass][Tool]
public partial class Board : Node2D
{
	private BoardResource _boardStats;

	private int _eventcalls = 0;

	private void OnBoardResourceChanged()
	{
		GD.Print("[Board] Running OnBoardResourceChanged");
		_eventcalls++;
		RemoveBoard();
		CreateBoard();
		QueueRedraw();
		GD.Print(_eventcalls);
		GD.Print("[Board] ", BoardSettings.Instance.GetSignalConnectionList(BoardSettings.SignalName.BoardStatsChanged));
		GD.Print("---------------------------------------------------------------------------------------------------");
	}

	private void CreateBoard()
	{
		for (int y = 0; y < _boardStats.BoardY; y++)
		{
			for (int x = 0; x < _boardStats.BoardX; x++)
			{
				var cellScene = GD.Load<PackedScene>("res://scenes/board_cell.tscn");
				var cell = cellScene.Instantiate<AnimatedSprite2D>();
				AddChild(cell);
				cell.Position = new Vector2(x * _boardStats.BoardCellSize, y * _boardStats.BoardCellSize);
				cell.Scale = Vector2.One * (_boardStats.BoardCellSize / 32);
			}
		}
	}

	private void RemoveBoard()
	{
		var children = GetChildren();
		children.ToList().ForEach(child => RemoveChild(child));
	}
	
	public override void _ExitTree()
	{
		GD.Print("[Board] Exiting Tree. Removing callback from Board...");
		// BoardSettings.Instance.BoardStatsChanged -= OnBoardResourceChanged;
		GD.Print("[Board] ", BoardSettings.Instance.GetSignalConnectionList(BoardSettings.SignalName.BoardStatsChanged));
		GD.Print("---------------------------------------------------------------------------------------------------");
	}

	public override void _Ready()
	{
		GD.Print("[Board] Ready. Connecting to BoardStatsChanged...");
		_boardStats = BoardSettings.Instance.BoardStats;
		BoardSettings.Instance.BoardStatsChanged += OnBoardResourceChanged;
		// I think this causes some NullPointerExeptions when rebuilding the project while editor is running.
		// TODO: This gets called multiple times actually, need to figure out why
		OnBoardResourceChanged();
		GD.Print("---------------------------------------------------------------------------------------------------");
	}

	public override void _Process(double delta)
	{
	}

	public override void _Draw()
	{
		// Just drawing debug lines to help visualize the board.
		if (Engine.IsEditorHint())
		{
			DrawLine(Vector2.Zero, new Vector2(_boardStats.BoardX * _boardStats.BoardCellSize, 0), Colors.Coral);
			DrawLine(Vector2.Zero, new Vector2(0, _boardStats.BoardY * _boardStats.BoardCellSize), Colors.Coral);
			DrawLine(new Vector2(_boardStats.BoardX * _boardStats.BoardCellSize, 0), new Vector2(_boardStats.BoardX * _boardStats.BoardCellSize, _boardStats.BoardY * _boardStats.BoardCellSize), Colors.Coral);
			DrawLine(new Vector2(0, _boardStats.BoardY * _boardStats.BoardCellSize), new Vector2(_boardStats.BoardX * _boardStats.BoardCellSize, _boardStats.BoardY * _boardStats.BoardCellSize), Colors.Coral);
		}
	}
}
