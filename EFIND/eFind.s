/*
   Macro          EFind
   Author         Carlo.Hogeveen@xs4all.nl
   Date           13 October 2000
   Version        2.0.2
   Date           1 July 2006
   Compatibility  TSE Pro 2.5e upwards

   This macro allows you to search in a gigantic amount of open files.

   When more files are opened in TSE than fit in memory, then this
   macro can search across them without running into the memory limit.

   EFind relies on TSE's standard ability to open but not load files.
   For example, if you open multiple files in TSE using wildcards and the
   "-a" and "-s" options, then TSE only actually loads the file that becomes
   the new current file. The other files are "opened but not loaded", until
   you give a command that accesses their content. TSE's standard Find is
   such a command. When eFind searches across files, it only temporarily
   loads each unloaded file and then immediately unloads each of those those
   from memory again.

   Tip:
      Also see the AbanName macro, which can Abandon or Keep opened files
      based on their name, also without permanently loading unloaded files.

   Caveats:
   -  In TSE versions below 3.0 this macro changes each file's bufferid,
      which might upset other macros which depend on files always keeping
      their original bufferid.
   -  While this macro keeps files unloaded when possible, there are other
      macros and TSE commands which load all files anyway, getting your
      memory limit problem right back. It is your own responsibility not to
      use those other commands while using eFind on more files than fit in
      memory.

   There are some differences with the standard Find command, among which:
   -  Found words are not highlighted.
   -  In a View Finds list the file lines are not colored.
   -  The "n" option is assumed, it's absence will be ignored.

   Limitations:
      Because this macro's functionality encourages you to open enormous
      amounts of files in TSE, it is necessary to be aware of the following
      TSE-limitations.
      While according to its documentation from TSE Pro 3.0 upwards you can
      open up to 2,147,483,647 files, it is not safe to do so until TSE Pro
      versions after 4.4.
      Details in macro language:
      -  In TSE Pro version 3.0 thru 4.4 the AbandonFile() command only works
         for the first 32768 files.
      -  In TSE versions up to and including 4.4 bufferids above 65535 are not
         supported.
      -  Both TSE itself and macros rely heavily on both these features.
      Details in English:
      -  TSE Pro versions below 3.0 are unstable if you have
         loaded more than 65536 files during a TSE session.
      -  TSE Pro versions from  3.0 through 4.4 are unstable if you have
         loaded more than 32768 files during a TSE session.
      EFind checks for these limitations, and refuses to run if you have
      exceeded them.

   Formats:
      efind             (interactive mode)
      efind find        (interactive mode)
      efind find&do     (interactive mode)
      efind again
      efind find search_value search_options

      efind l           (low-level interactive mode)
      efind lfind       (low-level interactive mode)
      efind lfind&do    (low-level interactive mode)
      efind lagain
      efind lfind search_value search_options

   Installation:
      Copy this macro's source to TSE's "mac" directory and compile it there.
      It can be executed from the menu or attached to keys with the formats
      above.

   The beta versions of my macros can be found at:
      http://www.xs4all.nl/~hyphen/tse

   Wishlist (in random order):
      Integrate the bFind macro and add the "o" option to
      add Logical/Boolean Finds to the functionality.
      Replace.
      Extra "Find & Do" choices:
      -  Tse commands.
      S option to make searches span across lines.
      S option to replace across lines (also joining and splitting lines).
      <Ctrl E> to edit found lines in all files at once.
      Implementing TSE's standard N option.
      Adding a P option to Preview replacements.
      To hilight found strings.


   History:

   v0.00    Multiple not public releases from 13 October 2000 onwards.

      14 November 2000.
         Solved a bug, and added the <alt e> key to edit the found list.
      15 November 2000.
         The macro now returns the number of found lines as a string
         in TSE's MacroCmdLine variable.
         Note: If the user presses Escape in the found list we get after using
         the "v" option, then zero is returned.
         Added the "l" functions to emulate TSE's low-level lFind and lReplace
         commands: no messages and no beeps.
      16 November 2000.
         Bug solved: the "a" option should only cause a search to start at the
         begin or end of the current file when combined with the "v" option.
         Also a close current line for the view list is determined.
      19 November 2000.
         Bug solved: When using option "a", it changed the cursor position
         in files it traversed.
         Very nasty bug solved: TSE has a limit of 65535 bufferids.
         Solution: reduced bufferids by reusing adminfinds_id and
         viewfinds_id instead of creating them anew for each call to eFind.
         Bug anticipated: now using an id-independent push_position, etc.
      12 March 2001.
         Adding optimizations for TSE 3.00.
      24 June 2005.
         Abandon File and Keep File implemented.
         Showing a progress percentage.

   v1.00    18 August 2005    First public release.

      Programmed a warning about the "number of files limitation" existing
      in TSE itself.

   v2.00    29 April 2006

      Altered checking TSE's version number.

      Removed eFind's dependency on Global.zip and MacPar3.zip: the cost
      is the loss in some functionality when passing parameters to the
      macro, for which functionality I have a strong indication that
      nobody was using it anyway.

      Removed very annoying warnings about split lines, at the risk of
      possibly removing some significant TSE-warnings warnings too.

   v2.01    4 May 2006

      Removed the not implemented "Replace" option from the menu and from
      the documentation.

      Added a pre-emptive check (including for regular expressions) to warn
      the user, that it is pointless to search for an empty string.

   v2.0.2   1 July 2007
      Solved a bug in and improved the way that the macro determines whether
      too many files were opened.

*/

