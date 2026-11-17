# leastsquaresline.ps1 - version 1.0.0.0.5
# Floating-point least squares line with an interactive, resizable Windows XY plot.
param(
    [Parameter(Mandatory=$true)][string]$IniPath
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()
$culture = [System.Globalization.CultureInfo]::InvariantCulture
$styles = [System.Globalization.NumberStyles]::Float

function Show-Failure([string]$message) {
    [void][System.Windows.Forms.MessageBox]::Show(
        $message, 'Least Squares Line - input error',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error)
}
function Format-Number([double]$value) {
    return $value.ToString('0.######', $culture)
}
function Parse-Number([string]$value) {
    $parsed = 0.0
    if (-not [double]::TryParse($value, $styles, $culture, [ref]$parsed) -or
        [double]::IsNaN($parsed) -or [double]::IsInfinity($parsed)) {
        throw "Invalid numeric value '$value'. Use '.' as decimal separator."
    }
    return $parsed
}
function Get-Inputs([string]$path) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "INI file not found: $path" }
    $section = ''
    $settings = @{}
    foreach ($rawLine in [System.IO.File]::ReadAllLines($path)) {
        $line = $rawLine.Trim()
        if ($line.Length -eq 0 -or $line.StartsWith(';') -or $line.StartsWith('#')) { continue }
        if ($line -match '^\[([^\]]+)\]$') { $section = $Matches[1].Trim(); continue }
        if ($section -ine 'parameters') { continue }
        if ($line -match '^([^=]+)=(.*)$') {
            $settings[$Matches[1].Trim().ToLowerInvariant()] = $Matches[2].Trim()
        }
    }
    if (-not $settings.ContainsKey('n') -or $settings['n'] -notmatch '^\d+$') {
        throw 'N must be an integer greater than or equal to 2.'
    }
    $n = [int]::Parse($settings['n'], $culture)
    if ($n -lt 2) { throw 'N must be at least 2.' }
    if (-not $settings.ContainsKey('xypoints')) { throw 'Missing xypoints in [parameters].' }
    if (-not $settings.ContainsKey('xpredictionvalue')) { throw 'Missing xpredictionvalue in [parameters].' }
    [double]$xPrediction = Parse-Number $settings['xpredictionvalue']
    $source = $settings['xypoints']
    $pattern = '\(\s*([+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?)\s*,\s*([+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?)\s*\)'
    $pointMatches = [regex]::Matches($source, $pattern)
    $remaining = [regex]::Replace($source, $pattern, '')
    if ($remaining -notmatch '^\s*(?:,\s*)*$') {
        throw 'Invalid xypoints. Format: (1,2) (2,3) (3,5) (4,6).'
    }
    if ($pointMatches.Count -ne $n) {
        throw "N=$n but exactly $($pointMatches.Count) valid (x,y) pairs were supplied."
    }
    $points = New-Object 'System.Collections.Generic.List[object]'
    foreach ($m in $pointMatches) {
        $points.Add([pscustomobject]@{
            X = [double](Parse-Number $m.Groups[1].Value)
            Y = [double](Parse-Number $m.Groups[2].Value)
        })
    }
    return [pscustomobject]@{ Points = $points.ToArray(); XPrediction = $xPrediction }
}

