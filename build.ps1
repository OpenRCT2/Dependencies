#########################################################
# Script to build all the libraries required for OpenRCT2
# into a single lib file for x86.
#########################################################
#$ErrorActionPreference = "Stop"

function AppExists($app)
{
    $result = (Get-Command $app -CommandType Application -ErrorAction SilentlyContinue)
    return ($result -ne $null -and $result.Count -gt 0)
}

if (-not (AppExists("msbuild")))
{
    Write-Host "msbuild not found, make sure you run this in a VS prompt" -ForegroundColor Red
    return 1
}
if (-not (AppExists("7z")))
{
    Write-Host "Build script requires 7z to be in PATH" -ForegroundColor Red
    return 1
}

Write-Host "-----------------------------------------------------" -ForegroundColor Cyan
Write-Host "Creating OpenRCT2 dependencies for Visual Studio 2015" -ForegroundColor Cyan
Write-Host "Platform: x86"                                         -ForegroundColor Cyan
Write-Host "-----------------------------------------------------" -ForegroundColor Cyan

$libExe = "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\bin\lib.exe"

$binDir = ".\bin"
$artifactsDir = ".\artifacts"
$buildOpenSSL = false

Remove-Item -Force -Recurse $binDir       -ErrorAction SilentlyContinue

New-Item -Force -ItemType Directory $binDir       > $null
New-Item -Force -ItemType Directory $artifactsDir > $null

# Build breakpad
Write-Host "Building breakpad..." -ForegroundColor Cyan
msbuild ".\src\breakpad\src\src\client\windows\breakpad_client.sln" "/p:Configuration=Release" "/p:Platform=Win32" "/p:PlatformToolset=v140" "/v:Minimal"
Copy-Item -Force ".\src\breakpad\src\src\client\windows\Release\lib\common.lib" $binDir
Copy-Item -Force ".\src\breakpad\src\src\client\windows\Release\lib\crash_generation_client.lib" $binDir
Copy-Item -Force ".\src\breakpad\src\src\client\windows\Release\lib\exception_handler.lib" $binDir
Copy-Item -Force ".\src\breakpad\src\src\client\windows\Release\lib\crash_report_sender.lib" $binDir
Write-Host

# Build libcurl
Write-Host "Building libcurl..." -ForegroundColor Cyan
git apply --directory=src\curl patches\curl.diff
.\src\curl\projects\generate.bat VC14
msbuild ".\src\curl\projects\Windows\VC14\lib\libcurl.sln" "/p:Configuration=LIB Release - DLL Windows SSPI" "/p:Platform=Win32" "/p:PlatformToolset=v140" "/v:minimal"
Copy-Item -Force ".\src\curl\build\Win32\VC14\LIB Release - DLL Windows SSPI\libcurl.lib" $binDir

# Build freetype2
Write-Host "Building freetype2..." -ForegroundColor Cyan
msbuild ".\src\freetype2\builds\windows\vc2010\freetype.sln" "/p:Configuration=Release Multithreaded" "/p:Platform=Win32" "/p:PlatformToolset=v140" "/v:minimal"
Write-Host
Copy-Item -Force ".\src\freetype2\objs\vc2010\Win32\freetype*.lib" "$binDir\freetype.lib"

# Build jansson
Write-Host "Building jansson..." -ForegroundColor Cyan
cmake -Bsrc\jansson\ -Hsrc\jansson\ -G "Visual Studio 14" -DJANSSON_STATIC_CRT=ON -DJANSSON_BUILD_DOCS=OFF
msbuild ".\src\jansson\jansson.sln" "/p:Configuration=Release" "/p:Platform=Win32" "/p:PlatformToolset=v140" "/v:minimal"
Copy-Item -Force ".\src\jansson\lib\Release\jansson.lib" $binDir

# Build SDL2
Write-Host "Building SDL2..." -ForegroundColor Cyan

# Patch vcxproj
$vcxprojPath = ".\src\sdl\VisualC\SDL\SDL.vcxproj"
(Get-Content $vcxprojPath).Replace('<ConfigurationType>DynamicLibrary</ConfigurationType>', '<ConfigurationType>StaticLibrary</ConfigurationType>') | Set-Content $vcxprojPath
(Get-Content $vcxprojPath).Replace('<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>', '<RuntimeLibrary>MultiThreaded</RuntimeLibrary>') | Set-Content $vcxprojPath
(Get-Content $vcxprojPath).Replace('%(PreprocessorDefinitions)', 'HAVE_LIBC;%(PreprocessorDefinitions)') | Set-Content $vcxprojPath
msbuild $vcxprojPath "/p:Configuration=Release" "/p:Platform=Win32" "/p:PlatformToolset=v140" "/v:minimal"
Write-Host
Copy-Item -Force ".\src\sdl\VisualC\SDL\Win32\Release\SDL2.lib" $binDir

# Build SDL2_TTF
Write-Host "Building SDL2_TTF..." -ForegroundColor Cyan

