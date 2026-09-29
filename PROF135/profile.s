
/*

    Profile -- TSE 2.5 macro for reading and writing INI files

    Profile.si is the file you actually want to include

    See Profile.txt for usage.

    v1.3.5 - Dec 12, 2001

    Author:
    Chris Antos <chrisant@microsoft.com>, Michael Graham <magmac@occamstoothbrush.com>

*/

#define MAX_CMD_LINE 128
#define MAXPATH 255


// Variables --------------------------------------------------------------

string Current_INI_File[255]     = ""
string ini_buf_name[]            = "+++profile_ini_file+++"
integer id_ini                   = 0
integer Settings_Serial          = 0
string  Windows_Profile_Dir[255] = ""

integer CurrentSectionKeyLine = 0
integer CurrentSectionEnd     = 0
integer CurrentSectionNumber  = 0

// Functions --------------------------------------------------------------

integer proc NeedToReloadSettings(var integer serial)
    if serial < GetGlobalInt('setcache:refresh_serial')
        serial = GetGlobalInt('setcache:refresh_serial')
        return(1)
    endif
    return(0)
end

integer proc FirstNonWhite()
    if PosFirstNonWhite()
        return(Asc(GetText(PosFirstNonWhite(),1)))
    endif
    return(0)
end

proc GotoLastNonBlank()
    while (not PosFirstNonWhite()) and Up()
    endwhile
end

integer proc MarkSection(string section)
    integer section_start
    integer section_end

    UnmarkBlock()
    BegFile()
    GotoBufferId(id_ini)

    if lFind("["+section+"]", "^gi")
        if Down()
            section_start = CurrLine()
            if lFind("\[.*\]", "^x")
                Up()
                section_end = CurrLine()
            else
                EndFile()
                section_end = CurrLine()
            endif
            MarkLine(section_start, section_end)
            return(TRUE)
        endif
    endif
    return(FALSE)
end

integer proc FindValue(string section, string keynm, integer fRequired)
    // look for value (and place cursor at start of value)

    PushBlock()
    if MarkSection(section)
        if lFind("[\t ]*"+keynm+"=\c", "^ilgx")
            PopBlock()
            return(TRUE)
        else
            PopBlock()
        endif
    endif

    // if not found, but required, create keyname (and section if necessary)
    if fRequired
        if lFind("["+section+"]", "^gi")
            Down()
        else
            EndFile()
            GotoLastNonBlank()
            AddLine()
            AddLine("["+section+"]")
            EndLine()   // so the lFind below doesn't match
        endif
        if lFind("\[[A-Za-z0-9_]+\]", "^x")
            Up()
        else
            EndFile()
        endif
        GotoLastNonBlank()
        AddLine(keynm+"=")
        EndLine()
        return(TRUE)
    endif

    return(FALSE)
end

string proc GetValue(string section, string keynm, string default)
    if FindValue(section, keynm, FALSE)
        return(GetText(CurrPos(), 255))
    endif
    return(default)
end

proc SetValue(string section, string keynm, string value)
    FindValue(section, keynm, TRUE)
    KillToEol()
    InsertText(value)
end

// Doesn't actually load the keys; instead just moves the
// CurrentSectionKeyLine pointer to the start of the section
// The extra work is to find out if there are actually any
// keys in this section.

integer proc LoadSectionKeys(string section)
    PushBlock()

    if MarkSection(section)
        GotoBlockBegin()
        Up()
        CurrentSectionKeyLine = CurrLine()
        GotoBlockEnd()
        CurrentSectionEnd = CurrLine()
        PopBlock()
        return(TRUE)
    else
        PopBlock()
    endif
    return(FALSE)
end

string proc GetNextKey (string default)
    integer f

    if CurrentSectionKeyLine > 0

        CurrentSectionKeyLine = CurrentSectionKeyLine + 1
        GotoLine(CurrentSectionKeyLine)

        f = FirstNonWhite()

        while (f == 0  or f == Asc(';')) and Down()
            f = FirstNonWhite()
        endwhile

        if CurrLine() < NumLines() and CurrLine() <= CurrentSectionEnd
            CurrentSectionKeyLine = CurrLine()
        else
            CurrentSectionKeyLine = 0
        endif

        if Pos('=',GetText(1,CurrLineLen()))
            return(Trim(GetToken(GetText(1,CurrLineLen()),'=',1)))
        else
            return('')
        endif
    endif
    return(default)
