# UTF8SHORT 1.0.0.0.4 - OpenAI Codex (GPT-6)
param([string]$Directory = (Join-Path $PSScriptRoot 'samples'))
$ErrorActionPreference = 'Stop'
[IO.Directory]::CreateDirectory($Directory) | Out-Null
foreach ($name in @('ascii.txt', ('caf' + [char]0xe9 + '.txt'),
                    ([string][char]0x4e2d + [char]0x6587 + '.txt'))) {
    $path = Join-Path $Directory $name
    if ([IO.File]::Exists($path)) {
        Write-Host "Already exists; left unchanged: $path"
    } else {
        [IO.File]::WriteAllText($path, "Hello from UTF8SHORT 1.0.0.0.4!`r`n", [Text.Encoding]::ASCII)
        Write-Host "Created: $path"
    }
}
