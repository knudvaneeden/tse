# UTF8SHORT 1.0.0.0.4 - OpenAI Codex (GPT-6)
# Use 32-bit Windows PowerShell; this checks the DLL without TSE.
$ErrorActionPreference = 'Stop'
if ([IntPtr]::Size -ne 4) {
    throw 'Run with C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe'
}
$dllPath = Join-Path $PSScriptRoot 'utf8short.dll'
Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class Utf8ShortTest {
    [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
    public static extern IntPtr LoadLibraryW(string path);
    [DllImport("utf8short.dll", CallingConvention=CallingConvention.StdCall)]
    public static extern int UniFromUtf8(IntPtr text);
    [DllImport("utf8short.dll", CallingConvention=CallingConvention.StdCall)]
    public static extern int UniByte(int index);
    [DllImport("utf8short.dll", CallingConvention=CallingConvention.StdCall)]
    public static extern int UniError();
}
'@
if ([Utf8ShortTest]::LoadLibraryW($dllPath) -eq [IntPtr]::Zero) {
    throw ('DLL load failed: ' + [Runtime.InteropServices.Marshal]::GetLastWin32Error())
}
function Resolve-Utf8([byte[]]$bytes) {
    if ($bytes.Length -gt 255) { throw 'Test pathname exceeds SAL limit.' }
    $ptr = [Runtime.InteropServices.Marshal]::AllocHGlobal(257)
    try {
        [Runtime.InteropServices.Marshal]::WriteInt16($ptr, [int16]$bytes.Length)
        [Runtime.InteropServices.Marshal]::Copy($bytes, 0, [IntPtr]::Add($ptr,2), $bytes.Length)
        return [Utf8ShortTest]::UniFromUtf8($ptr)
    } finally { [Runtime.InteropServices.Marshal]::FreeHGlobal($ptr) }
}
function Assert-Status($actual, $expected, $name) {
    if ($actual -ne $expected) { throw "$name returned $actual, expected $expected" }
    Write-Host "PASS: $name"
}
$folder = Join-Path ([IO.Path]::GetTempPath()) ('utf8short-' + [Guid]::NewGuid().ToString('N'))
[IO.Directory]::CreateDirectory($folder) | Out-Null
try {
    Assert-Status (Resolve-Utf8 ([byte[]](0xc3,0x28))) -4 'Invalid UTF-8'
    Assert-Status ([Utf8ShortTest]::UniByte(1)) 0 'Failure clears output'
    $missing = Join-Path $folder 'missing.txt'
    Assert-Status (Resolve-Utf8 ([Text.Encoding]::UTF8.GetBytes($missing))) -1 'Missing file'
    Assert-Status (Resolve-Utf8 ([Text.Encoding]::UTF8.GetBytes($folder))) -5 'Directory'
    foreach ($name in @('ascii.txt', ('caf' + [char]0xe9 + '.txt'),
                        ([string][char]0x4e2d + [char]0x6587 + '.txt'))) {
        $path = Join-Path $folder $name
        [IO.File]::WriteAllText($path, 'UTF8SHORT DLL test 1.0.0.0.4')
        $status = Resolve-Utf8 ([Text.Encoding]::UTF8.GetBytes($path))
        if ($status -eq -2) {
            Write-Host 'PASS: no ASCII short path exists; correctly rejected.'
            continue
        }
        Assert-Status $status 1 'Existing filename'
        $short = ''
        for ($i=1; $i -le 255; $i++) {
            $b = [Utf8ShortTest]::UniByte($i)
            if ($b -eq 0) { break }
            if ($b -gt 127) { throw 'Non-ASCII output.' }
            $short += [char]$b
        }
        if ([IO.File]::ReadAllText($short) -ne 'UTF8SHORT DLL test 1.0.0.0.4') {
            throw 'Resolved path points to wrong content.'
        }
        Write-Host "PASS: ASCII path opens original content: $short"
    }
    Write-Host 'DLL tests completed. Next test the macro in TSE.'
} finally { [IO.Directory]::Delete($folder, $true) }
