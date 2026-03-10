use godot::prelude::*;

mod player;
mod renetclient;
mod tile;

struct ClientRenet;

#[gdextension]
unsafe impl ExtensionLibrary for ClientRenet {}
