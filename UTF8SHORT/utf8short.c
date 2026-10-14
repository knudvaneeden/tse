/* UTF8SHORT 1.0.0.0.4 - OpenAI Codex (GPT-6).
   Win32, no C runtime. Each export takes at most one argument so SAL's
   PASCAL declaration and Win32 stdcall have identical stack layouts. */
#ifdef LOCAL_PE_BUILD
#include "win32_min.h"
#else
#include <windows.h>
#include <commdlg.h>
#endif

#ifndef MB_ERR_INVALID_CHARS
#define MB_ERR_INVALID_CHARS 8
#endif

typedef struct SalStringTag {
    unsigned short length;
    char data[255];
} SalString;

static char shortPath[256];
static DWORD lastError;
static WCHAR longPath[32768];
static WCHAR shortWide[32768];

/* Status: 1 success, 0 cancelled, -1 Win32 failure, -2 no ASCII path,
   -3 output exceeds 255 bytes, -4 invalid UTF-8/input, -5 directory. */
static int resolvePath(const WCHAR *path)
{
    DWORD attributes, length, i;
    shortPath[0] = 0;
    lastError = 0;
    attributes = GetFileAttributesW(path);
    if (attributes == (DWORD)-1) {
        lastError = GetLastError();
        return -1;
    }
    if (attributes & FILE_ATTRIBUTE_DIRECTORY) return -5;
    length = GetShortPathNameW(path, shortWide, 32768);
    if (!length) {
        lastError = GetLastError();
        return -1;
    }
    if (length >= 32768) return -3;
    for (i = 0; i < length; ++i)
        if (shortWide[i] > 127) return -2;
    if (length > 255) return -3;
    for (i = 0; i < length; ++i) shortPath[i] = (char)shortWide[i];
    shortPath[length] = 0;
    return 1;
}

int WINAPI UniSelect(int owner)
{
    OPENFILENAMEW dialog;
    unsigned int i;
    unsigned char *bytes = (unsigned char *)&dialog;
    shortPath[0] = 0;
    lastError = 0;
    longPath[0] = 0;
    for (i = 0; i < sizeof(dialog); ++i) bytes[i] = 0;
    dialog.lStructSize = sizeof(dialog);
    dialog.hwndOwner = (HWND)(UINT_PTR)(unsigned int)owner;
    dialog.lpstrFile = longPath;
    dialog.nMaxFile = 32768;
    dialog.lpstrTitle = L"UTF8SHORT 1.0.0.0.4 - Select an existing file";
    dialog.Flags = OFN_EXPLORER | OFN_FILEMUSTEXIST | OFN_PATHMUSTEXIST
                 | OFN_NOCHANGEDIR | OFN_HIDEREADONLY;
    if (!GetOpenFileNameW(&dialog)) {
        lastError = CommDlgExtendedError();
        return lastError ? -1 : 0;
    }
    return resolvePath(longPath);
}

int WINAPI UniFromUtf8(const SalString *input)
{
    int count;
    unsigned int i;
    shortPath[0] = 0;
    lastError = 0;
    if (!input || !input->length || input->length > 255) return -4;
    for (i = 0; i < input->length; ++i)
        if (!input->data[i]) return -4;
    count = MultiByteToWideChar(65001, MB_ERR_INVALID_CHARS, input->data,
                              input->length, longPath, 32767);
    if (!count) {
        lastError = GetLastError();
        return -4;
    }
    longPath[count] = 0;
    return resolvePath(longPath);
}

/* Retrieve bytes without modifying a SAL string parameter. Index is 1-based. */
int WINAPI UniByte(int index)
{
    int i;
    if (index < 1 || index > 255) return 0;
    for (i = 0; i < index; ++i)
        if (!shortPath[i]) return 0;
    return (unsigned char)shortPath[index - 1];
}

int WINAPI UniError(void)
{
    return (int)lastError;
}

#ifndef LOCAL_PE_BUILD
BOOL WINAPI DllMain(HINSTANCE instance, DWORD reason, LPVOID reserved)
{
    (void)instance;
    (void)reason;
    (void)reserved;
    return TRUE;
}
#endif
