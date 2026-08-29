/*
 * ASCII chart support DLL for The SemWare Editor Professional.
 * Version 1.0.0.0.4
 * Compiler: Borland C++ command-line compiler 5.5 (bcc32)
 */

#define WIN32_LEAN_AND_MEAN
#include <windows.h>

/*
 * Return the character at the one-based console screen position (x, y).
 * The original DOS implementation used BIOS interrupts 10h/02h and 10h/08h.
 */
__declspec(dllexport) int __stdcall GetChar(int x, int y)
{
    HANDLE outputHandle;
    COORD position;
    CHAR character;
    DWORD charactersRead;
    CONSOLE_SCREEN_BUFFER_INFO screenInfo;

    if (x < 1 || y < 1)
        return 32;

    outputHandle = GetStdHandle(STD_OUTPUT_HANDLE);
    if (outputHandle == INVALID_HANDLE_VALUE || outputHandle == NULL)
        return 32;

    if (!GetConsoleScreenBufferInfo(outputHandle, &screenInfo))
        return 32;

    position.X = (SHORT)(screenInfo.srWindow.Left + x - 1);
    position.Y = (SHORT)(screenInfo.srWindow.Top  + y - 1);

    if (!ReadConsoleOutputCharacterA(outputHandle, &character, 1,
                                     position, &charactersRead) ||
        charactersRead != 1)
        return 32;

    return (int)(unsigned char)character;
}

BOOL WINAPI DllEntryPoint(HINSTANCE instance, DWORD reason, LPVOID reserved)
{
    (void)instance;
    (void)reason;
    (void)reserved;
    return TRUE;
}
