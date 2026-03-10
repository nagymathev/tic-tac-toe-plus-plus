use serde::{Deserialize, Serialize};
use std::collections::HashMap;

pub type PlayerId = u64;

#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
pub enum Tile {
    Empty,
    Tic,
    Tac,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Player {
    pub name: String,
    pub piece: Tile,
}

#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
pub enum Stage {
    PreGame,
    InGame,
    Ended,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct GameState {
    pub stage: Stage,
    pub board: [Tile; 9],
    pub active_player_id: PlayerId,
    pub players: HashMap<PlayerId, Player>,
    history: Vec<GameEvent>,
}

impl Default for GameState {
    fn default() -> Self {
        Self {
            stage: Stage::PreGame,
            board: [Tile::Empty; 9],
            active_player_id: 0,
            players: HashMap::new(),
            history: Vec::new(),
        }
    }
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum GameEndReason {
    PlayerLeft { player_id: PlayerId },
    PlayerWon { winner: PlayerId },
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum GameEvent {
    PlayerJoined { player_id: PlayerId, name: String },
    PlayerDisconnected { player_id: PlayerId },
    GameBegin { goes_first: PlayerId },
    GameEnd { reason: GameEndReason },
    PlaceTile { player_id: PlayerId, at: usize },
}

impl GameState {
    pub fn consume(&mut self, event: &GameEvent) {
        use GameEvent::*;

        match event {
            PlayerJoined { player_id, name } => {
                self.players.insert(
                    *player_id,
                    Player {
                        name: name.to_string(),
                        piece: if self.players.len() > 0 {
                            Tile::Tac
                        } else {
                            Tile::Tic
                        },
                    },
                );
            }
            PlayerDisconnected { player_id } => {
                self.players.remove(player_id);
            }
            GameBegin { goes_first } => {
                self.active_player_id = *goes_first;
                self.stage = Stage::InGame;
            }
            GameEnd { reason: _ } => {
                self.stage = Stage::Ended;
            }
            PlaceTile { player_id, at } => {
                self.board[*at] = self.players.get(player_id).unwrap().piece;
                self.active_player_id = self
                    .players
                    .keys()
                    .find(|id| *id != player_id)
                    .unwrap()
                    .clone();
            }
        }

        self.history.push(event.clone());
    }

    pub fn validate(&self, event: &GameEvent) -> bool {
        use GameEvent::*;

        match event {
            PlayerJoined { player_id, name: _ } => {
                if self.players.contains_key(player_id) {
                    return false;
                }
            }
            PlayerDisconnected { player_id } => {
                if !self.players.contains_key(player_id) {
                    return false;
                }
            }
            GameBegin { goes_first } => {
                if !self.players.contains_key(goes_first) {
                    return false;
                }

                if self.stage != Stage::PreGame {
                    return false;
                }
            }
            GameEnd { reason } => match reason {
                GameEndReason::PlayerWon { winner: _ } => {
                    if self.stage != Stage::InGame {
                        return false;
                    }
                }
                _ => {}
            },
            PlaceTile { player_id, at } => {
                if !self.players.contains_key(player_id) {
                    return false;
                }

                if self.active_player_id != *player_id {
                    return false;
                }

                if *at > 8 {
                    return false;
                }

                if self.board[*at] != Tile::Empty {
                    return false;
                }
            }
        }

        return true;
    }

    pub fn dispatch(&mut self, event: &GameEvent) -> Result<(), ()> {
        if !self.validate(event) {
            return Err(());
        }

        self.consume(event);
        Ok(())
    }

    pub fn determine_winner(&self) -> Option<PlayerId> {
        let row1: [usize; 3] = [0, 1, 2];
        let row2: [usize; 3] = [3, 4, 5];
        let row3: [usize; 3] = [6, 7, 8];
        let col1: [usize; 3] = [0, 3, 6];
        let col2: [usize; 3] = [1, 4, 7];
        let col3: [usize; 3] = [2, 5, 8];
        let diag1: [usize; 3] = [0, 4, 8];
        let diag2: [usize; 3] = [6, 4, 2];

        for arr in [row1, row2, row3, col1, col2, col3, diag1, diag2] {
            let tiles = [self.board[arr[0]], self.board[arr[1]], self.board[arr[2]]];
            let all_the_same = tiles
                .get(0)
                .map(|first| tiles.iter().all(|x| x == first))
                .unwrap_or(true);

            if all_the_same {
                if let Some((winner, _)) = self
                    .players
                    .iter()
                    .find(|(_, player)| player.piece == self.board[arr[0]])
                {
                    return Some(*winner);
                }
            }
        }

        None
    }
}
