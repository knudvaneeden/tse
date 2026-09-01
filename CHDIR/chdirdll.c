/* CHDIRDLL.C
   32-bit directory-change DLL for TSE SAL.
   Borland C++ command-line compiler 5.5 compatible.
   Version: 1.0.0.0.1
   LLM: OpenAI Codex (GPT-5)
*/

#define WIN32_LEAN_AND_MEAN
#include <windows.h>

/*
 * TSE declares this routine with its PASCAL modifier. Borland's __pascal
 * keyword supplies the matching convention. The DEF file publishes the
 * stable, undecorated entry-point name CHDIR.
 *
 * Return value:
 *     0              success
 *     Windows error  failure (from GetLastError)
 */
int __declspec(dllexport) __pascal CHDIR(const char *directory)
{
    DWORD errorCode;

    if (directory == NULL || directory[0] == '\0')
        return (int)ERROR_INVALID_PARAMETER;

    if (SetCurrentDirectoryA(directory))
        return 0;

    errorCode = GetLastError();
    if (errorCode == ERROR_SUCCESS)
        errorCode = ERROR_PATH_NOT_FOUND;

    return (int)errorCode;
}

BOOL WINAPI DllEntryPoint(HINSTANCE instance, DWORD reason, LPVOID reserved)
{
    (void)instance;
    (void)reason;
    (void)reserved;
    return TRUE;
}
