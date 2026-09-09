/*
    finfo32.c
    Version : 1.0.0.0.1
    Date    : 2026-09-09
    Compiler: Borland C++ 5.5.1 for Win32
*/

#include <windows.h>

#define DLL_EXPORT __declspec(dllexport)

static int fileTimeParts(const char *fileName, WORD *dosDate, WORD *dosTime)
{
    WIN32_FILE_ATTRIBUTE_DATA data;
    FILETIME localTime;

    if (!GetFileAttributesExA(fileName, GetFileExInfoStandard, &data))
        return -((int)GetLastError());
    if (!FileTimeToLocalFileTime(&data.ftLastWriteTime, &localTime))
        return -((int)GetLastError());
    if (!FileTimeToDosDateTime(&localTime, dosDate, dosTime))
        return -((int)GetLastError());
    return 0;
}

DLL_EXPORT int __pascal FINFOGETATTRIBUTES(const char *fileName)
{
    DWORD attributes = GetFileAttributesA(fileName);
    /* Borland C++ 5.5's older Windows headers do not define
       INVALID_FILE_ATTRIBUTES. Its documented value is 0xFFFFFFFF. */
    if (attributes == 0xFFFFFFFFUL)
        return -((int)GetLastError());
    return (int)attributes;
}

DLL_EXPORT int __pascal FINFOSETATTRIBUTES(const char *fileName, int attributes)
{
    DWORD windowsAttributes = (DWORD)attributes;

    if ((windowsAttributes & ~FILE_ATTRIBUTE_NORMAL) != 0)
        windowsAttributes &= ~FILE_ATTRIBUTE_NORMAL;
    if (windowsAttributes == 0)
        windowsAttributes = FILE_ATTRIBUTE_NORMAL;

    if (!SetFileAttributesA(fileName, windowsAttributes))
        return -((int)GetLastError());
    return (int)windowsAttributes;
}

DLL_EXPORT int __pascal FINFOGETSIZE(const char *fileName)
{
    WIN32_FILE_ATTRIBUTE_DATA data;
    if (!GetFileAttributesExA(fileName, GetFileExInfoStandard, &data))
        return -((int)GetLastError());
    if (data.nFileSizeHigh != 0 || data.nFileSizeLow > 0x7fffffffUL)
        return -1;
    return (int)data.nFileSizeLow;
}

DLL_EXPORT int __pascal FINFOGETDATE(const char *fileName)
{
    WORD dosDate = 0;
    WORD dosTime = 0;
    int result = fileTimeParts(fileName, &dosDate, &dosTime);
    if (result < 0)
        return result;
    return (int)dosDate;
}

DLL_EXPORT int __pascal FINFOGETTIME(const char *fileName)
{
    WORD dosDate = 0;
    WORD dosTime = 0;
    int result = fileTimeParts(fileName, &dosDate, &dosTime);
    if (result < 0)
        return result;
    return (int)dosTime;
}

BOOL WINAPI DllEntryPoint(HINSTANCE instance, DWORD reason, LPVOID reserved)
{
    (void)instance;
    (void)reason;
    (void)reserved;
    return TRUE;
}
