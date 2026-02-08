const express = require('express')
const app = express()
const port = 3000

const game = require("./game.js")

app.get('/', (req, res) => {
    res.send('Helllo World!')
})

app.get('/currentPlayer', (req, res) => {
    let payload = {
        player: game.getCurrentPlayer()
    }
    res.send(payload);
})

app.get('/takeTurn/:posX-:posY', (req, res) => {
    let { posX, posY } = req.params;
    game.turn(posX, posY);
    res.send(game.board);
})

app.listen(port, () => {
    console.log(`Example app listening on port ${port}`)
    game.printBoard();
})
