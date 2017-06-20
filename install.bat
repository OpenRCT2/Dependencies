mkdir %VCPKG%
pushd %VCPKG%
  REM Install vcpkg
  IF NOT EXIST %VCPKG%\.git (
    git clone -q https://github.com/Microsoft/vcpkg.git .
    call .\bootstrap-vcpkg.bat
  )
  git pull

  REM Install x86 libraries
  REM .\vcpkg install curl:x86-windows-static
  .\vcpkg install freetype:x86-windows-static
  .\vcpkg install libpng:x86-windows-static
  .\vcpkg install sdl2:x86-windows-static
  .\vcpkg install openssl:x86-windows-static
  .\vcpkg install zlib:x86-windows-static
  REM .\vcpkg install jansson:x86-windows-static
  REM .\vcpkg install libspeex:x86-windows-static
  .\vcpkg install libzip:x86-windows-static

  REM Install x64 libraries
  REM .\vcpkg install curl:x64-windows-static
  .\vcpkg install freetype:x64-windows-static
  .\vcpkg install libpng:x64-windows-static
  .\vcpkg install sdl2:x64-windows-static
  .\vcpkg install openssl:x64-windows-static
  .\vcpkg install zlib:x64-windows-static
  REM .\vcpkg install jansson:x64-windows-static
  REM .\vcpkg install libspeex:x64-windows-static
  .\vcpkg install libzip:x64-windows-static

popd
