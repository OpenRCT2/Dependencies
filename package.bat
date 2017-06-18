set packages=%VCPKG%\installed\x64-windows-static
set artifacts=%CD%\artifacts
set include=%artifacts%\include
set outzip=%artifacts%\openrct2-libs-vs2017.zip

REM copy headers
xcopy /EIY "%packages%\include" "%include%"

REM create zip
7z a -tzip -mx9 -mtc=off "%outZip%" "%artifacts%\*"
