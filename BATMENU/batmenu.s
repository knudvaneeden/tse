/*
   Macro:   BatMenu.
   Author:  carlo.hogeveen@xs4all.nl.
   Date:    1 May 2001.
   Version: 1.1.0.0.1 (30 August 2026).
   Updated by OpenAI GPT-5 Codex.

   This macro provides and manages a whole list of bat files
   from a single icon on the DesTop.

   The ShortCut should have a commandline something like this:

      For TsePro/16:    c:\tse\e.exe -eBatMenu
      For TsePro/32:    c:\tse32\e32.exe -eBatMenu

   Further installation:
   -  Copy this macro BatMenu.s (and optionally the data file BatMenu.dat)
      to TSE's "mac" directory, then load the macro in the editor,
      and compile it with the menu Macro Compile.

   Examples:
   -  The macro is distributed with a BatMenu.dat file which contains 40
      dummy bat files as an example. You may either delete the examples from
      within when running BatMenu, or you may delete all bat files from
      BatMenu by deleting the file BatMenu.dat. However see the known bug.

   Limitations:
   -  The macro should not be started from within a TSE session,
      because open files will be lost.

   Known bugs:
   -  If the list of bat files is empty, then you are not shown,
      that you can press the "N" key to create a first bat file.
      This is caused by a same peculiarity in TSE's List command,
      which I didn't think worth the time to program around.
*/

string bat_files [255] = ""
string bat_title [255] = ""

integer escape_means_stop = TRUE
integer bat_files_id = 0
integer old_InsertLineBlocksAbove = 0
integer view_line = 0

#ifdef WIN32
#else
   integer proc LongestLineInBuffer()
      integer result = 0
      PushPosition()
      BegFile()
      repeat
         if result < CurrLineLen()
            result = CurrLineLen()
         endif
      until not Down()
      PopPosition()
      return(result)
   end
#endif

forward proc extra_disable()

proc check_in_bat_file()
   // Precondition: the bat_view_id is current and the cursor on a filled line.
   integer org_id = GetBufferId()
   integer line_from = 0
   integer line_to   = 0
   bat_title = GetText(1,CurrLineLen())
   GotoBufferId(bat_files_id)
   if lFind("" + bat_title + "", "gi")
      Down()
      line_from = CurrLine()
      if lFind("", "")
         Up()
      else
         EndFile()
      endif
      line_to = CurrLine()
      if line_from > line_to
         GotoLine(line_from)
         InsertLine("")
         line_to = line_from
      endif
      MarkLine(line_from, line_to)
      Copy()
      if EditFile("c:\tsebat.bat", _DONT_PROMPT_)
         EmptyBuffer()
         Paste()
         SaveAs(CurrFilename(), _OVERWRITE_|_DONT_PROMPT_)
         AbandonFile()
      else
         Warn("Error: cannot edit c:\tsebat.bat")
      endif
      UnMarkBlock()
   endif
   GotoBufferId(org_id)
end

proc check_out_bat_file()
   integer org_id = GetBufferId()
   integer line_from = 0
   integer line_to   = 0
   if FileExists("c:\tsebat.bat")
      EditFile("c:\tsebat.bat", _DONT_PROMPT_)
      MarkLine(1, NumLines())
      Copy()
      AbandonFile()
      EraseDiskFile("c:\tsebat.bat")
      GotoBufferId(bat_files_id)
      if lFind("" + bat_title + "", "gi")
         Down()
         line_from = CurrLine()
         if lFind("", "")
            Up()
         else
            EndFile()
         endif
         line_to = CurrLine()
         if line_from <= line_to
            MarkLine(line_from, line_to)
            KillBlock()
         endif
         GotoLine(line_from - 1)
      else
         EndLine()
         if old_InsertLineBlocksAbove == ON
            lFind("", "b")
            InsertLine("" + bat_title + "")
         else
            if lFind("", "")
               InsertLine("" + bat_title + "")
            else
               EndFile()
               AddLine("" + bat_title + "")
               view_line = view_line + 1
            endif
         endif
      endif
      Paste()
      UnMarkBlock()
      SaveAs(CurrFilename(), _OVERWRITE_|_DONT_PROMPT_)
   endif
   GotoBufferId(org_id)
end

