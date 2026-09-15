param(
    [Parameter(Mandatory = $true)][string]$ArchivePath,
    [Parameter(Mandatory = $true)][string]$OutputPath
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression

$script:MaximumDepth = 8
$script:MaximumMemberBytes = 268435456
$script:MaximumExpandedBytes = 536870912
$script:ExpandedBytes = [Int64]0
$script:CopyBuffer = New-Object byte[] 65536
$writer = New-Object System.IO.StreamWriter(
    $OutputPath, $false, [System.Text.Encoding]::Default)
$script:SevenZipPath = ''
$script:RarPath = ''
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$iniPath = Join-Path $scriptDirectory 'filefin2.ini'

function Get-IniValue {
    param([string]$Path, [string]$Section, [string]$Key)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return '' }
    $currentSection = ''
    foreach ($line in [System.IO.File]::ReadAllLines($Path)) {
        $text = $line.Trim()
        if ($text -eq '' -or $text.StartsWith(';') -or
            $text.StartsWith('#')) { continue }
        if ($text.StartsWith('[') -and $text.EndsWith(']')) {
            $currentSection = $text.Substring(1, $text.Length - 2).Trim()
            continue
        }
        if ($currentSection -ieq $Section) {
            $equals = $text.IndexOf('=')
            if ($equals -gt 0 -and
                $text.Substring(0, $equals).Trim() -ieq $Key) {
                return $text.Substring($equals + 1).Trim().Trim('"')
            }
        }
    }
    return ''
}

$configuredSevenZip = Get-IniValue $iniPath 'ArchiveTools' 'SevenZipExe'
if ($configuredSevenZip -ne '') {
    $configuredSevenZip =
        [Environment]::ExpandEnvironmentVariables($configuredSevenZip)
    if (Test-Path -LiteralPath $configuredSevenZip -PathType Leaf) {
        $script:SevenZipPath = $configuredSevenZip
    }
}
$configuredRar = Get-IniValue $iniPath 'ArchiveTools' 'RarExe'
if ($configuredRar -ne '') {
    $configuredRar = [Environment]::ExpandEnvironmentVariables($configuredRar)
    if (Test-Path -LiteralPath $configuredRar -PathType Leaf) {
        $script:RarPath = $configuredRar
    }
}

$localSevenZip = Join-Path $scriptDirectory '7z.exe'
$programFilesSevenZip = ''
$programFilesX86SevenZip = ''
$programFilesX86 = [Environment]::GetEnvironmentVariable('ProgramFiles(x86)')
if ($env:ProgramFiles) {
    $programFilesSevenZip = Join-Path $env:ProgramFiles '7-Zip\7z.exe'
}
if ($programFilesX86) {
    $programFilesX86SevenZip = Join-Path $programFilesX86 '7-Zip\7z.exe'
}
if ($script:SevenZipPath -eq '' -and
    (Test-Path -LiteralPath $localSevenZip -PathType Leaf)) {
    $script:SevenZipPath = $localSevenZip
}
elseif ($script:SevenZipPath -eq '') {
    $sevenZipCommand = Get-Command '7z.exe' -ErrorAction SilentlyContinue
    if ($sevenZipCommand -ne $null) {
        $script:SevenZipPath = $sevenZipCommand.Source
    }
    elseif ($programFilesSevenZip -ne '' -and
            (Test-Path -LiteralPath $programFilesSevenZip -PathType Leaf)) {
        $script:SevenZipPath = $programFilesSevenZip
    }
    elseif ($programFilesX86SevenZip -ne '' -and
            (Test-Path -LiteralPath $programFilesX86SevenZip -PathType Leaf)) {
        $script:SevenZipPath = $programFilesX86SevenZip
    }
}

