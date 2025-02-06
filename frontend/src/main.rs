use yew::prelude::*;
use reqwest::Client;
use serde::Deserialize;
use log::error;

struct App {
    products: Vec<Product>,
    client: Client,
    error_message: Option<String>,
    fetching: bool,
}

#[derive(Deserialize, Clone, PartialEq, Debug)]
struct Product {
    id: i32,
    name: String,
    description: String,
    price: f64,
}

#[derive(Clone, PartialEq, Debug)]
enum Msg {
    FetchProducts,
    FetchProductsSuccess(Vec<Product>),
    FetchProductsFailure(String),
    ToggleFetching(bool),
}

impl Component for App {
    type Message = Msg;
    type Properties = ();

    fn create(_ctx: &Context<Self>) -> Self {
        App {
            products: Vec::new(),
            client: Client::new(),
            error_message: None,
            fetching: false,
        }
    }

    fn update(&mut self, _ctx: &Context<Self>, msg: Self::Message) -> bool {
        match msg {
            Msg::FetchProducts => {
                self.fetching = true;
                _ctx.link().send_message(Msg::ToggleFetching(true));

                let request = self.client.get("http://localhost:4000/api/products");

                let callback = _ctx.link().callback(move |response: Result<reqwest::Response, reqwest::Error>| {
                    match response {
                        Ok(resp) => {
                            if resp.status().is_success() {
                                let future = async move {
                                    match resp.json::<Vec<Product>>().await {
                                        Ok(products) => Ok(Msg::FetchProductsSuccess(products)),
                                        Err(err) => Err(Msg::FetchProductsFailure(err.to_string())),
                                    }
                                };

                                spawn_local(async move {
                                    let msg_result = future.await;
                                    match msg_result {
                                        Ok(msg) => _ctx.link().send_message(msg),
                                        Err(err) => _ctx.link().send_message(Msg::FetchProductsFailure(err.to_string())),
                                    }
                                    _ctx.link().send_message(Msg::ToggleFetching(false));
                                });

                                true
                            } else {
                                _ctx.link().send_message(Msg::FetchProductsFailure(format!("HTTP Error: {}", resp.status())));
                                _ctx.link().send_message(Msg::ToggleFetching(false));
                                true
                            }
                        }
                        Err(err) => {
                            _ctx.link().send_message(Msg::FetchProductsFailure(err.to_string()));
                            _ctx.link().send_message(Msg::ToggleFetching(false));
                            true
                        }
                    }
                });

                let future = request.send().map(move |response| {
                    callback.emit(response)
                });

                spawn_local(async move {
                    future.await;
                });

                true
            }

            Msg::FetchProductsSuccess(products) => {
                self.products = products;
                self.error_message = None;
                self.fetching = false;
                true
            }

            Msg::FetchProductsFailure(err) => {
                error!("Failed to fetch products: {}", err);
                self.error_message = Some(err);
                self.fetching = false;
                true
            }

            Msg::ToggleFetching(is_fetching) => {
                self.fetching = is_fetching;
                true
            }
        }
    }

    fn view(&self, _ctx: &Context<Self>) -> Html {
        html! {
            <>
                <link rel="stylesheet" href="styles/styles.css" />
                <div class="app-container">
                    <header class="header">
                        <h1>{ "Nexus Browser" }</h1>
                        <nav>
                            <ul>
                                <li>{ "Home" }</li>
                                <li>{ "Bookmarks" }</li>
                                <li>{ "History" }</li>
                            </ul>
                        </nav>
                    </header>
                    <div class="main-content">
                        <aside class="sidebar">
                            <h2>{ "Sidebar" }</h2>
                            <ul>
                                <li>{ "Bookmark 1" }</li>
                                <li>{ "Bookmark 2" }</li>
                            </ul>
                        </aside>
                        <main class="content-area">
                            <h2>{ "Welcome to Nexus!" }</h2>
                            <button onclick={_ctx.link().callback(|_| Msg::FetchProducts)} disabled={self.fetching}>
                                { if self.fetching { "Fetching..." } else { "Fetch Products" } }
                            </button>
                            {
                                if let Some(err) = &self.error_message {
                                    html! { <p class="error">{ err }</p> }
                                } else {
                                    html! {}
                                }
                            }
                            <ul>
                                { self.products.iter().map(|product| {
                                    html! { <li>{ format!("{} - ${}", product.name, product.price) }</li> }
                                }).collect::<Html>() }
                            </ul>
                        </main>
                    </div>
                    <footer class="footer">
                        <p>{ "Footer content here" }</p>
                    </footer>
                </div>
            </>
        }
    }
}

fn main() {
    wasm_logger::init(wasm_logger::Config::new(log::Level::Info));
    yew::Renderer::<App>::new().render();
}