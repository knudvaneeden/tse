/* FILEFIN2 ZIP central-directory reader for TSE 4.50.
   Supports classic ZIP, data descriptors, UTF-8 names and ZIP64 metadata.
   Uses Win32 only: no Borland C runtime library is required.
   Version 1.0.0.0.17 - 2026-09-08 - OpenAI Codex */

#include <windows.h>

#ifndef CREATE_NO_WINDOW
#define CREATE_NO_WINDOW 0x08000000UL
#endif

#ifndef INVALID_FILE_ATTRIBUTES
#define INVALID_FILE_ATTRIBUTES ((DWORD)-1)
#endif

#define MAX_ZIPS 8
#define SAL_TEXT_MAX 255
#define EOCD_SCAN_MAX 65557UL
#define PATH_TEXT_MAX 520
#define LINE_TEXT_MAX 1024

typedef unsigned __int64 U64;

typedef struct SAL_STRING_TAG {
    unsigned short length;
    char text[1];
} SAL_STRING;

typedef struct ZIP_CONTEXT_TAG {
    int used;
    HANDLE file;
    HANDLE nestedFile;
    U64 remaining;
    U64 size;
    unsigned short dosDate;
    unsigned short dosTime;
    int hasNested;
    int nestedPrepared;
    char archivePath[PATH_TEXT_MAX];
    char nestedPath[MAX_PATH];
    char name[SAL_TEXT_MAX + 1];
} ZIP_CONTEXT;

static ZIP_CONTEXT contexts[MAX_ZIPS];
static HINSTANCE moduleInstance;

static unsigned short get16(const unsigned char *data)
{
    return (unsigned short)(data[0] | ((unsigned short)data[1] << 8));
}

static unsigned long get32(const unsigned char *data)
{
    return (unsigned long)data[0] |
           ((unsigned long)data[1] << 8) |
           ((unsigned long)data[2] << 16) |
           ((unsigned long)data[3] << 24);
}

static U64 get64(const unsigned char *data)
{
    return (U64)get32(data) | ((U64)get32(data + 4) << 32);
}

static void copy_bytes(char *target, const char *source, int count)
{
    int index;
    for (index = 0; index < count; index++) target[index] = source[index];
}

static int text_length(const char *text)
{
    int count = 0;
    while (text[count]) count++;
    return count;
}

static char upper_char(char value)
{
    if (value >= 'a' && value <= 'z') return (char)(value - 'a' + 'A');
    return value;
}

static int wildcard_match(const char *pattern, const char *value)
{
    /* '*' and '.*' match zero or more characters; '?' matches one. */
    const char *star = NULL;
    const char *retry = NULL;

    while (*value) {
        if (*pattern == '?' ||
            (*pattern && upper_char(*pattern) == upper_char(*value))) {
            pattern++;
            value++;
        } else if (*pattern == '*' ||
                   (*pattern == '.' && pattern[1] == '*')) {
            if (*pattern == '.') pattern++;
            star = pattern++;
            retry = value;
        } else if (star) {
            pattern = star + 1;
            value = ++retry;
        } else {
            return 0;
        }
    }
    while (*pattern == '*' || (*pattern == '.' && pattern[1] == '*')) {
        if (*pattern == '.') pattern++;
        pattern++;
    }
    return *pattern == '\0';
}

static const char *member_base_name(const char *name)
{
    const char *base = name;
    while (*name) {
        if (*name == '/' || *name == '\\') base = name + 1;
        name++;
    }
    return base;
}

static int is_zip_name(const char *name)
{
    int length = text_length(name);
    if (length < 4) return 0;
    return name[length - 4] == '.' &&
           upper_char(name[length - 3]) == 'Z' &&
           upper_char(name[length - 2]) == 'I' &&
           upper_char(name[length - 1]) == 'P';
}

static void copy_text(char *target, const char *source, int maximum)
{
    int count = text_length(source);
    if (count > maximum) count = maximum;
    if (count > 0) copy_bytes(target, source, count);
    target[count] = '\0';
}

static void append_text(char *target, const char *source, int maximum)
{
    int targetLength = text_length(target);
    int sourceIndex = 0;
    while (targetLength < maximum && source[sourceIndex])
        target[targetLength++] = source[sourceIndex++];
    target[targetLength] = '\0';
}

static void sal_to_c(const SAL_STRING *source, char *target, int targetSize)
{
    int count;
    if (!source || !target || targetSize <= 0) return;
    count = (int)source->length;
    if (count >= targetSize) count = targetSize - 1;
    if (count > 0) copy_bytes(target, source->text, count);
    target[count] = '\0';
}

