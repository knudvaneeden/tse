/* FILEFIN2 Win32 file finder DLL.
   Borland C++ 5.5 compatible C source.
   Version 1.0.0.0.13 - 2026-09-08 - OpenAI Codex */

#include <windows.h>

#define MAX_SEARCHES 64
#define SAL_TEXT_MAX 255
#define MAX_TREES 8
#define MAX_TREE_DEPTH 128
#define TREE_PATH_MAX 520

typedef struct SAL_STRING_TAG {
    unsigned short length;
    char text[1];
} SAL_STRING;

typedef struct SEARCH_TAG {
    int used;
    HANDLE handle;
    WIN32_FIND_DATAA data;
    int allowed;
} SEARCH;

typedef struct TREE_FRAME_TAG {
    int started;
    HANDLE handle;
    WIN32_FIND_DATAA data;
    char directory[TREE_PATH_MAX];
} TREE_FRAME;

typedef struct TREE_SEARCH_TAG {
    int used;
    int depth;
    int includeZip;
    int currentMatches;
    int currentIsZip;
    char mask[256];
    char currentName[256];
    char currentPath[TREE_PATH_MAX];
    WIN32_FIND_DATAA currentData;
    TREE_FRAME frames[MAX_TREE_DEPTH];
} TREE_SEARCH;

static SEARCH searches[MAX_SEARCHES];
static TREE_SEARCH trees[MAX_TREES];

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

