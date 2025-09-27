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
