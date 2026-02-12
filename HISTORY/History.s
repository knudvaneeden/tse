/*
   Macro          History
   Author         Carlo Hogeveen
   Website        eCarlo.nl/tse
   Compatibility  TSE Pro 4 upwards
   Version        v5.0.8   17 Sep 2022

   Purpose:
      Avoid history lists deleting each other.

      Get an overview of all history lists with their names.

      Delete an entire history list.

      Continuously remove strings that contain certain expressions from
      certain history lists. For instance automatically remove temporary
      files or macros executed with "-e" from the _EDIT_HISTORY_ list.

      See the Help for details.

   Install:
      Put the files History.s and History.hlp in TSE's "mac" directory,
      then compile History.s.
      Execute Macro "History" to configure it.

   Note:
      Finished and uploaded versions of my macros are at Semware's website at
         http://www.semware.com
      Beta versions or not yet uploaded versions of my macros are at
         http://www.xs4all.nl/~hyphen/tse

   Whish List:
      History resorted by reopening file.
      History sharing across TSE sessions.
      Separate histories for files and directories.



   HISTORY

   v1   21 feb 1999
      Initial version, not released.

   v2   22 feb 1999
      Released as "MaxHist".
      This version also maximizes MaxHistoryPerList if there are very few
      history lists.

   v3   19 oct 2001
      Not released, I don't know why.
      This version 3 solves a problem: when opening TSE 3.0 with the menu
      and choosing New, there is no history list in id 6 loaded yet, so
      the macro erroneously thinks that there are 0 history lists.

   v4   13 nov 2004
      Not released because it had no significant functional changes.
      Version 4 renames the macro from MaxHist to the more general
      name History, because I envisioned several other possible
      optimizations to the way TSE handles history lists.
      The macro was adapted too to prepare it for the ability to handle
      other functions, but no other functions were added yet.

   v5.0.1   feb/mar 2007
      Using TSE from WinSCP clutters TSE's history list with temporary
      files. Very annoying. Time to add the ability to auto-delete
      entries from history lists using simple or regular expressions.

   v5.0.2   10 mar 2007
      Bug solved: Closing TSE hanged if no cleanup rules were defined,
      which was not the default, so there is hope that not too many people
      encountered it.

   v5.0.3   11 mar 2007
      Renamed "Exclude Rules" to "Cleanup Rules", which is more
      appropriate, because history entries are deleted some time AFTER
      entering a history list.
      Bug solved: The History macro got confused if you tried to
      define Cleanup Rules for history list 10 or 13. To solve it the
      format of the History.not configuration file was changed: if a user
      has this file in the old format, then it is automatically converted
      to the new format.

   v5.0.4   13 mar 2007
      Bug solved: a harmless warning at TSE's startup was removed.
      It happened for people with a small number of history lists.

   v5.0.5   17 mar 2007
      Bug solved: When showing the overview of history lists, the number
      instead of the name of the _GOTOLINE_HISTORY_ was shown.
      Bug solved: If you had defined "^$" as a cleanup rule, then TSE
      hanged when you tried to close it.

   v5.0.6   29 mar 2007
      Optimized the Help file.
      Do a cleanup of a history list just before viewing it: this also
      makes a new or modified Cleanup Rule immediately effective.

   v5.0.7   4 Jan 2019
      Made saving the TSE settings a question.

   v5.0.8   17 Sep 2022
      Fixed incompatibility with TSE's '-i' command line option
      and the TSELOADDIR environment variable.

*/

#define HISTORY_BUFFER            6
#define CMD_VIEW_HISTORY_LIST   257
#define CMD_DELETE_HISTORY_LIST 258
#define CMD_DELETE_HISTORY_ITEM 259
#define CMD_EDIT_CLEANUP_RULES  260
#define CMD_ADD_CLEANUP_RULE    261
#define CMD_EDIT_CLEANUP_RULE   262
#define CMD_DELETE_CLEANUP_RULE 263

string not_file          [255] = ""
string macroname         [255] = ""
string regular_expression [21] = "regular expression   "
string  simple_expression [21] = " simple expression   "

