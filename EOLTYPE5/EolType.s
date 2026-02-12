/*
   Macro          EolType
   Author         Carlo.Hogeveen@xs4all.nl
   Date           5 July  1999
   Version 5.1    1 April 2007
   Compatibility  TSE Pro 2.5e upwards

   Purpose:

      Save unix files with EndOfLineType LF, save all other files with
      EndOfLineType CR+LF (microsoft format).

      You can tell this macro by what filename parts it can recognize
      unix files. It interprets this case-insensitive.

      This macro monitors all your file saves, and sets the configured
      EndOfLineType for each file as it is saved.

      You will optionally get warnings if the loaded EndOfLineType differs
      from the (to be) saved EndOfLineType, and the possibility to override
      the configured EndOfLineType type.

   Typical use:

      You are for instance from a Windows machine accessing files on a
      unix machine which is mapped as a Windows drive, for instance "X".
      In such a case you want to tell EolType to save all files that have
      "x:\" in their name as unix files.

      You are for instance using Total Commander (formerly Windows Commander,
      http://www.ghisler.com/ ) to browse unix machines and you have TSE
      configured as it's external editor.
      Total Commander ftp's such a file to a directory "$wc" which is
      created in a directory for temporary files, then calls TSE to edit it,
      and when TSE is exited then Total Commander ftp's the file back to the
      unix machine. (You have to have an ftp account on the unix machines
      involved.) In such a case you want to tell EolType to save all files
      that have "\$wc\" in their name as unix files.

   Install:

      Copy EolType.s to TSE's "mac" directory, and compile it.

      Execute the macro "EolType" once, to configure what case insensitive
      filename parts separated by a space indicate a unix filename.

   Example input:

      x:\ \$wc\ \_tc\ \Temp\scp

      The above are examples for a Samba drive, Windows Commander,
      Total Commander, and WinSCP.

      But note if for instance you configured WinSCP to do TEXT transfers
      of text files, then you do NOT want to configure \Temp\scp in EolType.

   History:

      Version 1      5 July 1999
      You can specify filename parts starting with a drive letter.

      Version 2      29 August 2001
      You can specify any part of a filename to indicate that it is a unix
      file.
      The EolType.dat file is created in TSE's "mac" directory instead of in
      the TSE directory.

      Version 3      21 April 2002
      Cleans up some code, and displays a warning when the saved
      End-Of-Line-Type will differ from the loaded End-Of-Line-Type.

      Version 4      14 March 2003
      Makes everything configurable and adds optionally overriding
      the EndOfLineType default.

      Version 5      17 April 2003
      EolType.dat was changed to EolType.cfg, and the default
      configuration was changed to not give info or ask questions about
      the end-of-line-type.

      Version 5.1    1 April 2007
      In version 5 the macro lost its compatibility with TSE Pro 2.5e
      thru TSE Pro 3.0: this version is compatible again.
      The macro now adds or removes itself from the Macro AutoloadList when
      it is configured.
*/

integer eoltype_id  = 0
integer current_id  = 0
integer info_delay  = 0
integer no_override_choice = 0
integer overriding_eoltype = 0
integer old_makebackups = 0
integer old_protectedsaves = 0
string  cfg_file [255] = ""
string  restore_saved_settings_flag [1] = "n"
string  macroname [255] = ""

// Variables loaded from configuration file:
string unix_substrings [255] = ""
string disable_eoltype_macro_yn [1] = ""
string warn_early_changing_eoltype_yn [1] = ""
string warn_late_changing_eoltype_yn [1] = ""
string override_changing_eoltype_yn [1] = ""

proc say(string text)
   Alarm()
   Message(text)
   Delay(54)
end

string proc eoltype_to_text(integer eol_type)
   string result [17] = ""
   case eol_type
      when 1
         result = "APPLE     (CR)"
      when 2
         result = "UNIX      (LF)"
      when 3
         result = "MICROSOFT (CR+LF)"
      otherwise
         result = "UNKNOWN"
   endcase
   return(result)
end

