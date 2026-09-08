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

$work = Join-Path $env:TEMP ("grepzip_" + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $work | Out-Null
$writer = New-Object System.IO.StreamWriter($Manifest, $false, [Text.Encoding]::Default)
$writer.WriteLine('#WORK=' + $work)

function Add-SearchFile([string]$disk, [string]$display) {
    if ($display.IndexOf("`t") -ge 0) { $display = $display.Replace("`t", ' ') }
    $writer.WriteLine($disk + "`t" + $display)
}

function Expand-ZipRecursive([string]$zipPath, [string]$display, [int]$depth) {
    if ($depth -gt 32) { return }
    $stream = [IO.File]::Open($zipPath, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::ReadWrite)
    try {
        $archive = New-Object IO.Compression.ZipArchive($stream, [IO.Compression.ZipArchiveMode]::Read)
        try {
            foreach ($entry in $archive.Entries) {
                if ([string]::IsNullOrEmpty($entry.Name)) { continue }
                $safeName = [IO.Path]::GetFileName($entry.Name)
                if ([string]::IsNullOrEmpty($safeName)) { continue }
                $target = Join-Path $work (([Guid]::NewGuid().ToString('N')) + '_' + $safeName)
                $input = $entry.Open()
                try {
                    $output = [IO.File]::Create($target)
                    try { $input.CopyTo($output) } finally { $output.Dispose() }
                } finally { $input.Dispose() }
                $virtual = $display + '::' + $entry.FullName
                if ($entry.Name.EndsWith('.zip', [StringComparison]::OrdinalIgnoreCase)) {
                    Expand-ZipRecursive $target $virtual ($depth + 1)
                } else {
                    Add-SearchFile $target $virtual
                }
            }
        } finally { $archive.Dispose() }
    } catch {
        # Invalid/encrypted ZIPs are skipped; ordinary files remain searchable.
    } finally { $stream.Dispose() }
}

try {
    $expanded = [Environment]::ExpandEnvironmentVariables($Specification.Trim('"'))
    if (Test-Path -LiteralPath $expanded -PathType Container) {
        $root = (Resolve-Path -LiteralPath $expanded).Path
        $files = Get-ChildItem -LiteralPath $root -File -Recurse -Force -ErrorAction SilentlyContinue
    } elseif (Test-Path -LiteralPath $expanded -PathType Leaf) {
        $files = @(Get-Item -LiteralPath $expanded)
    } else {
        $parent = Split-Path -Parent $expanded
        $mask = Split-Path -Leaf $expanded
        if ([string]::IsNullOrEmpty($parent)) { $parent = (Get-Location).Path }
        $files = Get-ChildItem -LiteralPath $parent -File -Recurse -Force -Filter $mask -ErrorAction SilentlyContinue
    }

    foreach ($file in $files) {
        if ($file.Extension.Equals('.zip', [StringComparison]::OrdinalIgnoreCase)) {
            Expand-ZipRecursive $file.FullName $file.FullName 0
        } else {
            Add-SearchFile $file.FullName $file.FullName
        }
    }
} finally {
    $writer.Dispose()
}
