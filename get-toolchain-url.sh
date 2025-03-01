#!/bin/bash
# This script gets the x86_64 SafaOS's toolchain download url from the SafaOS/rust latest release for a given rust version

set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 <rust-version>"
    exit 1
fi

rust_version=$1
RELEASES_ENDPOINT="https://api.github.com/repos/SafaOS/rust/releases"

function list_releases {
    curl -sL \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "$RELEASES_ENDPOINT"
}

list_releases | jq -r ".[] | select(.tag_name | startswith(\"$rust_version\")) | .assets[] | .browser_download_url"