integer not_id = 0
integer history_sizes_checked = FALSE
integer idle_period = 18 * 300
integer idle_remaining = 9
integer tmp_hist_id = 0

proc show_help()
   integer org_id = GetBufferId()
   integer tmp_id = EditBuffer(SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_|_NAME_) + ".hlp", _SYSTEM_)
   List("History Help", LongestLineInBuffer())
   GotoBufferId(org_id)
   AbandonFile(tmp_id)
end

proc check_history_sizes()
   integer changes = FALSE
   integer minimum = 1
   integer maximum = MAXINT / 2
   integer between = 0
   integer h_no = 0
   integer histories = 0
   integer old_msglevel
   integer old_maxhistorysize = Query(MaxHistorySize)
   integer old_maxhistoryperlist = Query(MaxHistoryPerList)

   for h_no = 1 to 255
      if NumHistoryItems(h_no)
         histories = histories + 1
      endif
   endfor
   if histories > 0
      // Set persistent history on.
      if Query(PersistentHistory) <> ON
         Set(PersistentHistory, ON)
         changes = TRUE
      endif

      // Set MaxHistorySize to TSE's maximum.
      old_msglevel = Set(MsgLevel, _NONE_)
      repeat
         between = (minimum + maximum) / 2
         Set(MaxHistorySize, between)
         if Query(MaxHistorySize) == between
            minimum = between
         else
            maximum = between
         endif
      until maximum - minimum < 2
      Set(MsgLevel, old_msglevel)
      if Query(MaxHistorySize) <> old_MaxHistorySize
         changes = TRUE
      endif

      // Make all historylists of equal size, so TSE doesn't make them
      // push out each others values.
      //
      // First set MaxHistoryPerList temporarily to TSE's maximum.
      old_msglevel = Set(MsgLevel, _NONE_)
      minimum = 1
      maximum = Query(MaxHistorySize)
      repeat
         between = (minimum + maximum) / 2
         Set(MaxHistoryPerList, between)
         if Query(MaxHistoryPerList) == between
            minimum = between
         else
            maximum = between
         endif
      until maximum - minimum < 2
      Set(MsgLevel, old_msglevel)

      // If there are too many history lists then reduce each to an equal
      // maximum historysize per list.
      if histories > 0
      and Query(MaxHistorySize) / histories < Query(MaxHistoryPerList)
         Set(MaxHistoryPerList, Query(MaxHistorySize) / histories)
      endif
      if Query(MaxHistoryPerList) <> old_MaxHistoryPerList
         changes = TRUE
      endif

      // Save any changed TSE settings.
      if changes
         if YesNo('The TSE history settings have been optimized. Save all TSE settings now?') == 1
            SaveSettings()
         endif
         UpdateDisplay()
      endif

      // Mark that history sizes have been checked.
      history_sizes_checked = TRUE
   endif
end

proc fill_hist(integer hist_no)
   integer org_id = GetBufferId()
   integer i = 0
   GotoBufferId(tmp_hist_id)
   EmptyBuffer()
   for i = 1 to NumHistoryItems(hist_no)
      AddLine(GetHistoryStr(hist_no, i))
   endfor
   BegFile()
   if CurrLineLen() == 0
      KillLine()
   endif
   GotoBufferId(org_id)
end

proc check_hist(integer hist_no, string find_string, string find_options)
   integer org_id = GetBufferId()
   GotoBufferId(tmp_hist_id)
   while lFind(find_string, find_options)
      DelHistoryStr(hist_no, CurrLine())
      KillLine()
   endwhile
   GotoBufferId(org_id)
end

proc check_cleanup_rules()
   integer org_id = GetBufferId()
   integer prev_hist = 0
   integer curr_hist = 0
   string find_options  [4] = ""
   string find_string [255] = ""
   if not_id
      GotoBufferId(not_id)
      BegFile()
      repeat
         if CurrLineLen() > 0
            curr_hist = CurrChar()
            if curr_hist <> prev_hist
               fill_hist(curr_hist)
            endif
            if GetText(2, Length(simple_expression)) == simple_expression
               find_options = "bgi"
            else
               find_options = "bgix"
            endif
            find_string = GetText(Length(simple_expression) + 2, 255)
            check_hist(curr_hist, find_string, find_options)
         endif
      until not Down()
      GotoBufferId(org_id)
   endif
