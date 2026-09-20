/*
    screenshotwindowtse_dll.c
    Version 1.0.0.0.18

    TSE SAL supplies:
      - final output pathname
      - output format
      - optional target-window title or title fragment

    Empty target-window title:
      capture the current foreground window.

    Non-empty target-window title:
      enumerate visible top-level windows, try an exact case-insensitive
      title match first, then a case-insensitive partial title match.

    file type:
      1 = PNG
      2 = BMP
      3 = JPEG/JPG

    PNG/JPEG/BMP encoding uses the GDI+ flat API loaded dynamically from
    gdiplus.dll. No Borland GDI+ import library or C runtime is required.
*/

#include <windows.h>

#ifndef PW_RENDERFULLCONTENT
#define PW_RENDERFULLCONTENT 0x00000002
#endif

typedef BOOL (WINAPI *PFNPRINTWINDOW)(HWND, HDC, UINT);

typedef struct {
    unsigned long GdiplusVersion;
    void *DebugEventCallback;
    BOOL SuppressBackgroundThread;
    BOOL SuppressExternalCodecs;
} GDIPLUSSTARTUPINPUT_LOCAL;

typedef int (WINAPI *PFNGDIPLUSSTARTUP)(unsigned long *, const GDIPLUSSTARTUPINPUT_LOCAL *, void *);
typedef void (WINAPI *PFNGDIPLUSSHUTDOWN)(unsigned long);
typedef int (WINAPI *PFNGDIPCREATEBITMAPFROMHBITMAP)(HBITMAP, HPALETTE, void **);
typedef int (WINAPI *PFNGDIPSAVEIMAGETOFILE)(void *, const WCHAR *, const CLSID *, const void *);
typedef int (WINAPI *PFNGDIPDISPOSEIMAGE)(void *);

static char g_outputPath[MAX_PATH];
static int g_outputLen = 0;
static int g_fileType = 1;

static char g_windowTitle[256];
static int g_windowTitleLen = 0;
static HWND g_foundWindow = NULL;
static int g_matchExact = 0;

static const CLSID CLSID_BMP_ENCODER =
    {0x557cf400,0x1a04,0x11d3,{0x9a,0x73,0x00,0x00,0xf8,0x1e,0xf3,0x2e}};
static const CLSID CLSID_JPEG_ENCODER =
    {0x557cf401,0x1a04,0x11d3,{0x9a,0x73,0x00,0x00,0xf8,0x1e,0xf3,0x2e}};
static const CLSID CLSID_PNG_ENCODER =
    {0x557cf406,0x1a04,0x11d3,{0x9a,0x73,0x00,0x00,0xf8,0x1e,0xf3,0x2e}};

static void ZeroBytes(void *ptr, DWORD count)
{
    BYTE *p = (BYTE *)ptr;
    while (count) {
        *p++ = 0;
        --count;
    }
}

static char LowerAscii(char c)
{
    if (c >= 'A' && c <= 'Z')
        return (char)(c + ('a' - 'A'));

    return c;
}

static int EqualNoCase(const char *a, const char *b)
{
    int i;

    i = 0;
    while (a[i] && b[i]) {
        if (LowerAscii(a[i]) != LowerAscii(b[i]))
            return 0;
        ++i;
    }

    return a[i] == 0 && b[i] == 0;
}

static int ContainsNoCase(const char *text, const char *part)
{
    int i;
    int j;

    if (!part[0])
        return 1;

    i = 0;
    while (text[i]) {
        j = 0;
        while (part[j] && text[i + j] &&
               LowerAscii(text[i + j]) == LowerAscii(part[j])) {
            ++j;
        }

        if (!part[j])
            return 1;

        ++i;
    }

    return 0;
}

