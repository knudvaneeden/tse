/* INTENSE2 Win32 DLL declarations for TSE Pro/32. */

dll "colors.dll"
    proc PASCAL bright(Integer onOrOff) : "BRIGHT"
    proc PASCAL overscan(Integer attr) : "OVERSCAN"
    integer proc PASCAL getBrightState() : "GETBRIGHTSTATE"
    integer proc PASCAL getOverscanColor() : "GETOVERSCANCOLOR"
end
