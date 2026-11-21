# riemannhypothesisgraph.ps1 - version 1.0.0.0.9
# Windows PowerShell 5.1; no third-party packages or internet required.
param([string]$IniPath)
# When launched via CMD START, no INI parameter is necessary.
# Resolve everything relative to this PS1, never relative to CurrDir().
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrWhiteSpace($IniPath)) {
  $IniPath = Join-Path $scriptDir 'riemannhypothesisgraph.ini'
}
$statusPath = Join-Path $scriptDir 'riemannhypothesisgraph_status.txt'
function Write-GraphStatus([string]$state, [string]$detail) {
  @(
    'Riemann Hypothesis Graph - version 1.0.0.0.9',
    ('Status: ' + $state),
    ('Updated: ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')),
    ('Details: ' + $detail),
    ('HTML graph: ' + (Join-Path $scriptDir 'riemannhypothesisgraph.html')),
    ('Numerical data: ' + (Join-Path $scriptDir 'riemannhypothesisgraph_data.json')),
    ('Output manifest: ' + (Join-Path $scriptDir 'riemannhypothesisgraph_output.txt'))
  ) | Set-Content -LiteralPath $statusPath -Encoding UTF8
}
Write-GraphStatus 'RUNNING' 'Calculations started; TSE is available.' 
$ErrorActionPreference='Stop'
$version='1.0.0.0.9'
$culture=[System.Globalization.CultureInfo]::InvariantCulture
Add-Type -AssemblyName System.Numerics
function Read-Ini([string]$path) {
  $d=@{}; $section=''
  foreach($line in [System.IO.File]::ReadAllLines($path)) {
    $s=$line.Trim()
    if($s -match '^\[([^\]]+)\]$') {$section=$matches[1].ToLowerInvariant();continue}
    if($s -match '^([^;#][^=]*)=(.*)$') {$d[($section+'.'+$matches[1].Trim().ToLowerInvariant())]=$matches[2].Trim()}
  }
  return $d
}
function Num([hashtable]$c,[string]$key,[double]$default) {
  $s=$c['graph.'+$key]
  if ($null -eq $s -or $s -eq '') {return $default}
  return [double]::Parse($s,[System.Globalization.NumberStyles]::Float,$culture)
}
function Pwr([double]$n,[System.Numerics.Complex]$s) {
  return [System.Numerics.Complex]::Exp($s * [Math]::Log($n))
}
# Euler-Maclaurin: sum 1..N-1 plus continuation and Bernoulli terms.
# Terms B_(2k)/(2k)! for k=1..10.
$em=@(0.08333333333333333,-0.001388888888888889,0.00003306878306878307,
  -0.0000008267195767195767,0.0000000208767569878681,-0.0000000005284190138687493,
  0.000000000013382536925836,-0.000000000000338968029632258,
  0.0000000000000085860620562778,-0.000000000000000217486869855807)
