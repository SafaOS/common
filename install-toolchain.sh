#!/bin/bash
# This script installs the x86_64 SafaOS's toolchain for the current stable rustc version

set -e

RUSTC_VERSION=$(rustc +stable --version | cut -d' ' -f2)
SYSROOT=$(rustc +stable --print=sysroot)

TOOLCHAIN_ROOT=$SYSROOT/lib/rustlib/x86_64-unknown-safaos
DOWNLOAD_URL=$(./get-toolchain-url.sh $RUSTC_VERSION)

echo "Downloading toolchain from $DOWNLOAD_URL"

# Create a temporary directory to download the toolchain
TMP_DIR=$(mktemp -d)

# Download the toolchain
curl -L $DOWNLOAD_URL -o $TMP_DIR/toolchain.tar.gz
tar -xzf $TMP_DIR/toolchain.tar.gz -C $TMP_DIR


echo "extracting toolchain to $TOOLCHAIN_ROOT"
rm -vrf $TOOLCHAIN_ROOT
mkdir -vp $TOOLCHAIN_ROOT

cp -r $TMP_DIR/x86_64-unknown-safaos-toolchain/* $TOOLCHAIN_ROOT
