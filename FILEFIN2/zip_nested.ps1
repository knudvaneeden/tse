param(
    [Parameter(Mandatory = $true)][string]$ArchivePath,
    [Parameter(Mandatory = $true)][string]$OutputPath
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression

$writer = New-Object System.IO.StreamWriter(
    $OutputPath, $false, [System.Text.Encoding]::Default)
$script:ExpandedBytes = 0

function Write-NestedEntries {
    param(
        [System.IO.Stream]$Stream,
        [string]$Prefix,
        [int]$Depth
    )

    if ($Depth -gt 8) {
        return
    }

    $archive = New-Object System.IO.Compression.ZipArchive(
        $Stream, [System.IO.Compression.ZipArchiveMode]::Read, $true)
    try {
        foreach ($entry in $archive.Entries) {
            if ([string]::IsNullOrEmpty($entry.Name)) {
                continue
            }

            $displayName = $Prefix + $entry.FullName
            if ($Depth -gt 0) {
                $size = $entry.Length
                if ($size -gt 2147483647) {
                    $size = 2147483647
                }
                $dateS = $entry.LastWriteTime.DateTime.ToString('MM/dd/yy')
                $timeS = $entry.LastWriteTime.DateTime.ToString('HH:mm:ss')
                $writer.WriteLine("{0}`t{1}`t{2}`t{3}",
                    $size, $dateS, $timeS, $displayName)
            }

            if ($Depth -lt 8 -and
                $entry.Name.EndsWith('.zip',
                    [System.StringComparison]::OrdinalIgnoreCase) -and
                $entry.Length -le 268435456 -and
                ($script:ExpandedBytes + $entry.Length) -le 536870912) {
                $memory = New-Object System.IO.MemoryStream
                $entryStream = $null
                try {
                    $script:ExpandedBytes += $entry.Length
                    $entryStream = $entry.Open()
                    $entryStream.CopyTo($memory)
                    $memory.Position = 0
                    Write-NestedEntries -Stream $memory `
                        -Prefix ($displayName + '::') -Depth ($Depth + 1)
                }
                catch {
                    # Ignore a member named .zip that is not a readable ZIP.
                }
                finally {
                    if ($entryStream -ne $null) {
                        $entryStream.Dispose()
                    }
                    $memory.Dispose()
                }
            }
        }
    }
    finally {
        $archive.Dispose()
    }
}

$fileStream = $null
try {
    $fileStream = [System.IO.File]::OpenRead($ArchivePath)
    Write-NestedEntries -Stream $fileStream -Prefix '' -Depth 0
}
finally {
    if ($fileStream -ne $null) {
        $fileStream.Dispose()
    }
    $writer.Dispose()
}
