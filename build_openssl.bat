pushd .\src\openssl
    call "%VSCOMNTOOLS%\..\..\VC\vcvarsall.bat" x86
    perl Configure VC-WIN32 no-asm
    call ms\do_ms
    nmake /f ms\nt.mak
popd