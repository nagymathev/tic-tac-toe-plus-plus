using Godot;
using System;

[GlobalClass][Tool]
public partial class BoardCell : AnimatedSprite2D
{
	// Used for the SpriteFrames
	private enum CellStates
	{
		Normal,
		Hovered,
		Pressed
	}

	private enum XOStates
	{
		X,
		O
	}

	private CellStates _state = CellStates.Normal;
	private XOStates _xoState = XOStates.X;
	private Area2D _mouseDetectionArea;
	
	public override void _Ready()
	{
		_mouseDetectionArea = GetNode<Area2D>("MouseDetectionArea");
		_mouseDetectionArea.MouseEntered += OnMouseEntered;
		_mouseDetectionArea.MouseExited += OnMouseExited;
	}

	private void OnMouseEntered()
	{
		ChangeCellState(CellStates.Hovered);
	}

	private void OnMouseExited()
	{
		ChangeCellState(CellStates.Normal);
	}

	private void ChangeCellState(CellStates state)
	{
		_state = state;
		Frame = (int)_state;
	}
}
