/****************************************************************************\

    KeyAssgn.S

    Help for keyboard assignments

    Displays a popup window and asks the user to hit any key.
    The user-selected UI source and the on-disk .S sources of
    currently loaded macros are searched for the translated key
    code.  The corresponding command and comment are displayed.

    Package version 1.0.0.0.39/15.09.2026
    Based on        v3.01/18.04.97
    Modified with   OpenAI Codex
    Copyright       (c) 1993-96 by DiK

    History
    1.0.0.0.39/15.09.2026
                    do not show searched source paths by default
    1.0.0.0.36/15.09.2026
                    add preferred Windows and Linux editable path defaults
                    optionally show source paths in a temporary buffer only
    1.0.0.0.30/14.09.2026
                    widen output popup to the available screen width
    1.0.0.0.29/14.09.2026
                    add Windows, WSL Linux, and native Linux support
    1.0.0.0.28/14.09.2026
                    restore UI fallback and key-assignment popup
    1.0.0.0.27/14.09.2026
                    trim leading record space before GetToken
    1.0.0.0.26/14.09.2026
                    extract first fixed-record field with GetToken
    1.0.0.0.25/14.09.2026
                    load sources from normalized parsed macro list
    1.0.0.0.24/14.09.2026
                    stop macro name at first whitespace using GetText
    1.0.0.0.23/14.09.2026
                    persist per-macro load trace before possible crash
    1.0.0.0.22/14.09.2026
                    diagnostic load of all resolved macro sources
    1.0.0.0.21/14.09.2026
                    diagnostic load of one resolved macro source
    1.0.0.0.20/14.09.2026
                    search direct TSEPath directories before mac subdirs
    1.0.0.0.19/14.09.2026
                    diagnostic pathname resolution for one macro
    1.0.0.0.18/14.09.2026
                    parse displayed list lines with bounded GetText
    1.0.0.0.17/14.09.2026
                    diagnostic stop after parsing captured macro names
    1.0.0.0.16/14.09.2026
                    diagnostic stop immediately after macro-list capture
    1.0.0.0.15/14.09.2026
                    read plain displayed macro names from column 1
    1.0.0.0.14/13.09.2026
                    safely extract names from raw or plain list records
    1.0.0.0.13/13.09.2026
                    process the captured visible list without raw decoding
    1.0.0.0.12/13.09.2026
                    use the supplied working NewFile/list_startup pattern
    1.0.0.0.11/13.09.2026
                    restore the normal user buffer before Main runs
    1.0.0.0.10/13.09.2026
                    preserve the marked live macro list until CopyBlock
    1.0.0.0.9/13.09.2026
                    refresh loaded macros from Main, not WhenLoaded
    1.0.0.0.8/13.09.2026
                    force TSE to rebuild the loaded-macro list before capture
    1.0.0.0.7/13.09.2026
                    search loaded macro sources before the UI source
    1.0.0.0.6/13.09.2026
                    show the full source filename of the key definition
    1.0.0.0.5/13.09.2026
                    resolve constant NAME = <key> followed by <NAME>
    1.0.0.0.4/13.09.2026
                    show the saved search-path buffer after Escape
    1.0.0.0.3/13.09.2026
                    write searched source paths in search order to
                    keyassgn_search_paths.txt in the current directory
    1.0.0.0.2/13.09.2026
                    search the current directory first for macro sources
    1.0.0.0.1/13.09.2026
                    ask for the UI source file
                    search the .S sources of all loaded macros
    v3.01/18.04.97  adaption for public release
    v3.00/22.10.96  adaption to TSE32
    v2.11/09.02.96  adaption new ui
    v2.10/18.09.95  adaption to v2.5 of TSE
    v2.00/28.10.94  adaption to v2.0 of TSE
    v1.10/25.01.94  bug fix
    v1.00/29.12.93  primary release

\****************************************************************************/

/****************************************************************************\
    global variables and constants
\****************************************************************************/

constant  KEYWIDTH = 32,
          CMDWIDTH = 192

integer cmdfile
integer tmpfile
integer loaded_macros_id = 0
integer parsed_macros_id = 0
integer resolved_macro_id = 0
integer loaded_source_id = 0
integer debugFile
integer traceFile
integer showDebugFileB = FALSE
integer showLoadedMacrosB = FALSE
integer showParsedMacrosB = FALSE
integer showResolvedMacroB = FALSE
integer showLoadedSourceB = FALSE
integer showCombinedSourcesB = FALSE
integer showSearchPathsGB = FALSE
integer originalFileI = 0