end

proc idle()
   if idle_remaining > 0
      idle_remaining = idle_remaining - 1
   else
      idle_remaining = idle_period
      if history_sizes_checked
         check_cleanup_rules()
      else
         // Check history sizes only once after editor-startup, to avoid
         // saving TSE-settings when the user might be changing TSE-settings.
         check_history_sizes()
      endif
   endif
end

proc on_abandon_editor()
   // TSE's close button bug needs no work-around in this macro.
   check_cleanup_rules()
end

proc WhenLoaded()
   integer org_id = GetBufferId()
   macroname = SplitPath(CurrMacroFilename(), _NAME_)
   not_file  = SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_|_NAME_) + ".not"
   not_id    = CreateTempBuffer()
   if not LoadBuffer(not_file, -2)
      if CurrLineLen() > 0
         // In versions 5.0.0 thru 5.0.2 this configuration file was in
         // normal format, not in the binary "-b-2" format.
         // It appears that this user still has a configuration file in the
         // old format. We will try to convert it to the new format.
         Message("Converting History.not from old to new format ...")
         BegFile()
         while NumLines() > 1
         and   JoinLine()
         endwhile
         lReplace("\d013\d010", "\n", "gnx")
         PushBlock()
         BegFile()
         MarkChar()
         EndFile()
         MarkChar()
         CutToWinClip()
         PasteFromWinClip()
         UnMarkBlock()
         PopBlock()
         EndFile()
         if CurrLineLen() == 0
            KillLine()
            Up()
         endif
         BinaryMode(-2)
         SaveAs(not_file, _OVERWRITE_)
         Delay(36)
      endif
   endif
   tmp_hist_id = CreateTempBuffer()
   GotoBufferId(org_id)
   Hook(_IDLE_, idle)
   Hook(_ON_ABANDON_EDITOR_, on_abandon_editor)
end

proc toggle_interfering()
   if GetProfileStr(macroname, "Independent", "No") == "Yes"
      WriteProfileStr(macroname, "Independent", "No")
   else
      WriteProfileStr(macroname, "Independent", "Yes")
   endif
end

keydef keys_for_cleanup_rules
   <Ins>       EndProcess(CMD_ADD_CLEANUP_RULE)
   <GreyIns>   EndProcess(CMD_ADD_CLEANUP_RULE)
   <Enter>     EndProcess(CMD_EDIT_CLEANUP_RULE)
   <GreyEnter> EndProcess(CMD_EDIT_CLEANUP_RULE)
   <Del>       EndProcess(CMD_DELETE_CLEANUP_RULE)
   <GreyDel>   EndProcess(CMD_DELETE_CLEANUP_RULE)
end

proc enable_keys_for_cleanup_rules()
   UnHook(enable_keys_for_cleanup_rules)
   if Enable(keys_for_cleanup_rules)
      ListFooter(' {Enter} - Edit     {Ins} - Add     {Del} - Delete ')
   endif
end

proc disable_keys_for_cleanup_rules()
   Disable(keys_for_cleanup_rules)
end

