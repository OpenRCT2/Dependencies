Import-Module Pscx

mkdir build
mkdir openssl_tmp
cp .\src\argparse .\build -Recurse -Force
cp .\src\cutest .\build -Recurse -Force
cp .\src\jansson .\build -Recurse -Force
cp .\src\libspeex .\build -Recurse -Force
cp .\src\lodepng .\build -Recurse -Force
cp .\src\sdl .\build -Recurse -Force

pushd .\src\openssl
    Invoke-BatchFile 'C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat'
    $oldPath = $env:Path
    $env:Path = $oldPath+';C:\nasm-2.11.08'
    perl Configure VC-WIN32 --prefix=../../openssl_tmp
    ms\do_nasm
    nmake /NOLOGO -f ms\nt.mak
    nmake /NOLOGO /N -f ms\nt.mak test    nmake /NOLOGO -f ms\nt.mak install
    $env:Path = $oldPath
popd