string uiFile[_MAXPATH_] = ""
string macroSearchPathS[255] = ""

/****************************************************************************\
    obtain and load the source files of all currently loaded macros
\****************************************************************************/

proc list_startup()
    PushLocation()
    PushBlock()
    MarkLine(1, NumLines())
    GotoBufferId(loaded_macros_id)
    CopyBlock()
    PopBlock()
    PopLocation()
end list_startup

proc AddDebugPath(string sourceFileS)
    integer oldBufferI

    oldBufferI = GotoBufferId(debugFile)
    AddLine(ExpandPath(sourceFileS))
    GotoBufferId(oldBufferI)
end

proc AddTraceLine(string traceLineS)
    integer oldBufferI

    oldBufferI = GotoBufferId(traceFile)
    AddLine(traceLineS)
    GotoBufferId(oldBufferI)
end

string proc FindMacroSource(string macroNameS)
    string macroBaseS[255] = ""
    string macroFileS[_MAXPATH_] = ""
    string sourceFileS[_MAXPATH_] = ""

    macroBaseS = SplitPath(macroNameS, _NAME_)
    if WhichOS() == _LINUX_
        // Loaded names are normally uppercase, while Linux source and
        // compiled-macro filenames are commonly lowercase.
        macroBaseS = Lower(macroBaseS)
    endif

    // The current working directory has explicit first priority.
    sourceFileS = SearchPath(macroBaseS + ".s", ".")
    if Length(sourceFileS)
        return(sourceFileS)
    endif

    // Search user-supplied directories next.  The live Purge Macro list
    // contains names only, so a macro loaded from C:\TEMP cannot otherwise
    // reveal that original directory.
    if Length(macroSearchPathS)
        sourceFileS = SearchPath(macroBaseS + ".s", macroSearchPathS)
        if Length(sourceFileS)
            return(sourceFileS)
        endif

        macroFileS = SearchPath(macroBaseS + ".mac", macroSearchPathS)
        if Length(macroFileS)
            sourceFileS = SplitPath(macroFileS,
                                    _DRIVE_|_PATH_|_NAME_) + ".s"
            if FileExists(sourceFileS)
                return(sourceFileS)
            endif
        endif
    endif

    // Next search the configured TSEPath directories directly.  Source
    // directories such as F:\BBC\TAAL need not be named "mac".
    sourceFileS = SearchPath(macroBaseS + ".s", Query(TSEPath))
    if Length(sourceFileS)
        return(sourceFileS)
    endif

    // Then find the loaded .MAC directly through TSEPath and look beside it.
    macroFileS = macroBaseS + ".mac"
    macroFileS = SearchPath(macroFileS, Query(TSEPath))
    if Length(macroFileS)
        sourceFileS = SplitPath(macroFileS, _DRIVE_|_PATH_|_NAME_) + ".s"
        if FileExists(sourceFileS)
            return(sourceFileS)
        endif
    endif

    // Finally try the conventional mac subdirectory below each TSEPath entry.
    macroFileS = SearchPath(macroBaseS + ".mac", Query(TSEPath), "mac")
    if Length(macroFileS)
        sourceFileS = SplitPath(macroFileS, _DRIVE_|_PATH_|_NAME_) + ".s"
        if FileExists(sourceFileS)
            return(sourceFileS)
        endif
    endif
    sourceFileS = SearchPath(macroBaseS + ".s", Query(TSEPath), "mac")
    return(sourceFileS)
end

integer proc InsertSearchSource(string sourceFileS)
    integer insertedB

    GotoBufferId(cmdfile)
    EndFile()
    AddLine("// KEYASSGN_SOURCE: " + ExpandPath(sourceFileS))
    AddLine("")
    BegLine()
    insertedB = InsertFile(sourceFileS, _DONT_PROMPT_)
    return(insertedB)
end

string proc GetLoadedMacroName()
    integer lineLengthI = CurrLineLen()
    string lineTextS[255] = ""
    string macroNameS[255] = ""

    // The visible name is the first space-delimited field of a fixed-width
    // internal record.  Whole-line GetText works reliably in both tested TSEs.
    if lineLengthI > 255
        lineLengthI = 255
    endif
    if lineLengthI
        lineTextS = GetText(1, lineLengthI)
        macroNameS = GetToken(Trim(lineTextS), " ", 1)
    endif
    return(macroNameS)
