pub struct Pos {
    x: usize,
    y: usize,
}

struct Board {
    players: [char; 2],
    current_player: usize,
    board: [[char; 3]; 3],
}

impl Board {
    pub fn new() -> Board {
        Board {
            players: ['X', 'O'],
            current_player: 0,
            board: [
                ['_','_','_',],
                ['_','_','_',],
                ['_','_','_',],
            ],
        }
    }

    fn next_player(mut self: Self) {
        self.current_player = (self.current_player + 1) % self.players.len();
    }

    fn turn(mut self: Self, pos: Pos) {
        self.board[pos.y][pos.x] = self.players[self.current_player];
    }
}