proc info(integer old_eoltype, integer new_eoltype)
   integer old_textattr = Query(TextAttr)
   integer counter = 5
   Alarm()
   UpdateDisplay()
   PopWinOpen(39, 15, 77, 23, 1, "End-Of-Line-Type warning:", Query(MenuBorderAttr))
   Set(Attr, Query(HelpTextAttr))
   repeat
      ClrScr()
      WriteLine(" ")
      WriteLine(" File LOAD format: ", eoltype_to_text(old_eoltype))
      WriteLine(" ")
      WriteLine(" File SAVE format: ", eoltype_to_text(new_eoltype))
      WriteLine(" ")
      Write    (" ", counter, " ...")
      Delay(18)
      counter = counter - 1
   until KeyPressed()
      or counter == 0
   PopWinClose()
   Set(TextAttr, old_textattr)
end

integer proc set_old_eoltype()
   integer org_id     = GetBufferId()
   integer eol_type   = 0
   integer handle     = 0
   integer bytes_read = 0
   integer position   = 0
   string  data [255] = ""
   Set(EOLType, 0) // As loaded.
   handle = fOpen(CurrFilename(), _OPEN_READONLY_)
   if handle <> -1
      repeat
         bytes_read = fRead(handle, data, 255)
         if bytes_read <> -1
            position = Min(iif(Pos(Chr(10), data), Pos(Chr(10), data), MAXINT),
                           iif(Pos(Chr(13), data), Pos(Chr(13), data), MAXINT))
            if position in 1 .. 254
               if data [position] == Chr(13)
                  if data [position + 1] == Chr(10)
                     eol_type = 3      // Ms:      CR+LF.
                  else
                     eol_type = 1      // Apple:   CR.
                  endif
               else
                  eol_type = 2         // Unix:    LF.
               endif
            else
               fSeek(handle, -1, _SEEK_CURRENT_)
            endif
         endif
      until eol_type   >    0
         or bytes_read ==  -1
         or bytes_read <  255
      fClose(handle)
   endif
   if eol_type > 0
      GotoBufferId(eoltype_id)
      EndFile()
      AddLine(Format(Str(org_id), " ", Str(eol_type)))
      GotoBufferId(org_id)
   endif
   return(eol_type)
end

proc del_old_eoltype()
   integer org_id = GetBufferId()
   GotoBufferId(eoltype_id)
   if lFind(Format("^", Str(org_id), " "), "gx")
      KillLine()
      BegFile()
   endif
   GotoBufferId(org_id)
end

proc on_file_load()
   if disable_eoltype_macro_yn == "n"
      set_old_eoltype()
   endif
end

integer proc get_new_eoltype()
   integer result = 3   // CR+LF.
   integer token_number
   for token_number = 1 to NumTokens(unix_substrings, " ")
      if Pos(GetToken(unix_substrings, " ", token_number),
             Lower(CurrFilename()))
         result = 2   // LF.
      endif
   endfor
   return(result)
end

integer proc get_old_eoltype()
   integer result = 0
   integer org_id = GetBufferId()
   GotoBufferId(eoltype_id)
   if lFind(Format("^", Str(org_id), " "), "gx")
      result = Val(GetToken(GetText(1, CurrLineLen()), " ", 2))
      GotoBufferId(org_id)
   else
      GotoBufferId(org_id)
      result = set_old_eoltype()
   endif
   return(result)
end

proc set_override_choice()
   /*
      Menu choices 1, 5 and 10 are unchoosable.
      Therefore translate choices 2,3,4,6,7,8,9 to eoltypes 1,2,3,4,5,6,7.
   */
   overriding_eoltype = MenuOption() - 1
   if overriding_eoltype > 4
      overriding_eoltype = overriding_eoltype - 1
   endif
end

menu override_menu()
   TITLE = "Saving this file: override it's default EndOfLine type:"
   X = 5
   y = 5
   history = no_override_choice
   COMMAND = set_override_choice()
   "",, SKIP
   "&Apple     CR"
   "&Unix      LF"
   "&Microsoft CR+LF"
   "",, SKIP
   "All files in this save as A&pple     CR"
   "All files in this save as U&nix      LF"
   "All files in this save as M&icrosoft CR+LF"
   "All files in this save as l&oaded"
