/* fl32.c - Win32 helper for FL.S
   Version 1.0.0.0.12 - 2026-09-09
   Borland C++ 5.5.1, 32-bit Windows */

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <stdio.h>
#include <string.h>

#define FF_RDONLY 0x01
#define FF_HIDDEN 0x02
#define FF_SYSTEM 0x04
#define FF_VOLUME 0x08
#define FF_SUBDIR 0x10
#define FF_ARCH   0x20

static HANDLE findHandle = INVALID_HANDLE_VALUE;
static WIN32_FIND_DATA findData;
static int requestedAttributes = 0;
static DWORD totalSize = 0;

static void Split83Name(const char *source, char *base, char *extension)
{
    const char *dot = strrchr(source, '.');
    size_t baseLength;

    base[0] = '\0';
    extension[0] = '\0';
    if (strcmp(source, "..") == 0)
    {
        strcpy(base, "..");
        return;
    }
    if (dot != NULL && dot != source)
    {
        baseLength = (size_t)(dot - source);
        if (baseLength > 8) baseLength = 8;
        strncpy(base, source, baseLength);
        base[baseLength] = '\0';
        strncpy(extension, dot + 1, 7);
        extension[7] = '\0';
    }
    else
    {
        strncpy(base, source, 8);
        base[8] = '\0';
    }
}

static void AttributeString(DWORD attributes, char *text)
{
    text[0] = (attributes & FILE_ATTRIBUTE_READONLY)  ? 'R' : '_';
    text[1] = (attributes & FILE_ATTRIBUTE_HIDDEN)    ? 'H' : '_';
    text[2] = (attributes & FILE_ATTRIBUTE_SYSTEM)    ? 'S' : '_';
    text[3] = (attributes & FILE_ATTRIBUTE_ARCHIVE)   ? 'A' : '_';
    text[4] = (attributes & FILE_ATTRIBUTE_DIRECTORY) ? 'D' : '_';
    text[5] = '\0';
}

static int ToDosAttributes(DWORD attributes)
{
    int result = 0;
    if (attributes & FILE_ATTRIBUTE_READONLY)  result |= FF_RDONLY;
    if (attributes & FILE_ATTRIBUTE_HIDDEN)    result |= FF_HIDDEN;
    if (attributes & FILE_ATTRIBUTE_SYSTEM)    result |= FF_SYSTEM;
    if (attributes & FILE_ATTRIBUTE_DIRECTORY) result |= FF_SUBDIR;
    if (attributes & FILE_ATTRIBUTE_ARCHIVE)   result |= FF_ARCH;
    return(result);
}

static int IsRequested(const WIN32_FIND_DATA *data)
{
    int attributes = ToDosAttributes(data->dwFileAttributes);
    if ((attributes & FF_HIDDEN) && !(requestedAttributes & FF_HIDDEN)) return(0);
    if ((attributes & FF_SYSTEM) && !(requestedAttributes & FF_SYSTEM)) return(0);
    if ((attributes & FF_SUBDIR) && !(requestedAttributes & FF_SUBDIR)) return(0);
    if ((attributes & FF_VOLUME) && !(requestedAttributes & FF_VOLUME)) return(0);
    return(1);
}

static void StoreWord(unsigned char *target, unsigned short value)
{
    target[0] = (unsigned char)(value & 0xff);
    target[1] = (unsigned char)((value >> 8) & 0xff);
}

static void StoreDword(unsigned char *target, DWORD value)
{
    target[0] = (unsigned char)(value & 0xff);
    target[1] = (unsigned char)((value >> 8) & 0xff);
    target[2] = (unsigned char)((value >> 16) & 0xff);
    target[3] = (unsigned char)((value >> 24) & 0xff);
}

static void FillFindBlock(char *block, const WIN32_FIND_DATA *data)
{
    FILETIME localFileTime;
    WORD dosDate = 0;
    WORD dosTime = 0;
    const char *name = data->cFileName;

    memset(block, 0, 255);
    FileTimeToLocalFileTime(&data->ftLastWriteTime, &localFileTime);
    FileTimeToDosDateTime(&localFileTime, &dosDate, &dosTime);
    block[21] = (char)ToDosAttributes(data->dwFileAttributes);
    StoreWord((unsigned char *)block + 22, dosTime);
    StoreWord((unsigned char *)block + 24, dosDate);
    StoreDword((unsigned char *)block + 26, data->nFileSizeLow);

    if (data->cAlternateFileName[0] != '\0') name = data->cAlternateFileName;
    strncpy(block + 30, name, 224);
    block[254] = '\0';
}

static int ReturnRequested(char *block)
{
    do
    {
        if (IsRequested(&findData))
        {
            FillFindBlock(block, &findData);
            return(1);
        }
    }
    while (FindNextFile(findHandle, &findData));

    FindClose(findHandle);
    findHandle = INVALID_HANDLE_VALUE;
    return(0);
}

