# determinantarea.ps1 - version 1.0.0.0.1
# Windows PowerShell 5.1+; Windows Forms / System.Drawing (no extra packages).
param([Parameter(Mandatory=$true)][string]$IniPath)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

function Read-IniSection([string]$Path,[string]$Section) {
    if (-not (Test-Path -LiteralPath $Path)) { throw "INI not found: $Path" }
    $values = @{}
    $inside = $false
    foreach ($line in [System.IO.File]::ReadAllLines($Path)) {
        $s = $line.Trim()
        if ($s -match '^\[(.+)\]$') { $inside = ($matches[1] -ieq $Section); continue }
        if ($inside -and $s -match '^([^;#=][^=]*)=(.*)$') {
            $values[$matches[1].Trim().ToLowerInvariant()] = $matches[2].Trim()
        }
    }
    return $values
}
function Num([string]$Text,[string]$Name) {
    $value = 0.0
    if (-not [double]::TryParse($Text,[System.Globalization.NumberStyles]::Float,[System.Globalization.CultureInfo]::InvariantCulture,[ref]$value)) {
        throw "Invalid $Name = '$Text'. Use a decimal point, e.g. 1.5 or -2."
    }
    if ([double]::IsNaN($value) -or [double]::IsInfinity($value) -or [math]::Abs($value) -gt 100000) {
        throw "Value $Name is too large or not finite."
    }
    return $value
}
function F([double]$x) { return $x.ToString('0.###',[System.Globalization.CultureInfo]::InvariantCulture) }
function P([double]$x,[double]$y) { return [System.Drawing.PointF]::new([single]$x,[single]$y) }
function DrawArrow($g,$pen,$p1,$p2,[single]$head=12) {
    $g.DrawLine($pen,$p1,$p2)
    $dx=$p2.X-$p1.X; $dy=$p2.Y-$p1.Y
    $len=[math]::Sqrt($dx*$dx+$dy*$dy)
    if ($len -lt 1) { return }
    $ux=$dx/$len; $uy=$dy/$len
    $size=[math]::Min($head,[math]::Max(5,$len*0.28))
    $w=0.45*$size
    $left=P ($p2.X-$size*$ux-$w*$uy) ($p2.Y-$size*$uy+$w*$ux)
    $right=P ($p2.X-$size*$ux+$w*$uy) ($p2.Y-$size*$uy-$w*$ux)
    $g.FillPolygon([System.Drawing.SolidBrush]::new($pen.Color),[System.Drawing.PointF[]]@($p2,$left,$right))
}