static void c_to_sal(SAL_STRING *target, const char *source, int maximum)
{
    int count;
    if (!target || !source) return;
    count = text_length(source);
    if (count > maximum) count = maximum;
    target->length = (unsigned short)count;
    if (count > 0) copy_bytes(target->text, source, count);
}

static int read_exact(HANDLE file, void *buffer, unsigned long count)
{
    DWORD actual = 0;
    return ReadFile(file, buffer, count, &actual, NULL) && actual == count;
}

static int seek64(HANDLE file, U64 position)
{
    LONG high = (LONG)(position >> 32);
    DWORD low;
    SetLastError(NO_ERROR);
    low = SetFilePointer(file, (LONG)(DWORD)position, &high, FILE_BEGIN);
    return !(low == INVALID_SET_FILE_POINTER && GetLastError() != NO_ERROR);
}

static U64 file_size(HANDLE file)
{
    DWORD high = 0;
    DWORD low = GetFileSize(file, &high);
    if (low == INVALID_FILE_SIZE && GetLastError() != NO_ERROR) return 0;
    return (U64)low | ((U64)high << 32);
}

static int state_number(const SAL_STRING *state)
{
    int index;
    int result = 0;
    for (index = 0; index < (int)state->length; index++) {
        char value = state->text[index];
        if (value < '0' || value > '9') break;
        result = result * 10 + value - '0';
    }
    return result - 1;
}

static void set_state(SAL_STRING *state, int slot)
{
    state->length = 1;
    state->text[0] = (char)('1' + slot);
}

static ZIP_CONTEXT *get_context(const SAL_STRING *state)
{
    int slot = state_number(state);
    if (slot < 0 || slot >= MAX_ZIPS || !contexts[slot].used) return NULL;
    return &contexts[slot];
}

static void close_context(ZIP_CONTEXT *context)
{
    if (context && context->used) {
        if (context->file != INVALID_HANDLE_VALUE) CloseHandle(context->file);
        if (context->nestedFile != INVALID_HANDLE_VALUE)
            CloseHandle(context->nestedFile);
        if (context->nestedPath[0]) DeleteFileA(context->nestedPath);
        context->file = INVALID_HANDLE_VALUE;
        context->nestedFile = INVALID_HANDLE_VALUE;
        context->nestedPath[0] = '\0';
        context->used = 0;
    }
}

static int find_central_directory(HANDLE file, U64 size, U64 *offset, U64 *entries)
{
    DWORD tailSize;
    unsigned char *tail;
    LONG index;
    U64 tailStart;
    int found = 0;

    tailSize = size > EOCD_SCAN_MAX ? EOCD_SCAN_MAX : (DWORD)size;
    if (tailSize < 22) return 0;
    tailStart = size - tailSize;
    tail = (unsigned char *)HeapAlloc(GetProcessHeap(), 0, tailSize);
    if (!tail) return 0;
    if (!seek64(file, tailStart) || !read_exact(file, tail, tailSize)) {
        HeapFree(GetProcessHeap(), 0, tail);
        return 0;
    }

    for (index = (LONG)tailSize - 22; index >= 0; index--) {
        if (get32(tail + index) == 0x06054b50UL &&
            (DWORD)index + 22UL + get16(tail + index + 20) <= tailSize) {
            unsigned short count16 = get16(tail + index + 10);
            unsigned long offset32 = get32(tail + index + 16);
            *entries = count16;
            *offset = offset32;
            found = 1;

            if (count16 == 0xffffU || offset32 == 0xffffffffUL) {
                unsigned char locator[20];
                unsigned char zip64[56];
                U64 eocdPosition = tailStart + (U64)index;
                U64 zip64Position;
                if (eocdPosition < 20 || !seek64(file, eocdPosition - 20) ||
                    !read_exact(file, locator, 20) ||
                    get32(locator) != 0x07064b50UL) {
                    found = 0;
                    break;
                }
                zip64Position = get64(locator + 8);
                if (!seek64(file, zip64Position) || !read_exact(file, zip64, 56) ||
                    get32(zip64) != 0x06064b50UL) {
                    found = 0;
                    break;
                }
                *entries = get64(zip64 + 32);
                *offset = get64(zip64 + 48);
            }
            break;
        }
    }

    HeapFree(GetProcessHeap(), 0, tail);
    return found;
}

