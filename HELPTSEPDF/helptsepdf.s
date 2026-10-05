// HELPTSEPDF version 1.0.0.0.0
// Created 2026-10-05. LLM: GPT-6.1.
// ASCII source. Windows TSE SAL; no DLL required.
proc main()
    string SDirectory[255]
    string SIni[255]
    string SPdf[255]
    string SCommand[255]
    string SMessage[255]
    integer BSilent = FALSE
    integer BOk = FALSE

    SDirectory = SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_)
    SIni = CurrDir() + "\helptsepdf.ini"
    if not FileExists(SIni)
        SIni = SDirectory + "helptsepdf.ini"
    endif
    BSilent = Lower(GetProfileStr("helptsepdf", "silent", "false", SIni)) == "true"
    SPdf = GetProfileStr("helptsepdf", "pdffilename",
                        "testhelphyperlinktseadobe.pdf", SIni)
    if SplitPath(SPdf, _DRIVE_ | _PATH_) == ""
        SPdf = SDirectory + SPdf
    endif
    SMessage = "HELPTSEPDF 1.0.0.0.0: PDF not found: " + SPdf
    if FileExists(SPdf)
        // Limit before concatenation: SAL strings hold at most 255 characters.
        if Length(SPdf) <= 220
            SCommand = 'cmd.exe /d /c start "" "' + SPdf + '"'
            BOk = Dos(SCommand, _DONT_PROMPT_)
            if BOk
                SMessage = "HELPTSEPDF 1.0.0.0.0: Opening TSE help in your default PDF viewer. Use Ctrl+F to find a topic. Set silent=true in helptsepdf.ini to hide this message."
            else
                SMessage = "HELPTSEPDF 1.0.0.0.0: Could not launch the PDF viewer. Open the PDF manually."
            endif
        else
            SMessage = "HELPTSEPDF 1.0.0.0.0: PDF path too long. Move the package to a shorter directory."
        endif
    endif
    if not BSilent
        Warn(SMessage)
    endif
end
