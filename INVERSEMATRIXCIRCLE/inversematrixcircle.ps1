# INVERSEMATRIXCIRCLE 1.0.0.0.2
# Interactive 2D vector/matrix transformation plot, launched from TSE SAL.
# Requires Windows PowerShell 5.1 or Windows PowerShell with WinForms support.
param(
    [Parameter(Mandatory=$true)][string]$Radius,
    [Parameter(Mandatory=$true)][string]$A11,
    [Parameter(Mandatory=$true)][string]$A12,
    [Parameter(Mandatory=$true)][string]$A21,
    [Parameter(Mandatory=$true)][string]$A22,
    [string]$StepDegrees = '5'
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Convert-ToFiniteDouble([string]$value, [string]$name) {
    $number = 0.0
    # Allow comma decimals typed in TSE as well as dot decimals.
    $normalized = $value.Trim().Replace(',', '.')
    if (-not [double]::TryParse($normalized,
            [System.Globalization.NumberStyles]::Float,
            [System.Globalization.CultureInfo]::InvariantCulture,
            [ref]$number) -or [double]::IsNaN($number) -or [double]::IsInfinity($number)) {
        throw "Invalid numeric value for ${name}: '$value'. Use e.g. -1.25"
    }
    return $number
}

try {
    $r = Convert-ToFiniteDouble $Radius 'R'
    $m11 = Convert-ToFiniteDouble $A11 'a11'
    $m12 = Convert-ToFiniteDouble $A12 'a12'
    $m21 = Convert-ToFiniteDouble $A21 'a21'
    $m22 = Convert-ToFiniteDouble $A22 'a22'
    $step = Convert-ToFiniteDouble $StepDegrees 'StepDegrees'
    if ($r -le 0) { throw 'R must be greater than zero.' }
    if ($step -le 0 -or $step -gt 360) { throw 'StepDegrees must be greater than 0 and at most 360.' }
} catch {
    [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'INVERSEMATRIXCIRCLE - Input error',
        [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
    exit 1
}

function Format-N([double]$value) {
    return $value.ToString('0.###', [System.Globalization.CultureInfo]::InvariantCulture)
}

# A^-1 = [a22, -a12; -a21, a11] / determinant.
# A singular matrix cannot recover the original vector uniquely.
$determinant = $m11*$m22 - $m12*$m21
$matrixMagnitude = [math]::Max([math]::Max([math]::Abs($m11),[math]::Abs($m12)),
                               [math]::Max([math]::Abs($m21),[math]::Abs($m22)))
$detTolerance = 1e-14 * $matrixMagnitude * $matrixMagnitude
if ($determinant -eq 0 -or [math]::Abs($determinant) -le $detTolerance) {
    [System.Windows.Forms.MessageBox]::Show(
        'The determinant is zero or too close to zero for stable inversion. The inverse does not exist or is numerically unstable. Choose another matrix.',
        'INVERSEMATRIXCIRCLE - Singular matrix',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
    exit 1
}
$inv11 = $m22 / $determinant
$inv12 = -$m12 / $determinant
$inv21 = -$m21 / $determinant
$inv22 = $m11 / $determinant

$form = New-Object System.Windows.Forms.Form
$form.Text = 'INVERSEMATRIXCIRCLE 1.0.0.0.2 - matrix action on rotating vector'
$form.ClientSize = New-Object System.Drawing.Size(980,780)
$form.StartPosition = 'CenterScreen'
$form.MinimumSize = New-Object System.Drawing.Size(650,560)
$form.KeyPreview = $true
$form.BackColor = [System.Drawing.Color]::White

$state = [pscustomobject]@{ Index = 0; Stage = 1 }
$brushText = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(37,43,54))
$penGrid = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(236,239,244),1)
$penAxis = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(140,148,157),1.3)
$penInverse = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(29,153,97),5.8)
$penInverse.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash
$penInput = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(27,113,203),3.3)
$penOutput = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(222,75,48),3.3)
$penInput.CustomEndCap = New-Object System.Drawing.Drawing2D.AdjustableArrowCap(5,6)
$penInverse.CustomEndCap = New-Object System.Drawing.Drawing2D.AdjustableArrowCap(6,7)
$penOutput.CustomEndCap = New-Object System.Drawing.Drawing2D.AdjustableArrowCap(5,6)
$font = New-Object System.Drawing.Font('Segoe UI',10)
$fontBold = New-Object System.Drawing.Font('Segoe UI',10,[System.Drawing.FontStyle]::Bold)
$fontTitle = New-Object System.Drawing.Font('Segoe UI',12,[System.Drawing.FontStyle]::Bold)

