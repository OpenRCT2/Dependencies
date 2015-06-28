Import-Module Pscx
Invoke-BatchFile 'C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat'
msbuild .\src\curl\projects\Windows\VC12\lib\libcurl.sln /p:Configuration="LIB Release - LIB OpenSSL" /p:Platform=Win32