$localRar = Join-Path $scriptDirectory 'rar.exe'
$programFilesRar = ''
$programFilesX86Rar = ''
if ($env:ProgramFiles) {
    $programFilesRar = Join-Path $env:ProgramFiles 'WinRAR\rar.exe'
}
if ($programFilesX86) {
    $programFilesX86Rar = Join-Path $programFilesX86 'WinRAR\rar.exe'
}
if ($script:RarPath -eq '' -and
    (Test-Path -LiteralPath $localRar -PathType Leaf)) {
    $script:RarPath = $localRar
}
elseif ($script:RarPath -eq '') {
    $rarCommand = Get-Command 'rar.exe' -ErrorAction SilentlyContinue
    if ($rarCommand -ne $null) {
        $script:RarPath = $rarCommand.Source
    }
    elseif ($programFilesRar -ne '' -and
            (Test-Path -LiteralPath $programFilesRar -PathType Leaf)) {
        $script:RarPath = $programFilesRar
    }
    elseif ($programFilesX86Rar -ne '' -and
            (Test-Path -LiteralPath $programFilesX86Rar -PathType Leaf)) {
        $script:RarPath = $programFilesX86Rar
    }
}

function Get-ArchiveKind {
    param([string]$Name)
    $lower = $Name.ToLowerInvariant()
    if ($lower.EndsWith('.zip')) { return 'zip' }
    if ($lower.EndsWith('.jar')) { return 'zip' }
    if ($lower.EndsWith('.tar')) { return 'tar' }
    if ($lower.EndsWith('.tgz')) { return 'tgz' }
    if ($lower.EndsWith('.rar')) { return 'rar' }
    if ($lower.EndsWith('.7z')) { return 'sevenzip' }
    return ''
}

function Read-Exact {
    param([System.IO.Stream]$Stream, [byte[]]$Buffer, [int]$Count)
    $offset = 0
    while ($offset -lt $Count) {
        $read = $Stream.Read($Buffer, $offset, $Count - $offset)
        if ($read -le 0) { return $false }
        $offset += $read
    }
    return $true
}

function Skip-Bytes {
    param([System.IO.Stream]$Stream, [Int64]$Count)
    if ($Count -le 0) { return $true }
    if ($Stream.CanSeek) {
        [void]$Stream.Seek($Count, [System.IO.SeekOrigin]::Current)
        return $true
    }
    while ($Count -gt 0) {
        $part = [int][Math]::Min([Int64]$script:CopyBuffer.Length, $Count)
        $read = $Stream.Read($script:CopyBuffer, 0, $part)
        if ($read -le 0) { return $false }
        $Count -= $read
    }
    return $true
}

function Get-TarText {
    param([byte[]]$Header, [int]$Offset, [int]$Count)
    $text = [System.Text.Encoding]::ASCII.GetString($Header, $Offset, $Count)
    $zero = $text.IndexOf([char]0)
    if ($zero -ge 0) { $text = $text.Substring(0, $zero) }
    return $text.Trim()
}

function Get-TarOctal {
    param([byte[]]$Header, [int]$Offset, [int]$Count)
    $text = (Get-TarText $Header $Offset $Count).Trim()
    [Int64]$value = 0
    foreach ($character in $text.ToCharArray()) {
        if ($character -lt '0' -or $character -gt '7') { break }
        if ($value -gt 1152921504606846975) { return [Int64]::MaxValue }
        $value = ($value * 8) + ([int]$character - [int][char]'0')
    }
    return $value
}

function Write-ArchiveEntry {
    param([Int64]$Size, [DateTime]$Date, [string]$Name)
    if ($Size -gt 2147483647) { $Size = 2147483647 }
    $writer.WriteLine("{0}`t{1}`t{2}`t{3}", $Size,
        $Date.ToString('MM/dd/yy'), $Date.ToString('HH:mm:ss'), $Name)
}

function Copy-ToMemory {
    param([System.IO.Stream]$Stream, [Int64]$Count)
    $memory = New-Object System.IO.MemoryStream
    while ($Count -gt 0) {
        $part = [int][Math]::Min([Int64]$script:CopyBuffer.Length, $Count)
        $read = $Stream.Read($script:CopyBuffer, 0, $part)
        if ($read -le 0) {
            $memory.Dispose()
            return $null
        }
        $memory.Write($script:CopyBuffer, 0, $read)
        $Count -= $read
    }
    $memory.Position = 0
    return $memory
}

