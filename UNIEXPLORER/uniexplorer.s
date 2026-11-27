/*
  Extension       UniExplorer           (Was: UnicodeOpenFilenameFromExplorer)
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   Windows GUI TSE 4.50.33 target (compile); 4.50.35+ upstream runtime
  Version         v0.0.0.8   BETA   25 Nov 2026
  Local patch     1.0.0.0.19   27 Nov 2026 (unofficial compatibility build)


  This extension fixes five possible TSE v4.50.35-upwards bugs that can occur
  when opening a file with non-ASCII characters in its name from Windows File
  Explorer:

  - that TSE opens an ANSI-compatible filename by its short name.   (1)
  - that TSE opens an existing other file that has a similar name.  (2)
  - that TSE opens a not-empty file as an empty file.               (3)
  - that TSE does not start.                                        (4)
  - that TSE opens a file as empty and with the filename garbled.   (5)

  Windows File Explorer has the benefit, that it shows us a file's full name,
  unmodified for TSE's limitations.

  There are three ways to open a file from Windows File Explorer with TSE:
  - In Windows you associated a file extension with TSE, for example ".txt",
    and you now simply click or otherwise select the file in File Explorer.
  - You right-click or <Shift F10> a file in File Explorer,
    select "Open with", and then select TSE.
  - You added TSE to File Explorer's file context menu
    either during TSE's installation or with Potpourri's EditWithTSE tool,
    and now you right-click or <Shift F10> a file and select TSE.


  INSTALLATION

  Copy this file to TSE's "mac" directory and compile it there, for example
  by opening it there in TSE and applying the Macro Compile menu.

  Add "UniExplorer" low in the TSE's Macro AutoLoad List menu,
  below the Unicode macro if you have that one.
  Restart TSE.

  Note for the unlikely case that you *manually* added TSE to File Explorer's
  (right-click) context menu menu:
  If you did not let TSE's installation do it, or did not do it with Potpourri's
  EditWithTSE tool, then you need to verify that the context menu starts TSE
  with double quotes around the filename.


  DETAILS

  Because this file is likely to be read in TSE, I cannot use non-ASCII
  characters in the text here, because in TSE non-ASCII characters will
  display as different characters in different Windows configurations.
  For non-ASCII characters I will therefore resort to a character's Unicode
  name between quotes.

  Here are bugs in TSE v4.50.27 - v4.50.30, that this extension solves,
  and that might be solved in future TSE versions:

  (1)
    In most Western Windows installations TSE supports the ANSI character
    "latin small letter e with acute".
    However, TSE v4.50.27 upwards will show a filename containing it
    by its short filename instead. That is a step back.

  (2)
    If two similar filenames exists, where the only difference is that one uses
    a "latin small letter a" and the other a "latin small letter a with breve",
    then when you try to open the second one, TSE opens the first one instead.

    This is because TSE uses a default Windows mechanism to try to convert an
    unknown character, like a "latin small letter a with breve" to a related
    known character, like a "latin small letter a", a.k.a. "a".
    Windows calls this making a "best fit".
    Another example of this is the "greek small letter alpha" also being
    converted to an "a".

  (3)
    If TSE incorrectly converts an input filename, which is more likely to
    happen from Windows File Explorer, then TSE opens the incorrect filename
    as an empty file.
    For example, this happens if the filename contains a "latin small letter a
    with breve" but an otherwise same filename with an "a" does not exist.

  (4)
    If Windows' code page is one that uses 1-byte characters,
    then TSE does not (appear to) start from Windows File Explorer
    if the filename contains Chinese characters.

  (5)
    If Windows' code page is one that uses multi-byte characters, and an input
    filename is not ASCII, then TSE opens an empty file with a garbled filename
    instead.
    This for example happens for a filename containing a "latin small letter e
    with acute" or a Chinese character.
    The garbled filename characters are actually the bytes of the character
    according to the multi-byte code page.


  Here is test directory containing files with "evil" names:
    https://ecarlo.nl/tse/DemosAndTests.html#TestableUnicodeFilenames


  TODO    (UniExlorer)
    MUST
    - Replace the use of get_token_w(), which only works for drive-letter
      roots.
    - Check remaing "xx" issues.
    - More testing.
    SHOULD
    COULD
    WONT


  HISTORY

  v0.0.0.8  25 Nov 2026
    - Removed the work-around for TSE's inability to reliably open files
      by their short name, and made the fixed TSE version v4.50.35 this
      macro's minimum requirement.
    - Described this macro's main algorithms in the technical background
      section.
    - Tweaked some code.

  v0.0.0.7  24 Nov 2026
    Fixed internal bugs that caused external crashes:
    - Contrary to what its documentation says, PathCchStripToRoot's cchPath
      parameter must be the length (in "wide" characters, including NULL
      terminator) of pszPath's string, not of pszPath's buffer.
    - An index was increased twice: by and in a for-loop.
    - The macro's memory block for _WIN32_FIND_DATAW was defined too small.
    - Defining a memory block using a TSE line works unreliably, because the
      line's address can change as soon as it is not the current line.

    Identified a TSE bug that sometimes caused the wrong file to be loaded:
    - All TSE versions before v4.50.35 cannot reliably load the correct file
      based on its short name.

  v0.0.0.6   9 Nov 2026
    Fixed that the extension did not work if the Windows code page was 936
    (Simplified Chinese).

    Restricted usage to TSE versions <= v4.50.32 due to a bug in v4.50.33.

  v0.0.0.5    6 Oct 2026
    Updated the documentation.

    Unsolved bug found:
    The extension does not work if the Windows code page is 936 (Simplified
    Chinese).

  v0.0.0.4    5 Oct 2026
    Also made the extension work if the external code page is a multi-byte one,
    like 65001 (UTF-8).

    Changed the status to BETA.
    The extension seems to work, and there are no known bugs.

  v0.0.0.3   29 Sep 2026
    Renamed the extension from "UnicodeOpenFilenameFromExplorer" to
    "UniExplorer".

    Bugs were found.

    Completely rewrote the extension to keep a path's ANSI and ASCII names
    where possible, and only use Windows short names for non-ANSI names.
    For example, a name simply containing a "latin small letter e acute"
    should not be shortened if ANSI is available.

  v0.0.0.2   18 Sep 2026
    Included lots of debugging code to check whether it works correctly.
    For now the debugging code is left in.
    No bugs were found. An assumption was rectified and code was optimized.

  v0.0.0.1   15 Sep 2026
    Initial development release.

*/





/*
  T E C H N I C A L   B A C K G R O U N D   I N F O


  DEBUGGING WITH WARN()

    During WhenLoaded() the Warn() statement can display random garbage
    characters instead of non-ASCII characters.

    This was very confusing.
    It made me think the macro was wrong, where in fact the Warn() that
    debugged it was wrong.

    I created a ansi_to_ascii() function that converts a string to a pure
    ASCII alternative by replacing each non-displayable character and each
    non-ASCII character by its 2-character hex-value prefixed by '%'.

    Warn() displays this pure ASCII alternative correctly.


  WINDOWS LONG PATHS AND NAMES

    The way I understand it, nowadays long paths can be 32767 characters long
    instead of 260, while a path's name components can typically be 255
    characters long.

    Formally the maximum length of a name component is what the
    lpMaximumComponentLength parameter of the GetVolumeInformation
    function returns. This value is commonly 255 characters.

    Windows only has the legacy constant MAX_PATH for the value 260.
    I additionally defined my own constants for other maximum sizes.


    Because wide characters are UTF-16LE encoded characters, they can
    technically be 2 or 4 bytes long.
    However, just like Windows itself, this macro simplistically counts wide
    characters as the number of byte-pairs instead.
    In other words, one 4-byte UTF-16LE character is counted as two wide
    characters.


  WINDOWS SHORT NAMES

    Windows supports alternate "short names" for files.
    You might think these short names are limited to ASCII characters and
    Windows' old 8.3 format, however, this is not universally true.
    Using "dir /x" from the command line will show these short names.

    The Windows GetShortPathNameW() API does not return ASCII short names
    if the external code page is a multi-byte one other than 65001.
    In practice this is a problem for code page 936 (Simplified Chinese).

    I had to program my own get_short_path_name_w() function that does
    always return ASCII short names.

    I created a dedicated test macro:
      https://ecarlo.nl/tse/DemosAndTests.html#Test_GetShortPaths


  ALGORITHM FOR OPENING A FILE FROM WINDOW FILE EXPLORER

  - Determine the max-byte-size of the default Windows' code page's characters
    with GetCPInfoExW().
  - Get the command line passed to TSE with GetCommandLineW().
    This will contain the fully qualified names of g32.exe and its one
    parameter, typically both double-quoted.
  - Stop if the command line does not contain 4 double quotes.
    Let TSE handle this situation, even if it cannot.
  - Get the filename parameter.
  - Stop if the filename is fully compatible with ASCII.
    Let TSE handle this situation: It can.
  - Replace all parts of the fully qualified filename with their short names.
    If the Windows code page's max-byte-size is 1,
    then use GetShortPathNameW(),
    otherwise program and use your own get_short_path_name_w().
    There is a "GET_SHORT_PATH_NAME_W() ALGORITHM" described further on.
  - Note:
    We now have a long and short form of the fully qualified filename,
    for example:
      T:\TestableUnicodeFilenames\The letter á.txt
      T:\TESTAB~1\THELET~3.TXT
    and
      T:\TestableUnicodeFilenames\The letter <a-non-code-page-1252-letter>.txt
      T:\TESTAB~1\TH0244~1.TXT
  - Note:
    GUI TSE internally uses code page 1252.
    We want GUI TSE to show code page 1252-compatible name-parts by their long
    name, and other name-parts by their short name.
    We can determine whether a name-part is code page 1252-compatible,
    by converting it from UTF-16LE to code page 1252 and back with
      WideCharToMultiByte()
      MultiByteToWideChar()
    If the converted name-part equals the original, then it is 1252-compatible.
  - Merge the fully qualified filenames' long and short name-parts:
    If the name-part is code page 1252-compatible, then use its long name-part,
    otherwise use its short name-part.
  - Note:
    For example, the above two examples result in
      T:\TestableUnicodeFilenames\The letter á.txt
    and
      T:\TestableUnicodeFilenames\TH0244~1.TXT
    This example does not show that this algorithm would also replace
    directory-names by their short names if they contain characters that are
    code page 1252-incompatible.
  - Open the file in TSE using all its short name-parts.
    If this fails, then stop and let TSE handle the file.
  - Rename the file to its merged name.
  - Set(DosCmdLine, '') to stop TSE from handling the file.


  ALGORITHM FOR SAVING NON-ASCII FILENAMES
    If the file was opened by UniExplorer
    and UniExplorer changed its full filename
    then:
    - _ON_FILE_SAVE_
        Remember the file's current ANSI name.
        Get the file's wide long name with MultiByteToWideChar().
        Get the file's wide short name with get_short_path_name_w().
        Get the file's ASCII short name.
        Change the file's name to its ASCII short name.
        Let TSE save the file using its ASCII short name.
    - _AFTER_FILE_SAVE_
        Restore the filename to its remembered name.


  GET_SHORT_PATH_NAME_W() ALGORITHM

    The Windows function GetShortPathNameW() works OK for single-byte code
    pages, but might not return ASCII characters for multi-byte code pages.
    A specific example is code page 936 (Simplified Chinese), for which
    GetShortPathNameW() might return a short name with Chinese characters
    instead of ASCII characters.

    Get_short_path_name_w() uses the feature that FindFirstFileW() also returns
    the short name of its last name-part, and there the short name is ASCII.

    Get_short_path_name_w()'s algorithm is to rebuild the filename from its
    root, adding one directory-part or filename-part at a time, and calling
    FindFirstFileW() to get each part's ASCII short name.

    Caveat:
      This only makes sense for drives that support short names.
      Untested:
        The algorithm assumes FindFirstFileW() "knows" on which drives to
        return short names for filename parts.

    For example:
      Starting with
        T:\TestableUnicodeFilenames\The letter á.txt
      the algorithm step by step builds up
        T:\TESTAB~1
        T:\TESTAB~1\THELET~3.TXT
      calling FindFirstFileW() for each step.

*/





// Start of compatibility restrictions and mitigations ...


#ifdef LINUX
  Error: This extension is not compatible with LINUX TSE.
#endif

#ifndef INTERNAL_VERSION
  #define INTERNAL_VERSION 0
#endif

// Local compatibility patch 1.0.0.0.19.
// Experimental legacy runtime is enabled by default in this release.
// Set FALSE to disable legacy runtime; test with disposable files only.
#define UNIEXPLORER_LEGACY_RUNTIME TRUE



//  End of compatibility restrictions and mitigations.





//  Constants and semi-constants

//  Currently this constant should be FALSE,
//  because UniExplorer randomly crashes when it uses GlobalAlloc().
//  Despite weeks of testing I still do not know why.
//  Also note that this constant occurs in FOUR places.
#define MEMBLOCK_USES_GLOBAL_ALLOC FALSE

#if MEMBLOCK_USES_GLOBAL_ALLOC
  #define MAX_LONG_PATH               32768
  #define MAXLINELEN_W                MAXLINELEN * 2
#else
  #define MAX_LONG_PATH               15000
  #define MAXLINELEN_W                MAXLINELEN
#endif

#define BACKSLASH                     92
#define COLON                         58
#define CP_ACP                        0
#define DOUBLE_QUOTE                  34
integer EXT_CP_MAX_CHAR_LENGTH      = 0
#define FIND_DATA_SIZE_W              602
#define FIND_DATA_W_SHORT_NAME_OFFSET 564
#define GMEM_FIXED                    0x0000
#define GMEM_ZEROINIT                 0x0040
#define INVALID_HANDLE_VALUE          -1
#define LPCPINFOEXW_LENGTH            532
string  MACRO_NAME   [MAXSTRINGLEN] = ''
#define MAX_CMDLINE_LENGTH            8191
#define MAX_CMDLINE_LENGTH_W          MAX_CMDLINE_LENGTH * 2
#define MAX_LONG_PATH_W               MAX_LONG_PATH * 2
#define MAX_NAME                      256
#define MAX_NAME_W                    MAX_NAME * 2
#define MAX_PATH                      260
#define MAX_PATH_W                    MAX_PATH * 2
#define MAX_SHORT_NAME                14
#define MAX_SHORT_NAME_W              MAX_SHORT_NAME * 2
#define MB_ERR_INVALID_CHARS          0x00000008
#define MB_PRECOMPOSED                0x00000001
#define NULL                          0
#define QUESTIONMARK                  63
#define S_FALSE                       1
#define S_OK                          0
integer TSE_CODE_PAGE               = 0
#define USE_NULL_TERMINATED_STRINGS  -1
#define WC_COMPOSITECHECK             0x00000200
#define WC_DEFAULTCHAR                0x00000040
#define WC_ERR_INVALID_CHARS          0x00000080 // Only use for CP 65001.
#define WC_NO_BEST_FIT_CHARS          0x00000400





//  Global variables

