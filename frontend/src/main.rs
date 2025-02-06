use yew::prelude::*;
use reqwest::Client;
use serde::Deserialize;
use log::error;
use wasm_bindgen_futures::spawn_local;
use web_sys::{Document, Element};

struct App {
    products: Vec<Product>,
    client: Client,
    error_message: Option<String>,
    fetching: bool,
}

#[derive(Deserialize, Clone)]
struct Product {
    id: i32,
    name: String,
    description: String,
    price: f64,
}

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

                request.send().map(move |response| {
                    callback.emit(response)
                }).await;

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
        let onclick = _ctx.link().callback(|_| Msg::FetchProducts);

        html! {
            <div>
                <button onclick={onclick} disabled={self.fetching}>
                    { if self.fetching { "Fetching..." } else { "Fetch products" } }
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
                        html! { <li>{ format!("{} - {}", product.name, product.price) }</li> }
                    }).collect::<Html>() }
                </ul>
            </div>
        }
    }
}

fn main() {
    wasm_logger::init(wasm_logger::Config::new(log::Level::Info));
    let document = web_sys::window().unwrap().document().unwrap();
    let root = document.query_selector("#root").unwrap().dyn_into::<Element>().unwrap();
    yew::Renderer::<App>::with_root(root).render();
}