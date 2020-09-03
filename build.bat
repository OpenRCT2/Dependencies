setlocal
pushd vcpkg
  set libraries=discord-rpc:%TRIPLET% duktape:%TRIPLET% freetype:%TRIPLET% libpng:%TRIPLET% libzip[core]:%TRIPLET% nlohmann-json:%TRIPLET% sdl2:%TRIPLET% speexdsp:%TRIPLET% zlib:%TRIPLET%
  .\vcpkg install %libraries%
  .\vcpkg export %libraries% --zip --nuget
popd
