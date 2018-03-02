set packages=vcpkg\installed\%TRIPLET%
set outarchive=openrct2-libs-%TRIPLET%

pushd %packages%

REM create zip
7z a -tzip -mx9 -mtc=off "%outarchive%.zip" "*"
7z a -t7z -mx9 -mtc=off "%outarchive%.7z" "*"

popd
