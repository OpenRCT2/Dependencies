REM add linker to PATH
set PATH=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Tools\MSVC\14.10.25017\bin\Host%1\%1;%PATH%

set packages=%VCPKG%\installed\%1-windows-static
set artifacts=%CD%\artifacts
set outlib=%artifacts%\openrct2-libs-vs2017-%1.lib

REM aggregate libs
mkdir "%artifacts%"
pushd "%packages%\lib"
    lib /LTCG "/OUT:%outlib%" bz2.lib freetype.lib jansson.lib libcurl.lib libeay32.lib libpng16.lib libspeexdsp.lib libssh2.lib SDL2.lib ssleay32.lib zip.lib zlib.lib
popd