static void store_name(ZIP_CONTEXT *context, const unsigned char *name,
                       unsigned short nameLength, unsigned short flags)
{
    int count;
    if ((flags & 0x0800U) != 0) {
        WCHAR wideName[256];
        int wideCount = MultiByteToWideChar(CP_UTF8, 0, (LPCSTR)name,
                                             (int)nameLength, wideName, 255);
        if (wideCount > 0) {
            count = WideCharToMultiByte(CP_ACP, 0, wideName, wideCount,
                                         context->name, 255, NULL, NULL);
            if (count < 0) count = 0;
            context->name[count] = '\0';
            return;
        }
    }
    count = nameLength > 255 ? 255 : (int)nameLength;
    if (count > 0) copy_bytes(context->name, (const char *)name, count);
    context->name[count] = '\0';
}

static int run_nested_scanner(ZIP_CONTEXT *context)
{
    char modulePath[PATH_TEXT_MAX];
    char scriptPath[PATH_TEXT_MAX];
    char tempDirectory[MAX_PATH];
    char command[1600];
    int index;
    STARTUPINFOA startup;
    PROCESS_INFORMATION process;
    DWORD exitCode = 1;

    if (!GetModuleFileNameA((HMODULE)moduleInstance, modulePath,
                            PATH_TEXT_MAX - 1)) return 0;
    modulePath[PATH_TEXT_MAX - 1] = '\0';
    index = text_length(modulePath);
    while (index > 0 && modulePath[index - 1] != '\\' &&
           modulePath[index - 1] != '/') index--;
    modulePath[index] = '\0';
    copy_text(scriptPath, modulePath, PATH_TEXT_MAX - 1);
    append_text(scriptPath, "zip_nested.ps1", PATH_TEXT_MAX - 1);
    if (GetFileAttributesA(scriptPath) == INVALID_FILE_ATTRIBUTES) return 0;

    if (!GetTempPathA(MAX_PATH, tempDirectory) ||
        !GetTempFileNameA(tempDirectory, "FFZ", 0, context->nestedPath))
        return 0;

    command[0] = '\0';
    append_text(command, "powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"",
                1599);
    append_text(command, scriptPath, 1599);
    append_text(command, "\" \"", 1599);
    append_text(command, context->archivePath, 1599);
    append_text(command, "\" \"", 1599);
    append_text(command, context->nestedPath, 1599);
    append_text(command, "\"", 1599);

    for (index = 0; index < (int)sizeof(startup); index++)
        ((unsigned char *)&startup)[index] = 0;
    for (index = 0; index < (int)sizeof(process); index++)
        ((unsigned char *)&process)[index] = 0;
    startup.cb = sizeof(startup);
    startup.dwFlags = STARTF_USESHOWWINDOW;
    startup.wShowWindow = SW_HIDE;

    if (!CreateProcessA(NULL, command, NULL, NULL, FALSE, CREATE_NO_WINDOW,
                        NULL, NULL, &startup, &process)) {
        DeleteFileA(context->nestedPath);
        context->nestedPath[0] = '\0';
        return 0;
    }
    WaitForSingleObject(process.hProcess, INFINITE);
    GetExitCodeProcess(process.hProcess, &exitCode);
    CloseHandle(process.hThread);
    CloseHandle(process.hProcess);
    if (exitCode != 0) {
        DeleteFileA(context->nestedPath);
        context->nestedPath[0] = '\0';
        return 0;
    }

    context->nestedFile = CreateFileA(
        context->nestedPath, GENERIC_READ, FILE_SHARE_READ, NULL,
        OPEN_EXISTING, FILE_ATTRIBUTE_TEMPORARY, NULL);
    return context->nestedFile != INVALID_HANDLE_VALUE;
}

static unsigned long decimal_value(const char *text)
{
    unsigned long result = 0;
    while (*text >= '0' && *text <= '9') {
        unsigned long digit = (unsigned long)(*text - '0');
        if (result > 214748364UL ||
            (result == 214748364UL && digit > 7UL))
            return 2147483647UL;
        result = result * 10UL + digit;
        text++;
    }
    return result;
}