integer g_ansi_long_path_address  = 0
integer g_ansi_short_path_address = 0
integer g_container_id            = 0
integer g_wide_long_path_address  = 0
integer g_wide_short_path_address = 0





//  Start of Windows APIs ...


dll "<Kernel32.dll>"
  /*
    https://learn.microsoft.com/en-us/windows/win32/api/processenv/nf-processenv-getcommandlinew

    LPWSTR GetCommandLineW();
  */
  integer proc GetCommandLineW()

  integer proc CopyFileW(integer sourceAddressI, integer destinationAddressI, integer failIfExistsI)


  /*
    https://learn.microsoft.com/en-us/windows/win32/api/processenv/nf-processenv-getcommandlinea

    LPSTR GetCommandLineA();
  */
  integer proc GetCommandLineA()


  /*
    https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-getshortpathnamew
      GetShortPathNameW(..., 0, 0) returns the length in characters including
      the terminating NULL character.

    DWORD GetShortPathNameW(
      [in]  LPCWSTR lpszLongPath,
      [out] LPWSTR  lpszShortPath,
      [in]  DWORD   cchBuffer);
  */
  integer proc GetShortPathNameW(
    integer lpszLongPath,
    integer lpszShortPath,
    integer cchBuffer)


  /*
    https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-getshortpathnamea
      GetShortPathNameA(..., 0, 0) returns the length in characters including
      the terminating NULL character.

    DWORD GetShortPathNameA(
      [in]  LPCSTR lpszLongPath,
      [out] LPSTR  lpszShortPath,
      [in]  DWORD  cchBuffer);
  */
  integer proc GetShortPathNameA(
    integer lpszLongPath,
    integer lpszShortPath,
    integer cchBuffer)


  /*
    https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-findfirstfilea
      https://learn.microsoft.com/en-us/windows/win32/api/minwinbase/ns-minwinbase-win32_find_dataa

    HANDLE FindFirstFileA(
      [in]  LPCSTR             lpFileName,
      [out] LPWIN32_FIND_DATAA lpFindFileData);

    typedef struct _WIN32_FIND_DATAA {
      DWORD dwFileAttributes;                4
      FILETIME ftCreationTime;               8
      FILETIME ftLastAccessTime;             8
      FILETIME ftLastWriteTime;              8
      DWORD nFileSizeHigh;                   4
      DWORD nFileSizeLow;                    4
      DWORD dwReserved0;                     4
      DWORD dwReserved1;                     4
      CHAR cFileName[MAX_PATH];            260
      CHAR cAlternateFileName[14];          14
    #ifdef _MAC
      DWORD dwFileType;
      DWORD dwCreatorType;
      WORD  wFinderFlags;
    #endif
    } WIN32_FIND_DATAA, *PWIN32_FIND_DATAA, *LPWIN32_FIND_DATAA;
  */
  integer proc FindFirstFileA(
    integer lpFileName,
    integer lpFindFileData)


  /*
    https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-findfirstfilew
      https://learn.microsoft.com/en-us/windows/win32/api/minwinbase/ns-minwinbase-win32_find_dataw

    HANDLE FindFirstFileW(
      [in]  LPCWSTR            lpFileName,
      [out] LPWIN32_FIND_DATAW lpFindFileData);

    typedef struct _WIN32_FIND_DATAW {
      DWORD dwFileAttributes;                4
      FILETIME ftCreationTime;               8
      FILETIME ftLastAccessTime;             8
      FILETIME ftLastWriteTime;              8
      DWORD nFileSizeHigh;                   4
      DWORD nFileSizeLow;                    4
      DWORD dwReserved0;                     4
      DWORD dwReserved1;                     4  //  Subtotal  44 bytes
      WCHAR cFileName[MAX_PATH];           520  //  Subtotal 564 bytes
      WCHAR cAlternateFileName[14];         28  //  Subtotal 592 bytes
    #ifdef _MAC
      DWORD dwFileType;                      4
      DWORD dwCreatorType;                   4
      WORD  wFinderFlags;                    2  //  Total    602 bytes
    #endif
    } WIN32_FIND_DATAW, *PWIN32_FIND_DATAW, *LPWIN32_FIND_DATAW;
  */
  integer proc FindFirstFileW(
    integer lpFileName,
    integer lpFindFileData)


  /*
    https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-findclose

    BOOL FindClose(
      [in, out] HANDLE hFindFile);
  */
  integer proc FindClose(
    integer hFindFile)




  /*
    https://learn.microsoft.com/en-us/windows/win32/api/stringapiset/nf-stringapiset-widechartomultibyte

    int WideCharToMultiByte(
      [in]            UINT                               CodePage,
      [in]            DWORD                              dwFlags,
      [in]            _In_NLS_string_(cchWideChar)LPCWCH lpWideCharStr,
      [in]            int                                cchWideChar,
      [out, optional] LPSTR                              lpMultiByteStr,     [Pointer to NULL-terminated string of 8-bit CHARs.]
      [in]            int                                cbMultiByte,
      [in, optional]  LPCCH                              lpDefaultChar,      [Pointer to 8-bit CHAR.]
      [out, optional] LPBOOL                             lpUsedDefaultChar); [Poiter to BOOL, both 32-bit integers.]
  */
  integer proc WideCharToMultiByte(
        integer code_page,
        integer dwFlags,
        integer lpWideCharStr,
        integer cchWideChar,
        integer lpMultiByteStr,
        integer cbMultiByte,
        integer lpDefaultChar,
    var integer lpUsedDefaultChar)


  /*
    https://learn.microsoft.com/en-us/windows/win32/api/stringapiset/nf-stringapiset-multibytetowidechar

    int MultiByteToWideChar(
      [in]            UINT                              CodePage,
      [in]            DWORD                             dwFlags,
      [in]            _In_NLS_string_(cbMultiByte)LPCCH lpMultiByteStr,
      [in]            int                               cbMultiByte,
      [out, optional] LPWSTR                            lpWideCharStr,
      [in]            int                               cchWideChar);
  */
  integer proc MultiByteToWideChar(
    integer CodePage,
    integer dwFlags,
    integer lpMultiByteStr,
    integer cbMultiByte,
    integer lpWideCharStr,
    integer cchWideChar)


  /*
    https://learn.microsoft.com/en-us/windows/win32/api/winnls/nf-winnls-getcpinfoexw

    BOOL GetCPInfoExW(
      [in]  UINT        CodePage,
      [in]  DWORD       dwFlags,
      [out] LPCPINFOEXW lpCPInfoEx);

    https://learn.microsoft.com/en-us/windows/win32/api/winnls/ns-winnls-cpinfoexw

    lpCPInfoEx's structure:
      typedef struct _cpinfoexW {
        UINT  MaxCharSize;                    [  4 bytes]
        BYTE  DefaultChar[MAX_DEFAULTCHAR];   [  1 byte ]
        BYTE  LeadByte[MAX_LEADBYTES];        [  1 byte ]
        WCHAR UnicodeDefaultChar;             [  2 bytes]
        UINT  CodePage;                       [  4 bytes]
        WCHAR CodePageName[MAX_PATH];         [520 bytes]   //  Total 532 bytes.
      } CPINFOEXW, *LPCPINFOEXW;

    lpCPInfoEx's constants:
      MAX_DEFAULTCHAR is   2.
      MAX_LEADBYTES   is  12: 5 ranges of 2 bytes each, 0 terminated.
      MAX_PATH        is 260.

    Type:
      WCHAR           is a 16-bits UTF-16LE code unit.
                      It can be a character or half a character.
                      Half because a UTF-16LE surrogate pair requires 2 WCHARs.
  */
  integer proc GetCPInfoExW(
    integer code_page,    //  [in]  UINT
    integer dwFlags,      //  [in]  DWORD
    integer lpCPInfoExW   //  [out] LPCPINFOEXW
    )


  /*
    https://learn.microsoft.com/en-us/windows/win32/api/errhandlingapi/nf-errhandlingapi-getlasterror

    _Post_equals_last_error_ DWORD GetLastError();
  */
  integer proc GetLastError()


end



dll "<KernelBase.dll>"
  /*
    https://learn.microsoft.com/en-us/windows/win32/api/pathcch/nf-pathcch-pathcchstriptoroot

    The Windows function PathCchStripToRoot() reduces a path to its root.

    CAVEAT!
      Unlike what the documentation states, cchPath must be the size of the
      input string instead of the size of the input buffer.

    The size is in characters and must include the terminating NULL character.

    The function only works for absolute paths.
    For relative and unknown paths it returns an empty string.

    This also works for paths starting with the roots:
      \\<servername>\<sharename>
      \\?\<driveletter>:
      \\?\UMC\<servername>\<sharename>
      \\.\<devicename>

    Note in these examples where it does (not) return a trailing slash:
      \                                    ->   \
      \Users\me                            ->   \
      C:                                   ->   C:
      C:\                                  ->   C:\
      C:\Users\Me                          ->   C:\
      \\wsl$\Debian\home\me                ->   \\wsl$\Debian
      \\?\UNC\servername\sharename\home\me ->   \\?\UNC\servername\sharename
      \\.\devicename\home\me               ->   \\.\devicename

    WINPATHCCHAPI HRESULT PathCchStripToRoot(
      [in, out] PWSTR  pszPath,
      [in]      size_t cchPath);
  */
  integer proc PathCchStripToRoot(
    integer pszPath,
    integer cchPath)
end



dll "<Kernel32.dll>"
  integer proc CreateFileMappingA(integer fileI, integer securityI, integer protectionI, integer highI, integer lowI, integer nameI)
  integer proc MapViewOfFile(integer mappingI, integer accessI, integer highI, integer lowI, integer sizeI)
  integer proc UnmapViewOfFile(integer addressI)
  integer proc InterlockedCompareExchange(integer addressI, integer exchangeI, integer compareI)
  integer proc InterlockedExchange(integer addressI, integer valueI)
  integer proc GetCurrentProcessId()
  proc Sleep(integer millisecondsI)
  integer proc GetPrivateProfileIntA(integer sectionI, integer keyI, integer defaultI, integer pathI)
  integer proc CreateFileW(integer pathI, integer accessI, integer shareI, integer securityI, integer dispositionI, integer flagsI, integer templateI)
  integer proc ReplaceFileW(integer originalI, integer stageI, integer backupI, integer flagsI, integer excludeI, integer reservedI)
  integer proc GetTickCount()
  integer proc CreateFileA(integer pathI, integer accessI, integer shareI,
                           integer securityI, integer dispositionI, integer flagsI, integer templateI)
  integer proc WriteFile(integer handleI, integer dataI, integer countI,
                         integer writtenI, integer overlappedI)
  integer proc ReadFile(integer handleI, integer dataI, integer countI, integer readI, integer overlappedI)
  integer proc CloseHandle(integer handleI)
  integer proc SetLastError(integer errorI)
  integer proc GetLocalTime(integer timeAddressI)
  integer proc VirtualAlloc(integer addressI, integer sizeI, integer typeI, integer protectI)
  integer proc VirtualFree(integer addressI, integer sizeI, integer typeI)
  integer proc GetPrivateProfileStringA(integer sectionI, integer keyI, integer defaultI,
                                         integer resultI, integer sizeI, integer pathI)
end

dll "<User32.dll>"
  integer proc PostMessageA(integer hwndI, integer msgI, integer wpI, integer lpI)
  integer proc GetWindowThreadProcessId(integer hwndI, integer pidAddressI)
  integer proc SetForegroundWindow(integer hwndI)
  integer proc AllowSetForegroundWindow(integer pidI)
  integer proc IsIconic(integer hwndI)
  integer proc ShowWindow(integer hwndI, integer showI)
end

integer ueRetryIntervalGI = 100
integer ueBusyTimeoutGI = 10000
integer ueAckTimeoutGI = 10000
integer ueAssocHeadGI = 0
integer ueDeduplicateGB = TRUE
integer ueSaveBackGB = TRUE
integer ueBackupGB = FALSE
integer ueSavingGB = FALSE
integer ueNoneditSenderGI = 0
integer ueMappingGI = 0
integer ueMailboxGI = 0
integer ueMasterGB = FALSE
integer ueCloseGB = FALSE
integer ueLoggingGB = TRUE
string ueLogPathGS[MAXSTRINGLEN] = ''

//  End of Windows APIs.





//  Start of include of get_last_error_name.inc  ...