/*

File: Source: FILE_ID.DIZ]

(Jul 1, 2007) - eFind v2.0.2 for TSE Pro v2.5e upwards.
This macro allows you to search in a gigantic amount of files.
TSE lets you open more files than fit in memory, and then this macro can
search across them without running into the memory limit.
It can also keep or abandon files which contain a certain string: you can do
this multiple times to step by step zero in on a selection of files.
v2.0.2 Improves the warning if too many files were opened.
Author: Carlo Hogeveen.

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



// Give readable names to numbers.
#define horizontal_tab 9
#define space 32

// Global variables.
integer adminfinds_id             = 0
integer viewfinds_id              = 0
integer bannedfiles_id            = 0
integer start_id                  = 0
integer start_line                = 0
integer start_column              = 0
integer ids_checked               = 0
integer find_history              = 0
integer replace_history           = 0
integer option_history            = 0
integer highlevel                 = TRUE
integer parameter_no              = 0
string  prev_search_value   [255] = ""
string  prev_search_options  [25] = ""
string  result              [255] = ""

#if EDITOR_VERSION < 0x3000
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

/*
   If the editor_version is before TSE 3.00,
   these three procedures use filenames instead of file-ids,
   because of the non-fixed file-ids caused by the this macro.
*/
#if EDITOR_VERSION >= 0x3000
   proc push_position()
      PushPosition()
   end
   proc pop_position()
      PopPosition()
   end
   proc kill_position()
      KillPosition()
   end
#else
   integer efind_position = 0
   proc push_position()
      efind_position = efind_position + 1
      SetGlobalStr("efind_position_" + Str(efind_position) + "_name",
                   CurrFilename())
      SetGlobalInt("efind_position_" + Str(efind_position) + "_line",
                   CurrLine())
      SetGlobalInt("efind_position_" + Str(efind_position) + "_column",
                   CurrCol())
   end
   proc pop_position()
      GotoBufferId(GetBufferId(GetGlobalStr("efind_position_" +
                                                Str(efind_position) + "_name")))
      GotoLine(GetGlobalInt("efind_position_" + Str(efind_position) + "_line"))
      GotoColumn(GetGlobalInt("efind_position_" + Str(efind_position) +
                                                                     "_column"))
      DelGlobalVar("efind_position_" + Str(efind_position) + "_name")
      DelGlobalVar("efind_position_" + Str(efind_position) + "_line")
      DelGlobalVar("efind_position_" + Str(efind_position) + "_column")
      efind_position = efind_position - 1
   end
   proc kill_position()
      DelGlobalVar("efind_position_" + Str(efind_position) + "_name")
      DelGlobalVar("efind_position_" + Str(efind_position) + "_line")
      DelGlobalVar("efind_position_" + Str(efind_position) + "_column")
      efind_position = efind_position - 1
   end
