/*************************************************************************
  ANSI.S      ANSI Interpreter (Viewer) for TSE

  Author:     Dr. Sieghard Schicktanz, Kreidestr. 12, 8196 Achmuehle

  Date:       Sep 30, 1994 - Corrected version

  Overview:

  This macro is an attempt to create an ANSI view facility for TSE.
  It takes an ANSI coded file with lines of no more than 255 characters
  length and displays it in a video window, interpreting the ANSI
  control sequences interspersed in the text.

  Keys:       (none)

  Usage notes:

  This macro does not have any key assignments.
  There are a couple of limitations:
  - Lines may be no longer than 255 characters.
  - Not all ANSI sequences are supported, mainly PC specific ones
    are (intentionally) left out.
  - Scrolling is not supported.
  This is an update to a preliminary version which was not tested
  on cursor positioning commands and commands using default parameter
  values as defined in the ANSI specification. Those commands did not
  work properly then, which has been corrected.

*************************************************************************/

/* ANSI codes:

   Lead-in sequence:        <Esc>[

   Basic codes:

   clear screen     2J              clear to eol        K
   cursor up        <n>A            cursor down         <n>B
   cursor right     <n>C            cursor left         <n>D
   cursor position  <row>;<col>H    report cursor pos   6n
   save cursor pos  s               restore cursor pos  u
   set attributes   <n>m            set display mode    =<n>h
   enable wrapping  =7h             disable wrapping    =7l

   Codes for video attributes:

   0    no attribute (reset)
   1    high intensity              2    low intensity
   3    italic                      4    underline
   5    blink                       6    rapid blink
   7    reverse video               8    invisible text
   colors:
   30+<c>   foreground              40+<c>  background
   0    black                       1    red
   2    green                       3    yellow
   4    blue                        5    magenta
   6    cyan                        7    white

   Codes for display modes (IBM-PC only):

   0    40 x 25, 16 col text        1    40 x 25, 16 col text
   2    80 x 25, 16 col text        3    80 x 25, 16 col text
   (others not useful)
 */

constant StringSize = 255   /* TSE string variable size */
constant ANSImax = 12
constant ANSIhigh = 8       /* color attribute */
constant ANSIdefault = 7    /* color attribute */
constant ANSIblink = 128    /* blink attribute */
integer  WorkBuffer = 0
integer  ANSIx, ANSIy       /* stored cursor position */


integer proc ParamVal (VAR string ANSIcmd)
    integer result = 0

    if ('0' <= ANSIcmd [1]) and (ANSIcmd [1] <= '9')
        while ('0' <= ANSIcmd [1]) and (ANSIcmd [1] <= '9')
            result= 10* result+ (Asc (ANSIcmd)- 48) /* 48= Asc ('0') */
            ANSIcmd= SubStr (ANSIcmd, 2, ANSImax)
        endwhile
    else
        return (1)              /* default value if nothing specified */
    endif

    return (result)
end

integer proc MapColor (integer ANSIcolor)
/* because of the different bit assignment, color indices
   have to be remapped for use on a PC video system */

    case ANSIcolor
        when 0, 2, 5, 7         /* these do incidentally match */
            return (ANSIcolor)
        when 1
            return (4)          /* all others need to be changed */
        when 3
            return (6)
        when 4
            return (1)
        when 6
            return (3)
    endcase
    return (ANSIdefault)        /* just here to make SC happy... */
end

proc SetAttributes (VAR string AttribVals)
    integer P, A

    while AttribVals <> ''
        P= ParamVal (AttribVals)
        case P
            when 0
                Set (Attr, ANSIdefault)
            when 1
                Set (Attr, Query (Attr) | ANSIhigh)
            when 2
                Set (Attr, Query (Attr) & (ANSIhigh ^ 255))
            when 3, 4           /* not implemented... can't do it */
            when 5, 6           /* won't work on color displays, either */
                Set (Attr, Query (Attr) | ANSIblink)
            when 7
                A= Query (Attr)
                A= ((A shl 4) & 240) | ((A shr 4) & 15)
                Set (Attr, A)   /* the "magic" values here are designed */
            when 8              /* to mask out the bits that have to be */
                Set (Attr, 0)   /* replaced by new values from the ANSI */
            when 30..37         /* command's parameters */
                A= (Query (Attr) & 248) | MapColor (P- 30)
                Set (Attr, A)
            when 40..47
                A= (Query (Attr) & 143) | (MapColor (P- 40) shl 4)
                Set (Attr, A)
        endcase
        AttribVals= SubStr (AttribVals, 2, ANSImax)
    endwhile
end