end

string proc GetCurrentValue()

    if CurrentSectionKeyLine > 0
        GotoLine(CurrentSectionKeyLine)

        if Pos('=',GetText(1,CurrLineLen()))
            return(Trim(GetToken(GetText(1,CurrLineLen()),'=',2)))
        endif

        // Make sure we're not into the next section
        // if not lFind('^[ \t]*\[.*\][ \t]*$', 'cx')
        if CurrLine() <= CurrentSectionEnd
             return(GetText(1,CurrLineLen()))
        endif
    endif
    return('')
end

// Doesn't actually load the sections; instead just resets
// CurrentSectionNumber pointer
// The extra work is to figure out if there are actually
// any sections in the file which contain any values.
integer proc LoadSectionNames()
    CurrentSectionNumber = 0

    BegFile()

    PushBlock()
    while lFind("\[{.*}\]\c", "^ix")
        PushPosition()
        if MarkSection(GetFoundText(1))
            if lFind("[\t ]*[~\[\t ]+=.+", "^iglx")
                PopBlock()
                PopPosition()
                return(TRUE)
            endif
        endif
        PopPosition()
    endwhile
    PopBlock()

    return(FALSE)
end

string proc GetNextSection(string default)
    integer sec = 0

    BegFile()
    CurrentSectionNumber = CurrentSectionNumber + 1
    while lFind("^\[{.*}\]\c", "xi")
        sec = sec + 1
        if sec == CurrentSectionNumber
            return(GetFoundText(1))
        endif
    endwhile
    return(default)
end

proc RemoveKey(string section, string keynm)
    BegFile()
    if FindValue(section, keynm, 0)
        KillLine()
    endif
end

proc RemoveSection(string section)
    PushBlock()
    UnMarkBlock()
    if lFind("["+section+"]", "^gi")
        MarkLine()

        Down()
        BegLine()

        if lFind("^\[.*\]", "x")
            Up()
        else
            while Down()
            endwhile
        endif

        MarkLine()
        KillBlock()
    endif
    PopBlock()
end

proc Save()
    integer cid

    if id_ini
        cid = GotoBufferId(id_ini)
        if FileChanged()
            SaveAs(Current_INI_File, _OVERWRITE_|_DONT_PROMPT_)
        endif
        GotoBufferId(cid)
    endif
end

string proc Find_INI_File(string fn)
    string filename[255] = fn

    if filename == ''
        filename = LoadDir() + 'tse.ini'

    else
        if SplitPath(filename,_DRIVE_) == ''
        and SplitPath(filename,_PATH_) == ''
            if Windows_Profile_Dir == ''
                if GetEnvStr('OS') == 'Windows_NT'
                    Windows_Profile_Dir = GetEnvStr('SYSTEMROOT')
                    if Windows_Profile_Dir == ''
                        Windows_Profile_Dir = GetEnvStr('systemroot')
                    endif
                else
                    Windows_Profile_Dir = GetEnvStr('WINDIR')
                    if Windows_Profile_Dir == ''
                        Windows_Profile_Dir = GetEnvStr('windir')
                    endif
                endif

                if Windows_Profile_Dir <> ''
                    if Windows_Profile_Dir[Length(Windows_Profile_Dir):1] <> '\'
                        Windows_Profile_Dir = Windows_Profile_Dir + '\'
                    endif
                endif
            endif
            filename = Windows_Profile_Dir + filename
        endif
    endif

    return(filename)
end

