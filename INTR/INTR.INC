/*  INTR.INC --- include file for TSE macros to access Interrupt calls
                 w/o the need for assembly interfacing

    Author:  Steve Watkins
             Semware
    Date:    04-13-93

    DO NOT MODIFY THIS FILE.  Simply include it with any
    macros you wish to access interrupts.

    Intr.inc is a simple interface file for calling interrupts
    without having to write assembly modules.

    The user may set any of the following variables before calling
    the Intr() function:

    _AX, _BX, _CX, _DX, _SI, _DI, _BP, _ES, and _DS

    The following registers are not modifiable:

    cs, ip, ss, sp

    Upon calling Intr(), the registers are loaded with the low-order
    words of the appropriate TSE variables. When the specified
    interrupt completes, the low order words of the TSE variables
    are loaded with their corresponding registers.  The high order
    words of the TSE variables are set to zero.  Thus, the TSE
    interrupt variables are treated as unsigned.

    For example, if an interrupt call sets ax to 0xffff, _AX is set
    to 0xffff, not -1.

    The TSE variable _FLAGS serves a unique role.

        (1) _FLAGS must be passed as the first parameter to Intr()
        (2) _FLAGS is only set by the flags returned by the specified
            interrupt call.  _FLAGS are not set before the interrupt
            call itself.

        _FLAGS contains bit encoded flags which correspond to the
        constants defined below.


    A few helper functions are also provided:

        IntSeg()    Segment of an integer variable
        IntOff()    Offset of an integer variable
        StrSeg()    Segment of a string
        StrOff()    Offset of a string

    Note: When setting pointers using these helper function be aware
    that the segment:offset of a string variable points to
    the actual string data and does NOT include or modify the
    strings length.  Since most interrupts return an ASCIIZ string
    (a null terminated string), the variables referenced when passed
    in must have a null terminate on the end.  Similarly, when a string
    is pointed to for returning information, be aware that since the
    length word for strings is not modified, the user must pre-initialize
    the string to its maximum length in order to access the string
    within TSE.

    For example:

        To set the DTA, DS:DX must be set to a buffer area of at least 128
        bytes.  Once the DTA is set and FindFirst/FindNext is called,
        the filename is at offset 31 within the specified dta string.
        If the dta string was never initialized to 128 characters,
        functions such as Length(), Pos(), SubStr(), etc. will have an
        invalid length of the string.  Thus, in order to insure that the
        string can be properly referenced, it must be pre-initialized to
        128 character.

        Here's a simple setting of the DTA designed for use with
        FindFirst/FindNext

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
        Intr(_FLAGS, 0x21)      // Call DOS interrupts 0x21

        if not (_FLAGS & flCARRY)

            _AX = 0x4e00            // Set AH to 0x4e for FindFirst
            _CX = 0                 // Set attribute byte to zero
            _DS = StrSeg(fn)        // Points DS:DX to wildcard spec *.*
            _DX = StrOff(fn)
            Intr(_FLAGS, 0x21)      // Call DOS interrupts 0x21

            while not (_FLAGS & flCARRY)
                // The filename is up to 12 characters but is always followed
                // by a null terminate ==> 13 characters needed
                // load fn with null terminated filename
                fn = substr(dta, 31, 13)
                // clear all information after the null
                fn = substr(fn,1,pos(chr(0), fn))

                Addline(fn)             // add line to file

                _AX = 0x4f00            // Set AH to 0x4f for FindNext
                Intr(_FLAGS, 0x21)      // Call DOS interrupts 0x21
            endwhile

        endif

*/

// DO NOT CHANGE THE ORDER OR LOCATION OF THESE VARIABLES
integer _FLAGS,_AX,_BX,_CX,_DX,_SI,_DI,_BP,_ES,_DS

constant flOVERFLOW     =   0000100000000000b
constant flDIRECTION    =   0000010000000000b
constant flINTERRUPT    =   0000001000000000b
constant flTRAP         =   0000000100000000b
constant flSIGN         =   0000000010000000b
constant flZERO         =   0000000001000000b
constant flAUX          =   0000000000010000b
constant flPARITY       =   0000000000000100b
constant flCARRY        =   0000000000000001b

binary ["intr.bin"]
    integer proc IntOff(var integer n)                  :   0
    integer proc IntSeg(var integer n)                  :   2
    integer proc StrOff(string s)                       :   4
    integer proc StrSeg(string s)                       :   2
    proc Intr(var integer FLAGS, integer INTERRUPT_NO)  :   6
end

// Intr() must be called with _FLAGS passed as the first parameter.