$script:N=100; $script:K=10
function Zeta([double]$x,[double]$t) {
  $s=[System.Numerics.Complex]::new($x,$t)
  if ([System.Numerics.Complex]::Abs($s - [System.Numerics.Complex]::One) -lt 1.0e-10) {return $null}
  $sum=[System.Numerics.Complex]::Zero
  for($n=1;$n -lt $script:N;$n++) { $sum += Pwr $n (-$s) }
  $nn=[double]$script:N
  $sum += (Pwr $nn ([System.Numerics.Complex]::One-$s)) / ($s-[System.Numerics.Complex]::One)
  $sum += (Pwr $nn (-$s))*0.5
  $rising=[System.Numerics.Complex]::One
  for($k=1;$k -le $script:K;$k++) {
    if ($k -eq 1) {$rising=$s} else {
      $rising *= ($s + (2*$k-3)); $rising *= ($s + (2*$k-2))
    }
    $p = Pwr $nn (-$s-(2*$k-1))
    $sum += ($em[$k-1] * $rising * $p)
  }
  return $sum
}
function Magnitude([double]$x,[double]$t) {
  $z=Zeta $x $t
  if($null -eq $z){return [double]::PositiveInfinity}
  return [System.Numerics.Complex]::Abs($z)
}
function Find-Min([double]$lo,[double]$hi) {
  $phi=0.6180339887498948482
  $a=$lo;$b=$hi;$c=$b-$phi*($b-$a);$d=$a+$phi*($b-$a)
  $fc=Magnitude 0.5 $c;$fd=Magnitude 0.5 $d
  for($i=0;$i -lt 42;$i++) {
    if($fc -lt $fd) {$b=$d;$d=$c;$fd=$fc;$c=$b-$phi*($b-$a);$fc=Magnitude 0.5 $c}
    else {$a=$c;$c=$d;$fc=$fd;$d=$a+$phi*($b-$a);$fd=Magnitude 0.5 $d}
  }
  return 0.5*($a+$b)
}
try {
  $ini=[System.IO.Path]::GetFullPath($IniPath)
  $dir=[System.IO.Path]::GetDirectoryName($ini)
  $cfg=Read-Ini $ini
  $xmin=Num $cfg 'real_min' -6; $xmax=Num $cfg 'real_max' 2
  $ymin=Num $cfg 'imag_min' 0; $ymax=Num $cfg 'imag_max' 35
  $nx=[int](Num $cfg 'real_samples' 49); $ny=[int](Num $cfg 'imag_samples' 71)
  $cap=Num $cfg 'height_cap' 8
  $script:N=[int](Num $cfg 'summation_terms' 100)
  $script:K=[int](Num $cfg 'correction_terms' 10)
  $imageXMin=Num $cfg 'image_real_min' -3.5
  $imageXMax=Num $cfg 'image_real_max' 3.5
  $imageYMin=Num $cfg 'image_imag_min' -3.5
  $imageYMax=Num $cfg 'image_imag_max' 3.5
  $sigmaLines=[int](Num $cfg 'image_sigma_lines' 15)
  $tLines=[int](Num $cfg 'image_t_lines' 13)
  $imageLineWidth=Num $cfg 'image_line_width' 1.5
  if($imageXMin -ge $imageXMax -or $imageYMin -ge $imageYMax) {throw 'Invalid image-plane bounds.'}
  if($sigmaLines -lt 2 -or $sigmaLines -gt 32 -or $tLines -lt 2 -or $tLines -gt 32) {throw 'image_sigma_lines and image_t_lines must be 2..32.'}
  if($imageLineWidth -le 0 -or $imageLineWidth -gt 6) {throw 'image_line_width must be >0 and <=6.'}
  $step=Num $cfg 'zero_search_step' 0.25
  $open=[int](Num $cfg 'open_browser' 1)
  $theme=[string]$cfg['graph.theme']; if(!$theme){$theme='dark'}; $theme=$theme.ToLowerInvariant()
  if($theme -notin @('light','dark')){throw 'theme must be light or dark'}
  $view=[string]$cfg['graph.default_view']; if(!$view){$view='plane'}; $view=$view.ToLowerInvariant()
  if($view -notin @('image','plane','surface')){throw 'default_view must be image, plane or surface'}
  if($xmin -ge $xmax -or $ymin -ge $ymax){throw 'Axis minimum must be smaller than maximum.'}
  if($nx -lt 9 -or $nx -gt 151 -or $ny -lt 9 -or $ny -gt 201){throw 'Sample counts must be between 9 and 151/201.'}
  if($cap -le 0 -or $script:N -lt 20 -or $script:N -gt 300 -or $script:K -lt 1 -or $script:K -gt 10 -or $step -le 0){throw 'Invalid cap/terms/search-step parameter.'}
  $rows=[System.Collections.Generic.List[object]]::new()
  $realRows=[System.Collections.Generic.List[object]]::new()
  $imagRows=[System.Collections.Generic.List[object]]::new()
  for($j=0;$j -lt $ny;$j++) {
    $y=$ymin+($ymax-$ymin)*$j/($ny-1)
    $row=[System.Collections.Generic.List[double]]::new()
    $realRow=[System.Collections.Generic.List[object]]::new()
    $imagRow=[System.Collections.Generic.List[object]]::new()
    for($i=0;$i -lt $nx;$i++) {
      $x=$xmin+($xmax-$xmin)*$i/($nx-1)
      $z=Zeta $x $y
      if($null -eq $z) {$a=$cap; $re=[double]::NaN; $im=[double]::NaN}
      else {$a=[System.Numerics.Complex]::Abs($z); $re=$z.Real; $im=$z.Imaginary}
      if([double]::IsNaN($a) -or [double]::IsInfinity($a)){$a=$cap}
      if([double]::IsInfinity($re)){$re=[double]::NaN}
      if([double]::IsInfinity($im)){$im=[double]::NaN}
      $realRow.Add($(if([double]::IsNaN($re)){$null}else{$re}))
      $imagRow.Add($(if([double]::IsNaN($im)){$null}else{$im}))
      $row.Add([Math]::Min($cap,$a))
    }
    $rows.Add($row.ToArray())
    $realRows.Add($realRow.ToArray())
    $imagRows.Add($imagRow.ToArray())
    if(($j % 10) -eq 0){Write-Host "Computed surface row $($j+1) / $ny"}
  }
  $trivial=[System.Collections.Generic.List[object]]::new()
  $left=[int][Math]::Floor($xmin/2)
  $right=[int][Math]::Ceiling($xmax/2)
  for($k=$left;$k -le $right;$k++) {
    $x=2*$k
    if($k -le -1 -and $x -ge $xmin -and $x -le $xmax -and $ymin -le 0 -and $ymax -ge 0) {
      $trivial.Add(@{x=[double]$x;y=0.0})
    }
  }
  $zeros=[System.Collections.Generic.List[object]]::new()
  $critical=[System.Collections.Generic.List[object]]::new()
  if($xmin -le 0.5 -and $xmax -ge 0.5) {
    $prevPrev=0.0; $prev=0.0; $lastT=$ymin
    $previousT=$ymin
    $prev=Magnitude 0.5 $previousT
    $hasPrevPrev=$false
    for($t=$ymin+$step;$t -le $ymax+$step*0.5;$t+=$step) {
      $nextT=[Math]::Min($t,$ymax)
      $current=Magnitude 0.5 $nextT
      if($hasPrevPrev -and $prev -lt $prevPrev -and $prev -lt $current) {
        $z=Find-Min $lastT $nextT
        if((Magnitude 0.5 $z) -lt 0.00002) {
          if($zeros.Count -eq 0 -or [Math]::Abs($zeros[$zeros.Count-1].y-$z) -gt 0.1) {
            $zeros.Add(@{x=0.5;y=$z})
          }
        }
      }
      $prevPrev=$prev;$prev=$current;$lastT=$previousT;$previousT=$nextT;$hasPrevPrev=$true
      if($nextT -ge $ymax){break}
    }
    for($j=0;$j -lt 350;$j++) {
      $t=$ymin+($ymax-$ymin)*$j/349
      $mag=Magnitude 0.5 $t
      $critical.Add(@{t=$t;m=[Math]::Min($cap,$mag)})
    }
  }
  # The highlighted critical line is evaluated at exactly Re(s)=0.5,
  # not at the nearest real-axis grid column. This is independent of nx.
  $mappedCritical=[System.Collections.Generic.List[object]]::new()
  if($xmin -le 0.5 -and $xmax -ge 0.5) {
    $criticalSamples=[Math]::Max(401,3*$ny)
    for($j=0;$j -lt $criticalSamples;$j++) {
      $t=$ymin+($ymax-$ymin)*$j/($criticalSamples-1)
      $z=Zeta 0.5 $t
      if($null -eq $z -or [double]::IsInfinity($z.Real) -or [double]::IsInfinity($z.Imaginary) -or [double]::IsNaN($z.Real) -or [double]::IsNaN($z.Imaginary)) {
        $mappedCritical.Add(@($null,$null))
      } else {
        $mappedCritical.Add(@([double]$z.Real,[double]$z.Imaginary))
      }
    }
  }
  $data=@{version=$version;xmin=$xmin;xmax=$xmax;ymin=$ymin;ymax=$ymax;
    cap=$cap;nx=$nx;ny=$ny;imageXMin=$imageXMin;imageXMax=$imageXMax;imageYMin=$imageYMin;imageYMax=$imageYMax;sigmaLines=$sigmaLines;tLines=$tLines;imageLineWidth=$imageLineWidth;theme=$theme;default_view=$view;surface=$rows.ToArray();re=$realRows.ToArray();im=$imagRows.ToArray();trivial=$trivial.ToArray();
    nontrivial=$zeros.ToArray();critical=$critical.ToArray();mappedCritical=$mappedCritical.ToArray(); generated=(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')}
  $json=$data | ConvertTo-Json -Depth 10 -Compress
  $jsonPath=[System.IO.Path]::Combine($dir,'riemannhypothesisgraph_data.json')
  [System.IO.File]::WriteAllText($jsonPath,$json,[System.Text.UTF8Encoding]::new($false))
  $tpl=[System.IO.File]::ReadAllText([System.IO.Path]::Combine($dir,'riemannhypothesisgraph_template.html'))
  $html=$tpl.Replace('data-theme="__RIEMANN_INITIAL_THEME__"', ('data-theme="' + $theme + '"')).Replace('/*__RIEMANN_DATA__*/','const DATA = '+$json+';')
  $htmlPath=[System.IO.Path]::Combine($dir,'riemannhypothesisgraph.html')
  [System.IO.File]::WriteAllText($htmlPath,$html,[System.Text.UTF8Encoding]::new($false))
  $manifest=[System.IO.Path]::Combine($dir,'riemannhypothesisgraph_output.txt')
  $lines=@("Riemann Hypothesis Graph - version $version", "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
    "HTML graph: $htmlPath", "Numerical data: $jsonPath", "Settings: $ini", "Default view: mapping w = zeta(s), with a critical-line domain inset and optional domain contours and 3D surface",
    "Trivial zeros shown: $($trivial.Count)", "Numerically located critical-line zeros: $($zeros.Count)",
    'The critical line is not a proof of the Riemann Hypothesis.',
    'Note: zero detection and surface values are numerical approximations.')
  [System.IO.File]::WriteAllLines($manifest,$lines,[System.Text.UTF8Encoding]::new($false))
  Write-Host ($lines -join [Environment]::NewLine)
  Write-GraphStatus 'COMPLETED' 'Graph generated successfully.'
  if($open -ne 0){Start-Process -FilePath $htmlPath}
} catch {
  Write-GraphStatus 'FAILED' $_.Exception.Message
  Write-Error $_
  exit 1
}
