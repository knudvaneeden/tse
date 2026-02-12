/****************************************************************************\

  TseSHelp.S

  Help screen for TseShell.

  Version         0.99/15.04.96

  Copyright       (c) 1995 by DiK
                  (c) 1996 rewrite 0.99 Dr. S. Schicktanz

\****************************************************************************/

/****************************************************************************\
    help screen
\****************************************************************************/

helpdef ShellHelp
    title = "Help on TseShell"
    x = 6
    y = 3
    width = 68
    height = 19

    ""
    " General remarks"
    " ---------------"
    ""
    " Any line in this buffer can be used as a command to be executed."
    " Commands will also be stored in the Dos command history list."
    ""
    " A special key assignment allows even for execution of single or"
    " multiple ('batched') commands from a normal editing buffer."
    ""
    " Program output (if not written directly to screen memory) will"
    " be captured to this buffer, so it can be editied, modified or"
    " copied to another place."
    ""
    " Although it is possible to execute Dos batch files, an internal"
    " 'batch' function allows for simple execution of multiple Dos"
    " commands. It is used if a block is marked in the current buffer"
    " (usually, the TseShell buffer) and the Execute key is pressed."
    " All lines within this block will be executed in sequence as"
    " Dos commands."
    ""
    " Additional features"
    " -------------------"
    ""
    " All Dos commands will be stored in the Dos history, from where"
    " they can be recalled at any time while in the TseShell buffer"
    " (and from the Dos command dialog box, of course)."
    " The method for command recall can be selected through the setup"
    " dialog. The 'floating window' select box is also available via"
    " a special key."
    " In addition, the Edit file history can be called to enter a"
    " a file name at any place."
    " File names can also be selected from a pick list."
    ""
    " Internal commands"
    " -----------------"
    ""
    " A few commands are implemented internally in TseShell to speed"
    " up a few things. All editing functions are available."
    ""
    "   cls         clear screen and empty buffer"
    "   cd          change directory"
    "   cdd         change directory and drive"
    "   cde         change directory to current editing dir"
    "   [a-z]:      fast change drive"
    "   path\       fast change directory and drive"
    "               (trailing '\' required!)"
    "   ..{.}       step up directory hierarchy -"
    "               using 4DOS' multiple dot nomenclature,"
    "               stepping up an additional level for every"
    "               additional dot."
    "               (This can be combined with fast change dir)"
    ""
    " Key bindings"
    " ------------"
    ""
    " To move the cursor within the screen buffer, use the normal"
    " cursor keys."
    ""
    " Executing commands"
    "   Enter               execute command or contents"
    "                       of marked block"
    "   Alt Enter           same function within editing buffer"
    ""
    " Command line editing"
    "   Ctrl Enter          reassignment of non-executing Enter"
    "                       (useful for splitting lines, e.g.)"
    "   Escape              delete command line"
    "   Alt Del             clear screen and buffer"
    ""
    " Histories / Selection boxes"
    "   Ctrl CursorUp,"
    "   Ctrl CursorDown     get last/next Dos history entry"
    "   Ctrl-Shift Up,"
    "   Ctrl-Shift Down     pop up Dos command history box"
    "   F2                  insert filename from Edit history"
    "   Ctrl F2             insert filename from pick list"
    ""
    " Miscellaneous"
    "   F1                  show this help"
    "   Ctrl F7             change to editing directory and drive"
    "   Alt F7              set editing directory to current"
    "   F9                  configuration menu"
    "   F11                 switch back to previous buffer"
    "                       (any command changing buffers does)"
    "   Alt X               unload TseShell (make buffer visible)"
    ""
end

/****************************************************************************\
    main program
\****************************************************************************/

proc main ()
    QuickHelp (ShellHelp)
    PurgeMacro (CurrMacroFilename ())
end