# Patch vcxproj
$vcxprojPath = ".\src\sdl_ttf\VisualC\SDL_ttf.vcxproj"
(Get-Content $vcxprojPath).Replace('<ConfigurationType>DynamicLibrary</ConfigurationType>', '<ConfigurationType>StaticLibrary</ConfigurationType>') | Set-Content $vcxprojPath
(Get-Content $vcxprojPath).Replace('<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>', '<RuntimeLibrary>MultiThreaded</RuntimeLibrary>') | Set-Content $vcxprojPath
(Get-Content $vcxprojPath).Replace("external\include", "external\include;..\..\sdl\include") | Set-Content $vcxprojPath
(Get-Content $vcxprojPath).Replace("external\lib\x86", "external\lib\x86;..\..\..\$binDir") | Set-Content $vcxprojPath
(Get-Content $vcxprojPath -Raw) -replace "<CustomBuild(.|\n|\r)+?<\/CustomBuild>", "" | Set-Content $vcxprojPath
msbuild $vcxprojPath "/p:Configuration=Release" "/p:Platform=Win32" "/p:PlatformToolset=v140" "/v:minimal"
Write-Host
Copy-Item -Force ".\src\sdl_ttf\VisualC\Win32\Release\SDL2_ttf.lib" $binDir

# Build libpng + zlib
Write-Host "Building libpng + zlib..." -ForegroundColor Cyan
git apply --directory=src\libpng patches\libpng.diff
msbuild ".\src\libpng\projects\vstudio\vstudio.sln" "/p:Configuration=Release Library" "/p:Platform=Win32" "/p:PlatformToolset=v140" "/v:minimal"
Write-Host
Copy-Item -Force ".\src\libpng\projects\vstudio\Release Library\libpng16.lib" $binDir
Copy-Item -Force ".\src\libpng\projects\vstudio\Release Library\zlib.lib"     $binDir

# Build nonproject (libspeex)
Write-Host "Building nonproject (libspeex)..." -ForegroundColor Cyan
msbuild ".\src\nonproject\nonproject.sln" "/p:Configuration=Release" "/p:Platform=x86" "/p:PlatformToolset=v140" "/v:minimal"
Copy-Item -Force ".\src\nonproject\bin\nonproject.lib" $binDir

if ($buildOpenSSL)
{
	# Download OpenSSL
	$opensslDownloadUrl = "https://github.com/openssl/openssl/archive/OpenSSL_1_0_2-stable.zip"
	$opensslDownloadOut = ".\openssl.zip"
	if (-not (Test-Path -PathType Leaf $opensslDownloadOut))
	{
		$extractDir = ".\src\openssl-OpenSSL_1_0_2-stable"
		Invoke-WebRequest $opensslDownloadUrl -OutFile $opensslDownloadOut
		Remove-Item -Force -Recurse $extractDir     -ErrorAction SilentlyContinue
		Remove-Item -Force -Recurse ".\src\openssl" -ErrorAction SilentlyContinue
		7z x $opensslDownloadOut -osrc | Write-Host
		Move-Item $extractDir ".\src\openssl"
	}

	# Build OpenSSL
	Write-Host "Building OpenSSL..." -ForegroundColor Cyan
	$env:VSCOMNTOOLS = (Get-Content("env:VS140COMNTOOLS"))
	& ".\build_openssl.bat"
} else {
	# Download OpenSSL
	$opensslVersion = "1.0.2h"
	$opensslDownloadUrl = "http://www.npcglib.org/~stathis/downloads/openssl-$opensslVersion-vs2015.7z"
	$opensslDownloadOut = ".\openssl-precompiled.7z"
	if (-not (Test-Path -PathType Leaf $opensslDownloadOut))
	{
		$extractDir = ".\src\openssl-$opensslVersion-vs2015"
		Invoke-WebRequest $opensslDownloadUrl -OutFile $opensslDownloadOut
		Remove-Item -Force -Recurse $extractDir     -ErrorAction SilentlyContinue
		Remove-Item -Force -Recurse ".\src\openssl" -ErrorAction SilentlyContinue
		7z x $opensslDownloadOut -osrc | Write-Host
		Move-Item $extractDir ".\src\openssl"
		Copy-Item -Force ".\src\openssl\lib\libeay32MT.lib" "$binDir\libeay32.lib"
	}
}


Write-Host "-----------------------------------------------------" -ForegroundColor Cyan

# Merge static libraries
Write-Host "Merging static libraries..." -ForegroundColor Cyan
Push-Location ".\bin"
& $libExe /LTCG "/OUT:..\$artifactsDir\openrct2-libs-vs2015-x86.lib" `
    ".\SDL2.lib" `
    ".\SDL2_ttf.lib" `
    ".\freetype.lib" `
    ".\jansson.lib" `
    ".\libpng16.lib" `
    ".\zlib.lib" `
    ".\nonproject.lib" `
    ".\libcurl.lib" `
    ".\libeay32.lib" `
    ".\common.lib" `
    ".\crash_report_sender.lib" `
    ".\exception_handler.lib" `
    ".\crash_generation_client.lib"

if ($LASTEXITCODE -ne 0)
{
    Write-Host "Failed to create merged library." -ForegroundColor Red
    return 1
}

Pop-Location
