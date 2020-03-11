#!/usr/bin/env bash

# Checklist when updating libraries:
# [ ] Has libpng been updated? -> Change reference at bottom.
# [ ] Has ICU been updated? -> Change reference at bottom.

# Echo commands as they're executed
set -x

# Exit when any of the commands below fails
set -e

# First, let's get the include folder sorted
mkdir include/
cp -r /usr/local/include/freetype2/ include/freetype2/
cp -r /usr/local/include/libpng16/ include/libpng16/
cp -r /usr/local/include/SDL2/ include/SDL2/
cp -r /usr/local/include/speex/ include/speex/
cp -r /usr/local/include/unicode/ include/unicode/
cp -r /usr/local/opt/openssl@1.1/include/openssl/ include/openssl/
cp /usr/local/include/jansson*.h include/
cp /usr/local/include/zip*.h include/

# Now, copy the actual libraries themselves.
mkdir lib/
cp /usr/local/Cellar/openssl@1.1/*/lib/libcrypto.1.1.dylib lib/libcrypto.dylib
cp /usr/local/lib/libfreetype.dylib lib/libfreetype.dylib
cp /usr/local/lib/libicudata.dylib lib/libicudata.dylib
cp /usr/local/lib/libicuuc.dylib lib/libicuuc.dylib
cp /usr/local/lib/libjansson.dylib lib/libjansson.dylib
cp /usr/local/lib/libpng16.dylib lib/libpng16.dylib
cp /usr/local/lib/libSDL2.dylib lib/libSDL2.dylib
cp /usr/local/lib/libspeexdsp.dylib lib/libspeexdsp.dylib
cp /usr/local/lib/libzip.dylib lib/libzip.dylib

# Change modes to allow modification
chmod 644 lib/*.dylib

# Correct identifiers in dylibs
install_name_tool -id @rpath/libcrypto.dylib lib/libcrypto.dylib
install_name_tool -id @rpath/libfreetype.dylib lib/libfreetype.dylib
install_name_tool -id @rpath/libicudata.dylib lib/libicudata.dylib
install_name_tool -id @rpath/libicuuc.dylib lib/libicuuc.dylib
install_name_tool -id @rpath/libjansson.dylib lib/libjansson.dylib
install_name_tool -id @rpath/libpng16.dylib lib/libpng16.dylib
install_name_tool -id @rpath/libSDL2.dylib lib/libSDL2.dylib
install_name_tool -id @rpath/libspeexdsp.dylib lib/libspeexdsp.dylib
install_name_tool -id @rpath/libzip.dylib lib/libzip.dylib

# Correct additional references to dylibs
install_name_tool -change '/usr/local/opt/libpng/lib/libpng16.16.dylib' '@loader_path/libpng16.dylib' lib/libfreetype.dylib
install_name_tool -change '@loader_path/libicudata.64.dylib' '@loader_path/libicudata.dylib' lib/libicuuc.dylib

# Make a zip file of the lot.
zip -rX openrct2-libs-vXX-x64-macos-dylibs.zip include lib
