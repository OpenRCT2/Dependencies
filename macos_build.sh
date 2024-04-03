#!/bin/zsh

# exit on error
set -e

rsync -ah x64-osx-openrct2/* universal-osx-openrct2
for lib in x64-osx-openrct2/lib/*.dylib; do
    if [ -f "$lib" ] && [ ! -L $lib ]; then
      lib_filename=$(basename "$lib")
      lib_name=$(echo $lib_filename | cut -d'.' -f 1)
      echo "Creating universal (fat) $lib_name"
      if [ "$lib_name" = "libzip" ]; then
        # libzip embeds the full rpath in LC_RPATH
        # they will be different for arm64 and x86_64
        # this will cause issues, and is unnecessary
        install_name_tool -delete_rpath `pwd`"/vcpkg/packages/${lib_name}_x64-osx-openrct2/lib" "x64-osx-openrct2/lib/$lib_filename"
        install_name_tool -delete_rpath `pwd`"/vcpkg/installed/x64-osx-openrct2/x64-osx-openrct2/lib" "x64-osx-openrct2/lib/$lib_filename"
        install_name_tool -delete_rpath `pwd`"/vcpkg/packages/${lib_name}_arm64-osx-openrct2/lib" "arm64-osx-openrct2/lib/$lib_filename"
        install_name_tool -delete_rpath `pwd`"/vcpkg/installed/arm64-osx-openrct2/arm64-osx-openrct2/lib" "arm64-osx-openrct2/lib/$lib_filename"
      fi
      lipo -create "x64-osx-openrct2/lib/$lib_filename" "arm64-osx-openrct2/lib/$lib_filename" -output "universal-osx-openrct2/lib/$lib_filename"
    fi
done

(
  cd universal-osx-openrct2 &&
  zip -rXy ../openrct2-libs-v${version}-universal-macos-dylibs.zip * -x '*/.*'
)