proc edit_bat_file()
   integer org_id = GetBufferId()
   extra_disable()
   view_line = CurrLine()
   bat_title = GetText(1, CurrLineLen())
   check_in_bat_file()
   if FileExists("c:\tsebat.bat")
      ClrScr()
      #ifdef WIN32
         Dos(LoadDir() + "e32.exe c:\tsebat.bat", _DONT_PROMPT_)
      #else
         Dos(LoadDir() + "e.exe c:\tsebat.bat", _DONT_PROMPT_)
      #endif
      if FileExists("c:\tsebat.bat")
         check_out_bat_file()
      endif
   endif
   GotoBufferId(org_id)
   PushKey(<Escape>)
   escape_means_stop = FALSE
end

proc new_copy_of_bat_file()
   integer org_id = GetBufferId()
   string new_title [255] = ""
   extra_disable()
   view_line = CurrLine()
   bat_title = GetText(1, CurrLineLen())
   new_title = bat_title
   check_in_bat_file()
   ClrScr()
   if  Ask("Give a title to the (copy of the)/(new) bat file:", new_title)
   and Trim(new_title) <> ""
      new_title = Trim(new_title)
      new_title [1] = upper(new_title [1])
      GotoBufferId(bat_files_id)
      PushPosition()
      if lFind("" + new_title + "", "gi")
         PopPosition()
         Warn("Error: title already exists")
      else
         KillPosition()
         if not FileExists("c:\tsebat.bat")
            Dos("echo. > " + "c:\tsebat.bat", _DONT_PROMPT_|_DONT_CLEAR_)
         endif
         bat_title = new_title
         check_out_bat_file()
         PushKey(<e>)
      endif
   endif
   PushKey(<Escape>)
   escape_means_stop = FALSE
   GotoBufferId(org_id)
end

proc del_bat_file()
   integer org_id = GetBufferId()
   integer line_from = 0
   integer line_to   = 0
   extra_disable()
   view_line = CurrLine()
   bat_title = GetText(1, CurrLineLen())
   GotoBufferId(bat_files_id)
   if lfind("" + bat_title + "", "gi")
      line_from = currline()
      if lfind("", "+")
         up()
      else
         endfile()
      endif
      line_to = currline()
      markline(line_from, line_to)
      killblock()
      saveas(currfilename(), _overwrite_|_dont_prompt_)
   endif
   GotoBufferId(org_id)
   PushKey(<Escape>)
   escape_means_stop = FALSE
end

proc change_title_of_bat_file()
   integer org_id = GetBufferId()
   string new_title [255] = ""
   extra_disable()
   view_line = CurrLine()
   bat_title = GetText(1, CurrLineLen())
   new_title = bat_title
   gotobufferid(bat_files_id)
   if  ask("Give a title to the bat file:", new_title)
   and trim(new_title) <> ""
      new_title = trim(new_title)
      new_title [1] = upper(new_title [1])
      if  Lower(new_title) <> Lower(bat_title)
      and lfind("" + new_title + "", "gi")
         warn("Error: the new title aready exists")
      else
         if  new_title <> bat_title
         and lfind("" + bat_title + "", "gi")
            lreplace("" + bat_title + "", "" + new_title + "", "cgin")
            saveas(currfilename(), _overwrite_|_dont_prompt_)
         endif
      endif
   endif
   GotoBufferId(org_id)
   PushKey(<Escape>)
   escape_means_stop = FALSE
end

proc move_bat_file_up()
   integer org_id = GetBufferId()
   integer old_InsertLineBlocksAbove = Set(InsertLineBlocksAbove, on)
   integer line_from = 0
   integer line_to   = 0
   extra_disable()
   view_line = currline()
   bat_title = gettext(1, currlinelen())
   if view_line > 1
      view_line = view_line - 1
      gotobufferid(bat_files_id)
      if lfind("" + bat_title + "", "gi")
         line_from = currline()
         if lfind("", "+")
            up()
         else
            endfile()
         endif
         line_to = currline()
         gotoline(line_from)
         BegLine()
         if lfind("", "b")
            markline(line_from, line_to)
            cut()
            paste()
            unmarkblock()
            saveas(currfilename(), _overwrite_|_dont_prompt_)
         endif
      endif
      GotoBufferId(org_id)
   endif
   PushKey(<Escape>)
   escape_means_stop = FALSE
   Set(InsertLineBlocksAbove, old_InsertLineBlocksAbove)
end

