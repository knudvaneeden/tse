/*
   Macro          AbanName
   Author         Carlo.Hogeveen@xs4all.nl
   Date           16 December 2003
   Version        3.0.2
   Date           3 August 2007
   Compatibility  TSE Pro 2.5e upwards

   From the files already opened in TSE, you can select files based on (part
   of) their drive:\path\filenames, and Abandon or Keep the selected files.

   Keeping the selected files means abandoning all others.

   Example:
      We use TSE's wonderful ability to open files without loading them.
      You open all files from some directory in TSE, e.g. "-a -s c:\*".
      Note that TSE so far only opens these files, not loads them, otherwise
      we would have a memory-problem depending on the directory's size.
      Next you use AbanName to abandon files with extensions like .bak, .exe,
      .dll, .class or whatever. You can either abandon extensions one by one,
      or all at once using a regular expression.
      Note that AbanName also does not load opened files, so we are still
      good, memory-wise.
      A typical next action would be to search in the remaining files, but
      beware that TSE's native Find command DOES load files that are opened
      but not loaded yet, so either risk that the remaining files do not fit
      in memory, or better use a macro like eFind, which also keeps unloaded
      files unloaded.

   Also see the "help_data" section below, or access Help in run-time.

   WARNING !!!

      Because this macro's functionality encourages you to open enormous
      amounts of files in TSE, it is necessary to be aware of the following
      limitation.

      While from TSE Pro 3.0 upwards TSE's documentation says you can open
      up to 2,147,483,647 files [overall during a TSE session], you can
      in TSE Pro versions 2.5 through 2.8 only load 65536 files safely,
      and in TSE Pro versions 3.0 through 4.4 only 32767 files safely.
      If you exceed that limit, then TSE becomes unstable without a warning.

      This macro does give a warning and stops if it can determine that too
      many files are loaded for your TSE version. However, it cannot always
      determine that, and then it just continues.

      The same explanation in macro language terms:
      -  In TSE Pro version 3.0 thru 4.4 the AbandonFile() command only works
         for bufferids up to and including 32676.
      -  In TSE Pro versions up to and including 4.4 bufferids above 65535
         do not occur: the next file gets bufferid 0 again.

   Installation:

      Copy this file to TSE's "mac" directory and compile it.

      Either run it from the menu with Macro Execute "AbanName",
      or assign ExecMacro("AbanName") to a key,
      or add "AbanName" to the Potpourri menu.


   History:

   v1       16 December 2003
      Initial version.

   v2       16 June 2004
      Solved a clumsy programming error causing AbanName to sometimes
      loop infinitely. Thanks for the report to Jose Adriano Baltieri,
      who also made suggestions for improvements.
      Added optionally matching whole filenames.
      Added optionally matching using MsDos expressions and TSE regular
      expressions.
      Added run-time Help.

   v3       13 August 2005
      Solved a counting error that occurred sometimes in a parallel and much
      different version of AbanName.
      Merged the nice interface of v2 with the better search-algorith of the
      parallel version of AbanName.

   v3.0.1   1 July 2007
      Solved a bug in and improved the way that the macro determines whether
      too many files were opened.

   v3.0.2   3 August 2007
      Nasty bug solved: if afterwards the current file became a file that
      hadn't been loaded yet, then it was loaded as (changed to) an empty
      file.
*/



// The following determines the editor version at compile-time.
// Note: TSE Pro versions older than 2.5 don't understand compilation
//       directives (e.g. the "#ifdef"), giving a desired compiler error,
//       which should act as a clue to the user that this macro is not
//       compatible with TSE Pro versions older than 2.5.
#ifdef EDITOR_VERSION
   // From TSE Pro 3.0 upwards the built-in constant EDITOR_VERSION exists.
#else
   #ifdef WIN32
      // From TSE Pro 2.6 upwards the built-in constant WIN32 exists.
      #define EDITOR_VERSION 0x2800
      // TSE Pro < 2.5e and TSE Pro 2.6 are not supported by this macro.
      // Note: TSE 2.5e (the Dos version of TSE) has existed so long, that
      //       almost every Dos user has upgraded to it, so supporting older
      //       versions is no longer worth the effort. Due to a bug in
      //       TSE 2.5c (and presumably older TSE 2.5 versions (which is one
      //       of the reasons for not supporting them), the line below is
      //       syntax-checked despite the lack of WIN32 in those versions,
      //       and generates a desired compiler error, which should act as a
      //       clue to the user that this macro is not compatible with TSE
      //       2.5 thru 2.5c.
      // Note: TSE 2.6 was an intermediate 32-bits version from which anyone
      //       could freely upgrade to TSE 2.8. The parameter constant
      //       _MFSKIP_ exists since TSE 2.8, so the line below will
      //       correctly generate a desired compiler error for TSE 2.6,
      //       giving a clue to the user that this macro is not compatible
      //       with TSE 2.6.
      #define TSE_UNSUPPORTED_TEST _MFSKIP_
   #else
      // Since all other TSE versions were excluded, this must be TSE 2.5e.
      #define EDITOR_VERSION 0x2500
   #endif