function Read-ZipArchive {
    param([System.IO.Stream]$Stream, [string]$Prefix,
          [int]$Depth, [bool]$EmitEntries)
    $archive = New-Object System.IO.Compression.ZipArchive(
        $Stream, [System.IO.Compression.ZipArchiveMode]::Read, $true)
    try {
        foreach ($entry in $archive.Entries) {
            if ([string]::IsNullOrEmpty($entry.Name)) { continue }
            $displayName = $Prefix + $entry.FullName
            if ($EmitEntries) {
                Write-ArchiveEntry $entry.Length $entry.LastWriteTime.LocalDateTime `
                    $displayName
            }
            $kind = Get-ArchiveKind $entry.Name
            if ($kind -ne '' -and $Depth -lt $script:MaximumDepth -and
                $entry.Length -le $script:MaximumMemberBytes -and
                ($script:ExpandedBytes + $entry.Length) -le
                    $script:MaximumExpandedBytes) {
                $entryStream = $null
                $memory = $null
                try {
                    $script:ExpandedBytes += $entry.Length
                    $entryStream = $entry.Open()
                    $memory = Copy-ToMemory $entryStream $entry.Length
                    if ($memory -ne $null) {
                        Read-Archive $memory $entry.Name ($displayName + '::') `
                            ($Depth + 1) $true
                    }
                }
                catch { }
                finally {
                    if ($entryStream -ne $null) { $entryStream.Dispose() }
                    if ($memory -ne $null) { $memory.Dispose() }
                }
            }
        }
    }
    finally { $archive.Dispose() }
}