proc Load_INI_File(string fn)
    string filename[255] = Find_INI_File(fn)

    integer cid = GetBufferId()

    if NeedToReloadSettings(Settings_Serial)
        or filename <> Current_INI_File

        if id_ini
            Save()
            SetHookState(OFF, _ON_CHANGING_FILES_)
            AbandonFile(id_ini)
            SetHookState(ON, _ON_CHANGING_FILES_)
        endif

        id_ini = CreateBuffer(ini_buf_name, _SYSTEM_)

        Current_INI_File = filename

        if FileExists(Current_INI_File)

            PushBlock()
            InsertFile(Current_INI_File, _DONT_PROMPT_)
            UnMarkBlock()
            PopBlock()
        else
            InsertLine("; TSE Pro macro settings file")
        endif

        BegFile()
        FileChanged(FALSE)

        Hook(_ON_ABANDON_EDITOR_, Save)

    endif

    if not id_ini
        Warn("Error creating buffer "+ini_buf_name)
        return()
    endif

    GotoBufferId(cid)
end

proc WhenPurged()
    Save()
    if id_ini
        SetHookState(OFF, _ON_CHANGING_FILES_)
        AbandonFile(id_ini)
        SetHookState(ON, _ON_CHANGING_FILES_)
    endif
end

// Main -------------------------------------------------------------------

