/**********************************************************************
   TSE printer wrappers. Printing results come from TSE print commands.
   See PRINTER_DOS.S for the original 1993 BIOS-dependent version.

 Revision history:

    1.0      8 JUN 93   Original
 **********************************************************************/

// Package version 1.0.0.0.0. Keep printer.ini in the current directory.
proc Main()
    string silentS[10] = GetProfileStr("Settings", "silent", "false", "printer.ini")
    if Lower(silentS) <> "true"
        Warn("PRINTER 1.0.0.0.0: printer wrappers for TSE. " +
             "Include PRINTER.INC in your UI and PRINTER.S in its source. " +
             "Read printer_readme.md for setup and limitations.")
    endif
end



// TSE's built-in print operations report their own success or failure.
// A preflight port check is unavailable for modern printer queues.

// PrinterReady()
/* Retained for source compatibility. A modern print queue has no
   reliable port preflight check; print commands report failures. */

integer proc PrinterReady()
    // Status cannot be reliably predicted for a modern print queue.
    // The printing operation itself supplies the definitive result.
    return (TRUE)
end


proc PrinterWarning()
    warn("Printer operation failed or printer unavailable.")
end



// mPrintBlock() is a replacement for the built-in PrintBlock() command.
/* Prints and returns TRUE on success; warns and returns FALSE on error. */

integer proc mPrintBlock()
    if PrintBlock()
        return (TRUE)
    endif
    PrinterWarning()
    return (FALSE)
end



// mPrintChar() is a replacement for the built-in PrintChar() command.
/* Sends the character and warns if TSE reports a print failure. */

integer proc mPrintChar(string s)
    if PrintChar(s)
        return (TRUE)
    endif
    PrinterWarning()
    return (FALSE)
end



// mPrintFile() is a replacement for the built-in PrintFile() command.
/* Prints and returns TRUE on success; warns and returns FALSE on error. */

integer proc mPrintFile()
    if PrintFile()
        return (TRUE)
    endif
    PrinterWarning()
    return (FALSE)
end



// PrintString() prints a string using repeated calls to PrintChar().
/* It does NOT check printer status.  It is intended as a helper
   function for procedures that check the printer ahead of this call.
   Any error handling is provided by the built-in PrintChar() command. */

proc PrintString(string s)
    integer i = 1
    while i <= Length(s) and PrintChar(s[i])
        i = i + 1
    endwhile
end



// SendPrintString() is a stand-alone string print procedure.
/* Sends the string and reports a failed character print. */

integer proc SendPrintString(string s)
    integer iI = 1
    while iI <= Length(s)
        if not PrintChar(s[iI])
            PrinterWarning()
            return (FALSE)
        endif
        iI = iI + 1
    endwhile
    return (TRUE)
end
