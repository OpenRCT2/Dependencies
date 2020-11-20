#!/bin/zsh

brew install libyaml
sudo easy_install pyyaml

git clone -q https://github.com/Microsoft/vcpkg.git
vcpkg/bootstrap-vcpkg.sh

TRIPLET="--overlay-triplets=. --triplet=x64-osx-openrct2"
LIBRARIES="duktape freetype libpng libzip[core] nlohmann-json sdl2"
vcpkg/vcpkg install ${=TRIPLET} ${=LIBRARIES}  
