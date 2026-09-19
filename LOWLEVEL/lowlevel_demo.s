/*
   lowlevel_demo.s
   Minimal TSE SAL demonstration of the Windows LOWLEVEL DLL.

   Version : 1.0.0.0.5
   Date    : 2026-09-19 23:36 CEST
   LLM     : GPT-5.6 Sol
*/

#include ["lowlevel.inc"]

PROC Main()
    string fileS[255] = CurrFilename()
    string dataS[255] = ""
    string resultS[255] = ""
    integer handleI = -1
    integer positionI = -1
    integer bytesReadI = -1
    integer closeResultI = -1

    if fileS == ""
        resultS = "LOWLEVEL demo: no current file is open."
    else
        handleI = _open(fileS)
        if handleI < 0
            resultS = "LOWLEVEL demo: _open() failed for " + fileS
        else
            positionI = _seek(handleI, 0, SEEK_SET)
            if positionI < 0
                resultS = "LOWLEVEL demo: _seek() failed.  handle=" + Str(handleI)
            else
                bytesReadI = _read(handleI, dataS, 80)
                if bytesReadI < 0
                    resultS = "LOWLEVEL demo: _read() failed.  handle=" + Str(handleI) + "  position=" + Str(positionI)
                else
                    resultS = "LOWLEVEL 1.0.0.0.5  handle=" + Str(handleI) + "  position=" + Str(positionI) + "  bytes=" + Str(bytesReadI) + "  data=[" + dataS + "]"
                endif
            endif
            closeResultI = _close(handleI)
            resultS = resultS + "  close=" + Str(closeResultI)
        endif
    endif

    Warn(resultS)
END