#define NO_ERROR                          0
#define ERROR_INVALID_FUNCTION            1
#define ERROR_FILE_NOT_FOUND              2
#define ERROR_PATH_NOT_FOUND              3
#define ERROR_TOO_MANY_OPEN_FILES         4
#define ERROR_ACCESS_DENIED               5
#define ERROR_INVALID_HANDLE              6
#define ERROR_ARENA_TRASHED               7
#define ERROR_NOT_ENOUGH_MEMORY           8
#define ERROR_INVALID_BLOCK               9
#define ERROR_BAD_ENVIRONMENT            10
#define ERROR_BAD_FORMAT                 11
#define ERROR_INVALID_ACCESS             12
#define ERROR_INVALID_DATA               13
#define ERROR_INVALID_DRIVE              15
#define ERROR_CURRENT_DIRECTORY          16
#define ERROR_NOT_SAME_DEVICE            17
#define ERROR_NO_MORE_FILES              18
#define ERROR_WRITE_PROTECT              19
#define ERROR_BAD_UNIT                   20
#define ERROR_NOT_READY                  21
#define ERROR_BAD_COMMAND                22
#define ERROR_CRC                        23
#define ERROR_BAD_LENGTH                 24
#define ERROR_SEEK                       25
#define ERROR_NOT_DOS_DISK               26
#define ERROR_SECTOR_NOT_FOUND           27
#define ERROR_OUT_OF_PAPER               28
#define ERROR_WRITE_FAULT                29
#define ERROR_READ_FAULT                 30
#define ERROR_GEN_FAILURE                31
#define ERROR_SHARING_VIOLATION          32
#define ERROR_LOCK_VIOLATION             33
#define ERROR_WRONG_DISK                 34
#define ERROR_FCB_UNAVAILABLE            35
#define ERROR_SHARING_BUFFER_EXCEEDED    36
#define ERROR_NOT_SUPPORTED              50
#define ERROR_FILE_EXISTS                80
#define ERROR_DUP_FCB                    81
#define ERROR_CANNOT_MAKE                82
#define ERROR_FAIL_I24                   83
#define ERROR_OUT_OF_STRUCTURES          84
#define ERROR_ALREADY_ASSIGNED           85
#define ERROR_INVALID_PASSWORD           86
#define ERROR_INVALID_PARAMETER          87
#define ERROR_NET_WRITE_FAULT            88
#define ERROR_NO_PROC_SLOTS              89
#define ERROR_NOT_FROZEN                 90
#define ERROR_NO_ITEMS                   93
#define ERROR_INTERRUPT                  95
#define ERROR_TOO_MANY_SEMAPHORES       100
#define ERROR_EXCL_SEM_ALREADY_OWNED    101
#define ERROR_SEM_IS_SET                102
#define ERROR_TOO_MANY_SEM_REQUESTS     103
#define ERROR_INVALID_AT_INTERRUPT_TIME 104
#define ERROR_SEM_OWNER_DIED            105
#define ERROR_SEM_USER_LIMIT            106
#define ERROR_DISK_CHANGE               107
#define ERROR_DRIVE_LOCKED              108
#define ERROR_BROKEN_PIPE               109
#define ERROR_OPEN_FAILED               110
#define ERROR_BUFFER_OVERFLOW           111
#define ERROR_DISK_FULL                 112
#define ERROR_NO_MORE_SEARCH_HANDLES    113
#define ERROR_INVALID_TARGET_HANDLE     114
#define ERROR_PROTECTION_VIOLATION      115
#define ERROR_VIOKBD_REQUEST            116
#define ERROR_INVALID_CATEGORY          117
#define ERROR_INVALID_VERIFY_SWITCH     118
#define ERROR_BAD_DRIVER_LEVEL          119
#define ERROR_CALL_NOT_IMPLEMENTED      120
#define ERROR_SEM_TIMEOUT               121
#define ERROR_INSUFFICIENT_BUFFER       122
#define ERROR_INVALID_NAME              123
#define ERROR_INVALID_LEVEL             124
#define ERROR_NO_VOLUME_LABEL           125
#define ERROR_MOD_NOT_FOUND             126
#define ERROR_PROC_NOT_FOUND            127
#define ERROR_WAIT_NO_CHILDREN          128
#define ERROR_CHILD_NOT_COMPLETE        129
#define ERROR_DIRECT_ACCESS_HANDLE      130
#define ERROR_NEGATIVE_SEEK             131
#define ERROR_SEEK_ON_DEVICE            132
#define ERROR_IS_JOIN_TARGET            133
#define ERROR_IS_JOINED                 134
#define ERROR_IS_SUBSTED                135
#define ERROR_NOT_JOINED                136
#define ERROR_NOT_SUBSTED               137
#define ERROR_JOIN_TO_JOIN              138
#define ERROR_SUBST_TO_SUBST            139
#define ERROR_JOIN_TO_SUBST             140
#define ERROR_SUBST_TO_JOIN             141
#define ERROR_BUSY_DRIVE                142
#define ERROR_SAME_DRIVE                143
#define ERROR_DIR_NOT_ROOT              144
#define ERROR_DIR_NOT_EMPTY             145
#define ERROR_IS_SUBST_PATH             146
#define ERROR_IS_JOIN_PATH              147
#define ERROR_PATH_BUSY                 148
#define ERROR_IS_SUBST_TARGET           149
#define ERROR_SYSTEM_TRACE              150
#define ERROR_INVALID_EVENT_COUNT       151
#define ERROR_TOO_MANY_MUXWAITERS       152
#define ERROR_INVALID_LIST_FORMAT       153
#define ERROR_LABEL_TOO_LONG            154
#define ERROR_TOO_MANY_TCBS             155
#define ERROR_SIGNAL_REFUSED            156
#define ERROR_DISCARDED                 157
#define ERROR_NOT_LOCKED                158
#define ERROR_BAD_THREADID_ADDR         159
#define ERROR_BAD_ARGUMENTS             160
#define ERROR_BAD_PATHNAME              161
#define ERROR_SIGNAL_PENDING            162
#define ERROR_UNCERTAIN_MEDIA           163
#define ERROR_MAX_THRDS_REACHED         164
#define ERROR_MONITORS_NOT_SUPPORTED    165
#define ERROR_INVALID_SEGMENT_NUMBER    180
#define ERROR_INVALID_CALLGATE          181
#define ERROR_INVALID_ORDINAL           182
#define ERROR_ALREADY_EXISTS            183
#define ERROR_NO_CHILD_PROCESS          184
#define ERROR_CHILD_ALIVE_NOWAIT        185
#define ERROR_INVALID_FLAG_NUMBER       186
#define ERROR_SEM_NOT_FOUND             187
#define ERROR_INVALID_STARTING_CODESEG  188
#define ERROR_INVALID_STACKSEG          189
#define ERROR_INVALID_MODULETYPE        190
#define ERROR_INVALID_EXE_SIGNATURE     191
#define ERROR_EXE_MARKED_INVALID        192
#define ERROR_BAD_EXE_FORMAT            193
#define ERROR_ITERATED_DATA_EXCEEDS_64k 194
#define ERROR_INVALID_MINALLOCSIZE      195
#define ERROR_DYNLINK_FROM_INVALID_RING 196
#define ERROR_IOPL_NOT_ENABLED          197
#define ERROR_INVALID_SEGDPL            198
#define ERROR_AUTODATASEG_EXCEEDS_64k   199
#define ERROR_RING2SEG_MUST_BE_MOVABLE  200
#define ERROR_RELOC_CHAIN_XEEDS_SEGLIM  201
#define ERROR_INFLOOP_IN_RELOC_CHAIN    202
#define ERROR_ENVVAR_NOT_FOUND          203
#define ERROR_NOT_CURRENT_CTRY          204
#define ERROR_NO_SIGNAL_SENT            205
#define ERROR_FILENAME_EXCED_RANGE      206
#define ERROR_RING2_STACK_IN_USE        207
#define ERROR_META_EXPANSION_TOO_LONG   208
#define ERROR_INVALID_SIGNAL_NUMBER     209
#define ERROR_THREAD_1_INACTIVE         210
#define ERROR_INFO_NOT_AVAIL            211
#define ERROR_LOCKED                    212
#define ERROR_BAD_DYNALINK              213
#define ERROR_TOO_MANY_MODULES          214
#define ERROR_NESTING_NOT_ALLOWED       215
#define ERROR_INVALID_TOKEN             315
#define ERROR_USER_DEFINED_BASE      0xF000


integer get_last_error_id = 0

string proc get_last_error()
  string  error_name [MAXSTRINGLEN] = ''
  integer error_number              = GetLastError()
  integer org_id                    = GetBufferId()

  if get_last_error_id
    GotoBufferId(get_last_error_id)
  else
    get_last_error_id = CreateTempBuffer()
    ChangeCurrFilename(SplitPath(CurrMacroFilename(), _NAME_)
                       + ':get_last_error',
                       _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
    LoadBuffer(SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_|_NAME_) + '.s')
  endif

  if error_number
    if lFind('^ @\#define #{ERROR_[0-9A-Za-z_]#} #' + Str(error_number) + ' @$', 'gx')
      error_name = GetFoundText(1)
    endif
  else
    error_name = 'NO_ERROR'
  endif

  GotoBufferId(org_id)
  return(Trim(Format(error_number; error_name)))
end get_last_error


//  End of include of get_last_error_name.inc.





//  Start of include of MemBlock.inc ...

/*
#if MEMBLOCK_USES_GLOBAL_ALLOC
  #ifexist ['MemBlock_using_GlobalAlloc.inc']
    #Include ['MemBlock_using_GlobalAlloc.inc']
  #endif
#else
  #ifexist ['MemBlock_using_TSE_lines.inc']
    #Include ['MemBlock_using_TSE_lines.inc']
  #endif
#endif
*/


/*
  Include file    MemBlock_using_GlobalAlloc.inc
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   Windows TSE
  Version         v0.0.0.4   STILL IN DEVELOPMENT   11 Nov 2026


  MemBlock is a reference implementation for creating memory blocks in Windows
  TSE. Memory blocks are typically used to communicate with Windows APIs.

  MemBlock lets you create a container and memory blocks in that container.
  You can explicitly delete a memory block, and should do so if you create them
  in a loop, in order to not unnecessarily use up TSE's memory.
  Deleting a container deletes all its memory blocks.

  MemBlock can be used as an include file, but my advise is to copy it whole
  into each parent macro, because that saves all of us from having to deal with
  file version dependencies.


  WARNING
    It is your own responsibility to limit your macro to a memory block's size.
    Nothing protects your macro from reading and writing outside a memory block.


  INTERFACE

    integer proc memblock_create_container(var integer container_id)

      Create a container that will hold memory blocks.

      container_id     returns the id of the created container upon success.
      Its return value indicates the function's success as TRUE or FALSE.

      Typically one container is all you need.

    integer proc memblock_create_block(    integer container_id,
                                       var integer block_address,
                                           integer block_size)

      Create a memory block in a container.

      container_id     inputs in which container to create the memory block.
      block_address    returns the address of the newly created memory block.
      block_size       inputs the requested size of the memory block.
      Its return value indicates the function's success as TRUE or FALSE.

      A macro can only create memory blocks in a container that the macro
      created itself.

    integer proc memblock_delete_block(integer container_id,
                                       integer block_address)

      Delete a memory block by providing its address.

      container_id     inputs from which container to delete the memory block.
      block_address    inputs which block to delete.
      Its return value indicates the function's success as TRUE or FALSE.

      Deleting a memory block frees up the memory it used.

    integer proc memblock_delete_container(integer container_id)

      Delete a container.

      container_id     inputs which container to delete.
      Its return value indicates the function's success as TRUE or FALSE.

      Deleting a container deletes all its remaining memory blocks.


    All these functions react to TSE's MsgLevel variable.

    The purpose of a container is the ability to delete all its remaining
    memory blocks all at once.
    It is up to the programmer to decide which memory blocks need to be deleted
    as soon as possible and which ones can wait.
    Sometimes it is safer or best practice to delete a memory block a.s.a.p.
    Sometimes better performance can be achieved by reusing memory blocks.


  LIMITATIONS

    TSE's total memory  : ~3.9 GB.
    Memory block        : ~3.9 GB.       (*)
    Blocks per container: 2,147,483,647. (MAXINT)
    Containers          : 2,147,483,647. (MAXINT)

    (*)
      The memory block's stated size limit is very theoretical,
      because it shares that limited memory with the rest of TSE.


*/


dll "<Kernel32.dll>"
  /*
    https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-globalalloc

    ECLSPEC_ALLOCATOR HGLOBAL GlobalAlloc(
      [in] UINT   uFlags,
      [in] SIZE_T dwBytes);
  */
  integer proc GlobalAlloc(
    integer uFlags,
    integer dwBytes)

  /*
    https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-globalfree

    HGLOBAL GlobalFree(
      [in] _Frees_ptr_opt_ HGLOBAL hMem);
  */
  integer proc GlobalFree(
    integer hMem)

end


