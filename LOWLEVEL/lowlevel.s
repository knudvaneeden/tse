/*
   lowlevel.s
   Test/demo macro for the Windows LOWLEVEL DLL replacement.

   Version : 1.0.0.0.5
   Date    : 2026-09-19 23:36 CEST
   LLM     : GPT-5.6 Sol
*/

#include ["lowlevel.inc"]

PROC Main()
    string iniFileS[255] = SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_) + "lowlevel.ini"
    string testFileS[255] = GetProfileStr("lowlevel", "testfile", "", iniFileS)
    string dataS[255] = ""
    integer seekOffsetI = GetProfileInt("lowlevel", "seekoffset", 0, iniFileS)
    integer seekMethodI = GetProfileInt("lowlevel", "seekmethod", SEEK_SET, iniFileS)
    integer readBytesI = GetProfileInt("lowlevel", "readbytes", 32, iniFileS)
    integer handleI = -1
    integer positionI = -1
    integer bytesReadI = -1
    integer closeResultI = -1

    if testFileS == ""
        testFileS = CurrFilename()
    endif

    if readBytesI < 0
        readBytesI = 0
    endif
    if readBytesI > 255
        readBytesI = 255
    endif

    if testFileS <> "" and FileExists(testFileS)
        handleI = _open(testFileS)
        if handleI >= 0
            positionI = _seek(handleI, seekOffsetI, seekMethodI)
            if positionI >= 0
                bytesReadI = _read(handleI, dataS, readBytesI)
            endif
            closeResultI = _close(handleI)
        endif
    endif

    Warn("LOWLEVEL 1.0.0.0.5  file=" + testFileS + "  handle=" + Str(handleI) + "  position=" + Str(positionI) + "  bytes=" + Str(bytesReadI) + "  close=" + Str(closeResultI) + "  data=[" + dataS + "]")
END