end

proc ParseLoadedMacroNames()
    integer oldBufferI
    string macroNameS[255] = ""

    parsed_macros_id = NewFile()
    if not parsed_macros_id
        Warn("Cannot allocate parsed-macro list")
        return()
    endif

    GotoBufferId(loaded_macros_id)
    BegFile()
    repeat
        macroNameS = GetLoadedMacroName()
        if Length(macroNameS)
            oldBufferI = GotoBufferId(parsed_macros_id)
            AddLine(macroNameS)
            GotoBufferId(oldBufferI)
        endif
    until not Down()
end

proc LoadLoadedMacroSources()
    integer insertedB
    string macroNameS[255] = ""
    string sourceFileS[_MAXPATH_] = ""

    // Use the normalized plain-name buffer.  The original captured list is
    // an internal fixed-width list and must not be reread at this stage.
    GotoBufferId(parsed_macros_id)
    BegFile()
    repeat
        macroNameS = GetLoadedMacroName()
        if Length(macroNameS)
            AddTraceLine("BEGIN")
            AddTraceLine(macroNameS)
            sourceFileS = FindMacroSource(macroNameS)
            if Length(sourceFileS)
                AddTraceLine("RESOLVED")
                AddTraceLine(ExpandPath(sourceFileS))
                AddDebugPath(sourceFileS)
                AddTraceLine("INSERTING")
                insertedB = InsertSearchSource(sourceFileS)
                if insertedB
                    AddTraceLine("LOADED")
                else
                    AddTraceLine("LOAD FAILED")
                endif
                GotoBufferId(parsed_macros_id)
            else
                AddTraceLine("SOURCE NOT FOUND")
            endif
        endif
    until not Down()
end

/****************************************************************************\
    translate key codes on supported 32-bit Windows and Linux editions
\****************************************************************************/

string proc FindKey( integer key )
    integer n
    string key_name[KEYWIDTH]

    key_name = KeyName(key)
    for n = Length(key_name) downto 1
    	if Asc(key_name[n]) < 32
    		key_name = "<"+Str(key)+">"
    		break
    	endif
    endfor
    return (key_name)
end

/****************************************************************************\
    find key binding
\****************************************************************************/

proc TranslateKey( var string key )
    integer oldBufferI

    oldBufferI = GotoBufferId(tmpfile)
    AddLine(key)
    lReplace("{[\\\[\]{}?.*+#@~|^$]}","\\\1","gnx")
    key = GetText(1,CurrLineLen())
    EmptyBuffer()
    GotoBufferId(oldBufferI)
end

proc FindDefinitionFile(var string definitionFileS)
    PushPosition()
    definitionFileS = ""
    if lFind("^// KEYASSGN_SOURCE: {.*}$", "bix")
        definitionFileS = GetFoundText(1)
    endif
    PopPosition()
end

proc FindCmd ( var string cmd, var string dsc, var string definitionFileS,
               string key, integer first )
    integer bindingFoundB = FALSE
    string constantNameS[255] = ""
    string keyExpressionS[KEYWIDTH] = key

    TranslateKey(keyExpressionS)
    GotoBufferId(cmdfile)
    dsc = ""
    definitionFileS = ""

    // Resolve an active symbolic key declaration such as:
    // constant TEMPLATE_MENU = <CtrlAltShift F8>
    // ... followed later by: <TEMPLATE_MENU> TemplateMenu()
    BegFile()
    if lFind("^[ \t]*constant[ \t]+{[A-Za-z_][A-Za-z0-9_]*}[ \t]*=[ \t]*" +
             keyExpressionS, "gix")
        constantNameS = GetFoundText(1)
        BegFile()
        if lFind("^<" + constantNameS + ">", "gix")
            bindingFoundB = TRUE
        endif
    endif

    // If the key is not symbolic, find a direct definition beginning
    // with the requested key.  Anchoring at column 1 skips comments and
    // unrelated occurrences of the same key text.
    if not bindingFoundB
        BegFile()
        if lFind("^" + keyExpressionS, "gix")
            bindingFoundB = TRUE
        endif
    endif

    if not bindingFoundB
        cmd = "not assigned"
        return()
    endif

    FindDefinitionFile(definitionFileS)

    if first and lFind("^<.+><.+>","cgx")
        cmd = ""
    else
        if lFind("^<.#> #{.+}{//}|$","cgix")
            MarkFoundText(1)
            cmd = Trim(GetMarkedText())
            if lFind("^<.#> #{.#}//{.#}$","cgx")
                MarkFoundText(2)
                dsc = Trim(GetMarkedText())
            endif
        else
            cmd = "invalid keydefinition"
        endif
    endif
