/*
To compile with Borland C 5.51:
bcc32 foo.c

To compile with GCC:
gcc foo.c -o foo -lcomdlg32 -luser32
*/

#include <windows.h>
#include <commdlg.h>
#include <stdio.h>
#include <wchar.h>

typedef unsigned char   uchar;

/*--------------------------------------------------------------
  copy a utf16 string to an ascii string
  u_len is the size of the unicode buffer in wchar_t chars.
  c_str means that unicode_buf is 0 terminated string.
  Either c_str must be set of u_len must be > 0.
 --------------------------------------------------------------*/
int utf16_to_ascii(const wchar_t *unicode_buf, char *ascii_buf,
        int u_len, int c_str) {
    uchar *cp = (uchar *)ascii_buf;
    const wchar_t *wp = unicode_buf;
    int ok = 1;

    if (u_len == 0 && !c_str)
        return 0;

    for (;;) {
        if (c_str) {
            if (*wp == 0)
                break;
        } else {
            if (u_len <= 0) {
                break;
            }
            --u_len;
        }
        // could set: *cp++ = '?' if char out of range.
        if ((unsigned)*wp > 127) {
            ok = 0;
        }

        *cp++ = *wp++;
    }
    if (c_str)
        *cp = '\0';
    return ok;
}

int main() {
    OPENFILENAMEW ofn;
    wchar_t szLongFile[MAX_PATH] = L"";
    wchar_t szShortFile[MAX_PATH] = L"";
    char short_file[MAX_PATH];

    // initialize the OPENFILENAMEW structure
    ZeroMemory(&ofn, sizeof(ofn));
    ofn.lStructSize = sizeof(ofn);
    ofn.hwndOwner = NULL;
    ofn.lpstrFile = szLongFile;
    ofn.nMaxFile = sizeof(szLongFile) / sizeof(wchar_t);
    ofn.lpstrFilter = L"All Files\0*.*\0";
    ofn.nFilterIndex = 1;
    ofn.Flags = OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST;

    if (GetOpenFileNameW(&ofn)) {

        // convert the long path to the 8.3 short format
        DWORD shortPathLength = GetShortPathNameW(szLongFile,
                szShortFile, MAX_PATH);

        if (shortPathLength == 0) {
            wchar_t szError[128];
            _snwprintf(szError, 128,
                L"Failed to get short path. Error code: %lu",
                GetLastError());
            MessageBoxW(NULL, szError, L"Error",
                MB_OK | MB_ICONERROR);
        } else {
            MessageBoxW(NULL, szShortFile,
                L"Short 8.3 Alternate Path",
                MB_OK | MB_ICONINFORMATION);
            MessageBoxW(NULL, szLongFile, L"Long Path",
                MB_OK | MB_ICONINFORMATION);

            utf16_to_ascii(szShortFile, short_file, 0, 1);
            MessageBox(NULL, short_file,
                "Short 8.3 Path in ASCII what TSE will use",
                MB_OK | MB_ICONINFORMATION);

        }

    }

    return 0;
}
