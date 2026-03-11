use std::{
    net::UdpSocket,
    time::{Duration, SystemTime},
};

use godot::prelude::*;
use renet::{ConnectionConfig, DefaultChannel, RenetClient};
use renet_netcode::{ClientAuthentication, NETCODE_USER_DATA_BYTES, NetcodeClientTransport};

use crate::player::Player;

pub const PROTOCOL_ID: u64 = 7661;

fn to_netcode_user_data(username: &str) -> [u8; NETCODE_USER_DATA_BYTES] {
    let mut user_data = [0u8; NETCODE_USER_DATA_BYTES];
    if username.len() > NETCODE_USER_DATA_BYTES - 8 {
        panic!("Username is too big");
    }
    user_data[0..8].copy_from_slice(&(username.len() as u64).to_le_bytes());
    user_data[8..username.len() + 8].copy_from_slice(username.as_bytes());

    user_data
}

#[derive(GodotClass)]
#[class(no_init, base=Node)]
struct ClientRenet {
    base: Base<Node>,

    client: RenetClient,
    client_id: store::PlayerId,
    transport: NetcodeClientTransport,
}

#[godot_api]
impl ClientRenet {
    /// Called when someone wants to place a tile.
    #[signal]
    fn placed_tile(player_id: store::PlayerId, at: i64);

    /// Called when first created and joined the server, returns self id.
    #[signal]
    fn connected_to_game(client_id: store::PlayerId);

    /// Called when the game begins.
    #[signal]
    fn game_begin(goes_first: store::PlayerId);

    /// Called when any player joins the server, including self, can be used to collect players.
    #[signal]
    fn player_joined(id: store::PlayerId, username: GString);

    /// Called when any player leaves the server.
    #[signal]
    fn player_left(id: store::PlayerId);

    /// Called when game ends because a player left the server.
    #[signal]
    fn game_end_player_left();

    /// Called when game ends because a player won the game.
    #[signal]
    fn game_end_player_won(winner: store::PlayerId);

    #[func]
    fn create_connection(username: GString, server_addr: GString) -> Gd<Self> {
        let connection_config = ConnectionConfig::default();
        let client = RenetClient::new(connection_config);

        let socket = UdpSocket::bind("0.0.0.0:0").unwrap();
        let current_time = SystemTime::now()
            .duration_since(SystemTime::UNIX_EPOCH)
            .unwrap();
        let client_id = current_time.as_millis() as u64;
        let authentication = ClientAuthentication::Unsecure {
            protocol_id: PROTOCOL_ID,
            client_id,
            server_addr: server_addr.to_string().parse().unwrap(),
            user_data: Some(to_netcode_user_data(&username.to_string())),
        };
        let transport = NetcodeClientTransport::new(current_time, authentication, socket).unwrap();

        let s = Gd::from_init_fn(|base| Self {
            base,
            client,
            transport,
            client_id,
        });

        s
    }

    #[func]
    fn place_tile(&mut self, client_id: store::PlayerId, at: i64) {
        let event = store::GameEvent::PlaceTile {
            player_id: client_id,
            at: at as usize,
        };
        self.client.send_message(
            DefaultChannel::ReliableOrdered,
            serde_json::to_string(&event).unwrap(),
        );
    }
}

#[godot_api]
impl INode for ClientRenet {
    fn ready(&mut self) {
        let client_id = self.client_id.clone();
        self.signals().connected_to_game().emit(client_id);
    }

    fn physics_process(&mut self, delta: f64) {
        self.client.update(Duration::from_secs_f64(delta));
        self.transport
            .update(Duration::from_secs_f64(delta), &mut self.client)
            .unwrap();

        if self.client.is_connected() {
            while let Some(text) = self.client.receive_message(DefaultChannel::ReliableOrdered) {
                let text = String::from_utf8(text.into()).unwrap();
                // godot::global::print(&[text.to_variant()]);
                godot_print!("RENETCLIENT{}: {}", self.client_id, text);
                let event: store::GameEvent = serde_json::from_str(&text).unwrap();
                match event {
                    store::GameEvent::PlayerJoined { player_id, name } => {
                        self.signals().player_joined().emit(player_id, &name)
                    }
                    store::GameEvent::PlayerDisconnected { player_id } => {
                        self.signals().player_left().emit(player_id);
                    }
                    store::GameEvent::GameBegin { goes_first } => {
                        self.signals().game_begin().emit(goes_first);
                    }
                    store::GameEvent::GameEnd { reason } => match reason {
                        store::GameEndReason::PlayerLeft { player_id: _ } => {
                            self.signals().game_end_player_left().emit();
                        }
                        store::GameEndReason::PlayerWon { winner } => {
                            self.signals().game_end_player_won().emit(winner);
                        }
                    },
                    store::GameEvent::PlaceTile { player_id, at } => {
                        self.signals().placed_tile().emit(player_id, at as i64);
                    }
                }
            }
        }

        self.transport.send_packets(&mut self.client).unwrap();
    }
}
