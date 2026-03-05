# TicTacToe++

#### TODO
- Switch to TCP sockets.
- Matchmaking service to punch through firewall.
- Autostart a server instance when running client. (Or probably more like an option to start or connect)
- Implement TTL for connections.
- Finish the main menu.

#### Networking
I think trying to implement a deterministic lock-step type of networking for this kind of game would work perfect.
This game ins't really a fast paced game. Latency is not a big consideration. More like need to make sure actions are reflected on all clients.
Need to think about server hosting. Having dedicated servers is really expensive, so better use a not-so server based architecture.
    - I think it will be like someone can start a server locally (and advertising itself on the matchmaking service) and the other player will be connected through a matchmaking system.

For more TODOs turn to:
```
rg -in --pretty --trim "TODO" *
```