__declspec(dllexport) int __stdcall FLFINDFIRST(char *path, char *block, int attributes)
{
    if (findHandle != INVALID_HANDLE_VALUE) FindClose(findHandle);
    requestedAttributes = attributes;
    findHandle = FindFirstFile(path, &findData);
    if (findHandle == INVALID_HANDLE_VALUE) return(0);
    return(ReturnRequested(block));
}

__declspec(dllexport) int __stdcall FLFINDNEXT(char *block)
{
    if (findHandle == INVALID_HANDLE_VALUE) return(0);
    if (!FindNextFile(findHandle, &findData))
    {
        FindClose(findHandle);
        findHandle = INVALID_HANDLE_VALUE;
        return(0);
    }
    return(ReturnRequested(block));
}

__declspec(dllexport) int __stdcall FLBUILDLIST(int attributes)
{
    HANDLE handle;
    WIN32_FIND_DATA data;
    FILE *output;
    int count = 0;
    DWORD errorCode;
    DWORD tempLength;
    char outputFile[MAX_PATH];

    tempLength = GetEnvironmentVariable("TEMP", outputFile, MAX_PATH);
    if (tempLength == 0 || tempLength >= MAX_PATH - 16)
        return(-(int)ERROR_BUFFER_OVERFLOW);
    if (outputFile[tempLength - 1] != '\\')
        strcat(outputFile, "\\");
    strcat(outputFile, "$FLLIST$.$$$");
    output = fopen(outputFile, "wb");
    if (output == NULL) return(-1);

    requestedAttributes = attributes;
    totalSize = 0;
    handle = FindFirstFile("*.*", &data);
    if (handle == INVALID_HANDLE_VALUE)
    {
        errorCode = GetLastError();
        fclose(output);
        if (errorCode == ERROR_FILE_NOT_FOUND) return(0);
        return(-(int)errorCode);
    }

    do
    {
        const char *name = data.cFileName;
        char base[9];
        char extension[8];
        char attributeText[6];
        char dateText[11];
        char timeText[11];
        char sizeText[16];
        FILETIME localFileTime;
        SYSTEMTIME systemTime;

        if (!IsRequested(&data)) continue;
        if (strcmp(name, ".") == 0) continue;
        if (data.cAlternateFileName[0] != '\0') name = data.cAlternateFileName;

        Split83Name(name, base, extension);
        AttributeString(data.dwFileAttributes, attributeText);
        FileTimeToLocalFileTime(&data.ftLastWriteTime, &localFileTime);
        FileTimeToSystemTime(&localFileTime, &systemTime);
        sprintf(dateText, "%02u-%02u-%02u", systemTime.wMonth,
                systemTime.wDay, systemTime.wYear % 100);
        sprintf(timeText, "%02u:%02u", systemTime.wHour, systemTime.wMinute);

        if (data.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
            sizeText[0] = '\0';
        else
        {
            sprintf(sizeText, "%lu", data.nFileSizeLow);
            if (data.nFileSizeLow > 0x7fffffffUL)
                totalSize = 0x7fffffffUL;
            else if (totalSize <= 0x7fffffffUL - data.nFileSizeLow)
                totalSize += data.nFileSizeLow;
            else
                totalSize = 0x7fffffffUL;
        }

        fprintf(output, "%-9.9s%-8.8s%8.8s%10.10s%10.10s %s        \r\n",
                base, extension, sizeText, dateText, timeText, attributeText);
        count++;
    }
    while (FindNextFile(handle, &data));

    FindClose(handle);
    fclose(output);
    return(count);
}

__declspec(dllexport) int __stdcall FLGETTOTALSIZE(void)
{
    return((int)totalSize);
}

__declspec(dllexport) int __stdcall FLSETATTR(char *fileName, int attributes)
{
    DWORD winAttributes = 0;
    if (attributes & FF_RDONLY) winAttributes |= FILE_ATTRIBUTE_READONLY;
    if (attributes & FF_HIDDEN) winAttributes |= FILE_ATTRIBUTE_HIDDEN;
    if (attributes & FF_SYSTEM) winAttributes |= FILE_ATTRIBUTE_SYSTEM;
    if (attributes & FF_ARCH)   winAttributes |= FILE_ATTRIBUTE_ARCHIVE;
    if (winAttributes == 0) winAttributes = FILE_ATTRIBUTE_NORMAL;
    return(SetFileAttributes(fileName, winAttributes) != 0);
}

BOOL WINAPI DllEntryPoint(HINSTANCE instance, DWORD reason, LPVOID reserved)
{
    (void)instance;
    (void)reserved;
    if (reason == DLL_PROCESS_DETACH && findHandle != INVALID_HANDLE_VALUE)
    {
        FindClose(findHandle);
        findHandle = INVALID_HANDLE_VALUE;
    }
    return(TRUE);
}