#endif

// The following function determines the minimum amount of characters that a
// given regular expression can match. For practical purposes "^" and "$"
// are pretended to have length 1.
// The use of this macro is, that eFind (and the user) can beforehand avoid
// searching for an empty string, which is logically pointless.

#define THIS_TIME 1
#define NEXT_TIME 2

integer proc minimum_regexp_length(string s)
   integer result = 0
   integer i = 0
   integer prev_i = 0
   integer addition = 0
   integer prev_addition = 0
   integer tag_level = 0
   integer orred_addition = 0
   integer use_orred_addition = FALSE
   // For each character.
   for i = 1 to Length(s)
      // Ignore this zero-length "character".
      if Lower(SubStr(s,i,2)) == "\c"
         i = i + 1
      else
         // Skip index for all these cases so they will be counted as one
         // character.
         case SubStr(s,i,1)
            when "["
               while i < Length(s)
               and   SubStr(s,i,1) <> "]"
                  i = i + 1
               endwhile
            when "\"
               i = i + 1
               case Lower(SubStr(s,i,1))
                  when "x"
                     i = i + 2
                  when "d", "o"
                     i = i + 3
               endcase
         endcase
         // Now start counting.
         if use_orred_addition == NEXT_TIME
            use_orred_addition =  THIS_TIME
         endif
         // Count a literal character as one:
         if SubStr(s,i-1,1) == "\" // (Using the robustness of SubStr!)
            addition = 1
         // Count a tagged string as the length of its subexpression:
         elseif SubStr(s,i,1) == "{"
            prev_i = i
            tag_level = 1
            while i < Length(s)
            and   (tag_level <> 0 or SubStr(s,i,1) <> "}")
               i = i + 1
               if SubStr(s,i,1) == "{"
                  tag_level = tag_level + 1
               elseif SubStr(s,i,1) == "}"
                  tag_level = tag_level - 1
               endif
            endwhile
            addition = minimum_regexp_length(SubStr(s,prev_i+1,i-prev_i-1))
         // For a "previous character or tagged string may occur zero
         // times" operator: since it was already counted, subtract it.
         elseif SubStr(s,i,1) in "*", "@", "?"
            addition = -1 * Abs(prev_addition)
         // This is a tough one: the "or" operator.
         // For now subtract the length of the previous character or
         // tagged string, but remember doing so, because you might have
         // to add it again instead of the length of the character or
         // tagged string after the "or" operator.
         elseif SubStr(s,i,1) == "|"
            addition = -1 * Abs(prev_addition)
            orred_addition = Abs(prev_addition)
            use_orred_addition = NEXT_TIME
         else
         // Count ordinary characters as 1 character.
            addition = 1
         endif
         if use_orred_addition == THIS_TIME
            if orred_addition < addition
               addition = orred_addition
            endif
            use_orred_addition = FALSE
         endif
         result = result + addition
         prev_addition = addition
      endif
   endfor
   return(result)
end

proc create_or_initialize(string buffer_name, var integer buffer_id)
   if buffer_id == 0
      buffer_id = CreateBuffer(buffer_name, _HIDDEN_)
   else
      GotoBufferId(buffer_id)
      BegFile()
      EmptyBuffer()
   endif
end

proc remove_option(string option, var string options)
   while Pos(option, options)
      options = SubStr(options, 1, Pos(option, options) - 1)
              + SubStr(options, Pos(option, options) + 1,
                       Length(options) - Pos(option, options))
   endwhile
end

proc beg_end_file(var string search_options)
   if Pos("b", search_options)
      EndFile()
   else
      BegFile()
      remove_option("+", search_options)
   endif
end

