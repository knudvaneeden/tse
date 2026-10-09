param(
    [string]$Specification = '',
    [string]$Request = '',
    [switch]$ListOnly,
    [string]$Manifest = (Join-Path $env:TEMP 'grepzip_manifest.txt'),
    [switch]$Cleanup
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$sevenZipConfigured = ''
$rarConfigured = ''
$iniPath = Join-Path $PSScriptRoot 'proj0200.ini'
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
    if ($disk.Length -gt 254 -or $display.Length -gt 254) {
        $writer.WriteLine('#ERROR=Path exceeds TSE SAL 254 characters: ' + $display)
        return
    }
    # Separate records avoid concatenating two long paths into one SAL string.
    $writer.WriteLine('F' + $disk)
    $writer.WriteLine('D' + $display)
}

function Get-ArchiveKind([string]$name) {
    $lower = $name.ToLowerInvariant()
    if ($lower.EndsWith('.zip') -or $lower.EndsWith('.jar')) { return 'zip' }
    if ($lower.EndsWith('.tgz') -or $lower.EndsWith('.tar.gz')) { return 'tgz' }
    if ($lower.EndsWith('.tar')) { return 'tar' }
    if ($lower.EndsWith('.7z')) { return '7z' }
    if ($lower.EndsWith('.rar')) { return 'rar' }
    if ($lower.EndsWith('.gz') -or $lower.EndsWith('.gzip')) { return 'gzip' }
    if ($lower.EndsWith('.bz2') -or $lower.EndsWith('.xz')) { return '7z' }
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
    if (-not $tarCommand) { Expand-SevenZipArchive $archivePath $display $mask $depth; return }
    $extractRoot = Join-Path $work ([Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $extractRoot | Out-Null
    & $tarCommand.Source -xf $archivePath -C $extractRoot 2>$null
    if ($LASTEXITCODE -ne 0) { throw 'Archive extraction failed.' }
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
    if ([string]::IsNullOrEmpty($sevenZip)) { throw '7z.exe is required for this archive; set SevenZipExecutable in proj0200.ini.' }
    $extractRoot = Join-Path $work ([Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $extractRoot | Out-Null
    $outputOption = '-o' + $extractRoot
    & $sevenZip x -y $outputOption -- $archivePath *> $null
    if ($LASTEXITCODE -ne 0) { throw 'Archive extraction failed.' }
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
    if ($LASTEXITCODE -ne 0) { throw 'Archive extraction failed.' }
    $members = Get-ChildItem -LiteralPath $extractRoot -File -Recurse -Force `
                             -ErrorAction SilentlyContinue
    foreach ($member in $members) {
        $relative = $member.FullName.Substring($extractRoot.Length).TrimStart('\')
        $relative = $relative.Replace('\', '/')
        Process-File $member.FullName ($display + '::' + $relative) `
                     $mask ($depth + 1) $false
    }
}

function Expand-GzipArchive([string]$archivePath, [string]$display,
                            [string]$mask, [int]$depth) {
    $target = Join-Path $work ([Guid]::NewGuid().ToString('N') + '_gzip')
    $input = [IO.File]::OpenRead($archivePath)
    try {
        $gzip = New-Object IO.Compression.GZipStream($input, [IO.Compression.CompressionMode]::Decompress)
        try {
            $output = [IO.File]::Create($target)
            try { $gzip.CopyTo($output) } finally { $output.Dispose() }
        } finally { $gzip.Dispose() }
    } finally { $input.Dispose() }
    $member = [IO.Path]::GetFileNameWithoutExtension($display)
    Process-File $target ($display + '::' + $member) $mask ($depth + 1) $true
}

function Process-File([string]$disk, [string]$display, [string]$mask,
                      [int]$depth, [bool]$forceSearch) {
    if ($depth -gt 32) { return }
    $kind = Get-ArchiveKind $display
    try {
        if ($ListOnly) { Add-SearchFile $disk $display; return }
        if ($kind -eq 'gzip') {
            Expand-GzipArchive $disk $display $mask $depth
        } elseif ($kind -eq 'zip') {
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
        $writer.WriteLine("#ERROR=" + $display + ": " + $_.Exception.Message)
    }
}

# Request records: F=exact file, S=scan path, K=known extension, P=saved project.
# No project activation, editor-buffer restore, or membership write takes place.
$seen = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
function Visit-Scope([string[]]$paths, [string[]]$types, [string]$base) {
    $excludes = @($paths | Where-Object { $_.StartsWith('<') } | ForEach-Object { $_.Substring(1) })
    foreach ($path in $paths) {
        if ([string]::IsNullOrWhiteSpace($path) -or $path.StartsWith('<')) { continue }
        $recursive = $path.StartsWith('>')
        if ($recursive) { $path = $path.Substring(1) }
        $path = [Environment]::ExpandEnvironmentVariables($path.Replace('%@PJROOT%', $base))
        if (-not [IO.Path]::IsPathRooted($path)) { $path = Join-Path $base $path }
        if (Test-Path -LiteralPath $path -PathType Leaf) {
            $members = @(Get-Item -LiteralPath $path)
            $exact = $true
        } elseif (Test-Path -LiteralPath $path -PathType Container) {
            $members = @(Get-ChildItem -LiteralPath $path -File -Recurse:$recursive -Force -ErrorAction SilentlyContinue)
            $exact = $false
        } else {
            # A named unsaved buffer may exist only in TSE; emit its exact filename.
            if ([IO.Path]::GetExtension($path) -and $seen.Add($path)) { Add-SearchFile $path $path }
            $writer.WriteLine('#ERROR=Missing scope path on disk: ' + $path)
            continue
        }
        foreach ($file in $members) {
            $excluded = $false
            foreach ($exclude in $excludes) {
                $exclude = $exclude.Replace('%@PJROOT%', $base)
                if (-not [IO.Path]::IsPathRooted($exclude)) { $exclude = Join-Path $base $exclude }
                if ($file.FullName -eq $exclude -or $file.FullName.StartsWith($exclude.TrimEnd('\') + '\', [StringComparison]::OrdinalIgnoreCase)) { $excluded = $true; break }
            }
            if ($excluded) { continue }
            $extension = $file.Extension.TrimStart('.').ToLowerInvariant()
            if (($exact -or (Get-ArchiveKind $file.Name) -or $types -contains $extension) -and $seen.Add($file.FullName)) {
                Process-File $file.FullName $file.FullName '*' 0 $true
            }
        }
    }
}
try {
    $records = [IO.File]::ReadAllLines($Request, [Text.Encoding]::Default)
    $types = @($records | Where-Object { $_.StartsWith('K') } | ForEach-Object { $_.Substring(1).Trim().TrimStart('.').ToLowerInvariant() })
    $paths = @($records | Where-Object { $_.StartsWith('S') -or $_.StartsWith('F') } | ForEach-Object { $_.Substring(1) })
    $rootRecord = @($records | Where-Object { $_.StartsWith('R') } | Select-Object -First 1)
    $base = $PSScriptRoot
    if ($rootRecord.Count -gt 0 -and $rootRecord[0].Length -gt 1) { $base = $rootRecord[0].Substring(1) }
    Visit-Scope $paths $types $base
    foreach ($record in $records) {
        if (-not $record.StartsWith('P')) { continue }
        $project = $record.Substring(1)
        if (-not (Test-Path -LiteralPath $project -PathType Leaf)) { $writer.WriteLine('#ERROR=Missing project: ' + $project); continue }
        $section = ''
        $projectPaths = @()
        $projectTypes = @()
        $cachedFiles = @()
        foreach ($line in [IO.File]::ReadAllLines($project, [Text.Encoding]::Default)) {
            if ($line -match '^\[(.+)\]') { $section = $Matches[1]; continue }
            if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith(';')) { continue }
            if ($section -eq 'Paths') { $projectPaths += $line }
            elseif ($section -eq 'KnownFileTypes') { $projectTypes += $line.Trim().TrimStart('.').ToLowerInvariant() }
            elseif ($section -eq 'FilesInProject') {
                $parts = $line.Split([char]1)
                if ($parts.Length -eq 2) { $cachedFiles += ($parts[1] + $parts[0]) }
            }
        }
        if ($projectTypes.Count -eq 0) { $projectTypes = $types }
        # Paths are authoritative. Cached entries are used only when no paths exist.
        if ($projectPaths.Count -eq 0) { $projectPaths = $cachedFiles }
        $projectBase = $PSScriptRoot
        if ([IO.Path]::GetFileName($project) -ieq 'local.pj') { $projectBase = [IO.Path]::GetDirectoryName($project) }
        Visit-Scope $projectPaths $projectTypes $projectBase
    }
} catch { $writer.WriteLine('#ERROR=' + $_.Exception.Message); exit 1 }
finally { $writer.Dispose() }
