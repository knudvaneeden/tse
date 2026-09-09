/*
   bh.c - portable 32-bit BH launcher, Borland C++ 5.5
   Version 1.0.0.0.12 - 2026-09-09 22:56 CEST - OpenAI Codex
*/
#include <windows.h>
#include <shellapi.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void url_encode(const char *s, char *d, int max)
{
    static const char hx[] = "0123456789ABCDEF";
    unsigned char c;
    int n = 0;
    while ((c = (unsigned char)*s++) != 0 && n < max - 4) {
        if ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') ||
            (c >= '0' && c <= '9') || c == '_' || c == '-') d[n++] = c;
        else {
            d[n++] = '%'; d[n++] = hx[c >> 4]; d[n++] = hx[c & 15];
        }
    }
    d[n] = 0;
}

static void url_encode_path(const char *s, char *d, int max)
{
    static const char hx[] = "0123456789ABCDEF";
    unsigned char c;
    int n = 0;
    while ((c = (unsigned char)*s++) != 0 && n < max - 4) {
        if (c == '\\') c = '/';
        if ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') ||
            (c >= '0' && c <= '9') || c == '_' || c == '-' ||
            c == '.' || c == '/' || c == ':') d[n++] = c;
        else {
            d[n++] = '%'; d[n++] = hx[c >> 4]; d[n++] = hx[c & 15];
        }
    }
    d[n] = 0;
}

static void get_exe_directory(char *dir)
{
    char *p;
    GetModuleFileName(NULL, dir, MAX_PATH);
    p = strrchr(dir, '\\');
    if (p) *p = 0;
}

static void get_hlp_paths(const char *input, char *fullHlp, char *html)
{
    char hlpDirectory[MAX_PATH], base[MAX_PATH], *slash, *dot;
    GetFullPathName(input, MAX_PATH, fullHlp, NULL);
    strcpy(hlpDirectory, fullHlp);
    slash = strrchr(hlpDirectory, '\\');
    if (slash) {
        strcpy(base, slash + 1);
        *slash = 0;
    } else {
        strcpy(base, hlpDirectory);
        strcpy(hlpDirectory, ".");
    }
    dot = strrchr(base, '.');
    if (dot) *dot = 0;
    sprintf(html, "%s\\%s_html\\%s.html", hlpDirectory, base, base);
}

static int file_exists(const char *fileName)
{
    DWORD attributes = GetFileAttributes(fileName);
    return attributes != (DWORD)-1 && !(attributes & FILE_ATTRIBUTE_DIRECTORY);
}

static int convert_if_needed(const char *exeDir, const char *fullHlp,
                             const char *html)
{
    char outDir[MAX_PATH], command[4 * MAX_PATH], *slash;
    int result;
    if (file_exists(html)) return 1;
    if (!file_exists(fullHlp)) {
        MessageBox(NULL, "The selected HLP file was not found.",
                   "BH error", MB_OK | MB_ICONERROR);
        return 0;
    }
    strcpy(outDir, html);
    slash = strrchr(outDir, '\\');
    if (slash) *slash = 0;
    sprintf(command, "\"%s\\hlp2html.exe\" \"%s\" \"%s\"",
            exeDir, fullHlp, outDir);
    result = system(command);
    if (result != 0 || !file_exists(html)) {
        MessageBox(NULL, "Automatic HLP-to-HTML conversion failed.",
                   "BH error", MB_OK | MB_ICONERROR);
        return 0;
    }
    return 1;
}

int main(int argc, char **argv)
{
    char dir[MAX_PATH], ini[MAX_PATH], html[MAX_PATH], fullHlp[MAX_PATH];
    char query[1024], enc[3072], htmlUrl[3 * MAX_PATH];
    char target[4096], launcher[MAX_PATH];
    FILE *out;
    int firstQuery, i;

    get_exe_directory(dir);
    sprintf(ini, "%s\\bh.ini", dir);
    html[0] = 0;
    query[0] = 0;

    if (argc >= 3) {
        get_hlp_paths(argv[1], fullHlp, html);
        if (!convert_if_needed(dir, fullHlp, html)) return 2;
        WritePrivateProfileString("BH", "HelpFile", html, ini);
        firstQuery = 2;
    } else {
        GetPrivateProfileString("BH", "HelpFile", "", html, MAX_PATH, ini);
        if (!html[0]) {
            MessageBox(NULL, "Usage: bh.exe helpfile.hlp search-word",
                       "BH configuration", MB_OK | MB_ICONINFORMATION);
            return 1;
        }
        firstQuery = 1;
    }

    for (i = firstQuery; i < argc; i++) {
        if (i > firstQuery) strcat(query, " ");
        if (strlen(query) + strlen(argv[i]) < sizeof(query) - 1)
            strcat(query, argv[i]);
    }

    url_encode(query, enc, sizeof(enc));
    url_encode_path(html, htmlUrl, sizeof(htmlUrl));
    sprintf(target, "file:///%s#q=%s", htmlUrl, enc);
    sprintf(launcher, "%s\\bh_launch.html", dir);
    out = fopen(launcher, "wb");
    if (!out) {
        MessageBox(NULL, "Could not create bh_launch.html beside bh.exe.",
                   "BH error", MB_OK | MB_ICONERROR);
        return 3;
    }
    fputs("<!doctype html><meta charset=\"utf-8\"><title>BH search</title>"
          "<p>Opening Help search...</p><script>location.replace(\"", out);
    fputs(target, out);
    fputs("\");</script>", out);
    fclose(out);
    if ((INT_PTR)ShellExecute(NULL, "open", launcher, NULL, NULL,
                              SW_SHOWNORMAL) <= 32) {
        MessageBox(NULL, "Could not open the BH launcher page.",
                   "BH error", MB_OK | MB_ICONERROR);
        return 4;
    }
    return 0;
}
