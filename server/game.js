let board = [
    ['-', '-', '-'],
    ['-', '-', '-'],
    ['-', '-', '-'],
];

/**
 * Players array, the first element is the empty.
 */
let emptyCell = '-';
let players = ['X', 'O'];
let consecutiveNeeded = 3;
let currentPlayer = 0;

function printBoard() {
    for (let y = 0; y < board.length; y++) {
        for (let x = 0; x < board.length; x++) {
            process.stdout.write(`${board[y][x]}`);
        }
        process.stdout.write("\n");
    }
}

/**
 * Performs a turn on the board.
 *
 * @param {int} posX - Position X
 * @param {int} posY - Position Y
 * @returns {bool} validMove - returns true if valid positions, false if invalid positions.
 *
 */
function turn(posX, posY) {
    if (posX >= board.length) {
        console.log("position x out of range...");
        return;
    }
    if (posY >= board.length) {
        console.log("position y out of range...");
        return;
    }
    board[posY][posX] = players[currentPlayer];
    console.log(checkWinner());
    currentPlayer = (currentPlayer + 1) % 2;
}

function equals3(a, b, c) {
    return (a == b & b == c && a != emptyCell);
}

function checkWinner() {
    let winner = null;

    // Rows
    for (let i = 0; i < board.length; i++) {
        if (equals3(board[i][0], board[i][1], board[i][2])) {
            winner = board[i][0];
        }
    }

    // Columns
    for (let i = 0; i < board.length; i++) {
        if (equals3(board[0][i], board[1][i], board[2][i])) {
            winner = board[0][i];
        }
    }

    // Diagonal
    if (equals3(board[0][0], board[1][1], board[2][2])) {
        winner = board[0][0];
    }
    if (equals3(board[2][0], board[1][1], board[0][2])) {
        winner = board[2][0];
    }

    let emptyCells = false;
    for (let i = 0; i < board.length; i++) {
        for (let j = 0; j < board.length; j++) {
            if (board[i][j] == emptyCell) {
                emptyCells = true;
                break;
            }
        }
    }

    // TIE
    if (!emptyCells) {
        winner = "T"
    }

    return winner;

}

function getCurrentPlayer() {
    return players[currentPlayer];
}

module.exports = { printBoard, turn, getCurrentPlayer, board }
