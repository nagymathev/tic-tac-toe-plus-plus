using Godot;
using System;

[GlobalClass][Tool]
public partial class BoardSettings : Node
{
	// Necessary to be able to access this Singleton without GetNode() Hackery.
	public static BoardSettings Instance { get; private set; }
	
	[Signal]
	public delegate void BoardStatsChangedEventHandler();
	
	private BoardResource _boardStats;

	[Export]
	public BoardResource BoardStats
	{
		get => _boardStats;
		set
		{
			_boardStats = value;
			if (_boardStats != null)
			{
				GD.Print("[BoardSettings] Attaching and Printing SignalConnectionList:");
				_boardStats.Changed += OnBoardResourceChanged;
				GD.Print("[BoardSettings] ", GetSignalConnectionList(SignalName.BoardStatsChanged));
				GD.Print("[BoardSettings] Print Tree: ");
				PrintTree();
				GD.Print("---------------------------------------------------------------------------------------------------");
			}
		}
	}

	private void OnBoardResourceChanged()
	{
		GD.Print("[BoardSettings] Running OnBoardResourceChanged. Emitting BoardStatsChanged...");
		// TODO: Warning: for some reason after building source and reloading the editor it starts calling this multiple times.
		// So still not fixed with this thing and might cause some weird bugs in the future so just keep that in mind.
		EmitSignal(SignalName.BoardStatsChanged);
		GD.Print("---------------------------------------------------------------------------------------------------");
	}

	public override void _EnterTree()
	{
		GD.Print("[BoardSettings] Enters tree.");
		if (Instance != null)
		{
			GD.Print($"[BoardSettings] Instance already exists ({Instance}) that is not self ({this}): freeing self.");
			return;
		}
		else
		{
			GD.Print($"[BoardSettings] No instance detected... Settings self as instance: {this}");
			Instance = this;
		}
		GD.Print($"[BoardSettings] Instance Pointer: {Instance}");
		GD.Print("---------------------------------------------------------------------------------------------------");
	}

	public override void _ExitTree()
	{
		GD.Print("[BoardSettings] Exits tree.");
		GD.Print($"[BoardSettings] Pointer: {this}");
		GD.Print("[BoardSettings] Freeing self.");
		_boardStats.Changed -= OnBoardResourceChanged;
		GD.Print("---------------------------------------------------------------------------------------------------");
	}
}
