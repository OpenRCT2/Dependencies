set packages=vcpkg\installed\%TRIPLET%
set outzip=openrct2-libs-%TRIPLET%.zip

REM create zip
7z a -tzip -mx9 -mtc=off "%outZip%" "%packages%\*"
