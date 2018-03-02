REM Install upstream vcpkg

git clone -q https://github.com/Microsoft/vcpkg.git
robocopy /v /fp triplets vcpkg/triplets/
pushd vcpkg
call .\bootstrap-vcpkg.bat
git pull

REM Uninstall out of date packages so they are updated
.\vcpkg remove --outdated --recurse
popd
