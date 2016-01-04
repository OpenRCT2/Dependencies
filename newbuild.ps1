#########################################################
# Script to build all the libraries required for OpenRCT2
# into a single lib file that is packaged with headers.
#########################################################
$ErrorActionPreference = "Stop"

function AppExists($app)
{
    $result = (Get-Command $app -CommandType Application -ErrorAction SilentlyContinue)
    return ($result -ne $null -and $result.Count -gt 0)
}

Write-Host "-----------------------------------------------------" -ForegroundColor Cyan
Write-Host "Creating OpenRCT2 dependencies for Visual Studio 2015" -ForegroundColor Cyan
Write-Host "-----------------------------------------------------" -ForegroundColor Cyan

$libExe = "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\bin\lib.exe"

$binDir = ".\bin"
$includeDir = ".\artifacts\include"
$artifactsDir = ".\artifacts"
$outZip = "$artifactsDir\openrct2-libs-vs2015.zip"

Remove-Item -Force -Recurse $binDir       -ErrorAction SilentlyContinue
Remove-Item -Force -Recurse $artifactsDir -ErrorAction SilentlyContinue

New-Item -Force -ItemType Directory $binDir       > $null
New-Item -Force -ItemType Directory $includeDir   > $null
New-Item -Force -ItemType Directory $artifactsDir > $null

# Build libpng + zlib
Write-Host "Building libpng + zlib..." -ForegroundColor Cyan
msbuild ".\src\libpng\projects\vstudio\vstudio.sln" "/p:Configuration=Release Library" "/p:Platform=Win32" "/p:PlatformToolset=v140" "/v:minimal"
Write-Host
Copy-Item -Force ".\src\libpng\projects\vstudio\Release Library\libpng16.lib" $binDir
Copy-Item -Force ".\src\libpng\projects\vstudio\Release Library\zlib.lib"     $binDir

Write-Host "-----------------------------------------------------" -ForegroundColor Cyan

# Merge static libraries
Write-Host "Merging static libraries..." -ForegroundColor Cyan
Push-Location ".\bin"
& $libExe /LTCG "/OUT:..\$artifactsDir\openrct2-libs-vs2015.lib" ".\libpng16.lib" ".\zlib.lib"
Pop-Location

Write-Host "-----------------------------------------------------" -ForegroundColor Cyan

# Copy headers
function CopyHeaders($src, $dst)
{
    $dst = "$includeDir\$dst"
    Write-Host "Copying headers to $dst"
    New-Item -Force -ItemType Directory $dst > $null
    Copy-Item -Force $src $dst
}

Write-Host "Copying headers..." -ForegroundColor Cyan
CopyHeaders ".\src\libpng\*.h" "libpng"
CopyHeaders ".\src\zlib\*.h"   "zlib"

Write-Host "-----------------------------------------------------" -ForegroundColor Cyan

# Create dependencies package
Write-Host "Creating dependencies package..." -ForegroundColor Cyan


# Create archive using 7z (renowned for speed and compression)
$7zcmd = "7za"
if (-not (AppExists($7zcmd)))
{
    # AppVeyor in particular uses '7z' instead
    $7zcmd = "7z"
    if (-not (AppExists($7zcmd)))
    {
        Write-Host "Build script requires 7z to be in PATH" -ForegroundColor Red
        return 1
    }
}
& $7zcmd a -tzip -mx9 $outZip "$artifactsDir\*" | Write-Host
if ($LASTEXITCODE -ne 0)
{
    Write-Host "Failed to create zip." -ForegroundColor Red
    return 1
}