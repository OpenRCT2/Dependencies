#!/bin/zsh

# exit on error
set -ex

easy_install --user pyyaml==5.4.1 

git clone -q https://github.com/Microsoft/vcpkg.git

if [ -v VCPKG_COMMIT_HASH ]; then
  echo "Using pinned vcpkg commit: ${VCPKG_COMMIT_HASH}"
  pushd vcpkg
  git checkout -q $VCPKG_COMMIT_HASH
  popd
fi

vcpkg/bootstrap-vcpkg.sh

ARM_TRIPLET="--overlay-triplets=. --triplet=arm64-osx-openrct2"
X64_TRIPLET="--overlay-triplets=. --triplet=x64-osx-openrct2"
LIBRARIES="libpng freetype openssl icu[core,tools] libzip[core] nlohmann-json openal-soft sdl2 speexdsp discord-rpc gtest libflac libogg libvorbis"
vcpkg/vcpkg install ${=X64_TRIPLET} "icu[core,tools]" || true
find /Users/runner/work/Dependencies/Dependencies/vcpkg/ -name '*icu*.dylib'
cat /Users/runner/work/Dependencies/Dependencies/vcpkg/buildtrees/icu/make-build-fix-rpath-arm64-osx-openrct2-rel-err.log
