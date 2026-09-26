/* ========================================================================

  OS2START.S  Macro to start any program when running under OS/2

  Author:     Dr. Sieghard Schicktanz, Kreidestr. 12, 8196 Achmuehle

  Date:       Apr 22, 1995 - First released version
              Sep 17, 1995 - Improved version, accepts macro command line

  Overview:

  This macro will start any program
  - Dos, OS/2 text, OS/2 PM, when running TSE under OS/2

  Keys:
      INSTALL_KEY       installs / deinstalls stater function
      START_PROG_KEY    invokes starter function interactively
      START_HELP_KEY    displays instruction window

  Usage notes:

  Will only work for TSE 2.5 or later!
  This improved version accepts a macro command line supplying all neccessary
  arguments. The syntax is (command line only!):

    {-<Options> }<ProgPath>{ <Parameters>}

  where:

    {-<Options>}       program start up options
                       as specified in the help window (see below)
                       (must be preceded by a dash!)
    <ProgPath>         path of the program to be started
                       the extension ".exe" may be omitted
    { <Parameters>}    optional parameters for the program
                       (note the leading space!)

***************************************************************************

TREVOR@wordperfect.com

Below is a dinky program to start a os/2 program from a os/2 dos window.
It's pretty ugly right now, but it works fairly well.  I dug this up by
debugging VIEW.EXE, so there may be errors or omissions.  Anyone can have
this, feel free to mutilate it in any way you wish.

S. Schicktanz:

I took the freedom to translate the Pascal version I made that into, which
I had enhanced somewhat before already to allow for more versatility than
provided by the original version.

=========================================================================== */

// Constant strings - cannot be specified directly under "constant" heading
  string CMDname [14] = 'C:\OS2\CMD.EXE'    // OS/2 command processor name

constant
  // Keys
  INSTALL_KEY =    <Ctrl \>,                // also deinstalls
  START_PROG_KEY = <CtrlShift F9>,          // was <Ctrl F8>,
  START_HELP_KEY = <CtrlShift F8>,

  // NULL pointer
  NIL = 0,

  // Related
  //  New session is an independent session
  SSF_RELATED_INDEPENDENT = 0,
  //  New session is a child session
  SSF_RELATED_CHILD =       1,

  // FgBg
  //  Start session in foreground
  SSF_FGBG_FORE =           0,
  //  Start session in background
  SSF_FGBG_BACK =           1,

  // TraceOpt
  //  No trace
  SSF_TRACEOPT_NONE =       0,
  //  Trace with no notification of descendants
  SSF_TRACEOPT_TRACE =      1,
  //  Trace all descendant sessions
  SSF_TRACEOPT_TRACEALL =   2,

  // InheritOpt
  //  Inherit the Shell's environment.
  SSF_INHERTOPT_SHELL =     0,
  //  Inherit the environment of the program
  SSF_INHERTOPT_PARENT =    1,

  // SessionType
  //  Use the PgmHandle data, or allow the Shell
  SSF_TYPE_DEFAULT =        0,
  //  Start the program in a full-screen session.
  SSF_TYPE_FULLSCREEN =     1,
  //  Start the program in a windowed session
  SSF_TYPE_WINDOWABLEVIO =  2,
  //  Start the program in a PM windowed session
  SSF_TYPE_PM =             3,
  //  Start the program in a full-screen DOS session.
  SSF_TYPE_VDM =            4,
  //  Start the program in a windowed DOS session.
  SSF_TYPE_WINDOWEDVDM =    7

/* TYPE
  StartData = RECORD                      // Offset
                Length,                   //   0
                Related,                  //   2
                FgBg,                     //   4
                TraceOpt:      word       //   6
                PgmTitle,                 //   8
                PgmName,                  // $0C 12
                PgmInputs,                // $10 16
                TermQ:         PChar      // $14 20
                Environment:   pointer    // $18 24
                InheritOpt:    word       // $1C 28
                SessionType:   word       // $1E 30
              END                         // $20 32
*/
constant  // structure offsets for string insertion
//  Length - string length word used here
//  further offsets are string indices, calculated as
//      structure offset (as above)- 2+ 1 (for first string position)
    Related =      1,
    FgBg =         3,
    TraceOpt =     5,
    PgmTitle =     7,
    PgmName =     11,
    PgmInputs =   15,
    TermQ =       19,
    Environment = 23,
    InheritOpt =  27,
    SessionType = 29


string proc asPointer (integer Pointer)
    return (chr (LoByte (LoWord (Pointer)))+
            chr (HiByte (LoWord (Pointer)))+
            chr (LoByte (HiWord (Pointer)))+
            chr (HiByte (HiWord (Pointer))))
end

string proc asWord (integer Value)
    return (chr (LoByte (Value))+ chr (HiByte (value)))
end

HelpDef StartOS2Help

    title =  "Help on 'Start an OS/2 program'"
    width =  62
    height = 12
    x =       8
    y =       4

    ' Usage:'
    '       <OS2Prog> <program parameters>'
    ' Options:'
    '       F    start the session in Foreground (default).'
    '       B    start the session in Background.'
    '       P    start the program in a PM windowed session.'
    '       D    start the program in a (full-screen) DOS session'
    '            (must precede W or S options).'
    '       W    start the program in a Windowed session.'
    '       S    start the program in a full-Screen session.'
    '       V    Verbosely display effective command line'
end

