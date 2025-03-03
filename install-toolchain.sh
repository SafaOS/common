#!/bin/bash
# This script installs the x86_64 SafaOS's toolchain for the current stable rustc version

set -e


function list_releases {
    RELEASES_ENDPOINT="https://api.github.com/repos/SafaOS/rust/releases"

    curl -sL \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "$RELEASES_ENDPOINT"
}

# This function gets the latest download url for the toolchain for a given rust version
function get_toolchain_urls {
    rust_version=$1
    list_releases | jq -r ".[] | select(.tag_name | startswith(\"$rust_version\")) | .assets[] | .browser_download_url"
}

function get_toolchain_url {
    if [ $# -ne 1 ]; then
        echo "get_toolchain_url: Usage $0 <rust-version>"
        exit 1
    fi

    rust_version=$1
    get_toolchain_urls $rust_version | head -n 1
}
STABLE_RUSTC_VERSION=$(rustc +stable --version | cut -d' ' -f2)
# This is a temporary solution until the .latest_stable_release.lock is created
# This file has the rustc version which the SafaOS/rust stable branch is based on as of this commit
LAST_STABLE_RUSTC_VERSION=$(cat .latest_stable_rustc_version.lock)

# May be removed in unstable commits for testing purposes
if [ -f .latest_stable_release.lock ]; then
    LATEST_STABLE_RELEASE=$(cat .latest_stable_release.lock)
else 
    LATEST_STABLE_RELEASE=$LAST_STABLE_RUSTC_VERSION
fi

if [ $STABLE_RUSTC_VERSION == $LAST_STABLE_RUSTC_VERSION ]; then 
    SPECIFIER="+stable"
else 
    SPECIFIER="+$LAST_STABLE_RUSTC_VERSION"
fi

SYSROOT=$(rustc "$SPECIFIER" --print=sysroot)

TOOLCHAIN_ROOT=$SYSROOT/lib/rustlib/x86_64-unknown-safaos
DOWNLOAD_URL=$(get_toolchain_url $LATEST_STABLE_RELEASE)

echo "Downloading toolchain from $DOWNLOAD_URL..."

# Create a temporary directory to download the toolchain
TMP_DIR=$(mktemp -d)

# Download the toolchain
curl -L $DOWNLOAD_URL -o $TMP_DIR/toolchain.tar.gz
tar -xzf $TMP_DIR/toolchain.tar.gz -C $TMP_DIR


echo "extracting toolchain to $TOOLCHAIN_ROOT"
rm -vrf $TOOLCHAIN_ROOT
mkdir -vp $TOOLCHAIN_ROOT

cp -r $TMP_DIR/x86_64-unknown-safaos-toolchain/* $TOOLCHAIN_ROOT