end

proc restore_saved_settings()
   if restore_saved_settings_flag == "y"
      Set(MakeBackups   , old_makebackups   )
      Set(ProtectedSaves, old_protectedsaves)
   endif
end

proc on_file_save()
   integer old_eoltype  = 0
   integer new_eoltype  = 0
   #ifdef WIN32
   #else
      restore_saved_settings()
   #endif
   if disable_eoltype_macro_yn == "n"
      old_eoltype  = get_old_eoltype()
      new_eoltype  = get_new_eoltype()
      Set(EOLType, new_eoltype)
      if  old_eoltype >  0
      and new_eoltype <> old_eoltype
      and BufferType() == _NORMAL_
         if warn_late_changing_eoltype_yn == "y"
            info(old_eoltype, new_eoltype)
         endif
         if override_changing_eoltype_yn == "y"
            if overriding_eoltype == 0
               UpdateDisplay()
               no_override_choice = new_eoltype + 1
               override_menu()
            endif
            if overriding_eoltype < 4
               Set(EOLType, overriding_eoltype)
            else
               if overriding_eoltype == 7
                  Set(EOLType, 0)
               else
                  Set(EOLType, overriding_eoltype - 3)
               endif
            endif
         endif
      endif
      if Query(EOLType) == 2
         old_makebackups    = Set(MakeBackups   , OFF)
         old_protectedsaves = Set(ProtectedSaves, OFF)
      else
         old_makebackups    = Query(MakeBackups)
         old_protectedsaves = Query(ProtectedSaves)
      endif
      restore_saved_settings_flag = "y"
      del_old_eoltype()
      current_id = 0
   endif
end

#ifdef WIN32
   proc after_file_save()
      restore_saved_settings()
   end
#endif

proc on_changing_files()
   #ifdef WIN32
   #else
      restore_saved_settings()
   #endif
   if disable_eoltype_macro_yn == "n"
      current_id = 0
   endif
end

proc idle()
   integer old_eoltype = 0
   integer new_eoltype = 0
   overriding_eoltype = 0
   #ifdef WIN32
   #else
      restore_saved_settings()
   #endif
   if disable_eoltype_macro_yn == "y"
      PurgeMacro(macroname)
   else
      if GetBufferId() == current_id
         if info_delay > 0
            if KeyPressed()
               info_delay = 10
            else
               info_delay = info_delay - 1
               if info_delay == 0
                  old_eoltype = get_old_eoltype()
                  new_eoltype = get_new_eoltype()
                  if  warn_early_changing_eoltype_yn == "y"
                  and old_eoltype > 0
                  and old_eoltype <> new_eoltype
                     info(old_eoltype, new_eoltype)
                  endif
               endif
            endif
         endif
      else
         current_id = GetBufferId()
         get_old_eoltype()
         info_delay = 10
      endif
   endif
end

proc WhenPurged()
   UnHook(on_file_load)
   UnHook(on_file_save)
   UnHook(on_changing_files)
   UnHook(idle)
end

proc make_default(var string variable, string default_value)
   if not (variable in "y", "n")
      variable = default_value
   endif
end

