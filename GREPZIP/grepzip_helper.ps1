param(
    [string]$Specification = '',
    [string]$Manifest = (Join-Path $env:TEMP 'grepzip_manifest.txt'),
    [switch]$Cleanup
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$sevenZipConfigured = ''
$rarConfigured = ''
$iniPath = Join-Path $PSScriptRoot 'grepzip.ini'
if (Test-Path -LiteralPath $iniPath -PathType Leaf) {
    foreach ($iniLine in [IO.File]::ReadAllLines($iniPath)) {
        $trimmed = $iniLine.Trim()
        if ($trimmed -match '^SevenZipExecutable\s*=\s*(.*)$') {
            $sevenZipConfigured = [Environment]::ExpandEnvironmentVariables(
                $Matches[1].Trim().Trim('"'))
        } elseif ($trimmed -match '^RarExecutable\s*=\s*(.*)$') {
            $rarConfigured = [Environment]::ExpandEnvironmentVariables(
                $Matches[1].Trim().Trim('"'))
        }
    }
}

if ($Cleanup) {
    if (Test-Path -LiteralPath $Manifest) {
        $first = [IO.File]::ReadLines($Manifest) | Select-Object -First 1
        if ($first -and $first.StartsWith('#WORK=')) {
            $oldWork = $first.Substring(6)
            if ($oldWork -and (Test-Path -LiteralPath $oldWork)) {
                Remove-Item -LiteralPath $oldWork -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
        Remove-Item -LiteralPath $Manifest -Force -ErrorAction SilentlyContinue
    }
    exit 0
}

$work = Join-Path $env:TEMP ('grepzip_' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $work | Out-Null
$writer = New-Object IO.StreamWriter($Manifest, $false, [Text.Encoding]::Default)
$writer.WriteLine('#WORK=' + $work)

function Add-SearchFile([string]$disk, [string]$display) {
    if ($display.IndexOf("`t") -ge 0) { $display = $display.Replace("`t", ' ') }
    $writer.WriteLine($disk + "`t" + $display)
}

function Get-ArchiveKind([string]$name) {
    $lower = $name.ToLowerInvariant()
    if ($lower.EndsWith('.zip') -or $lower.EndsWith('.jar')) { return 'zip' }
    if ($lower.EndsWith('.tgz') -or $lower.EndsWith('.tar.gz')) { return 'tgz' }
    if ($lower.EndsWith('.tar')) { return 'tar' }
    if ($lower.EndsWith('.7z')) { return '7z' }
    if ($lower.EndsWith('.rar')) { return 'rar' }
    return ''
}

function Get-SevenZipCommand() {
    if ($sevenZipConfigured -and
        (Test-Path -LiteralPath $sevenZipConfigured -PathType Leaf)) {
        return $sevenZipConfigured
    }
    $command = Get-Command 7z.exe -ErrorAction SilentlyContinue
    if ($command) { return $command.Source }
    if ($env:ProgramFiles) {
        $candidate = Join-Path $env:ProgramFiles '7-Zip\7z.exe'
        if (Test-Path -LiteralPath $candidate -PathType Leaf) { return $candidate }
    }
    $programFilesX86 = [Environment]::GetEnvironmentVariable('ProgramFiles(x86)')
    if ($programFilesX86) {
        $candidate = Join-Path $programFilesX86 '7-Zip\7z.exe'
        if (Test-Path -LiteralPath $candidate -PathType Leaf) { return $candidate }
    }
    return ''
}

function Get-RarCommand() {
    if ($rarConfigured -and
        (Test-Path -LiteralPath $rarConfigured -PathType Leaf)) {
        return $rarConfigured
    }
    $command = Get-Command rar.exe -ErrorAction SilentlyContinue
    if ($command) { return $command.Source }
    if ($env:ProgramFiles) {
        $candidate = Join-Path $env:ProgramFiles 'WinRAR\Rar.exe'
        if (Test-Path -LiteralPath $candidate -PathType Leaf) { return $candidate }
    }
    $programFilesX86 = [Environment]::GetEnvironmentVariable('ProgramFiles(x86)')
    if ($programFilesX86) {
        $candidate = Join-Path $programFilesX86 'WinRAR\Rar.exe'
        if (Test-Path -LiteralPath $candidate -PathType Leaf) { return $candidate }
    }
    return ''
}

function Test-Mask([string]$name, [string]$mask) {
    if ([string]::IsNullOrEmpty($mask)) { return $true }
    if ($mask -eq '*' -or $mask -eq '*.*') { return $true }
    return $name -like $mask
}

function Expand-ZipArchive([string]$archivePath, [string]$display,
                           [string]$mask, [int]$depth) {
    $stream = [IO.File]::Open($archivePath, [IO.FileMode]::Open,
                              [IO.FileAccess]::Read, [IO.FileShare]::ReadWrite)
    try {
        $archive = New-Object IO.Compression.ZipArchive(
            $stream, [IO.Compression.ZipArchiveMode]::Read)
        try {
            foreach ($entry in $archive.Entries) {
                if ([string]::IsNullOrEmpty($entry.Name)) { continue }
                $safeName = [IO.Path]::GetFileName($entry.Name)
                if ([string]::IsNullOrEmpty($safeName)) { continue }
                $target = Join-Path $work (
                    [Guid]::NewGuid().ToString('N') + '_' + $safeName)
                $input = $entry.Open()
                try {
                    $output = [IO.File]::Create($target)
                    try { $input.CopyTo($output) } finally { $output.Dispose() }
                } finally { $input.Dispose() }
                Process-File $target ($display + '::' + $entry.FullName) `
                             $mask ($depth + 1) $false
            }
        } finally { $archive.Dispose() }
    } finally { $stream.Dispose() }
}

function Expand-TarArchive([string]$archivePath, [string]$display,
                           [string]$mask, [int]$depth) {
    $tarCommand = Get-Command tar.exe -ErrorAction SilentlyContinue
    if (-not $tarCommand) { return }
    $extractRoot = Join-Path $work ([Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $extractRoot | Out-Null
    & $tarCommand.Source -xf $archivePath -C $extractRoot 2>$null
    if ($LASTEXITCODE -ne 0) { return }
    $members = Get-ChildItem -LiteralPath $extractRoot -File -Recurse -Force `
                             -ErrorAction SilentlyContinue
    foreach ($member in $members) {
        $relative = $member.FullName.Substring($extractRoot.Length).TrimStart('\')
        $relative = $relative.Replace('\', '/')
        Process-File $member.FullName ($display + '::' + $relative) `
                     $mask ($depth + 1) $false
    }
}

function Expand-SevenZipArchive([string]$archivePath, [string]$display,
                                [string]$mask, [int]$depth) {
    $sevenZip = Get-SevenZipCommand
    if ([string]::IsNullOrEmpty($sevenZip)) { return }
    $extractRoot = Join-Path $work ([Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $extractRoot | Out-Null
    $outputOption = '-o' + $extractRoot
    & $sevenZip x -y $outputOption -- $archivePath *> $null
    if ($LASTEXITCODE -ne 0) { return }
    $members = Get-ChildItem -LiteralPath $extractRoot -File -Recurse -Force `
                             -ErrorAction SilentlyContinue
    foreach ($member in $members) {
        $relative = $member.FullName.Substring($extractRoot.Length).TrimStart('\')
        $relative = $relative.Replace('\', '/')
        Process-File $member.FullName ($display + '::' + $relative) `
                     $mask ($depth + 1) $false
    }
}

function Expand-RarArchive([string]$archivePath, [string]$display,
                           [string]$mask, [int]$depth) {
    $rarCommand = Get-RarCommand
    if ([string]::IsNullOrEmpty($rarCommand)) {
        Expand-SevenZipArchive $archivePath $display $mask $depth
        return
    }
    $extractRoot = Join-Path $work ([Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $extractRoot | Out-Null
    $destination = $extractRoot + '\'
    & $rarCommand x -o+ -inul $archivePath $destination *> $null
    if ($LASTEXITCODE -ne 0) { return }
    $members = Get-ChildItem -LiteralPath $extractRoot -File -Recurse -Force `
                             -ErrorAction SilentlyContinue
    foreach ($member in $members) {
        $relative = $member.FullName.Substring($extractRoot.Length).TrimStart('\')
        $relative = $relative.Replace('\', '/')
        Process-File $member.FullName ($display + '::' + $relative) `
                     $mask ($depth + 1) $false
    }
}

function Process-File([string]$disk, [string]$display, [string]$mask,
                      [int]$depth, [bool]$forceSearch) {
    if ($depth -gt 32) { return }
    $kind = Get-ArchiveKind $display
    try {
        if ($kind -eq 'zip') {
            Expand-ZipArchive $disk $display $mask $depth
        } elseif ($kind -eq 'tar' -or $kind -eq 'tgz') {
            Expand-TarArchive $disk $display $mask $depth
        } elseif ($kind -eq '7z') {
            Expand-SevenZipArchive $disk $display $mask $depth
        } elseif ($kind -eq 'rar') {
            Expand-RarArchive $disk $display $mask $depth
        } elseif ($forceSearch -or (Test-Mask ([IO.Path]::GetFileName($display)) $mask)) {
            Add-SearchFile $disk $display
        }
    } catch {
        # Damaged, encrypted and unsupported archives are skipped.
    }
}

try {
    $expanded = [Environment]::ExpandEnvironmentVariables($Specification.Trim('"'))
    $mask = '*'
    $forceSingle = $false
    if (Test-Path -LiteralPath $expanded -PathType Container) {
        $root = (Resolve-Path -LiteralPath $expanded).Path
        $files = Get-ChildItem -LiteralPath $root -File -Recurse -Force `
                               -ErrorAction SilentlyContinue
    } elseif (Test-Path -LiteralPath $expanded -PathType Leaf) {
        $files = @(Get-Item -LiteralPath $expanded)
        $forceSingle = $true
    } else {
        $parent = Split-Path -Parent $expanded
        $mask = Split-Path -Leaf $expanded
        if ([string]::IsNullOrEmpty($parent)) { $parent = (Get-Location).Path }
        $files = Get-ChildItem -LiteralPath $parent -File -Recurse -Force `
                               -ErrorAction SilentlyContinue
    }

    foreach ($file in $files) {
        $kind = Get-ArchiveKind $file.Name
        if ($kind -or $forceSingle -or (Test-Mask $file.Name $mask)) {
            Process-File $file.FullName $file.FullName $mask 0 $forceSingle
        }
    }
} finally {
    $writer.Dispose()
}
