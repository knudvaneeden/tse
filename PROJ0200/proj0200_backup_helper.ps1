# PROJ0200 1.0.0.0.151 - OpenAI Codex (GPT-6)
param([string]$Request,[string]$Settings,[string]$Log,[string]$Status)
$ErrorActionPreference='Stop'
$writer=New-Object IO.StreamWriter($Log,$false,[Text.Encoding]::Default)
$work=''
try {
    $config=@{}
    foreach ($line in [IO.File]::ReadAllLines($Settings,[Text.Encoding]::Default)) {
        $parts=$line -split '=',2
        if ($parts.Length -eq 2) { $config[$parts[0]]=$parts[1] }
    }
    $destinations=@()
    $seen=New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    foreach ($entry in ($config['backupdirectories'] -split ';')) {
        $directory=[Environment]::ExpandEnvironmentVariables($entry.Trim().Trim('"'))
        if (-not $directory) { continue }
        if (-not [IO.Path]::IsPathRooted($directory)) { $directory=Join-Path $PSScriptRoot $directory }
        $directory=[IO.Path]::GetFullPath($directory)
        if ($seen.Add($directory.TrimEnd('\'))) { $destinations += $directory }
    }
    if (-not $destinations.Count) { throw 'No backup destination directories were supplied.' }
    $zipMode=$config['backupzip'] -eq 'true'
    $zipExe=''
    $template=$config['backupzipcommand']
    if ($zipMode) {
        $zipExe=[Environment]::ExpandEnvironmentVariables($config['backupzipexe'])
        if (-not $zipExe) { throw 'Set backupzipexe in proj0200.ini before ZIP backups.' }
        if (-not [IO.Path]::IsPathRooted($zipExe) -and (Test-Path -LiteralPath (Join-Path $PSScriptRoot $zipExe))) { $zipExe=Join-Path $PSScriptRoot $zipExe }
        $zipExe=(Get-Command $zipExe -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source
        foreach ($placeholder in @('{exe}','{archive}','{source}')) {
            if (-not $template.Contains($placeholder)) { throw ('backupzipcommand must contain ' + $placeholder) }
        }
    }
    $records=[IO.File]::ReadAllLines($Request,[Text.Encoding]::Default)
    $items=@()
    $sources=New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    for ($i=0;$i -lt $records.Length;$i++) {
        if (-not $records[$i].StartsWith('S')) { continue }
        $source=[IO.Path]::GetFullPath($records[$i].Substring(1))
        $inputFile=$source
        if ($i+1 -lt $records.Length -and $records[$i+1].StartsWith('B')) { $inputFile=$records[++$i].Substring(1) }
        # Project directories can include our own changing control files.
        # Limit exclusions to generated files beside this installed helper.
        $sourceDirectory=[IO.Path]::GetDirectoryName($source).TrimEnd('\')
        $installedDirectory=[IO.Path]::GetFullPath($PSScriptRoot).TrimEnd('\')
        $sourceName=[IO.Path]::GetFileName($source)
        $generated=($sourceName -match '^proj0200_(backup|scope)_(log|status|request|settings|manifest|targets|message)\.txt$') -or
                   ($sourceName -match '^proj0200_(backup|scope)_(run|cleanup)\.bat$') -or
                   ($sourceName -match '^proj0200_backup_snapshot_[0-9]+_[0-9]+\.tmp$')
        if ($sourceDirectory -ieq $installedDirectory -and $generated) {
            $writer.WriteLine('Skipped generated backup/scope control file: ' + $source)
            continue
        }
        if (-not (Test-Path -LiteralPath $inputFile -PathType Leaf)) { throw ('Missing backup source: ' + $source) }
        if (-not $sources.Add($source)) { continue }
        # Distinct drives/directories remain distinct, even for equal basenames.
        if ($source.StartsWith('\\')) { $relative='UNC\' + $source.TrimStart('\') }
        else { $relative=$source.Replace(':','').TrimStart('\') }
        $items += [pscustomobject]@{Source=$source;Input=$inputFile;Relative=$relative}
    }
    if (-not $items.Count) { throw 'No files to back up.' }
    $identifier=[Guid]::NewGuid().ToString('N')
    $scopeName=@{'1'='current_file';'2'='current_project';'3'='all_projects'}[$config['scope']]
    if (-not $scopeName) { $scopeName='projects' }
    $runName='PROJ0200_' + $scopeName + '_' + (Get-Date -Format 'yyyyMMdd_HHmmss') + '_' + $identifier.Substring(0,8)
    $work=Join-Path ([IO.Path]::GetTempPath()) ('proj0200_backup_' + $identifier)
    $stage=Join-Path $work 'files'
    [IO.Directory]::CreateDirectory($stage) | Out-Null
    foreach ($item in $items) {
        $target=Join-Path $stage $item.Relative
        [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($target)) | Out-Null
        [IO.File]::Copy($item.Input,$target,$false)
        $writer.WriteLine('Staged: ' + $item.Source + ' -> ' + $item.Relative)
    }
    $archive=Join-Path $work ($runName + '.zip')
    if ($zipMode) {
        $batch=Join-Path $work 'zip.bat'
        $command=$template.Replace('{exe}',$zipExe).Replace('{archive}',$archive).Replace('{source}',$stage)
        $writer.WriteLine('ZIP command: ' + $command)
        [IO.File]::WriteAllText($batch,"@echo off`r`n" + $command + "`r`nexit /b %errorlevel%`r`n",[Text.Encoding]::Default)
        $start=New-Object Diagnostics.ProcessStartInfo
        $start.FileName=$env:ComSpec
        $start.Arguments='/d /s /c ""' + $batch + '""'
        $start.UseShellExecute=$false
        $start.CreateNoWindow=$true
        $start.RedirectStandardOutput=$true
        $start.RedirectStandardError=$true
        $process=[Diagnostics.Process]::Start($start)
        $stdout=$process.StandardOutput.ReadToEndAsync()
        $stderr=$process.StandardError.ReadToEndAsync()
        $process.WaitForExit()
        $writer.WriteLine($stdout.Result)
        $writer.WriteLine($stderr.Result)
        $code=$process.ExitCode
        $process.Dispose()
        if ($code -ne 0) { throw ('ZIP command failed, exit ' + $code + '. No destination backup was written.') }
        if (-not (Test-Path -LiteralPath $archive -PathType Leaf)) { throw 'ZIP command produced no archive at {archive}.' }
        # Refuse an unreadable or incomplete archive before distributing it.
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $zip=[IO.Compression.ZipFile]::OpenRead($archive)
        try {
            $names=New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
            foreach ($entry in $zip.Entries) { $null=$names.Add($entry.FullName.Replace('/','\')) }
            foreach ($item in $items) {
                if (-not $names.Contains($item.Relative)) { throw ('ZIP archive is missing: ' + $item.Relative + '. Adjust backupzipcommand to store the contents of {source}.') }
            }
        } finally { $zip.Dispose() }
    }
    $success=0
    $failures=0
    foreach ($destination in $destinations) {
        try {
            [IO.Directory]::CreateDirectory($destination) | Out-Null
            if ($zipMode) {
                $target=Join-Path $destination ($runName + '.zip')
                [IO.File]::Copy($archive,$target,$false)
            } else {
                $target=Join-Path $destination $runName
                [IO.Directory]::CreateDirectory($target) | Out-Null
                foreach ($item in $items) {
                    $copy=Join-Path $target $item.Relative
                    [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($copy)) | Out-Null
                    [IO.File]::Copy((Join-Path $stage $item.Relative),$copy,$false)
                }
            }
            $writer.WriteLine('BACKUP OK: ' + $target)
            $success++
        } catch {
            $writer.WriteLine('BACKUP FAILED: ' + $destination + ': ' + $_.Exception.Message)
            $failures++
        }
    }
    $prefix='OK: '
    if ($failures) { $prefix='WARNING: ' }
    [IO.File]::WriteAllText($Status,($prefix + $items.Count + ' file(s); ' + $success + ' destination(s) completed; ' + $failures + ' failed.'),[Text.Encoding]::Default)
} catch {
    $writer.WriteLine($_.Exception.Message)
    [IO.File]::WriteAllText($Status,('ERROR: ' + $_.Exception.Message),[Text.Encoding]::Default)
    exit 1
} finally {
    if ($work -and (Test-Path -LiteralPath $work)) { Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue }
    $writer.Dispose()
}
