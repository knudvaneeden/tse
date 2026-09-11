#define WIN32_LEAN_AND_MEAN
#include <windows.h>

/*
 * INTENSE2 Win32 compatibility DLL
 * Borland C++ 5.5.1, 32-bit
 *
 * Windows consoles already use the high background bit for intensity and do
 * not expose the old VGA overscan border.  These routines retain the original
 * callable interface and remember the requested settings without changing
 * unrelated console colours.
 */

static LONG brightState = 1;
static LONG overscanColor = 0;

#pragma argsused
BOOL WINAPI DllEntryPoint(HINSTANCE instance, DWORD reason, LPVOID reserved)
{
    return TRUE;
}

void __declspec(dllexport) __pascal BRIGHT(LONG onOrOff)
{
    brightState = onOrOff ? 1 : 0;
}

void __declspec(dllexport) __pascal OVERSCAN(LONG attr)
{
    overscanColor = attr & 15;
}

LONG __declspec(dllexport) __pascal GETBRIGHTSTATE(void)
{
    return brightState;
}

LONG __declspec(dllexport) __pascal GETOVERSCANCOLOR(void)
{
    return overscanColor;
}
