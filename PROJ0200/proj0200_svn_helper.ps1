# PROJ0200 1.0.0.0.151 - OpenAI Codex (GPT-6)
# Portable adaptation of updafisc.s: copy, add if needed, commit to local SVN.
param([string]$Request, [string]$Settings, [string]$Log, [string]$Status)
$ErrorActionPreference = 'Stop'
$logWriter = New-Object IO.StreamWriter($Log, $false, [Text.Encoding]::Default)
# cygpath belongs to the same installation as the selected Cygwin SVN.
$script:cygpath = ''
$script:pathCache = @{}
function Convert-CygPath([string]$path, [string]$format) {
    $previousPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $converted = @(& $script:cygpath $format '--' $path 2>&1)
        $exitCode = $LASTEXITCODE
    } finally { $ErrorActionPreference = $previousPreference }
    if ($exitCode -ne 0 -or $converted.Count -ne 1) { throw ('cygpath failed for: ' + $path + ' ' + ($converted -join ' ')) }
    return ([string]$converted[0]).Trim()
}
function Convert-SvnPath([string]$path) {
    if (-not $script:cygpath) { return $path }
    # Convert only Windows absolute paths. Preserve SVN's trailing empty peg.
    if ($path -notmatch '^(?:[A-Za-z]:[\\/]|\\\\)') { return $path }
    $peg = ''
    $plain = $path
    if ($plain.EndsWith('@')) { $peg = '@'; $plain = $plain.Substring(0, $plain.Length-1) }
    if (-not $script:pathCache.ContainsKey($plain)) {
        $script:pathCache[$plain] = Convert-CygPath $plain '-u'
        $logWriter.WriteLine('Path: ' + $plain + ' -> ' + $script:pathCache[$plain])
    }
    return ($script:pathCache[$plain] + $peg)
}
function Run-Svn([string[]]$arguments) {
    $arguments = @($arguments | ForEach-Object { Convert-SvnPath $_ })
    $logWriter.WriteLine("SVN: " + $script:svn + " " + ($arguments -join " "))
    $previousPreference = $ErrorActionPreference
    try { $ErrorActionPreference = 'Continue'; $output = @(& $script:svn @arguments 2>&1); $exitCode = $LASTEXITCODE }
    finally { $ErrorActionPreference = $previousPreference }
    foreach ($line in $output) { $logWriter.WriteLine([string]$line) }
    if ($exitCode -ne 0) { throw ('svn failed (exit ' + $exitCode + '): ' + ($arguments -join ' ')) }
    return ($output -join "`n")
}
try {
    $config = @{}
    foreach ($line in [IO.File]::ReadAllLines($Settings, [Text.Encoding]::Default)) {
        $parts = ($line -split '=', 2)
        if ($parts.Length -eq 2) { $config[$parts[0]] = $parts[1] }
    }
    $script:svn = $config['svnexe']
    if (-not [IO.Path]::IsPathRooted($script:svn) -and (Test-Path -LiteralPath (Join-Path $PSScriptRoot $script:svn) -PathType Leaf)) { $script:svn = Join-Path $PSScriptRoot $script:svn }
    $script:svn = [Environment]::ExpandEnvironmentVariables($script:svn)
    $command = Get-Command $script:svn -CommandType Application -ErrorAction Stop | Select-Object -First 1
    $script:svn = $command.Source
    $svnDirectory = [IO.Path]::GetDirectoryName($script:svn)
    $script:cygpath = $config['svncygpath']
    if ($script:cygpath) {
        $script:cygpath = [Environment]::ExpandEnvironmentVariables($script:cygpath)
        if (-not [IO.Path]::IsPathRooted($script:cygpath)) { $script:cygpath = Join-Path $PSScriptRoot $script:cygpath }
        if (-not (Test-Path -LiteralPath $script:cygpath -PathType Leaf)) { throw ('Configured svncygpath not found: ' + $script:cygpath) }
    } elseif (Test-Path -LiteralPath (Join-Path $svnDirectory 'cygwin1.dll') -PathType Leaf) {
        $script:cygpath = Join-Path $svnDirectory 'cygpath.exe'
        if (-not (Test-Path -LiteralPath $script:cygpath -PathType Leaf)) { throw ('Cygwin SVN needs cygpath.exe beside it: ' + $script:cygpath) }
    }
    $logWriter.WriteLine('Executable: ' + $script:svn)
    if ($script:cygpath) { $logWriter.WriteLine('Cygwin path conversion: ' + $script:cygpath) }
    else { $logWriter.WriteLine('Native Windows path mode') }
    $working = [Environment]::ExpandEnvironmentVariables($config['svnworkingdirectory'])
    if (-not [IO.Path]::IsPathRooted($working)) { $working = Join-Path $PSScriptRoot $working }
    $working = [IO.Path]::GetFullPath($working).TrimEnd('\')
    [xml]$info = Run-Svn @('info', '--xml', '--non-interactive', '--', ($working + '@'))
    $repoRoot = [string]$info.info.entry.repository.root
    if (([Uri]$repoRoot).Scheme -ne 'file') { throw 'This working copy belongs to a remote repository. Only local file:// repositories are allowed.' }
    if ($config['svnrepository']) {
        $repository = [Environment]::ExpandEnvironmentVariables($config['svnrepository'])
        if (-not [IO.Path]::IsPathRooted($repository)) { $repository = Join-Path $PSScriptRoot $repository }
        $repositoryPath = ([Uri]$repoRoot).LocalPath
        if ($script:cygpath) { $repositoryPath = Convert-CygPath $repositoryPath '-w' }
        if ([IO.Path]::GetFullPath($repositoryPath).TrimEnd('\') -ine [IO.Path]::GetFullPath($repository).TrimEnd('\')) { throw 'Configured svnrepository differs from the checkout repository.' }
    }
    $layout = $config['svnlayout']
    if ($layout -notin @('flat', 'paths')) { throw 'svnlayout must be flat or paths.' }
    $records = [IO.File]::ReadAllLines($Request, [Text.Encoding]::Default)
    $items = @()
    $targetsSeen = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    for ($i=0; $i -lt $records.Length; $i++) {
        if (-not $records[$i].StartsWith('S')) { continue }
        $source = [IO.Path]::GetFullPath($records[$i].Substring(1))
        $snapshot = ''
        if ($i+1 -lt $records.Length -and $records[$i+1].StartsWith('B')) { $snapshot = $records[$i+1].Substring(1); $i++ }
        $message = $config['svnmessage']
        if ($i+1 -lt $records.Length -and $records[$i+1].StartsWith('M')) { $message = $records[$i+1].Substring(1); $i++ }
        $inputFile = $source
        if ($snapshot) { $inputFile = $snapshot }
        if (-not (Test-Path -LiteralPath $inputFile -PathType Leaf)) { throw ('Source or snapshot missing: ' + $source) }
        if ($layout -eq 'flat') { $relative = [IO.Path]::GetFileName($source) }
        else { $relative = $source.Replace(':', '').TrimStart('\') }
        $destination = [IO.Path]::GetFullPath((Join-Path $working $relative))
        if (-not $destination.StartsWith($working + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Destination escaped the configured working directory.' }
        if ($relative.Split('\') -contains '.svn' -or $relative.Split('\') -contains '_svn') { throw 'SVN administrative files cannot be uploaded.' }
        if (-not $targetsSeen.Add($destination)) { $logWriter.WriteLine('Shared destination, last source wins: ' + $destination) }
        $items += [pscustomobject]@{Source=$source;Input=$inputFile;Target=$destination;Message=$message}
    }
    # Keep the last source for each shared destination in flat mode.
    $lastItems = @{}
    foreach ($item in $items) { $lastItems[$item.Target] = $item }
    $items = @($items | Where-Object { [object]::ReferenceEquals($_, $lastItems[$_.Target]) })
    if ($items.Count -eq 0) { throw 'There are no files to upload in this scope.' }
    # All validation above finishes before writing working-copy files.
    $commitTargets = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    $targetFile = Join-Path $PSScriptRoot 'proj0200_svn_targets.txt'
    $messageFile = Join-Path $PSScriptRoot 'proj0200_svn_message.txt'
    function Commit-Selected([string]$message) {
        [IO.File]::WriteAllLines($targetFile, @($commitTargets | Sort-Object | ForEach-Object { Convert-SvnPath ($_ + '@') }), (New-Object Text.UTF8Encoding($false)))
        [IO.File]::WriteAllText($messageFile, $message, (New-Object Text.UTF8Encoding($false)))
        $null = Run-Svn @('commit', '--depth', 'empty', '--targets', $targetFile, '--file', $messageFile, '--encoding', 'UTF-8', '--non-interactive')
    }
    foreach ($item in $items) {
        $parent = [IO.Path]::GetDirectoryName($item.Target)
        [IO.Directory]::CreateDirectory($parent) | Out-Null
        if ($item.Input -ine $item.Target) { [IO.File]::Copy($item.Input, $item.Target, $true) }
        $null = Run-Svn @('add', '--parents', '--force', '--depth', 'empty', '--non-interactive', '--', ($item.Target + '@'))
        $null = $commitTargets.Add($item.Target)
        while ($parent.StartsWith($working + '\', [StringComparison]::OrdinalIgnoreCase)) {
            [xml]$state = Run-Svn @('status', '--xml', '--depth', 'empty', '--', ($parent + '@'))
            if ([string]$state.status.target.entry.'wc-status'.item -eq 'added') { $null = $commitTargets.Add($parent) }
            $parent = [IO.Path]::GetDirectoryName($parent)
        }
        if ($config['automatic'] -eq '0') {
            Commit-Selected $item.Message
            $commitTargets.Clear()
        }
    }
    if ($config['automatic'] -ne '0') { Commit-Selected $config['svnmessage'] }
    [IO.File]::WriteAllText($Status, ('OK: uploaded ' + $items.Count + ' file(s) to local Subversion.'), [Text.Encoding]::Default)
} catch {
    $logWriter.WriteLine($_.Exception.Message)
    [IO.File]::WriteAllText($Status, ('ERROR: ' + $_.Exception.Message), [Text.Encoding]::Default)
    exit 1
} finally { $logWriter.Dispose() }