#endif



datadef help_data
""
"This macro abandons or keeps those loaded files, the filenames of which"
"contain or fully match the string you supply."
""
"Abandoning files means removing them from the editor without saving."
"Keeping a selection of files means abandoning all other files."
""
"Matching is done case-insensitive."
"For disk files the drive and path are part of the filename."
"AbanName does not load files that are opened but not loaded yet."
""
'"Contain" means matching the string you supply with a part of the filename.'
'"Fully match" means matching the string you supply with the whole filename.'
""
"The string you supply can have three formats:"
"   Literal text           - all characters are interpreted as themselves."
"   MsDos expression       - may contain the MsDos wildcards * and ?."
"   Regular expression     - all TSE's regular expression characters"
"                            except ^ and $ are allowed."
""
end

string method_texts [255] = "|"
                          + "containing the literal text:|"
                          + "containing the msdos expression:|"
                          + "containing the regular expression:|"
                          + "|"
                          + "matching the literal text:|"
                          + "matching the msdos expression:|"
                          + "matching the regular expression:"

proc no_op()
end

proc abanname_help()
   integer org_id = GetBufferId()
   integer hlp_id = CreateTempBuffer()
   PushBlock()
   InsertData(help_data)
   UnMarkBlock()
   PopBlock()
   List("AbanName Help", 80)
   GotoBufferId(org_id)
   AbandonFile(hlp_id)
end

keydef help_keys
   <f1> abanname_help()
end

proc prompt_startup()
   Enable(help_keys)
   WindowFooter("{F1} Help")
end

proc prompt_cleanup()
   Disable(help_keys)
end

menu action_menu()
   history
   "&Abandon"
   "&Keep"
   "",no_op(),divide
   "&Help",abanname_help()
end

menu abandon_method_menu()
   history
   title = "Abandon files with a [drive:\path\]filename"
   "containing",,divide
   "   &literal text"
   "   &msdos expression"
   "   &regular expression"
   "fully matching",,divide
   "   literal &text"
   "   ms&dos expression"
   "   re&gular expression"
   "",no_op(),divide
   "   &help",abanname_help()
end

menu keep_method_menu()
   history
   title = "Keep files with a [drive:\path\]filename"
   "containing",,divide
   "   &literal text"
   "   &msdos expression"
   "   &regular expression"
   "fully matching",,divide
   "   literal &text"
   "   ms&dos expression"
   "   re&gular expression"
   "",no_op(),divide
   "   &help",abanname_help()
end

string proc msdos_to_regexp(string expression)
   string result [255] = expression
   integer i = 1
   while i <= Length(result)
      case SubStr(result,i,1)
         when "*"
            result = SubStr(result, 1, i - 1)
                   + "."
                   + SubStr(result, i, 255)
            i = i + 1
         when "?"
            result = SubStr(result, 1, i - 1)
                   + "."
                   + SubStr(result, i + 1, 255)
         when ".", "^", "$", "|", "[", "]", "+", "@", "#", "{", "}", "\"
            result = SubStr(result, 1, i - 1)
                   + "\"
                   + SubStr(result, i, 255)
            i = i + 1
      endcase
      i = i + 1
   endwhile
   return(result)
end

integer proc match(integer tmp_id, integer method, string expression_in)
   integer org_id = GetBufferId()
   integer result = FALSE
   string expression [255] = Lower(expression_in)
   string filename [255] = Lower(CurrFilename())
   GotoBufferId(tmp_id)
   EmptyBuffer()
   AddLine(filename)
   if method == 2 // Containing a literal.
      result = lFind(expression, "g")
   else
      if method == 6 // Fully matching a literal.
         result = (  lFind(expression, "g")
                  and Length(GetFoundText()) == CurrLineLen())
      else
         case method
            when 3 // Containing an msdos expression.
               expression = "^.*" + msdos_to_regexp(expression) + ".*$"
            when 7 // Fully matching an msdos expression.
               expression = "^" + msdos_to_regexp(expression) + "$"
            when 8 // Fully matching a regular expression.
               expression = "^" + expression + "$"
//          when 1   Menu divider: not selectable.
//          when 4   Already a regular expression.
//          when 5   Menu divider: not selectable.
         endcase
         result = lFind(expression, "gx")
      endif
   endif
   GotoBufferId(org_id)
   return(result)
end

