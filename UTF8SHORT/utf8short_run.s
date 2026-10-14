// UTF8SHORT 1.0.0.0.4 - OpenAI Codex (GPT-6).
// ASCII source. No clipboard conversion and no file renaming.
#include ["utf8short.inc"]

proc Main()
    string methodS[1] = "1"
    string inputS[255] = ""
    string pathS[255] = ""
    string messageS[255] = ""
    integer statusI = 0
    integer indexI = 1
    integer byteI = 0

    if Ask("1=Unicode Windows file picker, 2=raw UTF-8 pathname:",
           methodS, _EDIT_HISTORY_)
        if methodS == "1"
            statusI = UniSelect(GetWinHandle())
        elseif methodS == "2"
            if Ask("Raw UTF-8 pathname (no surrounding quotes):",
                   inputS, _EDIT_HISTORY_)
                statusI = UniFromUtf8(inputS)
            endif
        else
            messageS = "Choose 1 or 2."
        endif

        if statusI == 1
            byteI = UniByte(indexI)
            while byteI <> 0 and indexI <= 255
                pathS = pathS + Chr(byteI)
                indexI = indexI + 1
                byteI = UniByte(indexI)
            endwhile
            if EditFile(pathS)
                messageS = "ASCII path passed to TSE: " + pathS
            else
                messageS = "TSE could not open ASCII path: " + pathS
            endif
        elseif statusI == -1
            messageS = "Windows API error: " + Str(UniError())
        elseif statusI == -2
            messageS = "No all-ASCII short path exists for this file."
        elseif statusI == -3
            messageS = "The returned path exceeds SAL's 255-byte limit."
        elseif statusI == -4
            messageS = "Invalid UTF-8 pathname. Windows error: " + Str(UniError())
        elseif statusI == -5
            messageS = "Select a file, not a directory."
        endif
    endif

    if Length(messageS) > 0
        Warn("UTF8SHORT 1.0.0.0.4 - ", messageS)
    endif
end
