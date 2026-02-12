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

    Version         v1.10/31.03.96
    Copyright       (c) 1996 by DiK

    History
    v1.10/31.03.96  removed changing the machine title
    v1.00/26.03.96  first release

\****************************************************************************/

/****************************************************************************\
    constant

    WARNING:
    Do NOT change this values! It is the limit of the Win95 API!
\****************************************************************************/

constant MAX_APP_TITLE_LEN = 80

/****************************************************************************\
    idle handler
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
    changing files handler
\****************************************************************************/

proc ChangeHook()
    register r
    string fname[128] = CurrFilename()

    if Length(fname) >= MAX_APP_TITLE_LEN   // limit size of title
        fname = fname[1..MAX_APP_TITLE_LEN-4] + "..."
    endif

    fname = fname + Chr(0)                  // terminate with NULL

    r.ax = 0x168E                           // Set Application Title
    r.dx = 0x0000
    r.di = Ofs(fname)+2
    r.es = Seg(fname)
    Intr(0x2F,r)
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

    r.ax = 0x168F                           // Enable Close
    r.dx = 0x0001
    Intr(0x2F,r)

    Hook(_IDLE_,IdleHook)                   // install event handlers
    Hook(_ON_CHANGING_FILES_,ChangeHook)
    Hook(_ON_ABANDON_EDITOR_,AbandonHook)
end

/****************************************************************************\
    setup
\****************************************************************************/

proc WhenPurged()
    register r

    r.ax = 0x168F                           // Disable Close
    r.dx = 0x0000
    Intr(0x2F,r)

    UnHook(IdleHook)                        // remove event handlers
    UnHook(ChangeHook)
    UnHook(AbandonHook)
end
