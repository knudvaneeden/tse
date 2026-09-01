/* CHDIR.S
   TSE SAL directory changer using CHDIRDLL.DLL.
   Version: 1.0.0.0.1
   LLM: OpenAI Codex (GPT-5)
*/

dll "chdirdll.dll"
    integer proc PASCAL ChDirDll(string directoryS : cstrval) : "CHDIR"
end

public proc mChDir()
    string pathS[255] = ""
    integer resultI = 0

    if Ask("New directory:", pathS) AND Length(pathS)
        resultI = ChDirDll(pathS)

        if resultI == 0
            EditFile()
        else
            Warn("Cannot change directory. Windows error: ", resultI)
        endif
    endif
end

proc Main()
    mChDir()
end
