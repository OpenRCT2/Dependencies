pushd vcpkg

REM Install libraries
.\vcpkg install benchmark:%TRIPLET% breakpad:%TRIPLET% curl:%TRIPLET% discord-rpc:%TRIPLET% freetype:%TRIPLET% jansson:%TRIPLET% libpng:%TRIPLET% libzip:%TRIPLET% openssl:%TRIPLET% sdl2:%TRIPLET% speexdsp:%TRIPLET% zlib:%TRIPLET%

REM Export libraries
.\vcpkg export benchmark:%TRIPLET% breakpad:%TRIPLET% curl:%TRIPLET% discord-rpc:%TRIPLET% freetype:%TRIPLET% jansson:%TRIPLET% libpng:%TRIPLET% libzip:%TRIPLET% openssl:%TRIPLET% sdl2:%TRIPLET% speexdsp:%TRIPLET% zlib:%TRIPLET% --zip --nuget

popd
