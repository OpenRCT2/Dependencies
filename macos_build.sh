#!/bin/zsh

easy_install --user pyyaml

#git clone -q https://github.com/Microsoft/vcpkg.git
git clone -q https://github.com/LRFLEW/vcpkg.git
git -C vcpkg checkout openrct2-devel

vcpkg/bootstrap-vcpkg.sh

TRIPLET="--overlay-triplets=. --triplet=x64-osx-openrct2"
LIBRARIES="duktape freetype libpng libzip[core] nlohmann-json openssl sdl2 speexdsp"
vcpkg/vcpkg install ${=TRIPLET} ${=LIBRARIES}  

pushd vcpkg/installed/x64-osx-openrct2
zip -rXy ../../../openrct2-libs-v27-x64-macos-dylibs.zip * -x '*/.*'
popd
