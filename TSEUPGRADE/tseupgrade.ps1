# TSEUPGRADE version 1.0.0.0.53
# Created: 2026-10-31 18:43:55
# Windows PowerShell 5.1; built-in .NET ZIP extraction. No third-party utilities.
param([switch]$ValidateOnly)

$ErrorActionPreference = 'Stop'
$script:upgradeStartedAt = Get-Date
$script:upgradeWatch = [Diagnostics.Stopwatch]::StartNew()
$script:upgradeResult = 'STOPPED'
$base = $PSScriptRoot
$ini = Join-Path $base 'tseupgrade.ini'
$settings = @{}
$section = ''
$script:logPath = ''
$script:logSetupError = ''
$script:unattended = $false
$script:batchCompileFailures = 0
$script:compilerTimingLog = ''
$script:compilerInvocationId = 0
$script:lastCompilerExit = $null
$script:copyDisplay = 'none'
$script:copyEta = $true
function Format-UpgradeLogRecord([string]$message, [string]$level = 'INFO', [string]$type = 'UPGRADE') {
    if ($message -match '^ERROR:\s*') { $level = 'ERROR'; $message = $message -replace '^ERROR:\s*','' }
    elseif ($message -match '^(WARNING|WARN):\s*') { $level = 'WARN'; $message = $message -replace '^(WARNING|WARN):\s*','' }
    elseif ($message -match '^INFO:\s*') { $message = $message -replace '^INFO:\s*','' }
    elseif ($message -match '^\s*(Error\s+\d+|Fatal\b|Compilation\s+failed\b)') { $level = 'ERROR' }
    elseif ($message -match '^\s*Warning\b') { $level = 'WARN' }
    return ('{0:yyyy-MM-dd HH:mm:ss} {1} [{2}] {3}' -f (Get-Date), $level, $type, $message)
}
function Write-UpgradeLog {
    param([Parameter(Position=0)][object]$Object = '', [ConsoleColor]$ForegroundColor,
        [ValidateSet('ERROR','WARN','INFO')][string]$Level = 'INFO', [string]$Type = 'UPGRADE')
    if ($PSBoundParameters.ContainsKey('ForegroundColor')) {
        if ($ForegroundColor -eq [ConsoleColor]::Red) { $Level = 'ERROR' }
        elseif ($ForegroundColor -eq [ConsoleColor]::Yellow) { $Level = 'WARN' }
    }
    foreach ($line in ([string]$Object -split '\r?\n')) {
        if (-not $line) { continue }
        $record = Format-UpgradeLogRecord $line $Level $Type
        if ($PSBoundParameters.ContainsKey('ForegroundColor')) {
            Microsoft.PowerShell.Utility\Write-Host $record -ForegroundColor $ForegroundColor
        } else { Microsoft.PowerShell.Utility\Write-Host $record }
        if ($script:logPath) {
            try { [IO.File]::AppendAllText($script:logPath, $record + "`r`n", [Text.Encoding]::ASCII) }
            catch {
                Microsoft.PowerShell.Utility\Write-Host (Format-UpgradeLogRecord ("Log write failed: {0}; {1}" -f $script:logPath,$_.Exception.Message) 'ERROR' 'LOG') -ForegroundColor Red
                $script:logPath = ''
            }
        }
    }
}
function Initialize-UpgradeLog {
    $name = 'tseupgrade_{0}_{1}.log' -f (Get-Date -Format 'yyyyMMdd_HHmmss'), [guid]::NewGuid().ToString('N').Substring(0,8)
    $path = Join-Path $base $name
    try { [IO.File]::WriteAllText($path, '', [Text.Encoding]::ASCII) }
    catch {
        $path = Join-Path ([IO.Path]::GetTempPath()) $name
        [IO.File]::WriteAllText($path, '', [Text.Encoding]::ASCII)
    }
    $script:logPath = $path
    Write-UpgradeLog 'TSEUPGRADE 1.0.0.0.53 started; logging precedes INI validation.' -Type 'START'
    Write-UpgradeLog "Main log: $script:logPath" -Type 'LOG'
}
function Select-ConfiguredUpgradeLog {
    if (-not (Value 'log_file')) { return }
    try {
        $requested = Resolve-Setting (Value 'log_file')
        Reject-Links $requested
        if ($requested -ieq $script:logPath) { return }
        if (Value 'old_directory') {
            $oldLogRoot = (Resolve-Setting (Value 'old_directory')).TrimEnd('\') + '\'
            if ($requested.StartsWith($oldLogRoot,[StringComparison]::OrdinalIgnoreCase)) { throw 'Log cannot be inside the OLD installation.' }
        }
        $protected = @($ini, $PSCommandPath)
        foreach ($key in @('ui_file','cfg_file','cuamark_file','old_compile_data')) {
            if (Value $key) { $protected += Resolve-Setting (Value $key) }
        }
        if ($protected -icontains $requested) { throw 'Log would overwrite a source file.' }
        # Copy the early messages and use CreateNew semantics; never overwrite a log.
        $earlyLog = $script:logPath
        [IO.File]::Copy($earlyLog, $requested, $false)
        $script:logPath = $requested
        Write-UpgradeLog "Main log: $requested (early startup messages copied from $earlyLog)" -Type 'LOG'
    } catch {
        $script:logSetupError = $_.Exception.Message
        Write-UpgradeLog ("log_file: {0}; retaining early main log: {1}" -f $script:logSetupError,$script:logPath) -Level 'ERROR' -Type 'INI'
    }
}
function Value([string]$name) {
    if ($settings.ContainsKey($name)) { return $settings[$name] }
    return ''
}
function Resolve-Setting([string]$value, [string]$root = $base) {
    if (-not $value) { return '' }
    $value = [Environment]::ExpandEnvironmentVariables($value)
    if (-not [IO.Path]::IsPathRooted($value)) { $value = Join-Path $root $value }
    return [IO.Path]::GetFullPath($value)
}
$script:consoleWindow = [IntPtr]::Zero
function Initialize-ConsoleFocus {
    try {
        if (-not ('TseUpgradeFocus' -as [type])) {
            Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class TseUpgradeFocus {
 [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
 [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr window);
 [DllImport("user32.dll")] public static extern bool IsWindow(IntPtr window);
 [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
 [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr window, IntPtr processId);
 [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint source, uint target, bool attach);
 [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr window);
 [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr window);
 [DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr window, int command);
}
'@
        }
    } catch { Write-UpgradeLog 'Console focus control unavailable; use Alt+Tab if needed.' }
}
function Restore-ConsoleFocus {
    if (('TseUpgradeFocus' -as [type]) -and $script:consoleWindow -ne [IntPtr]::Zero) {
        if ([TseUpgradeFocus]::IsWindow($script:consoleWindow)) {
            if ([TseUpgradeFocus]::IsIconic($script:consoleWindow)) {
                [void][TseUpgradeFocus]::ShowWindowAsync($script:consoleWindow, 9)
            }
            $foreground = [TseUpgradeFocus]::GetForegroundWindow()
            if ($foreground -eq $script:consoleWindow) { return }
            $currentThread = [TseUpgradeFocus]::GetCurrentThreadId()
            $foregroundThread = [TseUpgradeFocus]::GetWindowThreadProcessId($foreground, [IntPtr]::Zero)
            $attached = $false
            try {
                if ($foregroundThread -ne 0 -and $foregroundThread -ne $currentThread) {
                    $attached = [TseUpgradeFocus]::AttachThreadInput($currentThread, $foregroundThread, $true)
                }
                [void][TseUpgradeFocus]::BringWindowToTop($script:consoleWindow)
                [void][TseUpgradeFocus]::SetForegroundWindow($script:consoleWindow)
            } finally {
                if ($attached) { [void][TseUpgradeFocus]::AttachThreadInput($currentThread, $foregroundThread, $false) }
            }
        }
    }
}
function Confirm-Step([string]$text) {
    while ($true) {
        Restore-ConsoleFocus
        Write-UpgradeLog ''
        Write-UpgradeLog ("TSE upgrade: {0} -> {1}" -f $script:oldVersion, $script:newVersion)
        Write-UpgradeLog $text
        if ($script:unattended) {
            Write-UpgradeLog 'AUTO YES (unattended=true)'
            return $true
        }
        $reply = Read-Host 'Proceed? Enter=Yes, y=Yes, n=No [Y/n]'
        # Capture the actual window accepting input, including Windows Terminal hosts.
        if ('TseUpgradeFocus' -as [type]) { $script:consoleWindow = [TseUpgradeFocus]::GetForegroundWindow() }
        Restore-ConsoleFocus
        Write-UpgradeLog ("Confirmation answer: [{0}]" -f $reply) -Type INPUT
        if ($reply -eq '' -or $reply -ieq 'y') { return $true }
        if ($reply -ieq 'n') { return $false }
        Write-UpgradeLog 'Invalid answer. Press Enter for Yes, or enter only y or n.' -ForegroundColor Yellow
    }
}
function Required([string]$key, [string]$prompt) {
    $v = Value $key
    if (-not $v -and -not $script:unattended) { $v = Read-Host $prompt }
    if (-not $v) { throw "Required setting is blank: $key" }
    return $v
}
function Require-File([string]$path) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "File not found: $path" }
}
function Reject-Links([string]$path) {
    $cursor = $path
    while ($cursor) {
        if (Test-Path -LiteralPath $cursor) {
            if ((Get-Item -LiteralPath $cursor -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) {
                throw "Junction/symbolic-link path is not allowed: $cursor"
            }
        }
        $parent = Split-Path -Parent $cursor
        if ($parent -eq $cursor) { break }
        $cursor = $parent
    }
}
function New-Output([string]$path) {
    $full = [IO.Path]::GetFullPath($path)
    if (($full.TrimEnd('\') + '\') -ne $script:newPrefix -and -not $full.StartsWith($script:newPrefix,[StringComparison]::OrdinalIgnoreCase)) {
        throw "Output must be inside the NEW installation: $full"
    }
    Reject-Links $full
    return $full
}
function Personal-Output([string]$path, [string]$source) {
    $full = [IO.Path]::GetFullPath($path)
    if (($full.TrimEnd('\') + '\').StartsWith($script:oldPrefix,[StringComparison]::OrdinalIgnoreCase)) {
        throw "Personal output cannot be inside the OLD installation: $full"
    }
    if ($full -eq [IO.Path]::GetFullPath($source)) { throw "Old and new personal filenames must differ: $full" }
    foreach ($protected in $script:protectedSources) {
        if ($full -eq $protected) { throw "Output would overwrite an old personal source: $full" }
    }
    Reject-Links $full
    if (-not (Test-Path -LiteralPath (Split-Path -Parent $full) -PathType Container)) { throw "Output parent does not exist: $full" }
    if (Test-Path -LiteralPath $full) { Require-File $full }
    # Existing NEW personal outputs are allowed; back up only after confirmation.
    return $full
}
function Backup-PersonalOutput([string]$path) {
    if (-not (Test-Path -LiteralPath $path)) { return }
    Require-File $path
    Reject-Links $path
    $backup = $path + '.before_upgrade_' + [guid]::NewGuid().ToString('N').Substring(0,12) + '.bak'
    Reject-Links $backup
    # No overwrite: preserve the existing NEW output before replacing it.
    [IO.File]::Move($path, $backup)
    Write-UpgradeLog "Existing NEW personal output backed up: $path -> $backup"
}
function Get-SourceEntries([string]$root, [bool]$recursive = $true) {
    Reject-Links $root
    # Walk one directory at a time. Never hand a link to a recursive enumerator.
    $pending = New-Object 'System.Collections.Generic.Stack[string]'
    $pending.Push($root)
    $scanTimer = [Diagnostics.Stopwatch]::StartNew()
    $lastScanUpdate = [long]0
    $scanned = 0
    $skippedLinks = 0
    while ($pending.Count -gt 0) {
        $current = $pending.Pop()
        Reject-Links $current
        foreach ($entry in Get-ChildItem -LiteralPath $current -Force) {
            $scanned++
            if ($script:copyDisplay -ne 'none' -and $scanTimer.ElapsedMilliseconds - $lastScanUpdate -ge 1000) {
                Write-UpgradeLog "Scanned $scanned entries..."
                $lastScanUpdate = $scanTimer.ElapsedMilliseconds
            }
            if ($entry.Attributes -band [IO.FileAttributes]::ReparsePoint) {
                $skippedLinks++
                if ($script:copyDisplay -ne 'none') { Write-UpgradeLog "SKIP linked file/directory: $($entry.FullName)" }
                continue
            }
            Write-Output $entry
            if ($recursive -and $entry.PSIsContainer) { $pending.Push($entry.FullName) }
        }
    }
    if ($script:copyDisplay -ne 'none') { Write-UpgradeLog "Scan finished: $scanned entries inspected; $skippedLinks links skipped." }
}
function Copy-Sources([string]$source, [string]$destination) {
    Reject-Links $source
    $destination = New-Output $destination
    $srcPrefix = [IO.Path]::GetFullPath($source).TrimEnd('\') + '\'
    if ($destination.StartsWith($srcPrefix,[StringComparison]::OrdinalIgnoreCase)) {
        throw 'Source staging directory cannot be inside its source directory.'
    }
    Restore-ConsoleFocus
    if ($script:copyEta) {
        Write-UpgradeLog 'Copying has started. Please be patient... An initial time estimate will follow after scanning and a short copy sample.'
    } else { Write-UpgradeLog 'Copying has started. Please be patient...' }
    if ($script:copyDisplay -ne 'none') { Write-UpgradeLog "Scanning source: $source" }
    if ($script:copyDisplay -ne 'none') { Write-UpgradeLog "Copy destination: $destination" }
    # Capture only ordinary entries; linked entries are reported and omitted.
    $entries = @(Get-SourceEntries $source)
    $files = @($entries | Where-Object { -not $_.PSIsContainer })
    $directories = @($entries | Where-Object { $_.PSIsContainer } | Sort-Object { $_.FullName.Length })
    $total = $files.Count
    $totalBytes = [double](($files | Measure-Object -Property Length -Sum).Sum)
    if ($script:copyDisplay -ne 'none') { Write-UpgradeLog "Scan complete: $total files, $($directories.Count) directories." }
    New-Item -ItemType Directory -Path $destination -Force | Out-Null
    $directoryTimer = [Diagnostics.Stopwatch]::StartNew()
    $lastDirectoryUpdate = [long]0
    $directoriesReady = 0
    foreach ($directory in $directories) {
        $relative = $directory.FullName.Substring($srcPrefix.Length)
        $target = New-Output (Join-Path $destination $relative)
        try {
            New-Item -ItemType Directory -Path $target -Force | Out-Null
        } catch { throw "Could not prepare directory [$target]: $($_.Exception.Message)" }
        $directoriesReady++
        if ($script:copyDisplay -eq 'all') { Write-UpgradeLog "Directory: $relative" }
        if ($script:copyDisplay -eq 'summary' -and $directoryTimer.ElapsedMilliseconds - $lastDirectoryUpdate -ge 1000) {
            Write-UpgradeLog "Directories ready: $directoriesReady/$($directories.Count)"
            $lastDirectoryUpdate = $directoryTimer.ElapsedMilliseconds
        }
    }
    $copied = 0
    $bytesCopied = [long]0
    $timer = [Diagnostics.Stopwatch]::StartNew()
    $lastCopyUpdate = [long]0
    $etaShown = $false
    if ($script:copyDisplay -ne 'none') { Write-UpgradeLog "Copying: 0/$total files..." }
    try {
        foreach ($file in $files) {
            $relative = $file.FullName.Substring($srcPrefix.Length)
            $target = New-Output (Join-Path $destination $relative)
            if ($script:copyDisplay -eq 'all') { Write-UpgradeLog ("Copy [{0}/{1}]: {2}" -f ($copied + 1), $total, $relative) }
            try {
                Copy-Item -LiteralPath $file.FullName -Destination $target -Force
            } catch {
                throw "Copy failed: [$($file.FullName)] -> [$target]: $($_.Exception.Message)"
            }
            $copied++
            $bytesCopied += $file.Length
            if ($script:copyEta -and -not $etaShown -and $timer.Elapsed.TotalSeconds -ge 3 -and $copied -ge 5 -and $copied -lt $total) {
                # One early estimate; no recurring progress display.
                $remaining = $timer.Elapsed.TotalSeconds * ($total - $copied) / $copied
                if ($bytesCopied -gt 0) {
                    $byteRemaining = $timer.Elapsed.TotalSeconds * [Math]::Max(0, $totalBytes - $bytesCopied) / $bytesCopied
                    $remaining = [Math]::Max($remaining, $byteRemaining)
                }
                $span = [TimeSpan]::FromSeconds([Math]::Min([int]::MaxValue, [Math]::Ceiling($remaining)))
                Write-UpgradeLog ("Estimated copying time remaining: approximately {0:00}:{1:00}:{2:00} (hours:minutes:seconds). Please be patient..." -f [int][Math]::Floor($span.TotalHours), $span.Minutes, $span.Seconds)
                $etaShown = $true
            }
            if ($script:copyDisplay -eq 'summary' -and $timer.ElapsedMilliseconds - $lastCopyUpdate -ge 1000) {
                $percent = [int](100 * $copied / $total)
                $status = "{0}/{1} files ({2}%), {3:N2} MB, {4:N1} seconds" -f $copied, $total, $percent, ($bytesCopied / 1MB), $timer.Elapsed.TotalSeconds
                Write-UpgradeLog "Copying: $status"
                if ($script:copyDisplay -eq 'summary') { Write-Progress -Id 1 -Activity 'Copying TSE files' -Status $status -PercentComplete $percent }
                $lastCopyUpdate = $timer.ElapsedMilliseconds
            }
        }
        $timer.Stop()
        if ($script:copyDisplay -ne 'none') { Write-UpgradeLog ("Copy complete: {0}/{1} files, {2:N2} MB, {3:N1} seconds." -f $copied, $total, ($bytesCopied / 1MB), $timer.Elapsed.TotalSeconds) }
    } finally {
        if ($script:copyDisplay -eq 'summary') { Write-Progress -Id 1 -Activity 'Copying TSE files' -Completed }
    }
    return $destination
}
function Invoke-CompilerCore([string[]]$arguments, [string]$directory) {
    Require-File $script:compiler
    Push-Location -LiteralPath $directory
    try {
        # Preserve visible output while retaining evidence for successful nonzero results.
        $hasErrors = $false
        $confirmedSuccess = $false
        & $script:compiler @arguments | ForEach-Object {
            $line = [string]$_
            Write-UpgradeLog $line -Type SC32
            if ($line -match '(?i)^\s*(?:Error(?:\s+\d+|\s*:)|Fatal\b|Compilation\s+failed\b)') { $hasErrors = $true }
            if ($line -match '(?i)^\s*(?:Installation successful!|Writing output to file\s)') { $confirmedSuccess = $true }
        }
        $compilerExit = $LASTEXITCODE
        $script:lastCompilerExit = $compilerExit
        if ($hasErrors) { throw "Compiler reported errors (exit $compilerExit)." }
        if ($compilerExit -ne 0) {
            if ($compilerExit -eq 1 -and $confirmedSuccess) {
                Write-UpgradeLog 'Compiler confirmed successful completion (exit 1). Continuing upgrade.'
            } else {
                throw "Compiler failed or success was not confirmed (exit $compilerExit)."
            }
        }
    } finally { Pop-Location }
}
function Write-CompilerTiming([object[]]$fields) {
    # AppendAllText closes/flushed the file on each event, independently of transcript buffering.
    $cleanFields = @($fields | ForEach-Object {
        ([string]$_).Replace("`t", '\t').Replace("`r", '\r').Replace("`n", '\n')
    })
    [IO.File]::AppendAllText($script:compilerTimingLog, ($cleanFields -join "`t") + "`r`n", [Text.Encoding]::ASCII)
}
function Run-Compiler([string[]]$arguments, [string]$directory) {
    $script:compilerInvocationId++
    $invocationId = $script:compilerInvocationId
    $compilerPath = $script:compiler
    $script:lastCompilerExit = $null
    $argumentText = ConvertTo-Json -InputObject @($arguments) -Compress
    $commandText = '"' + $compilerPath + '" ' + (($arguments | ForEach-Object { '"' + $_ + '"' }) -join ' ')
    $startedAt = Get-Date
    $watch = [Diagnostics.Stopwatch]::StartNew()
    $result = 'FAILED'
    $detail = ''
    # START is committed before file validation or launching sc32.
    Write-CompilerTiming @($startedAt.ToString('yyyy-MM-dd HH:mm:ss.fff'), $invocationId, 'START', '', '', 'RUNNING', $compilerPath, $directory, $argumentText, '')
    Write-UpgradeLog ("SC32 START [{0}] {1:yyyy-MM-dd HH:mm:ss.fff}; command: {2}; working directory: {3}" -f $invocationId, $startedAt, $commandText, $directory)
    try {
        Invoke-CompilerCore $arguments $directory
        $result = 'SUCCESS'
    } catch {
        $detail = $_.Exception.Message
        throw
    } finally {
        $watch.Stop()
        $finishedAt = Get-Date
        $elapsedSeconds = $watch.Elapsed.TotalSeconds.ToString('F3', [Globalization.CultureInfo]::InvariantCulture)
        Write-CompilerTiming @($finishedAt.ToString('yyyy-MM-dd HH:mm:ss.fff'), $invocationId, 'END', $elapsedSeconds, $script:lastCompilerExit, $result, $compilerPath, $directory, $argumentText, $detail)
        Write-UpgradeLog ("SC32 END [{0}] {1:yyyy-MM-dd HH:mm:ss.fff}; elapsed={2}s; exit={3}; result={4}" -f $invocationId, $finishedAt, $elapsedSeconds, $script:lastCompilerExit, $result)
        if ($watch.Elapsed.TotalSeconds -ge 10) {
            Write-UpgradeLog ("SC32 SLOW [{0}]: {1}s; {2}" -f $invocationId, $elapsedSeconds, $commandText) -ForegroundColor Yellow
        }
    }
}
function New-HelperStartInfo([string]$executable, [string]$macro, [string]$directory) {
    # Use Microsoft's command processor explicitly, never a TCC COMSPEC alias.
    $commandProcessor = Join-Path $env:SystemRoot 'System32\cmd.exe'
    Require-File $commandProcessor
    foreach ($path in @($executable, $macro, $directory)) {
        [void](Sal-Literal $path)
        if ($path.Contains('%')) { throw 'Helper launch paths cannot contain percent signs (cmd.exe expands them).' }
    }
    # CMD treats the first quoted START argument as a title, hence the empty title.
    # -1- asks TSE itself not to hand this request to an existing editor.
    $command = 'start "" /wait /d "' + $directory.TrimEnd('\') + '" "' + $executable + '" -1- -e"' + $macro + '"'
    $info = New-Object System.Diagnostics.ProcessStartInfo
    $info.FileName = $commandProcessor
    $info.Arguments = '/d /v:off /s /c "' + $command + '"'
    $info.WorkingDirectory = $directory
    $info.UseShellExecute = $false
    Write-UpgradeLog ("HELPER START command: {0}" -f $command)
    Write-UpgradeLog ("HELPER shell command: `"{0}`" {1}" -f $info.FileName, $info.Arguments)
    return $info
}
function Suspend-NewAutoload([string]$action) {
    $autoloadPath = New-Output (Join-Path $new 'tseload.dat')
    if (-not (Test-Path -LiteralPath $autoloadPath)) {
        Write-UpgradeLog "$action AUTOLOAD: no NEW tseload.dat to suspend: $autoloadPath"
        return $null
    }
    Require-File $autoloadPath
    Reject-Links $autoloadPath
    $backupPath = New-Output ($autoloadPath + '.upgrade_autoload_' + [guid]::NewGuid().ToString('N').Substring(0,12) + '.bak')
    # Move without overwrite; touch only the NEW installation.
    [IO.File]::Move($autoloadPath, $backupPath)
    Write-UpgradeLog "$action AUTOLOAD suspended: $autoloadPath -> $backupPath"
    return @{Original=$autoloadPath; Backup=$backupPath; Action=$action}
}
function Restore-NewAutoload($state) {
    if ($null -eq $state) { return }
    Require-File $state.Backup
    [void](New-Output $state.Original)
    [void](New-Output $state.Backup)
    # Preserve a file recreated by the helper before restoring the original bytes.
    if (Test-Path -LiteralPath $state.Original) {
        Require-File $state.Original
        $generatedBackup = New-Output ($state.Original + '.helper_generated_' + [guid]::NewGuid().ToString('N').Substring(0,12) + '.bak')
        [IO.File]::Move($state.Original, $generatedBackup)
        Write-UpgradeLog "$($state.Action) AUTOLOAD preserved helper-created file: $generatedBackup"
    }
    try {
        [IO.File]::Move($state.Backup, $state.Original)
    } catch {
        throw "Could not restore NEW autoload file. Original remains at $($state.Backup). Restore it to $($state.Original) before normal use. $($_.Exception.Message)"
    }
    Write-UpgradeLog "$($state.Action) AUTOLOAD restored: $($state.Original)"
}
function Wait-GeneratedMacroLaunch([string]$macro, [string]$action) {
    $delaySeconds = 5
    $delaySetting = Value 'generated_macro_launch_delay_seconds'
    if ($delaySetting) {
        if (-not [int]::TryParse($delaySetting, [ref]$delaySeconds) -or $delaySeconds -lt 0 -or $delaySeconds -gt 300) {
            throw 'generated_macro_launch_delay_seconds must be an integer from 0 through 300.'
        }
    }
    Require-File $macro
    $compiledFile = Get-Item -LiteralPath $macro
    Write-UpgradeLog ("{0} pre-launch delay START: {1:yyyy-MM-dd HH:mm:ss.fff}; seconds={2}; macro={3}; bytes={4}; last-write={5:yyyy-MM-dd HH:mm:ss.fff}" -f $action, (Get-Date), $delaySeconds, $macro, $compiledFile.Length, $compiledFile.LastWriteTime)
    Write-UpgradeLog ("Waiting {0} seconds after compilation before launching g32.exe. Please be patient..." -f $delaySeconds)
    $delayWatch = [Diagnostics.Stopwatch]::StartNew()
    if ($delaySeconds -gt 0) { Start-Sleep -Seconds $delaySeconds }
    $delayWatch.Stop()
    Require-File $macro
    $compiledFile = Get-Item -LiteralPath $macro
    Write-UpgradeLog ("{0} pre-launch delay END: {1:yyyy-MM-dd HH:mm:ss.fff}; elapsed={2}; macro bytes={3}" -f $action, (Get-Date), $delayWatch.Elapsed, $compiledFile.Length)
}
function Enabled-Setting([string]$name) {
    $setting = Value $name
    if (-not $setting) { return $true }
    if (@('true','false') -notcontains $setting.ToLowerInvariant()) { throw "$name must be true or false." }
    return $setting -ieq 'true'
}
function Sal-Literal([string]$path) {
    if (-not $path -or $path.Contains('"') -or $path -match '[^\x20-\x7e]' -or $path.Length -gt 220) {
        throw 'Automatic SAL actions require nonempty ASCII paths without quotes, at most 220 characters.'
    }
    return '"' + $path + '"'
}
function Run-EditorAction([string]$moduleName, [string]$expression, [string[]]$before = @()) {
    $modulePath = Join-Path $base ($moduleName + '.s')
    Require-File $modulePath
    $actionId = [guid]::NewGuid().ToString('N').Substring(0,12)
    $source = New-Output (Join-Path $new ($moduleName + '_' + $actionId + '.s'))
    $macro = [IO.Path]::ChangeExtension($source, '.mac')
    $marker = [IO.Path]::ChangeExtension($source, '.result.ini')
    $markerLiteral = Sal-Literal $marker
    # Strip standalone entry only; retain the independent operation and helpers.
    $moduleText = [IO.File]::ReadAllText($modulePath, [Text.Encoding]::ASCII)
    $entryMatch = [regex]::Match($moduleText, '(?im)^PROC Main\(\)\s*$')
    if (-not $entryMatch.Success) { throw "Missing module entry: $modulePath" }
    $moduleText = $moduleText.Substring(0, $entryMatch.Index)
    $main = @('PROC Main()', ' INTEGER actionOk = FALSE')
    $main += (' WriteProfileStr("action", "saved", "false", {0})' -f $markerLiteral)
    $main += $before
    $main += (' actionOk = ' + $expression)
    $main += ' IF actionOk'
    $main += ('  WriteProfileStr("action", "saved", "true", {0})' -f $markerLiteral)
    $main += @(' ENDIF', ' Exit()', 'END')
    [IO.File]::WriteAllText($source, $moduleText + ($main -join "`r`n") + "`r`n", [Text.Encoding]::ASCII)
    Write-UpgradeLog "ACTION module: $moduleName; source: $source; confirmation: $marker"
    Run-Compiler @($source) $new
    Require-File $macro
    Wait-GeneratedMacroLaunch $macro ('ACTION ' + $moduleName)
    $startInfo = New-HelperStartInfo $editor ([IO.Path]::GetFullPath($macro)) $new
    Write-UpgradeLog ("ACTION operation: {0}; directory: {1}" -f $expression, $new)
    $actionWatch = [Diagnostics.Stopwatch]::StartNew()
    $actionAutoload = $null
    try {
        $actionAutoload = Suspend-NewAutoload ('ACTION ' + $moduleName)
        $process = [Diagnostics.Process]::Start($startInfo)
        $process.WaitForExit()
        $process.Refresh()
        Write-UpgradeLog ("ACTION START shell finished: PID={0}; exit={1}; elapsed={2}" -f $process.Id, $process.ExitCode, $actionWatch.Elapsed)
    } finally {
        try { Restore-NewAutoload $actionAutoload }
        finally { $actionWatch.Stop(); Restore-ConsoleFocus }
    }
    $confirmed = $false
    $poll = [Diagnostics.Stopwatch]::StartNew()
    do {
        if (Test-Path -LiteralPath $marker -PathType Leaf) {
            $confirmed = [IO.File]::ReadAllText($marker) -match '(?im)^\s*saved\s*=\s*true\s*$'
        }
        if ($confirmed -or $poll.Elapsed.TotalSeconds -ge $prepareWaitSeconds) { break }
        Start-Sleep -Milliseconds 250
    } while ($true)
    $poll.Stop()
    Write-UpgradeLog "ACTION result: $moduleName; saved=true confirmed=$confirmed; marker=$marker"
    if (-not $confirmed) { throw "Automatic action not confirmed: $moduleName. Inspect $marker and the log." }
}
function Show-CompilationEstimate([double]$seconds, [string]$basis) {
    $seconds = [Math]::Max(0,$seconds)
    $low = [Math]::Max(1,[Math]::Floor($seconds * 0.5))
    $high = [Math]::Max($low,[Math]::Ceiling($seconds * 2.0))
    $estimate = [TimeSpan]::FromSeconds([Math]::Min([int]::MaxValue,$seconds))
    Write-UpgradeLog ("SC32 rough compilation estimate: about {0} ({1:N0} seconds); broad range {2:N0}..{3:N0} seconds. Basis: {4}." -f $estimate.ToString('c'), $seconds, $low, $high, $basis)
    Write-UpgradeLog 'Macro complexity, includes, disk speed and compiler errors can change this substantially.'
}
function Compile-Directory([string]$directory, [bool]$recursive = $true) {
    if (-not (Test-Path -LiteralPath $directory -PathType Container)) { throw "Macro directory not found: $directory" }
    Write-UpgradeLog "Scanning macro sources: $directory (recursive=$recursive; extensions=.s,.si)"
    $files = @(Get-SourceEntries $directory $recursive | Where-Object {
        -not $_.PSIsContainer -and ($_.Extension -ieq '.s' -or $_.Extension -ieq '.si')
    })
    Require-File $script:compiler
    # Validate staged paths once before allowing native wildcard expansion.
    foreach ($file in $files) { [void](New-Output $file.FullName) }
    $groups = @($files | Group-Object DirectoryName | Sort-Object Name)
    $sCount = @($files | Where-Object { $_.Extension -ieq '.s' }).Count
    $siCount = $files.Count - $sCount
    Write-UpgradeLog "Found $($files.Count) sources: $sCount .s and $siCount .si in $($groups.Count) directories."
    $showCompileEta = (Value 'compileeta') -ine 'false'
    $historyPath = Join-Path $base 'tseupgrade_compile_history.tsv'
    $etaShown = $false
    if ($showCompileEta -and $files.Count -gt 0) {
        if (Test-Path -LiteralPath $historyPath -PathType Leaf) {
            try {
                $sample = Import-Csv -LiteralPath $historyPath -Delimiter "`t" | Where-Object {
                    $_.compiler -ieq $script:compiler -and $_.directory -ieq $directory -and
                    $_.result -eq 'SUCCESS' -and [int]$_.source_count -gt 0 -and [double]$_.elapsed_seconds -gt 0
                } | Select-Object -Last 1
                if ($sample) {
                    $estimateSeconds = [double]$sample.elapsed_seconds * $files.Count / [int]$sample.source_count
                    Show-CompilationEstimate $estimateSeconds 'last successful run in this directory, scaled by current source count'
                    $etaShown = $true
                }
            } catch { Write-UpgradeLog 'Compilation timing history unavailable/invalid; using this run instead.' -ForegroundColor Yellow }
        }
        if (-not $etaShown) { Write-UpgradeLog 'SC32 estimate: no usable history yet. A remaining-time estimate follows the first successful wildcard batch, if work remains.' }
    }
    $compileWatch = [Diagnostics.Stopwatch]::StartNew()
    $successfulSourceCount = 0
    $successfulSeconds = 0.0
    $attemptedCount = 0
    $successfulRuns = 0
    $selectedSources = 0
    $failedRuns = New-Object 'System.Collections.Generic.List[string]'
    foreach ($group in $groups) {
        foreach ($extension in @('.s', '.si')) {
            $matching = @($group.Group | Where-Object { $_.Extension -ieq $extension })
            if ($matching.Count -eq 0) { continue }
            $pattern = '*' + $extension
            $attemptedCount++
            $selectedSources += $matching.Count
            Write-UpgradeLog ("Compile wildcard run [{0}]: {1}; pattern={2}; sources={3}" -f $attemptedCount, $group.Name, $pattern, $matching.Count)
            $batchWatch = [Diagnostics.Stopwatch]::StartNew()
            try {
                # A native wildcard could otherwise include a source link skipped by the scanner.
                foreach ($entry in Get-ChildItem -LiteralPath $group.Name -Filter $pattern -Force) {
                    if (-not $entry.PSIsContainer) { Reject-Links $entry.FullName }
                }
                # Pass ONE literal wildcard argument to SC32; no PowerShell file expansion.
                Run-Compiler @($pattern) $group.Name
                $successfulRuns++
                $successfulSourceCount += $matching.Count
                $successfulSeconds += $batchWatch.Elapsed.TotalSeconds
                if ($showCompileEta -and -not $etaShown -and $selectedSources -lt $files.Count) {
                    $remainingSeconds = $successfulSeconds * ($files.Count - $selectedSources) / $successfulSourceCount
                    Show-CompilationEstimate $remainingSeconds 'remaining sources, based on successful batches in this run'
                    $etaShown = $true
                }
            } catch {
                $failedRuns.Add(($group.Name + ' | ' + $pattern))
                $script:batchCompileFailures++
                Write-UpgradeLog ("COMPILE RUN FAILED; continuing: {0}; pattern={1}" -f $group.Name, $pattern) -ForegroundColor Yellow
                Write-UpgradeLog $_.Exception.Message
            }
        }
    }
    $compileWatch.Stop()
    Write-UpgradeLog ("SC32 actual compilation elapsed: {0} ({1:N1} seconds), excluding source scan." -f $compileWatch.Elapsed.ToString('c'), $compileWatch.Elapsed.TotalSeconds)
    if ($files.Count -gt 0) {
        try {
            $historyResult = 'SUCCESS'; if ($failedRuns.Count -gt 0) { $historyResult = 'FAILED' }
            $historyRow = [pscustomobject][ordered]@{
                timestamp=(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'); compiler=$script:compiler;
                directory=$directory; source_count=$files.Count;
                elapsed_seconds=$compileWatch.Elapsed.TotalSeconds.ToString('F3',[Globalization.CultureInfo]::InvariantCulture);
                result=$historyResult
            }
            $historyRow | Export-Csv -LiteralPath $historyPath -Delimiter "`t" -NoTypeInformation -Append -Encoding ASCII
            Write-UpgradeLog "Compilation estimate history saved: $historyPath"
        } catch { Write-UpgradeLog ("Could not save compilation timing history: {0}" -f $_.Exception.Message) -ForegroundColor Yellow }
    }
    Write-UpgradeLog ("Compilation batch complete: {0} sources selected; {1} wildcard runs, {2} successful runs, {3} failed runs." -f $selectedSources, $attemptedCount, $successfulRuns, $failedRuns.Count)
    foreach ($failedRun in $failedRuns) { Write-UpgradeLog "FAILED WILDCARD RUN: $failedRun" }
    if ($failedRuns.Count -gt 0) { Write-UpgradeLog 'Continuing upgrade despite the batch compilation errors. See compiler output for source errors.' }
}

# Aggregate checks are read-only except for the separate validation report.
function Add-Validation([string]$level, [string]$key, [string]$message) {
    [void]$script:validationIssues.Add(('{0}: {1}: {2}' -f $level, $key, $message))
}
function Check-ValidationPath([string]$key, [string]$root, [string]$kind, [string]$missingLevel) {
    $raw = Value $key
    if (-not $raw) { return '' }
    try {
        $path = Resolve-Setting $raw $root
        Reject-Links $path
        if ($raw.Contains('"')) { Add-Validation 'ERROR' $key 'Do not enclose INI paths in quotes.' }
        if ([Environment]::ExpandEnvironmentVariables($raw) -match '%[^%]+%') {
            Add-Validation 'ERROR' $key 'Contains an unresolved environment variable.'
        }
        if ($kind -eq 'Output') {
            if (Test-Path -LiteralPath $path -PathType Container) {
                Add-Validation 'ERROR' $key "Expected an output filename, found a directory: $path"
            }
            $parent = Split-Path -Parent $path
            if ($parent -and -not (Test-Path -LiteralPath $parent -PathType Container)) {
                Add-Validation 'WARNING' $key "Output parent does not yet exist: $parent (may be created by an earlier step)."
            }
        } elseif (-not (Test-Path -LiteralPath $path)) {
            Add-Validation $missingLevel $key "Not found: $path"
        } elseif (-not (Test-Path -LiteralPath $path -PathType $kind)) {
            Add-Validation 'ERROR' $key "Wrong path type; expected ${kind}: $path"
        }
        return $path
    } catch {
        Add-Validation 'ERROR' $key $_.Exception.Message
        return ''
    }
}
function Test-UpgradeSettings {
    $script:validationIssues = New-Object 'System.Collections.Generic.List[string]'
    if ($script:logSetupError) { Add-Validation 'ERROR' 'log_file' $script:logSetupError }
    $knownKeys = @('silent','unattended','copydisplay','copyeta','compileeta','powershell_exe',
        'old_version','new_version','old_directory','new_directory','archive_file',
        'download_url','installer_exe','preparation_compiler_exe','preparation_wait_seconds',
        'generated_macro_launch_delay_seconds','ui_file','ui_destination','cfg_file',
        'custom_macro_directory','cuamark_file','editor_exe','compiler_exe','cfg_destination',
        'cfg_data_file','tse_path','kbd_path','working_directory','log_file',
        'old_compile_data','export_cfg','merge_compile_data','new_compile_data','startup_macro')
    foreach ($problem in $script:iniParseProblems) { Add-Validation 'WARNING' 'INI syntax' $problem }
    foreach ($key in $settings.Keys | Sort-Object) {
        if ($knownKeys -notcontains $key) { Add-Validation 'WARNING' $key 'Unknown setting; ignored. Check spelling.' }
    }
    $automatic = (Value 'unattended') -ieq 'true'
    foreach ($key in @('silent','unattended','copyeta','compileeta','export_cfg','merge_compile_data')) {
        $v = Value $key
        if ($v -and @('true','false') -notcontains $v.ToLowerInvariant()) {
            Add-Validation 'ERROR' $key 'Use true or false.'
        }
    }
    foreach ($key in @('old_version','new_version','old_directory','new_directory')) {
        if (-not (Value $key)) {
            if ($automatic -or $ValidateOnly) { Add-Validation 'ERROR' $key 'Required value is blank.' }
            else { Add-Validation 'WARNING' $key 'Required value is blank; you will be asked before installation starts.' }
        }
    }
    $display = Value 'copydisplay'
    if ($display -and @('all','summary','none') -notcontains $display.ToLowerInvariant()) {
        Add-Validation 'ERROR' 'copydisplay' 'Use all, summary or none.'
    }
    foreach ($key in @('preparation_wait_seconds','generated_macro_launch_delay_seconds')) {
        $v = Value $key; $number = 0
        if ($v -and (-not [int]::TryParse($v,[ref]$number) -or $number -lt 0 -or $number -gt 300)) {
            Add-Validation 'ERROR' $key 'Use an integer from 0 through 300.'
        }
    }
    $url = Value 'download_url'; $parsedUrl = $null
    if ($url -and (-not [Uri]::TryCreate($url,[UriKind]::Absolute,[ref]$parsedUrl) -or $parsedUrl.Scheme -notin @('http','https'))) {
        Add-Validation 'ERROR' 'download_url' 'Use an absolute http:// or https:// URL.'
    }
    $oldPath = Check-ValidationPath 'old_directory' $base 'Container' 'ERROR'
    $newPath = Check-ValidationPath 'new_directory' $base 'Container' 'INFO'
    if ($newPath -and -not (Test-Path -LiteralPath $newPath)) {
        Add-Validation 'INFO' 'new_directory' 'A new installation directory can be created by the upgrade.'
    }
    if ($oldPath -and $newPath) {
        $op = $oldPath.TrimEnd('\') + '\'; $np = $newPath.TrimEnd('\') + '\'
        if ($np.StartsWith($op,[StringComparison]::OrdinalIgnoreCase) -or $op.StartsWith($np,[StringComparison]::OrdinalIgnoreCase)) {
            Add-Validation 'ERROR' 'new_directory' 'OLD and NEW must be separate, non-nested directories.'
        }
    }
    foreach ($key in @('ui_file','cfg_file','cuamark_file','archive_file','preparation_compiler_exe')) {
        if (Value $key) { [void](Check-ValidationPath $key $base 'Leaf' 'WARNING') }
        elseif ($key -ne 'preparation_compiler_exe') { Add-Validation 'INFO' $key 'Blank: optional step is skipped.' }
    }
    foreach ($key in @('working_directory','custom_macro_directory')) {
        if (Value $key) { [void](Check-ValidationPath $key $base 'Container' 'WARNING') }
        else { Add-Validation 'INFO' $key 'Blank: optional setting is not applied.' }
    }
    if (Value 'powershell_exe') { [void](Check-ValidationPath 'powershell_exe' $base 'Leaf' 'ERROR') }
    if ($newPath) {
        foreach ($key in @('editor_exe','compiler_exe','installer_exe','cfg_data_file','new_compile_data')) {
            $name = Value $key
            if (-not $name) {
                $defaults = @{editor_exe='g32.exe';compiler_exe='sc32.exe';installer_exe='tse.exe';cfg_data_file='tsecfg.dat';new_compile_data='compile.dat'}
                $name = $defaults[$key]
            }
            try {
                $path = Resolve-Setting $name $newPath
                Reject-Links $path
                if (Test-Path -LiteralPath $path) {
                    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { Add-Validation 'ERROR' $key "Expected a file: $path" }
                } elseif ($key -eq 'cfg_data_file') {
                    Add-Validation 'INFO' $key "Absent: $path. Does not block installation; configuration preparation will be skipped."
                } else {
                    Add-Validation 'INFO' $key "Not present yet: $path. Checked again at its step; copying/extraction/installation may supply it."
                }
                if ($oldPath -and $path.StartsWith(($oldPath.TrimEnd('\')+'\'),[StringComparison]::OrdinalIgnoreCase)) {
                    Add-Validation 'ERROR' $key 'Must not point inside the OLD installation.'
                }
                if (-not $path.StartsWith(($newPath.TrimEnd('\')+'\'),[StringComparison]::OrdinalIgnoreCase)) {
                    Add-Validation 'ERROR' $key 'Must be inside the NEW installation.'
                }
            } catch { Add-Validation 'ERROR' $key $_.Exception.Message }
        }
        $outputRoot = $newPath
        if (Value 'working_directory') {
            try { $outputRoot = Resolve-Setting (Value 'working_directory') } catch { }
        }
        foreach ($key in @('ui_destination','cfg_destination','log_file')) {
            if (Value $key) {
                $root = $outputRoot; if ($key -eq 'log_file') { $root = $base }
                $target = Check-ValidationPath $key $root 'Output' 'WARNING'
                if ($target -and $oldPath -and $target.StartsWith(($oldPath.TrimEnd('\')+'\'),[StringComparison]::OrdinalIgnoreCase)) {
                    Add-Validation 'ERROR' $key 'Output must not be inside the OLD installation.'
                }
                $sourceKey = @{ui_destination='ui_file';cfg_destination='cfg_file'}[$key]
                if ($target -and $sourceKey -and (Value $sourceKey)) {
                    try {
                        if ($target -ieq (Resolve-Setting (Value $sourceKey))) { Add-Validation 'ERROR' $key 'Output would overwrite its OLD source.' }
                    } catch { }
                }
            }
        }
    }
    if ((Value 'merge_compile_data') -ine 'false' -and $oldPath) {
        $data = Value 'old_compile_data'
        if (-not $data) { $data = Join-Path $oldPath 'compile.dat' }
        try {
            $path = Resolve-Setting $data
            if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { Add-Validation 'WARNING' 'old_compile_data' "Merge source not found: $path" }
        } catch { Add-Validation 'ERROR' 'old_compile_data' $_.Exception.Message }
    }
    foreach ($key in @('tse_path','kbd_path')) {
        $v = Value $key
        if ($v -and ($v.Contains('"') -or $v.Length -gt 220)) { Add-Validation 'ERROR' $key 'Search path must have no quotes and be at most 220 characters.' }
    }
    $macro = Value 'startup_macro'
    if ($macro -and ($macro.Contains('"') -or $macro -match '[\r\n]')) { Add-Validation 'ERROR' 'startup_macro' 'Do not include quotes or newlines.' }
    if ($macro) { Add-Validation 'INFO' 'startup_macro' "TSE will resolve [$macro] at final launch after compilation; existence is deferred." }
    $errors = @($script:validationIssues | Where-Object { $_.StartsWith('ERROR:') }).Count
    $warnings = @($script:validationIssues | Where-Object { $_.StartsWith('WARNING:') }).Count
    $report = @('TSEUPGRADE 1.0.0.0.53 - INI validation', ('Configuration: '+$ini),
        ('Checked: '+(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')), '') +
        @($script:validationIssues) + @('', "Validation summary: $errors error(s), $warnings warning(s).",
        'Warnings describe optional/conditional steps; choosing such a step still requires its files.',
        'Generated/installed files are checked again when used. This report does not test executables or write permissions.')
    $reportPath = Join-Path $base ('tseupgrade_{0}_{1}.validation.log' -f (Get-Date -Format 'yyyyMMdd_HHmmss'), [guid]::NewGuid().ToString('N').Substring(0,8))
    foreach ($line in $report) {
        if ($line.StartsWith('ERROR:')) { Write-UpgradeLog $line -ForegroundColor Red -Type INI }
        elseif ($line.StartsWith('WARNING:')) { Write-UpgradeLog $line -ForegroundColor Yellow -Type INI }
        else { Write-UpgradeLog $line -Type INI }
    }
    try {
        $formattedReport = @($report | Where-Object { $_ } | ForEach-Object { Format-UpgradeLogRecord $_ 'INFO' 'INI' })
        [IO.File]::WriteAllLines($reportPath, $formattedReport, [Text.Encoding]::ASCII)
        Write-UpgradeLog "Validation report: $reportPath"
    } catch { Write-UpgradeLog "Could not save validation report: $($_.Exception.Message)" -ForegroundColor Yellow }
    if ($errors -gt 0) { throw "INI validation failed: $errors error(s). Correct the listed settings before upgrading." }
}

try {
    Initialize-UpgradeLog
    Initialize-ConsoleFocus
    Require-File $ini
    $script:iniParseProblems = New-Object 'System.Collections.Generic.List[string]'
    $seenKeys = @{}
    $lineNumber = 0
    foreach ($line in [IO.File]::ReadAllLines($ini)) {
        $lineNumber++
        $s = $line.Trim()
        if (-not $s -or $s.StartsWith(';') -or $s.StartsWith('#')) { continue }
        if ($s -match '^\[(.+)\]$') {
            $section = $Matches[1]
            if ($section -ine 'tseupgrade') { [void]$script:iniParseProblems.Add("Line ${lineNumber}: unknown section [$section]; ignored.") }
            continue
        }
        if ($section -eq 'tseupgrade' -and $s.Contains('=')) {
            $i = $s.IndexOf('=')
            $key = $s.Substring(0,$i).Trim()
            if (-not $key) { [void]$script:iniParseProblems.Add("Line ${lineNumber}: empty setting name."); continue }
            if ($seenKeys.ContainsKey($key)) { [void]$script:iniParseProblems.Add("Line ${lineNumber}: duplicate key [$key]; last value wins (earlier line $($seenKeys[$key])).") }
            $seenKeys[$key] = $lineNumber
            $settings[$key] = $s.Substring($i+1).Trim()
        } elseif ($section -ieq 'tseupgrade') {
            [void]$script:iniParseProblems.Add("Line ${lineNumber}: expected key=value.")
        } elseif (-not $section) {
            [void]$script:iniParseProblems.Add("Line ${lineNumber}: setting outside [tseupgrade]; ignored.")
        }
    }
    $script:unattended = (Value 'unattended') -ieq 'true'
    Select-ConfiguredUpgradeLog
    Test-UpgradeSettings
    if ($ValidateOnly) { $script:upgradeResult = 'VALIDATED'; Write-UpgradeLog 'Validation-only check finished; no upgrade steps executed.'; return }
    $unattendedSetting = Value 'unattended'
    if ($unattendedSetting) {
        if (@('true','false') -notcontains $unattendedSetting.ToLowerInvariant()) { throw 'unattended must be true or false.' }
        $script:unattended = $unattendedSetting -ieq 'true'
    }
    $etaSetting = Value 'copyeta'
    if ($etaSetting) {
        if (@('true','false') -notcontains $etaSetting.ToLowerInvariant()) { throw 'copyeta must be true or false.' }
        $script:copyEta = $etaSetting -ieq 'true'
    }
    $displaySetting = Value 'copydisplay'
    if ($displaySetting) { $script:copyDisplay = $displaySetting.ToLowerInvariant() }
    if (@('all','summary','none') -notcontains $script:copyDisplay) {
        throw 'Invalid copydisplay setting. Use all, summary, or none.'
    }
    $log = $script:logPath
    $oldVersion = Required 'old_version' 'Old TSE version (label)'
    $newVersion = Required 'new_version' 'New TSE version (label)'
    $old = Resolve-Setting (Required 'old_directory' 'Full path to OLD TSE installation')
    $new = Resolve-Setting (Required 'new_directory' 'Full path to NEW TSE installation')
    if (-not (Test-Path -LiteralPath $old -PathType Container)) { throw "Old installation not found: $old" }
    Reject-Links $old
    Reject-Links $new
    $script:oldPrefix = $old.TrimEnd('\') + '\'
    $script:protectedSources = @()
    foreach ($key in @('ui_file','cfg_file','cuamark_file','old_compile_data')) {
        $sourcePath = Resolve-Setting (Value $key)
        if ($sourcePath) { $script:protectedSources += $sourcePath }
    }
    $script:newPrefix = $new.TrimEnd('\') + '\'
    if ($newPrefix.StartsWith($oldPrefix,[StringComparison]::OrdinalIgnoreCase) -or
        $oldPrefix.StartsWith($newPrefix,[StringComparison]::OrdinalIgnoreCase)) {
        throw 'Old and new directories must be separate, non-nested directories.'
    }
    if ($log.StartsWith($oldPrefix,[StringComparison]::OrdinalIgnoreCase)) { throw 'Log cannot be inside the old installation.' }
    Reject-Links $log
    Write-UpgradeLog ("INSTALLATION START: {0:yyyy-MM-dd HH:mm:ss.fff zzz}" -f $script:upgradeStartedAt)
    Write-UpgradeLog "Upgrade automatic confirmations: $script:unattended; tse.exe installer remains interactive."
    $script:compilerTimingLog = $log + '.sc32.tsv'
    if (Test-Path -LiteralPath $script:compilerTimingLog) { throw "Compilation timing log already exists: $script:compilerTimingLog" }
    $timingHeader = @('timestamp_local', 'invocation_id', 'event', 'elapsed_seconds', 'exit_code', 'result', 'compiler', 'working_directory', 'arguments_json', 'detail') -join "`t"
    [IO.File]::WriteAllText($script:compilerTimingLog, $timingHeader + "`r`n", [Text.Encoding]::ASCII)
    Write-UpgradeLog "SC32 compilation timing log: $script:compilerTimingLog"
    Write-UpgradeLog "Upgrade $oldVersion -> $newVersion`nOLD: $old`nNEW: $new`nLOG: $log"
    $archive = Resolve-Setting (Value 'archive_file')
    $url = Value 'download_url'
    if ($url -and (Confirm-Step ("Open download URL in your default browser?`nURL: {0}`nArchive file: {1}" -f $url, $archive))) {
        if ($url -notmatch '^https?://') { throw 'download_url must start with https:// or http://' }
        Start-Process -FilePath $url -WindowStyle Minimized
        Write-UpgradeLog 'Opening download URL; returning focus to the upgrade console...'
        # Browser startup/reused tabs can activate later than Start-Process returns.
        for ($focusAttempt = 0; $focusAttempt -lt 25; $focusAttempt++) {
            Start-Sleep -Milliseconds 200
            Restore-ConsoleFocus
        }
        Restore-ConsoleFocus
        if (('TseUpgradeFocus' -as [type]) -and [TseUpgradeFocus]::GetForegroundWindow() -ne $script:consoleWindow) {
            Write-UpgradeLog 'Windows did not grant console focus. Use Alt+Tab to return to this console.' -ForegroundColor Yellow
        }
        Write-UpgradeLog 'Finish the download and set archive_file before installing. Rerun if needed.'
    }
    if (-not (Confirm-Step ("Continue with NEW installation directory [{0}]? Files there may be overwritten." -f $new))) { return }
    if (Test-Path -LiteralPath $new) {
        foreach ($entry in Get-ChildItem -LiteralPath $new -Recurse -Force) {
            if ($entry.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Linked target is not supported: $($entry.FullName)" }
        }
        if (-not (Test-Path -LiteralPath $new -PathType Container)) { throw 'Target is not a directory.' }
        if (-not (Confirm-Step ("NEW installation directory [{0}] already exists. Have you backed it up and want to reuse it?" -f $new))) { return }
    } else { New-Item -ItemType Directory -Path $new | Out-Null }
    if (Confirm-Step ("Copy OLD installation to NEW?`nRead source: {0}`nWrite destination: {1}`nExisting destination files may be overwritten." -f $old, $new)) {
        [void](Copy-Sources $old $new)
    }
    if ($archive -and (Confirm-Step ("Extract ZIP archive?`nRead archive: {0}`nWrite destination: {1}`nExisting destination files may be overwritten." -f $archive, $new))) {
        Require-File $archive
        # Expand-Archive -Force works on Windows PowerShell 5.1; commands wait.
        Expand-Archive -LiteralPath $archive -DestinationPath $new -Force
    }
    $installerName = Value 'installer_exe'
    if (-not $installerName) { $installerName = 'tse.exe' }
    $installer = Resolve-Setting $installerName $new
    if ($installer.StartsWith($oldPrefix,[StringComparison]::OrdinalIgnoreCase)) {
        throw 'The installer must not be run from the old installation.'
    }
    Write-UpgradeLog "Installer: $installer"
    Write-UpgradeLog "Select this NEW installation directory in the installer: $new"
    Write-UpgradeLog 'Complete the installation before continuing. Keep the OLD installation unchanged.'
    if (Confirm-Step ("Run installer [{0}] now for NEW directory [{1}]? Answer No if it was already installed." -f $installer, $new)) {
        Require-File $installer
        Reject-Links $installer
        # Prepare the copied editor's internal TSEPath, not a Windows environment variable.
        $prepareEditorName = Value 'editor_exe'; if (-not $prepareEditorName) { $prepareEditorName = 'g32.exe' }
        $prepareEditor = New-Output (Resolve-Setting $prepareEditorName $new)
        $prepareCompilerName = Value 'preparation_compiler_exe'
        if ($prepareCompilerName) {
            $prepareCompiler = Resolve-Setting $prepareCompilerName
        } else {
            $prepareCompilerName = Value 'compiler_exe'
            if (-not $prepareCompilerName) { $prepareCompilerName = 'sc32.exe' }
            $prepareCompiler = New-Output (Resolve-Setting $prepareCompilerName $new)
        }
        $prepareDataName = Value 'cfg_data_file'; if (-not $prepareDataName) { $prepareDataName = 'tsecfg.dat' }
        $prepareData = New-Output (Resolve-Setting $prepareDataName $new)
        $backup = $null
        if (-not (Test-Path -LiteralPath $prepareData)) {
            Write-UpgradeLog "PREPARE configuration absent: $prepareData" -ForegroundColor Yellow
            Write-UpgradeLog 'Skipping copied-configuration preparation; missing tsecfg.dat does not block installation.'
            Write-UpgradeLog 'No configuration backup exists for this run, so no DAT restoration will be attempted.'
        } else {
            Require-File $prepareData
            foreach ($file in @($prepareEditor, $prepareCompiler)) {
                Require-File $file
                Reject-Links $file
            }
            foreach ($prepareBinary in @($prepareEditor, $prepareCompiler)) {
                $prepareInfo = (Get-Item -LiteralPath $prepareBinary).VersionInfo
                Write-UpgradeLog ("PREPARE executable: {0}; file version: {1}; product version: {2}" -f $prepareBinary, $prepareInfo.FileVersion, $prepareInfo.ProductVersion)
            }
            $prepareId = [guid]::NewGuid().ToString('N').Substring(0,12)
            $backup = $prepareData + '.before_prepare_' + $prepareId + '.bak'
            $prepareSource = Join-Path $new ('tseupgrade_prepare_' + $prepareId + '.s')
            $prepareMacro = [IO.Path]::ChangeExtension($prepareSource, '.mac')
            $prepareMarker = Join-Path $new ('tseupgrade_prepare_' + $prepareId + '.ini')
            # SAL strings and TSEPath have bounded lengths; never silently truncate paths.
            foreach ($salPath in @($new, $prepareMarker)) {
                if ($salPath.Contains('"') -or $salPath -match '[^\x20-\x7e]' -or $salPath.Length -gt 220) {
                    throw 'Preparation requires ASCII paths without quotes, at most 220 characters.'
                }
            }
            if ($new.Length -gt 80) { throw 'The preparation TSEPath directory exceeds the documented 80-character limit.' }
            if (-not (Confirm-Step ("Prepare the copied NEW editor before installation?`nEditor: {0}`nCompiler (read/run only): {1}`nBack up: {2}`nBackup destination: {3}`nSet internal TSEPath to: {4}`nSave settings in the copied editor, then close it. The OLD installation is not the save target." -f $prepareEditor, $prepareCompiler, $prepareData, $backup, $new))) {
                Write-UpgradeLog 'Preparation declined. Installer has not been started.'
                return
            }
            [IO.File]::Copy($prepareData, $backup, $false)
            Write-UpgradeLog "Copied configuration backup: $backup"
            $prepareLines = @(
                'PROC Main()',
                (' WriteProfileStr("preparation", "started", "true", "{0}")' -f $prepareMarker),
                (' Set(TSEPath, "{0}")' -f $new),
                ' IF NOT SaveSettings()',
                '  Warn("Could not save preparation settings. Installation must not proceed.")',
                '  RETURN()',
                ' ENDIF',
                (' WriteProfileStr("preparation", "saved", "true", "{0}")' -f $prepareMarker),
                ' Exit()',
                'END'
            )
            [IO.File]::WriteAllLines($prepareSource, $prepareLines, [Text.Encoding]::ASCII)
            $previousCompiler = $script:compiler
            try {
                $script:compiler = $prepareCompiler
                Run-Compiler @($prepareSource) $new
            } finally { $script:compiler = $previousCompiler }
            Require-File $prepareMacro
            Wait-GeneratedMacroLaunch $prepareMacro 'PREPARE'
            Write-UpgradeLog "Running preparation in copied NEW editor: $prepareEditor"
            Write-UpgradeLog 'If saving fails, close the preparation editor; the installer remains blocked until preparation is confirmed.'
            $prepareStartInfo = New-HelperStartInfo $prepareEditor ([IO.Path]::GetFullPath($prepareMacro)) $new
            Write-UpgradeLog 'PREPARE launch: cmd.exe START with empty title, /wait, NEW directory, and TSE -1- separate-instance switch.'
            Write-UpgradeLog "PREPARE working directory: $new"
            Write-UpgradeLog "PREPARE source: $prepareSource"
            Write-UpgradeLog "PREPARE compiled macro: $prepareMacro"
            Write-UpgradeLog "PREPARE expected confirmation file: $prepareMarker"
            Write-UpgradeLog "PREPARE configuration backup: $backup"
            $prepareWatch = [Diagnostics.Stopwatch]::StartNew()
            $prepareAutoload = $null
            try {
                $prepareAutoload = Suspend-NewAutoload 'PREPARE'
                $prepareProcess = [Diagnostics.Process]::Start($prepareStartInfo)
                $prepareProcess.WaitForExit()
                # Refresh the process handle before reading ExitCode on Windows PowerShell.
                $prepareProcess.Refresh()
                Write-UpgradeLog ("PREPARE START shell finished: PID={0}; exit={1}; elapsed={2}" -f $prepareProcess.Id, $prepareProcess.ExitCode, $prepareWatch.Elapsed)
            } catch {
                Write-UpgradeLog ("PREPARE editor launch/wait failed: {0}" -f $_.Exception.Message) -ForegroundColor Red
                Write-UpgradeLog 'PREPARE confirmation will still be checked automatically.' -ForegroundColor Yellow
            } finally {
                try { Restore-NewAutoload $prepareAutoload }
                finally { $prepareWatch.Stop() }
            }
            Restore-ConsoleFocus
            # Allow delayed profile writes; always reread this run's exact marker path.
            $prepareWaitSeconds = 5
            $prepareWaitSetting = Value 'preparation_wait_seconds'
            if ($prepareWaitSetting) {
                if (-not [int]::TryParse($prepareWaitSetting, [ref]$prepareWaitSeconds) -or $prepareWaitSeconds -lt 0 -or $prepareWaitSeconds -gt 300) {
                    throw 'preparation_wait_seconds must be an integer from 0 through 300.'
                }
            }
            $prepareConfirmed = $false
            $prepareMarkerText = ''
            $prepareReadError = ''
            $preparePollWatch = [Diagnostics.Stopwatch]::StartNew()
            Write-UpgradeLog "PREPARE automatically checking confirmation for up to $prepareWaitSeconds seconds: $prepareMarker"
            do {
                $prepareMarkerExists = Test-Path -LiteralPath $prepareMarker -PathType Leaf
                if ($prepareMarkerExists) {
                    try {
                        $prepareMarkerText = [IO.File]::ReadAllText($prepareMarker)
                        $prepareReadError = ''
                        $prepareConfirmed = $prepareMarkerText -match '(?im)^\s*saved\s*=\s*true\s*$'
                    } catch { $prepareReadError = $_.Exception.Message }
                }
                if ($prepareConfirmed -or $preparePollWatch.Elapsed.TotalSeconds -ge $prepareWaitSeconds) { break }
                Start-Sleep -Milliseconds 250
            } while ($true)
            $preparePollWatch.Stop()
            Write-UpgradeLog "PREPARE confirmation file exists: $prepareMarkerExists"
            Write-UpgradeLog 'PREPARE confirmation contents BEGIN'
            Write-UpgradeLog $prepareMarkerText
            Write-UpgradeLog 'PREPARE confirmation contents END'
            if ($prepareReadError) { Write-UpgradeLog "PREPARE confirmation read error: $prepareReadError" }
            Write-UpgradeLog ("PREPARE automatic check elapsed: {0}" -f $preparePollWatch.Elapsed)
            Write-UpgradeLog "PREPARE saved=true confirmation accepted: $prepareConfirmed"
            if (-not $prepareConfirmed) {
                $prepareStarted = $prepareMarkerText -match '(?im)^\s*started\s*=\s*true\s*$'
                Write-UpgradeLog "PREPARE macro-start marker detected: $prepareStarted"
                throw "Automatic preparation unconfirmed. Installer not started. Inspect marker [$prepareMarker] and backup [$backup]."
            }
            Write-UpgradeLog 'PREPARE result: macro reported successful SaveSettings.'
            Write-UpgradeLog "Preparation confirmed. Internal TSEPath saved as: $new"
        }
        Write-UpgradeLog 'Starting installer. Check whether it now avoids the original personal macro directory.'
        # Refresh only after the preparation editor exits; it may clear the clipboard.
        try {
            Set-Clipboard -Value $new -ErrorAction Stop
            $clipboardText = Get-Clipboard -Raw -ErrorAction Stop
            if ($clipboardText -cne $new) { throw 'Clipboard read-back did not match the NEW directory.' }
            Write-UpgradeLog "Copied to the Microsoft Windows clipboard (verified): $new"
            Write-UpgradeLog "Paste this into the installer's destination field."
        } catch {
            Write-UpgradeLog "Could not copy the installation directory to the clipboard: $($_.Exception.Message)" -ForegroundColor Yellow
            Write-UpgradeLog "Enter this destination manually in the installer: $new"
        }
        try {
            $installerProcess = Start-Process -FilePath $installer -WorkingDirectory $new -Wait -PassThru
            $installerExit = $installerProcess.ExitCode
        } finally {
            # Restore even when installer launch/wait fails or it returns a failure code.
            # Only this run's original backup may be restored; never guess an older backup.
            try {
                if ($backup) {
                    Require-File $backup
                    Reject-Links $backup
                    [void](New-Output $prepareData)
                    if (Test-Path -LiteralPath $prepareData) {
                        Require-File $prepareData
                        $installerDataBackup = New-Output ($prepareData + '.after_installer_' + [guid]::NewGuid().ToString('N').Substring(0,12) + '.bak')
                        [IO.File]::Move($prepareData, $installerDataBackup)
                        Write-UpgradeLog "Preserved post-installer configuration: $installerDataBackup"
                    }
                    try {
                        [IO.File]::Copy($backup, $prepareData, $false)
                        $originalHash = (Get-FileHash -LiteralPath $backup -Algorithm SHA256).Hash
                        $restoredHash = (Get-FileHash -LiteralPath $prepareData -Algorithm SHA256).Hash
                        if ($restoredHash -ne $originalHash) { throw 'Restored DAT does not match its backup.' }
                    } catch {
                        throw "Configuration restoration failed. Original backup remains at [$backup]; restore it to [$prepareData]. $($_.Exception.Message)"
                    }
                    Write-UpgradeLog "Restored original pre-preparation configuration after installer (SHA256 verified): $prepareData"
                    Write-UpgradeLog "Original backup retained: $backup"
                } else {
                    Write-UpgradeLog 'DAT restoration skipped: no original configuration existed before preparation.'
                }
            } finally { Restore-ConsoleFocus }
        }
        Write-UpgradeLog "Installer finished (exit $installerExit)."
        if ($installerExit -ne 0) {
            # Do not apply SAL compiler return-code conventions to the installer.
            throw "Installer returned $installerExit. Check its result before rerunning."
        }
        if (-not (Confirm-Step ("Did installation finish successfully in NEW directory [{0}]?" -f $new))) {
            Write-UpgradeLog 'Installation not confirmed. Stopping before compilation.'
            return
        }
    } else {
        Write-UpgradeLog 'Installer skipped by user: using the existing NEW installation and continuing upgrade steps.'
        Write-UpgradeLog 'No preparation or DAT backup/restoration is performed when tse.exe is skipped.'
    }
    $editorName = Value 'editor_exe'; if (-not $editorName) { $editorName = 'g32.exe' }
    $compilerName = Value 'compiler_exe'; if (-not $compilerName) { $compilerName = 'sc32.exe' }
    $editor = New-Output (Resolve-Setting $editorName $new)
    $script:compiler = New-Output (Resolve-Setting $compilerName $new)
    foreach ($entry in Get-ChildItem -LiteralPath $new -Recurse -Force) {
        if ($entry.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Linked target is not supported: $($entry.FullName)" }
    }
    Require-File $editor
    Require-File $script:compiler
    foreach ($binary in @($editor, $script:compiler)) {
        $info = (Get-Item -LiteralPath $binary).VersionInfo
        Write-UpgradeLog ("Installed executable: {0}; file version: {1}; product version: {2}" -f $binary, $info.FileVersion, $info.ProductVersion)
    }
    $cuamark = Resolve-Setting (Value 'cuamark_file')
    if ($cuamark -and (Confirm-Step ("Copy personal cuamark source?`nRead source: {0}`nWrite destination: {1}" -f $cuamark, (Join-Path $new 'mac\cuamark.s')))) {
        Require-File $cuamark
        $mac = Join-Path $new 'mac'
        if (-not (Test-Path -LiteralPath $mac -PathType Container)) { throw "Missing directory: $mac" }
        if ($cuamark -ne (Join-Path $mac 'cuamark.s')) { Copy-Item -LiteralPath $cuamark -Destination (Join-Path $mac 'cuamark.s') -Force }
    }
    if (Confirm-Step ("Compile .s and .si wildcard batches recursively in NEW installation?`nSource/output directory: {0}`nCompiler: {1}`nBatch errors will be reported and compilation will continue." -f (Join-Path $new 'mac'), $script:compiler)) { Compile-Directory (Join-Path $new 'mac') }
    $custom = Resolve-Setting (Value 'custom_macro_directory')
    $customDestination = New-Output (Join-Path $new 'custom_macros')
    if ($custom) {
        if (Confirm-Step ("Copy personal files to NEW custom_macros?`nRead source tree: {0}`nWrite destination: {1}`nOriginal personal files are only read. Compilation has a separate confirmation." -f $custom, $customDestination)) {
            [void](Copy-Sources $custom $customDestination)
        } else {
            Write-UpgradeLog 'Personal-file copying skipped; existing custom_macros files are retained.' -Type COPY
        }
    } else {
        Write-UpgradeLog 'Personal-file copying skipped: custom_macro_directory is blank.' -Type COPY
    }
    if (Confirm-Step ("Compile personal .s and .si wildcard batches recursively in NEW custom_macros?`nSource/output directory: {0}`nCompiler: {1}`nThis does not copy files. Existing files can be compiled even if copying was skipped." -f $customDestination, $script:compiler)) {
        Compile-Directory $customDestination $true
    } else {
        Write-UpgradeLog 'Personal-macro compilation skipped.' -Type SC32
    }
    $ui = Resolve-Setting (Value 'ui_file')
    $uiRootPreview = Resolve-Setting (Value 'working_directory')
    if (-not $uiRootPreview) { $uiRootPreview = $new }
    $uiTargetPreview = Resolve-Setting (Value 'ui_destination') $uiRootPreview
    if (-not $uiTargetPreview -and $ui) { $uiTargetPreview = Join-Path $new ('new_' + (Split-Path -Leaf $ui)) }
    if ($ui -and (Confirm-Step ("Copy personal UI and compile into NEW editor?`nRead old UI: {0}`nWrite new UI: {1}`nModify NEW editor: {2}`nCompiler: {3}`nExisting NEW UI/output files are backed up before replacement." -f $ui, $uiTargetPreview, $editor, $script:compiler))) {
        Require-File $ui
        $uiRoot = Resolve-Setting (Value 'working_directory')
        if (-not $uiRoot) { $uiRoot = $new }
        $uiDestination = Resolve-Setting (Value 'ui_destination') $uiRoot
        if (-not $uiDestination) { $uiDestination = Join-Path $new ('new_' + (Split-Path -Leaf $ui)) }
        $uiDestination = Personal-Output $uiDestination $ui
        # Validate that destinations differ from OLD sources; preserve existing NEW outputs.
        $oldUiMacro = [IO.Path]::ChangeExtension($ui,'.mac')
        $uiMacro = [IO.Path]::ChangeExtension($uiDestination,'.mac')
        [void](Personal-Output $uiMacro $oldUiMacro)
        Backup-PersonalOutput $uiDestination
        Backup-PersonalOutput $uiMacro
        Copy-Item -LiteralPath $ui -Destination $uiDestination
        Run-Compiler @("-b$editor", $uiDestination) (Split-Path -Parent $uiDestination)
        Write-UpgradeLog "New personal UI: $uiDestination"
    }
    $cfg = Resolve-Setting (Value 'cfg_file')
    $cfgRootPreview = Resolve-Setting (Value 'working_directory')
    if (-not $cfgRootPreview) { $cfgRootPreview = $new }
    $cfgNamePreview = Value 'cfg_destination'
    if (-not $cfgNamePreview) { $cfgNamePreview = 'tseupgrade_settings.cfg' }
    $cfgTargetPreview = Resolve-Setting $cfgNamePreview $cfgRootPreview
    if ($cfg -and (Confirm-Step ("Copy and burn ASCII CFG for NEW installation?`nRead old CFG: {0}`nFresh CFG export destination: {1}`nModify NEW editor: {2}`nCompiler: {3}`nA staged CFG copy will be compiled inside the NEW installation." -f $cfg, $cfgTargetPreview, $editor, $script:compiler))) {
        Require-File $cfg
        $destName = Value 'cfg_destination'; if (-not $destName) { $destName = 'tseupgrade_settings.cfg' }
        $workingRoot = Resolve-Setting (Value 'working_directory')
        if (-not $workingRoot) { $workingRoot = $new }
        $dest = Personal-Output (Resolve-Setting $destName $workingRoot) $cfg
        # Compile a private copy inside NEW; never compile the old CFG in place.
        $stagedCfg = Join-Path $new ('tseupgrade_cfg_' + [guid]::NewGuid().ToString('N').Substring(0,8) + '.cfg')
        Copy-Item -LiteralPath $cfg -Destination $stagedCfg
        Write-UpgradeLog ("CFG command: `"{0}`" -b`"{1}`" `"{2}`"" -f $script:compiler, $editor, $stagedCfg)
        Write-UpgradeLog "CFG working directory: $new"
        Run-Compiler @("-b$editor", $stagedCfg) $new
        Write-UpgradeLog "Old CFG applied to NEW editor. Fresh ASCII export is performed by the separate export step."
    }
    $startupMacro = ''
    $tsePath = Value 'tse_path'; $kbdPath = Value 'kbd_path'
    if (($tsePath -or $kbdPath) -and (Confirm-Step ("Generate and compile search-path settings macro?`nWrite generated macro in: {0}`nApply later in NEW editor: {1}`nTSEPath: {2}`nKbdPath: {3}`nBlank paths are left unchanged; macro calls SaveSettings." -f $new, $editor, $tsePath, $kbdPath))) {
        $lines = @('PROC Main()')
        foreach ($entry in @(@('TsePath',$tsePath), @('KbdPath',$kbdPath))) {
            if ($entry[1]) {
                if ($entry[1].Contains('"') -or $entry[1].Length -gt 220) { throw 'Search path contains a quote or exceeds 220 characters.' }
                $lines += (' Set({0}, "{1}")' -f $entry[0],$entry[1])
            }
        }
        $lines += @(' IF NOT SaveSettings()', '  Warn("Could not save new TSE settings")', ' ENDIF', 'END')
        $source = Join-Path $new ('tseupgrade_paths_' + [guid]::NewGuid().ToString('N').Substring(0,8) + '.s')
        [IO.File]::WriteAllLines($source,$lines,[Text.Encoding]::ASCII)
        Run-Compiler @($source) $new
        $startupMacro = [IO.Path]::ChangeExtension($source,'.mac')
        Require-File $startupMacro
    }
    if (Enabled-Setting 'merge_compile_data') {
        $mergeSource = Resolve-Setting (Value 'old_compile_data')
        if (-not $mergeSource) { $mergeSource = Join-Path $old 'compile.dat' }
        $mergeTargetName = Value 'new_compile_data'; if (-not $mergeTargetName) { $mergeTargetName = 'compile.dat' }
        $mergeTarget = New-Output (Resolve-Setting $mergeTargetName $new)
        Require-File $mergeSource
        Require-File $mergeTarget
        Reject-Links $mergeSource
        Reject-Links $mergeTarget
        if ($mergeSource -eq $mergeTarget) { throw 'Old and NEW compiler DAT paths must differ.' }
        $mergeBackup = New-Output ($mergeTarget + '.before_merge.bak')
        if (Test-Path -LiteralPath $mergeBackup) { throw "Merge backup already exists; retain/move it before rerunning: $mergeBackup" }
        if (Confirm-Step ("Automatically merge compiler DAT records?`nRead source: {0}`nUpdate NEW destination: {1}`nBackup before changes: {2}`nNEW editor: {3}" -f $mergeSource, $mergeTarget, $mergeBackup, $editor)) {
            Run-EditorAction 'tseupgrade_mergedat' ('MergeData(' + (Sal-Literal $mergeTarget) + ', ' + (Sal-Literal $mergeSource) + ')')
        }
    }
    if (Enabled-Setting 'export_cfg') {
        # Export is independent of whether the old CFG was selected for burning.
        $exportTarget = $cfgTargetPreview
        if ($cfg) {
            $exportTarget = Personal-Output $exportTarget $cfg
        } else {
            $exportTarget = Personal-Output $exportTarget (Join-Path $old 'tseupgrade_protected.cfg')
        }
        if (Confirm-Step ("Automatically export current settings from NEW editor to ASCII CFG?`nEditor: {0}`nWrite fresh CFG: {1}`nApply generated path macro first: {2}`nExisting NEW CFG is backed up before replacement." -f $editor, $exportTarget, $startupMacro)) {
            $beforeExport = @()
            if ($startupMacro) { $beforeExport += (' ExecMacro(' + (Sal-Literal $startupMacro) + ')') }
            Backup-PersonalOutput $exportTarget
            Run-EditorAction 'tseupgrade_writecfg' ('WriteCfg(' + (Sal-Literal $exportTarget) + ')') $beforeExport
            Require-File $exportTarget
            Write-UpgradeLog "Fresh personal CFG exported by NEW editor: $exportTarget"
            # Already executed in the exporting editor; avoid replay at final launch.
            $startupMacro = ''
        }
    }
    $working = Resolve-Setting (Value 'working_directory')
    if ($working -and (Confirm-Step ("Set NEW editor startup directory?`nWrite INI: {0}`n[startup] working_directory={1}" -f (Join-Path $new 'tse.ini'), $working))) {
        if (-not (Test-Path -LiteralPath $working -PathType Container)) { throw 'Working directory does not exist.' }
        Add-Type -TypeDefinition @'
using System.Runtime.InteropServices;
public static class TseUpgradeIni {
 [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
 public static extern bool WritePrivateProfileString(string section,string key,string value,string file);
}
'@
        if (-not [TseUpgradeIni]::WritePrivateProfileString('startup','working_directory',$working,(Join-Path $new 'tse.ini'))) { throw 'Could not update tse.ini' }
    }
    Write-UpgradeLog 'Review the new installation before using it for daily work.'
    $oldData = Resolve-Setting (Value 'old_compile_data')
    if (-not $oldData) { $oldData = Join-Path $old 'compile.dat' }
    Write-UpgradeLog "Manual fallback if automatic merge was skipped: Shift+F9 > Advanced Setup > Merge Data File > $oldData"
    Write-UpgradeLog 'Manual fallback if automatic export was skipped: Options > Full configuration > Write settings to ASCII file.'
    $launchDirectory = New-Output (Join-Path $new 'custom_macros')
    # Personal startup macro is distinct from the generated settings macro.
    $personalStartupMacro = Value 'startup_macro'
    if ($personalStartupMacro -and ($personalStartupMacro.Contains('"') -or $personalStartupMacro -match '[\r\n]')) {
        throw 'startup_macro must not contain quotes or newlines.'
    }
    if (Confirm-Step ("Start NEW TSE editor?`nExecutable: {0}`nWorking directory: {1}`nGenerated settings macro: {2}`nPersonal startup macro: {3}" -f $editor, $launchDirectory, $startupMacro, $personalStartupMacro)) {
        if (-not (Test-Path -LiteralPath $launchDirectory -PathType Container)) {
            throw "Final launch directory does not exist: $launchDirectory. Copy your personal macros there before launching."
        }
        $start = @{FilePath=$editor; WorkingDirectory=$launchDirectory}
        $launchArguments = @()
        if ($startupMacro) { $launchArguments += ('-e"{0}"' -f $startupMacro) }
        if ($personalStartupMacro) { $launchArguments += ('-e"{0}"' -f $personalStartupMacro) }
        if ($launchArguments.Count -gt 0) { $start.ArgumentList = $launchArguments -join ' ' }
        Write-UpgradeLog ("Final editor launch: {0} {1}; working directory: {2}" -f $editor, ($launchArguments -join ' '), $launchDirectory)
        Start-Process @start
    } else {
        if ($startupMacro) { Write-UpgradeLog "Later execute this settings macro in the NEW editor: $startupMacro" }
        if ($personalStartupMacro) { Write-UpgradeLog "Personal startup macro for later launch: $personalStartupMacro" }
        Write-UpgradeLog "Launch the NEW editor from: $launchDirectory"
    }
    $script:upgradeResult = 'COMPLETED'
    Write-UpgradeLog ("Upgrade steps finished. Failed wildcard compilation runs: {0}. Old installation retained." -f $script:batchCompileFailures)
} catch {
    Write-UpgradeLog ("ERROR: " + $_.Exception.Message) -ForegroundColor Red
    Write-UpgradeLog 'Upgrade stopped. Inspect the log before retrying; completed steps are not rolled back.'
} finally {
    # End before the final console-close prompt; include all earlier user/installer waits.
    $script:upgradeWatch.Stop()
    $upgradeFinishedAt = Get-Date
    $duration = $script:upgradeWatch.Elapsed
    $totalSeconds = $duration.TotalSeconds.ToString('F3', [Globalization.CultureInfo]::InvariantCulture)
    $durationText = '{0}d {1:00}:{2:00}:{3:00}.{4:000}' -f $duration.Days, $duration.Hours, $duration.Minutes, $duration.Seconds, $duration.Milliseconds
    Write-UpgradeLog ("INSTALLATION START: {0:yyyy-MM-dd HH:mm:ss.fff zzz}" -f $script:upgradeStartedAt)
    Write-UpgradeLog ("INSTALLATION END: {0:yyyy-MM-dd HH:mm:ss.fff zzz}; result={1}; failed wildcard runs={2}" -f $upgradeFinishedAt, $script:upgradeResult, $script:batchCompileFailures)
    Write-UpgradeLog ("INSTALLATION TOTAL TIME: {0} ({1} seconds)" -f $durationText, $totalSeconds)
    if (-not $script:unattended) { [void](Read-Host 'Press Enter to close this console') }
}