# Reserve one pane for textual information. The coordinate origin remains central
# in the plot pane. Scale is fixed for ALL angular steps (no jumping axes).
$operatorBound = [math]::Sqrt($m11*$m11 + $m12*$m12 + $m21*$m21 + $m22*$m22)
$worldExtent = [math]::Max($r,$r*$operatorBound)*1.18
if ([double]::IsInfinity($worldExtent) -or [double]::IsNaN($worldExtent) -or $worldExtent -le 0) {
    [System.Windows.Forms.MessageBox]::Show('The matrix/radius values are too large to display.', 'INVERSEMATRIXCIRCLE') | Out-Null
    exit 1
}

function Draw-Arrow([System.Drawing.Graphics]$g, [System.Drawing.Pen]$pen,
                    [float]$originX,[float]$originY,[float]$endX,[float]$endY) {
    if ([math]::Abs($endX-$originX)+[math]::Abs($endY-$originY) -lt 1) {
        $g.FillEllipse($(if($pen -eq $penInput){[System.Drawing.Brushes]::Blue}elseif($pen -eq $penInverse){[System.Drawing.Brushes]::Green}else{[System.Drawing.Brushes]::OrangeRed}),
            $endX-4,$endY-4,8,8)
    } else {
        $g.DrawLine($pen,$originX,$originY,$endX,$endY)
    }
}

$form.Add_Paint({
    param($sender,$e)
    $g = $e.Graphics
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $w = $form.ClientSize.Width
    $h = $form.ClientSize.Height
    $top = 110
    $bottom = $h-195
    $side = 55
    $usableWidth = [math]::Max(100,$w-2*$side)
    $usableHeight = [math]::Max(100,$bottom-$top)
    $cx = [single]($side+$usableWidth/2)
    $cy = [single]($top+$usableHeight/2)
    $scale = [math]::Min($usableWidth,$usableHeight)/(2*$worldExtent)

    # Grid and Cartesian axes.
    $tickWorld = [math]::Pow(10,[math]::Floor([math]::Log10($worldExtent/3)))
    if ($worldExtent/$tickWorld -gt 7) { $tickWorld *= 2 }
    $nTicks = [math]::Min(100,[math]::Ceiling($worldExtent/$tickWorld))
    for ($i = -$nTicks; $i -le $nTicks; $i++) {
        $x = [single]($cx+$i*$tickWorld*$scale)
        $y = [single]($cy-$i*$tickWorld*$scale)
        if ($x -ge $side -and $x -le $w-$side) { $g.DrawLine($penGrid,$x,$top,$x,$bottom) }
        if ($y -ge $top -and $y -le $bottom) { $g.DrawLine($penGrid,$side,$y,$w-$side,$y) }
    }
    $g.DrawLine($penAxis,[single]$side,$cy,[single]($w-$side),$cy)
    $g.DrawLine($penAxis,$cx,[single]$top,$cx,[single]$bottom)
    $g.DrawString('X', $fontBold,$brushText,[single]($w-$side+8),$cy-14)
    $g.DrawString('Y', $fontBold,$brushText,$cx+10,[single]($top-18))
    $g.DrawString('0', $font,$brushText,$cx+5,$cy+4)

    $angleDeg = [math]::Min(360.0,$state.Index*$step)
    $angleRad = $angleDeg*[math]::PI/180.0
    $x0 = $r*[math]::Cos($angleRad)
    $y0 = $r*[math]::Sin($angleRad)
    $x1 = $m11*$x0 + $m12*$y0
    $y1 = $m21*$x0 + $m22*$y0
    $x2 = $inv11*$x1 + $inv12*$y1
    $y2 = $inv21*$x1 + $inv22*$y1
    $p2x = [single]($cx+$x2*$scale)
    $p2y = [single]($cy-$y2*$scale)
    $p0x = [single]($cx+$x0*$scale)
    $p0y = [single]($cy-$y0*$scale)
    $p1x = [single]($cx+$x1*$scale)
    $p1y = [single]($cy-$y1*$scale)

    # Stage 1: v only; stage 2: v and Av; stage 3: recovered vector A^-1(Av) only.
    # This isolates the recovery result visually, without the transformed vector.
    switch ($state.Stage) {
        1 {
            Draw-Arrow $g $penInput $cx $cy $p0x $p0y
        }
        2 {
            Draw-Arrow $g $penInput $cx $cy $p0x $p0y
            Draw-Arrow $g $penOutput $cx $cy $p1x $p1y
        }
        3 {
            Draw-Arrow $g $penInverse $cx $cy $p2x $p2y
        }
    }

    $stageName = switch ($state.Stage) {
        1 { '1/3  Original vector v (blue)' }
        2 { '2/3  Apply A: show v (blue) and Av (red)' }
        3 { '3/3  Apply inverse: show only A^-1(Av) (green dashed)' }
    }
    $g.DrawString($stageName,$fontTitle,$brushText,20,12)
    $g.DrawString(('A = [{0}, {1}; {2}, {3}]     det(A) = {4}     R = {5}     angle = {6} deg' -f
        (Format-N $m11),(Format-N $m12),(Format-N $m21),(Format-N $m22),
        (Format-N $determinant),(Format-N $r),(Format-N $angleDeg)), $font,$brushText,20,45)
    $g.DrawString(('A^-1 = (1 / {0}) * [{1}, {2}; {3}, {4}]' -f
        (Format-N $determinant),(Format-N $m22),(Format-N (-$m12)),
        (Format-N (-$m21)),(Format-N $m11)), $font,$brushText,20,70)

    $base = $h-175
    $blueBrush = New-Object System.Drawing.SolidBrush($penInput.Color)
    $redBrush = New-Object System.Drawing.SolidBrush($penOutput.Color)
    $greenBrush = New-Object System.Drawing.SolidBrush($penInverse.Color)
    try {
        if ($state.Stage -eq 1) {
            $g.DrawString(('v = ({0}, {1})' -f (Format-N $x0),(Format-N $y0)),
                $fontBold,$blueBrush,20,$base)
        }
        elseif ($state.Stage -eq 2) {
            $g.DrawString(('v = ({0}, {1})' -f (Format-N $x0),(Format-N $y0)),
                $fontBold,$blueBrush,20,$base)
            $g.DrawString(('Av = ({0}, {1})' -f (Format-N $x1),(Format-N $y1)),
                $fontBold,$redBrush,20,$base+27)
        }
        else {
            $g.DrawString(('A^-1(Av) = ({0}, {1})  |  recovery error = {2}' -f
                (Format-N $x2),(Format-N $y2),
                (Format-N ([math]::Sqrt(($x2-$x0)*($x2-$x0)+($y2-$y0)*($y2-$y0))))),
                $fontBold,$greenBrush,20,$base)
        }
    } finally {
        $blueBrush.Dispose(); $redBrush.Dispose(); $greenBrush.Dispose()
    }
    $g.DrawString(('Stage {0}/3  |  LEFT / SPACE / ENTER: next stage (then angle +{1} deg)  |  RIGHT / BACKSPACE: previous' -f
        $state.Stage,(Format-N $step)), $font,$brushText,20,$h-57)
    $g.DrawString('HOME: restart at 0 deg / stage 1  |  ESC: close',
        $font,$brushText,20,$h-33)
})