proc InteractiveProfile()
    integer originalBuffer = GetBufferId()
    integer sectionsBuffer = 0
    integer keysBuffer = 0
    integer lineNumber = 0
    integer equalsAt = 0
    integer inSection = FALSE
    integer selected = FALSE
    integer sectionDeleted = FALSE
    integer showResult = TRUE
    string filename[255] = ''
    string resolvedFilename[255] = ''
    string currentDirectory[255] = ''
    string section[80] = ''
    string keynm[80] = ''
    string value[255] = ''
    string lineText[255] = ''
    string action[4] = ''
    string result[255] = ''
    string promptText[80] = 'Choose existing INI file (F10 picks a file):'
    string macroDirectory[255] = ''
    string settingsFilename[255] = ''

    macroDirectory = SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_)
    if macroDirectory <> ''
        if macroDirectory[Length(macroDirectory):1] <> '\'
            if macroDirectory[Length(macroDirectory):1] <> '/'
                macroDirectory = macroDirectory + '\'
            endif
        endif
    endif
    settingsFilename = macroDirectory + 'prof135.ini'
    if macroDirectory == '' or not FileExists(settingsFilename)
        settingsFilename = CurrDir() + 'prof135.ini'
    endif
    Load_INI_File(settingsFilename)
    if id_ini
        GotoBufferId(id_ini)
        if Lower(Trim(GetValue('prof135', 'silent', 'false'))) == 'true'
            showResult = FALSE
        endif
        filename = Trim(GetValue('prof135', 'inifilename', ''))
        GotoBufferId(originalBuffer)
    endif

    // Escape at this prompt is the only way to leave the interface.
    while TRUE
        if not Ask(promptText, filename, _EDIT_HISTORY_)
            GotoBufferId(originalBuffer)
            return()
        endif
        filename = Trim(filename)
        resolvedFilename = filename
        if filename <> ''
            if SplitPath(filename, _DRIVE_) == '' and SplitPath(filename, _PATH_) == ''
                currentDirectory = CurrDir()
                if currentDirectory[Length(currentDirectory):1] <> '\'
                    if currentDirectory[Length(currentDirectory):1] <> '/'
                        currentDirectory = currentDirectory + '\'
                    endif
                endif
                resolvedFilename = currentDirectory + filename
            endif
        endif
        if filename == '' or not FileExists(resolvedFilename)
            if showResult
                Warn('File not found: ' + filename + '. Choose another file or press Esc to exit.')
            endif
            promptText = 'File not found; choose another (F10 picks a file):'
        else
            promptText = 'INI file (Esc exits; F10 picks another):'
            Load_INI_File(resolvedFilename)
            if not id_ini
                GotoBufferId(originalBuffer)
                return()
            endif

            // Escape in the section list goes back to the filename prompt.
            while TRUE
                section = ''
                sectionsBuffer = CreateTempBuffer()
                if not sectionsBuffer
                    GotoBufferId(originalBuffer)
                    return()
                endif
                GotoBufferId(id_ini)
                for lineNumber = 1 to NumLines()
                    GotoLine(lineNumber)
                    lineText = Trim(GetText(1, CurrLineLen()))
                    if Length(lineText) >= 3
                        if lineText[1:1] == '[' and lineText[Length(lineText):1] == ']'
                            GotoBufferId(sectionsBuffer)
                            AddLine(lineText)
                            GotoBufferId(id_ini)
                        endif
                    endif
                endfor
                GotoBufferId(sectionsBuffer)
                AddLine('+ Create a new section')
                BegFile()
                selected = List('Sections: Enter selects; Esc chooses file', 65)
                if selected
                    lineText = Trim(GetText(1, CurrLineLen()))
                endif
                GotoBufferId(originalBuffer)
                AbandonFile(sectionsBuffer)
                sectionsBuffer = 0
                if not selected
                    break
                endif

                if lineText == '+ Create a new section'
                    section = ''
                    keynm = ''
                    value = ''
                    if Ask('New section name (without brackets):', section, _EDIT_HISTORY_)
                        if section <> ''
                            if Ask('First key in new section:', keynm, _EDIT_HISTORY_)
                                if keynm <> ''
                                    if Ask('Value for first key:', value, _EDIT_HISTORY_)
                                        GotoBufferId(id_ini)
                                        SetValue(section, keynm, value)
                                        Save()
                                        GotoBufferId(originalBuffer)
                                        if showResult
                                            Warn('PROF135 1.0.0.0.9 (Codex): Created [' + section + ']')
                                        endif
                                    endif
                                endif
                            endif
                        endif
                    endif
                else
                    section = lineText[2:Length(lineText)-2]
                    // Escape in the key list goes back to the section list.
                    while TRUE
                        keynm = ''
                        inSection = FALSE
                        sectionDeleted = FALSE
                        keysBuffer = CreateTempBuffer()
                        if not keysBuffer
                            GotoBufferId(originalBuffer)
                            return()
                        endif
                        GotoBufferId(id_ini)
                        for lineNumber = 1 to NumLines()
                            GotoLine(lineNumber)
                            lineText = Trim(GetText(1, CurrLineLen()))
                            if Length(lineText) >= 2
                                if lineText[1:1] == '[' and lineText[Length(lineText):1] == ']'
                                    inSection = (Lower(lineText) == Lower('[' + section + ']'))
                                else
                                    if inSection
                                        equalsAt = Pos('=', lineText)
                                        if equalsAt > 1
                                            keynm = Trim(lineText[1:equalsAt-1])
                                            if keynm <> '' and keynm[1:1] <> ';'
                                                GotoBufferId(keysBuffer)
                                                AddLine(lineText)
                                                GotoBufferId(id_ini)
                                            endif
                                        endif
                                    endif
                                endif
                            endif
                        endfor
                        GotoBufferId(keysBuffer)
                        if NumLines() == 0
                            AddLine('(No existing keys)')
                        endif
                        AddLine('+ Add a new key')
                        AddLine('- Delete this section')
                        BegFile()
                        selected = List('Key: Enter opens View/Edit/Delete; + adds; Esc back', 65)
                        if selected
                            lineText = Trim(GetText(1, CurrLineLen()))
                        endif
                        GotoBufferId(originalBuffer)
                        AbandonFile(keysBuffer)
                        keysBuffer = 0
                        if not selected
                            break
                        endif

                        result = ''
                        if lineText == '(No existing keys)'
                            result = 'This section has no keys. Select + Add a new key.'
                        else
                        if lineText == '+ Add a new key'
                            keynm = ''
                            value = ''
                            if Ask('Name of new key:', keynm, _EDIT_HISTORY_)
                                if keynm <> ''
                                    if Ask('Value for new key:', value, _EDIT_HISTORY_)
                                        GotoBufferId(id_ini)
                                        SetValue(section, keynm, value)
                                        Save()
                                        result = 'Saved [' + section + '] ' + keynm + '=' + value
                                    endif
                                endif
                            endif
                        else
                            if lineText == '- Delete this section'
                                if YesNo('Delete section [' + section + '] and all its keys?') == 1
                                    GotoBufferId(id_ini)
                                    RemoveSection(section)
                                    Save()
                                    result = 'Deleted section [' + section + ']'
                                    sectionDeleted = TRUE
                                endif
                            else
                                keynm = Trim(GetToken(lineText, '=', 1))
                                GotoBufferId(id_ini)
                                value = GetValue(section, keynm, '')
                                action = 'V'
                                if Ask('Key ' + keynm[1:20] + ': V/G=view, E=update, R=delete:', action, _EDIT_HISTORY_)
                                    action = Upper(Trim(action))
                                    case action
                                        when 'V'
                                            result = '[' + section + '] ' + keynm + '=' + value
                                        when 'G'
                                            result = '[' + section + '] ' + keynm + '=' + value
                                        when 'E'
                                            if Ask('New value:', value, _EDIT_HISTORY_)
                                                GotoBufferId(id_ini)
                                                SetValue(section, keynm, value)
                                                Save()
                                                result = 'Saved [' + section + '] ' + keynm + '=' + value
                                            endif
                                        when 'R'
                                            if YesNo('Delete key [' + section + '] ' + keynm + '?') == 1
                                                GotoBufferId(id_ini)
                                                RemoveKey(section, keynm)
                                                Save()
                                                result = 'Removed [' + section + '] ' + keynm
                                            endif
                                        otherwise
                                            result = 'Choose V/G to view, E to edit, or R to remove.'
                                    endcase
                                endif
                            endif
                        endif
                        endif
                        GotoBufferId(originalBuffer)
                        if result <> '' and showResult
                            Warn('PROF135 1.0.0.0.9 (Codex): ' + result)
                        endif
                        if sectionDeleted
                            break
                        endif
                        // Rebuild the key list so changes appear immediately.
                    endwhile
                endif
            endwhile
        endif
    endwhile
