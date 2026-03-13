use std::sync::Arc;

use axum::{
    Json, Router, extract,
    http::StatusCode,
    routing::{get, post},
};
use serde::{Deserialize, Serialize};
use tokio::sync::{Mutex, RwLock};

#[tokio::main]
async fn main() {
    // initialize tracing
    tracing_subscriber::fmt::init();

    // build our application with a route
    let app = Router::new()
        // `GET /` goes to `root`
        .route("/", get(root))
        // `POST /users` goes to `create_user`
        .route("/create_host", post(create_host))
        .route("/create_client", post(create_client))
        .route("/get_host", get(get_host))
        .route("/get_client", get(get_client))
        .with_state(IpDbState::default());

    // run our app with hyper, listening globally on port 3000
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

type IpDbState = Arc<Mutex<State>>;

#[derive(Default)]
struct State {
    hosts: Vec<Host>,
    clients: Vec<Host>,
}

// basic handler that responds with a static string
async fn root() -> &'static str {
    "Hello, World!"
}

async fn create_host(
    extract::State(ip_state): extract::State<IpDbState>,
    Json(payload): Json<Host>,
) -> StatusCode {
    let hosts: &mut Vec<Host> = &mut ip_state.lock().await.hosts;

    hosts.push(payload);

    StatusCode::CREATED
}

async fn create_client(
    extract::State(ip_state): extract::State<IpDbState>,
    Json(payload): Json<Host>,
) -> StatusCode {
    let clients: &mut Vec<Host> = &mut ip_state.lock().await.clients;

    clients.push(payload);

    StatusCode::CREATED
}

async fn get_host(
    extract::State(ip_state): extract::State<IpDbState>,
) -> (StatusCode, Json<Option<Host>>) {
    let hosts: &mut Vec<Host> = &mut ip_state.lock().await.hosts;

    if let Some(host) = hosts.pop() {
        return (StatusCode::CREATED, Json(Some(host)));
    };
    return (StatusCode::CREATED, Json(None));
}

async fn get_client(
    extract::State(ip_state): extract::State<IpDbState>,
) -> (StatusCode, Json<Option<Host>>) {
    let clients: &mut Vec<Host> = &mut ip_state.lock().await.clients;

    if let Some(client) = clients.pop() {
        return (StatusCode::CREATED, Json(Some(client)));
    };
    return (StatusCode::CREATED, Json(None));
}

#[derive(Deserialize, Serialize)]
struct Host {
    public_ip: String,
    public_port: String,
    private_ip: String,
    private_port: String,
}
