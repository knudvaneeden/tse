#include <windows.h>

static int KeyDown(int virtualKey)
{
    return (GetAsyncKeyState(virtualKey) & 0x8000) != 0;
}

static int KeyToggle(int virtualKey)
{
    return (GetKeyState(virtualKey) & 1) != 0;
}

static int ShiftState(void)
{
    int state = 0;
    if (KeyDown(VK_RSHIFT)) state |= 0x01;
    if (KeyDown(VK_LSHIFT)) state |= 0x02;
    if (KeyDown(VK_CONTROL)) state |= 0x04;
    if (KeyDown(VK_MENU)) state |= 0x08;
    if (KeyToggle(VK_SCROLL)) state |= 0x10;
    if (KeyToggle(VK_NUMLOCK)) state |= 0x20;
    if (KeyToggle(VK_CAPITAL)) state |= 0x40;
    if (KeyToggle(VK_INSERT)) state |= 0x80;
    return state;
}

__declspec(dllexport) int __stdcall EnhancedShiftState(void)
{
    return ShiftState();
}

__declspec(dllexport) int __stdcall NormalShiftState(void)
{
    return ShiftState() & 0x0F;
}

__declspec(dllexport) int __stdcall BIOSShiftState(void)
{
    return ShiftState();
}

BOOL WINAPI DllEntryPoint(HINSTANCE instance, DWORD reason, LPVOID reserved)
{
    (void)instance;
    (void)reason;
    (void)reserved;
    return TRUE;
}
