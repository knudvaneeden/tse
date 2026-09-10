//  Macro to display the current character in HEX, and allow value to be
//  modified in hex.

Proc InsertHex()
    string hex[3] = ""
    integer i

    hex = str(currchar(), 16)
    if ask("Hex Value at Cursor: ", hex)
        if hex == "0"
            InsertText(chr(0))
        else
            i=val(hex,16)
            if i <> 0
                InsertText(chr(i))
            else
                alarm()
                message("Non-Hex Input.")
            endif
        endif
    endif

end

<F3> InsertHex()
