/***************************************************************
   Macro:         PickFil2.
   Author:        Carlo.Hogeveen@xs4all.nl.
   Date:          7 June 2004.
   Compatibility: TSE 3.0 upwards.

   This macro shows a picklist with only directory and filenames,
   in other words without date, time, size and attributes.

   It lacks the elaborate options of TSE's built-in PickFile, EditFile
   and EditThisFile commands.

   Another difference with the standard commands is, that when you type a
   string in the picklist, then this macro jumps to the first directory or
   file that contains that string, not to the first one that starts with
   that string.

   Installation:

      Copy this file to TSE's "mac" directory, and compile it.

      Assign a key of your choice to it in your .ui file, like this:
         <ctrl o> ExecMacro("PickFil2")

      You can also start it from the commandline or a .bat file with:
         drive:\path\g32.exe -ePickFile

   Credits: this macro is for the largest part based on an example macro
   written and e-mailed by Sammy Mitchell under the title "A different
   pickfile", which demonstrated one way of writing your own PickFile macro.

 ***************************************************************/

proc DisplayLn(integer is_cursorline)
    constant name_len = 78
    string pb_name[255] = PBName()
    string s[255]
    integer color_attr = Query(Attr)
    if PBAttribute() & _DIRECTORY_
        pb_name = "\" + pb_name
    endif
    s = Format(SqueezePath(pb_name, name_len):-name_len)
    if is_cursorline and Length(pb_name) > name_len
        s[1:Length(PB_Name) + 2] = pb_name + ' ]'
    endif
    PutStr(s)
    ClrEol()
    Set(Attr, color_attr)
end

proc DoDrive()
    string s[_MAXPATH_] = PickDrive()
    if s <> ""
        Set(PickFilePath, s + "*.*")
    endif
    EndProcess(-1)
end

string list_footer[] = "{Enter}-Select {Alt-F10}-Drives {Esc}-Quit"

keydef list_keys
   <Alt f10> DoDrive()
end

proc list_startup()
    UnHook(list_startup)
    Enable(list_keys)
    ListFooter(list_footer)
end

proc Main()
    integer id, ok
    string s[255]
    PushPosition()
    id = CreateTempBuffer()
    s = ""
    loop
        EmptyBuffer()
        s = ExpandPath(s)
        BuildPickBufferEx(s, -1)
        PushBlock()
        MarkColumn(1,14,NumLines(),14)
        lReplace("\\",Chr(0),"glnx")
        MarkColumn(1,14,NumLines(),14+255)
        ExecMacro("sort -i")
        MarkColumn(1,14,NumLines(),14)
        lReplace(Chr(0),"\\","glnx")
        PopBlock()
        BegFile()
        HookDisplay(DisplayLn,,,)
        Hook(_LIST_STARTUP_, list_startup)
        ok = List(s, 60)
        UnHookDisplay()
        if ok
            if ok == -1
                s = Query(PickFilePath)
            else
                s = SplitPath(Query(PickFilePath), _DRIVE_|_PATH_) + PBName()
                if (PBAttribute() & _DIRECTORY_) == 0
                    EditFile(QuotePath(s), _DONT_PROMPT_)
                    Break
                endif
            endif
        else
            Break
        endif
    endloop
    if Query(Key) in <Enter>, <GreyEnter>
        KillPosition()
    else
        PopPosition()
    endif
    AbandonFile(id)
    PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end

