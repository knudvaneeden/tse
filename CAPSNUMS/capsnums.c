/*
 * CAPSNUMS.DLL
 * Version 1.0.0.0.3
 *
 * Modern 32-bit Windows replacement for the original 1994 CAPSNUMS.BIN.
 * Compiler: Borland C++ command-line compiler 5.5 (BCC32.EXE).
 */

#include <windows.h>

static void SetLockKey(BYTE virtualKey, int turnOn)
{
    int isOn;

    isOn = ((GetKeyState((int) virtualKey) & 1) != 0);

    if (isOn != (turnOn != 0))
    {
        keybd_event(virtualKey, 0, 0, 0);
        keybd_event(virtualKey, 0, KEYEVENTF_KEYUP, 0);
    }
}

void CapsOff(void)
{
    SetLockKey(VK_CAPITAL, 0);
}

void CapsOn(void)
{
    SetLockKey(VK_CAPITAL, 1);
}

void NumsOff(void)
{
    SetLockKey(VK_NUMLOCK, 0);
}

void NumsOn(void)
{
    SetLockKey(VK_NUMLOCK, 1);
}
