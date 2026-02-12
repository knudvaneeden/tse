/* This is an example file for calling interrupts using Intr() function */

#include "intr.inc"

proc SetMouseTextCursor(string char)
    if (Query(MouseEnabled))    // make sure mouse is enabled
        HideMouse()             // hide mouse to avoid mouse "droppings"
                                // when the change is made
        _AX = 10                // Mouse Function number
        _BX = 0                 // Set TEXT cursor
        _CX = 0xff00            // Screen mask
        _DX = asc(char[1])      // Cursor mask
        Intr(_FLAGS, 0x33)

        ShowMouse()
    endif
end


/* Build a directory in a file */

proc Int21()                    // common proc for DOS interrupts
    Intr(_FLAGS, 0x21)
end

proc BuildDirectory()

    // make space for dta and initialize to 128 nulls
    // the dta is only set propertly within this procedure.
    // once the procedure is completed, the dta can no longer
    // be assumed valid

    string dta[128] = format('':128:chr(0))

    // NOTE: fn must be a max length of 13 since filenames
    // can be up to 12 characters followed by a null terminate
    // Also, the 'fn' passed in as a file specification must be
    // null terminated

    string fn[13] = "*.*" + chr(0)

    _AX = 0x1a00            // set AH to 0x1a (set DTA call)
    _DS = StrSeg(dta)       // DS points to Segment of variable 'dta'
    _DX = StrOff(dta)       // DX points to Offset of variable 'dta'
    Int21()                 // Call DOS interrupts 0x21

    if not (_FLAGS & flCARRY)

        _AX = 0x4e00            // Set AH to 0x4e for FindFirst
        _CX = 0                 // Set attribute byte to zero
        _DS = StrSeg(fn)        // Points DS:DX to wildcard spec *.*
        _DX = StrOff(fn)
        Int21()                 // Call DOS interrupts 0x21

        while not (_FLAGS & flCARRY)
            // The filename is up to 12 characters but is always followed
            // by a null terminate ==> 13 characters needed
            // load fn with null terminated filename
            fn = substr(dta, 31, 13)
            // clear all information after the null
            fn = substr(fn,1,pos(chr(0), fn))

            Addline(fn)             // add line to file

            _AX = 0x4f00            // Set AH to 0x4f for FindNext
            Int21()                 // Call DOS interrupts 0x21
        endwhile

    endif


end


<f1>    BuildDirectory()
<f2>    SetMouseTextCursor('%')
