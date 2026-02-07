using Godot;
using System;

[GlobalClass][Tool]
public partial class BoardResource : Resource
{
    private int _boardX = 3;

    [Export(PropertyHint.Range, "1,20,")]
    public int BoardX
    {
        get => _boardX;
        set
        {
            _boardX = value;
            EmitChanged();
        }
    }
    private int _boardY = 3;

    [Export(PropertyHint.Range, "1,20,")]
    public int BoardY
    {
        get => _boardY;
        set
        {
            _boardY = value;   
            EmitChanged();
        }
    }

    private int _boardCellSize = 32;

    [Export(PropertyHint.Range, "32,128,32,prefer_slider")]
    public int BoardCellSize
    {
        get => _boardCellSize;
        set
        {
            _boardCellSize = value;
            EmitChanged();
        }
    }
}