proc move_bat_file_down()
   integer org_id = GetBufferId()
   integer line_from = 0
   integer line_to   = 0
   extra_disable()
   view_line = currline()
   bat_title = gettext(1, currlinelen())
   if view_line < numlines()
      view_line = view_line + 1
      gotobufferid(bat_files_id)
      if lfind("" + bat_title + "", "gi")
         line_from = currline()
         if lfind("", "+")
            up()
         else
            endfile()
         endif
         line_to = CurrLine()
         gotoline(line_to)
         endline()
         if lfind("", "+")
            if lfind("", "+")
               up()
            else
               endfile()
            endif
            markline(line_from, line_to)
            cut()
            paste()
            unmarkblock()
            saveas(currfilename(), _overwrite_|_dont_prompt_)
         endif
      endif
      GotoBufferId(org_id)
   endif
   PushKey(<Escape>)
   escape_means_stop = FALSE
end

proc sort_titles_of_bat_files()
   string prev_title [255] = ""
   string next_title [255] = ""
   extra_disable()
   begfile()
   if numlines() > 1
      next_title = gettext(1, currlinelen())
      repeat
         Down()
         prev_title = next_title
         next_title = gettext(1, currlinelen())
      until Lower(prev_title) > Lower(next_title)
         or currline() == numlines()
      if lower(prev_title) > lower(next_title)
         view_line = currline()
         pushkey(<s>)
         pushkey(<u>)
      endif
   endif
   PushKey(<Escape>)
   escape_means_stop = FALSE
end

keydef extra_keys
   <D>         move_bat_file_down()
   <d>         move_bat_file_down()
   <del>       del_bat_file()
   <E>         edit_bat_file()
   <e>         edit_bat_file()
   <GreyDel>   del_bat_file()
   <N>         new_copy_of_bat_file()
   <n>         new_copy_of_bat_file()
   <S>         sort_titles_of_bat_files()
   <s>         sort_titles_of_bat_files()
   <T>         change_title_of_bat_file()
   <t>         change_title_of_bat_file()
   <U>         move_bat_file_up()
   <u>         move_bat_file_up()
end

proc extra_disable()
   Disable(extra_keys)
end

proc extra_keys_starter()
   UnHook(extra_keys_starter)
   if Enable(extra_keys)
      ListFooter("{Enter}-Execute  {Escape}-Cancel  {E}dit  {N}ewCopy  {T}itle  {U}p  {D}own  {S}ort  {Del}")
   endif
end

proc main()
   integer stop = FALSE
   integer bat_view_id = 0
   // When BATMENU.S is compiled/run from an ordinary working directory, the
   // current file is the source file and its directory is the best first
   // location for BATMENU.DAT.
   bat_files = SplitPath(CurrFilename(), _DRIVE_|_PATH_) + "BatMenu.dat"
   bat_view_id = CreateTempBuffer()
   old_InsertLineBlocksAbove = Set(InsertLineBlocksAbove, OFF)
   // Next look beside the loaded macro.  Keep the original installation-root
   // layout as the final compatibility fallback.
   if not FileExists(bat_files)
      bat_files = LoadDir() + "BatMenu.dat"
      if not FileExists(bat_files)
         bat_files = LoadDir() + "Mac\BatMenu.dat"
      endif
   endif
   if FileExists(bat_files)
      bat_files_id = EditFile(bat_files, _DONT_PROMPT_)
   else
      Warn("BatMenu 1.1.0.0.1: Cannot find BatMenu.dat beside the source, beside the macro, or in the Mac directory.")
   endif
   if bat_files_id
      repeat
         GotoBufferId(bat_view_id)
         EmptyBuffer()
         GotoBufferId(bat_files_id)
         if lFind("", "g")
            repeat
               MarkColumn(CurrLine(), 2, CurrLine(), CurrLineLen() - 1)
               bat_title = GetMarkedText()
               UnMarkBlock()
               AddLine(bat_title, bat_view_id)
            until not lRepeatFind()
         endif
         GotoBufferId(bat_view_id)
         GotoLine(view_line)
         escape_means_stop = TRUE
         Hook(_LIST_STARTUP_, extra_keys_starter)
         if List("Bat files", iif(LongestLineInBuffer() > 80, LongestLineInBuffer(), 80))
            Disable(extra_keys)
            view_line = CurrLine()
            check_in_bat_file()
            if FileExists("c:\tsebat.bat")
               Dos("c:\tsebat.bat", _DONT_PROMPT_)
               EraseDiskFile("c:\tsebat.bat")
            endif
         else
            Disable(extra_keys)
            if escape_means_stop
               stop = TRUE
            endif
         endif
      until stop
   endif
   Set(InsertLineBlocksAbove, old_InsertLineBlocksAbove)
   if bat_files_id
      AbandonFile(bat_files_id)
   endif
   AbandonFile(bat_view_id)
end
