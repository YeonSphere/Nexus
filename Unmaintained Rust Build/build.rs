use lib_flutter_rust_bridge_codegen::codegen;
use std::env;
use std::path::PathBuf;

fn main() {
    let out_dir = PathBuf::from(env::var("OUT_DIR").unwrap());
    let bridge_dir = out_dir.join("bridge");

    codegen::Config::from_config_file("flutter_rust_bridge.yaml")
        .unwrap()
        .output_dir(bridge_dir)
        .generate()
        .unwrap();

    println!("cargo:rerun-if-changed=src/");
    println!("cargo:rerun-if-changed=flutter_rust_bridge.yaml");
    println!("cargo:rerun-if-changed=src/ui/");
}
