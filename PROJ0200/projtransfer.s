// PROJ0200 1.0.0.0.168 - OpenAI Codex (GPT-6)
// Separate worker keeps uploads and backups below SAL's per-macro size limit.
string proc GetInstallationDir()
    string directory[255] = SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_)
    if Length(directory) and directory[Length(directory)] <> "\"
        directory = directory + "\"
    endif
    return(directory)
end

string proc PROJ_PackageSetting(string settingName)
    integer previousBuffer = GetBufferId()
    integer iniBuffer
    integer equalsAt
    string settingValue[255] = ""
    string lineText[255]
    string iniFilename[255] = GetInstallationDir() + "proj0200.ini"
    if not FileExists(iniFilename)
        return(settingValue)
    endif
    iniBuffer = CreateTempBuffer()
    if iniBuffer
        if InsertFile(iniFilename, _DONT_PROMPT_)
            BegFile()
            repeat
                lineText = Trim(GetText(1, 255))
                equalsAt = Pos("=", lineText)
                if equalsAt > 1
                    if Lower(Trim(SubStr(lineText, 1, equalsAt - 1))) == Lower(settingName)
                        settingValue = Trim(SubStr(lineText, equalsAt + 1, 255))
                        break
                    endif
                endif
            until not Down()
        endif
        GotoBufferId(previousBuffer)
        AbandonFile(iniBuffer)
    endif
    return(settingValue)
end

integer proc PROJ_CreateScopeRequest(integer scope)
    integer requestBuffer = 0
    if scope == GetGlobalInt("PROJ_TransferScope")
        requestBuffer = GetGlobalInt("PROJ_TransferRequest")
        SetGlobalInt("PROJ_TransferRequest", 0)
    endif
    return(requestBuffer)
end

integer proc PROJ_RunScopeHelper(integer requestBuffer, integer listOnly)
    integer originalBuffer = GetBufferId()
    integer batchBuffer = CreateTempBuffer()
    integer succeeded = FALSE
    integer manifestBuffer = 0
    string root[255] = GetInstallationDir()
    string requestFile[255] = root + "proj0200_scope_request.txt"
    string manifestFile[255] = root + "proj0200_scope_manifest.txt"
    string batchFile[255] = root + "proj0200_scope_run.bat"
    string switches[20] = ""
    if not batchBuffer
        return(0)
    endif
    if listOnly
        switches = " -ListOnly"
    endif
    if FileExists(manifestFile)
        EraseDiskFile(manifestFile)
    endif
    GotoBufferId(requestBuffer)
    if SaveAs(requestFile, _DONT_PROMPT_|_OVERWRITE_)
        GotoBufferId(batchBuffer)
        AddLine("@echo off")
        // Split PowerShell invocation across batch lines to avoid SAL's 255 limit.
        AddLine('powershell.exe -NoP -NonI -W Hidden -ExecutionPolicy Bypass ^')
        AddLine(' -File "' + root + 'proj0200_archive_helper.ps1" ^')
        AddLine(' -Request "' + requestFile + '" ^')
        AddLine(' -Manifest "' + manifestFile + '"' + switches)
        if SaveAs(batchFile, _DONT_PROMPT_|_OVERWRITE_)
            Dos('cmd.exe /d /c ""' + batchFile + '""', _DONT_PROMPT_)
            succeeded = FileExists(manifestFile)
        endif
    endif
    AbandonFile(batchBuffer)
    GotoBufferId(originalBuffer)
    if succeeded
        manifestBuffer = EditBuffer(manifestFile, _SYSTEM_)
    else
        Warn("Cannot create the scope manifest. Check PowerShell and the package helper.")
    endif
    return(manifestBuffer)
end

proc PROJ_CleanupScope()
    integer originalBuffer = GetBufferId()
    integer batchBuffer = CreateTempBuffer()
    string root[255] = GetInstallationDir()
    string filename[255] = root + "proj0200_scope_cleanup.bat"
    if batchBuffer
        AddLine("@echo off")
        AddLine('powershell.exe -NoP -NonI -W Hidden -ExecutionPolicy Bypass ^')
        AddLine(' -File "' + root + 'proj0200_archive_helper.ps1" ^')
        AddLine(' -Manifest "' + root + 'proj0200_scope_manifest.txt" -Cleanup')
        if SaveAs(filename, _DONT_PROMPT_|_OVERWRITE_)
            Dos('cmd.exe /d /c ""' + filename + '""', _DONT_PROMPT_)
        endif
        AbandonFile(batchBuffer)
    endif
    GotoBufferId(originalBuffer)
end


#include ["projsvn.si"]
#include ["projgit.si"]
#include ["projbackup.si"]

proc Main()
    integer originalBuffer = GetBufferId()
    integer scope = GetGlobalInt("PROJ_TransferScope")
    integer automatic = GetGlobalInt("PROJ_TransferAutomatic")
    integer unusedRequest
    case Lower(Trim(Query(MacroCmdLine)))
        when "svn"
            PROJ_UploadSVNScope(scope, automatic)
        when "git"
            PROJ_UploadGitScope(scope, automatic)
        when "backup"
            PROJ_BackupScope(scope)
        otherwise
            Warn("Run projtransfer through PROJ0200's upload or backup menu.")
    endcase
    unusedRequest = GetGlobalInt("PROJ_TransferRequest")
    if unusedRequest
        AbandonFile(unusedRequest)
        SetGlobalInt("PROJ_TransferRequest", 0)
    endif
    GotoBufferId(originalBuffer)
end