static BOOL CALLBACK FindWindowEnumProc(HWND hwnd, LPARAM lParam)
{
    char title[256];
    int len;

    if (lParam != 0) {
    }

    if (!IsWindowVisible(hwnd))
        return TRUE;

    title[0] = 0;
    len = GetWindowTextA(hwnd, title, sizeof(title));
    if (len <= 0)
        return TRUE;

    if (g_matchExact) {
        if (!EqualNoCase(title, g_windowTitle))
            return TRUE;
    } else {
        if (!ContainsNoCase(title, g_windowTitle))
            return TRUE;
    }

    g_foundWindow = hwnd;
    return FALSE;
}

static HWND FindTargetWindow(void)
{
    if (g_windowTitleLen == 0)
        return GetForegroundWindow();

    g_foundWindow = NULL;
    g_matchExact = 1;
    EnumWindows(FindWindowEnumProc, 0);

    if (g_foundWindow)
        return g_foundWindow;

    g_matchExact = 0;
    EnumWindows(FindWindowEnumProc, 0);

    return g_foundWindow;
}

__declspec(dllexport) int SWTSResetOutputPath(void)
{
    g_outputLen = 0;
    g_outputPath[0] = 0;
    return 1;
}

__declspec(dllexport) int SWTSAddOutputChar(int charI)
{
    if (charI < 1 || charI > 255)
        return 0;

    if (g_outputLen >= MAX_PATH - 1)
        return 0;

    g_outputPath[g_outputLen++] = (char)charI;
    g_outputPath[g_outputLen] = 0;
    return 1;
}

__declspec(dllexport) int SWTSSetFileType(int fileTypeI)
{
    if (fileTypeI < 1 || fileTypeI > 3)
        return 0;

    g_fileType = fileTypeI;
    return 1;
}

__declspec(dllexport) int SWTSResetWindowTitle(void)
{
    g_windowTitleLen = 0;
    g_windowTitle[0] = 0;
    return 1;
}

__declspec(dllexport) int SWTSAddWindowTitleChar(int charI)
{
    if (charI < 1 || charI > 255)
        return 0;

    if (g_windowTitleLen >= 255)
        return 0;

    g_windowTitle[g_windowTitleLen++] = (char)charI;
    g_windowTitle[g_windowTitleLen] = 0;
    return 1;
}

static int SaveHBitmapWithGdiPlus(HBITMAP hBitmap)
{
    HMODULE hGdiPlus;
    PFNGDIPLUSSTARTUP pStartup;
    PFNGDIPLUSSHUTDOWN pShutdown;
    PFNGDIPCREATEBITMAPFROMHBITMAP pCreateBitmap;
    PFNGDIPSAVEIMAGETOFILE pSave;
    PFNGDIPDISPOSEIMAGE pDispose;
    GDIPLUSSTARTUPINPUT_LOCAL input;
    unsigned long token;
    void *image;
    WCHAR widePath[MAX_PATH];
    const CLSID *encoder;
    int status;
    int wideCount;

    hGdiPlus = LoadLibraryA("gdiplus.dll");
    if (!hGdiPlus)
        return -5;

    pStartup = (PFNGDIPLUSSTARTUP)GetProcAddress(hGdiPlus, "GdiplusStartup");
    pShutdown = (PFNGDIPLUSSHUTDOWN)GetProcAddress(hGdiPlus, "GdiplusShutdown");
    pCreateBitmap = (PFNGDIPCREATEBITMAPFROMHBITMAP)GetProcAddress(hGdiPlus, "GdipCreateBitmapFromHBITMAP");
    pSave = (PFNGDIPSAVEIMAGETOFILE)GetProcAddress(hGdiPlus, "GdipSaveImageToFile");
    pDispose = (PFNGDIPDISPOSEIMAGE)GetProcAddress(hGdiPlus, "GdipDisposeImage");

    if (!pStartup || !pShutdown || !pCreateBitmap || !pSave || !pDispose) {
        FreeLibrary(hGdiPlus);
        return -5;
    }

    ZeroBytes(&input, sizeof(input));
    input.GdiplusVersion = 1;

    token = 0;
    status = pStartup(&token, &input, NULL);
    if (status != 0) {
        FreeLibrary(hGdiPlus);
        return -5;
    }

    image = NULL;
    status = pCreateBitmap(hBitmap, NULL, &image);
    if (status != 0 || !image) {
        pShutdown(token);
        FreeLibrary(hGdiPlus);
        return -5;
    }

    wideCount = MultiByteToWideChar(CP_ACP, 0, g_outputPath, -1, widePath, MAX_PATH);
    if (wideCount <= 0) {
        pDispose(image);
        pShutdown(token);
        FreeLibrary(hGdiPlus);
        return -5;
    }

    if (g_fileType == 2)
        encoder = &CLSID_BMP_ENCODER;
    else if (g_fileType == 3)
        encoder = &CLSID_JPEG_ENCODER;
    else
        encoder = &CLSID_PNG_ENCODER;

    status = pSave(image, widePath, encoder, NULL);

    pDispose(image);
    pShutdown(token);
    FreeLibrary(hGdiPlus);

    return status == 0 ? 1 : -5;
}

