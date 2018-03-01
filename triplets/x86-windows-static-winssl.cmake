# Based on upstream x86-windows-static.cmake
set(VCPKG_TARGET_ARCHITECTURE x86)
set(VCPKG_CRT_LINKAGE static)
set(VCPKG_LIBRARY_LINKAGE static)
# Make curl use winssl
set(CURL_USE_WINSSL ON)
