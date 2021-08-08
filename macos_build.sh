#!/bin/zsh

easy_install --user pyyaml

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
LIBRARIES="libpng freetype openssl icu duktape libzip[core] nlohmann-json sdl2 speexdsp discord-rpc"
vcpkg/vcpkg install ${=ARM_TRIPLET} ${=LIBRARIES}
vcpkg/vcpkg install ${=X64_TRIPLET} ${=LIBRARIES}

rsync -ah vcpkg/installed/x64-osx-openrct2/* universal-osx-openrct2
for lib in vcpkg/installed/x64-osx-openrct2/lib/*.dylib; do
    if [ -f "$lib" ] && [ ! -L $lib ]; then
    libname=$(basename "$lib")
      echo "Creating universal (fat) $libname"
      lipo -create "vcpkg/installed/x64-osx-openrct2/lib/$libname" "vcpkg/installed/arm64-osx-openrct2/lib/$libname" -output "universal-osx-openrct2/lib/$libname"
    fi
done

(
  cd universal-osx-openrct2 &&
  zip -rXy ../openrct2-libs-v${version}-universal-macos-dylibs.zip * -x '*/.*'
)