try {
    $inputData = Get-Inputs $IniPath
    $points = @($inputData.Points)
    [double]$xPrediction = $inputData.XPrediction
    $n = $points.Count
    # Explicitly implement the specified summation formulas in double precision.
    [double]$sumxsquared = 0.0
    [double]$sumx = 0.0
    [double]$sumy = 0.0
    [double]$sumxy = 0.0
    foreach ($p in $points) {
        $sumxsquared += $p.X * $p.X
        $sumx += $p.X
        $sumy += $p.Y
        $sumxy += $p.X * $p.Y
    }
    [double]$denom = $n * $sumxsquared - $sumx * $sumx
    [double]$scale = [Math]::Max(1.0, [Math]::Max([Math]::Abs($n * $sumxsquared), [Math]::Abs($sumx * $sumx)))
    if ([Math]::Abs($denom) -le 1e-12 * $scale) {
        throw 'A unique slope cannot be calculated: all X coordinates are identical (or nearly so).'
    }
    [double]$A = ($n * $sumxy - $sumx * $sumy) / $denom
    [double]$B = ($sumxsquared * $sumy - $sumx * $sumxy) / $denom
    [double]$sse = 0.0
    foreach ($p in $points) {
        [double]$resid = $p.Y - ($A * $p.X + $B)
        $sse += $resid * $resid
    }
    if ([double]::IsNaN($A) -or [double]::IsInfinity($A) -or
        [double]::IsNaN($B) -or [double]::IsInfinity($B)) {
        throw 'The numerical calculation overflowed. Use smaller coordinate magnitudes.'
    }
    [double]$yPrediction = $A * $xPrediction + $B
    if ([double]::IsNaN($yPrediction) -or [double]::IsInfinity($yPrediction)) {
        throw 'The predicted Y value overflowed. Use a smaller prediction X value.'
    }
} catch {
    Show-Failure $_.Exception.Message
    exit 1
}

$minX = [double](($points | Measure-Object -Property X -Minimum).Minimum)
$maxX = [double](($points | Measure-Object -Property X -Maximum).Maximum)
$minX = [Math]::Min($minX, $xPrediction)
$maxX = [Math]::Max($maxX, $xPrediction)
$minY = [double](($points | Measure-Object -Property Y -Minimum).Minimum)
$maxY = [double](($points | Measure-Object -Property Y -Maximum).Maximum)
$minY = [Math]::Min($minY, $yPrediction)
$maxY = [Math]::Max($maxY, $yPrediction)
# Include the calculated regression line within the plot's X extent.
$minY = [Math]::Min($minY, [Math]::Min(($A * $minX + $B), ($A * $maxX + $B)))
$maxY = [Math]::Max($maxY, [Math]::Max(($A * $minX + $B), ($A * $maxX + $B)))
$spanX = [Math]::Max(1e-6, $maxX - $minX)
$spanY = [Math]::Max(1e-6, $maxY - $minY)
$minX -= 0.12 * $spanX; $maxX += 0.12 * $spanX
$minY -= 0.15 * $spanY; $maxY += 0.15 * $spanY
$spanX = $maxX - $minX
$spanY = $maxY - $minY

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Least Squares Line - N=' + $n
$form.ClientSize = New-Object System.Drawing.Size(980,700)
$form.StartPosition = 'CenterScreen'
$form.MinimumSize = New-Object System.Drawing.Size(550,420)
$form.BackColor = [System.Drawing.Color]::White
$form.KeyPreview = $true

$header = New-Object System.Windows.Forms.Label
$header.Dock = 'Top'
$header.Height = 92
$header.Padding = New-Object System.Windows.Forms.Padding(16,9,6,4)
$header.Font = New-Object System.Drawing.Font('Segoe UI',13,[System.Drawing.FontStyle]::Bold)
$sign = if ($B -ge 0) { '+' } else { '-' }
$header.Text = 'Least squares fit: y = ' + (Format-Number $A) + ' x ' + $sign + ' ' + (Format-Number ([Math]::Abs($B))) +
    [Environment]::NewLine + 'N = ' + $n + '      A (slope) = ' + (Format-Number $A) +
    '      B (intercept) = ' + (Format-Number $B) + '      Sum of squared residuals = ' + (Format-Number $sse) +
    [Environment]::NewLine + 'Prediction: x = ' + (Format-Number $xPrediction) + '      y = ' + (Format-Number $yPrediction)
$form.Controls.Add($header)

# Buffered Panel reduces flickering during resize.
Add-Type -TypeDefinition @'
using System.Windows.Forms;
using System.Drawing;
public class LeastSquaresCanvas : Panel {
    public bool BufferingEnabled { get { return this.DoubleBuffered; } }
    public LeastSquaresCanvas() { this.DoubleBuffered = true; this.ResizeRedraw = true; }
}
'@ -ReferencedAssemblies 'System.Windows.Forms','System.Drawing'
$canvas = New-Object LeastSquaresCanvas
$canvas.Dock = 'Fill'
$canvas.BackColor = [System.Drawing.Color]::White
$form.Controls.Add($canvas)
$canvas.BringToFront()
$header.BringToFront()