static int CaptureWindowHandle(HWND hwnd)
{
    RECT rc;
    int width;
    int height;
    HDC hdcWindow;
    HDC hdcMem;
    HBITMAP hBitmap;
    HGDIOBJ oldObject;
    HMODULE hUser32;
    PFNPRINTWINDOW pPrintWindow;
    BOOL captured;
    int result;

    if (!GetWindowRect(hwnd, &rc))
        return -2;

    width = rc.right - rc.left;
    height = rc.bottom - rc.top;
    if (width <= 0 || height <= 0)
        return -2;

    hdcWindow = GetWindowDC(hwnd);
    if (!hdcWindow)
        return -3;

    hdcMem = CreateCompatibleDC(hdcWindow);
    if (!hdcMem) {
        ReleaseDC(hwnd, hdcWindow);
        return -3;
    }

    hBitmap = CreateCompatibleBitmap(hdcWindow, width, height);
    if (!hBitmap) {
        DeleteDC(hdcMem);
        ReleaseDC(hwnd, hdcWindow);
        return -3;
    }

    oldObject = SelectObject(hdcMem, hBitmap);

    captured = FALSE;
    hUser32 = GetModuleHandleA("user32.dll");
    pPrintWindow = NULL;

    if (hUser32)
        pPrintWindow = (PFNPRINTWINDOW)GetProcAddress(hUser32, "PrintWindow");

    if (pPrintWindow)
        captured = pPrintWindow(hwnd, hdcMem, PW_RENDERFULLCONTENT);

    if (!captured)
        captured = BitBlt(hdcMem, 0, 0, width, height, hdcWindow, 0, 0, SRCCOPY | CAPTUREBLT);

    SelectObject(hdcMem, oldObject);
    DeleteDC(hdcMem);
    ReleaseDC(hwnd, hdcWindow);

    if (!captured) {
        DeleteObject(hBitmap);
        return -3;
    }

    result = SaveHBitmapWithGdiPlus(hBitmap);
    DeleteObject(hBitmap);
    return result;
}

__declspec(dllexport) int SWTSCaptureWindow(void)
{
    HWND hwnd;

    if (g_outputLen == 0)
        return -4;

    hwnd = FindTargetWindow();

    if (!hwnd) {
        if (g_windowTitleLen > 0)
            return -6;
        return -1;
    }

    return CaptureWindowHandle(hwnd);
}

__declspec(dllexport) int SWTSCaptureActiveWindow(void)
{
    HWND hwnd;

    if (g_outputLen == 0)
        return -4;

    hwnd = GetForegroundWindow();
    if (!hwnd)
        return -1;

    return CaptureWindowHandle(hwnd);
}

BOOL WINAPI DllEntryPoint(HINSTANCE hinst, unsigned long reason, void *reserved)
{
    if (hinst != NULL) {
    }

    if (reason != 0) {
    }

    if (reserved != NULL) {
    }

    return TRUE;
}