proc Main()
   integer org_id = GetBufferId()
   integer high_id = GetBufferId()
   integer tmp_id = 0
   integer start_id = 0
   integer aban_id = 0
   integer start_id_renewed = FALSE
   integer abandoned = 0
   integer kept = 0
   integer action_history = 0
   integer method_history = 0
   integer i = 0
   integer menu_option = 0
   string action [8] = ""
   string expression [255] = ""
   GotoBufferId(32767)
   if GetBufferId() == 32767
      high_id = 32767
   endif
   GotoBufferId(65535)
   if GetBufferId() == 65535
      high_id = 65535
   endif
   GotoBufferId(org_id)
   if                              high_id < 32767
   or  EDITOR_VERSION > 0x4400
   or (EDITOR_VERSION < 0x3000 and high_id < 65535)
      tmp_id = CreateTempBuffer()
      GotoBufferId(org_id)
      action_history = GetFreeHistory(SplitPath(CurrMacroFilename(), _NAME_)
                                      + ":action")
      repeat
         // Inside loop and with <home>, so after Help history works too.
         for i = 1 to Val(GetHistoryStr(action_history, 1))
            PushKey(<CursorDown>)
         endfor
         PushKey(<home>)
         action_menu()
         // Don't use the debugger menus now until MenuOption() is stored.
         menu_option = MenuOption()
      until menu_option <> 4
      if menu_option in 1, 2
         DelHistoryStr(action_history, 1)
         if menu_option in 1, 2
            AddHistoryStr(Str(menu_option - 1), action_history)
         endif
         if menu_option == 1
            action = "Abandon"
         else
            action = "Keep"
         endif
         method_history = GetFreeHistory(SplitPath(CurrMacroFilename(), _NAME_)
                                         + ":method")
         repeat
            // Inside loop and with <home>, so after Help history works too.
            for i = 1 to Val(GetHistoryStr(method_history, 1))
               PushKey(<CursorDown>)
            endfor
            PushKey(<home>)
            if action == "Abandon"
               abandon_method_menu()
            else
               keep_method_menu()
            endif
         // Don't use the debugger menus now until MenuOption() is stored.
            menu_option = MenuOption()
         until Menu_Option <> 10
         if menu_option in 2, 3, 4, 6, 7, 8
            DelHistoryStr(method_history, 1)
            if menu_option in 2, 3, 4
               AddHistoryStr(Str(menu_option - 2), method_history)
            elseif menu_option in 6, 7, 8
               AddHistoryStr(Str(menu_option - 3), method_history)
            endif
            Hook(_PROMPT_STARTUP_, prompt_startup)
            Hook(_PROMPT_CLEANUP_, prompt_cleanup)
            if Ask(action
                   + " [drive:\path\]filenames "
                   + GetToken(method_texts, "|", menu_option),
                   expression,
                   GetFreeHistory(SplitPath(CurrMacroFilename(), _NAME_)
                                  + ":Expression"))
               UnHook(prompt_startup)
               UnHook(prompt_cleanup)
               if PrevFile(_DONT_LOAD_)
               or (    NumFiles() == 1
                   and BufferType() == _NORMAL_)
                  Message("Working ...")
                  NextFile(_DONT_LOAD_)
                  start_id = GetBufferId()
                  expression = Lower(expression)
                  repeat
                     start_id_renewed = FALSE
                     if match(tmp_id, menu_option, expression) ==
                                                           (action == "Abandon")
                        aban_id = GetBufferId()
                        if aban_id == start_id
                           NextFile(_DONT_LOAD_)
                           AbandonFile(aban_id)
                           start_id = GetBufferId()
                           start_id_renewed = TRUE
                           PrevFile(_DONT_LOAD_)
                        else
                           PrevFile(_DONT_LOAD_)
                           AbandonFile(aban_id)
                        endif
                        abandoned = abandoned + 1
                     else
                        kept = kept + 1
                     endif
                     NextFile(_DONT_LOAD_)
                  until NumFiles() == 0
                     or (start_id_renewed == FALSE and GetBufferId() == start_id)
                  // Ensure the current file is loaded.
                  NextFile(_DONT_LOAD_)
                  PrevFile()
                  Message(abandoned, " files abandoned, ", kept, " files kept.")
               else
                  Message("No action. There are no files.")
               endif
            else
               UnHook(prompt_startup)
               UnHook(prompt_cleanup)
               Message("No action. There are ", NumFiles(), " files.")
            endif
         else
            Message("No action. There are ", NumFiles(), " files.")
         endif
      else
         Message("No action. There are ", NumFiles(), " files.")
      endif
      GotoBufferId(org_id)
   else
      Warn("TSE version unstable for this many files: see doc in AbanName.s  ")
   endif
   PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end

