function nb-run {
    cargo run
}

function nb-build {
    cargo build --release
}

function nb-test {
    cargo test
}

function nb-clean {
    cargo clean
}

function nb-update {
    cargo update
}

function nb-doc {
    cargo doc --open
}

Write-Host "Nexus Browser development functions loaded. Available commands:"
Write-Host "nb-run    : Run the Nexus Browser"
Write-Host "nb-build  : Build the Nexus Browser in release mode"
Write-Host "nb-test   : Run the test suite"
Write-Host "nb-clean  : Clean the build artifacts"
Write-Host "nb-update : Update dependencies"
Write-Host "nb-doc    : Generate and open documentation"