static int is_dot_directory(const char *name)
{
    return name[0] == '.' &&
           (name[1] == '\0' || (name[1] == '.' && name[2] == '\0'));
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

static int state_number(const SAL_STRING *state)
{
    char value[16];
    int index = 0;
    int result = 0;
    sal_to_c(state, value, sizeof(value));
    while (value[index] >= '0' && value[index] <= '9') {
        result = result * 10 + value[index] - '0';
        index++;
    }
    return result - 1;
}

static void set_state(SAL_STRING *state, int slot)
{
    char value[3];
    int number = slot + 1;
    if (number >= 10) {
        value[0] = (char)('0' + number / 10);
        value[1] = (char)('0' + number % 10);
        value[2] = '\0';
    } else {
        value[0] = (char)('0' + number);
        value[1] = '\0';
    }
    c_to_sal(state, value, 2);
}

static int attributes(const WIN32_FIND_DATAA *data)
{
    int result = 0;
    DWORD value = data->dwFileAttributes;
    if (value & FILE_ATTRIBUTE_READONLY) result |= 1;
    if (value & FILE_ATTRIBUTE_HIDDEN) result |= 2;
    if (value & FILE_ATTRIBUTE_SYSTEM) result |= 4;
    if (value & FILE_ATTRIBUTE_DIRECTORY) result |= 16;
    if (value & FILE_ATTRIBUTE_ARCHIVE) result |= 32;
    if (value & FILE_ATTRIBUTE_REPARSE_POINT) result |= 1024;
    return result;
}

static int accepted(const SEARCH *search)
{
    int special = attributes(&search->data) & (1 | 2 | 4 | 16 | 1024);
    return ((special & ~search->allowed) == 0);
}

static int next_accepted(SEARCH *search)
{
    while (FindNextFileA(search->handle, &search->data)) {
        if (accepted(search)) return 1;
    }
    FindClose(search->handle);
    search->handle = INVALID_HANDLE_VALUE;
    search->used = 0;
    return 0;
}

static SEARCH *get_search(const SAL_STRING *state)
{
    int slot = state_number(state);
    if (slot < 0 || slot >= MAX_SEARCHES || !searches[slot].used) return NULL;
    return &searches[slot];
}

static int tree_state_number(const SAL_STRING *state)
{
    int result;
    if (!state || state->length != 1) return -1;
    result = state->text[0] - '1';
    return result;
}

static TREE_SEARCH *get_tree(const SAL_STRING *state)
{
    int slot = tree_state_number(state);
    if (slot < 0 || slot >= MAX_TREES || !trees[slot].used) return NULL;
    return &trees[slot];
}

static void close_tree(TREE_SEARCH *tree)
{
    int depth;
    if (!tree || !tree->used) return;
    for (depth = 0; depth <= tree->depth && depth < MAX_TREE_DEPTH; depth++) {
        if (tree->frames[depth].started &&
            tree->frames[depth].handle != INVALID_HANDLE_VALUE)
            FindClose(tree->frames[depth].handle);
    }
    tree->depth = -1;
    tree->used = 0;
}

static void initialize_frame(TREE_FRAME *frame, const char *directory)
{
    frame->started = 0;
    frame->handle = INVALID_HANDLE_VALUE;
    copy_text(frame->directory, directory, TREE_PATH_MAX - 1);
    if (text_length(frame->directory) > 0 &&
        frame->directory[text_length(frame->directory) - 1] != '\\')
        append_text(frame->directory, "\\", TREE_PATH_MAX - 1);
}

static int next_frame_entry(TREE_FRAME *frame)
{
    char pattern[TREE_PATH_MAX];
    if (!frame->started) {
        copy_text(pattern, frame->directory, TREE_PATH_MAX - 1);
        append_text(pattern, "*", TREE_PATH_MAX - 1);
        frame->handle = FindFirstFileA(pattern, &frame->data);
        frame->started = 1;
        return frame->handle != INVALID_HANDLE_VALUE;
    }
    if (frame->handle == INVALID_HANDLE_VALUE) return 0;
    return FindNextFileA(frame->handle, &frame->data) ? 1 : 0;
}

static int tree_local_time(const WIN32_FIND_DATAA *data, SYSTEMTIME *systemTime)
{
    FILETIME localTime;
    if (!FileTimeToLocalFileTime(&data->ftLastWriteTime, &localTime)) return 0;
    return FileTimeToSystemTime(&localTime, systemTime) ? 1 : 0;
}

BOOL WINAPI DllEntryPoint(HINSTANCE instance, DWORD reason, LPVOID reserved)
{
    int index;
    (void)instance;
    (void)reserved;
    if (reason == DLL_PROCESS_DETACH) {
        for (index = 0; index < MAX_SEARCHES; index++) {
            if (searches[index].used && searches[index].handle != INVALID_HANDLE_VALUE)
                FindClose(searches[index].handle);
        }
        for (index = 0; index < MAX_TREES; index++) close_tree(&trees[index]);
    }
    return TRUE;
}

__declspec(dllexport) int PASCAL FF_FindFirst(
    SAL_STRING *pathS, SAL_STRING *stateS, int attrI)
{
    char path[MAX_PATH * 2];
    int slot;
    for (slot = 0; slot < MAX_SEARCHES; slot++)
        if (!searches[slot].used) break;
    if (slot == MAX_SEARCHES) return 0;

    sal_to_c(pathS, path, sizeof(path));
    searches[slot].handle = FindFirstFileA(path, &searches[slot].data);
    if (searches[slot].handle == INVALID_HANDLE_VALUE) return 0;
    searches[slot].used = 1;
    searches[slot].allowed = attrI;
    set_state(stateS, slot);
    if (accepted(&searches[slot])) return 1;
    return next_accepted(&searches[slot]);
}

__declspec(dllexport) int PASCAL FF_FindNext(SAL_STRING *stateS)
{
    SEARCH *search = get_search(stateS);
    if (!search) return 0;
    return next_accepted(search);
}

__declspec(dllexport) int PASCAL FF_GetName(SAL_STRING *stateS, SAL_STRING *nameS)
{
    SEARCH *search = get_search(stateS);
    if (!search) return 0;
    c_to_sal(nameS, search->data.cFileName, SAL_TEXT_MAX);
    return 1;
}

__declspec(dllexport) int PASCAL FF_GetAttr(SAL_STRING *stateS)
{
    SEARCH *search = get_search(stateS);
    return search ? attributes(&search->data) : 0;
}

__declspec(dllexport) int PASCAL FF_GetSize(SAL_STRING *stateS)
{
    SEARCH *search = get_search(stateS);
    unsigned __int64 size;
    if (!search) return 0;
    size = ((unsigned __int64)search->data.nFileSizeHigh << 32) |
           (unsigned __int64)search->data.nFileSizeLow;
    if (size > 2147483647UL) return 2147483647L;
    return (int)size;
}

static int get_local_time(SEARCH *search, SYSTEMTIME *systemTime)
{
    FILETIME localTime;
    if (!FileTimeToLocalFileTime(&search->data.ftLastWriteTime, &localTime)) return 0;
    return FileTimeToSystemTime(&localTime, systemTime) ? 1 : 0;
}

__declspec(dllexport) int PASCAL FF_GetDate(SAL_STRING *stateS, SAL_STRING *dateS)
{
    SEARCH *search = get_search(stateS);
    SYSTEMTIME value;
    char text[9];
    if (!search || !get_local_time(search, &value)) return 0;
    text[0] = (char)('0' + value.wMonth / 10);
    text[1] = (char)('0' + value.wMonth % 10);
    text[2] = '/';
    text[3] = (char)('0' + value.wDay / 10);
    text[4] = (char)('0' + value.wDay % 10);
    text[5] = '/';
    text[6] = (char)('0' + (value.wYear % 100) / 10);
    text[7] = (char)('0' + value.wYear % 10);
    text[8] = '\0';
    c_to_sal(dateS, text, 8);
    return 1;
}

__declspec(dllexport) int PASCAL FF_GetTime(SAL_STRING *stateS, SAL_STRING *timeS)
{
    SEARCH *search = get_search(stateS);
    SYSTEMTIME value;
    char text[9];
    if (!search || !get_local_time(search, &value)) return 0;
    text[0] = (char)('0' + value.wHour / 10);
    text[1] = (char)('0' + value.wHour % 10);
    text[2] = ':';
    text[3] = (char)('0' + value.wMinute / 10);
    text[4] = (char)('0' + value.wMinute % 10);
    text[5] = ':';
    text[6] = (char)('0' + value.wSecond / 10);
    text[7] = (char)('0' + value.wSecond % 10);
    text[8] = '\0';
    c_to_sal(timeS, text, 8);
    return 1;
}

__declspec(dllexport) int PASCAL FF_TreeOpen(
    SAL_STRING *directoryS, SAL_STRING *maskS, int includeZipI,
    SAL_STRING *stateS)
{
    char directory[TREE_PATH_MAX];
    int slot;
    for (slot = 0; slot < MAX_TREES; slot++) if (!trees[slot].used) break;
    if (slot == MAX_TREES) return 0;

    sal_to_c(directoryS, directory, sizeof(directory));
    trees[slot].used = 1;
    trees[slot].depth = 0;
    trees[slot].includeZip = includeZipI;
    trees[slot].currentMatches = 0;
    trees[slot].currentIsZip = 0;
    sal_to_c(maskS, trees[slot].mask, sizeof(trees[slot].mask));
    initialize_frame(&trees[slot].frames[0], directory);
    stateS->length = 1;
    stateS->text[0] = (char)('1' + slot);
    return 1;
}

__declspec(dllexport) int PASCAL FF_TreeNext(SAL_STRING *stateS)
{
    TREE_SEARCH *tree = get_tree(stateS);
    TREE_FRAME *frame;
    WIN32_FIND_DATAA *data;
    char fullPath[TREE_PATH_MAX];

    if (!tree) return 0;
    while (tree->depth >= 0) {
        frame = &tree->frames[tree->depth];
        if (!next_frame_entry(frame)) {
            if (frame->handle != INVALID_HANDLE_VALUE) FindClose(frame->handle);
            frame->handle = INVALID_HANDLE_VALUE;
            frame->started = 0;
            tree->depth--;
            continue;
        }

        data = &frame->data;
        if (is_dot_directory(data->cFileName)) continue;
        copy_text(fullPath, frame->directory, TREE_PATH_MAX - 1);
        append_text(fullPath, data->cFileName, TREE_PATH_MAX - 1);

        if (data->dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
            if (!(data->dwFileAttributes & FILE_ATTRIBUTE_REPARSE_POINT) &&
                tree->depth + 1 < MAX_TREE_DEPTH) {
                tree->depth++;
                initialize_frame(&tree->frames[tree->depth], fullPath);
            }
            continue;
        }

        tree->currentData = *data;
        copy_text(tree->currentName, data->cFileName, 255);
        copy_text(tree->currentPath, fullPath, TREE_PATH_MAX - 1);
        tree->currentMatches = wildcard_match(tree->mask, tree->currentName);
        tree->currentIsZip = is_zip_name(tree->currentName);
        if (tree->currentMatches || (tree->includeZip && tree->currentIsZip)) return 1;
    }
    return 0;
}

__declspec(dllexport) int PASCAL FF_TreeMatches(SAL_STRING *stateS)
{
    TREE_SEARCH *tree = get_tree(stateS);
    return tree ? tree->currentMatches : 0;
}

__declspec(dllexport) int PASCAL FF_TreeIsZip(SAL_STRING *stateS)
{
    TREE_SEARCH *tree = get_tree(stateS);
    return tree ? tree->currentIsZip : 0;
}

__declspec(dllexport) int PASCAL FF_TreeGetName(
    SAL_STRING *stateS, SAL_STRING *nameS)
{
    TREE_SEARCH *tree = get_tree(stateS);
    if (!tree) return 0;
    c_to_sal(nameS, tree->currentName, SAL_TEXT_MAX);
    return 1;
}

__declspec(dllexport) int PASCAL FF_TreeGetPath(
    SAL_STRING *stateS, SAL_STRING *pathS)
{
    TREE_SEARCH *tree = get_tree(stateS);
    if (!tree) return 0;
    c_to_sal(pathS, tree->currentPath, SAL_TEXT_MAX);
    return 1;
}

__declspec(dllexport) int PASCAL FF_TreeGetSize(SAL_STRING *stateS)
{
    TREE_SEARCH *tree = get_tree(stateS);
    unsigned __int64 size;
    if (!tree) return 0;
    size = ((unsigned __int64)tree->currentData.nFileSizeHigh << 32) |
           (unsigned __int64)tree->currentData.nFileSizeLow;
    if (size > 2147483647UL) return 2147483647L;
    return (int)size;
}

__declspec(dllexport) int PASCAL FF_TreeGetDate(
    SAL_STRING *stateS, SAL_STRING *dateS)
{
    TREE_SEARCH *tree = get_tree(stateS);
    SYSTEMTIME value;
    char text[9];
    if (!tree || !tree_local_time(&tree->currentData, &value)) return 0;
    text[0] = (char)('0' + value.wMonth / 10);
    text[1] = (char)('0' + value.wMonth % 10);
    text[2] = '/';
    text[3] = (char)('0' + value.wDay / 10);
    text[4] = (char)('0' + value.wDay % 10);
    text[5] = '/';
    text[6] = (char)('0' + (value.wYear % 100) / 10);
    text[7] = (char)('0' + value.wYear % 10);
    text[8] = '\0';
    c_to_sal(dateS, text, 8);
    return 1;
}

__declspec(dllexport) int PASCAL FF_TreeGetTime(
    SAL_STRING *stateS, SAL_STRING *timeS)
{
    TREE_SEARCH *tree = get_tree(stateS);
    SYSTEMTIME value;
    char text[9];
    if (!tree || !tree_local_time(&tree->currentData, &value)) return 0;
    text[0] = (char)('0' + value.wHour / 10);
    text[1] = (char)('0' + value.wHour % 10);
    text[2] = ':';
    text[3] = (char)('0' + value.wMinute / 10);
    text[4] = (char)('0' + value.wMinute % 10);
    text[5] = ':';
    text[6] = (char)('0' + value.wSecond / 10);
    text[7] = (char)('0' + value.wSecond % 10);
    text[8] = '\0';
    c_to_sal(timeS, text, 8);
    return 1;
}

__declspec(dllexport) int PASCAL FF_TreeClose(SAL_STRING *stateS)
{
    TREE_SEARCH *tree = get_tree(stateS);
    if (!tree) return 0;
    close_tree(tree);
    return 1;
}
