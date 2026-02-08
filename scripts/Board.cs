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
		GD.Print("[Board](OnBoardResourceChanged) Running OnBoardResourceChanged");
		_eventcalls++;
		if (_boardStats == null)
		{
			ConnectBoardStats();
		}
		RemoveBoard();
		CreateBoard();
		QueueRedraw();
		GD.Print("[Board](OnBoardResourceChanged) ", _eventcalls);
	}

	/// <summary>
	/// Returns <c>true</c> if new connection, <c>false</c> if it's already connected.
	/// </summary>
	/// <returns></returns>
	private bool ConnectBoardStats()
	{
		GD.Print("[Board](ConnectBoardStats) Loading and Connecting to <BoardResource>");
		_boardStats = GD.Load<BoardResource>("res://resources/board_resource_default.tres");
		if (_boardStats == null)
		{
			GD.Print("[Board](ConnectBoardStats) Failed to load <BoardResource>");
		}

		GD.Print("[Board](ConnectBoardStats) Printing BEGIN SignalConnectionList nodes...");
		var alreadyInList = false;
		foreach (var dict in _boardStats.GetSignalConnectionList(BoardResource.SignalName.Changed))
		{
			var nodeInList = ((Callable)dict["callable"]).Target;
			GD.Print($"[Board](ConnectBoardStats)<SignalConnectionList> {nodeInList}");
			alreadyInList = nodeInList == this;
			break;
		}
		GD.Print("[Board](ConnectBoardStats) Printing END");

		if (alreadyInList)
		{
			GD.Print("[Board](ConnectBoardStats) Already connected to <Changed>, aborting connection...");
			return false;
		}
		GD.Print("[Board](ConnectBoardStats) Not yet connected to <Changed>, connecting...");
		_boardStats.Connect(BoardResource.SignalName.Changed, Callable.From(OnBoardResourceChanged));
		GD.Print("[Board](ConnectBoardStats) Connection Count: ", _boardStats.GetSignalConnectionList(BoardResource.SignalName.Changed).Count);
		return true;
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

	public override void _EnterTree()
	{
		GD.Print("[Board](_EnterTree) Enters tree.");
	}

	public override void _ExitTree()
	{
		GD.Print("[Board](_ExitTree) Exiting Tree.");
	}

	public override void _Ready()
	{
		GD.Print("[Board](_Ready) Ready.");
		var newConnection = ConnectBoardStats();
		if (newConnection)
		{
			OnBoardResourceChanged();
		}
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
