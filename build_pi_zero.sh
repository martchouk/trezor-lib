#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

OS="$(uname -s)"
ARCH="$(uname -m)"

if [[ "$OS" != "Linux" || "$ARCH" != "armv6l" ]]; then
  echo "This script is intended for Raspberry Pi Zero (Linux armv6l)."
  echo "Detected: OS=$OS ARCH=$ARCH"
  exit 1
fi

rm -rf build

# Use GNU toolchain on Pi Zero for compatibility with the final link step.
export CC=gcc
export CXX=g++

CFLAGS_RELEASE="-O3 -DNDEBUG -mcpu=arm1176jzf-s -fvisibility=hidden -ffunction-sections -fdata-sections"
LDFLAGS_COMMON="-Wl,--gc-sections"

cmake -S . -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_FLAGS_RELEASE="${CFLAGS_RELEASE}" \
  -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS_COMMON}" \
  -DCMAKE_SHARED_LINKER_FLAGS="${LDFLAGS_COMMON}" \
  -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF

cmake --build build -j1

test -f build/libTrezorCrypto.a
file build/libTrezorCrypto.a
echo "OK: built build/libTrezorCrypto.a for Raspberry Pi Zero"
