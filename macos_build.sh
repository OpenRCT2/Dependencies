#!/bin/zsh

easy_install --user pyyaml

git clone -q https://github.com/Microsoft/vcpkg.git


if [ -z "$VCPKG_COMMIT_HASH" ]; then
  echo "Using pinned vcpkg commit: ${VCPKG_COMMIT_HASH}"
  pushd vcpkg
  git checkout -q $VCPKG_COMMIT_HASH
  popd
fi

vcpkg/bootstrap-vcpkg.sh

TRIPLET="--overlay-triplets=. --triplet=x64-osx-openrct2"
LIBRARIES="duktape freetype libpng libzip[core] nlohmann-json openssl sdl2 speexdsp discord-rpc icu"
vcpkg/vcpkg install ${=TRIPLET} ${=LIBRARIES}

(
  cd vcpkg/installed/x64-osx-openrct2 &&
  zip -rXy ../../../openrct2-libs-v${version}-x64-macos-dylibs.zip * -x '*/.*'
)