integer proc memblock_create_container(var integer container_id)
  integer ok     = FALSE
  integer org_id = GetBufferId()

  container_id = CreateTempBuffer()
  ChangeCurrFilename(Format(SplitPath(CurrMacroFilename(), _NAME_),
                            ':MemBlockContainer:',
                            container_id),
                     _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
  GotoBufferId(org_id)
  if container_id
    ok = TRUE
  endif
  return(ok)
end memblock_create_container


integer proc memblock_check_container_id(integer container_id)
  integer ok = FALSE

  ok = GetBufferId(Format(SplitPath(CurrMacroFilename(), _NAME_),
                          ':MemBlockContainer:',
                          container_id))
  if not ok
    if Query(MsgLevel) <> _NONE_
      Warn(SplitPath(CurrMacroFilename(), _NAME_);
           'error caused by incorrect call to MemBlock:', Chr(13),
           'The provided container_id does not exist or does not belong to this macro.')
    endif
  endif

  return(ok)
end memblock_check_container_id


integer proc memblock_create_block(    integer container_id,
                                   var integer block_address,
                                       integer block_size)
  integer ok               = FALSE
  integer org_id           = GetBufferId()

  if memblock_check_container_id(container_id)
    block_address = GlobalAlloc(0, block_size)
    if block_address
      GotoBufferId(container_id)
      EndFile()
      AddLine(Str(block_address))
      GotoBufferId(org_id)
      ok = TRUE
    else
      if Query(MsgLevel) <> _NONE_
        Warn('Error from'; SplitPath(CurrMacroFilename(), _NAME_);
             'calling memblock_create_block():', Chr(13),
             'Windows failed to create a memory block.')
      endif
    endif
  endif

  return(ok)
end memblock_create_block


integer proc memblock_delete_block(integer container_id,
                                   integer block_address)
  integer ok     = FALSE
  integer org_id = GetBufferId()

  if memblock_check_container_id(container_id)
    if block_address
      GotoBufferId(container_id)
      if lFind(Str(block_address), '^g$')
        KillLine()

        if GlobalFree(block_address)
          if Query(MsgLevel) <> _NONE_
            Warn('Error from'; SplitPath(CurrMacroFilename(), _NAME_);
                 'calling memblock_delete_block():', Chr(13),
                 'Windows failed to delete a memory block at the provided block address.')
          endif
        else
          ok = TRUE
        endif
      else
        if Query(MsgLevel) <> _NONE_
          Warn('Error from'; SplitPath(CurrMacroFilename(), _NAME_);
               'calling memblock_delete_block():', Chr(13),
                'Memblock does not know the provided block address.')
        endif
      endif

      GotoBufferId(org_id)
    else
      if Query(MsgLevel) <> _NONE_
        Warn(SplitPath(CurrMacroFilename(), _NAME_);
             'error caused by incorrect call to memblock_delete_block:', Chr(13),
             'The provided memory address is NULL.')
      endif
    endif
  endif

  return(ok)
end memblock_delete_block


integer proc memblock_delete_container(integer container_id)
  integer ok     = TRUE
  integer org_id = GetBufferId()
  integer tmp_id = 0

  if memblock_check_container_id(container_id)
    GotoBufferId(container_id)
    if NumLines()
      PushBlock()
      MarkLine(1, NumLines())
      tmp_id = CreateTempBuffer()
      CopyBlock()
      BegFile()
      repeat
        if Val(GetText(1, 10))
          if not memblock_delete_block(container_id, Val(GetText(1, 10)))
            ok = FALSE
          endif
        endif
      until not Down()
      GotoBufferId(org_id)
      AbandonFile(tmp_id)
      PopBlock()
    else
      GotoBufferId(org_id)
    endif
    if not AbandonFile(container_id)
      ok = FALSE
    endif
  else
    ok = FALSE
  endif

  //  Avoid compiler note.
  if FALSE
    memblock_delete_block(0, 0)
  endif

  return(ok)
end memblock_delete_container





//  End of include of MemBlock.inc.





proc warn_windows_error(string api_name)
  Warn(MACRO_NAME, ':', Chr(13),
       api_name; 'returned error';
       get_last_error(), '.')
end warn_windows_error


integer proc change_curr_filename(string s)
  integer old_FileChanged = 0
  integer old_HookState   = 0
  integer result          = FALSE

  old_HookState   = SetHookState(FALSE, _ON_CHANGING_FILES_)
  old_FileChanged = FileChanged()
  result = ChangeCurrFilename(s, _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
  FileChanged(old_FileChanged)
  SetHookState(old_HookState, _ON_CHANGING_FILES_)
  return(result)
end change_curr_filename


proc init_string_w(integer address, integer size)
  integer i = 0

  for i = 0 to size - 2 by 2
    PokeWord(AdjPtr(address, i), NULL)
  endfor
end init_string_w


proc astring_to_amem(string s, integer address)
  integer i = 0

  for i = 1 to Length(s)
    PokeByte(AdjPtr(address, i - 1), Asc(s[i]))
  endfor

  PokeByte(AdjPtr(address, Length(s)), NULL)
end astring_to_amem


// Diagnostic logging uses independent native memory, not TSE file buffers.
proc ue_log_init()
  integer memI = 0
  integer countI = 0
  string baseS[MAXSTRINGLEN] = SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_|_NAME_)
  ueLogPathGS = baseS + '.log'
  memI = VirtualAlloc(0, 4096, 0x3000, 4)
  if memI
    astring_to_amem('UniExplorer', memI)
    astring_to_amem('logging', AdjPtr(memI, 32))
    astring_to_amem('true', AdjPtr(memI, 64))
    astring_to_amem(baseS + '.ini', AdjPtr(memI, 128))
    countI = GetPrivateProfileStringA(memI, AdjPtr(memI, 32), AdjPtr(memI, 64),
                                     AdjPtr(memI, 512), 32, AdjPtr(memI, 128))
    if countI
      // false, no, or 0 disables logging; default is true.
      case PeekByte(AdjPtr(memI, 512))
        when 48, 70, 78, 102, 110
          ueLoggingGB = FALSE
      endcase
    endif
    astring_to_amem('deduplicate', AdjPtr(memI, 32))
    ueDeduplicateGB = GetPrivateProfileIntA(memI, AdjPtr(memI, 32), 1, AdjPtr(memI, 128)) <> 0
    astring_to_amem('Save', memI)
    astring_to_amem('saveback', AdjPtr(memI, 32))
    ueSaveBackGB = GetPrivateProfileIntA(memI, AdjPtr(memI, 32), 1, AdjPtr(memI, 128)) <> 0
    astring_to_amem('backup', AdjPtr(memI, 32))
    ueBackupGB = GetPrivateProfileIntA(memI, AdjPtr(memI, 32), 0, AdjPtr(memI, 128)) <> 0
    astring_to_amem('Mailbox', memI)
    astring_to_amem('retryintervalms', AdjPtr(memI, 32))
    ueRetryIntervalGI = GetPrivateProfileIntA(memI, AdjPtr(memI, 32), 100, AdjPtr(memI, 128))
    astring_to_amem('busytimeoutms', AdjPtr(memI, 32))
    ueBusyTimeoutGI = GetPrivateProfileIntA(memI, AdjPtr(memI, 32), 10000, AdjPtr(memI, 128))
    astring_to_amem('acktimeoutms', AdjPtr(memI, 32))
    ueAckTimeoutGI = GetPrivateProfileIntA(memI, AdjPtr(memI, 32), 10000, AdjPtr(memI, 128))
    VirtualFree(memI, 0, 0x8000)
  endif
  // Bound invalid settings, including negative values and zero.
  if ueRetryIntervalGI < 10 or ueRetryIntervalGI > 1000
    ueRetryIntervalGI = 100
  endif
  if ueBusyTimeoutGI < 1000 or ueBusyTimeoutGI > 60000
    ueBusyTimeoutGI = 10000
  endif
  if ueAckTimeoutGI < 1000 or ueAckTimeoutGI > 60000
    ueAckTimeoutGI = 10000
  endif
end ue_log_init

proc ue_log_level(string levelS, string messageS)
  integer memI = 0
  integer handleI = 0
  integer resultI = 0
  string stampS[32] = ''
  if ueLoggingGB and ueLogPathGS <> ''
    memI = VirtualAlloc(0, 4096, 0x3000, 4)
    if memI
      astring_to_amem(ueLogPathGS, memI)
      // FILE_APPEND_DATA, share read/write, OPEN_ALWAYS, normal attributes.
      handleI = CreateFileA(memI, 4, 3, 0, 4, 128, 0)
      if handleI <> -1
        GetLocalTime(AdjPtr(memI, 768))
        stampS = Format(PeekWord(AdjPtr(memI, 768)):4:'0', '-',
                        PeekWord(AdjPtr(memI, 770)):2:'0', '-',
                        PeekWord(AdjPtr(memI, 774)):2:'0', ' ',
                        PeekWord(AdjPtr(memI, 776)):2:'0', ':',
                        PeekWord(AdjPtr(memI, 778)):2:'0', ':',
                        PeekWord(AdjPtr(memI, 780)):2:'0', ' ', levelS, ' ')
        // Append a complete record in one WriteFile call.
        astring_to_amem(stampS, AdjPtr(memI, 1024))
        astring_to_amem(messageS, AdjPtr(memI, 1024 + Length(stampS)))
        astring_to_amem(Chr(13) + Chr(10), AdjPtr(memI, 1024 + Length(stampS) + Length(messageS)))
        resultI = WriteFile(handleI, AdjPtr(memI, 1024), Length(stampS) + Length(messageS) + 2, AdjPtr(memI, 800), 0)
        resultI = CloseHandle(handleI)
      endif
      VirtualFree(memI, 0, 0x8000)
    endif
  endif
end ue_log_level

proc ue_log(string messageS)
  ue_log_level('INFO', messageS)
end ue_log

// Preserve every UTF-16 code unit in bounded chunks (including surrogate pairs).
proc ue_log_wide(string labelS, integer addressI, integer limitI)
  integer offsetI = 0
  integer unitI = 0
  string chunkS[200] = ''
  if ueLoggingGB and addressI
    for offsetI = 0 to limitI - 2 by 2
      unitI = PeekWord(AdjPtr(addressI, offsetI))
      if not unitI
        break
      endif
      if unitI >= 32 and unitI <= 126 and unitI <> 92
        chunkS = chunkS + Chr(unitI)
      else
        chunkS = Format(chunkS, Chr(92), 'u', unitI:4:'0':16)
      endif
      if Length(chunkS) >= 160
        ue_log(labelS + ': ' + chunkS)
        chunkS = ''
      endif
    endfor
    if chunkS <> ''
      ue_log(labelS + ': ' + chunkS)
    endif
    ue_log(Format(labelS; 'UTF-16 units='; offsetI / 2))
  endif
end ue_log_wide

string proc amem_to_ansi(integer address)
  integer c                = 0
  integer i                = 0
  string  s [MAXSTRINGLEN] = ''

  for i = 0 to MAXSTRINGLEN - 1
    c = PeekByte(AdjPtr(address, i))
    if c
      s = s + Chr(c)
    else
      NoOp()
      break
    endif
  endfor

  return(s)
end amem_to_ansi


/*
  This proc is not just used for debugging,
  but also for when the wide string is known to be ANSI-compatible.
*/
string proc wmem_to_ascii(integer address)
  integer c                = 0
  integer i                = 0
  string  s [MAXSTRINGLEN] = ''

  for i = 0 to MAX_LONG_PATH_W - 2 by 2
    c = PeekWord(AdjPtr(address, i))
    case c
      when 32 .. 126
        s = s + Chr(c)
      when 0
        NoOp()
        break
      when 1 .. 31, 127
        s = Format(s, '%', c:2:'0':16)
      otherwise
        //  The byte-order remains UTF-16LE's byte-order.
        s = Format(s, '%', (c mod 256):2:'0':16, '%', (c / 256):2:'0':16)
    endcase
  endfor

  return(s)
end wmem_to_ascii


/*
  This proc is for debugging only.
*/
string proc ansi_to_ascii(string s)
  integer i                = 0
  string  r [MAXSTRINGLEN] = ''

  for i = 1 to Length(s)
    if Asc(s[i]) in 32 .. 126
      r = r + s[i]
    else
      r = Format(r, '%', Asc(s[i]):2:'0':16)
    endif
  endfor

  return(r)
end ansi_to_ascii

//  xx  Recheck for infinite loop

integer proc get_1st_param_from_cmdline_w(integer cmdline_address,
                                          integer filename_address)
  integer c                 = 0
  integer i                 = 0
  integer j                 = 0
  integer num_chars         = 0
  integer num_double_quotes = 0

  //  TSE's executable's path and a 1st parameter are both double-quoted.
  //  So we start by searching for the 3rd double-quote.
  for i = 0 to MAX_CMDLINE_LENGTH_W - 2 by 2
    c = PeekWord(AdjPtr(cmdline_address, i))
    if c
      if c == DOUBLE_QUOTE
        num_double_quotes = num_double_quotes + 1
        if num_double_quotes == 3
          NoOp()
          break
        endif
      endif
    else
      NoOp()
      break
    endif
  endfor

  if num_double_quotes == 3
    i = i + 2
    while i <= MAX_CMDLINE_LENGTH_W - 2
    and   j <= MAX_LONG_PATH_W      - 2 - 2  // Save room for NULL.
      c = PeekWord(AdjPtr(cmdline_address, i))
      if c
        if c == DOUBLE_QUOTE
          num_chars = j / 2
          break
        else
          PokeWord(AdjPtr(filename_address, j), c)
        endif
      else
        NoOp()
        break
      endif
      i = i + 2
      j = j + 2
    endwhile
  endif

  if num_chars
    PokeWord(AdjPtr(filename_address, j), NULL)
  endif

  return(num_chars)
end get_1st_param_from_cmdline_w


integer proc num_double_quotes_w(integer cmdline_address)
  integer i = 0
  integer r = 0

  for i = 0 to MAX_CMDLINE_LENGTH_W - 2 by 2
    case PeekWord(AdjPtr(cmdline_address, i))
      when DOUBLE_QUOTE
        r = r + 1
      when 0
        NoOp()
        break
    endcase
  endfor

  return(r)
end num_double_quotes_w


integer proc is_ascii_w(integer address)
  integer c = 0
  integer i = 0
  integer r = TRUE

  for i = 0 to MAX_LONG_PATH_W - 2 by 2
    c = PeekWord(AdjPtr(address, i))
    if c >= 128
      r = FALSE
      break
    elseif c == 0
      NoOp()
      break
    endif
  endfor

  return(r)
end is_ascii_w


proc get_token_w(integer string_address,
                 string  delimiter_string,
                 integer token_number,
                 integer token_address)
  integer c             = 0
  integer delimiter     = Asc(delimiter_string)
  integer i             = 0
  integer j             = 0
  integer token_counter = 0

  c = PeekWord(AdjPtr(string_address, 0))
  if c
    token_counter = 1
  endif

  for i = 0 to MAX_LONG_PATH_W - 2 by 2
    c = PeekWord(AdjPtr(string_address, i))
    if c
      if c == delimiter
        token_counter = token_counter + 1
        if token_counter > token_number
          NoOp()
          break
        endif
      elseif token_counter == token_number
        PokeWord(AdjPtr(token_address, j), c)
        j = j + 2
      endif
    else
      NoOp()
      break
    endif
  endfor

  PokeWord(AdjPtr(token_address, j), NULL)
end get_token_w

/*
  The function requires that both strings are NULL-terminated.
*/
integer proc are_equal_strings_w(integer string_1_address,
                                 integer string_2_address)
  integer character_1 = 0
  integer character_2 = 0
  integer i           = 0
  integer equal       = FALSE

  for i = 0 to MAXLINELEN_W - 2 by 2
    character_1 = PeekWord(AdjPtr(string_1_address, i))
    character_2 = PeekWord(AdjPtr(string_2_address, i))
    if  character_1
    and character_1 == character_2
      NoOp()
    elseif character_1 == NULL
    and    character_2 == NULL
      equal = TRUE
      break
    else
      NoOp()
      break
    endif
  endfor

  return(equal)
end are_equal_strings_w


integer proc physical_length_w(integer address)
  integer result = 0

  while PeekWord(AdjPtr(address, result))
    result = result + 2
  endwhile

  result = result + 2
  return(result)
end physical_length_w


proc wmem_to_wmem(integer address_from, integer address_to)
  integer c = PeekWord(address_from)
  integer i = 0

  while c
    PokeWord(AdjPtr(address_to, i), c)
    i = i + 2
    c = PeekWord(AdjPtr(address_from, i))
  endwhile

  PokeWord(AdjPtr(address_to, i), NULL)
end wmem_to_wmem


proc add_part_to_path_w(integer part_address, integer path_address)
  integer i = 0
  integer j = 0

  while PeekWord(AdjPtr(path_address, i))
    i = i + 2
  endwhile

  PokeWord(AdjPtr(path_address, i), BACKSLASH)
  i = i + 2

  while PeekWord(AdjPtr(part_address, j))
    PokeWord(AdjPtr(path_address, i), PeekWord(AdjPtr(part_address, j)))
    i = i + 2
    j = j + 2
  endwhile

  PokeWord(AdjPtr(path_address, i), NULL)
end add_part_to_path_w



/*
  Windows' GetSHortPathA() and GetShortPathNameW() functions sometimes fail:
  - If the Windows code page is 936 (Simplified Chinese),
    then GetShortPathNameW() sometimes does not return an ASCII short name,
    but one with Chinese characters.
  - GetShortPathNameW() does not return a short name for most UNCs,
    but some UNCs can support it.
    For example, the "\\wsl$\Debian\" UNC does not support short paths.
  - Drive letters can refer to a physical drive or be mapped to an UNC.

  This proc get_short_path_name_w():
  - Does also returns an ASCII short name for code page 936.
  - Returns an ASCII short name if the drive or UNC supports it, or fails.

  get_short_path_name_w() mirrors GetShortPathNameW()'s functionality:
  - A relative input path is allowed, and returns a relative short path.
  - Its return value is the short name's number of characters,
    or zero on failure.
    On failure, if short_filename_address_w's address is not NULL then its value
    is assigned an empty string, meaning its first "character" is NULL.
  - If you pass NULL to max_result_chararcters_w,
    then the proc returns the number of required result characters.
    Here too, if short_filename_address_w's address is not NULL, then its value
    is assigned an empty string, meaning its first "character" is set to NULL.

*/
integer proc get_short_path_name_w(integer long_pathname_address_w,
                                   integer short_pathname_address_w,
                                   integer max_result_chararcters)
  integer dummy                    = max_result_chararcters
  integer find_data_address_w      = 0
  integer find_file_address_w      = 0
  integer handle                   = INVALID_HANDLE_VALUE
  integer l_short_filename_address = 0
  integer num_result_characters    = 0
  integer part_address             = 0
  integer part_char_offset         = 0
  integer part_end_offset          = 0
  integer part_start_offset        = 0
  integer path_char_offset         = 0
  integer root_length              = 0
  integer s_result                 = 0

  dummy = dummy   //  Pacify compiler.

  if  memblock_create_block(g_container_id, part_address            , MAX_LONG_PATH_W)
  and memblock_create_block(g_container_id, find_data_address_w     , FIND_DATA_SIZE_W)
  and memblock_create_block(g_container_id, find_file_address_w     , MAX_LONG_PATH_W)
  and memblock_create_block(g_container_id, l_short_filename_address, MAX_LONG_PATH_W)
    PokeWord(l_short_filename_address, NULL)

    //  Handle the root part separately because of its many forms and because
    //  it gets no short name.
    //  Note: In one case the determined root can be an empty string.
    wmem_to_wmem(long_pathname_address_w, part_address)
    s_result = PathCchStripToRoot(part_address, physical_length_w(part_address) / 2)
    case s_result
      when S_OK
        root_length = physical_length_w(part_address)
        if  root_length >= 4
        and PeekWord(AdjPtr(part_address, root_length - 4)) == BACKSLASH
          PokeWord(AdjPtr(part_address, root_length - 4), NULL)
        endif
      when S_FALSE
        //  xx  This is not a real error, but unfished programming.
        Warn('Error: PathCchStripToRoot(): The path is already just a root.')
      otherwise
        Warn('Error: PathCchStripToRoot() returned error ', s_result, '.')
    endcase
    wmem_to_wmem(part_address, l_short_filename_address)

    if FALSE
      Warn('After part_address -> l_short_filename_address:', Chr(13),
           'part_address = "', wmem_to_ascii(part_address), '".', Chr(13),
           'l_short_filename_address = "', wmem_to_ascii(l_short_filename_address), '".')
    endif

    //  Set the part_start_offset for the next path part.
    part_start_offset = physical_length_w(l_short_filename_address) - 2
    //  part_start_offset now points to BACKSLAH or NULL.
    if PeekWord(AdjPtr(long_pathname_address_w, part_start_offset)) == BACKSLASH
      part_start_offset = part_start_offset + 2
    endif

    //  After processing root part, now process directory parts and file part.
    while PeekWord(AdjPtr(long_pathname_address_w, part_start_offset)) <> NULL
      //  In the path find the end of the next part.
      part_end_offset = part_start_offset
      while not (PeekWord(AdjPtr(long_pathname_address_w, part_end_offset)) in BACKSLASH, NULL)
        part_end_offset = part_end_offset + 2
      endwhile

      //  Copy the part from the path to its own variable.
      part_char_offset = 0
      for path_char_offset = part_start_offset to part_end_offset - 2 by 2
        PokeWord(AdjPtr(part_address, part_char_offset),
                 PeekWord(AdjPtr(long_pathname_address_w, path_char_offset)))
        part_char_offset = part_char_offset + 2
      endfor
      PokeWord(AdjPtr(part_address, part_char_offset), NULL)

      //  Assign preliminary short path plus new part to the find path
      wmem_to_wmem(l_short_filename_address, find_file_address_w)
      add_part_to_path_w(part_address, find_file_address_w)

      handle = FindFirstFileW(find_file_address_w, find_data_address_w)

      if handle == INVALID_HANDLE_VALUE
        add_part_to_path_w(part_address, l_short_filename_address)
      else
        if PeekWord(AdjPtr(find_data_address_w, FIND_DATA_W_SHORT_NAME_OFFSET))
          add_part_to_path_w(AdjPtr(find_data_address_w, FIND_DATA_W_SHORT_NAME_OFFSET),
                             l_short_filename_address)
        else
          add_part_to_path_w(part_address, l_short_filename_address)
        endif
        FindClose(handle)
      endif

      //  Set the offset for the next path part.
      part_start_offset = part_end_offset
      if PeekWord(AdjPtr(long_pathname_address_w, part_start_offset)) == BACKSLASH
        part_start_offset = part_start_offset + 2
      endif
    endwhile
  endif

  if short_pathname_address_w
    wmem_to_wmem(l_short_filename_address, short_pathname_address_w)
    //  Excluding NULL terminator:
    num_result_characters = Max(physical_length_w(l_short_filename_address) / 2 - 1, 0)
  else
    //  Including NULL terminator:
    num_result_characters = physical_length_w(l_short_filename_address) / 2
  endif

  memblock_delete_block(g_container_id, part_address)
  memblock_delete_block(g_container_id, find_data_address_w)
  memblock_delete_block(g_container_id, find_file_address_w)
  memblock_delete_block(g_container_id, l_short_filename_address)

  return(num_result_characters)
end get_short_path_name_w


string proc merge_long_and_short_names(integer long_filename_address,
                                       integer short_filename_address)
  integer convert_back                     = 0
  integer i                                = 0
  integer long_namepart_address            = 0
  integer num_tokens                       = 0
  integer short_namepart_address           = 0
  integer tmp_namepart_back_address        = 0
  integer tmp_namepart_there_address       = 0
  string  tse_ansi_filename [MAXSTRINGLEN] = ''
  integer used_default_char                = FALSE

  if FALSE
    Warn('During merge (0):', Chr(13),
         'Filename = "', wmem_to_ascii(long_filename_address), '".', Chr(13),
         'Short address = ', short_filename_address, '.', Chr(13),
         'Short filename = "', wmem_to_ascii(short_filename_address), '".')
  endif

  if  memblock_create_block(g_container_id, long_namepart_address     , MAX_NAME_W)
  and memblock_create_block(g_container_id, short_namepart_address    , MAX_NAME_W)
  and memblock_create_block(g_container_id, tmp_namepart_back_address , MAX_NAME_W)
  and memblock_create_block(g_container_id, tmp_namepart_there_address, MAX_NAME_W)
    //  xx  This is an imperfect shortcut that only works for drive letters!
    num_tokens = NumTokens(wmem_to_ascii(long_filename_address), '\')

    for i = 1 to num_tokens

      if FALSE
        Warn('During merge (', i, '):', Chr(13),
             'Filename = "', wmem_to_ascii(long_filename_address), '".', Chr(13),
             'Short filename = "', wmem_to_ascii(short_filename_address), '".')
      endif

      get_token_w(long_filename_address , '\', i, long_namepart_address )
      get_token_w(short_filename_address, '\', i, short_namepart_address)

      //  Feels superfluous, but I am desperate.
      init_string_w(tmp_namepart_there_address, MAX_NAME_W)

      if WideCharToMultiByte(
           TSE_CODE_PAGE,
           WC_COMPOSITECHECK | WC_NO_BEST_FIT_CHARS | WC_DEFAULTCHAR,
           long_namepart_address,
           USE_NULL_TERMINATED_STRINGS,
           tmp_namepart_there_address,
           MAX_NAME,
           NULL,
           used_default_char) > 0

        if used_default_char
          PokeWord(tmp_namepart_back_address, NULL)
          convert_back = FALSE
        else
          convert_back = TRUE
        endif
      else
        warn_windows_error('WideCharToMultiByte')
        tse_ansi_filename = ''
        KeyPressed()
        Delay(90)
        break
      endif

      if convert_back
        if not MultiByteToWideChar(
                  TSE_CODE_PAGE,
                  MB_PRECOMPOSED | MB_ERR_INVALID_CHARS,
                  tmp_namepart_there_address,
                  USE_NULL_TERMINATED_STRINGS,
                  tmp_namepart_back_address,
                  MAX_NAME_W)
          warn_windows_error('merge_long_and_short_names: MultiByteToWideChar')
          tse_ansi_filename = ''
          KeyPressed()
          Delay(90)
          break
        endif
      endif

      if FALSE
        if i == num_tokens
          Warn('TSE_CODE_PAGE = "', TSE_CODE_PAGE, '",', Chr(13),
               'long_namepart = "', wmem_to_ascii(long_namepart_address), '",', Chr(13),
               'tmp_namepart_there = "', ansi_to_ascii(amem_to_ansi(tmp_namepart_there_address)), '",', Chr(13),
               'tmp_namepart_back = "', wmem_to_ascii(tmp_namepart_back_address), '".')
        endif
      endif

      if tse_ansi_filename <> ''
        tse_ansi_filename = tse_ansi_filename + '\'
      endif

      if are_equal_strings_w(long_namepart_address, tmp_namepart_back_address)
        tse_ansi_filename = tse_ansi_filename + amem_to_ansi(tmp_namepart_there_address)
      else
        tse_ansi_filename = tse_ansi_filename + wmem_to_ascii(short_namepart_address)
      endif
    endfor
  else
    Warn(MACRO_NAME, ': merge_long_and_short_names: Failed to create a memory block.')
  endif

  memblock_delete_block(g_container_id, long_namepart_address)
  memblock_delete_block(g_container_id, short_namepart_address)
  memblock_delete_block(g_container_id, tmp_namepart_back_address)
  memblock_delete_block(g_container_id, tmp_namepart_there_address)

  return(tse_ansi_filename)
end merge_long_and_short_names


/*
  This proc is only called if the external code page is that of a multi-byte
  character set other than 65001 (UTF-8).
  For example code page 936 (Simplified Chinese).
  Under that condition TSE v4.50.27 upwards cannot save a file with non-ASCII
  characters in its name.
  Here we try to work around that specific situation by at _ON_FILE_SAVE_
  temporarily renaming the file to its short name, and _AFTER_FILE_SAVE_
  renaming it back.

  There was a problem:
  GetShortPathNameA() fails with Windows error ERROR_FILE_NOT_FOUND on a
  non-ASCII filename if the external code page is a multi-byte one.
  The work-around:
  - Change the ANSI long  filename to a  wide  long  filename.
  - Change the wide long  filename to a  wide  short filename.
  - Change the wide short filename to an ASCII short filename.
  Note: "Wide" is Windows-API-speak for UTF-16LE character encoding.
*/
proc on_file_save()
  string  ascii_short_path [MAXSTRINGLEN] = ''
  string  org_filename     [MAXSTRINGLEN] = CurrFilename()
  integer num_chars                       = 0

  if      GetBufferInt(MACRO_NAME + ':SaveUsingWorkAround')
  and not isWord(org_filename, ChrSet('\d001-\d127'))

    if not g_ansi_long_path_address
      if  memblock_create_block(g_container_id, g_ansi_long_path_address , MAX_LONG_PATH)
      and memblock_create_block(g_container_id, g_ansi_short_path_address, MAX_LONG_PATH)
      and memblock_create_block(g_container_id, g_wide_long_path_address , MAX_LONG_PATH_W)
      and memblock_create_block(g_container_id, g_wide_short_path_address, MAX_LONG_PATH_W)
        NoOp()
      else
        Warn(MACRO_NAME, ': on_file_save: Error creating memory blocks.')
        g_ansi_long_path_address = 0
      endif
    endif

    if g_ansi_long_path_address
      astring_to_amem(org_filename, g_ansi_long_path_address)
      if MultiByteToWideChar(
          TSE_CODE_PAGE,
          MB_PRECOMPOSED | MB_ERR_INVALID_CHARS,
          g_ansi_long_path_address,
          USE_NULL_TERMINATED_STRINGS,
          g_wide_long_path_address,
          MAX_LONG_PATH)
        if FALSE
          Warn('g_ansi_long_path = "', amem_to_ansi(g_ansi_long_path_address), '",', Chr(13),
               'g_wide_long_path = "', wmem_to_ascii(g_wide_long_path_address), '".')
        endif
        num_chars = get_short_path_name_w(g_wide_long_path_address,
                                          g_wide_short_path_address,
                                          MAX_LONG_PATH_W)
        if num_chars
          if FALSE
            Warn('g_wide_short_path_address = ', g_wide_short_path_address, '.')
            ascii_short_path = wmem_to_ascii(g_wide_short_path_address)
            Warn('ascii_short_path = "', ascii_short_path, '",', Chr(13),
                 'Length(ascii_short_path) ='; Length(ascii_short_path))
            // Warn('g_wide_long_path  = "', wmem_to_ascii(g_wide_long_path_address), '",', Chr(13),
            //     'g_wide_short_path = "', wmem_to_ascii(g_wide_short_path_address), '".')
          endif

          //  Short path always ASCII-compatible, so this shortcut works:
          ascii_short_path = wmem_to_ascii(g_wide_short_path_address)
          if change_curr_filename(ascii_short_path)
            SetBufferStr(MACRO_NAME + ':OriginalFilename', org_filename)
          endif
        else
          warn_windows_error('on_file_save: GetShortPathNameW')
        endif
      else
        warn_windows_error('on_file_save: MultiByteToWideChar')
      endif
    endif
  endif
end on_file_save


proc after_file_save()
  string org_filename [MAXSTRINGLEN] = ''

  if GetBufferInt(MACRO_NAME + ':SaveUsingWorkAround')
    org_filename = GetBufferStr(MACRO_NAME + ':OriginalFilename')
    if org_filename <> ''
      change_curr_filename(org_filename)
      DelBufferVar(MACRO_NAME + ':OriginalFilename')
    endif
  endif
end after_file_save


#if INTERNAL_VERSION < 12467
// Mailbox states: 0 free, 1 writing, 2 ready, 3 loading, 4 success,
// 5 failure, 6 sender timed out during load. State changes are atomic.
// A single bounded slot; simultaneous senders wait before falling back.

// Version 14: exact UTF-16 identity, not a lossy ANSI filename or a hash.
// Record layout: next pointer 0, byte count 4, ASCII temp path 8,
// UTF-16 original path 272. Sidecar is raw UTF-16LE including final NUL.
// Sidecars and comparison snapshots are retained; save-back is experimental.
#define UE_IDENTITY_MAX_BYTES 16384
#define UE_IDENTITY_OFFSET 272

integer proc ue_identity_size(integer addressI)
  integer offsetI = 0
  if addressI
    for offsetI = 0 to UE_IDENTITY_MAX_BYTES - 2 by 2
      if not PeekWord(AdjPtr(addressI, offsetI))
        return(offsetI + 2)
      endif
    endfor
  endif
  return(0)
end ue_identity_size

integer proc ue_write_identity(string pathS, integer sourceI)
  integer sizeI = ue_identity_size(sourceI)
  integer memI = 0
  integer handleI = -1
  integer resultI = FALSE
  integer closeI = 0
  if sizeI > 2 and Length(pathS) + 7 < MAXSTRINGLEN
    memI = VirtualAlloc(0, 4096, 0x3000, 4)
    if memI
      astring_to_amem(pathS + '.ueorig', memI)
      // CREATE_NEW: do not overwrite an existing association.
      handleI = CreateFileA(memI, 0x40000000, 0, 0, 1, 128, 0)
      if handleI <> -1
        if WriteFile(handleI, sourceI, sizeI, AdjPtr(memI, 1024), 0)
          resultI = PeekLong(AdjPtr(memI, 1024)) == sizeI
        endif
        closeI = CloseHandle(handleI)
      endif
      VirtualFree(memI, 0, 0x8000)
    endif
  endif
  if resultI
    ue_log('Original UTF-16 association: ' + pathS + '.ueorig')
  else
    ue_log_level('WARN', 'Could not persist original filename; content-only fallback')
  endif
  return(resultI)
end ue_write_identity

// Read only sidecars explicitly marked as Unicode by the sender.
integer proc ue_read_identity(string pathS, integer destI)
  integer memI = 0
  integer handleI = -1
  integer sizeI = 0
  integer closeI = 0
  if Length(pathS) + 7 < MAXSTRINGLEN
    memI = VirtualAlloc(0, 4096, 0x3000, 4)
    if memI
      astring_to_amem(pathS + '.ueorig', memI)
      handleI = CreateFileA(memI, 0x80000000, 1, 0, 3, 128, 0)
      if handleI <> -1
        if ReadFile(handleI, destI, UE_IDENTITY_MAX_BYTES, AdjPtr(memI, 1024), 0)
          sizeI = PeekLong(AdjPtr(memI, 1024))
          if sizeI <= 2 or sizeI mod 2 or sizeI >= UE_IDENTITY_MAX_BYTES
            sizeI = 0
          elseif ue_identity_size(destI) <> sizeI
            sizeI = 0
          endif
        endif
        closeI = CloseHandle(handleI)
      endif
      VirtualFree(memI, 0, 0x8000)
    endif
  endif
  return(sizeI)
end ue_read_identity

proc ue_assoc_add(string pathS, integer sourceI, integer sizeI)
  integer recordI = 0
  integer resultI = 0
  if sizeI > 2 and sizeI <= UE_IDENTITY_MAX_BYTES
    recordI = VirtualAlloc(0, UE_IDENTITY_OFFSET + sizeI, 0x3000, 4)
    if recordI
      resultI = InterlockedExchange(recordI, ueAssocHeadGI)
      resultI = InterlockedExchange(AdjPtr(recordI, 4), sizeI)
      astring_to_amem(pathS, AdjPtr(recordI, 8))
      wmem_to_wmem(sourceI, AdjPtr(recordI, UE_IDENTITY_OFFSET))
      ueAssocHeadGI = recordI
      ue_log('Registered original association for: ' + pathS)
    else
      ue_log_level('WARN', 'Association memory unavailable; sidecar retained')
    endif
  endif
end ue_assoc_add

integer proc ue_assoc_select(integer sourceI, integer sizeI)
  integer recordI = ueAssocHeadGI
  integer offsetI = 0
  integer sameB = FALSE
  integer bufferI = 0
  integer originalI = GetBufferId()
  string pathS[MAXSTRINGLEN] = ''
  while recordI
    if PeekLong(AdjPtr(recordI, 4)) == sizeI
      sameB = TRUE
      for offsetI = 0 to sizeI - 2 by 2
        if PeekWord(AdjPtr(sourceI, offsetI)) <> PeekWord(AdjPtr(recordI, UE_IDENTITY_OFFSET + offsetI))
          sameB = FALSE
          break
        endif
      endfor
      if sameB
        pathS = amem_to_ansi(AdjPtr(recordI, 8))
        bufferI = GetBufferId(pathS)
        if bufferI
          if EditThisFile(pathS, _DONT_PROMPT_) and GetBufferId() == bufferI and Lower(CurrFilename()) == Lower(pathS)
            ue_log('Duplicate original filename; selected existing buffer: ' + pathS)
            return(TRUE)
          endif
          GotoBufferId(originalI)
        endif
      endif
    endif
    recordI = PeekLong(recordI)
  endwhile
  return(FALSE)
end ue_assoc_select

// Convert a known ASCII temporary path to a NUL-terminated wide string.
proc ue_ascii_w(string pathS, integer destI)
  integer iI = 0
  for iI = 1 to Length(pathS)
    PokeWord(AdjPtr(destI, (iI - 1) * 2), Asc(pathS[iI]))
  endfor
  PokeWord(AdjPtr(destI, Length(pathS) * 2), 0)
end ue_ascii_w

// Append an ASCII suffix to a bounded wide pathname.
proc ue_suffix_w(integer sourceI, integer destI, string suffixS)
  integer sizeI = ue_identity_size(sourceI)
  wmem_to_wmem(sourceI, destI)
  ue_ascii_w(suffixS, AdjPtr(destI, sizeI - 2))
end ue_suffix_w

// Compare raw bytes in bounded chunks. Deny writes while reading. A missing
// or unreadable file, or any mismatch, is a conflict, never permission to save.
integer proc ue_equal_files(integer firstI, integer secondI)
  integer aI = -1
  integer bI = -1
  integer memI = 0
  integer countAI = 0
  integer countBI = 0
  integer offsetI = 0
  integer equalB = FALSE
  integer resultI = 0
  aI = CreateFileW(firstI, 0x80000000, 1, 0, 3, 128, 0)
  if aI <> -1
    bI = CreateFileW(secondI, 0x80000000, 1, 0, 3, 128, 0)
    if bI <> -1
      memI = VirtualAlloc(0, 131088, 0x3000, 4)
      if memI
        repeat
          if not ReadFile(aI, memI, 65536, AdjPtr(memI, 131072), 0)
            break
          endif
          if not ReadFile(bI, AdjPtr(memI, 65536), 65536, AdjPtr(memI, 131076), 0)
            break
          endif
          countAI = PeekLong(AdjPtr(memI, 131072))
          countBI = PeekLong(AdjPtr(memI, 131076))
          if countAI <> countBI
            break
          endif
          if not countAI
            equalB = TRUE
            break
          endif
          offsetI = 0
          while offsetI + 4 <= countAI
            if PeekLong(AdjPtr(memI, offsetI)) <> PeekLong(AdjPtr(memI, 65536 + offsetI))
              break
            endif
            offsetI = offsetI + 4
          endwhile
          // A mismatch in a complete word must not be skipped.
          if offsetI + 4 <= countAI
            break
          endif
          while offsetI < countAI
            if PeekByte(AdjPtr(memI, offsetI)) <> PeekByte(AdjPtr(memI, 65536 + offsetI))
              break
            endif
            offsetI = offsetI + 1
          endwhile
          if offsetI <> countAI
            break
          endif
        until FALSE
        VirtualFree(memI, 0, 0x8000)
      endif
      resultI = CloseHandle(bI)
    endif
    resultI = CloseHandle(aI)
  endif
  return(equalB)
end ue_equal_files

// Private comparison snapshot; not a user backup. Created before editing.
proc ue_create_baseline(string pathS)
  integer memI = 0
  if ueSaveBackGB and Length(pathS) + 7 < MAXSTRINGLEN
    memI = VirtualAlloc(0, 4096, 0x3000, 4)
    if memI
      ue_ascii_w(pathS, memI)
      ue_ascii_w(pathS + '.uebase', AdjPtr(memI, 1024))
      if CopyFileW(memI, AdjPtr(memI, 1024), TRUE)
        ue_log('Save comparison snapshot created: ' + pathS + '.uebase')
      else
        ue_log_level('WARN', 'Save comparison snapshot unavailable: ' + pathS)
      endif
      VirtualFree(memI, 0, 0x8000)
    endif
  endif
end ue_create_baseline

// Only a registered live-session temporary pathname may be written back.
// Never trust an arbitrary sidecar opened by the user as authorization.
proc ue_after_save()
  integer recordI = ueAssocHeadGI
  integer originalI = 0
  integer memI = 0
  integer stageI = 0
  integer backupI = 0
  integer errorI = 0
  integer successB = FALSE
  string pathS[MAXSTRINGLEN] = CurrFilename()
  string suffixS[80] = ''
  if not ueSaveBackGB or ueSavingGB
    return()
  endif
  while recordI
    if Lower(amem_to_ansi(AdjPtr(recordI, 8))) == Lower(pathS)
      break
    endif
    recordI = PeekLong(recordI)
  endwhile
  if not recordI
    return()
  endif
  ueSavingGB = TRUE
  originalI = AdjPtr(recordI, UE_IDENTITY_OFFSET)
  ue_log('Save-back requested: ' + pathS)
  ue_log_wide('Save-back original W: ', originalI, ue_identity_size(originalI))
  memI = VirtualAlloc(0, 131072, 0x3000, 4)
  if memI
    ue_ascii_w(pathS, memI)
    ue_ascii_w(pathS + '.uebase', AdjPtr(memI, 1024))
    stageI = AdjPtr(memI, 4096)
    backupI = AdjPtr(memI, 36864)
    suffixS = Format('.ue-'; GetCurrentProcessId(); '-'; GetTickCount())
    ue_suffix_w(originalI, stageI, suffixS + '.tmp')
    ue_suffix_w(originalI, backupI, suffixS + '.bak')
    if not ue_equal_files(originalI, AdjPtr(memI, 1024))
      ue_log_level('ERROR', 'Save-back refused: original changed, missing, unreadable or snapshot unavailable')
    elseif not CopyFileW(memI, stageI, TRUE)
      ue_log_level('ERROR', Format('Save staging failed; Windows error='; GetLastError()))
    elseif ueBackupGB and not CopyFileW(originalI, backupI, TRUE)
      ue_log_level('ERROR', Format('Optional backup failed; Windows error='; GetLastError()))
    else
      if ueBackupGB
        ue_log_wide('Backup created W: ', backupI, ue_identity_size(backupI))
      else
        ue_log('Backup disabled by INI')
      endif
      // Recheck immediately before replacement. There remains a small race
      // between closing comparison handles and the Windows replacement call.
      if not ue_equal_files(originalI, AdjPtr(memI, 1024))
        ue_log_level('ERROR', 'Save-back refused: original changed during staging')
      elseif ReplaceFileW(originalI, stageI, 0, 0, 0, 0)
        successB = TRUE
        ue_log('Save-back ReplaceFileW succeeded')
        if not CopyFileW(memI, AdjPtr(memI, 1024), FALSE)
          ue_log_level('ERROR', 'Save succeeded but snapshot refresh failed; further saves may be refused')
          Warn(MACRO_NAME, ': Original saved but comparison snapshot refresh failed.')
        endif
      else
        errorI = GetLastError()
        ue_log_level('ERROR', Format('ReplaceFileW failed; Windows error='; errorI))
      endif
    endif
    if not successB
      ue_log_wide('Possible retained staging path W: ', stageI, ue_identity_size(stageI))
    endif
    VirtualFree(memI, 0, 0x8000)
  else
    ue_log_level('ERROR', 'Save-back allocation failed')
  endif
  if not successB
    FileChanged(TRUE)
    Warn(MACRO_NAME, ': Original save not confirmed. Temporary edited file retained. See log.')
  endif
  ueSavingGB = FALSE
end ue_after_save

proc ue_assoc_clear()
  integer nextI = 0
  while ueAssocHeadGI
    nextI = PeekLong(ueAssocHeadGI)
    VirtualFree(ueAssocHeadGI, 0, 0x8000)
    ueAssocHeadGI = nextI
  endwhile
end ue_assoc_clear

// Use a readable ASCII stem plus a unique suffix. Preserve simple ASCII
// extensions (e.g. .s, .cpp, .txt); use .txt if no safe extension exists.
string proc ue_readable_temp(integer sourceI)
  integer sizeI = ue_identity_size(sourceI)
  integer iI = 0
  integer startI = 0
  integer dotI = -1
  integer unitI = 0
  integer validB = TRUE
  string stemS[40] = ''
  string extS[20] = ''
  string tempS[MAXSTRINGLEN] = ''
  string dirS[MAXSTRINGLEN] = ''
  if sizeI <= 2
    return('')
  endif
  for iI = 0 to sizeI - 4 by 2
    unitI = PeekWord(AdjPtr(sourceI, iI))
    if unitI == 92 or unitI == 47
      startI = iI + 2
      dotI = -1
    elseif unitI == 46
      dotI = iI
    endif
  endfor
  if dotI > startI and sizeI - 2 - dotI <= 34
    for iI = dotI + 2 to sizeI - 4 by 2
      unitI = PeekWord(AdjPtr(sourceI, iI))
      if (unitI >= 48 and unitI <= 57) or (unitI >= 65 and unitI <= 90) or (unitI >= 97 and unitI <= 122)
        extS = extS + Chr(unitI)
      else
        validB = FALSE
      endif
    endfor
  endif
  if not validB or extS == ''
    extS = 'txt'
  endif
  if dotI <= startI
    dotI = sizeI - 2
  endif
  for iI = startI to dotI - 2 by 2
    unitI = PeekWord(AdjPtr(sourceI, iI))
    if (unitI >= 48 and unitI <= 57) or (unitI >= 65 and unitI <= 90) or (unitI >= 97 and unitI <= 122) or unitI == 45 or unitI == 95
      stemS = stemS + Chr(unitI)
    else
      stemS = stemS + '_'
    endif
    if Length(stemS) >= 36
      break
    endif
  endfor
  if stemS == ''
    stemS = 'unicode'
  endif
  dirS = GetTempPath()
  if dirS == ''
    return('')
  endif
  if dirS[Length(dirS)] <> Chr(92)
    dirS = dirS + Chr(92)
  endif
  tempS = MakeTempName(dirS, '.' + extS)
  if tempS == ''
    return('')
  endif
  if Length(dirS) + Length(stemS) + Length(SplitPath(tempS, _NAME_)) + Length(extS) + 20 >= MAXSTRINGLEN
    return(tempS)
  endif
  return(dirS + 'ue-' + stemS + '-' + SplitPath(tempS, _NAME_) + '.' + extS)
end ue_readable_temp

proc ue_mailbox_close()
  integer resultI = 0
  if ueMailboxGI
    resultI = UnmapViewOfFile(ueMailboxGI)
    ueMailboxGI = 0
  endif
  if ueMappingGI
    resultI = CloseHandle(ueMappingGI)
    ueMappingGI = 0
  endif
end ue_mailbox_close

proc ue_mailbox_init()
  integer memI = 0
  integer errorI = 0
  integer iI = 0
  string pathS[MAXSTRINGLEN] = Lower(CurrMacroFilename())
  string nameS[MAXSTRINGLEN] = 'Local\UniExplorer15-'
  // Windows named objects cannot contain backslashes after Local\.
  // | is not valid in a Windows filename, so substitution is unambiguous.
  if Length(pathS) + Length(nameS) >= MAXSTRINGLEN
    ue_log_level('WARN', 'Mailbox name too long; local opening only')
    return()
  endif
  for iI = 1 to Length(pathS)
    if pathS[iI] == Chr(92)
      nameS = nameS + '|'
    else
      nameS = nameS + pathS[iI]
    endif
  endfor
  memI = VirtualAlloc(0, 4096, 0x3000, 4)
  if not memI
    ue_log_level('WARN', 'Mailbox name allocation failed')
    return()
  endif
  astring_to_amem(nameS, memI)
  SetLastError(0)
  ueMappingGI = CreateFileMappingA(-1, 0, 4, 0, 4096, memI)
  errorI = GetLastError()
  VirtualFree(memI, 0, 0x8000)
  if not ueMappingGI
    ue_log_level('WARN', Format('CreateFileMappingA failed; Windows error='; errorI))
    return()
  endif
  ueMailboxGI = MapViewOfFile(ueMappingGI, 6, 0, 0, 4096)
  if not ueMailboxGI
    ue_log_level('WARN', 'MapViewOfFile failed; local opening only')
    ue_mailbox_close()
    return()
  endif
  if errorI <> 183
    ueMasterGB = TRUE
    InterlockedExchange(AdjPtr(ueMailboxGI, 8), GetCurrentProcessId())
    InterlockedExchange(AdjPtr(ueMailboxGI, 4), GetWinHandle())
    ue_log(Format('Mailbox primary PID='; GetCurrentProcessId()))
    ue_log(Format('Mailbox retry ms='; ueRetryIntervalGI; ' busy timeout ms='; ueBusyTimeoutGI; ' ack timeout ms='; ueAckTimeoutGI))
  else
    ue_log(Format('Mailbox secondary PID='; GetCurrentProcessId()))
  endif
end ue_mailbox_init

// Validate a window against the intended process before using it.
integer proc ue_window_matches(integer hwndI, integer pidI)
  integer memI = 0
  integer resultI = FALSE
  if hwndI and pidI
    memI = VirtualAlloc(0, 4096, 0x3000, 4)
    if memI
      if GetWindowThreadProcessId(hwndI, memI)
        resultI = (PeekLong(memI) == pidI)
      endif
      VirtualFree(memI, 0, 0x8000)
    endif
  endif
  return(resultI)
end ue_window_matches

proc ue_focus_primary()
  integer hwndI = 0
  integer pidI = 0
  integer resultI = 0
  if ueMailboxGI and not ueMasterGB
    hwndI = PeekLong(AdjPtr(ueMailboxGI, 4))
    pidI = PeekLong(AdjPtr(ueMailboxGI, 8))
    if ue_window_matches(hwndI, pidI)
      resultI = AllowSetForegroundWindow(pidI)
      ue_log(Format('Mailbox focus permission PID='; pidI; ' result='; resultI))
      if IsIconic(hwndI)
        ShowWindow(hwndI, 9)
      endif
      resultI = SetForegroundWindow(hwndI)
      if resultI
        ue_log(Format('Mailbox foreground requested for PID='; pidI))
      else
        ue_log_level('WARN', Format('Mailbox foreground denied for PID='; pidI))
      endif
    else
      ue_log_level('WARN', 'Mailbox primary window unavailable or PID mismatch')
    endif
  endif
end ue_focus_primary

integer proc ue_mailbox_send(string pathS, integer associatedB)
  integer stateI = 0
  integer waitedI = 0
  integer delayI = 0
  integer resultI = 0
  if not ueMailboxGI or ueMasterGB
    return(FALSE)
  endif
  if pathS == '' or Length(pathS) >= MAXSTRINGLEN
    return(FALSE)
  endif
  stateI = InterlockedCompareExchange(ueMailboxGI, 1, 0)
  if stateI <> 0
    ue_log(Format('Mailbox busy; waiting sender PID='; GetCurrentProcessId(); ' state='; stateI))
    while stateI <> 0 and waitedI < ueBusyTimeoutGI
      delayI = ueRetryIntervalGI
      if delayI > ueBusyTimeoutGI - waitedI
        delayI = ueBusyTimeoutGI - waitedI
      endif
      Sleep(delayI)
      waitedI = waitedI + delayI
      stateI = InterlockedCompareExchange(ueMailboxGI, 1, 0)
    endwhile
    if stateI <> 0
      ue_log_level('WARN', Format('Mailbox busy timeout; keeping secondary PID='; GetCurrentProcessId(); ' waited ms='; waitedI))
      return(FALSE)
    endif
    ue_log(Format('Mailbox acquired after waiting ms='; waitedI; ' sender PID='; GetCurrentProcessId()))
  endif
  resultI = InterlockedExchange(AdjPtr(ueMailboxGI, 12), GetCurrentProcessId())
  astring_to_amem(pathS, AdjPtr(ueMailboxGI, 16))
  resultI = InterlockedExchange(AdjPtr(ueMailboxGI, 272), associatedB)
  resultI = InterlockedExchange(ueMailboxGI, 2)
  ue_log(Format('Mailbox request sender PID='; GetCurrentProcessId()))
  ue_log('Mailbox request: ' + pathS)
  waitedI = 0
  while waitedI < ueAckTimeoutGI
    stateI = InterlockedCompareExchange(ueMailboxGI, 0, 0)
    if stateI == 4 or stateI == 5
      resultI = InterlockedExchange(ueMailboxGI, 0)
      if stateI == 4
        ue_log('Mailbox acknowledged successful load')
        return(TRUE)
      endif
      ue_log_level('WARN', 'Mailbox receiver could not load file')
      return(FALSE)
    endif
    delayI = ueRetryIntervalGI
    if delayI > ueAckTimeoutGI - waitedI
      delayI = ueAckTimeoutGI - waitedI
    endif
    Sleep(delayI)
    waitedI = waitedI + delayI
  endwhile
  // Cancel an unclaimed request, or mark an in-progress request abandoned.
  stateI = InterlockedCompareExchange(ueMailboxGI, 0, 2)
  if stateI <> 2
    stateI = InterlockedCompareExchange(ueMailboxGI, 6, 3)
    if stateI == 4 or stateI == 5
      resultI = InterlockedExchange(ueMailboxGI, 0)
      if stateI == 4
        ue_log('Mailbox acknowledged successful load at timeout boundary')
        return(TRUE)
      endif
    endif
  endif
  ue_log_level('WARN', 'Mailbox acknowledgment timed out; keeping secondary instance')
  return(FALSE)
end ue_mailbox_send

// A menu or picklist can suspend _IDLE_. Never load files in nonediting idle.
// Report each blocked sender once; the normal editing receiver owns all loads.
proc ue_mailbox_nonedit_idle()
  integer senderI = 0
  if ueMailboxGI and ueMasterGB
    if InterlockedCompareExchange(ueMailboxGI, 0, 0) == 2
      senderI = PeekLong(AdjPtr(ueMailboxGI, 12))
      if senderI <> ueNoneditSenderGI
        ueNoneditSenderGI = senderI
        ue_log_level('WARN', Format('Mailbox pending during nonediting idle; close menu or dialog; sender PID='; senderI))
      endif
    else
      ueNoneditSenderGI = 0
    endif
  endif
end ue_mailbox_nonedit_idle

proc ue_mailbox_idle()
  integer resultI = 0
  integer stateI = 5
  string pathS[MAXSTRINGLEN] = ''
  integer identityI = 0
  integer sizeI = 0
  if ueMailboxGI and ueMasterGB
    if InterlockedCompareExchange(ueMailboxGI, 3, 2) == 2
      if ueNoneditSenderGI
        ue_log('Mailbox editing idle resumed')
        ueNoneditSenderGI = 0
      endif
      pathS = amem_to_ansi(AdjPtr(ueMailboxGI, 16))
      ue_log(Format('Mailbox receiver PID='; GetCurrentProcessId(); ' sender PID='; PeekLong(AdjPtr(ueMailboxGI, 12))))
      ue_log('Mailbox received: ' + pathS)
      if pathS <> '' and FileExists(pathS)
        if PeekLong(AdjPtr(ueMailboxGI, 272))
          identityI = VirtualAlloc(0, UE_IDENTITY_MAX_BYTES, 0x3000, 4)
          if identityI
            sizeI = ue_read_identity(pathS, identityI)
          endif
        endif
        if ueDeduplicateGB and sizeI and ue_assoc_select(identityI, sizeI)
          stateI = 4
          ue_log('Duplicate copy retained on disk; existing buffer preserved')
        elseif EditThisFile(pathS, _DONT_PROMPT_)
          stateI = 4
          if sizeI
            ue_assoc_add(pathS, identityI, sizeI)
          endif
        endif
        if stateI == 4
          ue_log('Mailbox receiver loaded: ' + CurrFilename())
          // EditThisFile selects the newly loaded buffer; redraw in editing idle.
          UpdateDisplay(_ALL_WINDOWS_REFRESH_)
          ue_log('Mailbox receiver selected: ' + CurrFilename())
          resultI = InterlockedExchange(AdjPtr(ueMailboxGI, 4), GetWinHandle())
        endif
      endif
      if identityI
        VirtualFree(identityI, 0, 0x8000)
      endif
      if stateI == 5
        ue_log_level('ERROR', 'Mailbox receiver load failed: ' + pathS)
      endif
      resultI = InterlockedCompareExchange(ueMailboxGI, stateI, 3)
      if resultI == 6
        resultI = InterlockedCompareExchange(ueMailboxGI, 0, 6)
      endif
    endif
  endif
end ue_mailbox_idle

// Post a normal window-close request while still in AutoLoad. Unlike _IDLE_,
// the Windows message does not require the editor to enter text-editing mode.
integer proc ue_secondary_request_close()
  integer hwndI = 0
  integer pidI = GetCurrentProcessId()
  if ueCloseGB and not ueMasterGB
    hwndI = GetWinHandle()
    if ue_window_matches(hwndI, pidI)
      ue_focus_primary()
      if PostMessageA(hwndI, 0x0010, 0, 0)
        ue_log(Format('Acknowledged secondary PID='; pidI; ' WM_CLOSE posted'))
        return(TRUE)
      endif
      ue_log_level('WARN', Format('WM_CLOSE post failed PID='; pidI; ' Windows error='; GetLastError()))
    else
      ue_log_level('WARN', Format('Secondary window not ready PID='; pidI))
    endif
  endif
  return(FALSE)
end ue_secondary_request_close

proc ue_secondary_exit()
  UnHook(ue_secondary_exit)
  if ueCloseGB and not ueMasterGB
    if not ue_secondary_request_close()
      ue_log_level('WARN', 'Secondary close unavailable; close this instance manually')
    endif
  endif
end ue_secondary_exit
#endif

#if INTERNAL_VERSION < 12467
// Diagnostic content-only fallback. Keep the temporary file as the buffer's
// actual filename; write-back uses the registered exact UTF-16 original.
proc ue_legacy_copy_w(integer sourceAddressI, integer destinationAddressI)
  string tempS[MAXSTRINGLEN] = ''
  integer iI = 0
  integer byteI = 0
  integer safeB = TRUE
  integer errorI = 0
  integer associatedB = FALSE

  ue_log('Legacy CopyFileW content-only branch')
  // Do not let TSE open the lossy ANSI command-line filename on failure.
  Set(DosCmdLine, '')
  ue_log('DosCmdLine cleared before copying')
  tempS = ue_readable_temp(sourceAddressI)
  if tempS == ''
    safeB = FALSE
  endif
  if Length(tempS) >= MAXSTRINGLEN
    safeB = FALSE
  endif
  for iI = 1 to Length(tempS)
    byteI = Asc(tempS[iI])
    if byteI < 32 or byteI > 126
      safeB = FALSE
    endif
  endfor
  if not safeB
    ue_log_level('ERROR', 'Unsafe or unavailable ASCII temporary path')
    Warn(MACRO_NAME, ': Cannot obtain a safe ASCII temporary path.')
    return()
  endif
  // ASCII destination is identical in UTF-16 and in Windows ANSI.
  for iI = 1 to Length(tempS)
    PokeWord(AdjPtr(destinationAddressI, (iI - 1) * 2), Asc(tempS[iI]))
  endfor
  PokeWord(AdjPtr(destinationAddressI, Length(tempS) * 2), 0)
  ue_log('Temporary filename: ' + tempS)
  // TRUE: never overwrite a pre-existing destination.
  if CopyFileW(sourceAddressI, destinationAddressI, TRUE)
    ue_log('CopyFileW succeeded')
    associatedB = ue_write_identity(tempS, sourceAddressI)
    if associatedB
      ue_create_baseline(tempS)
    endif
    if ue_mailbox_send(tempS, associatedB)
      ueCloseGB = TRUE
      ue_log('Forwarded temporary copy; save-back requires registered association')
      return()
    endif
    if EditThisFile(tempS, _DONT_PROMPT_)
      if associatedB
        ue_assoc_add(tempS, sourceAddressI, ue_identity_size(sourceAddressI))
      endif
      ue_log('EditThisFile succeeded: ' + CurrFilename())
      ue_log('Temporary filename retained; save-back requires registered association')
    else
      ue_log_level('ERROR', 'EditThisFile failed; temporary copy retained')
      Warn(MACRO_NAME, ': Cannot open temporary copy: ', tempS)
    endif
  else
    errorI = GetLastError()
    ue_log_level('ERROR', Format('CopyFileW failed; Windows error='; errorI))
    Warn(MACRO_NAME, ': CopyFileW failed; see uniexplorer.log.')
  endif
end ue_legacy_copy_w
#endif


// Version 17: handle a native Single Instance switch before a quoted file.
// Accept a quoted or unquoted executable, then exactly -1 or -1-,
// then one quoted filename. Do not change the native editor setting here.
integer proc ue_cmd_space(integer charI)
  return(charI == 32 or charI == 9)
end ue_cmd_space

integer proc ue_parse_instance_switch(integer cmdlineI, integer filenameI)
  integer posI = 0
  integer charI = 0
  integer bytesI = 0
  integer offB = FALSE
  integer quotedB = FALSE
  charI = PeekWord(AdjPtr(cmdlineI, posI))
  if charI == DOUBLE_QUOTE
    quotedB = TRUE
    posI = posI + 2
  endif
  while posI <= MAX_CMDLINE_LENGTH_W - 2
    charI = PeekWord(AdjPtr(cmdlineI, posI))
    if not charI
      return(0)
    endif
    if quotedB
      if charI == DOUBLE_QUOTE
        posI = posI + 2
        break
      endif
    elseif ue_cmd_space(charI)
      break
    endif
    posI = posI + 2
  endwhile
  if posI > MAX_CMDLINE_LENGTH_W - 2
    return(0)
  endif
  if not ue_cmd_space(PeekWord(AdjPtr(cmdlineI, posI)))
    return(0)
  endif
  while posI <= MAX_CMDLINE_LENGTH_W - 2
    if not ue_cmd_space(PeekWord(AdjPtr(cmdlineI, posI)))
      break
    endif
    posI = posI + 2
  endwhile
  if posI > MAX_CMDLINE_LENGTH_W - 6
    return(0)
  endif
  if PeekWord(AdjPtr(cmdlineI, posI)) <> 45
  or PeekWord(AdjPtr(cmdlineI, posI + 2)) <> 49
    return(0)
  endif
  posI = posI + 4
  if PeekWord(AdjPtr(cmdlineI, posI)) == 45
    offB = TRUE
    posI = posI + 2
  endif
  if posI > MAX_CMDLINE_LENGTH_W - 2
    return(0)
  endif
  if not ue_cmd_space(PeekWord(AdjPtr(cmdlineI, posI)))
    return(0)
  endif
  while posI <= MAX_CMDLINE_LENGTH_W - 2
    if not ue_cmd_space(PeekWord(AdjPtr(cmdlineI, posI)))
      break
    endif
    posI = posI + 2
  endwhile
  if posI > MAX_CMDLINE_LENGTH_W - 2
    return(0)
  endif
  if PeekWord(AdjPtr(cmdlineI, posI)) <> DOUBLE_QUOTE
    return(0)
  endif
  posI = posI + 2
  while posI <= MAX_CMDLINE_LENGTH_W - 2
  and bytesI <= Min(MAX_CMDLINE_LENGTH_W, MAX_LONG_PATH_W) - 4
    charI = PeekWord(AdjPtr(cmdlineI, posI))
    if not charI
      return(0)
    endif
    if charI == DOUBLE_QUOTE
      posI = posI + 2
      while posI <= MAX_CMDLINE_LENGTH_W - 2
        charI = PeekWord(AdjPtr(cmdlineI, posI))
        if not charI
          if not bytesI
            return(0)
          endif
          PokeWord(AdjPtr(filenameI, bytesI), NULL)
          if offB
            ue_log('Command line Single Instance override: -1- (OFF)')
          else
            ue_log('Command line Single Instance override: -1 (ON)')
          endif
          return(bytesI / 2)
        endif
        if not ue_cmd_space(charI)
          return(0)
        endif
        posI = posI + 2
      endwhile
      return(0)
    endif
    PokeWord(AdjPtr(filenameI, bytesI), charI)
    bytesI = bytesI + 2
    posI = posI + 2
  endwhile
  return(0)
end ue_parse_instance_switch

proc check_command_line()
  integer ueErrorI                          = 0
  integer cmdline_address                   = 0
  integer filename_address                  = 0
  integer i                                 = 0
  integer num_chars                         = 0
  integer ok                                = TRUE
  integer org_id                            = GetBufferId()
  string  s                  [MAXSTRINGLEN] = ''
  integer short_filename_address            = 0
  integer tmp_id                            = 0
  string  temp_filename      [MAXSTRINGLEN] = ''
  string  tse_ansi_filename  [MAXSTRINGLEN] = ''
  string  tse_ascii_filename [MAXSTRINGLEN] = ''
  string  tse_short_filename [MAXSTRINGLEN] = ''

  ue_log('check_command_line entered')
  //  The command line is returned as a double-quoted executable,
  //  always followed by a space even if there are no parameters,
  //  and then space-separated double-quoted parameters.
  //  The sometimes superfluous space is a Windows legacy quirk
  //  that serves no purpose.


  //  The Lower() is for a bug in TSE 4.50.32,
  //  that lowercases CurrMacroFilename() in the TSE debugger.
  s = Lower(MACRO_NAME + '_debug:DosCmdLine')
  tmp_id = GetGlobalInt(s)
  if tmp_id
    ok = ok and memblock_create_block(g_container_id, cmdline_address, MAX_CMDLINE_LENGTH_W)
    if ok
      GotoBufferId(tmp_id)
      //  UTF-16LE word-sized numbers are being copied byte by byte.
      for i = 1 to CurrLineLen()
        PokeByte(AdjPtr(cmdline_address, i - 1), Asc(GetText(i, 1)))
      endfor
      PokeByte(AdjPtr(cmdline_address, CurrLineLen()    ), NULL)
      PokeByte(AdjPtr(cmdline_address, CurrLineLen() + 1), NULL)
      GotoBufferId(org_id)
    else
      ok = FALSE
    endif
  else
    cmdline_address = GetCommandLineW()
  endif

  ue_log_wide('Windows command line W', cmdline_address, MAX_CMDLINE_LENGTH_W)
  if not cmdline_address
    ue_log_level('ERROR', 'No command line pointer; exit')
    return()
  endif
  ue_log('Windows command line A: ' + amem_to_ansi(GetCommandLineA()))
  ue_log('TSE DosCmdLine: ' + Query(DosCmdLine))
  if FALSE
    Warn('Command line = "', wmem_to_ascii(cmdline_address), '".')
  endif

  ok = ok and memblock_create_block(g_container_id, filename_address, Min(MAX_LONG_PATH_W, MAX_CMDLINE_LENGTH_W))
  ok = ok and memblock_create_block(g_container_id, short_filename_address, MAX_LONG_PATH_W)

  //  xx  For debugging:
  if ok
      ue_log(Format('Allocation success='; ok))
    else
      ue_log_level('ERROR', Format('Allocation success='; ok))
    endif
  if ok
    PokeWord(AdjPtr(short_filename_address, 0), 72)
    PokeWord(AdjPtr(short_filename_address, 2),  0)
    ue_log(Format('Quote count='; num_double_quotes_w(cmdline_address)))
  endif

  // First try the explicit native Single Instance switch form.
  // Otherwise retain the original four-quote Explorer parser.
  if ok
    num_chars = ue_parse_instance_switch(cmdline_address, filename_address)
    if not num_chars
      if num_double_quotes_w(cmdline_address) <> 4
        ue_log('Skip: quote count is not four')
        ok = FALSE
      else
        num_chars = get_1st_param_from_cmdline_w(cmdline_address, filename_address)
      endif
    endif
  endif

  // Here num_chars excludes NULL terminator.
  if ok
    ue_log(Format('Parsed filename units='; num_chars))
    if not num_chars
      ue_log_level('WARN', 'Skip: no filename parsed')
      ok = FALSE
    else
      ue_log_wide('Original filename W', filename_address, MAX_LONG_PATH_W)
    endif
  endif

  if FALSE
    Warn('file_in = "', wmem_to_ascii(filename_address), '".')
  endif

  if  ok
  and is_ascii_w(filename_address)
    ue_log('Skip: filename is ASCII')
    // ASCII files may also be forwarded to the primary, without copying.
#if INTERNAL_VERSION < 12467
    if not ueMasterGB and ueMailboxGI and num_chars < MAXSTRINGLEN
      if ue_mailbox_send(wmem_to_ascii(filename_address), FALSE)
        Set(DosCmdLine, '')
        ueCloseGB = TRUE
      endif
    endif
#endif
    // Otherwise let TSE handle opening the file.
    ok = FALSE
  endif

#if INTERNAL_VERSION < 12467
  if ok
    ue_legacy_copy_w(filename_address, short_filename_address)
    ok = FALSE
  endif
#else
  if ok
    if EXT_CP_MAX_CHAR_LENGTH == 1
      //  We can do it the standard, fast way.
      num_chars = GetShortPathNameW(filename_address,
                                    short_filename_address,
                                    MAX_LONG_PATH_W)
      if not num_chars
        ueErrorI = GetLastError()
        ue_log_level('WARN', Format('GetShortPathNameW error='; ueErrorI))
        SetLastError(ueErrorI)
        warn_windows_error('GetShortPathNameW')
        ok = FALSE
      endif
    else
      //  We need to do it a non-standard, a fraction slower way.
      //  get_short_path_name_w() ensures that the short filename's names
      //  are still ASCII-encoded and 8.3-formatted for other Windows code pages.
      //  Tested for code page 936 (Simplified Chinese).
      num_chars = get_short_path_name_w(filename_address,
                                        short_filename_address,
                                        MAX_LONG_PATH_W)
      if not num_chars
        ue_log_level('WARN', 'get_short_path_name_w failed')
        Warn(MACRO_NAME, ': get_short_path_name_w() failed.')
        ok = FALSE
      endif
    endif
  endif

  if ok
    ue_log(Format('Short path API units='; num_chars))
    ue_log_wide('Short filename W', short_filename_address, MAX_LONG_PATH_W)
    if FALSE
      Warn('Before merge 1st:', Chr(13),
           'Filename = "', wmem_to_ascii(filename_address), '".', Chr(13),
           'Short address = ', short_filename_address, '.',  Chr(13),
           'Short filename = "', wmem_to_ascii(short_filename_address), '".')
    endif

    //  A fully qualified drive:\path\filename.extension consists of "names"
    //  separated by a backslash ("\").
    //  For each such name, if it is ANSI-compatible, then use
    //  the ANSI-compatible name, otherwise use its short name.
    tse_ansi_filename  = merge_long_and_short_names(filename_address,
                                                    short_filename_address)

    //  The short filename's names are ASCII-encoded and 8.3-formatted,
    //  so there is no problem assigning it to a TSE string,
    //  except theoretically cutting off an extremely long filename.
    tse_short_filename = wmem_to_ascii(short_filename_address)

    tse_ascii_filename = wmem_to_ascii(filename_address)

    if FALSE
      Warn('input filename ='                         , Chr(13),
           '"', wmem_to_ascii(filename_address), '"'  , Chr(13),
           'tse_short_filename ='                     , Chr(13),
           '"', tse_short_filename, '"'               , Chr(13),
           'tse_ansi_filename (converted to ASCII) =' , Chr(13),
           '"', tse_ascii_filename, '"')
    endif

    //  This extension opens a non-ASCII filename by its short names,
    //  then renames the filename's names back to their ANSI names.

    ue_log('Merged ANSI filename: ' + ansi_to_ascii(tse_ansi_filename))
    ue_log('Original escaped filename: ' + tse_ascii_filename)
    ue_log('Short filename: ' + tse_short_filename)
    ue_log(Format('FileExists(short)='; FileExists(tse_short_filename)))
    if tse_ansi_filename == tse_ascii_filename
      ue_log_level('WARN', 'Skip: merged ANSI filename equals escaped original')
    endif
    if tse_ansi_filename <> tse_ascii_filename
      if FileExists(tse_short_filename)
        if EditThisFile(tse_short_filename, _DONT_PROMPT_)
          change_curr_filename(tse_ansi_filename)
          SetBufferInt(MACRO_NAME + ':SaveUsingWorkAround', TRUE)
          Hook(_ON_FILE_SAVE_   , on_file_save)
          Hook(_AFTER_FILE_SAVE_, after_file_save)
          Set(DosCmdLine, '')
        else
          Warn('ERROR: Cannot open short filename:', Chr(13),
               QuotePath(tse_short_filename))
        endif

      else
        ue_log_level('WARN', 'Skip: short filename does not exist')
        Warn('ERROR: No such short filename:', Chr(13),
             QuotePath(tse_short_filename))
      endif
    endif
  endif

#endif

  if tmp_id
    memblock_delete_block(g_container_id, cmdline_address)
  endif

  memblock_delete_block(g_container_id, filename_address)
  memblock_delete_block(g_container_id, short_filename_address)
  ue_log('check_command_line exit: ' + CurrFilename())
end check_command_line


proc check_macro_load_order(string macro1, string macro2)
  integer org_id = GetBufferId()

  //  This proc's parameters are in the same order as the required macro load
  //  order.
  //
  //  When reading this proc's code, be aware of this triple reverse: (!)
  //    TSE calls same hooks in reverse macro load order,
  //    the "Loaded Macros" buffer contains macros in reverse load order,
  //    and below we search for the wrong load order.

  GotoBufferId(4) // TSE's "Loaded and public macros" buffer.
  PushLocation()

  if  lFind('\' + macro1 + '.mac', 'gi$')
  and lFind('\' + macro2 + '.mac', 'i$+')
    Alarm()
    MsgBox(MACRO_NAME + ' - Error in macro load order',
           Format(MACRO_NAME; 'found an error in the macro load order:',
                  Chr(13),
                  'The "', macro2, '" macro must be loaded after the "', macro1, '" macro.',
                  Chr(13),
                  'You should move "', macro2,'" down (or "', macro1, '" up)', Chr(13),
                  'in the Macro AutoLoad List menu and restart TSE.'))
    Delay(9)
  endif

  PopLocation()
  GotoBufferId(org_id)
end check_macro_load_order


proc idle_check_macro_load_orders()
  UnHook(idle_check_macro_load_orders)
  check_macro_load_order('Unicode', MACRO_NAME)
end idle_check_macro_load_orders


proc WhenPurged()
#if INTERNAL_VERSION < 12467
  if ueCloseGB and not ueMasterGB
    ue_log(Format('Acknowledged secondary cleanup PID='; GetCurrentProcessId()))
  endif
  ue_assoc_clear()
  ue_mailbox_close()
#endif
  //  Sound(1200, 200) Delay(4)
  //  Sound(1400, 200) Delay(4)
  if g_container_id
    memblock_delete_container(g_container_id)
    g_container_id = 0
  endif
  //  Sound(1400, 200) Delay(4)
  //  Sound(1200, 200) Delay(4)
end WhenPurged


proc WhenLoaded()
  integer font_flags               = 0
  string  font_name [MAXSTRINGLEN] = ''
  integer font_size                = 0
  integer lpCPInfoExW_address      = 0

  MACRO_NAME    = SplitPath(CurrMacroFilename(), _NAME_)
  ue_log_init()
  ue_log('===== UniExplorer compatibility 1.0.0.0.19 WhenLoaded =====')
  ue_log(Format('Compiler INTERNAL_VERSION='; INTERNAL_VERSION))
  ue_log('Macro path: ' + CurrMacroFilename())
  ue_log('Initial buffer: ' + CurrFilename())
#if INTERNAL_VERSION < 12467
  #if UNIEXPLORER_LEGACY_RUNTIME
    // Experimental legacy runtime explicitly enabled in source.
  #else
    Warn(MACRO_NAME, ': Legacy runtime disabled; compilation-only build.')
    return()
  #endif
#endif
  TSE_CODE_PAGE = Query(CodePage)

  Hook(_IDLE_, idle_check_macro_load_orders)
  Hook(_ON_ABANDON_EDITOR_, WhenPurged)

  if isGUI()
#if INTERNAL_VERSION < 12467
    ue_mailbox_init()
#endif
    GetFont(font_name, font_size, font_flags)
    if font_name <> 'Terminal'
      TSE_CODE_PAGE = 1252
    endif

    if memblock_create_container(g_container_id)
      if memblock_create_block(g_container_id, lpCPInfoExW_address, LPCPINFOEXW_LENGTH)
        if GetCPInfoExW(CP_ACP, 0, lpCPInfoExW_address)
          ue_log('GetCPInfoExW succeeded')
        else
          ue_log_level('ERROR', Format('GetCPInfoExW error='; GetLastError()))
        endif
        EXT_CP_MAX_CHAR_LENGTH = PeekLong(lpCPInfoExW_address)

        ue_log(Format('TSE code page='; TSE_CODE_PAGE; ' Windows max char bytes='; EXT_CP_MAX_CHAR_LENGTH))
        check_command_line()

        memblock_delete_block(g_container_id, lpCPInfoExW_address)
      else
        ue_log_level('ERROR', 'WhenLoaded: memblock_create_block failed')
        Warn(MACRO_NAME, ': WhenLoaded: memblock_create_block() failed.')

        //  xx  For debugging:
        Delay(18)
      endif
    else
      ue_log_level('ERROR', 'WhenLoaded: memblock_create_container failed')
      Warn(MACRO_NAME, ': WhenLoaded: memblock_create_container() failed.')
    endif
  endif

  ue_log('WhenLoaded exit buffer: ' + CurrFilename())
#if INTERNAL_VERSION < 12467
  if isGUI()
    if not ueCloseGB
      Hook(_AFTER_FILE_SAVE_, ue_after_save)
      ue_log(Format('Save-back enabled='; ueSaveBackGB; ' backup='; ueBackupGB))
    endif
    // Only the primary needs a persistent receiver; no general file tracing.
    if ueMasterGB
      Hook(_IDLE_, ue_mailbox_idle)
      Hook(_NONEDIT_IDLE_, ue_mailbox_nonedit_idle)
      ue_log(Format('Mailbox duplicate detection enabled='; ueDeduplicateGB))
      ue_log('Mailbox primary idle receiver installed')
    elseif ueCloseGB
      UnHook(idle_check_macro_load_orders)
      if not ue_secondary_request_close()
        // Retry once at the first editing OR non-editing idle event.
        Hook(_IDLE_, ue_secondary_exit)
        Hook(_NONEDIT_IDLE_, ue_secondary_exit)
        ue_log('Secondary close retry hooks installed')
      endif
    else
      ue_mailbox_close()
    endif
  endif
#else
  if EXT_CP_MAX_CHAR_LENGTH == 1
    ue_log('Purging macro as in upstream single-byte code-page path')
    PurgeMacro(MACRO_NAME)
  endif
#endif
end WhenLoaded


proc Main()
  ue_log('Main invoked (no filename processing)')
  NoOp()
end Main


