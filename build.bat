setlocal
pushd vcpkg
  set libraries=benchmark:%TRIPLET% breakpad:%TRIPLET% discord-rpc:%TRIPLET% duktape:%TRIPLET% freetype:%TRIPLET% jansson:%TRIPLET% libpng:%TRIPLET% libzip[core]:%TRIPLET% sdl2:%TRIPLET% speexdsp:%TRIPLET% zlib:%TRIPLET%
  .\vcpkg install %libraries%
  .\vcpkg export %libraries% --zip --nuget
popd