end

/****************************************************************************\
    hooked events
\****************************************************************************/

proc WhenLoaded()
    string defaultUiS[_MAXPATH_] = ""

    PushPosition()
    originalFileI = GetBufferId()

    defaultUiS = SearchPath("tse.ui", Query(TSEPath), "ui")
    if Length(defaultUiS)
        uiFile = defaultUiS
    else
        uiFile = ExpandPath("tse.ui")
    endif
    IF ( ( WhichOS() == _WINDOWS_ ) OR ( WhichOS() == _WINDOWS_NT_ ) )
        uiFile = "f:\bbc\taal\qedincke.ui"
    ELSEIF ( WhichOS() == _LINUX_ )
        uiFile = "/mnt/c/temp/tse_linux/tse45014working/ui/keyassignmentreplacementtseforlinuxbegin.ui"
    ENDIF
    if not Ask("Location of the .UI source file:", uiFile, _EDIT_HISTORY_)
        PurgeMacro(CurrMacroFileName())
        return()
    endif

    if not FileExists(uiFile)
        Warn("UI source file not found: ", uiFile)
        PurgeMacro(CurrMacroFileName())
        return()
    endif
    uiFile = ExpandPath(uiFile)

    debugFile = CreateTempBuffer()
    if not debugFile
        Warn("Cannot allocate debug-path buffer")
        PurgeMacro(CurrMacroFileName())
        return()
    endif
    traceFile = CreateTempBuffer()
    if not traceFile
        Warn("Cannot allocate load-trace buffer")
        PurgeMacro(CurrMacroFileName())
        return()
    endif
    AddTraceLine("KEYASSGN 1.0.0.0.36 LOAD TRACE")

    cmdfile = CreateTempBuffer()
    if not cmdfile
        Warn("Cannot allocate command buffer")
        PurgeMacro(CurrMacroFileName())
        return()
    endif
    tmpfile = CreateTempBuffer()
    if not tmpfile
        Warn("Cannot allocate work buffer")
        PurgeMacro(CurrMacroFileName())
        return()
    endif

    // Main must start from a normal editing buffer.  PurgeMacro() may not
    // open its live list when a temporary/system buffer is current.
    GotoBufferId(originalFileI)
    Message("Help on keyboard assignment...")
end

proc WhenPurged()
    integer debugFileToShowI = 0
    integer combinedSourcesToShowI = 0
    integer loadedMacrosToShowI = 0
    integer parsedMacrosToShowI = 0
    integer resolvedMacroToShowI = 0
    integer loadedSourceToShowI = 0

    if cmdfile and showCombinedSourcesB
        combinedSourcesToShowI = cmdfile
        cmdfile = 0
    elseif cmdfile
        AbandonFile(cmdfile)
    endif
    if tmpfile
        AbandonFile(tmpfile)
    endif
    if loaded_macros_id and showLoadedMacrosB
        loadedMacrosToShowI = loaded_macros_id
        loaded_macros_id = 0
    elseif loaded_macros_id
        AbandonFile(loaded_macros_id)
    endif
    if parsed_macros_id and showParsedMacrosB
        parsedMacrosToShowI = parsed_macros_id
        parsed_macros_id = 0
    elseif parsed_macros_id
        AbandonFile(parsed_macros_id)
    endif
    if resolved_macro_id and showResolvedMacroB
        resolvedMacroToShowI = resolved_macro_id
        resolved_macro_id = 0
    elseif resolved_macro_id
        AbandonFile(resolved_macro_id)
    endif
    if loaded_source_id and showLoadedSourceB
        loadedSourceToShowI = loaded_source_id
        loaded_source_id = 0
    elseif loaded_source_id
        AbandonFile(loaded_source_id)
    endif
    if debugFile and showDebugFileB
        debugFileToShowI = debugFile
        debugFile = 0
    elseif debugFile
        AbandonFile(debugFile)
    endif
    if traceFile
        AbandonFile(traceFile)
    endif
    PopPosition()
    if debugFileToShowI
        GotoBufferId(debugFileToShowI)
        BegFile()
    elseif loadedMacrosToShowI
        GotoBufferId(loadedMacrosToShowI)
        BegFile()
        Message("Breakpoint 1: captured loaded-macro list; no parsing performed")
    elseif parsedMacrosToShowI
        GotoBufferId(parsedMacrosToShowI)
        BegFile()
        Message("Breakpoint 2: parsed macro names; no path lookup performed")
    elseif resolvedMacroToShowI
        GotoBufferId(resolvedMacroToShowI)
        BegFile()
        Message("Breakpoint 3: one macro path resolved; no source loaded")
    elseif loadedSourceToShowI
        GotoBufferId(loadedSourceToShowI)
        BegFile()
        Message("Breakpoint 4: one resolved macro source loaded")
    elseif combinedSourcesToShowI
        GotoBufferId(combinedSourcesToShowI)
        BegFile()
        Message("Breakpoint 5: all resolved macro sources loaded; no UI")
    endif
    UpdateDisplay()
