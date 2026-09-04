
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


