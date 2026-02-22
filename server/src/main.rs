mod game;

use std::sync::Arc;

use axum::{
    Extension, Router, response, extract,
    routing::{get, post},
};

use serde_json::{Value, json};
use tokio::sync::Mutex;

struct PostData {
    id: usize,
    pos: game::Pos,
}

struct State {
    player_count: usize,
}

impl State {
    fn new() -> Self {
        State { player_count: 0 }
    }
}

#[tokio::main]
async fn main() {
    let state = Arc::new(Mutex::new(State::new()));

    let app = Router::new()
        .route("/", get(|| async { "Hello world!" }))
        .route("/register", get(register))
        .route("/turn", post(turn))
        .layer(Extension(state));

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

async fn register(state: Extension<Arc<Mutex<State>>>) -> response::Json<Value> {
    let mut state = state.lock().await;
    state.player_count += 1;
    let id = state.player_count;
    response::Json(json!({
        "id": id
    }))
}
async fn turn(pos: extract::Json<PostData>) {}
