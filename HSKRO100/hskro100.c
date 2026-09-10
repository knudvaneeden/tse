/* HSKRO100.C
   Win32 file-attribute DLL for the HSK Read-Only TSE macro.
   Borland C++ command-line compiler 5.5/5.5.1 compatible.
   Version: 1.0.0.0.1
   LLM: OpenAI Codex (GPT-5)
*/

#define WIN32_LEAN_AND_MEAN
#include <windows.h>

int __declspec(dllexport) __pascal HSKGETFILEATTRIBUTES(const char *fileName)
{
    DWORD attributes;

    if (fileName == NULL || fileName[0] == '\0')
        return -1;

    attributes = GetFileAttributesA(fileName);
    /* Borland C++ 5.5 headers do not always define
       INVALID_FILE_ATTRIBUTES. */
    if (attributes == 0xFFFFFFFFUL)
        return -1;

    return (int)attributes;
}

int __declspec(dllexport) __pascal HSKISREADONLY(const char *fileName)
{
    int attributes;

    attributes = HSKGETFILEATTRIBUTES(fileName);
    if (attributes == -1)
        return 0;

    return (attributes & FILE_ATTRIBUTE_READONLY) != 0;
}

BOOL WINAPI DllEntryPoint(HINSTANCE instance, DWORD reason, LPVOID reserved)
{
    (void)instance;
    (void)reason;
    (void)reserved;
    return TRUE;
}
