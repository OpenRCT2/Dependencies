#!/bin/zsh

git clone -q https://github.com/Microsoft/vcpkg.git
vcpkg/bootstrap-vcpkg.sh

TRIPLET=""
LIBRARIES=""
vcpkg/vcpkg install \
  --overlay-triplets=. --triplet=x64-osx-openrct2 \
  freetype libpng 'libzip[core]' nlohmann-json sdl2
