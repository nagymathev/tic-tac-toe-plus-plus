use godot::prelude::*;

mod renetclient;

struct ClientRenet;

#[gdextension]
unsafe impl ExtensionLibrary for ClientRenet {}