proc next_prev_file(string search_options)
   string search_options_2 [255] = search_options
   integer debug_id = GetBufferId()
   Pop_Position()
   if debug_id <> GetBufferId()
      Warn("debug_id <> GetBufferId()")
   endif
   if Pos("b", search_options)
      PrevFile()
   else
      NextFile()
   endif
   Push_Position()
   beg_end_file(search_options_2)
   ids_checked = ids_checked + 1
   if NumFiles() > 0
      Message(ids_checked * 100 / NumFiles(), " %   ")
   endif
end

proc foundlist_to_file()
   integer old_id = GetBufferId()
   integer counter = 0
   start_line = CurrLine()
   start_column = 1
   MarkLine(1, NumLines())
   Copy()
   repeat
      counter = counter + 1
      start_id = CreateBuffer("*View eFinds buffer " + Str(counter) + "*",
                              _NORMAL_)
   until start_id
   Paste()
   UnMarkBlock()
   GotoBufferId(old_id)
   PushKey(<Escape>)
end

Keydef extra_keys
   <alt e> foundlist_to_file()
end

proc extra_keys_starter()
   UnHook(extra_keys_starter)
   if Enable(extra_keys)
      ListFooter(" {Enter}-Go to line   {Escape}-Cancel   {Alt E}-Edit this list")
   endif
end

proc abandon_file()
   integer org_id = GetBufferId()
   GotoBufferId(bannedfiles_id)
   AddLine(Str(org_id))
   GotoBufferId(org_id)
end

proc abandon_files()
   integer org_id = GetBufferId()
   GotoBufferId(bannedfiles_id)
   BegFile()
   repeat
      if Val(GetText(1,255)) <> 0
         AbandonFile(Val(GetText(1,255)))
      endif
   until not Down()
   if not GotoBufferId(org_id)
      NextFile()
   endif
end

proc keep_file()
   integer org_id = GetBufferId()
   GotoBufferId(bannedfiles_id)
   if lFind("^" + Str(org_id) + "$", "gx")
      KillLine()
   endif
   GotoBufferId(org_id)
end

