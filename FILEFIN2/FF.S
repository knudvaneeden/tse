// A starter macro to show some fun things that can be done with
// SAL and ff.inc that comes with TSGREP (wp.bin can also be used.)
//
// This macro will dump  the found file names into the current
// buffer!
//
// a TSE file find macro
//


// **************************************************************************

string  cTmpLine[   100]            // used all over the place
                                    // so don't expect it to hold a value
                                    // for very long
string  fileToFind[  18]
string  zfileToFind[ 18]
string  ffblk[       43]
string  file_date[ 8]
string  file_time[ 8]
integer lLookInZip      = TRUE
integer zipBuffer       = -1
integer origId


// **************************************************************************
#include "convert.inc"
#include "ff.inc"
#include "zip.inc"

// **************************************************************************
proc setZip (integer lSet)
    lLookInZip = lSet
end

menu ZipSearch()
    history

    "Search Zip Files?", , Divide
    "&Yes" ,    setZip(TRUE)
    "&No"  ,    setZip(FALSE)
end

// **************************************************************************
proc lookInDir (string pathName)

    message(pathName)

    if (lLookInZip)

        if (findFirst(format(pathName, "*.ZIP"), ffblk, ALL_ATTRIBS))
            repeat
                ziplook(format(pathName, ffName(ffblk), chr(0)))
            until (not findNext(ffblk))
        endif
    endif

    if (findFirst(format(pathName, fileToFind), ffblk, ALL_ATTRIBS))
        repeat
            if (ffAttr(ffblk) & _A_SUBDIR)
                cTmpLine = format("<DIR>":-11)
            else
                // file size
                cTmpLine = format(bin2l(substr(ffblk, 27, 4)):9, "  ")
            endif

            file_date = dosDate(substr(ffblk, 25, 2))
            file_time = dosTime(substr(ffblk, 23, 2))

            cTmpLine = format(  cTmpLine,
                                file_date:-10,
                                file_time:-10,
                                pathName,
                                ffname(ffblk)
                                )
            addline(cTmpLine)
        until (not findNext(ffblk))
    endif

end

// **************************************************************************
proc findDirs (string pathName)
    string      ffblk[ 43] = ""

    lookInDir(pathName)

    if (findFirst(format(pathName, "*.*"), ffblk, _A_SUBDIR))
        repeat
            if ((ffAttr(ffblk) & _A_SUBDIR) and
                (substr(ffName(ffblk), 1, 1) <> "."))

                findDirs(format(pathName, ffName(ffblk), "\"))

            endif

        until (not findNext(ffblk))

    endif

end

// **************************************************************************
string proc strtran (string pcOrig, string pcFrom, string pcTo)
    integer     i = 1
    integer     n = Length(pcOrig)
    string      cRetval[ 18] = ""

    repeat
        case pcOrig[i]
            when pcFrom     cRetval = cRetval + pcTo
            otherwise       cRetval = cRetval + pcOrig[i]
        endcase
        i = i + 1
    until i > n
    return (cRetval)
end


// **************************************************************************
proc main ()

    if (ask("Enter File to find:", fileToFind) and length(fileToFind))

        fileToFind = upper(fileToFind)

        zipSearch()

        if (lLookInZip)
            // fix up the name of the file to find for regx
            zfileToFind = strtran(fileToFind,  ".", "\.")
            zfileToFind = strtran(zfileToFind, "?", ".")
            zfileToFind = strtran(zfileToFind, "*", ".*")
            origId    = getBufferId()
            zipBuffer = createTempBuffer()
        endif

        // start in root and work out
        findDirs("\")
        updateDisplay(_DEFAULT_)

        if (lLookInZip)
            abandonfile(zipBuffer)
            gotobufferid(origId)
        endif

    endif

end