$canvas.Add_Paint({
    param($sender, $e)
    $g = $e.Graphics
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $width = [double]$sender.ClientSize.Width
    $height = [double]$sender.ClientSize.Height
    $left = 83.0; $right = 31.0; $top = 25.0; $bottom = 66.0
    $plotW = [Math]::Max(1, $width - $left - $right)
    $plotH = [Math]::Max(1, $height - $top - $bottom)
    $toX = { param([double]$x) [single]($left + ($x - $minX) / $spanX * $plotW) }
    $toY = { param([double]$y) [single]($top + ($maxY - $y) / $spanY * $plotH) }
    $gridPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(230,233,238),1)
    $axisPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(100,108,120),1.3)
    $linePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(25,100,215),2.8)
    $pointBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(215,65,54))
    $predictionBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(32,140,78))
    $textBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(52,61,71))
    $font = New-Object System.Drawing.Font('Segoe UI',9)
    try {
        for ($i = 0; $i -le 8; $i++) {
            [double]$vx = $minX + $spanX * $i / 8.0
            [single]$px = & $toX $vx
            $g.DrawLine($gridPen,$px,[single]$top,$px,[single]($top + $plotH))
            $label = Format-Number $vx
            $g.DrawString($label,$font,$textBrush,[single]($px - 20),[single]($top + $plotH + 10))
        }
        for ($i = 0; $i -le 8; $i++) {
            [double]$vy = $minY + $spanY * $i / 8.0
            [single]$py = & $toY $vy
            $g.DrawLine($gridPen,[single]$left,$py,[single]($left + $plotW),$py)
            $label = Format-Number $vy
            $g.DrawString($label,$font,$textBrush,7,[single]($py - 8))
        }
        if ($minX -le 0 -and $maxX -ge 0) {
            [single]$zeroX = & $toX 0
            $g.DrawLine($axisPen,$zeroX,[single]$top,$zeroX,[single]($top + $plotH))
        }
        if ($minY -le 0 -and $maxY -ge 0) {
            [single]$zeroY = & $toY 0
            $g.DrawLine($axisPen,[single]$left,$zeroY,[single]($left + $plotW),$zeroY)
        }
        [single]$lx1 = & $toX $minX
        [single]$ly1 = & $toY ($A * $minX + $B)
        [single]$lx2 = & $toX $maxX
        [single]$ly2 = & $toY ($A * $maxX + $B)
        $g.DrawLine($linePen,$lx1,$ly1,$lx2,$ly2)
        foreach ($p in $points) {
            [single]$px = & $toX $p.X
            [single]$py = & $toY $p.Y
            $g.FillEllipse($pointBrush,[single]($px - 5),[single]($py - 5),10,10)
            $g.DrawString(('(' + (Format-Number $p.X) + ', ' + (Format-Number $p.Y) + ')'),
                $font,$textBrush,[single]($px + 7),[single]($py - 22))
        }
        [single]$predX = & $toX $xPrediction
        [single]$predY = & $toY $yPrediction
        $g.FillEllipse($predictionBrush,[single]($predX - 6),[single]($predY - 6),12,12)
        $g.DrawString(('prediction (' + (Format-Number $xPrediction) + ', ' + (Format-Number $yPrediction) + ')'),
            $font,$textBrush,[single]($predX + 8),[single]($predY - 24))
        $g.DrawString('X',$font,$textBrush,[single]($left + $plotW - 9),[single]($top + $plotH + 36))
        $g.DrawString('Y',$font,$textBrush,18,1)
        $g.DrawString('Blue = least squares line       Red = input XY points       Green = predicted point',
            $font,$textBrush,[single]$left,[single]($height - 24))
    } finally {
        $gridPen.Dispose(); $axisPen.Dispose(); $linePen.Dispose()
        $pointBrush.Dispose(); $predictionBrush.Dispose(); $textBrush.Dispose(); $font.Dispose()
    }
})
$form.Add_Shown({ $form.Activate() })
[void][System.Windows.Forms.Application]::Run($form)
$form.Dispose()