proc efind( var string function,
            var string search_value,
            var string replace_value,
            var string search_options,
            var string action)
   integer ok                       = TRUE
   integer first_id                 = 0
   integer first_line               = 0
   integer first_column             = 0
   string  current_filename   [255] = ""
   integer current_id               = 0
   integer current_line             = 0
   integer v_start_line             = 0
   integer v_list_line              = 0
   integer selected_line            = 0
   integer found_in_file            = 0
   integer found_in_files           = 0
   integer found_files              = 0
   integer continue_search          = FALSE
   integer option_a                 = FALSE
   integer option_m                 = FALSE
   integer option_v                 = FALSE
   integer old_ilba                 = 0
   integer num_files                = NumFiles()
   integer i                        = 0

   // Variables for editor_versions before 3.00.
   #if EDITOR_VERSION < 0x3000
      integer prev_id                  = 0
      integer old_id                   = 0
      integer new_id                   = 0
      string  filename           [255] = ""
   #endif

   Push_Position()
   ids_checked    = 1
   start_id       = GetBufferId()
   start_line     = CurrLine()
   start_column   = CurrCol()
   create_or_initialize("AdminFinds", AdminFinds_id)
   create_or_initialize("ViewFinds", ViewFinds_id)
   create_or_initialize("BannedFiles", BannedFiles_id)
   GotoBufferId(start_id)

   // Pacify compiler for yet unused variables.
   replace_value        = replace_value
   action               = action
   ok                   = ok
   start_line           = start_line
   start_column         = start_column
   first_line           = first_line
   first_column         = first_column
   option_m             = option_m

   if function == "again"
      search_value   = prev_search_value
      search_options = prev_search_options
      remove_option("g", search_options)
      remove_option("+", search_options)
      search_options = search_options + "+"
   endif

   prev_search_value = search_value
   prev_search_options = search_options

   if Pos("a", search_options)
      option_a = TRUE
      remove_option("a", search_options)
      /*
         EFind shorcut: option "a" across files in combination with option
         "v" viewing all results implies that the search starts at the begin
         or end of the current file. This is necessary to make a neat viewing
         list. Remember the current line though: we need it to determine what
         the current line in the view list will be.
      */
      if Pos("v", search_options)
         v_start_line = CurrLine()
         beg_end_file(search_options)
      endif
   endif

   if Pos("g", search_options)
      remove_option("g", search_options)
      beg_end_file(search_options)
   endif

   if Pos("m", search_options)
      option_m = TRUE
      remove_option("m", search_options)
      UnMarkBlock()
   endif

   if Pos("v", search_options)
      if not (action in "abandon file", "keep file")
         option_v = TRUE
      endif
      remove_option("v", search_options)
   endif

   if BufferType() <> _NORMAL_
      num_files = num_files + 1
   endif
   if action == "keep file"
      for i = 1 to num_files
         current_id = GetBufferId()
         GotoBufferId(bannedfiles_id)
         AddLine(Str(current_id))
         GotoBufferId(current_id)
         NextFile(_DONT_LOAD_)
      endfor
      GotoBufferId(start_id)
   endif

   repeat
      continue_search = FALSE
      if lFind(search_value, search_options)
         if ids_checked   <= 1
         or GetBufferId() <> start_id
         or CurrLine()    <  start_line
         or CurrCol()     <= start_column
            found_in_file = found_in_file + 1
            found_in_files = found_in_files + 1
            if found_in_file == 1
               found_files = found_files + 1
            endif
            if first_id == 0
               first_id = GetBufferId()
               first_line = CurrLine()
               first_column = CurrCol()
            endif
            if option_v
            or function == "find&do"
               continue_search = TRUE
            endif
            if not Pos("+", search_options)
               search_options = search_options + "+"
            endif
            current_filename = CurrFilename()
            current_id = GetBufferId()
            current_line = CurrLine()
            if found_in_file == 1
               GotoBufferId(adminfinds_id)
               AddLine("")
               GotoBufferId(viewfinds_id)
               AddLine(Format("File: ", current_filename, "   0 occurrences found"))
               GotoBufferId(current_id)
            endif
            PushBlock()
            UnMarkBlock()
            MarkLine()
            Copy()
            if v_list_line == 0
            and CurrLine() >= v_start_line
               v_list_line = -1
            endif
            GotoBufferId(adminfinds_id)
            AddLine(Format(current_id, " ", current_line, " ", current_filename))
            if v_list_line == -1
               v_list_line = CurrLine()
            endif
            GotoBufferId(viewfinds_id)
            old_ilba = Set(InsertLineBlocksAbove, OFF)
            Paste()
            EndFile()
            BegLine()
            InsertText("        ", _INSERT_)
            Set(InsertLineBlocksAbove, old_ilba)
            lReplace(" [0-9]# occurrences found$",
                     Format(" ", found_in_file, " occurrences found"),
                     "bnx1")
            EndFile()
            GotoBufferId(current_id)
            PopBlock()
            if function == "find&do"
               case action
                  when "delete line"
                     KillLine()
                     Up()
                  when "cut append"
                     UnMarkBlock()
                     MarkLine()
                     Cut(_APPEND_)
                  when "copy append"
                     UnMarkBlock()
                     MarkLine()
                     Cut(_APPEND_)
                  when "count"
                     // action_counter = action_counter + 1
                  when "abandon file"
                     abandon_file()
                     EndFile()
                  when "keep file"
                     keep_file()
                     EndFile()
                  when "tse commands"
                     ExecMacro("efind2")
               endcase
            endif
         endif
      else
         if ids_checked <= 1
         or GetBufferId() <> start_id
            if option_a
               if NumFiles() > 1
                  if FileChanged()
                  or not FileExists(CurrFilename())
                     next_prev_file(search_options)
                  else
                     /*
                        If the editor_version is before TSE 3.00, then
                        here we unload the current file from memory,
                        and go to the next or previous file.
                        Tricky: AbandonFile() loads the file it jumps back to,
                        so we have to do some extra jumping to avoid that.
                        Tricky too: the BufferId's of the files change.
                     */
                     #if EDITOR_VERSION >= 0x3000
                        // Exists, but do not use here: UnloadAllBuffers().
                        UnloadBuffer(GetBufferId())
                     #else
                        filename = CurrFilename()
                        old_id = GetBufferId()
                        PrevFile(_DONT_LOAD_)
                        prev_id = GetBufferId()
                        GotoBufferId(adminfinds_id)
                        AbandonFile(old_id)
                        GotoBufferId(prev_id)
                        EditFile(filename, _DONT_LOAD_)
                        new_id = GetBufferId()
                        if start_id == old_id
                           start_id = new_id
                        endif
                     #endif
                     next_prev_file(search_options)
                     #if EDITOR_VERSION < 0x3000
                        current_id = GetBufferId()
                        GotoBufferId(adminfinds_id)
                        lReplace("^" + Str(old_id) + " ",
                                 Str(new_id) + " ",
                                 "ginx")
                        GotoBufferId(current_id)
                     #endif
                  endif
                  Delay(1)
                  found_in_file = 0
                  beg_end_file(search_options)
               endif
               if GetBufferId() <> start_id
                  continue_search = TRUE
               endif
            endif
         endif
      endif
   until not continue_search
   if action in "abandon file", "keep file"
      abandon_files()
   endif
   if found_in_files
      if option_v
         GotoBufferId(ViewFinds_id)
         GotoLine(v_list_line)
         Hook(_LIST_STARTUP_, extra_keys_starter)
         if List(Format("View Finds   ", found_in_files,
                        " occurrences found"), LongestLineInBuffer())
         and GetText(1, 6) <> "File: "
            Disable(extra_keys)
            selected_line = CurrLine()
            GotoBufferId(adminfinds_id)
            GotoLine(selected_line)
            BegLine()
            current_id = Val(GetWord())
            WordRight()
            current_line = Val(GetWord())
            GotoBufferId(current_id)
            PrevFile(_DONT_LOAD_)
            NextFile()
            GotoLine(current_line)
         else
            found_in_files = 0
            Disable(extra_keys)
            EmptyBuffer()
            GotoBufferId(start_id)
            GotoLine(start_line)
            GotoColumn(start_column)
         endif
      else
         if highlevel
            if     action == "abandon file"
               Message(found_files, " of ", num_files, " files abandoned")
            elseif action == "keep file"
               Message(found_files, " of ", num_files, " files kept")
            else
               Message(found_in_files, " occurrences found")
            endif
         endif
      endif
   else
      GotoBufferId(start_id)
      GotoLine(start_line)
      GotoColumn(start_column)
      if highlevel
         if Query(Beep)
            Alarm()
         endif
         if     action == "abandon file"
            Message("No files were abandoned.")
         elseif action == "keep file"
            Message("No files were kept.")
         else
            Message(search_value, " not found.")
         endif
      endif
   endif
   Set(MacroCmdLine, Str(found_in_files))
   Kill_Position()
