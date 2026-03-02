mod game;

use std::sync::Arc;

use axum::{
    Extension, Json, Router, extract,
    http::StatusCode,
    response,
    routing::{get, post},
};

use axum_macros::debug_handler;
use serde::{Deserialize, Serialize};
use serde_json::{Value, json};
use tokio::sync::Mutex;
use uuid::Uuid;

#[derive(Deserialize)]
struct TurnData {
    id: Uuid,
    pos: game::Pos,
}

struct State {
    board: game::Board,
}

impl State {
    fn new() -> Self {
        State {
            board: game::Board::new(),
        }
    }
}

#[tokio::main]
async fn main() {
    let state = Arc::new(Mutex::new(State::new()));

    let app = Router::new()
        .route("/", get(|| async { "Hello world!" }))
        .route("/register", get(register))
        .route("/turn", post(turn))
        .route("/board", get(get_board))
        .layer(Extension(state));

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

async fn register(state: Extension<Arc<Mutex<State>>>) -> Json<Value> {
    let id = Uuid::new_v4();

    let mut state = state.lock().await;
    let player_type = state.board.add_player(id);
    println!(
        "[{}] new registered user: {}, with PlayerType: {:#?}",
        chrono::Local::now(),
        &id,
        player_type
    );
    Json(json!(
        {
            "id": id,
            "player_type": player_type,
        }
    ))
}

async fn health_check(Json(data): Json<Value>) -> StatusCode {
    StatusCode::OK
}

#[debug_handler]
async fn turn(state: Extension<Arc<Mutex<State>>>, Json(data): Json<TurnData>) -> StatusCode {
    let mut state = state.lock().await;
    state.board.turn(data.id, &data.pos);
    StatusCode::OK
}

async fn get_board(state: Extension<Arc<Mutex<State>>>) -> response::Json<Value> {
    let board = &state.lock().await.board;
    response::Json(json!({
        "board": board
    }))
}
