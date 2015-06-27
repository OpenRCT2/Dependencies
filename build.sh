mkdir build 
mkdir build/openssl
mkdir openssl_tmp
cp -ai ./src/argparse ./build
cp -ai ./src/cutest ./build
cp -ai ./src/jansson ./build
cp -ai ./src/libspeex ./build
cp -ai ./src/lodepng ./build

#build openssl for mingw here

#copy openssl_tmp to build/openssl here

#build libcurl for mingw here

#copy libxurl_tmp to build/libcurl here
