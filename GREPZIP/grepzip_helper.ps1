param(
    [string]$Specification = '',
    [string]$Manifest = (Join-Path $env:TEMP 'grepzip_manifest.txt'),
    [switch]$Cleanup
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

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

function Process-File([string]$disk, [string]$display, [string]$mask,
                      [int]$depth, [bool]$forceSearch) {
    if ($depth -gt 32) { return }
    $kind = Get-ArchiveKind $display
    try {
        if ($kind -eq 'zip') {
            Expand-ZipArchive $disk $display $mask $depth
        } elseif ($kind -eq 'tar' -or $kind -eq 'tgz') {
            Expand-TarArchive $disk $display $mask $depth
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