end

proc set_result(string new_result)
   result = new_result
end

menu function_menu()
   title = "Function Menu"
   history
   "&Find"       , set_result("find")
   "&Again"      , set_result("again")
   "Find and &Do", set_result("find&do")
end

menu action_menu()
   title = "for each find, Do:"
   history
   "&Delete Line"   , set_result("find")
   "C&ut Append"    , set_result("again")
   "&Copy Append"   , set_result("replace")
   "Cou&nt"         , set_result("find&do")
   "&Keep File"     , set_result("keep file")
   "&Abandon File"  , set_result("abandon file")
// "&Tse Command(s)", set_result("commands")
end

string proc poppar()
   string result[255] = ""
   parameter_no = parameter_no + 1
   result = GetToken(Query(MacroCmdLine), " ", parameter_no)
   return(result)
end

integer proc get_parameters(  var string function,
                              var string search_value,
                              var string replace_value,
                              var string search_options,
                              var string action)
   integer ok               = TRUE
   integer interactive_mode = TRUE

   parameter_no = 0
   function = Lower(poppar())
   if function [1] == "l"
      highlevel = FALSE
      function = SubStr(function, 2, Length(function) - 1)
   else
      highlevel = TRUE
   endif
   if function == ""
      result = ""
      function_menu()
      function = result
      if function == ""
         ok = FALSE
      endif
   else
      if function in "find", "again", "replace", "find&do"
         ok = ok
      else
         ok = FALSE
         Warn("Illegal function: ", function)
      endif
   endif

   if  ok
   and function == "replace"
      Warn('Function "', function, '" not implemented yet')
      ok = FALSE
   endif

   if ok
      if function in "find", "replace", "find&do"
         search_value = poppar()
         if search_value == ""
            if Ask("Search for ?", search_value, find_history)
               if search_value == ""
                  ok = FALSE
                  Warn("It is pointless to search for an empty string.")
               endif
            else
               ok = FALSE
            endif
         else
            interactive_mode = FALSE
         endif
      endif
   endif

   if  ok
   and function == "replace"
      replace_value = poppar()
      if  replace_value == "" and interactive_mode and not Ask("Replace by ?", replace_value, replace_history)
               ok = FALSE
      endif
   endif

   if  ok
   and function in "find", "replace", "find&do"
      search_options = poppar()
      if  search_options == ""
      and interactive_mode
      and not Ask("Search options ?", search_options, option_history)
         ok = FALSE
      endif
      if  ok
      and Pos("a", search_options)
      and BufferType() <> _NORMAL_
         Warn("No search across files from TSE hidden or system file")
         ok = FALSE
      endif
      if  ok
      and Pos("c", search_options)
         if Pos("a", search_options)
         or Pos("v", search_options)
            Warn("Option C does not combine with options A and V")
            ok = FALSE
         endif
      endif
   endif

   if ok
      if function == "find&do"
         action = poppar()
         if action == ""
            if interactive_mode
               result = ""
               action_menu()
               action = result
               if action == ""
                  ok = FALSE
               endif
            endif
         endif
         if ok
            if action in "delete line", "cut append", "copy append", "count",
                         "abandon file", "keep file"
            else
               ok = FALSE
            endif
         endif
      endif
   endif

   if ok
      if  Pos("x", Lower(search_options))     >  0
      and minimum_regexp_length(search_value) <= 0
         ok = FALSE
         if interactive_mode
            Warn("It is pointless to search for a possibly empty string.")
         endif
      endif
   endif

   return(ok)
