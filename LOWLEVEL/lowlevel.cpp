/*
   lowlevel.cpp
   Windows replacement for the original LOWLEVEL.BIN DOS helper.

   Version : 1.0.0.0.4
   Date    : 2026-09-19 23:36 CEST
   LLM     : GPT-5.6 Sol

   Build target: 32-bit Windows DLL with Borland C++ 5.5.1.
   Calling convention: __pascal. TSE SAL imports must be declared with the PASCAL modifier.
*/

#include <windows.h>

#define MAX_LOWLEVEL_HANDLES 64
#define MAX_TSE_STRING       255

static HANDLE gHandles[MAX_LOWLEVEL_HANDLES];

static int ValidHandleId(int handle)
{
    return handle > 0 && handle <= MAX_LOWLEVEL_HANDLES && gHandles[handle - 1] != NULL && gHandles[handle - 1] != INVALID_HANDLE_VALUE;
}

extern "C" __declspec(dllexport) int __pascal LOWOPEN(const char *path)
{
    HANDLE h;
    int i;

    if (path == NULL || path[0] == 0)
        return -1;

    h = CreateFileA(path, GENERIC_READ, FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
    if (h == INVALID_HANDLE_VALUE)
        return -1;

    for (i = 0; i < MAX_LOWLEVEL_HANDLES; i++)
    {
        if (gHandles[i] == NULL || gHandles[i] == INVALID_HANDLE_VALUE)
        {
            gHandles[i] = h;
            return i + 1;
        }
    }

    CloseHandle(h);
    return -1;
}

extern "C" __declspec(dllexport) int __pascal LOWSEEK(int handle, int offset, int method)
{
    DWORD moveMethod;
    DWORD newPos;

    if (!ValidHandleId(handle))
        return -1;

    if (method == 0)
        moveMethod = FILE_BEGIN;
    else if (method == 1)
        moveMethod = FILE_CURRENT;
    else if (method == 2)
        moveMethod = FILE_END;
    else
        return -1;

    SetLastError(NO_ERROR);
    newPos = SetFilePointer(gHandles[handle - 1], (LONG)offset, NULL, moveMethod);
    if (newPos == INVALID_SET_FILE_POINTER && GetLastError() != NO_ERROR)
        return -1;

    if (newPos > 0x7fffffffUL)
        return -1;

    return (int)newPos;
}

extern "C" __declspec(dllexport) int __pascal LOWREAD(int handle, void *tseString, int maxLen, int bytes)
{
    unsigned short *lenPtr;
    char *dataPtr;
    DWORD bytesRead;
    int wanted;

    if (!ValidHandleId(handle) || tseString == NULL)
        return -1;

    lenPtr = (unsigned short *)tseString;
    dataPtr = ((char *)tseString) + 2;
    *lenPtr = 0;

    if (bytes < 0)
        return -1;

    wanted = bytes;
    if (wanted > maxLen)
        wanted = maxLen;
    if (wanted > MAX_TSE_STRING)
        wanted = MAX_TSE_STRING;
    if (wanted < 0)
        wanted = 0;

    if (!ReadFile(gHandles[handle - 1], dataPtr, (DWORD)wanted, &bytesRead, NULL))
        return -1;

    if (bytesRead > MAX_TSE_STRING)
        bytesRead = MAX_TSE_STRING;

    *lenPtr = (unsigned short)bytesRead;
    return (int)bytesRead;
}

extern "C" __declspec(dllexport) int __pascal LOWCLOSE(int handle)
{
    BOOL ok;

    if (!ValidHandleId(handle))
        return -1;

    ok = CloseHandle(gHandles[handle - 1]);
    gHandles[handle - 1] = NULL;
    return ok ? 0 : -1;
}

BOOL WINAPI DllEntryPoint(HINSTANCE hinst, unsigned long reason, void *reserved)
{
    int i;
    (void)hinst;
    (void)reserved;

    if (reason == DLL_PROCESS_ATTACH)
    {
        for (i = 0; i < MAX_LOWLEVEL_HANDLES; i++)
            gHandles[i] = NULL;
    }
    else if (reason == DLL_PROCESS_DETACH)
    {
        for (i = 0; i < MAX_LOWLEVEL_HANDLES; i++)
        {
            if (gHandles[i] != NULL && gHandles[i] != INVALID_HANDLE_VALUE)
            {
                CloseHandle(gHandles[i]);
                gHandles[i] = NULL;
            }
        }
    }

    return TRUE;
}
