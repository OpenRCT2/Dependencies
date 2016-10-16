#!/bin/bash

BIT32=false
if [ "$1" == "32bit" ]; then BIT32=true; fi

# Handle 32-vs-64 bit differences here to reduce redundancy
if $BIT32; then BITCFLAGS="-m32"; else BITCFLAGS="-m64"; fi
if $BIT32; then OPENSSLPLATFORM="darwin-i386-cc"; else OPENSSLPLATFORM="darwin64-x86_64-cc"; fi

# Reduce redundancy by putting the shared configuration options here
PREFIXDIR="$(pwd)/build"
CONFIGUREOPTS=" --prefix=\"$PREFIXDIR\" --enable-shared=yes --enable-static=no CFLAGS=\"$BITCFLAGS -mmacosx-version-min=10.7\" LDFLAGS=\"$BITCFLAGS -mmacosx-version-min=10.7\" PKG_CONFIG_PATH=\"$PREFIXDIR/lib/pkgconfig\" "
COMMONMAKE=" make; make install; make clean; "

# Build Libraries
cd src
  
  echo -e "\n\nBuilding libpng ...\n\n"
  cd libpng
    ./autogen.sh
    eval ./configure $CONFIGUREOPTS --disable-unversioned-links
    eval $COMMONMAKE
    install_name_tool -id @rpath/libpng.dylib "$PREFIXDIR/lib/libpng16.dylib"
  cd ..
  
  echo -e "\n\nBuilding Freetype2 ...\n\n"
  cd freetype2
    ./autogen.sh
    eval ./configure $CONFIGUREOPTS --with-png=yes --with-harfbuzz=no
    eval $COMMONMAKE
    install_name_tool -id @rpath/libfreetype.dylib "$PREFIXDIR/lib/libfreetype.dylib"
  cd ..
  
  echo -e "\n\nBuilding jansson ...\n\n"
  cd jansson
    autoreconf -i
    eval ./configure $CONFIGUREOPTS
    eval $COMMONMAKE
    install_name_tool -id @rpath/libjansson.dylib "$PREFIXDIR/lib/libjansson.dylib"
  cd ..
  
  echo -e "\n\nBuilding speexdsp ...\n\n"
  cd speexdsp
    ./autogen.sh
    eval ./configure $CONFIGUREOPTS
    eval $COMMONMAKE
    install_name_tool -id @rpath/libspeexdsp.dylib "$PREFIXDIR/lib/libspeexdsp.dylib"
  cd ..
  
  echo -e "\n\nBuilding SDL2 ...\n\n"
  cd sdl
    ./autogen.sh
    # No-Static builds fail on install due to a bug
    eval ./configure $CONFIGUREOPTS --enable-static=yes --disable-video-x11
    eval $COMMONMAKE
    install_name_tool -id @rpath/libSDL2.dylib "$PREFIXDIR/lib/libSDL2.dylib"
  cd ..
  
  echo -e "\n\nBuilding SDL2_TTF ...\n\n"
  cd sdl_ttf
    ./autogen.sh
    eval ./configure $CONFIGUREOPTS "--with-freetype-prefix=$PREFIXDIR" "--with-sdl-prefix=$PREFIXDIR"
    eval $COMMONMAKE
    install_name_tool -id @rpath/libSDL2_ttf.dylib "$PREFIXDIR/lib/libSDL2_ttf.dylib"
  cd ..
  
  echo -e "\n\nBuilding libCrypto (OpenSSL) ...\n\n"
  cd openssl
    ./Configure "$OPENSSLPLATFORM" shared --openssldir="$PREFIXDIR" -mmacosx-version-min=10.7
    make depend; make; make install_sw
    chmod +w "$PREFIXDIR/lib/libcrypto.dylib" "$PREFIXDIR/lib/libssl.dylib"
    install_name_tool -id @rpath/libcrypto.dylib "$PREFIXDIR/lib/libcrypto.dylib"
    install_name_tool -id @rpath/libssl.dylib "$PREFIXDIR/lib/libssl.dylib"
  cd ..
  
cd ..

# We don't need a lot of what was just made, so copy only what's wanted

mkdir artifacts

# Manually copy headers wanted. Mostly to exclude freetype, which isn't directly used
mkdir artifacts/include
cp -R build/include/libpng16   artifacts/include/
cp    build/include/jansson*.h artifacts/include/
cp -R build/include/speex      artifacts/include/
cp -R build/include/SDL2       artifacts/include/
cp -R build/include/openssl    artifacts/include/

# Manually copy libs wanted. Removes static libraries and versioned libs
mkdir artifacts/lib
cp build/lib/libpng16.dylib    artifacts/lib/
cp build/lib/libfreetype.dylib artifacts/lib/
cp build/lib/libjansson.dylib  artifacts/lib/
cp build/lib/libspeexdsp.dylib artifacts/lib/
cp build/lib/libSDL2.dylib     artifacts/lib/
cp build/lib/libSDL2_ttf.dylib artifacts/lib/
cp build/lib/libcrypto.dylib   artifacts/lib/

# Make final archive
cd artifacts && zip -rX openrct2-libs-macos.zip include lib && cd ..
