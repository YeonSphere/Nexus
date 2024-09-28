alias nb-run="cargo run"
alias nb-build="cargo build --release"
alias nb-test="cargo test"
alias nb-check="cargo check"
alias nb-fmt="cargo fmt"
alias nb-clippy="cargo clippy"
alias nb-clean="cargo clean"
alias nb-update="cargo update && git submodule update --init --recursive && rustup update"
alias nb-doc="cargo doc --open"

nb-help() {
    echo "Nexus Browser development aliases:"
    echo "nb-run     : Run the Nexus Browser"
    echo "nb-build   : Build the Nexus Browser in release mode"
    echo "nb-test    : Run the test suite"
    echo "nb-check   : Check the project for errors"
    echo "nb-fmt     : Format the code"
    echo "nb-clippy  : Run Clippy linter"
    echo "nb-clean   : Clean the build artifacts"
    echo "nb-update  : Update dependencies, git submodules, and Rust toolchain"
    echo "nb-doc     : Generate and open documentation"
    echo "nb-help    : Show this help message"
}

# Display available commands when the file is sourced
nb-help