# PROJ0200 1.0.0.0.151 - OpenAI Codex (GPT-6)
# Adapted from updaficd.s: copy, add, commit, optional push via Cygwin Bash.
param([string]$Request, [string]$Settings, [string]$Log, [string]$Status)
$ErrorActionPreference = 'Stop'
$logWriter = New-Object IO.StreamWriter($Log, $false, [Text.Encoding]::Default)
$script:cygpath = ''
$script:bash = ''
$script:pathCache = @{}
$script:working = ''
$script:lastGitExit = 0
$utf8 = New-Object Text.UTF8Encoding($false)
function Convert-GitPath([string]$path) {
    if (-not $script:cygpath -or $path -notmatch '^(?:[A-Za-z]:[\\/]|\\\\)') { return $path }
    if (-not $script:pathCache.ContainsKey($path)) {
        $oldPreference = $ErrorActionPreference
        try { $ErrorActionPreference = 'Continue'; $result = @(& $script:cygpath '-u' '--' $path 2>&1); $code = $LASTEXITCODE }
        finally { $ErrorActionPreference = $oldPreference }
        if ($code -ne 0 -or $result.Count -ne 1) { throw ('cygpath failed for ' + $path) }
        $script:pathCache[$path] = ([string]$result[0]).Trim()
        $logWriter.WriteLine('Path: ' + $path + ' -> ' + $script:pathCache[$path])
    }
    return $script:pathCache[$path]
}
function Run-Git([string[]]$arguments, [int[]]$allowed = @(0)) {
    $callArguments = @('--literal-pathspecs', '-C', (Convert-GitPath $script:working)) + $arguments
    $logWriter.WriteLine('Git: ' + $script:git + ' ' + ($callArguments -join ' '))
    $oldPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        if ($script:bash) {
            # Script arguments remain separate; no messages or filenames become shell code.
            $output = @(& $script:bash '--login' (Convert-GitPath $script:runner) (Convert-GitPath $script:git) @callArguments 2>&1)
        } else { $output = @(& $script:git @callArguments 2>&1) }
        $script:lastGitExit = $LASTEXITCODE
    } finally { $ErrorActionPreference = $oldPreference }
    foreach ($line in $output) { $logWriter.WriteLine([string]$line) }
    if ($script:lastGitExit -notin $allowed) { throw ('Git failed (exit ' + $script:lastGitExit + '): ' + ($arguments -join ' ')) }
    return ($output -join "`n")
}
try {
    $config = @{}
    foreach ($line in [IO.File]::ReadAllLines($Settings, [Text.Encoding]::Default)) {
        $parts = $line -split '=',2
        if ($parts.Length -eq 2) { $config[$parts[0]] = $parts[1] }
    }
    $executable = [Environment]::ExpandEnvironmentVariables($config['gitexe'])
    if (-not [IO.Path]::IsPathRooted($executable) -and (Test-Path -LiteralPath (Join-Path $PSScriptRoot $executable))) { $executable = Join-Path $PSScriptRoot $executable }
    $script:git = (Get-Command $executable -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source
    $bin = [IO.Path]::GetDirectoryName($script:git)
    $cygwin = Test-Path -LiteralPath (Join-Path $bin 'cygwin1.dll') -PathType Leaf
    $script:cygpath = $config['gitcygpath']
    $script:bash = $config['gitbash']
    if ($cygwin) {
        if (-not $script:cygpath) { $script:cygpath = Join-Path $bin 'cygpath.exe' }
        if (-not $script:bash) { $script:bash = Join-Path $bin 'bash.exe' }
    }
    foreach ($name in @('cygpath','bash')) {
        $value = Get-Variable -Name $name -Scope Script -ValueOnly
        if ($value) {
            $value = [Environment]::ExpandEnvironmentVariables($value)
            if (-not [IO.Path]::IsPathRooted($value)) { $value = Join-Path $PSScriptRoot $value }
            if (-not (Test-Path -LiteralPath $value -PathType Leaf)) { throw ('Git helper executable missing: ' + $value) }
            Set-Variable -Name $name -Scope Script -Value $value
        }
    }
    $script:runner = Join-Path $PSScriptRoot 'proj0200_git_runner.sh'
    if ($script:bash) { [IO.File]::WriteAllText($script:runner, "#!/bin/bash`nexec `"`$@`"`n", $utf8) }
    $logWriter.WriteLine('Executable: ' + $script:git)
    $logWriter.WriteLine('Bash: ' + $script:bash)
    $script:working = [Environment]::ExpandEnvironmentVariables($config['gitworkingdirectory'])
    if (-not [IO.Path]::IsPathRooted($script:working)) { $script:working = Join-Path $PSScriptRoot $script:working }
    $script:working = [IO.Path]::GetFullPath($script:working).TrimEnd('\')
    if ((Run-Git @('rev-parse','--is-inside-work-tree')).Trim() -ne 'true') { throw 'gitworkingdirectory must be an existing non-bare Git working tree.' }
    $null = Run-Git @('var','GIT_AUTHOR_IDENT')
    $null = Run-Git @('var','GIT_COMMITTER_IDENT')
    $push = $config['gitpush'] -eq 'true'
    $remote = $config['gitremote']
    if (-not $remote) { $remote = 'origin' }
    $branch = $config['gitbranch']
    if (-not $branch) { $branch = (Run-Git @('symbolic-ref','--quiet','--short','HEAD')).Trim() }
    if ($push) {
        if ($remote.StartsWith('-') -or $branch.StartsWith('-')) { throw 'Remote and branch cannot start with a dash.' }
        $null = Run-Git @('remote','get-url',$remote)
        $null = Run-Git @('check-ref-format',('refs/heads/' + $branch))
    }
    # Probe option support before modifying any destination or index.
    $help = Run-Git @('commit','-h') @(0,129)
    if ($help -notmatch 'pathspec-from-file') { throw 'This Git version lacks --pathspec-from-file. Update Cygwin Git.' }
    $help = Run-Git @('add','-h') @(0,129)
    if ($help -notmatch 'pathspec-from-file') { throw 'This Git version lacks git add --pathspec-from-file. Update Cygwin Git.' }
    $layout = $config['gitlayout']
    if ($layout -notin @('flat','paths')) { throw 'gitlayout must be flat or paths.' }
    $records = [IO.File]::ReadAllLines($Request, [Text.Encoding]::Default)
    $items = @()
    for ($i=0; $i -lt $records.Length; $i++) {
        if (-not $records[$i].StartsWith('S')) { continue }
        $source = [IO.Path]::GetFullPath($records[$i].Substring(1))
        $inputFile = $source
        if ($i+1 -lt $records.Length -and $records[$i+1].StartsWith('B')) { $inputFile=$records[++$i].Substring(1) }
        $message = $config['gitmessage']
        if ($i+1 -lt $records.Length -and $records[$i+1].StartsWith('M')) { $message=$records[++$i].Substring(1) }
        if (-not (Test-Path -LiteralPath $inputFile -PathType Leaf)) { throw ('Missing source: ' + $source) }
        if ($layout -eq 'flat') { $relative = [IO.Path]::GetFileName($source) }
        else { $relative = $source.Replace(':','').TrimStart('\') }
        if ($relative.Split('\') -contains '.git') { throw 'Git administrative paths cannot be uploaded.' }
        $target = [IO.Path]::GetFullPath((Join-Path $script:working $relative))
        if (-not $target.StartsWith($script:working + '\',[StringComparison]::OrdinalIgnoreCase)) { throw 'Destination escaped Git working directory.' }
        $items += [pscustomobject]@{Source=$source;Input=$inputFile;Target=$target;Relative=$relative.Replace('\','/');Message=$message}
    }
    $lastItems=@{}
    foreach ($item in $items) {
        if ($lastItems.ContainsKey($item.Target)) { $logWriter.WriteLine('Shared destination, last source wins: ' + $item.Target) }
        $lastItems[$item.Target]=$item
    }
    $items=@($items | Where-Object { [object]::ReferenceEquals($_,$lastItems[$_.Target]) })
    if (-not $items.Count) { throw 'No files to upload.' }
    $targetFile=Join-Path $PSScriptRoot 'proj0200_git_targets.txt'
    $messageFile=Join-Path $PSScriptRoot 'proj0200_git_message.txt'
    $script:commits=0
    function Commit-Files($selected,[string]$message) {
        $names=@($selected | ForEach-Object { $_.Relative })
        [IO.File]::WriteAllText($targetFile, (($names -join [char]0) + [char]0), $utf8)
        $pathOption='--pathspec-from-file=' + (Convert-GitPath $targetFile)
        $null=Run-Git @('add',$pathOption,'--pathspec-file-nul')
        $null=Run-Git @('rev-parse','--verify','HEAD') @(0,128)
        $hasHead=$script:lastGitExit -eq 0
        $changed=-not $hasHead
        if ($hasHead) {
            foreach ($name in $names) {
                $null=Run-Git @('diff','--quiet','HEAD','--',$name) @(0,1)
                if ($script:lastGitExit -eq 1) { $changed=$true; break }
            }
        }
        if (-not $changed) { $logWriter.WriteLine('Selected files unchanged; no new commit.'); return }
        [IO.File]::WriteAllText($messageFile,$message,$utf8)
        $null=Run-Git @('commit','--only',$pathOption,'--pathspec-file-nul','--file',(Convert-GitPath $messageFile))
        $script:commits++
    }
    foreach ($item in $items) {
        [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($item.Target)) | Out-Null
        if ($item.Input -ine $item.Target) { [IO.File]::Copy($item.Input,$item.Target,$true) }
        $logWriter.WriteLine('Copied: ' + $item.Source + ' -> ' + $item.Target)
        if ($config['automatic'] -eq '0') { Commit-Files @($item) $item.Message }
    }
    if ($config['automatic'] -ne '0') { Commit-Files $items $config['gitmessage'] }
    if ($push) { $null=Run-Git @('push','--',$remote,('HEAD:refs/heads/' + $branch)) }
    $result='OK: processed ' + $items.Count + ' file(s); created ' + $script:commits + ' Git commit(s).'
    if ($push) { $result+=' Remote push succeeded.' }
    [IO.File]::WriteAllText($Status,$result,[Text.Encoding]::Default)
} catch {
    $logWriter.WriteLine($_.Exception.Message)
    [IO.File]::WriteAllText($Status,('ERROR: ' + $_.Exception.Message),[Text.Encoding]::Default)
    exit 1
} finally { $logWriter.Dispose() }
