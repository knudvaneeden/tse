// typedef struct
// {
//     char    ID[ 4];         //  1  zip ID
//     char    x1[ 4];         //  5
//     int     nMethod;        //  9  compression method
//     int     orig_time;      // 11  original file time
//     int     orig_date;      // 13  original file date
//     char    x2[ 4];         // 15  there's got to be some attributes in here somewhere
//     long    comp_size;      // 19  compressed size
//     long    uncomp;         // 23  uncompressed size
//     int     fn_size;        // 27  file name length
//     int     extra;          // 29  some extra space for me to skip over
// } ZIP;                      // total of 30 bytes
//
// directly after the header is comp_size bytes containing the compressed file
//
// if nMethod == 0, then the file is just "stored" and can be directly
// extracted (just copy to the bytes to a new file with the name given
// in the zip)
//

#include "lowlevel.inc"

forward proc zipread (string pcZipFile)
forward integer proc bin2i (string cTemp)
forward integer proc bin2l (string cTemp)

constant    HEADER_SIZE  =   30
string  cZipHeader[ HEADER_SIZE]

// **************************************************************************
proc ziplook (string pcPath)

    gotobufferid(zipBuffer)
    emptybuffer()

    zipread(pcPath)

    if (lFind(zfileToFind, "igx"))
        gotoline(1)
        gotocolumn(1)
        while (lrepeatfind())
            markLine()
            cTmpLine = getmarkedText()
            unmarkblock()
            cTmpLine = format(cTmpLine, "  <-  ", pcPath)
            addline(cTmpLine, origId)
        endwhile
    endif

    gotoBufferId(origId)
end

// **************************************************************************
proc zipread (string pcZipFile)

    integer iZipId
    integer comp_size
    integer uncomp
    integer fn_size
    integer extra

    iZipId = _open(pcZipFile)

    if (iZipId >= 0 and iZipId <= 255)  // not very portable, but then
                                        // neither is SAL
        while (1)

            // read zip file header
            if (HEADER_SIZE <> _read(iZipId, cZipHeader, HEADER_SIZE))
                break
            endif

            if (substr(cZipHeader, 1, 4) == "PK")
                break
            elseif (substr(cZipHeader, 1, 4) <> "PK")
                break
            endif

            comp_size = bin2l(substr(cZipHeader, 19, 4))
            uncomp    = bin2l(substr(cZipHeader, 23, 4))
            fn_size   = bin2i(substr(cZipHeader, 27, 2))
            extra     = bin2i(substr(cZipHeader, 29, 2))
            file_date = dosDate(substr(cZipHeader, 13, 2))
            file_time = dosTime(substr(cZipHeader, 11, 2))

            _read(iZipId, cTmpLine, fn_size)    // read file name
            _seek(iZipId, comp_size + extra, SEEK_CUR)

            addline(
                    format(
                        uncomp:9,
                        file_date:10,
                        file_time:10,
                        "  ",
                        cTmpLine))

        endwhile

        _close(iZipId)
    endif

end

// * end of file ZIP.S
