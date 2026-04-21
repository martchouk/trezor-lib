#!/usr/bin/env bash
set -euo pipefail

rm -rf build

OS="$(uname -s)"
ARCH="$(uname -m)"

if [[ "$OS" == "Darwin" ]]; then
  export CC=clang
  export CXX=clang++

  CMAKE_ARGS=(
    -S .
    -B build
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON
    -DCMAKE_OSX_ARCHITECTURES=arm64
    -DCMAKE_C_FLAGS_RELEASE="-O3 -DNDEBUG -mcpu=apple-m1 -flto=thin -fvisibility=hidden"
    -DCMAKE_EXE_LINKER_FLAGS="-flto=thin -Wl,-dead_strip"
    -DCMAKE_SHARED_LINKER_FLAGS="-flto=thin -Wl,-dead_strip"
  )

  BUILD_JOBS="$(sysctl -n hw.ncpu)"

elif [[ "$OS" == "Linux" ]]; then
  export CC=clang
  export CXX=clang++

  CMAKE_ARGS=(
    -S .
    -B build
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON
    -DCMAKE_C_FLAGS_RELEASE="-O3 -DNDEBUG -march=native -ffunction-sections -fdata-sections -fvisibility=hidden"
    -DCMAKE_EXE_LINKER_FLAGS="-Wl,--gc-sections"
    -DCMAKE_SHARED_LINKER_FLAGS="-Wl,--gc-sections"
  )

  BUILD_JOBS="$(nproc)"

else
  echo "Unsupported OS: $OS"
  exit 1
fi

cmake "${CMAKE_ARGS[@]}"
cmake --build build -j"$BUILD_JOBS"
