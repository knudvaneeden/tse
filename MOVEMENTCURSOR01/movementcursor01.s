// MOVEMENTCURSOR01 1.0.0.0.0
// Created: 2026-09-30 02:00:40 Europe/Amsterdam
// LLM: OpenAI GPT-6 (Codex)
// ASCII SAL source. No DLL required.

proc PROCClampCursorToLine()
    if CurrPos() > CurrLineLen() + 1
        GotoPos(CurrLineLen() + 1)
    endif
end

proc PROCMyCursorDown()
    Down()
    PROCClampCursorToLine()
end

proc PROCMyCursorUp()
    Up()
    PROCClampCursorToLine()
end

Keydef movementCursorKeys
    <CursorLeft>  PrevChar()
    <CursorRight> NextChar()
    <CursorUp>    PROCMyCursorUp()
    <CursorDown>  PROCMyCursorDown()
end

proc Main()
    string SIniFilename[255]
    string SSilent[20]

    SIniFilename = SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_)
    if SIniFilename == ""
        SIniFilename = CurrDir()
    endif
    if not (SIniFilename[Length(SIniFilename)] in "\\/")
        SIniFilename = SIniFilename + "\\"
    endif
    SIniFilename = SIniFilename + "movementcursor01.ini"
    SSilent = Lower(GetProfileStr("Settings", "silent", "false", SIniFilename))
    Enable(movementCursorKeys)
    if SSilent <> "true"
        Warn("MOVEMENTCURSOR01 1.0.0.0.0 enabled. Left/Right follow file data; " +
             "Up/Down clamp to EOL+1 only when beyond it. " +
             "Set silent=true in movementcursor01.ini to hide this message.")
    endif
end