end

/****************************************************************************\
    main program
\****************************************************************************/

proc main()
    integer key
    string  key_open[KEYWIDTH] = ""
    string  key_name[KEYWIDTH] = ""
    string  cmd_name[CMDWIDTH] = ""
    string  cmd_desc[CMDWIDTH] = ""
    string  definitionFileS[_MAXPATH_] = ""
    string  additionalPromptS[80] = ""

    // Use the supplied working pattern exactly: NewFile, hook list startup,
    // queue Escape, invoke PurgeMacro, then remove the hook.
    loaded_macros_id = NewFile()
    if not loaded_macros_id
        Warn("Cannot allocate loaded-macro list")
        PurgeMacro(CurrMacroFileName())
        return()
    endif
    Hook(_LIST_STARTUP_, list_startup)
    PushKey(<Escape>)
    PurgeMacro()
    UnHook(list_startup)

    // Normalize the captured fixed-width records, then load every macro
    // source that can be resolved before appending the UI fallback.
    ParseLoadedMacroNames()
    if WhichOS() == _LINUX_
        additionalPromptS = "Additional macro directories (Linux path list):"
    else
        additionalPromptS = "Additional macro directories (; separated):"
    endif
    IF ( ( WhichOS() == _WINDOWS_ ) OR ( WhichOS() == _WINDOWS_NT_ ) )
        macroSearchPathS = "c:\temp\"
    ELSEIF ( WhichOS() == _LINUX_ )
        macroSearchPathS = "/mnt/c/temp/"
    ENDIF
    if not Ask(additionalPromptS,
               macroSearchPathS, _EDIT_HISTORY_)
        showParsedMacrosB = TRUE
        PurgeMacro(CurrMacroFileName())
        return()
    endif
    LoadLoadedMacroSources()

    // Loaded macros have priority.  The selected UI source is appended
    // afterward and is therefore used only when no loaded macro matches.
    AddDebugPath(uiFile)
    if not InsertSearchSource(uiFile)
        Warn("Cannot load UI file")
        PurgeMacro(CurrMacroFileName())
        return()
    endif
    if PopWinOpen(2,5,Query(ScreenCols) - 1,18,4,"",112)
        Set(Cursor,OFF)
        Set(Attr,112)
        ClrScr()

        repeat
            GotoXY(7,2) ClrEol()
            GotoXY(3,2) ClrEol()
            Write("Hit key for description or press <Esc> to Exit")
            loop
                key = GetKey()
                key_name = key_open + '<' + FindKey(key) + '>'
                FindCmd(cmd_name,cmd_desc,definitionFileS,key_name,key_open=="")

                Set(Attr,112)
                GotoXY(3,4) ClrEol() Write(key_name)
                GotoXY(3,5) ClrEol() Write(cmd_name)
                GotoXY(3,7) ClrEol() Write(cmd_desc)
                GotoXY(3,9) ClrEol() Write("File: ", definitionFileS)

                if Length(cmd_name)
                    key_open = ""
                    break
                else
                    key_open = key_name
                    GotoXY(3,2) ClrEol() Write("TwoKey, hit second key")
                endif
            endloop
        until key == <Escape>

        Delay(9)
        PopWinClose()
        Set(Cursor,ON)
        showDebugFileB = showSearchPathsGB
    endif
    PurgeMacro(CurrMacroFileName())
end

