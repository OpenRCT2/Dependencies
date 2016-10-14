#########################################################
# Script to package the merged lib and headers into a zip.
#########################################################
$ErrorActionPreference = "Stop"

function AppExists($app)
{
    $result = (Get-Command $app -CommandType Application -ErrorAction SilentlyContinue)
    return ($result -ne $null -and $result.Count -gt 0)
}

if (-not (AppExists("7z")))
{
    Write-Host "Build script requires 7z to be in PATH" -ForegroundColor Red
    return 1
}

$includeDir = ".\artifacts\include"
$artifactsDir = ".\artifacts"
$outZip = "$artifactsDir\openrct2-libs-vs2015.zip"

Remove-Item -Force -Recurse $artifactsDir -ErrorAction SilentlyContinue

New-Item -Force -ItemType Directory $includeDir   > $null
New-Item -Force -ItemType Directory $artifactsDir > $null

# A bit hacky, but because build modifies the project files, its in a dirty state for build64,
# therefore we do a git clean and checkout. We have to temporarily rename artifacts so that
# doesn't get removed.
.\build.ps1
Write-Host "-----------------------------------------------------" -ForegroundColor Cyan
Write-Host
Write-Host "Cleaning for build64"
Move-Item $artifactsDir .\artifacts_noclean
.\clean.bat
git checkout .
Write-Host "-----------------------------------------------------" -ForegroundColor Cyan
Move-Item .\artifacts_noclean $artifactsDir
.\build64.ps1
Write-Host "-----------------------------------------------------" -ForegroundColor Cyan

# Copy headers
function CopyHeaders($src, $dst)
{
    $dst = "$includeDir\$dst"
    Write-Host "Copying headers to $dst"
    New-Item -Force -ItemType Directory $dst > $null
    Copy-Item -Force -Recurse $src $dst
}

Write-Host "Copying headers..." -ForegroundColor Cyan
CopyHeaders ".\src\breakpad\src\src\client\windows\handler\*.h"          "breakpad\client\windows\handler"
CopyHeaders ".\src\breakpad\src\src\client\windows\sender\*.h"           "breakpad\client\windows\sender"
CopyHeaders ".\src\breakpad\src\src\client\windows\common\*.h"           "breakpad\client\windows\common"
CopyHeaders ".\src\breakpad\src\src\common\*.h"                          "breakpad\common"
CopyHeaders ".\src\breakpad\src\src\common\windows\*.h"                  "breakpad\common\windows"
CopyHeaders ".\src\breakpad\src\src\client\windows\crash_generation\*.h" "breakpad\client\windows\crash_generation"
CopyHeaders ".\src\breakpad\src\src\google_breakpad\common\*.h"          "breakpad\google_breakpad\common"
CopyHeaders ".\src\sdl\include\*.h"                                      "sdl"
CopyHeaders ".\src\sdl_ttf\*.h"                                          "sdl_ttf"
CopyHeaders ".\src\libpng\*.h"                                           "libpng"
CopyHeaders ".\src\zlib\*.h"                                             "zlib"
CopyHeaders ".\src\jansson\src\*.h"                                      "jansson"
CopyHeaders ".\src\libspeex\*.h"                                         "libspeex"
CopyHeaders ".\src\libspeex\speex\*.h"                                   "libspeex\speex"
CopyHeaders ".\src\curl\include\curl\*.h"                                "curl"
CopyHeaders ".\src\openssl\include\openssl\*.h"                          "openssl"

Write-Host "-----------------------------------------------------" -ForegroundColor Cyan

# Create dependencies package
Write-Host "Creating dependencies package..." -ForegroundColor Cyan


# Create archive using 7z (renowned for speed and compression)
7z a -tzip -mx9 -mtc=off $outZip "$artifactsDir\*" | Write-Host
if ($LASTEXITCODE -ne 0)
{
    Write-Host "Failed to create zip." -ForegroundColor Red
    return 1
}
