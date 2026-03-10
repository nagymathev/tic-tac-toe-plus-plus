use crate::tile::Tile;
use godot::meta::ByValue;
use godot::prelude::*;

#[derive(Debug, Clone)]
pub struct Player(store::Player);

impl From<store::Player> for Player {
    fn from(value: store::Player) -> Self {
        Self(store::Player {
            name: value.name,
            piece: value.piece,
        })
    }
}

impl GodotConvert for Player {
    type Via = VarDictionary;
}

impl ToGodot for Player {
    type Pass = ByValue;

    fn to_godot(&self) -> Self::Via {
        vdict! {
            "name": self.0.name.to_string(),
            "tile": Tile::from(self.0.piece),
        }
    }
}
