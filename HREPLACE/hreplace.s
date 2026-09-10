/*
   Macro             hReplace
   Author            Carlo.Hogeveen@xs4all.nl
   Date              19 November 2006
   Compatibility     TSE Pro 2.5e upwards
   Version           1.0.0

   (  Un unofficial version of this macro was posted as "mReplace".
      It has been renamed to the much more appropriate "hReplace".
      No other changes were made. )

   This macro works exactly like TSE's standard Replace, except that it uses
   its own histories, so the Replace command will not use the same histories
   as the Find command.

   There are many ways to install this macro. Here are two main ones:
   Installation possibility 1:
      Put this macro in TSE's "mac" directory, and compile it.
      In TSE's win.ui file (or the .ui file you are actually using)
      replace " Replace()" with " ExecMacro('hReplace')",
      and recompile the .ui file.
      Don't forget the leading space!
   Installation possibility 2:
      Put this macro in TSE's "mac" directory.
      Delete the "PurgeMacro(macroname)" line.
      AFTER the last "end" line, add a line that looks like
         <ctrl h> Main()
      using your own favourite key of course. A key definition here will
      overrule a key definition in a .ui file.
      Recompile the macro.
      Add the macro to the Macro AutoLoad List.
      This way you leave your .ui file intact, which is a lifesaver if you
      ever have to upgrade to a new TSE version. The downside (?) is that
      you have not changed the Replace in TSE's Search menu.
*/

// Start of copied part from the .ui file.
string chart_title[] = "DEC HEX CHAR"
/****************************************************************************
  Display an ascii chart.
 ***************************************************************************/
proc mAsciiChart()
    integer i, ok, c, cur_id

    c = CurrChar()
    cur_id = GetBufferId()
    AbandonFile(GetBufferId("*AsciiChart*"))
    if CreateBuffer("*AsciiChart*", _SYSTEM_)
        if NumLines() == 0
            for i = 0 to 255
                if not AddLine(Format(i:5, Str(i, 16):4, Chr(i):4))
                    break
                endif
            endfor
        endif
        BegFile()
        if c > 0
            GotoLine(c + 1)
        endif
        ok = List(chart_title, Length(chart_title) + 6)
        i = CurrLine() - 1
        GotoBufferId(cur_id)
        if ok
            InsertText(Chr(i))
        endif
    endif
end
// End of copied part from the .ui file.

keydef extra_prompt_key
   <ctrl a> mAsciiChart()
end

proc enable_extra_prompt_key()
   if Enable(extra_prompt_key)
      WindowFooter("{Ctrl A}-Ascii Chart")
   endif
end

proc disable_extra_prompt_key()
   UnHook(enable_extra_prompt_key)
   Disable(extra_prompt_key)
end

proc Main()
   string macroname  [255] = SplitPath(CurrMacroFilename(), _NAME_)
   string search_for [255] =
            GetHistoryStr(GetFreeHistory(macroname + ":search_for"     ), 1)
   string replace_with [255] =
            GetHistoryStr(GetFreeHistory(macroname + ":replace_with"   ), 1)
   string replace_options [11] =
            GetHistoryStr(GetFreeHistory(macroname + ":replace_options"), 1)
   Hook(_PROMPT_STARTUP_, enable_extra_prompt_key)
   if  Ask("Search for:",
           search_for,
           GetFreeHistory(macroname + ":search_for"))
   and Ask("Replace with:",
           replace_with,
           GetFreeHistory(macroname + ":replace_with"))
      disable_extra_prompt_key()
      if Ask("[ABGLIWNX] (All-files Back Global Local Ignore-case Words No-prompt reg-eXp):",
             replace_options,
             GetFreeHistory(macroname + ":replace_options"))
         Replace(search_for, replace_with, replace_options)
      endif
   else
      disable_extra_prompt_key()
   endif
   PurgeMacro(macroname)
end

