#!/usr/bin/env bash

function is_platform_windows() {
  case "$OSTYPE" in
    cygwin*|msys*|win32*) return 0 ;;
    *) return 1 ;;
  esac
}

function is_platform_mac() {
    [[ "$OSTYPE" == "darwin"* ]]
}

function is_platform_linux() {
    [[ "$OSTYPE" == "linux-gnu"* ]]
}

function cpu_count() {
    if is_platform_mac; then
        sysctl -n hw.ncpu
    elif is_platform_linux; then
        nproc
    elif is_platform_windows; then
        # On Windows, use the NUMBER_OF_PROCESSORS environment variable
        echo "$NUMBER_OF_PROCESSORS"
    else
        echo 1
    fi
}
