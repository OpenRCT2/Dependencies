#!/bin/zsh

# exit on error
set -e

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
vcpkg/vcpkg install ${=ARM_TRIPLET} ${=LIBRARIES}
vcpkg/vcpkg install ${=X64_TRIPLET} ${=LIBRARIES}

rsync -ah vcpkg/installed/x64-osx-openrct2/* universal-osx-openrct2
for lib in vcpkg/installed/x64-osx-openrct2/lib/*.dylib; do
    if [ -f "$lib" ] && [ ! -L $lib ]; then
      lib_filename=$(basename "$lib")
      lib_name=$(echo $lib_filename | cut -d'.' -f 1)
      echo "Creating universal (fat) $lib_name"
      if [ "$lib_name" = "libzip" ]; then
        # libzip embeds the full rpath in LC_RPATH
        # they will be different for arm64 and x86_64
        # this will cause issues, and is unnecessary
        install_name_tool -delete_rpath `pwd`"/vcpkg/packages/${lib_name}_x64-osx-openrct2/lib" "vcpkg/installed/x64-osx-openrct2/lib/$lib_filename"
        install_name_tool -delete_rpath `pwd`"/vcpkg/installed/x64-osx-openrct2/lib" "vcpkg/installed/x64-osx-openrct2/lib/$lib_filename"
        install_name_tool -delete_rpath `pwd`"/vcpkg/packages/${lib_name}_arm64-osx-openrct2/lib" "vcpkg/installed/arm64-osx-openrct2/lib/$lib_filename"
        install_name_tool -delete_rpath `pwd`"/vcpkg/installed/arm64-osx-openrct2/lib" "vcpkg/installed/arm64-osx-openrct2/lib/$lib_filename"
      fi
      lipo -create "vcpkg/installed/x64-osx-openrct2/lib/$lib_filename" "vcpkg/installed/arm64-osx-openrct2/lib/$lib_filename" -output "universal-osx-openrct2/lib/$lib_filename"
    fi
done

(
  cd universal-osx-openrct2 &&
  zip -rXy ../openrct2-libs-v${version}-universal-macos-dylibs.zip * -x '*/.*'
)