end

/* Params:
    -x save
    -g get value
    -s set value
    -r remove value
    -f load new ini_file
    -lk load section keys
    -kn get next key
    -kv get value of current key
    -ls load section names
    -ns get next section
    -rk remove key
    -rs remove section
*/

proc Main()
    integer cid
    string function[3]
    string section[80]
    string keynm[80]
    string value[80]
    string s[255] = Query(MacroCmdLine)

    // profile.si separates internal arguments with Chr(10).  A direct
    // run can leave other text in MacroCmdLine, so do not test for ''.
    if Pos(Chr(10), s) == 0
        Set(MacroCmdLine, '')
        InteractiveProfile()
        return()
    endif

    if id_ini
        cid      = GotoBufferId(id_ini)

        function = GetToken(s, Chr(10) , 1)

        section  = GetToken(s, Chr(10) , 2)
        keynm    = GetToken(s, Chr(10) , 3)
        value    = GetToken(s, Chr(10) , 4)

        Set(MacroCmdLine, '')

        case function
            when "-x"
                Save()
            when "-f"
                Load_INI_File(section) // section actually contains the fn!
            when "-g"
                Set(MacroCmdLine, GetValue(section, keynm, value))
            when "-s"
                SetValue(section, keynm, value)
            when "-lk"
                Set(MacroCmdLine, Str(LoadSectionKeys(section)))
            when "-kn"
                Set(MacroCmdLine, GetNextKey(value))
            when "-kv"
                Set(MacroCmdLine, GetCurrentValue())
            when "-ls"
                Set(MacroCmdLine, Str(LoadSectionNames()))
            when "-sn"
                Set(MacroCmdLine, GetNextSection(section))
            when "-rk"
                RemoveKey(section,keynm)
            when "-rs"
                RemoveSection(section)
            otherwise
                Warn("PROFILE.MAC should only be called by the functions in PROFILE.SI")
        endcase
        GotoBufferId(cid)
    else
        case GetToken(s, Chr(10) , 1)
            when "-f"
                Load_INI_File(GetToken(s, Chr(10) , 2))
        endcase
    endif
end