try {
    $matrix = Read-IniSection $IniPath 'LastUsed'
    $defaults = Read-IniSection $IniPath 'Matrix'
    foreach ($name in @('a11','a12','a21','a22')) {
        if (-not $matrix.ContainsKey($name)) { $matrix[$name]=$defaults[$name] }
        if ([string]::IsNullOrWhiteSpace($matrix[$name])) { throw "Missing matrix value: $name" }
    }
    $a11=Num $matrix['a11'] 'a11'; $a12=Num $matrix['a12'] 'a12'
    $a21=Num $matrix['a21'] 'a21'; $a22=Num $matrix['a22'] 'a22'
    $det=$a11*$a22-$a12*$a21
    $area=[math]::Abs($det)
    $display=Read-IniSection $IniPath 'Display'
    $title='Determinant as parallelogram area'
    if ($display.ContainsKey('title') -and $display['title']) { $title=$display['title'] }
    $width=1050; $height=800
    $n=0
    if ($display.ContainsKey('width') -and [int]::TryParse($display['width'],[ref]$n)) { $width=[math]::Max(700,[math]::Min(1800,$n)) }
    if ($display.ContainsKey('height') -and [int]::TryParse($display['height'],[ref]$n)) { $height=[math]::Max(550,[math]::Min(1200,$n)) }

    $form=New-Object System.Windows.Forms.Form
    $form.Text=$title + '  |  v1.0.0.0.1'
    $form.StartPosition='CenterScreen'; $form.ClientSize=New-Object System.Drawing.Size($width,$height)
    $form.MinimumSize=New-Object System.Drawing.Size(700,550)
    $form.BackColor=[System.Drawing.Color]::White
    $form.KeyPreview=$true
    # Smooth rendering on resize: PictureBox paints only the current step.
    $canvas=New-Object System.Windows.Forms.PictureBox
    $canvas.Dock='Fill'; $canvas.BackColor=[System.Drawing.Color]::White
    $form.Controls.Add($canvas)
    $script:step=4
    $script:showOriginal=$true
    $script:showLabels=$true
    $canvas.Add_Paint({
        param($sender,$e)
        $g=$e.Graphics
        $g.SmoothingMode=[System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $g.TextRenderingHint=[System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
        $w=[double]$sender.ClientSize.Width; $h=[double]$sender.ClientSize.Height
        if ($w -lt 100 -or $h -lt 100) { return }
        $top=112.0; $bottom=110.0; $margin=75.0
        $plotW=[math]::Max(50,$w-2*$margin); $plotH=[math]::Max(50,$h-$top-$bottom)
        $xs=@(0.0,1.0,$a11,$a12,$a11+$a12)
        $ys=@(0.0,1.0,$a21,$a22,$a21+$a22)
        $xmin=[math]::Min(-0.5, ($xs | Measure-Object -Minimum).Minimum)
        $xmax=[math]::Max(1.5, ($xs | Measure-Object -Maximum).Maximum)
        $ymin=[math]::Min(-0.5, ($ys | Measure-Object -Minimum).Minimum)
        $ymax=[math]::Max(1.5, ($ys | Measure-Object -Maximum).Maximum)
        $rangeX=[math]::Max(2.5,$xmax-$xmin); $rangeY=[math]::Max(2.5,$ymax-$ymin)
        $padX=$rangeX*0.13; $padY=$rangeY*0.13
        $xmin-=$padX; $xmax+=$padX; $ymin-=$padY; $ymax+=$padY
        $scale=[math]::Min($plotW/($xmax-$xmin),$plotH/($ymax-$ymin))
        $cx=$margin+($plotW-($xmax-$xmin)*$scale)/2-$xmin*$scale
        $cy=$top+($plotH-($ymax-$ymin)*$scale)/2+$ymax*$scale
        $toPixel={ param([double]$x,[double]$y) P ($cx+$x*$scale) ($cy-$y*$scale) }
        $O=& $toPixel 0 0; $E1=& $toPixel 1 0; $E2=& $toPixel 0 1; $E12=& $toPixel 1 1
        $U=& $toPixel $a11 $a21; $V=& $toPixel $a12 $a22
        $UV=& $toPixel ($a11+$a12) ($a21+$a22)
        $font=New-Object System.Drawing.Font('Segoe UI',11)
        $titleFont=New-Object System.Drawing.Font('Segoe UI',17,[System.Drawing.FontStyle]::Bold)
        $small=New-Object System.Drawing.Font('Consolas',10)
        $text=[System.Drawing.Brushes]::Black
        $g.DrawString('Determinant = oriented area of the transformed unit square',$titleFont,$text,24,12)
        $g.DrawString(('A = [[{0}, {1}], [{2}, {3}]]    det(A) = {0} * {3} - {1} * {2} = {4}' -f (F $a11),(F $a12),(F $a21),(F $a22),(F $det)),$font,$text,25,53)
        $orientation='counterclockwise (positive)'
        if ($det -lt 0) { $orientation='clockwise (negative)' }
        if ($det -eq 0) { $orientation='degenerate (zero area)' }
        $g.DrawString(('Area = |det(A)| = {0} square units    Orientation: {1}' -f (F $area),$orientation),$font,$text,25,80)

        $gridPen=New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(235,238,242),1)
        $axisPen=New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(100,105,114),1.5)
        $xminInt=[int][math]::Ceiling($xmin); $xmaxInt=[int][math]::Floor($xmax)
        $yminInt=[int][math]::Ceiling($ymin); $ymaxInt=[int][math]::Floor($ymax)
        $tickStep=[math]::Max(1,[int][math]::Ceiling([math]::Max($rangeX,$rangeY)/16))
        for ($ix=$xminInt; $ix -le $xmaxInt; $ix+=$tickStep) {
            $xpx=[single]($cx+$ix*$scale)
            $g.DrawLine($gridPen,$xpx,[single]$top,$xpx,[single]($top+$plotH))
            if ($ix -ne 0) { $g.DrawString("$ix",$small,[System.Drawing.Brushes]::DimGray,$xpx+3,[single][math]::Max($top,[math]::Min($top+$plotH-18,$cy+4))) }
        }
        for ($iy=$yminInt; $iy -le $ymaxInt; $iy+=$tickStep) {
            $ypx=[single]($cy-$iy*$scale)
            $g.DrawLine($gridPen,[single]$margin,$ypx,[single]($margin+$plotW),$ypx)
            if ($iy -ne 0) { $g.DrawString("$iy",$small,[System.Drawing.Brushes]::DimGray,[single][math]::Max($margin,[math]::Min($margin+$plotW-28,$cx+5)),$ypx+2) }
        }
        $g.DrawLine($axisPen,[single]$margin,[single]$cy,[single]($margin+$plotW),[single]$cy)
        $g.DrawLine($axisPen,[single]$cx,[single]$top,[single]$cx,[single]($top+$plotH))
        $g.DrawString('x',$font,$text,[single]($margin+$plotW-18),[single]($cy-22))
        $g.DrawString('y',$font,$text,[single]($cx+9),[single]($top+2))

        if ($script:showOriginal) {
            $originalPen=New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(145,145,145),2)
            $originalPen.DashStyle=[System.Drawing.Drawing2D.DashStyle]::Dash
            $g.DrawPolygon($originalPen,[System.Drawing.PointF[]]@($O,$E1,$E12,$E2))
            $g.DrawString('original unit square',$small,[System.Drawing.Brushes]::Gray,$E12.X+6,$E12.Y-20)
            $originalPen.Dispose()
        }
        if ($script:step -ge 1) {
            $pen=New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(33,117,213),3.3)
            DrawArrow $g $pen $O $U
            $pen.Dispose()
        }
        if ($script:step -ge 2) {
            $pen=New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(222,91,38),3.3)
            DrawArrow $g $pen $O $V
            $pen.Dispose()
        }
        if ($script:step -ge 3) {
            $pen=New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(118,64,172),3.3)
            DrawArrow $g $pen $U $UV
            $pen.Dispose()
        }
        if ($script:step -ge 4) {
            if ($area -gt 0) {
                $fillBrush=New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(52,37,166,103))
                $g.FillPolygon($fillBrush,[System.Drawing.PointF[]]@($O,$U,$UV,$V))
                $fillBrush.Dispose()
            }
            $pen=New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(26,149,93),3.3)
            DrawArrow $g $pen $V $UV
            $pen.Dispose()
        }
        if ($script:showLabels) {
            $g.DrawString('(0,0)',$small,$text,$O.X+6,$O.Y+7)
            if ($script:step -ge 1) { $g.DrawString(('u = ({0},{1})' -f (F $a11),(F $a21)),$small,[System.Drawing.Brushes]::Blue,$U.X+8,$U.Y-24) }
            if ($script:step -ge 2) { $g.DrawString(('v = ({0},{1})' -f (F $a12),(F $a22)),$small,[System.Drawing.Brushes]::OrangeRed,$V.X+8,$V.Y+4) }
            if ($script:step -ge 4) { $g.DrawString(('u+v = ({0},{1})' -f (F ($a11+$a12)),(F ($a21+$a22))),$small,$text,$UV.X+8,$UV.Y-24) }
        }
        $footerY=[single]($h-88)
        $g.DrawString(('Step {0}/4:  1 blue A(1,0)   2 orange A(0,1)   3 purple translated v   4 green translated u' -f $script:step),$small,$text,25,$footerY)
        $g.DrawString('Right / Space: next    Left: previous    Home: reset    End: all    O: original square    L: labels    Esc: close',$small,[System.Drawing.Brushes]::DimGray,25,$footerY+28)
        $font.Dispose(); $titleFont.Dispose(); $small.Dispose(); $gridPen.Dispose(); $axisPen.Dispose()
    })
    $form.Add_KeyDown({
        param($sender,$e)
        switch ($e.KeyCode.ToString()) {
            'Right' { $script:step=[math]::Min(4,$script:step+1) }
            'Space' { $script:step=[math]::Min(4,$script:step+1) }
            'Left'  { $script:step=[math]::Max(0,$script:step-1) }
            'Home'  { $script:step=0 }
            'End'   { $script:step=4 }
            'O'     { $script:showOriginal= -not $script:showOriginal }
            'L'     { $script:showLabels= -not $script:showLabels }
            'Escape' { $sender.Close() }
        }
        $canvas.Invalidate()
    })
    $canvas.Add_Resize({ $canvas.Invalidate() })
    [void]$form.ShowDialog()
} catch {
    [System.Windows.Forms.MessageBox]::Show($_.Exception.Message,'Determinant Area - error','OK','Error') | Out-Null
    Write-Error $_.Exception.Message
    exit 1
}
