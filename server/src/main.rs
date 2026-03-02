mod game;

use std::sync::Arc;

use axum::{
    Extension, Router, extract, http::StatusCode, response, routing::{get, post},
    Json,
};

use axum_macros::debug_handler;
use serde_json::{Value, json};
use serde::{Serialize, Deserialize};
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
    println!("[{}] new registered user: {}", chrono::Local::now(), &id);

    let mut state = state.lock().await;
    state.board.add_player(id);
    state.board.next_player();
    Json(json!(
        {
            "id": id
        }
    ))
}

async fn health_check(Json(data): Json<Value>) -> StatusCode {
    StatusCode::OK
}

#[debug_handler]
async fn turn(state: Extension<Arc<Mutex<State>>>, Json(pos): Json<TurnData>) -> StatusCode {
    let mut state = state.lock().await;
    state.board.turn(pos.id, &pos.pos);
    state.board.next_player();
    StatusCode::OK
}

async fn get_board(state: Extension<Arc<Mutex<State>>>) -> response::Json<Value> {
    let board = &state.lock().await.board;
    response::Json(json!({
        "board": board
    }))
}
