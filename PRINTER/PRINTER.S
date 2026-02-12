/**********************************************************************
   This file contains a number of miscellaneous printer functions.
   These take advantage of the binary procedure CheckPrinterStatus()
   to check printer status before attempting to pass data to it.

 Revision history:

    1.0      8 JUN 93   Original
 **********************************************************************/



binary "CHKPRN.BIN"    // uses BIOS int 17h, fn 2.  See CHKPRN.ASM
    integer proc CheckPrinterStatus(integer p) : 0
end



// PrinterReady()
/* Gets printer device name and calls binary procedure to check
   port status.  Returns TRUE if printer ready and FALSE on error. */

integer proc PrinterReady()
    integer p
    case Query(PrintDevice)     // get print device name
        when "prn", "lpt1"      // if PRN or LPT1
            p = 0               //  printer number = 0
        when "lpt2"             // if LPT2
            p = 1               //  printer number = 1
        when "lpt3"             // if LPT3
            p = 2               //  printer number = 2
        when "lpt4"             // if LPT4
            p = 3               //  printer number = 3

    /* if not one, of these, we assume that the print device is
       a file name rather than a predefined DOS device name.  Simply
       return PrinterReady() = TRUE under this condition, and let the
       editor's own open/close/write functions handle the error if
       the file name is invalid. */

        otherwise
            return (TRUE)
    endcase

    return (CheckPrinterStatus(p))      // return the port status
end



proc PrinterWarning()
    warn("Printer offline or unavailable: ")
end



// mPrintBlock() is a replacement for the built-in PrintBlock() command.
/* It checks printer status before attempting to print and displays a
   warning message if the printer is not ready.  Returns TRUE on success
   and FALSE on error. */

integer proc mPrintBlock()
    if PrinterReady()
        return (PrintBlock())
    endif
    PrinterWarning()
    return (FALSE)
end



// mPrintChar() is a replacement for the built-in PrintChar() command.
/* It checks printer status before attempting to send the character
   and displays a warning message if the printer is not ready. */

integer proc mPrintChar(string s)
    if PrinterReady()
        return (PrintChar(s))
    endif
    PrinterWarning()
    return (FALSE)
end



// mPrintFile() is a replacement for the built-in PrintFile() command.
/* It checks printer status before attempting to print and displays a
   warning message if the printer is not ready.  Returns TRUE on success
   and FALSE on error. */

integer proc mPrintFile()
    if PrinterReady()
        return (PrintFile())
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
/* It checks the printer status before attempting to print.  Returns
   TRUE on success and FALSE on error. */

integer proc SendPrintString(string s)
    if PrinterReady()
        PrintString(s)
        return (TRUE)
    endif
    PrinterWarning()
    return (FALSE)
end
