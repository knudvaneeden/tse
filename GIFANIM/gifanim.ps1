param(
 [string]$FrameDirectory = '',
 [string]$OutputFile = '01.gif',
 [string]$OutputDirectory = '',
 [ValidateRange(1,65535)][int]$DelayCs = 10,
 [string]$Sequence = '*.png',
 [string]$IniFile = 'gifanim.ini'
)
$ErrorActionPreference = 'Stop'
try {
# Resolve the INI and blank frame directory from the script folder.
# SAL resolves relative directories against TSE's CurrDir() before writing the run INI.
if (-not [IO.Path]::IsPathRooted($IniFile)) { $IniFile = Join-Path $PSScriptRoot $IniFile }
Set-Location -LiteralPath $PSScriptRoot
# Plain ASCII INI: one key=value per line; command-line arguments take priority.
if (Test-Path -LiteralPath $IniFile) {
 foreach ($line in [IO.File]::ReadAllLines((Resolve-Path -LiteralPath $IniFile).Path)) {
  if ($line -match '^\s*(directory|sequence|output|outputdirectory|delay_cs)\s*=\s*(.*?)\s*$') {
   $key = $matches[1].ToLowerInvariant(); $value = $matches[2]
   switch ($key) {
    directory { if (-not $PSBoundParameters.ContainsKey('FrameDirectory')) { $FrameDirectory = $value } }
    sequence { if (-not $PSBoundParameters.ContainsKey('Sequence')) { $Sequence = $value } }
    output { if (-not $PSBoundParameters.ContainsKey('OutputFile')) { $OutputFile = $value } }
    outputdirectory { if (-not $PSBoundParameters.ContainsKey('OutputDirectory')) { $OutputDirectory = $value } }
    delay_cs { if (-not $PSBoundParameters.ContainsKey('DelayCs')) { $DelayCs = [int]$value } }
   }
  }
 }
}
if (-not $Sequence) { $Sequence = '*.png' }
if (-not $FrameDirectory) { $FrameDirectory = $PSScriptRoot }
if (-not [IO.Path]::IsPathRooted($FrameDirectory)) {
 $FrameDirectory = Join-Path $PSScriptRoot $FrameDirectory
}
if ($DelayCs -lt 1 -or $DelayCs -gt 65535) { throw 'delay_cs must be 1 through 65535' }
function Get-Frames($extension) {
 $frames = @(Get-ChildItem -LiteralPath $FrameDirectory -File | Where-Object { $_.Name -like $Sequence -and $_.Extension -ieq $extension -and $_.BaseName -match '^_?\d+$' } |
  Sort-Object @{Expression={[long]($_.BaseName -replace '^_', '')}}, @{Expression={$_.Name}})
 if ($frames.Count -eq 0) { throw "GIFANIM_NO_PNG: No numbered $extension frames (optionally prefixed with _) in $FrameDirectory" }
 return $frames
}
function GifParts($path, $targetWidth, $targetHeight) {
 $img = [Drawing.Image]::FromFile($path)
 try {
  $source = $img
  $canvas = $null
  try {
   if ($targetWidth -and $targetHeight -and ($img.Width -ne $targetWidth -or $img.Height -ne $targetHeight)) {
    $canvas = New-Object Drawing.Bitmap($targetWidth, $targetHeight)
    $graphics = [Drawing.Graphics]::FromImage($canvas)
    try {
     $graphics.Clear([Drawing.Color]::Transparent)
     $graphics.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
     $scale = [Math]::Min(($targetWidth / [double]$img.Width), ($targetHeight / [double]$img.Height))
     $width = [Math]::Max(1, [int][Math]::Round($img.Width * $scale))
     $height = [Math]::Max(1, [int][Math]::Round($img.Height * $scale))
     $x = [int][Math]::Floor(($targetWidth - $width) / 2)
     $y = [int][Math]::Floor(($targetHeight - $height) / 2)
     $graphics.DrawImage($img, $x, $y, $width, $height)
    } finally { $graphics.Dispose() }
    $source = $canvas
   }
   $ms = New-Object IO.MemoryStream
   try { $source.Save($ms,[Drawing.Imaging.ImageFormat]::Gif); $b = $ms.ToArray() }
   finally { $ms.Dispose() }
  } finally { if ($canvas) { $canvas.Dispose() } }
 } finally { $img.Dispose() }
 $p = 13; $n = 0
 if ($b[10] -band 128) { $n = 3 * (1 -shl (($b[10] -band 7) + 1)); $p += $n }
 while ($b[$p] -eq 0x21) { $p += 2; do { $len = $b[$p]; $p += 1 + $len } while ($len -ne 0) }
 if ($b[$p] -ne 0x2c) { throw "GIF frame invalid: $path" }
 $start = $p; $p += 10
 if ($b[$start+9] -band 128) { $p += 3 * (1 -shl (($b[$start+9] -band 7) + 1)) }
 $p++
 do { $len = $b[$p]; $p += 1 + $len } while ($len -ne 0)
 return @{ B=$b; Start=$start; End=$p; Palette=$n }
}
 if (-not (Test-Path -LiteralPath $FrameDirectory -PathType Container)) { throw "Folder not found: $FrameDirectory" }
 $FrameDirectory = (Resolve-Path -LiteralPath $FrameDirectory).Path
 # A configured output directory overrides the location in output=.
 if ($OutputDirectory) {
  if (-not [IO.Path]::IsPathRooted($OutputDirectory)) {
   $OutputDirectory = Join-Path $PSScriptRoot $OutputDirectory
  }
  if (-not (Test-Path -LiteralPath $OutputDirectory -PathType Container)) { throw "Output folder not found: $OutputDirectory" }
  $OutputFile = Join-Path $OutputDirectory ([IO.Path]::GetFileName($OutputFile))
 } elseif (-not [IO.Path]::IsPathRooted($OutputFile)) {
  $OutputFile = Join-Path $FrameDirectory $OutputFile
 }
 $OutputFile = [IO.Path]::GetFullPath($OutputFile)
 $frames = @(Get-Frames '.png')
  Add-Type -AssemblyName System.Drawing
  # First pass: choose the largest source frame by pixel area.
  # Second pass below: scale every frame to fit its dimensions.
  $bestArea = 0.0
  foreach ($frame in $frames) {
   $probe = [Drawing.Image]::FromFile($frame.FullName)
   try {
    $area = [double]$probe.Width * $probe.Height
    if ($area -gt $bestArea) {
     $bestArea = $area
     $targetWidth = $probe.Width
     $targetHeight = $probe.Height
    }
   } finally { $probe.Dispose() }
  }
  if ($targetWidth -gt 65535 -or $targetHeight -gt 65535) { throw 'GIF frame dimensions must not exceed 65535 pixels' }
  $first = GifParts $frames[0].FullName $targetWidth $targetHeight
  $out = New-Object IO.MemoryStream
  try {
   $out.Write($first.B,0,(13 + $first.Palette))
   foreach ($frame in $frames) {
    $part = GifParts $frame.FullName $targetWidth $targetHeight; $b = $part.B; $start = $part.Start
    if ($b[6] -ne $first.B[6] -or $b[7] -ne $first.B[7] -or $b[8] -ne $first.B[8] -or $b[9] -ne $first.B[9]) { throw "Frame dimensions differ: $($frame.Name)" }
    [byte[]]$gce = @(0x21,0xf9,0x04,0x08,($DelayCs -band 255),(($DelayCs -shr 8) -band 255),0,0)
    $out.Write($gce,0,8)
    if (($b[$start+9] -band 128) -eq 0) {
     [byte[]]$desc = New-Object byte[] 10
     [Array]::Copy($b,$start,$desc,0,10)
     $desc[9] = [byte](0x80 -bor ($b[10] -band 7))
     $out.Write($desc,0,10); $out.Write($b,13,$part.Palette)
     $out.Write($b,$start+10,$part.End-$start-10)
    } else { $out.Write($b,$start,$part.End-$start) }
   }
   $out.WriteByte(0x3b)
   [IO.File]::WriteAllBytes($OutputFile,$out.ToArray())
  } finally { $out.Dispose() }
 Write-Host "Created $OutputFile from $($frames.Count) frames at ${targetWidth}x${targetHeight} (PowerShell)."
 exit 0
} catch {
 $message = $_.Exception.Message
 $marker = if ($message -like 'GIFANIM_NO_PNG:*') { 'gifanim_no_png.flag' } else { 'gifanim_error.flag' }
 # INI format lets TSE read the actual error with GetProfileStr().
 $message = $message -replace '[\r\n]+', ' '
 try { [IO.File]::WriteAllText((Join-Path $PSScriptRoot $marker), "[GifAnimError]`r`nmessage=$message`r`n") } catch {}
 [Console]::Error.WriteLine($message)
 exit 1
}
