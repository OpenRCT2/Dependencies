cp .\src\curl\include\curl .\build\libcurl\include -Recurse -Force
cp '.\src\curl\build\Win32\VC12\LIB Release - LIB OpenSSL\libcurl.lib' .\build\libcurl\lib
cp .\src\sdl_ttf\SDL_ttf.h .\build\SDL2_ttf\include -Force
cp .\src\sdl_ttf\VisualC\Win32\Release\SDL2_ttf.lib .\build\SDL2_ttf\lib\x86 -Force