proc startOS2 (string Title, string Progname, string Params, string Options)
    integer i, verbose = FALSE, SType = SSF_TYPE_DEFAULT
    Register R
    string FName [255] = ProgName, PPars [255] = Params,
           Heading [60]= Title+ chr (0), NewProgram [32]

    // This variable must have a length of exactly 32 bytes,
    // as it serves as a data structure for passing all relevant parameters!
    NewProgram= asWord (SSF_RELATED_INDEPENDENT)+
                asWord (SSF_FGBG_FORE)+
                asWord (SSF_TRACEOPT_NONE)+
                asPointer (AdjPtr (Addr (Heading), 2))+
                asPointer (AdjPtr (Addr (FName), 2))+
                asPointer (NIL)+
                asPointer (NIL)+
                asPointer (NIL)+
                asWord (SSF_INHERTOPT_SHELL)+
                asWord (SSF_TYPE_DEFAULT)+ '  ' // <- 2 blanks are required!

    for i= 1 to Length (Options)
        case Upper (Options [i])
            when 'F'  // Start session in foreground.
                NewProgram [FgBg: 2]= asWord (SSF_FGBG_FORE)

            when 'B'  // Start session in background.
                NewProgram [FgBg: 2]= asWord (SSF_FGBG_BACK)

            when 'W'  // Start the program in a windowed session
                if SType == SSF_TYPE_VDM
                    // Start the program in a windowed DOS session.
                    SType= SSF_TYPE_WINDOWEDVDM
                    NewProgram [SessionType:2]= asWord (SType)
                else
                    SType= SSF_TYPE_WINDOWABLEVIO
                    NewProgram [SessionType:2]= asWord (SType)
                endif

            when 'S'  // Start the program in a full-screen session.
                if SType <> SSF_TYPE_VDM
                    // Start the program in a full-screen session.
                    SType= SSF_TYPE_FULLSCREEN
                    NewProgram [SessionType:2]= asWord (SType)
                endif

            when 'P'  // Start the program in a PM windowed session
                SType= SSF_TYPE_PM
                NewProgram [SessionType:2]= asWord (SType)

            when 'D'  // Start the program in a full-screen DOS session.
                SType= SSF_TYPE_VDM
                NewProgram [SessionType:2]= asWord (SType)
                NewProgram [InheritOpt: 2]= asWord (SSF_INHERTOPT_PARENT)

            when 'V'
                verbose= TRUE
        endcase
    endfor

    if FName == '*'
        if (SType == SSF_TYPE_VDM) or (SType == SSF_TYPE_WINDOWEDVDM)
            FName= GetEnvStr ('COMSPEC')
        else
            FName= CMDname
        endif
    else
        if FName == 'CMD'
            FName= CMDname
        else
            if FName == 'COMMAND'
                FName= GetEnvStr ('COMSPEC')
            endif
        endif
    endif

    if (Pos ('.EXE', FName) == 0) and (Pos ('.COM', FName) == 0)
        if Pos ('.', FName) == 0
            FName= FName+ '.EXE'
        endif
    endif

    FName= Upper (ExpandPath (FName))+ chr (0)

    if Params <> ''
        PPars= PPars+ chr (0)
        NewProgram [PgmInputs:4]= asPointer (AdjPtr (Addr (PPars), 2))
    endif

    R.AX= 0x6400
    R.BX= 0x0025
    R.CX= 0x636C
    R.SI= Ofs (NewProgram)
    R.DS= Seg (NewProgram)
    Intr (0x21, R)

    if verbose
        Message ('"', FName, ' ', PPars, '" started')
    endif
end

proc StartOS2Prog ()
    string Progname [60], Params [255] = '', Options [10] = ''

    if Ask ('Program to start', Params, _DOS_HISTORY_)
        Ask ('Options [FB DP WS V]', Options)

        if NumTokens (Params, ' ') > 1
            ProgName= GetToken (Params, ' ', 1)
            Params= SubStr (Params, Length (ProgName)+ 2, 255)
        else
            ProgName= Params
            Params= ''
        endif

        startOS2 (Upper (Progname), Progname, Params, Options)
    endif
end

forward proc DisableOS2Starter ()

KeyDef OS2Starter
    <INSTALL_KEY>       DisableOS2Starter ()
    <START_PROG_KEY>    StartOS2Prog ()
    <START_HELP_KEY>    QuickHelp (StartOS2Help)
end

proc EnableOS2Starter ()
    Message ('OS/2 Program starter installed')
    Enable (OS2Starter)
end

proc DisableOS2Starter ()
    Message ('OS/2 Program starter removed')
    Disable (OS2Starter)
end

<INSTALL_KEY>           EnableOS2Starter ()


proc WhenLoaded ()
    string Options [8] = ''
    string CmdLine [128] = ''
    string ProgName [128] = Query (MacroCmdLine)
    integer Separator

    if ProgName <> ''
        Separator= Pos ('-', ProgName)
        if Separator == 1           // there are Options...
            Separator= Pos (' ', ProgName)
            Options=  Upper (ProgName [2..Separator-1]) // separate options
            ProgName= ProgName [Separator+ 1..255]      // Rest
        endif
        Separator= Pos (' ', ProgName)                  // program parameters?
        if Separator == 0                               // no
            ProgName= Lower (ProgName)
        else                                            // yes, strip off
            CmdLine=  ProgName [Separator+ 1..255]      // Rest
            ProgName= Lower (ProgName [1: Separator-1])
        endif
        startOS2 ('StartOS2', ProgName, CmdLine, Options)
    endif
    PurgeMacro (CurrMacroFileName ())
end

proc Main ()
    WhenLoaded ()
end