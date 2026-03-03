use std::collections::HashMap;

use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Serialize, Debug)]
pub enum PlayerType {
    PlayerX,
    PlayerO,
    Spectator,
}

// There has to be a better way.
pub fn make_player_type(e: u8) -> PlayerType {
    match e {
        0 => PlayerType::PlayerX,
        1 => PlayerType::PlayerO,
        _ => PlayerType::Spectator,
    }
}

#[derive(Deserialize)]
pub struct Pos {
    x: usize,
    y: usize,
}

#[derive(Serialize)]
pub struct Board {
    players: [char; 2],
    players_hashed: HashMap<Uuid, char>,
    current_player: usize,
    board: [[char; 3]; 3],
}

impl Board {
    pub fn new() -> Board {
        Board {
            players: ['X', 'O'],
            players_hashed: HashMap::new(),
            current_player: 0,
            board: [['_', '_', '_'], ['_', '_', '_'], ['_', '_', '_']],
        }
    }

    pub fn add_player(&mut self, id: Uuid) -> PlayerType {
        let len = self.players_hashed.len();
        if len < 2 {
            self.players_hashed.insert(id, self.players[len]);
            let player_type = make_player_type(len as u8);
            return player_type;
        }
        println!("Player capacity reached! Player added as a Spectator!");
        return PlayerType::Spectator;
    }

    pub fn next_player(&mut self) {
        self.current_player = (self.current_player + 1) % self.players.len();
    }

    /// Returns wether it was a valid turn or not.
    pub fn turn(&mut self, id: Uuid, pos: &Pos) -> bool {
        if self.players_hashed.contains_key(&id)
            && self.players_hashed[&id] == self.players[self.current_player]
        {
            if self.board[pos.y][pos.x] != '_' {
                return false;
            }

            self.board[pos.y][pos.x] = self.players[self.current_player];

            // TODO: Return something instead to notify the client.
            if let Some(winner) = self.check_for_winner() {
                println!("Winner is: {winner}!");
            }
            self.next_player();
            return true;
        }
        println!("Someone turned without permissions: {id}");
        return false;
    }

    pub fn check_for_winner(&self) -> Option<char> {
        let mut winner: Option<char> = None;
        // Check Rows
        for y in 0..self.board.len() {
            if self.board[y][0] != '_'
                && Self::eq_three(self.board[y][0], self.board[y][1], self.board[y][2])
            {
                winner = Some(self.board[y][0]);
                break;
            }
        }

        // Check Columns
        for x in 0..self.board.len() {
            if self.board[0][x] != '_'
                && Self::eq_three(self.board[0][x], self.board[1][x], self.board[2][x])
            {
                winner = Some(self.board[0][x]);
                break;
            }
        }

        // Check Diagonals
        if self.board[0][0] != '_'
            && Self::eq_three(self.board[0][0], self.board[1][1], self.board[2][2])
        {
            winner = Some(self.board[0][0]);
        }
        if self.board[2][0] != '_'
            && Self::eq_three(self.board[2][0], self.board[1][1], self.board[0][2])
        {
            winner = Some(self.board[2][0]);
        }

        winner
    }

    fn eq_three<T>(a: T, b: T, c: T) -> bool
    where
        T: PartialEq,
    {
        if a == b && b == c && a == c {
            return true;
        }
        return false;
    }
}