static int next_nested_entry(ZIP_CONTEXT *context)
{
    char line[LINE_TEXT_MAX];
    char *field[4];
    DWORD actual;
    char value;
    int length = 0;
    int fields = 1;
    int index;

    if (context->nestedFile == INVALID_HANDLE_VALUE) return 0;
    while (length < LINE_TEXT_MAX - 1) {
        if (!ReadFile(context->nestedFile, &value, 1, &actual, NULL) ||
            actual != 1) break;
        if (value == '\n') break;
        if (value != '\r') line[length++] = value;
    }
    if (length == 0) return 0;
    line[length] = '\0';
    field[0] = line;
    for (index = 0; index < length && fields < 4; index++) {
        if (line[index] == '\t') {
            line[index] = '\0';
            field[fields++] = line + index + 1;
        }
    }
    if (fields != 4) return 0;
    context->size = decimal_value(field[0]);
    copy_text(context->name, field[3], SAL_TEXT_MAX);
    context->dosDate = 0;
    context->dosTime = 0;
    if (text_length(field[1]) == 8) {
        unsigned int month = (field[1][0] - '0') * 10 + field[1][1] - '0';
        unsigned int day = (field[1][3] - '0') * 10 + field[1][4] - '0';
        unsigned int year = (field[1][6] - '0') * 10 + field[1][7] - '0';
        year = year >= 80 ? year - 80 : year + 20;
        context->dosDate = (unsigned short)((year << 9) |
                                            (month << 5) | day);
    }
    if (text_length(field[2]) == 8) {
        unsigned int hour = (field[2][0] - '0') * 10 + field[2][1] - '0';
        unsigned int minute = (field[2][3] - '0') * 10 + field[2][4] - '0';
        unsigned int second = (field[2][6] - '0') * 10 + field[2][7] - '0';
        context->dosTime = (unsigned short)((hour << 11) |
                                            (minute << 5) | (second / 2));
    }
    return 1;
}

BOOL WINAPI DllEntryPoint(HINSTANCE instance, DWORD reason, LPVOID reserved)
{
    int index;
    (void)reserved;
    if (reason == DLL_PROCESS_ATTACH) moduleInstance = instance;
    if (reason == DLL_PROCESS_DETACH)
        for (index = 0; index < MAX_ZIPS; index++) close_context(&contexts[index]);
    return TRUE;
}