proc WhenLoaded()
   integer org_id = GetBufferId()
   integer temp_id = 0
   macroname = SplitPath(CurrMacroFilename(), _NAME_)
   Hook(_ON_FILE_LOAD_, on_file_load)
   Hook(_ON_FILE_SAVE_, on_file_save)
   Hook(_ON_CHANGING_FILES_, on_changing_files)
   Hook(_IDLE_        , idle        )
   #ifdef WIN32
      Hook(_AFTER_FILE_SAVE_, after_file_save)
      cfg_file = QuotePath(LoadDir() + "mac\eoltype.cfg")
   #else
      cfg_file = LoadDir() + "mac\eoltype.cfg"
   #endif
   eoltype_id = CreateTempBuffer()
   if eoltype_id
      GotoBufferId(org_id)
      temp_id = EditFile(cfg_file, _DONT_PROMPT_)
      if temp_id
         BegFile()
         unix_substrings = Lower(GetText(1,CurrLineLen()))
         if Down()
            disable_eoltype_macro_yn = Lower(GetText(1,CurrLineLen()))
            if Down()
               warn_early_changing_eoltype_yn = Lower(GetText(1,CurrLineLen()))
               if Down()
                  warn_late_changing_eoltype_yn = Lower(GetText(1,CurrLineLen()))
                  if Down()
                     override_changing_eoltype_yn = Lower(GetText(1,CurrLineLen()))
                  endif
               endif
            endif
         endif
         make_default(disable_eoltype_macro_yn, "n")
         make_default(warn_early_changing_eoltype_yn, "n")
         make_default(warn_late_changing_eoltype_yn, "n")
         make_default(override_changing_eoltype_yn, "n")
         GotoBufferId(org_id)
         AbandonFile(temp_id)
      endif
   else
      Warn("EolType: could not create temp buffer")
      PurgeMacro(macroname)
   endif
end

proc save_settings()
   integer org_id = GetBufferId()
   integer edit_id = 0
   edit_id = EditFile(cfg_file, _DONT_PROMPT_)
   if edit_id
      EmptyBuffer()
      InsertLine(unix_substrings)
      AddLine(disable_eoltype_macro_yn)
      AddLine(warn_early_changing_eoltype_yn)
      AddLine(warn_late_changing_eoltype_yn)
      AddLine(override_changing_eoltype_yn)
      SaveAs(cfg_file, _OVERWRITE_|_DONT_PROMPT_)
      GotoBufferId(org_id)
      AbandonFile(edit_id)
   else
      Warn("EolType error: cannot save config file")
   endif
end

integer proc is_autoload_macro()
   integer org_id = GetBufferId()
   integer result = FALSE
   integer autoload_id = 0
   #ifdef WIN32
      autoload_id = EditBuffer(LoadDir() + "tseload.dat", _SYSTEM_)
   #else
      autoload_id = CreateTempBuffer()
      if autoload_id
         InsertFile(LoadDir() + "tseload.dat", _DONT_PROMPT_)
      endif
   #endif
   if autoload_id
      result = lFind(macroname, "giw")
      GotoBufferId(org_id)
      AbandonFile(autoload_id)
   endif
   return(result)
end

proc Main()
   integer stop = FALSE
   if Ask("Do you want to disable all EndOfLineType checking (y/n)?",
          disable_eoltype_macro_yn)
      disable_eoltype_macro_yn = Lower(disable_eoltype_macro_yn)
      if disable_eoltype_macro_yn == "y"
         save_settings()
         say("All EndOfLineType checking is now disabled")
         DelAutoLoadMacro(macroname)
         PurgeMacro(macroname)
      else
         repeat
            stop = TRUE
            if Ask("List discriminating substrings of unix path/filenames, separated by a space:",
                   unix_substrings)
               if NumTokens(unix_substrings, " ") == 0
                  say("Error: you have to supply unix substrings for this macro to make sense")
                  stop = FALSE
               else
                  if Ask("Do you want early warnings about EndOfLineType changes (y/n)?",
                         warn_early_changing_eoltype_yn)
                     warn_early_changing_eoltype_yn = Lower(warn_early_changing_eoltype_yn)
                     if Ask("Do you want late warnings about EndOfLineType changes (y/n)?",
                            warn_late_changing_eoltype_yn)
                        warn_late_changing_eoltype_yn = Lower(warn_late_changing_eoltype_yn)
                        if Ask("Do you want question to override EndOfLineType changes when saving (y/n)?",
                               override_changing_eoltype_yn)
                           override_changing_eoltype_yn = Lower(override_changing_eoltype_yn)
                           save_settings()
                           if not is_autoload_macro()
                              AddAutoLoadMacro(macroname)
                           endif
                        else
                           say("Configuration aborted")
                        endif
                     else
                        say("Configuration aborted")
                     endif
                  else
                     say("Configuration aborted")
                  endif
               endif
            else
               say("Configuration aborted")
            endif
         until stop
      endif
   else
      say("Configuration aborted")
   endif
end

