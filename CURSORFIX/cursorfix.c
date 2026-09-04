/*
   File       : cursorfix.c
   Purpose    : Restore the blinking Win32 caret used by TSE g32.exe.
   Compiler   : Borland C++ 5.5.1 (32-bit)
   Version    : 1.0.0.0.5
   Date       : 2026-09-03
   Calling convention: Pascal/WinAPI (__stdcall)
*/

#define WIN32_LEAN_AND_MEAN
#include <windows.h>

#ifndef GUI_CARETBLINKING
#define GUI_CARETBLINKING 0x00000001
#endif

#define DEFAULT_CARET_BLINK_MS 530

/*
   Returns:
      1..16 : number of successful ShowCaret calls
       0    : caret was already blinking; repaint was requested
      -1    : no focused window
      -2    : no Win32 caret owned by this GUI thread
      -3    : ShowCaret failed
      -4    : the Windows caret blink interval could not be restored

   We stop as soon as Windows reports GUI_CARETBLINKING. This avoids blindly
   over-incrementing the caret's internal show counter.
*/
int __stdcall ForceCursorFix(void)
{
    GUITHREADINFO info;
    HWND focusWindow;
    HWND caretWindow;
    UINT blinkTime;
    int calls;

    focusWindow = GetFocus();
    if (focusWindow == NULL)
        return -1;

    /*
       Windows returns INFINITE when caret blinking has been disabled.
       Restore a normal blink interval before making the caret visible.
    */
    blinkTime = GetCaretBlinkTime();
    if (blinkTime == INFINITE)
    {
        if (!SetCaretBlinkTime(DEFAULT_CARET_BLINK_MS))
            return -4;
    }

    info.cbSize = sizeof(info);
    if (!GetGUIThreadInfo(0, &info) || info.hwndCaret == NULL)
    {
        InvalidateRect(focusWindow, NULL, FALSE);
        UpdateWindow(focusWindow);
        return -2;
    }

    caretWindow = info.hwndCaret;
    calls = 0;

    while ((info.flags & GUI_CARETBLINKING) == 0 && calls < 16)
    {
        if (!ShowCaret(caretWindow))
            return -3;

        calls++;
        info.cbSize = sizeof(info);
        if (!GetGUIThreadInfo(0, &info))
            break;
    }

    InvalidateRect(focusWindow, NULL, FALSE);
    UpdateWindow(focusWindow);
    SetFocus(focusWindow);

    return calls;
}

BOOL WINAPI DllEntryPoint(HINSTANCE instance, DWORD reason, LPVOID reserved)
{
    (void) instance;
    (void) reason;
    (void) reserved;
    return TRUE;
}