proc edit_cleanup_rules(integer h_no, string h_name)
/*
   Note:
      TSE erroneously doesn't show a list's window footer for empty lists.
      Work-around: add a dummy empty line when the list is empty, remove it
      when the list becomes not empty.
*/
   integer org_id           = GetBufferId()
   integer tmp_id           = CreateTempBuffer()
   integer selected         = 0
   integer rule_line        = 0
   integer old_ilba         = Set(InsertLineBlocksAbove, OFF)
   integer rules_changed    = FALSE
   string rule_type   [255] = ""
   string rule_string [255] = ""
   if not_id
      GotoBufferId(not_id)
      BegFile()
      repeat
         if CurrChar() == h_no
            MarkLine(CurrLine(), CurrLine())
            Copy()
            GotoBufferId(tmp_id)
            Paste()
            UnMarkBlock()
            Down()
            BegLine()
            DelChar()
            GotoBufferId(not_id)
         endif
      until not Down()
      GotoBufferId(tmp_id)
      if NumLines()    == 0
      or CurrLineLen() == 0
         InsertLine("")
      endif
      repeat
         if rule_line == 0
            BegFile()
         else
            GotoLine(rule_line)
            if CurrLine() <> rule_line
               EndFile()
            endif
         endif
         Hook(_LIST_STARTUP_, enable_keys_for_cleanup_rules)
         selected = List(Format("Cleanup Rules for history:   Number = ",
                                h_no, "   Name = ", h_name),
                         LongestLineInBuffer())
         rule_line = CurrLine()
         disable_keys_for_cleanup_rules()
         case selected
            when CMD_EDIT_CLEANUP_RULE
               if CurrLineLen() == 0
                  selected = FALSE
               else
                  selected = YesNo(Format('Rule type stays "',
                                          Trim(GetText(1, Length(simple_expression))),
                                          '"?'))
               endif
               if selected
                  if selected == 2
                     if rule_type == simple_expression
                        rule_type = regular_expression
                     else
                        rule_type = simple_expression
                     endif
                  else
                     rule_type = GetText(1, Length(simple_expression))
                  endif
                  rule_string = GetText(Length(simple_expression) + 1, 255)
                  Message("History:   Number = ", h_no, "   Name = ", h_name)
                  Set(X1, 1)
                  Set(Y1, 3)
                  if Ask(Format("Cleanup history items containing the ",
                                Trim(rule_type), ":"),
                         rule_string)
                  and rule_string <> ""
                     BegLine()
                     KillToEol()
                     InsertText(rule_type + rule_string)
                     rules_changed = TRUE
                  endif
               endif
            when CMD_ADD_CLEANUP_RULE
               selected =  MsgBoxEx("Type of new cleanup rule?",
                                    "See TSE's Help, Table of Contents, Regular Expressions."
                                    + Chr(13) + Chr(13)
                                    + "Will the new Cleanup Rule be expressed by a simple expression or a regular expression?",
                                    "&Simple;&Regular")
               if selected
                  if selected == 1
                     rule_type = simple_expression
                  elseif selected == 2
                     rule_type = regular_expression
                  endif
                  Message("History:   Number = ", h_no, "   Name = ", h_name)
                  Set(X1, 1)
                  Set(Y1, 3)
                  if Ask(Format("Cleanup history items containing the ",
                                Trim(rule_type), ":"),
                         rule_string)
                  and rule_string <> ""
                     BegFile()
                     InsertLine(rule_type + rule_string)
                     rules_changed = TRUE
                     if lFind("^$", "gx")
                        KillLine()
                        BegFile()
                     endif
                  endif
               endif
            when CMD_DELETE_CLEANUP_RULE
               if KillLine()
                  rules_changed = TRUE
                  rules_changed = rules_changed
               endif
               BegFile()
               if NumLines()    == 0
               or CurrLineLen() == 0
                  InsertLine("")
               endif
         endcase
      until not selected
      if rules_changed
         GotoBufferId(not_id)
         while lFind(Chr(h_no), "g^")
            KillLine()
         endwhile
         GotoBufferId(tmp_id)
         BegFile()
         if  NumLines()    > 0
         and CurrLineLen() > 1
            lReplace("^", "\" + Chr(h_no), "gnx")
            MarkLine(1, NumLines())
            Copy()
            GotoBufferId(not_id)
            EndFile()
            Paste()
            UnMarkBlock()
            SaveAs(not_file, _OVERWRITE_)
         endif
      endif
   endif
   Set(InsertLineBlocksAbove, old_ilba)
   GotoBufferId(org_id)
   AbandonFile(tmp_id)
end

keydef keys_for_history_list
   <Enter>     EndProcess(CMD_EDIT_CLEANUP_RULES)
   <GreyEnter> EndProcess(CMD_EDIT_CLEANUP_RULES)
   <Del>       EndProcess(CMD_DELETE_HISTORY_ITEM)
   <GreyDel>   EndProcess(CMD_DELETE_HISTORY_ITEM)
end

proc enable_keys_for_history_list()
   UnHook(enable_keys_for_history_list)
   if Enable(keys_for_history_list)
      ListFooter(' {Enter} - Edit "Cleanup Rules"     {Del} - Delete history item ')
   endif
end

proc disable_keys_for_history_list()
   Disable(keys_for_history_list)
end

proc view_history_list(integer h_no, string h_name, integer h_entries)
   integer org_id   = GetBufferId()
   integer tmp_id   = CreateTempBuffer()
   integer item_no  = 0
   integer selected = 0
   integer h_line   = 0
   repeat
      check_cleanup_rules() // Cleanup the history list before viewing it.
      EmptyBuffer()
      for item_no = 1 to NumHistoryItems(h_no)
         AddLine(GetHistoryStr(h_no, item_no))
      endfor
      if h_line == 0
         BegFile()
      else
         GotoLine(h_line)
         if CurrLine() <> h_line
            EndFile()
         endif
      endif
      Hook(_LIST_STARTUP_, enable_keys_for_history_list)
      selected = List(Format("History:   Number = ", h_no, "   Name = ",
                             h_name, "   Entries = ", h_entries),
                      LongestLineInBuffer())
      h_line  = CurrLine()
      item_no = h_line
      disable_keys_for_history_list()
      case selected
         when CMD_DELETE_HISTORY_ITEM
            DelHistoryStr(h_no, item_no)
         when CMD_EDIT_CLEANUP_RULES
            edit_cleanup_rules(h_no, h_name)
      endcase
   until not selected
   GotoBufferId(org_id)
   AbandonFile(tmp_id)
end

string proc get_freehistory_name(integer h_no)
   integer org_id = GetBufferId()
   string h_name [255] = ""
   GotoBufferId(HISTORY_BUFFER)
   PushPosition()
   if lFind("^\" + Chr(h_no), "gx")
      h_name = GetText(2, 255)
      PopPosition()
   else
      KillPosition()
   endif
   GotoBufferId(org_id)
   return(h_name)
end

string proc get_history_name(integer h_no)
   string h_name [255] = ""
   case h_no
      when _EDIT_HISTORY_           h_name = "_EDIT_HISTORY_"
      when _NEWNAME_HISTORY_        h_name = "_NEWNAME_HISTORY_"
      when _EXECMACRO_HISTORY_      h_name = "_EXECMACRO_HISTORY_"
      when _LOADMACRO_HISTORY_      h_name = "_LOADMACRO_HISTORY_"
      when _KEYMACRO_HISTORY_       h_name = "_KEYMACRO_HISTORY_"
      when _GOTOLINE_HISTORY_       h_name = "_GOTOLINE_HISTORY_"
      when _GOTOCOLUMN_HISTORY_     h_name = "_GOTOCOLUMN_HISTORY_"
      when _REPEATCMD_HISTORY_      h_name = "_REPEATCMD_HISTORY_"
      when _DOS_HISTORY_            h_name = "_DOS_HISTORY_"
      when _FINDOPTIONS_HISTORY_    h_name = "_FINDOPTIONS_HISTORY_"
      when _REPLACEOPTIONS_HISTORY_ h_name = "_REPLACEOPTIONS_HISTORY_"
      when _FIND_HISTORY_           h_name = "_FIND_HISTORY_"
      when _REPLACE_HISTORY_        h_name = "_REPLACE_HISTORY_"
      when _FILLBLOCK_HISTORY_      h_name = "_FILLBLOCK_HISTORY_"
      when _HELP_SEARCH_HISTORY_    h_name = "_HELP_SEARCH_HISTORY_"
      otherwise                     h_name = get_freehistory_name(h_no)
   endcase
   return(h_name)
end

keydef keys_for_histories_list
   <Enter>     EndProcess(CMD_VIEW_HISTORY_LIST)
   <GreyEnter> EndProcess(CMD_VIEW_HISTORY_LIST)
   <Del>       EndProcess(CMD_DELETE_HISTORY_LIST)
   <GreyDel>   EndProcess(CMD_DELETE_HISTORY_LIST)
end

proc enable_keys_for_histories_list()
   UnHook(enable_keys_for_histories_list)
   if Enable(keys_for_histories_list)
      ListFooter(" {Enter} - View history list     {Del} - Delete history list ")
   endif
end

proc disable_keys_for_histories_list()
   Disable(keys_for_histories_list)
end

proc list_history_lists()
   integer org_id = GetBufferId()
   integer tmp_id = CreateTempBuffer()
   integer h_no = 0
   integer selected = FALSE
   integer h_entries = 0
   integer h_line = 0
   string  h_name [255] = ""
   string  old_wordset [32] = Set(WordSet, ChrSet("\d033-\d255"))
   repeat
      EmptyBuffer()
      for h_no = 0 to 255
         if GetHistoryStr(h_no, 1) <> ""
            AddLine(Format(h_no:21, " ", get_history_name(h_no):-24, " ",
                           NumHistoryItems(h_no):10))
         endif
      endfor
      BegFile()
      if h_line == 0
         lFind("_EDIT_HISTORY_", "g")
         h_line = CurrLine()
      else
         if CurrLine() <> h_line
         and not GotoLine(h_line)
            EndFile()
         endif
      endif
      Hook(_LIST_STARTUP_, enable_keys_for_histories_list)
      selected = List("History:   Number Name                        Entries", 1)
      disable_keys_for_histories_list()
      if selected
         h_line = CurrLine()
         lFind("[0-9]", "cgx")
         h_no = Val(GetWord())
         Right(Length(GetWord()) + 2)
         h_name = GetWord()
         WordRight()
         h_entries = Val(GetWord())
      endif
      case selected
         when CMD_VIEW_HISTORY_LIST
            view_history_list(h_no, h_name, h_entries)
         when CMD_DELETE_HISTORY_LIST
            DelHistory(h_no)
      endcase
   until not selected
   Set(WordSet, old_wordset)
   GotoBufferId(org_id)
   AbandonFile(tmp_id)
end

menu configuration_menu()
   title = "History Configuration"
   history
   " ",,_MF_SKIP_
   "&Help", show_help(), _MF_DONT_CLOSE_
   " ",,_MF_SKIP_
   "&Independent History Lists"
      [GetProfileStr(macroname, "Independent", "No"):3],
      toggle_interfering(),
      _MF_DONT_CLOSE_,
      "TSE default: one history list can grow by deleting elements from another list"
   " ",,_MF_SKIP_
   "&Options per history list ...", list_history_lists(),,
      "Start by listing the history lists that are actually used"
   " ",,_MF_SKIP_
   "&Escape                 (when you are done)",,,
      "Changes were effective immediately, so just exit the menu"
   " ",,_MF_SKIP_
end

proc configure()
   integer original_id = GetBufferId()
   integer autoload_id  = 0
   integer is_autoload_macro = FALSE
   repeat
      configuration_menu()
      // Warn(MenuOption())
   until not (MenuOption() in 2, 6)
   if not_id > 0
   or GetProfileStr(macroname, "Independent", "No") == "Yes"
      autoload_id = EditBuffer(LoadDir() + "tseload.dat", _SYSTEM_)
      if autoload_id
         is_autoload_macro = lFind(macroname, "giw")
         GotoBufferId(original_id)
         AbandonFile(autoload_id)
         if not is_autoload_macro
            AddAutoLoadMacro(macroname)
         endif
      endif
      AddAutoLoadMacro(macroname)
   else
      RemoveProfileSection(macroname)
      DelAutoLoadMacro(macroname)
      PurgeMacro(macroname)
   endif
end

proc Main()
   configure()
end

