use std::collections::HashMap;

use axum::http::StatusCode;
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Deserialize)]
pub struct Pos {
    x: usize,
    y: usize,
}

#[derive(Serialize)]
pub struct Board {
    players: [char; 2],
    players_hashed: HashMap<char, Uuid>,
    current_player: usize,
    board: [[char; 3]; 3],
}

impl Board {
    pub fn new() -> Board {
        Board {
            players: ['X', 'O'],
            players_hashed: HashMap::new(),
            current_player: 0,
            board: [
                ['_','_','_',],
                ['_','_','_',],
                ['_','_','_',],
            ],
        }
    }

    pub fn add_player(&mut self, id: Uuid) {
        self.players_hashed.insert(self.players[self.current_player], id);
    }

    pub fn next_player(&mut self) {
        self.current_player = (self.current_player + 1) % self.players.len();
    }

    pub fn turn(&mut self, id: Uuid, pos: &Pos) -> StatusCode {
        if self.players_hashed[&self.players[self.current_player]] == id {
            self.board[pos.y][pos.x] = self.players[self.current_player];
            return StatusCode::OK
        }
        println!("Someone turned without permissions: {id}");
        StatusCode::FORBIDDEN
    }

    pub fn check_for_winner(&self) -> Option<char> {
        let mut winner: Option<char> = None;
        // Check Rows
        for y in 0..self.board.len() {
            if Self::eq_three(self.board[y][0], self.board[y][1], self.board[y][2]) {
                winner = Some(self.board[y][0]);
                break;
            }
        }

         // Check Columns
        for x in 0..self.board.len() {
            if Self::eq_three(self.board[0][x], self.board[1][x], self.board[2][x]) {
                winner = Some(self.board[0][x]);
                break;
            }
        }

        // Check Diagonals
        if Self::eq_three(self.board[0][0], self.board[1][1], self.board[2][2]) {
            winner = Some(self.board[0][0]);
        }
        if Self::eq_three(self.board[2][0], self.board[1][1], self.board[0][2]) {
            winner = Some(self.board[2][0]);
        }

        winner
    }

    fn eq_three<T>(a: T, b: T, c: T) -> bool
    where
        T: PartialEq
     {
        if a == b && b == c && a == c {
            return true
        }
        return false
    }
}