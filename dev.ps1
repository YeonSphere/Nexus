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
    Write-Host "Updating dependencies..."
    cargo update
    Write-Host "Updating git submodules..."
    git submodule update --init --recursive
    Write-Host "Update complete."
}

function nb-doc {
    cargo doc --open
}

function Show-NexusBrowserCommands {
    Write-Host "Nexus Browser development functions loaded. Available commands:"
    Write-Host "nb-run    : Run the Nexus Browser"
    Write-Host "nb-build  : Build the Nexus Browser in release mode"
    Write-Host "nb-test   : Run the test suite"
    Write-Host "nb-clean  : Clean the build artifacts"
    Write-Host "nb-update : Update dependencies and git submodules"
    Write-Host "nb-doc    : Generate and open documentation"
}

# Call the function to display commands when the script is loaded
Show-NexusBrowserCommands