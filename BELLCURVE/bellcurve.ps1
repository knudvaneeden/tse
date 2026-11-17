# bellcurve.ps1 - version 1.0.0.0.1
# Windows PowerShell 5.1, Windows Forms + System.Drawing, no external modules.
param(
    [Parameter(Mandatory=$true)][int]$N,
    [Parameter(Mandatory=$true)][string]$Data
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

function Show-Problem([string]$message) {
    [void][System.Windows.Forms.MessageBox]::Show($message, 'Bell curve - input error',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error)
}

try {
    if ($N -lt 2) { throw 'N must be at least 2.' }
    $parts = @($Data -split ',')
    if ($parts.Count -ne $N) {
        throw ('N = {0}, but {1} comma-separated data values were supplied.' -f $N, $parts.Count)
    }
    $culture = [System.Globalization.CultureInfo]::InvariantCulture
    $numberStyle = [System.Globalization.NumberStyles]::Float
    [double[]]$values = @()
    foreach ($part in $parts) {
        [double]$number = 0
        if (-not [double]::TryParse($part.Trim(), $numberStyle, $culture, [ref]$number)) {
            throw ('Invalid numeric data point: "{0}". Use decimal points, not decimal commas.' -f $part)
        }
        if ([double]::IsNaN($number) -or [double]::IsInfinity($number)) {
            throw 'Data points must be finite numbers.'
        }
        $values += $number
    }
    [double]$mean = 0.0
    foreach ($number in $values) { $mean += $number }
    $mean /= $N

    [double]$sumSquaredDifferences = 0.0
    foreach ($number in $values) {
        $difference = $number - $mean
        $sumSquaredDifferences += $difference * $difference
    }
    [double]$variance = $sumSquaredDifferences / $N
    [double]$standardDeviation = [Math]::Sqrt($variance)
    if ($standardDeviation -le 0) { throw 'All data points are identical; standard deviation is zero, so a normal density curve is undefined.' }

    $pdf = { param([double]$x)
        $z = ($x - $mean) / $standardDeviation
        (1.0 / ($standardDeviation * [Math]::Sqrt(2.0 * [Math]::PI))) * [Math]::Exp(-0.5 * $z * $z)
    }
    [double]$minData = ($values | Measure-Object -Minimum).Minimum
    [double]$maxData = ($values | Measure-Object -Maximum).Maximum
    [double]$xMin = [Math]::Min($minData, $mean - 3.7 * $standardDeviation)
    [double]$xMax = [Math]::Max($maxData, $mean + 3.7 * $standardDeviation)
    [double]$pad = ($xMax - $xMin) * 0.04
    $xMin -= $pad
    $xMax += $pad
    [double]$peak = & $pdf $mean
    [double]$yMax = $peak * 1.22

    $form = New-Object System.Windows.Forms.Form
    $form.Text = ('Bell curve - N={0}, mean={1:N4}, standard deviation={2:N4}' -f $N, $mean, $standardDeviation)
    $form.StartPosition = 'CenterScreen'
    $form.ClientSize = [System.Drawing.Size]::new(1080,720)
    $form.MinimumSize = [System.Drawing.Size]::new(700,480)
    $form.BackColor = [System.Drawing.Color]::White
    $form.Add_Paint({
        param($sender, $e)
        $g = $e.Graphics
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $w = [double]$form.ClientSize.Width
        $h = [double]$form.ClientSize.Height
        $left = 92.0; $right = $w - 40.0; $top = 110.0; $bottom = $h - 105.0
        if ($right -le $left -or $bottom -le $top) { return }
        $toX = { param([double]$x) [float]($left + ($x - $xMin) / ($xMax - $xMin) * ($right-$left)) }
        $toY = { param([double]$y) [float]($bottom - ($y / $yMax) * ($bottom-$top)) }
        $axisPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(70,70,70), 1.5)
        $gridPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(230,230,230), 1)
        $curvePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(30,105,210), 3)
        $meanPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(200,75,65), 1.5)
        $meanPen.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash
        $font = New-Object System.Drawing.Font('Segoe UI',10)
        $smallFont = New-Object System.Drawing.Font('Segoe UI',9)
        $titleFont = New-Object System.Drawing.Font('Segoe UI',15,[System.Drawing.FontStyle]::Bold)
        $brush = [System.Drawing.Brushes]::Black
        $blueBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30,105,210))
        $dotBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(235,135,30))
        try {
            $g.DrawString('Normal bell curve fitted to the data points',$titleFont,$brush,18,14)
            $g.DrawString(('N = {0}     Mean = {1:G7}     Variance (population) = {2:G7}     Standard deviation = {3:G7}' -f $N,$mean,$variance,$standardDeviation),$font,$brush,20,53)
            for ($i=0; $i -le 5; $i++) {
                $yy = $yMax * $i / 5.0
                $py = & $toY $yy
                $g.DrawLine($gridPen,[float]$left,$py,[float]$right,$py)
                $g.DrawString($yy.ToString('0.0000',$culture),$smallFont,$brush,8,[float]($py-8))
            }
            $g.DrawLine($axisPen,[float]$left,[float]$top,[float]$left,[float]$bottom)
            $g.DrawLine($axisPen,[float]$left,[float]$bottom,[float]$right,[float]$bottom)
            for ($i=0; $i -le 10; $i++) {
                $xx = $xMin + ($xMax-$xMin)*$i/10.0
                $px = & $toX $xx
                $g.DrawLine($axisPen,$px,[float]$bottom,$px,[float]($bottom+5))
                $s = $xx.ToString('0.##',$culture)
                $g.DrawString($s,$smallFont,$brush,[float]($px-14),[float]($bottom+9))
            }
            $g.DrawString('X (data values)',$font,$brush,[float](($left+$right)/2-48),[float]($h-50))
            $g.DrawString('Probability density',$smallFont,$brush,8,89)
            $g.DrawLine($meanPen,(& $toX $mean),[float]$top,(& $toX $mean),[float]$bottom)
            $g.DrawString(('mean = {0:G5}' -f $mean),$smallFont,[System.Drawing.Brushes]::Firebrick,[float]((& $toX $mean)+5),[float]($top+6))
            $previous = $null
            for ($i=0; $i -le 700; $i++) {
                $xx = $xMin + ($xMax-$xMin)*$i/700.0
                $yy = & $pdf $xx
                $p = [System.Drawing.PointF]::new((& $toX $xx),(& $toY $yy))
                if ($null -ne $previous) { $g.DrawLine($curvePen,$previous,$p) }
                $previous = $p
            }
            # Orange data points shown as a 'rug' on the X axis; duplicates stack.
            $positions = @{}
            foreach ($number in ($values | Sort-Object)) {
                $key = $number.ToString('R',$culture)
                if (-not $positions.ContainsKey($key)) { $positions[$key] = 0 }
                $j = [int]$positions[$key]
                $positions[$key] = $j + 1
                $px = & $toX $number
                $py = [float]($bottom-9-($j*13))
                $g.FillEllipse($dotBrush,[float]($px-5),[float]($py-5),10.0,10.0)
            }
            $g.FillEllipse($dotBrush,[float]($left+8),[float]($h-75),10.0,10.0)
            $g.DrawString('Observed data points (duplicates stacked)',$smallFont,$brush,[float]($left+23),[float]($h-78))
            $g.DrawLine($curvePen,[float]($left+380),[float]($h-70),[float]($left+425),[float]($h-70))
            $g.DrawString('Normal probability density',$smallFont,$brush,[float]($left+435),[float]($h-78))
        } finally {
            $axisPen.Dispose(); $gridPen.Dispose(); $curvePen.Dispose(); $meanPen.Dispose()
            $font.Dispose(); $smallFont.Dispose(); $titleFont.Dispose(); $blueBrush.Dispose(); $dotBrush.Dispose()
        }
    })
    [void][System.Windows.Forms.Application]::Run($form)
} catch {
    Show-Problem $_.Exception.Message
    exit 1
}
