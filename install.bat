REM Install upstream vcpkg
git clone -q https://github.com/Microsoft/vcpkg.git
pushd vcpkg
  git apply ..\0001-Patch-duktape.patch
  call .\bootstrap-vcpkg.bat
popd
