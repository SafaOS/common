#!/bin/bash
# This script echoes the rustc toolchain required based on `.latest_stable_rustc_version.lock`
CURRENT_RUSTC_VERSION=$(rustc --version | cut -d' ' -f2)
STABLE_RUSTC_VERSION=$(rustc +stable --version | cut -d' ' -f2)
LAST_STABLE_RUSTC_VERSION=$(cat .latest_stable_rustc_version.lock)

if [ $CURRENT_RUSTC_VERSION == $LAST_STABLE_RUSTC_VERSION ]; then
    SPECIFIER=""
elif [ $STABLE_RUSTC_VERSION == $LAST_STABLE_RUSTC_VERSION ]; then 
    SPECIFIER="+stable"
else 
    SPECIFIER="+$LAST_STABLE_RUSTC_VERSION"
fi

echo $SPECIFIER
