#!/bin/zsh

easy_install --user pyyaml

git clone -q https://github.com/Microsoft/vcpkg.git

vcpkg/bootstrap-vcpkg.sh

TRIPLET="--overlay-triplets=. --triplet=x64-osx-openrct2"
LIBRARIES="duktape freetype libpng libzip[core] nlohmann-json openssl sdl2 speexdsp discord-rpc icu"
vcpkg/vcpkg install ${=TRIPLET} ${=LIBRARIES}

(
  cd vcpkg/installed/x64-osx-openrct2 &&
  zip -rXy ../../../openrct2-libs-v${version}-x64-macos-dylibs.zip * -x '*/.*'
)
