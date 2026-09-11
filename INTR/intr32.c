#include <windows.h>

static HANDLE findHandleG = INVALID_HANDLE_VALUE;
static WIN32_FIND_DATAA findDataG;

static int IsDotName(const char *nameS)
{
    if (nameS[0] == '.' && nameS[1] == 0)
        return 1;
    if (nameS[0] == '.' && nameS[1] == '.' && nameS[2] == 0)
        return 1;
    return 0;
}

static int FindUsable(void)
{
    while (findHandleG != INVALID_HANDLE_VALUE)
    {
        if (!IsDotName(findDataG.cFileName))
            return 1;
        if (!FindNextFileA(findHandleG, &findDataG))
        {
            FindClose(findHandleG);
            findHandleG = INVALID_HANDLE_VALUE;
            return 0;
        }
    }
    return 0;
}

int __pascal IntrFindFirst(void)
{
    if (findHandleG != INVALID_HANDLE_VALUE)
    {
        FindClose(findHandleG);
        findHandleG = INVALID_HANDLE_VALUE;
    }

    findHandleG = FindFirstFileA("*.*", &findDataG);
    if (findHandleG == INVALID_HANDLE_VALUE)
        return 0;

    return FindUsable();
}

int __pascal IntrFindNext(void)
{
    if (findHandleG == INVALID_HANDLE_VALUE)
        return 0;

    if (!FindNextFileA(findHandleG, &findDataG))
    {
        FindClose(findHandleG);
        findHandleG = INVALID_HANDLE_VALUE;
        return 0;
    }

    return FindUsable();
}

int __pascal IntrGetNameLength(void)
{
    int lengthI = 0;

    if (findHandleG == INVALID_HANDLE_VALUE)
        return 0;

    while (findDataG.cFileName[lengthI] != 0)
        lengthI++;

    return lengthI;
}

int __pascal IntrGetNameChar(int indexI)
{
    int lengthI = IntrGetNameLength();

    if (indexI < 1 || indexI > lengthI)
        return 0;

    return (unsigned char)findDataG.cFileName[indexI - 1];
}

int __pascal IntrCloseFind(void)
{
    if (findHandleG != INVALID_HANDLE_VALUE)
    {
        FindClose(findHandleG);
        findHandleG = INVALID_HANDLE_VALUE;
    }
    return 1;
}

int __pascal IntrSetConsoleCursor(int sizeI, int visibleI)
{
    HANDLE outputH;
    CONSOLE_CURSOR_INFO cursorInfo;

    outputH = GetStdHandle(STD_OUTPUT_HANDLE);
    if (outputH == INVALID_HANDLE_VALUE || outputH == 0)
        return 0;

    if (!GetConsoleCursorInfo(outputH, &cursorInfo))
        return 0;

    if (sizeI < 1)
        sizeI = 1;
    if (sizeI > 100)
        sizeI = 100;

    cursorInfo.dwSize = (DWORD)sizeI;
    cursorInfo.bVisible = visibleI ? TRUE : FALSE;

    return SetConsoleCursorInfo(outputH, &cursorInfo) ? 1 : 0;
}

#pragma argsused
BOOL WINAPI DllEntryPoint(HINSTANCE instanceH, DWORD reasonD, LPVOID reservedP)
{
    if (reasonD == DLL_PROCESS_DETACH && findHandleG != INVALID_HANDLE_VALUE)
    {
        FindClose(findHandleG);
        findHandleG = INVALID_HANDLE_VALUE;
    }
    return TRUE;
}

