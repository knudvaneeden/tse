// UTF8SHORT 1.0.0.0.4 - OpenAI Codex (GPT-6).
// Portable launcher. All package files are located beside this macro.
// Preload the DLL before loading the worker's DLL declarations.
dll "<kernel32.dll>"
    integer proc pascal FNLoadLibrary(string pathS:cstrval) : "LoadLibraryA"
    integer proc pascal FNFreeLibrary(integer moduleI) : "FreeLibrary"
    integer proc pascal FNLastError() : "GetLastError"
end

proc Main()
    string directoryS[255] = SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_)
    string dllS[255] = ""
    string workerS[255] = ""
    string messageS[255] = ""
    integer moduleI = 0
    integer releasedB = FALSE

    if Length(directoryS) == 0
        directoryS = CurrDir()
    endif
    if directoryS[Length(directoryS)] <> "\" and
       directoryS[Length(directoryS)] <> "/"
        directoryS = directoryS + "\"
    endif

    if Length(directoryS) + Length("utf8short_run.mac") > 255
        messageS = "Package path exceeds SAL's 255-byte limit."
    else
        dllS = directoryS + "utf8short.dll"
        workerS = directoryS + "utf8short_run.mac"
        moduleI = FNLoadLibrary(dllS)
        if moduleI == 0
            messageS = "Cannot load companion DLL. Windows error: " + Str(FNLastError())
        else
            ExecMacro('"' + workerS + '"')
            releasedB = FNFreeLibrary(moduleI)
            if not releasedB
                messageS = "Cannot release launcher DLL reference. Windows error: " + Str(FNLastError())
            endif
        endif
    endif

    if Length(messageS) > 0
        Warn("UTF8SHORT 1.0.0.0.4 - ", messageS)
    endif
end