proc ExecuteANSI (VAR string ANSIcmd)   /* processes one ANSI command */
    integer p
    string Identifier [1]

    Identifier = ANSIcmd [Length (ANSIcmd)]
    case Identifier
        when "A"
            p= WhereY ()-ParamVal (ANSIcmd)
            if p < 0
                p= 0
            endif
            GotoXY (WhereX (), p)
        when "B"
            p= WhereY ()+ParamVal (ANSIcmd)
            if p > Query (ScreenRows)
                p= Query (ScreenRows)
            endif
            GotoXY (WhereX (), p)
        when "C"
            p= WhereX ()+ParamVal (ANSIcmd)
            if p > Query (ScreenCols)
                p= Query (ScreenCols)
            endif
            GotoXY (p, WhereY ())
        when "D"
            p= WhereX ()-ParamVal (ANSIcmd)
            if p < 0
                p= 0
            endif
            GotoXY (p, WhereY ())
        when "H"
            p= ParamVal (ANSIcmd)
            ANSIcmd= SubStr (ANSIcmd, 2, ANSImax)
            GotoXY (ParamVal (ANSIcmd), p)
        when "J"
            ClrScr ()
        when "K"
            ClrEol ()
        when "h"                /* not implemented... too PC-specific */
        when "l"                /* not implemented... too PC-specific */
        when "m"
            SetAttributes (ANSIcmd)
        when "n"                /* not implemented... what for? */
        when "s"
            ANSIx= WhereX ()    /* this, of course, works only */
            ANSIy= WhereY ()    /* for a single level! */
        when "u"
            GotoXY (ANSIx, ANSIy)
    endcase
end

integer proc ANSIprocessed ()   /* will return true if file depleted ;-) */
    integer StartPos
    string ANSItext [StringSize] = ''

    BegLine ()

    repeat
        StartPos= CurrCol ()

        if lFind ('[', 'c')
            /* every thing upto the first ANSI command
               on the line must be plain text, just to
               be displayed using the current attributes */

            ANSItext= GetText (StartPos, CurrCol ()- StartPos)
            PutStr (ANSItext)
            GotoXY (WhereX ()+ Length (ANSItext), WhereY ())
            /* the cursor has to be put beyond the last character written */

            /* now let's extract the command. This must exist,
               because the lFind command reported so */

            Right (2)           /* skip lead in */
            ANSItext= ''
            StartPos= CurrCol ()
            while CurrChar () < Asc ('A')
                Right ()
            endwhile
            Right ()
            ANSItext= GetText (StartPos, CurrCol ()- StartPos)
            ExecuteANSI (ANSItext)

            /* this brought us beyond the command, so on
               a possible next iteration we will first
               encounter plain text to output directly */
        else
            /* if arrived here, we can be sure that there's
               no further command on this line, so we can
               take all the text left and output it directly */

            ANSItext= GetText (CurrCol (), StringSize)
            PutStr (ANSItext)
            EndLine ()          /* just to make sure... */
        endif
    until CurrChar () < 0       /* this will terminate at end of line */

    StartPos= WhereY ()+ 1      /* handle wrap around on next line */
    if StartPos > Query (ScreenRows)    /* no scrolling, what for? */
        StartPos= Query (ScreenRows)
    endif
    GotoXY (1, StartPos)        /* start at beginning of new line */

    return (not Down ())        /* skip the line just processed */
end

proc ProcessFile ()
    integer R = 0

    if PopWinOpen (1, 1, Query (ScreenCols), Query (ScreenRows),
                   Query (CurrWinBorderType), 'ANSI-Display',
                   Query (CurrWinBorderAttr))

        Set (Attr, ANSIdefault)
        GotoXY (1, 1)
        ClrScr ()

        repeat
            if KeyPressed ()
                R= GetKey ()
            endif
        until ANSIprocessed () or (R == <Escape>)

        Sound (660)             /* after building the display, */
        Delay (3)               /* give a ready cue and let the */
        NoSound ()              /* user have a chance to look at */
        GetKey ()               /* the picture as long as he desires */
        PopWinClose ()          /* before the window is removed */
    endif
end

proc DoneFile ()        /* this could be done at several places... */

    AbandonFile (WorkBuffer)
    WorkBuffer= 0
end

proc ReadFile (string FileName)

    WorkBuffer= EditFile (FileName)

    if WorkBuffer
        GotoBufferId (WorkBuffer)
        BufferType (_SYSTEM_)   /* don't show the file contents */
        ProcessFile ()          /* as the display is built indirectly */
        DoneFile ()
    endif
end

proc main ()
    ReadFile ('')
end