__declspec(dllexport) int PASCAL ZIP_Open(SAL_STRING *pathS, SAL_STRING *stateS)
{
    char path[MAX_PATH * 2];
    HANDLE file;
    U64 size;
    U64 offset;
    U64 entries;
    int slot;

    sal_to_c(pathS, path, sizeof(path));
    file = CreateFileA(path, GENERIC_READ, FILE_SHARE_READ | FILE_SHARE_WRITE,
                       NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
    if (file == INVALID_HANDLE_VALUE) return 0;
    size = file_size(file);
    if (!find_central_directory(file, size, &offset, &entries) || !seek64(file, offset)) {
        CloseHandle(file);
        return 0;
    }
    for (slot = 0; slot < MAX_ZIPS; slot++) if (!contexts[slot].used) break;
    if (slot == MAX_ZIPS) {
        CloseHandle(file);
        return 0;
    }
    contexts[slot].used = 1;
    contexts[slot].file = file;
    contexts[slot].nestedFile = INVALID_HANDLE_VALUE;
    contexts[slot].remaining = entries;
    contexts[slot].hasNested = 0;
    contexts[slot].nestedPrepared = 0;
    contexts[slot].nestedPath[0] = '\0';
    copy_text(contexts[slot].archivePath, path, PATH_TEXT_MAX - 1);
    set_state(stateS, slot);
    return 1;
}

__declspec(dllexport) int PASCAL ZIP_Next(SAL_STRING *stateS)
{
    ZIP_CONTEXT *context = get_context(stateS);
    unsigned char header[46];
    unsigned char *name;
    unsigned char *extra;
    unsigned short flags;
    unsigned short nameLength;
    unsigned short extraLength;
    unsigned short commentLength;
    unsigned long size32;
    U64 size64;
    unsigned long position;

    if (!context) return 0;
    if (context->remaining == 0) {
        if (!context->nestedPrepared) {
            context->nestedPrepared = 1;
            if (context->hasNested) run_nested_scanner(context);
        }
        return next_nested_entry(context);
    }
    if (!read_exact(context->file, header, 46) || get32(header) != 0x02014b50UL) {
        close_context(context);
        return 0;
    }
    flags = get16(header + 8);
    context->dosTime = get16(header + 12);
    context->dosDate = get16(header + 14);
    size32 = get32(header + 24);
    size64 = size32;
    nameLength = get16(header + 28);
    extraLength = get16(header + 30);
    commentLength = get16(header + 32);

    name = (unsigned char *)HeapAlloc(GetProcessHeap(), 0, (DWORD)nameLength + 1);
    extra = (unsigned char *)HeapAlloc(GetProcessHeap(), 0, (DWORD)extraLength + 1);
    if (!name || !extra || !read_exact(context->file, name, nameLength) ||
        !read_exact(context->file, extra, extraLength)) {
        if (name) HeapFree(GetProcessHeap(), 0, name);
        if (extra) HeapFree(GetProcessHeap(), 0, extra);
        close_context(context);
        return 0;
    }

    store_name(context, name, nameLength, flags);
    if (is_zip_name(member_base_name(context->name))) context->hasNested = 1;
    if (size32 == 0xffffffffUL) {
        position = 0;
        while (position + 4UL <= (unsigned long)extraLength) {
            unsigned short tag = get16(extra + position);
            unsigned short length = get16(extra + position + 2);
            position += 4;
            if (position + (unsigned long)length >
                (unsigned long)extraLength) break;
            if (tag == 0x0001U && length >= 8) {
                size64 = get64(extra + position);
                break;
            }
            position += length;
        }
    }
    context->size = size64;
    HeapFree(GetProcessHeap(), 0, name);
    HeapFree(GetProcessHeap(), 0, extra);

    if (commentLength != 0) {
        LONG high = 0;
        SetLastError(NO_ERROR);
        if (SetFilePointer(context->file, commentLength, &high, FILE_CURRENT) ==
            INVALID_SET_FILE_POINTER && GetLastError() != NO_ERROR) {
            close_context(context);
            return 0;
        }
    }
    context->remaining--;
    return 1;
}

__declspec(dllexport) int PASCAL ZIP_GetName(SAL_STRING *stateS, SAL_STRING *nameS)
{
    ZIP_CONTEXT *context = get_context(stateS);
    if (!context) return 0;
    c_to_sal(nameS, context->name, SAL_TEXT_MAX);
    return 1;
}

__declspec(dllexport) int PASCAL ZIP_GetSize(SAL_STRING *stateS)
{
    ZIP_CONTEXT *context = get_context(stateS);
    if (!context) return 0;
    if (context->size > 2147483647UL) return 2147483647L;
    return (int)context->size;
}

__declspec(dllexport) int PASCAL ZIP_NameMatches(
    SAL_STRING *stateS, SAL_STRING *patternS)
{
    ZIP_CONTEXT *context = get_context(stateS);
    char pattern[256];
    const char *name;
    if (!context) return 0;
    sal_to_c(patternS, pattern, sizeof(pattern));
    name = member_base_name(context->name);
    return *name ? wildcard_match(pattern, name) : 0;
}

__declspec(dllexport) int PASCAL ZIP_GetDate(SAL_STRING *stateS, SAL_STRING *dateS)
{
    ZIP_CONTEXT *context = get_context(stateS);
    char text[9];
    unsigned int month;
    unsigned int day;
    unsigned int year;
    if (!context) return 0;
    month = (context->dosDate >> 5) & 15;
    day = context->dosDate & 31;
    year = ((context->dosDate >> 9) + 80) % 100;
    text[0] = (char)('0' + month / 10); text[1] = (char)('0' + month % 10);
    text[2] = '/';
    text[3] = (char)('0' + day / 10); text[4] = (char)('0' + day % 10);
    text[5] = '/';
    text[6] = (char)('0' + year / 10); text[7] = (char)('0' + year % 10);
    text[8] = '\0';
    c_to_sal(dateS, text, 8);
    return 1;
}

__declspec(dllexport) int PASCAL ZIP_GetTime(SAL_STRING *stateS, SAL_STRING *timeS)
{
    ZIP_CONTEXT *context = get_context(stateS);
    char text[9];
    unsigned int hour;
    unsigned int minute;
    unsigned int second;
    if (!context) return 0;
    hour = (context->dosTime >> 11) & 31;
    minute = (context->dosTime >> 5) & 63;
    second = (context->dosTime & 31) * 2;
    text[0] = (char)('0' + hour / 10); text[1] = (char)('0' + hour % 10);
    text[2] = ':';
    text[3] = (char)('0' + minute / 10); text[4] = (char)('0' + minute % 10);
    text[5] = ':';
    text[6] = (char)('0' + second / 10); text[7] = (char)('0' + second % 10);
    text[8] = '\0';
    c_to_sal(timeS, text, 8);
    return 1;
}

__declspec(dllexport) int PASCAL ZIP_Close(SAL_STRING *stateS)
{
    ZIP_CONTEXT *context = get_context(stateS);
    if (!context) return 0;
    close_context(context);
    return 1;
}
