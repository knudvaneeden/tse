/*
   File       : cursorfix.s
   Purpose    : Restore TSE's blinking text cursor, with a DLL fallback.
   Version    : 1.0.0.0.4
   Date       : 2026-09-03
   LLM        : OpenAI GPT-5.6
*/

DLL "cursorfix.dll"
    INTEGER PROC ForceCursorFix()
END

PROC Main()
    INTEGER resultI = 0

    /* A size of zero explicitly makes the cursor invisible. */
    IF ( Query( InsertCursorSize ) == 0 )
        Set( InsertCursorSize, 4 )
    ENDIF

    IF ( Query( OverwriteCursorSize ) == 0 )
        Set( OverwriteCursorSize, 2 )
    ENDIF

    /* Reinitialize TSE's own cursor-visible state. */
    Set( Cursor, OFF )
    Set( Cursor, ON )

    UpdateDisplay( _ALL_WINDOWS_REFRESH_ )

    /*
       SAL cannot inspect the pixels to determine whether the cursor is now
       visible. The DLL call is therefore always made as the fallback step.
       It returns immediately without changing the ShowCaret count when
       Windows already reports that the caret is blinking.
    */
    resultI = ForceCursorFix()

    IF ( resultI < 0 )
        Warn( "The TSE cursor reset was performed, but the DLL did not find ",
              "a recoverable Win32 caret. Result = ", resultI )
    ELSE
        UpdateDisplay( _ALL_WINDOWS_REFRESH_ )
    ENDIF
END

<CtrlAlt C> Main()
