set packages=vcpkg\installed\%TRIPLET%
set outarchive=openrct2-libs-v%version%-%TRIPLET%
pushd %packages%
  7z a -tzip -mx9 -mtc=off "%outarchive%.zip" "*"
popd