end

proc WhenLoaded()
    find_history     = GetFreeHistory("efind:find")
    replace_history  = GetFreeHistory("efind:replace")
    option_history   = GetFreeHistory("efind:option")
end

proc Main()
   string function         [8] = ""
   string search_value   [255] = ""
   string replace_value  [255] = ""
   string search_options  [25] = ""
   string action         [255] = ""
   integer old_break           = Set(Break, ON)
   integer old_msglevel        = Set(MsgLevel, _NONE_)
   integer tmp_id              = 0
   //
   IF NOT ( YesNo( "First abandon all large files (e.g. bibtse.s, addjob.dok, ...) as it might cause out of memory." ) == 1 )
    RETURN()
   ENDIF
   //
   PushPosition()
   tmp_id = CreateTempBuffer()
   PopPosition()
   if                              tmp_id <= 32767
   or  EDITOR_VERSION > 0x4400
   or (EDITOR_VERSION < 0x3000 and tmp_id <= 65535)
      if get_parameters(function, search_value, replace_value, search_options, action)
         if highlevel
            Message("Searching ...")
         endif
         efind(function, search_value, replace_value, search_options, action)
      else
         Set(MacroCmdLine, "0")
      endif
   else
      Warn("Too many files for this TSE version: see eFind's documentation")
   endif
   Set(MsgLevel, old_msglevel)
   Set(Break, old_break)
end

