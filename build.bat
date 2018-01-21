REM add linker to PATH
@echo off

set cdir=%CD%

for /f "usebackq tokens=*" %%i in (`"C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do (
  set InstallDir=%%i
)

if %1=="x64" (
    set devEnv="-arch=x64 -host_arch=x64"
)
if %1=="x86" (
    set devEnv="-arch=x86 -host_arch=x86"
)

if exist "%InstallDir%\Common7\Tools\vsdevcmd.bat" (
  call "%InstallDir%\Common7\Tools\vsdevcmd.bat" %devEnv% -no_logo
)

cd %cdir%

set packages=C:\tools\vcpkg\installed\%1-windows-static
set artifacts=%CD%\artifacts
set outlib=%artifacts%\openrct2-libs-vs2017-%1

REM aggregate libs
mkdir "%artifacts%"
pushd "%packages%\lib"
    lib /LTCG "/OUT:%outlib%.lib" bz2.lib discord-rpc.lib freetype.lib jansson.lib libcurl.lib libeay32.lib libpng16.lib libspeexdsp.lib libssh2.lib SDL2.lib ssleay32.lib zip.lib zlib.lib
popd
pushd "%packages%\debug\lib"
    lib /LTCG "/OUT:%outlib%d.lib" bz2d.lib discord-rpc.lib freetyped.lib jansson_d.lib libcurl.lib libeay32.lib libpng16d.lib libspeexdsp.lib libssh2.lib SDL2d.lib ssleay32.lib zip.lib zlibd.lib
popd
