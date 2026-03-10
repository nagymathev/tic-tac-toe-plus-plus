use std::{
    net::{SocketAddr, UdpSocket},
    thread,
    time::{Duration, Instant, SystemTime},
};

use log::{info, trace, warn};
use renet::{ConnectionConfig, DefaultChannel, RenetServer, ServerEvent};
use renet_netcode::{NETCODE_USER_DATA_BYTES, NetcodeServerTransport, ServerConfig};

use store::{GameEndReason, GameEvent, GameState};

pub const PROTOCOL_ID: u64 = 7661;

/// Utility function for extracting a players name from renet user data
fn name_from_user_data(user_data: &[u8; NETCODE_USER_DATA_BYTES]) -> String {
    let mut buffer = [0u8; 8];
    buffer.copy_from_slice(&user_data[0..8]);
    let mut len = u64::from_le_bytes(buffer) as usize;
    len = len.min(NETCODE_USER_DATA_BYTES - 8);
    let data = user_data[8..len + 8].to_vec();
    String::from_utf8(data).unwrap()
}

fn main() {
    env_logger::init();

    let server_addr: SocketAddr = "0.0.0.0:8991".parse().unwrap();

    let connection_config = ConnectionConfig::default();
    let mut server = RenetServer::new(connection_config);

    let current_time = SystemTime::now()
        .duration_since(SystemTime::UNIX_EPOCH)
        .unwrap();
    let server_config = ServerConfig {
        current_time,
        max_clients: 2,
        protocol_id: PROTOCOL_ID,
        public_addresses: vec![server_addr],
        authentication: renet_netcode::ServerAuthentication::Unsecure,
    };
    let socket = UdpSocket::bind(server_addr).unwrap();
    let mut transport = NetcodeServerTransport::new(server_config, socket).unwrap();

    trace!("Server listening on {}", server_addr);

    let mut game_state = GameState::default();
    let mut last_updated = Instant::now();
    loop {
        let now = Instant::now();
        let duration = now - last_updated;
        last_updated = now;

        server.update(duration);
        transport.update(duration, &mut server).unwrap();

        while let Some(event) = server.get_event() {
            match event {
                ServerEvent::ClientConnected { client_id } => {
                    for (player_id, player) in game_state.players.iter() {
                        let event = GameEvent::PlayerJoined {
                            player_id: *player_id,
                            name: player.name.clone(),
                        };
                        server.send_message(
                            client_id,
                            DefaultChannel::ReliableOrdered,
                            serde_json::to_string(&event).unwrap(),
                        );
                    }

                    let user_data = transport.user_data(client_id).unwrap();
                    let username = name_from_user_data(&user_data);
                    let event = GameEvent::PlayerJoined {
                        player_id: client_id,
                        name: username,
                    };
                    game_state.dispatch(&event);

                    server.broadcast_message(
                        DefaultChannel::ReliableOrdered,
                        serde_json::to_string(&event).unwrap(),
                    );
                    info!("Client {} connected!", client_id);

                    if game_state.players.len() == 2 {
                        let event = GameEvent::GameBegin {
                            goes_first: client_id,
                        };
                        game_state.dispatch(&event);
                        server.broadcast_message(
                            DefaultChannel::ReliableOrdered,
                            serde_json::to_string(&event).unwrap(),
                        );
                        trace!("The game has begun!");
                    }
                }
                ServerEvent::ClientDisconnected { client_id, reason } => {
                    let event = GameEvent::PlayerDisconnected {
                        player_id: client_id,
                    };
                    game_state.dispatch(&event);
                    server.broadcast_message(
                        DefaultChannel::ReliableOrdered,
                        serde_json::to_string(&event).unwrap(),
                    );
                    info!("Client {} disconnected.", client_id);

                    let event = GameEvent::GameEnd {
                        reason: GameEndReason::PlayerLeft {
                            player_id: client_id,
                        },
                    };
                    game_state.dispatch(&event);
                    server.broadcast_message(
                        DefaultChannel::ReliableOrdered,
                        serde_json::to_string(&event).unwrap(),
                    );
                }
            }
        }

        for client_id in server.clients_id() {
            while let Some(message) =
                server.receive_message(client_id, DefaultChannel::ReliableOrdered)
            {
                let message = String::from_utf8(message.into()).unwrap();
                let event: GameEvent = serde_json::from_str(&message).unwrap();
                match game_state.dispatch(&event) {
                    Ok(_) => {
                        trace!("Player {} sent: \n\t{:#?}", client_id, event);
                        server.broadcast_message(
                            DefaultChannel::ReliableOrdered,
                            serde_json::to_string(&event).unwrap(),
                        );

                        if let Some(winner) = game_state.determine_winner() {
                            let event = GameEvent::GameEnd {
                                reason: GameEndReason::PlayerWon { winner },
                            };
                            server.broadcast_message(
                                DefaultChannel::ReliableOrdered,
                                serde_json::to_string(&event).unwrap(),
                            );
                        }
                    }
                    Err(_) => {
                        warn!("Player {} sent invalid event: \n\t{:#?}", client_id, event);
                    }
                }
            }
        }

        transport.send_packets(&mut server);
        thread::sleep(Duration::from_millis(50));
    }
}
