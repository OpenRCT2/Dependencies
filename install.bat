REM Install upstream vcpkg
git clone -q https://github.com/Microsoft/vcpkg.git
pushd vcpkg
  call .\bootstrap-vcpkg.bat
popd
