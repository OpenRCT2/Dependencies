#uses glob and local to separate where to extract files in the OpenRCT2 during pre-build
UNAME=$(uname)
if [ ${UNAME:0:6} == "CYGWIN" ]; then
	PATH_SEPARATOR=';'
fi

BASEDIR=`pwd`/`dirname $0`

mkdir build 
mkdir build/local
mkdir build/glob
mkdir build/glob/include
mkdir build/glob/lib
mkdir RCTBUILD
cp -ai ./src/argparse ./build/local
cp -ai ./src/cutest ./build/local
cp -ai ./src/libspeex ./build/local
cp -ai ./src/lodepng ./build/local

#build openssl for mingw
pushd ./src/openssl
	CROSS_COMPILE="i686-w64-mingw32-" ./Configure mingw no-asm --prefix=$BASEDIR/RCTBUILD
	make clean
	make depend
	make
	make install
popd

#build libcurl for mingw
pushd ./src/curl
	autoreconf -vi
	./configure mingw32 --target=i686-w64-mingw32 --host=i686-w64-mingw32 --with-ssl=$BASEDIR/RCTBUILD --disable-shared --disable-ldap --disable-ldaps --disable-rtsp --disable-zlib --prefix=$BASEDIR/RCTBUILD curl_disallow_strtok_r=yes
	make clean
	make
	make install-strip
popd

#build jansson for minw
pushd ./src/jansson
	autoreconf -vi
	./configure --build=mingw32 --host=i686-w64-mingw32 --target=i686-w64-mingw32 --prefix=$BASEDIR/RCTBUILD --disable-shared
	make clean
	make
	make install
popd

#copy global includes to the build
mkdir ./RCTBUILD/include/jansson
mv ./RCTBUILD/include/jansson*.h ./RCTBUILD/include/jansson/.
cp -ai ./RCTBUILD/lib ./build/glob/
cp -ai ./RCTBUILD/include ./build/glob/

#add sdl_ttf to glob
cp -ai ./src/sdl_ttf/MinGW/* ./build/glob
