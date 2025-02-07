#!/bin/bash

set -e

install_rust_analyzer_with_rustup() {
    echo "Installing rust-analyzer using rustup..."
    rustup +stable component add rust-analyzer
    
    echo "rust-analyzer installation complete! Verify with 'rust-analyzer --version'"
}

if [[ "$(uname -s)" == "Linux" ]]; then
    if grep -qi ubuntu /etc/os-release; then
        echo "Detected Ubuntu. Proceeding with rust-analyzer installation..."
        install_rust_analyzer_with_rustup
    else
        echo "This script is designed for Ubuntu. Exiting."
        exit 1
    fi
elif [[ "$(uname -s)" == "Darwin" ]]; then
    echo "Detected macOS. Proceeding with rust-analyzer installation..."
    install_rust_analyzer_with_rustup
else
    echo "Unsupported OS. This script works only on Ubuntu and macOS."
    exit 1
fi
