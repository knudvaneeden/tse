/****************************************************************************\

    Win95Xit.S

    Make TSE close sensitive while running in a Win95 window.

    Overview:

    This macro shuts down TSE, if it is running in a windowed session
    under Win95 after the user has chosen the Close command or pressed
    the Close button. Moreover, it displays the current filename as the
    title of the window. Consult the DOC file for more information.

    Keys:
            <none>

    Usage notes:

    You must add Win95Xit to TSE's autoload list.

    Version         v1.20/08.05.96
    Copyright       (c) 1996 by DiK

    History
    v1.20/08.05.96  added: displays long filenames
                    fixed: uses _after_update_statusline_ hook
                    fixed: clear application title when purged
                    fixed: checking for Windows 95
    v1.10/31.03.96  removed changing the machine title
    v1.00/26.03.96  first release

    Acknowledgements:
    þ thanks to Chris Antos for suggestions

\****************************************************************************/

/****************************************************************************\
    constants

    WARNING:
    Do NOT change this value! It is the limit of the Win95 API!
\****************************************************************************/

constant MAX_APP_TITLE_LEN = 80

/****************************************************************************\
    global variables
\****************************************************************************/

integer buff

string prev_name[255]
string long_name[255]

/****************************************************************************\
    set the vm's application title
\****************************************************************************/

proc SetApplicationTitle()
    register r

    r.ax = 0x168E                           // Set Application Title
    r.dx = 0x0000
    r.di = Ofs(long_name)+2
    r.es = Seg(long_name)
    Intr(0x2F,r)
end

/****************************************************************************\
    translate short alias to long filename
\****************************************************************************/

proc GetLongPathName()
    register r
    integer bid
    integer pntr_name, pntr_long

    bid = GotoBufferId(buff)

    AddLine(prev_name)                  // arg(1) = alias name
    EndLine()
    InsertText(Chr(0))
    pntr_name = CurrLinePtr()

    AddLine()                           // arg(2) = buffer for long name
    GotoColumn(260)
    InsertText(Chr(0))
    pntr_long = CurrLinePtr()

    r.ax = 0x7160                       // Get Long Path Name
    r.cx = 0x8002                       // subst'ed long path names
    r.si = LoWord(pntr_name)
    r.ds = HiWord(pntr_name)
    r.di = LoWord(pntr_long)
    r.es = HiWord(pntr_long)
    Intr(0x21,r)

    if r.flags & _flCARRY_              // check result
        long_name = prev_name
    else
        lFind(Chr(0),"cg")              // find end of string
        KillToEol()
        long_name = GetText(1,254)
    endif
    long_name = long_name + Chr(0)

    EmptyBuffer()
    GotoBufferId(bid)
end

/****************************************************************************\
    changing files handler

    REMARK:
    don't update status line, so both filenames can be seen
\****************************************************************************/

proc StatLineHook()
    string name[255] = CurrFilename()

    if name <> prev_name
        if Length(name) >= MAX_APP_TITLE_LEN
            name = name[1..MAX_APP_TITLE_LEN-4] + "..."
        endif
        prev_name = name
        GetLongPathName()
        SetApplicationTitle()
    endif
end

/****************************************************************************\
    idle handler (watch close button)
\****************************************************************************/

proc IdleHook()
    register r

    r.ax = 0x168F                           // Query Close
    r.dx = 0x0100
    Intr(0x2F,r)

    if r.ax == 0                            // closed
        r.ax = 0x168F                       // Acknowledge Close
        r.dx = 0x0200
        Intr(0x2F,r)

        ExecMacro("QuickXit")               // let's get out of here

        if NumFiles()                       // oops, user canceled something
            r.ax = 0x168F                   // Cancel Close
            r.dx = 0x0300
            Intr(0x2F,r)
        endif
    endif
end

/****************************************************************************\
    trap exit
\****************************************************************************/

proc AbandonHook()
    WhenPurged()
end

/****************************************************************************\
    setup
\****************************************************************************/

proc WhenLoaded()
    register r
    integer rc
    integer bid

    r.ax = 0x3000                           // get dos version
    Intr(0x21,r)
    rc = LoByte(r.ax) >= 7
    if rc
        r.ax = 0x4A33                       // check for ms-dos
        Intr(0x2F,r)
        rc = r.ax == 0
        if rc
            r.ax = 0x1600                   // get windows version
            Intr(0x2F,r)
            rc = r.ax <> 0x1600 and LoByte(r.ax) < 0x80 and LoByte(r.ax) >= 4
        endif
    endif

    if not rc                               // dos mode or old dos
        PurgeMacro(CurrMacroFilename())
        return()
    endif

    bid = GetBufferId()                     // alloc work space
    buff = CreateTempBuffer()
    if not buff
        Warn("Win95Xit: cannot allocate work space")
        PurgeMacro(CurrMacroFilename())
        return()
    endif
    GotoBufferId(bid)

    r.ax = 0x168F                           // Enable Close
    r.dx = 0x0001
    Intr(0x2F,r)

    Hook(_IDLE_,IdleHook)                   // install event handlers
    Hook(_ON_ABANDON_EDITOR_,AbandonHook)
    Hook(_AFTER_UPDATE_STATUSLINE_,StatLineHook)
end

/****************************************************************************\
    setup
\****************************************************************************/

proc WhenPurged()
    register r

    if buff == 0                            // error while loading ?
        return()
    endif

    r.ax = 0x168F                           // Disable Close
    r.dx = 0x0000
    Intr(0x2F,r)

    long_name = Chr(0)                      // clear application title
    SetApplicationTitle()

    UnHook(IdleHook)                        // remove event handlers
    UnHook(AbandonHook)
    UnHook(StatLineHook)

    AbandonFile(buff)                       // free work space
end