$form.Add_KeyDown({
    param($sender,$e)
    $direction = 0
    switch ($e.KeyCode) {
        'Space'     { $direction = 1; break }
        'Enter'     { $direction = 1; break }
        'Left'      { $direction = 1; break }
        'Right'     { $direction = -1; break }
        'Back'      { $direction = -1; break }
        'Home'      { $state.Index = 0; $state.Stage = 1; break }
        'Escape'    { $form.Close(); return }
        default     { return }
    }
    $lastIndex = [int][math]::Ceiling(360.0/$step)
    if ($direction -eq 1) {
        if ($state.Stage -lt 3) { $state.Stage++ }
        else {
            $state.Stage = 1
            $state.Index++
            if ($state.Index -gt $lastIndex) { $state.Index = 0 }
        }
    } elseif ($direction -eq -1) {
        if ($state.Stage -gt 1) { $state.Stage-- }
        else {
            $state.Stage = 3
            $state.Index--
            if ($state.Index -lt 0) { $state.Index = $lastIndex }
        }
    }
    $form.Invalidate()
    $e.Handled = $true
    $e.SuppressKeyPress = $true
})
try {
    [void]$form.ShowDialog()
} finally {
    $penInput.Dispose(); $penOutput.Dispose(); $penInverse.Dispose(); $penGrid.Dispose(); $penAxis.Dispose()
    $brushText.Dispose(); $font.Dispose(); $fontBold.Dispose(); $fontTitle.Dispose()
    $form.Dispose()
}