function Read-TarArchive {
    param([System.IO.Stream]$Stream, [string]$Prefix,
          [int]$Depth, [bool]$EmitEntries)
    $header = New-Object byte[] 512
    while (Read-Exact $Stream $header 512) {
        $nonZero = $false
        foreach ($value in $header) {
            if ($value -ne 0) { $nonZero = $true; break }
        }
        if (-not $nonZero) { break }

        $name = Get-TarText $header 0 100
        $prefixName = Get-TarText $header 345 155
        if ($prefixName -ne '') { $name = $prefixName + '/' + $name }
        $size = Get-TarOctal $header 124 12
        $seconds = Get-TarOctal $header 136 12
        $typeFlag = [char]$header[156]
        $isFile = ($typeFlag -eq [char]0 -or $typeFlag -eq '0' -or
                   $typeFlag -eq '7')
        $displayName = $Prefix + $name
        $date = [DateTime]::SpecifyKind(
            [DateTime]'1970-01-01 00:00:00', [DateTimeKind]::Utc)
        try { $date = $date.AddSeconds($seconds).ToLocalTime() } catch { }

        if ($isFile -and $EmitEntries -and $name -ne '') {
            Write-ArchiveEntry $size $date $displayName
        }
        $kind = Get-ArchiveKind $name
        $canDescend = $isFile -and $kind -ne '' -and
            $Depth -lt $script:MaximumDepth -and
            $size -le $script:MaximumMemberBytes -and
            ($script:ExpandedBytes + $size) -le $script:MaximumExpandedBytes

        $memory = $null
        if ($canDescend) {
            $script:ExpandedBytes += $size
            $memory = Copy-ToMemory $Stream $size
            if ($memory -eq $null) { return }
        }
        elseif (-not (Skip-Bytes $Stream $size)) { return }

        $padding = (512 - ($size % 512)) % 512
        if (-not (Skip-Bytes $Stream $padding)) {
            if ($memory -ne $null) { $memory.Dispose() }
            return
        }
        if ($memory -ne $null) {
            try {
                Read-Archive $memory $name ($displayName + '::') `
                    ($Depth + 1) $true
            }
            catch { }
            finally { $memory.Dispose() }
        }
    }
}

function Read-SevenZipRecord {
    param([hashtable]$Record, [string]$ArchiveFile,
          [string]$Prefix, [int]$Depth, [bool]$EmitEntries)

    if (-not $Record.ContainsKey('Path') -or
        -not $Record.ContainsKey('Size')) { return }
    if ($Record.ContainsKey('Folder') -and $Record['Folder'] -eq '+') { return }

    $name = $Record['Path']
    [Int64]$size = 0
    if (-not [Int64]::TryParse($Record['Size'], [ref]$size)) { return }
    $date = [DateTime]'1980-01-01 00:00:00'
    if ($Record.ContainsKey('Modified')) {
        $modified = $Record['Modified']
        if ($modified.Length -ge 19) {
            [DateTime]$parsedDate = $date
            if ([DateTime]::TryParseExact($modified.Substring(0, 19),
                    'yyyy-MM-dd HH:mm:ss',
                    [System.Globalization.CultureInfo]::InvariantCulture,
                    [System.Globalization.DateTimeStyles]::None,
                    [ref]$parsedDate)) {
                $date = $parsedDate
            }
        }
    }

    $displayName = $Prefix + $name
    if ($EmitEntries) { Write-ArchiveEntry $size $date $displayName }

    $kind = Get-ArchiveKind $name
    if ($kind -eq '' -or $Depth -ge $script:MaximumDepth -or
        $size -gt $script:MaximumMemberBytes -or
        ($script:ExpandedBytes + $size) -gt $script:MaximumExpandedBytes) {
        return
    }

    $tempDirectory = Join-Path ([System.IO.Path]::GetTempPath()) `
        ('FF7' + [Guid]::NewGuid().ToString('N'))
    [void][System.IO.Directory]::CreateDirectory($tempDirectory)
    try {
        & $script:SevenZipPath x -y ("-o" + $tempDirectory) -- `
            $ArchiveFile $name | Out-Null
        if ($LASTEXITCODE -ne 0) { return }
        $extractedFile = Get-ChildItem -LiteralPath $tempDirectory -Recurse `
            -Force | Where-Object { -not $_.PSIsContainer } | Select-Object -First 1
        if ($extractedFile -eq $null) { return }

        $script:ExpandedBytes += $size
        $nestedStream = $null
        try {
            $nestedStream = [System.IO.File]::OpenRead($extractedFile.FullName)
            Read-Archive $nestedStream $name ($displayName + '::') `
                ($Depth + 1) $true
        }
        finally {
            if ($nestedStream -ne $null) { $nestedStream.Dispose() }
        }
    }
    catch { }
    finally {
        Remove-Item -LiteralPath $tempDirectory -Recurse -Force `
            -ErrorAction SilentlyContinue
    }
}

function Read-SevenZipFile {
    param([string]$ArchiveFile, [string]$Prefix,
          [int]$Depth, [bool]$EmitEntries)

    if ($script:SevenZipPath -eq '') { return }
    $lines = & $script:SevenZipPath l -slt -ba -sccUTF-8 -- $ArchiveFile 2>$null
    if ($LASTEXITCODE -gt 1) { return }

    $record = @{}
    foreach ($line in $lines) {
        if ([string]::IsNullOrWhiteSpace($line)) {
            if ($record.Count -gt 0) {
                Read-SevenZipRecord $record $ArchiveFile $Prefix $Depth $EmitEntries
                $record = @{}
            }
        }
        elseif ($line -match '^([^=]+) = (.*)$') {
            $record[$matches[1].Trim()] = $matches[2]
        }
    }
    if ($record.Count -gt 0) {
        Read-SevenZipRecord $record $ArchiveFile $Prefix $Depth $EmitEntries
    }
}

function Read-SevenZipStream {
    param([System.IO.Stream]$Stream, [string]$Prefix,
          [int]$Depth, [bool]$EmitEntries)

    if ($script:SevenZipPath -eq '') { return }
    $tempArchive = [System.IO.Path]::GetTempFileName()
    $tempStream = $null
    try {
        $tempStream = [System.IO.File]::Create($tempArchive)
        $Stream.CopyTo($tempStream)
        $tempStream.Dispose()
        $tempStream = $null
        Read-SevenZipFile $tempArchive $Prefix $Depth $EmitEntries
    }
    finally {
        if ($tempStream -ne $null) { $tempStream.Dispose() }
        Remove-Item -LiteralPath $tempArchive -Force -ErrorAction SilentlyContinue
    }
}

function Read-RarFile {
    param([string]$ArchiveFile, [string]$Prefix,
          [int]$Depth, [bool]$EmitEntries)

    if ($script:SevenZipPath -ne '') {
        Read-SevenZipFile $ArchiveFile $Prefix $Depth $EmitEntries
        return
    }
    if ($script:RarPath -eq '') {
        return
    }

    $names = & $script:RarPath lb -c- -idq -p- $ArchiveFile 2>$null
    if ($LASTEXITCODE -gt 1) { return }
    foreach ($item in $names) {
        $name = ([string]$item).Trim()
        if ($name -eq '') { continue }
        $displayName = $Prefix + $name
        if ($EmitEntries) {
            Write-ArchiveEntry 0 ([DateTime]'1980-01-01 00:00:00') $displayName
        }

        $kind = Get-ArchiveKind $name
        if ($kind -eq '' -or $Depth -ge $script:MaximumDepth) { continue }

        $tempDirectory = Join-Path ([System.IO.Path]::GetTempPath()) `
            ('FFR' + [Guid]::NewGuid().ToString('N'))
        [void][System.IO.Directory]::CreateDirectory($tempDirectory)
        try {
            & $script:RarPath e -y -inul -p- $ArchiveFile $name `
                ($tempDirectory + '\') | Out-Null
            if ($LASTEXITCODE -ne 0) { continue }
            $extractedFile = Get-ChildItem -LiteralPath $tempDirectory -Force |
                Where-Object { -not $_.PSIsContainer } | Select-Object -First 1
            if ($extractedFile -eq $null) { continue }
            [Int64]$size = $extractedFile.Length
            if ($size -gt $script:MaximumMemberBytes -or
                ($script:ExpandedBytes + $size) -gt
                    $script:MaximumExpandedBytes) { continue }

            $script:ExpandedBytes += $size
            $nestedStream = $null
            try {
                $nestedStream = [System.IO.File]::OpenRead($extractedFile.FullName)
                Read-Archive $nestedStream $name ($displayName + '::') `
                    ($Depth + 1) $true
            }
            finally {
                if ($nestedStream -ne $null) { $nestedStream.Dispose() }
            }
        }
        catch { }
        finally {
            Remove-Item -LiteralPath $tempDirectory -Recurse -Force `
                -ErrorAction SilentlyContinue
        }
    }
}

function Read-RarStream {
    param([System.IO.Stream]$Stream, [string]$Prefix,
          [int]$Depth, [bool]$EmitEntries)

    if ($script:RarPath -eq '' -and $script:SevenZipPath -eq '') { return }
    $tempArchive = [System.IO.Path]::GetTempFileName()
    $tempStream = $null
    try {
        $tempStream = [System.IO.File]::Create($tempArchive)
        $Stream.CopyTo($tempStream)
        $tempStream.Dispose()
        $tempStream = $null
        Read-RarFile $tempArchive $Prefix $Depth $EmitEntries
    }
    finally {
        if ($tempStream -ne $null) { $tempStream.Dispose() }
        Remove-Item -LiteralPath $tempArchive -Force -ErrorAction SilentlyContinue
    }
}

function Read-Archive {
    param([System.IO.Stream]$Stream, [string]$Name, [string]$Prefix,
          [int]$Depth, [bool]$EmitEntries)
    if ($Depth -gt $script:MaximumDepth) { return }
    $kind = Get-ArchiveKind $Name
    if ($kind -eq 'zip') {
        Read-ZipArchive $Stream $Prefix $Depth $EmitEntries
    }
    elseif ($kind -eq 'tar') {
        Read-TarArchive $Stream $Prefix $Depth $EmitEntries
    }
    elseif ($kind -eq 'tgz') {
        $gzip = New-Object System.IO.Compression.GZipStream(
            $Stream, [System.IO.Compression.CompressionMode]::Decompress, $true)
        try { Read-TarArchive $gzip $Prefix $Depth $EmitEntries }
        finally { $gzip.Dispose() }
    }
    elseif ($kind -eq 'sevenzip') {
        Read-SevenZipStream $Stream $Prefix $Depth $EmitEntries
    }
    elseif ($kind -eq 'rar') {
        Read-RarStream $Stream $Prefix $Depth $EmitEntries
    }
}

$fileStream = $null
try {
    $rootKind = Get-ArchiveKind $ArchivePath
    if ($rootKind -eq 'sevenzip') {
        Read-SevenZipFile $ArchivePath '' 0 $true
    }
    elseif ($rootKind -eq 'rar') {
        Read-RarFile $ArchivePath '' 0 $true
    }
    else {
        $fileStream = [System.IO.File]::OpenRead($ArchivePath)
        $emitRootEntries = ($rootKind -eq 'tar' -or $rootKind -eq 'tgz')
        Read-Archive $fileStream $ArchivePath '' 0 $emitRootEntries
    }
}
finally {
    if ($fileStream -ne $null) { $fileStream.Dispose() }
    $writer.Dispose()
}
