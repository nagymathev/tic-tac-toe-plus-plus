use godot::prelude::*;

#[derive(GodotConvert, Var, Export, Default, Clone)]
#[godot(via = i64)]
pub enum Tile {
    #[default]
    Empty,
    Tic,
    Tac,
}

impl From<store::Tile> for Tile {
    fn from(value: store::Tile) -> Self {
        match value {
            store::Tile::Empty => Self::Empty,
            store::Tile::Tic => Self::Tic,
            store::Tile::Tac => Self::Tac,
        }
    }
}
