/*
   Macro          OpenType
   Author         Carlo.Hogeveen@xs4all.nl
   Date           31 May 2005
   Version        1.3
   Compatibility  TSE 4.4 upwards.

   This macro is only relevant and effective when the TSE-option
   "Use the Windows Common File Dialogs" (aka UseCommonDialogs) is ON.

   Without this macro:
      The list of filetypes in TSE's File Open dialog is fixed,
      and the initial filetype is the last selected filetype.

   With this macro:
      The list of filetypes in TSE's File Open dialog is based on the types
      of the files that you previously opened with TSE, either sorted on
      their recentness, or sorted on the frequency with which they were
      selected.

      You can set the initial filetype that TSE should always start with.

      You can group filetypes that have the same program-association.

   Notes:
      You can always get at any filetype by selecting the "*" filetype at the
      bottom of the list, or by typing "*.the_specific_file_extension" at the
      "File name" prompt.

      This macro and its settings are ignored by the DlgOpen procedure
      of Dieter Koessl's WinDlg macro.

   Installation:
      Put this macrosource in TSE's "mac" directory.
      Compile it.
      Execute it at least once to configure it.


   History:

   v0.1     31 may 2005
      Sets the File Open filetypes list based on the frequency with wich the
      filtype occurs in TSE's _edit_history_ history-list.

   v0.2     4 jun 2005
      Added configurability when executed.
      Added disabling the macro.
      Added basing filtype-list on unsorted history.
      Added setting an initial filetype.

   v0.3     12 jun 2005
      Solved a bug in remembering a fixed initial File Open filetype.
      Solved that the macro wasn't active in TSE's startup Open menu.
      Standard group extensions with the same program association.

   v1.0     7 August 2005
      Optionally group extensions with the same program association.
      Added the "*" filetype at the bottom of the list of filetypes.

   v1.1     10 August 2005
      Big bug: because TSE unexpectedly but not wrongly doesn't update the
      _edit_history_ when UseCommonDialogs is ON, this macro becomes useless.
      Informed Semware in time to abort publishing the uploaded v1.0.

   v1.2     22 August 2005
      The macro now updates the _edit_history_ if UseCommonDialogs is ON.
      Solved a range of little bugs which made OpenType work inconsistenly.
      One point remains: OpenType needs some serious retesting.

   v1.3     4 September 2005
      Tested it again, and found no bugs.
      Only made some documentation changes.
*/

constant ERROR_SUCCESS        = 0
constant ERROR_NO_MORE_ITEMS  = 259

constant HKEY_CLASSES_ROOT    = 0x80000000
constant HKEY_CURRENT_USER    = 0x80000001

constant KEY_QUERY_VALUE      = 0x0001

integer open_type_refreshed   = TRUE
integer tmp_id                = 0
integer list_type             = 0
integer group_type            = 1
integer standard_type         = 0
string  filter          [255] = ""
string  custom_filter   [255] = ""
string  macroname       [255] = ""

dll "<advapi32.dll>"
   integer proc RegOpenKeyEx(
      integer     hKey,
      string      lpSubKey:cstrval,
      integer     ulOptions,
      integer     samDesired,
      var integer phkResult):"RegOpenKeyExA"
   integer proc RegEnumValue(
      integer     hKey,
      integer     dwIndex,
      integer     lpValueName,
      var integer lpcValueName,
      integer     lpReserved,
      integer     lpType,
      integer     lpData,
      var integer lpcbData):"RegEnumValueA"
   integer proc RegCloseKey(
      integer     hKey)
end

proc set_string_length(integer string_adr, integer string_len, integer trailer)
   if string_len < 2
      // An empty string has no traling zero byte.
      PokeWord(string_adr - 2, 0)
   else
      // Ignore the trailing zero byte for value data, not for value name.
      PokeWord(string_adr - 2, string_len - trailer)
   endif
end

string proc read_reg(integer root_key, string sub_key, string value_name)
   string  result [255]          = ""
   integer reg_options           = 0
   integer reg_access            = KEY_QUERY_VALUE
   integer reg_key_handle        = 0
   integer reg_value_index       = -1
   string  reg_value_name [255]  = Format("":255)
   integer reg_value_name_adr    = Addr(reg_value_name) + 2
   integer reg_value_name_len    = 255
   integer reg_value_type        = 0
   string  reg_value_data [255]  = Format("":255)
   integer reg_value_data_adr    = Addr(reg_value_data) + 2
   integer reg_value_data_len    = 255
   integer reg_error             = 0
   if RegOpenKeyEx(root_key, sub_key, reg_options, reg_access,
         reg_key_handle) == ERROR_SUCCESS
      repeat
         reg_value_index    = reg_value_index + 1
         reg_value_name_len = 255
         reg_value_data_len = 255
         reg_error = RegEnumValue(  reg_key_handle,
                                    reg_value_index,
                                    reg_value_name_adr,
                                    reg_value_name_len,
                                    reg_options,
                                    reg_value_type,
                                    reg_value_data_adr,
                                    reg_value_data_len)
         if reg_error == ERROR_SUCCESS
            set_string_length(reg_value_name_adr, reg_value_name_len, 0)
            set_string_length(reg_value_data_adr, reg_value_data_len, 1)
            if Lower(reg_value_name) == Lower(value_name)
               result = reg_value_data
            endif
         elseif reg_error == ERROR_NO_MORE_ITEMS
            NoOp()
         else
            Warn("Error ", reg_error, " reading Key: ", sub_key)
         endif
      until reg_error <> ERROR_SUCCESS
         or result <> ""
      if RegCloseKey(reg_key_handle) <> ERROR_SUCCESS
         Warn("Close key failed: ", sub_key)
      endif
   endif
   return(result)
end

string proc extract_program(string value_data)
   string result [255] = ""
   integer position = StrFind(".exe", value_data, "i")
   if position
      result = SubStr(value_data, 1, position - 1)
      position = StrFind("\", result, "b")
      if position
         result = SubStr(result, position + 1, 255)
      endif
   endif
   return (result)
end

string proc get_program(string extension)
/*
   Registry search order, stopping at the first find:

   1  Key:        HKEY_CURRENT_USER\Software\Microsoft\Windows\
                     CurrentVersion\Explorer\FileExts\.ext
      Value Name: Application
      Value Data: <X>

      Key:        HKEY_CLASSES_ROOT\Applications\<X>\shell\open\command
      Value Name: Default
      Value Data: A string containing the .exe program.

   2  Key:        HKEY_CLASSES_ROOT\.ext
      Value Name: Default
      Value Data: <Y>

      Key:        HKEY_CLASSES_ROOT\<Y>\shell\open\command
      Value Name: Default
      Value Data: A string containing the .exe program.
*/
   string result [255] = ""
   string value_data [255] = ""
   if extension == "txt"
      result = result
   endif
   value_data = read_reg(HKEY_CURRENT_USER,
      "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\"
      + "." + extension, "Application")
   if value_data <> ""
      value_data = read_reg(HKEY_CLASSES_ROOT, "Applications\" + value_data
         + "\shell\open\command", "")
      if value_data <> ""
         result = extract_program(value_data)
      endif
   else
      value_data = read_reg(HKEY_CLASSES_ROOT, "." + extension, "")
      if value_data <> ""
         value_data = read_reg(HKEY_CLASSES_ROOT,
                               value_data + "\Shell\open\command", "")
         result = extract_program(value_data)
      endif
   endif
   return(result)
end

string proc add_asterisks(string extensions)
   string result [255] = ""
   integer i = 0
   for i = 1 to NumTokens(extensions, ";")
      if i > 1
         result = result + ";"
      endif
      result = result + "*." + GetToken(extensions, ";", i)
   endfor
   return(result)
end

string proc get_first_filter_pair(string filter)
   string  result [255] = ""
   integer start        = 0
   start = StrFind(Chr(0), filter, "", 2)
   if start == 0
      result = Chr(0) + Chr(0)
   else
      result = SubStr(filter, 1, start) + Chr(0)
   endif
   return(result)
end

proc refresh_open_type()
   integer org_id                   = GetBufferId()
   integer old_msglevel             = Set(MsgLevel, _WARNINGS_ONLY_)
   integer i                        = 0
   integer extensions               = 0
   string  extension          [255] = ""
   string  program            [255] = ""
   string  filter_pair        [255] = ""
   string  used_custom_filter [255] = ""
   integer killed_first_line        = FALSE
   PushBlock()
   // Get a list of all files from the edit history.
   GotoBufferId(tmp_id)
   EmptyBuffer()
   for i = 1 to NumHistoryItems(_EDIT_HISTORY_)
      AddLine(GetHistoryStr(_EDIT_HISTORY_, i))
   endfor
   // Remove empty lines and lines with files without extensions. Reduce the
   // remaing lines to a list of file extensions excluding the leading period.
   lReplace('^"', '', 'gnx')
   lReplace('"$', '', 'gnx')
   BegFile()
   repeat
      if killed_first_line
         killed_first_line = FALSE
         Up()
      endif
      if  lFind(".", "bcg")
      and CurrCol() > 1
      and CurrCol() <> CurrLineLen()
      and Pos(" ", GetText(CurrCol() + 1, 255)) == 0
      and not lFind("\?|\*|\[|\]", "cgx")
         MarkColumn(CurrLine(), 1, CurrLine(), CurrCol())
         KillBlock()
      else
         if CurrLine() == 1
            KillLine()
            killed_first_line = TRUE
         else
            KillLine()
            Up()
         endif
      endif
   until not Down()
   // Set the file in lowercase.
   MarkLine(1, NumLines())
   Lower()
   UnMarkBlock()
   // Precede extensions with a counter of their occurrence,
   // and remove duplicate lines.
   BegFile()
   repeat
      extension = GetText(1,CurrLineLen())
      extensions = 1
      EndLine()
      PushPosition()
      while lFind(extension, "iw+")
         extensions = extensions + 1
         KillLine()
         Up()
         EndLine()
      endwhile
      PopPosition()
      BegLine()
      InsertText(Format(extensions:10, " "), _INSERT_)
   until not Down()
   // Add associated programs.
   if group_type == 1
      BegFile()
      repeat
         extension = GetToken(Trim(GetText(1,CurrLineLen()))," ", 2)
         program   = get_program(extension)
         if program <> ""
            EndLine()
            InsertText(" program=" + Lower(program), _INSERT_)
            BegLine()
         endif
      until not Down()
   endif
   // Group extensions with the same program association.
   if group_type == 1
      BegFile()
      repeat
         if lFind(" program=", "bcg")
            PushPosition()
            program = GetText(CurrCol() + 9, 255)
            extensions = Val(GetText(1, 10))
            extension = ""
            EndLine()
            while lFind(" program=" + program + "$", "x+")
               extension  = extension + ";" + GetText(12, CurrCol() - 12)
               extensions = extensions + Val(GetText(1, 10))
               KillLine()
               Up()
               EndLine()
            endwhile
            PopPosition()
            KillToEol()
            BegLine()
            InsertText(Format(extensions:10), _OVERWRITE_)
            EndLine()
            InsertText(extension, _INSERT_)
         endif
      until not Down()
   endif
   // Sort the extensions accordig to the configuration setting.
   MarkColumn(1, 1, NumLines(), 11)
   if list_type == 3
      Sort(_IGNORE_CASE_|_DESCENDING_)
   endif
   KillBlock()
   // Build Open Type filetypes in the variable "filter".
   BegFile()
   if custom_filter == (Chr(0) + Chr(0))
      filter = ""
   else
      filter = SubStr(custom_filter, 1, Length(custom_filter) - 1)
   endif
   repeat
      filter_pair = GetToken(Trim(GetText(1,255))," ",1) + Chr(0)
      if NumTokens(Trim(GetText(1,255)), " ") > 1
         // Maybe the program-name here instead?
         filter_pair = filter_pair
                     + add_asterisks(GetToken(Trim(GetText(1,255))," ",1))
      else
         filter_pair = filter_pair
                     + add_asterisks(GetToken(Trim(GetText(1,255))," ",1))
      endif
      filter_pair = filter_pair + Chr(0)
      if  filter_pair + Chr(0) <> custom_filter
      and Length(filter) + Length(filter_pair) <= 248
         filter = filter + filter_pair
      endif
   until not Down()
   // Always add the "*" filetype at the bottom of the filetype list.
   filter = filter + "*" + Chr(0) + "*.*" + Chr(0) + Chr(0)
   // Set the Window custom_filter to the first value of filter.
   // This only makes used_custom_filter different if custom_filter is empty.
   // TSE tech note: GetToken does not work with Chr(0) as delimiter.
   used_custom_filter = get_first_filter_pair(filter)
   PopBlock()
   GotoBufferId(org_id)
   Set(MsgLevel, old_msglevel)
   SetOpenFilenameFilter(filter)
   SetOpenFilenameCustomFilter(used_custom_filter)
   open_type_refreshed = TRUE
end

proc idle()
   if not open_type_refreshed
      if list_type > 1
         refresh_open_type()
      else
         SetOpenFilenameFilter      (Chr(0) + Chr(0))
         SetOpenFilenameCustomFilter(Chr(0) + Chr(0))
         RemoveProfileSection(macroname)
         DelAutoLoadMacro(macroname)
         PurgeMacro(macroname)
         MsgBox("The macro " + Upper(macroname) + " has been disabled.")
         UpdateDisplay()
      endif
   endif
end

proc on_first_edit()
// open_type_refreshed = FALSE
   if FileExists(CurrFilename())
      if Query(UseCommonDialogs)
         AddHistoryStr(CurrFilename(), _EDIT_HISTORY_)
      endif
//    if CurrExt() <> ""
//       custom_filter = SubStr(CurrExt(),2,255) + Chr(0) + "*"
//                     + CurrExt() + Chr(0) + Chr(0)
//    endif
   endif
end

proc WhenLoaded()
   integer org_id = GetBufferId()
   tmp_id = CreateTempBuffer()
   GotoBufferId(org_id)
   macroname     = SplitPath(CurrMacroFilename(), _NAME_)
   custom_filter = GetProfileStr(macroname, "CustomFilter", "")
   custom_filter = StrReplace(" ", custom_filter, Chr(0), "b1")
   custom_filter = custom_filter + Chr(0) + Chr(0)
   list_type     = GetProfileInt(macroname, "ListType", 1)
   standard_type = GetProfileInt(macroname, "StandardType", 1)
   group_type    = GetProfileInt(macroname, "GroupType", 1)
   Hook(_ON_FIRST_EDIT_, on_first_edit)
   Hook(_IDLE_, idle)
   refresh_open_type()
end

menu configure_list_types_menu()
   title = "Configure the list of available filetypes for Open File:"
   "Do not interfere"
   "Base on recentness in TSE history"
   "Base on frequency  in TSE history"
end

menu configure_standard_type_menu()
   title = "Configure the initial File Open filetype:"
   "Variable: The top one from the filetypes list"
   "Fixed   : Select one from the history list"
   "Fixed   : Make your own one"
end

proc configure()
   integer org_id = GetBufferId()
   string new_custom_filter [255] = Trim(StrReplace("\d000#", custom_filter, " ", "x"))
   string description [255] = ""
   string extensions  [255] = ""
   integer yes_no
   Message("Configure the filetypes for Open File")
   if not Query(UseCommonDialogs)
      Delay(9)
      if MsgBox("Warning!",
                'The TSE option "Use the Windows Common File Dialogs" is OFF.'
                + " This macro effects only TSE's Windows File Open dialog,"
                + " not the character-mode File Open dialog."
                + Chr(13) + Chr(13)
                + "Do you want to set the TSE option UseCommonDialogs to ON?",
                _YES_NO_) == 1
         Set(UseCommonDialogs, ON)
         Delay(9)
         if MsgBox("Save settings?",
                   "Do you want to save your TSE settings?",
                   _YES_NO_) == 1
            SaveSettings()
         endif
      endif
   endif
   if not Query(UseCommonDialogs)
      Delay(9)
      Warn("No UseCommonDialogs: configuration stopped: no changes.")
   else
      if list_type == 2
         PushKey(<CursorDown>)
      elseif list_type == 3
         PushKey(<CursorDown>)
         PushKey(<CursorDown>)
      endif
      Delay(9)
      configure_list_types_menu()
      list_type = MenuOption()
      WriteProfileInt(macroname, "ListType", list_type)
      if not IsAutoloaded(macroname)
         AddAutoLoadMacro(macroname)
         NoOp()
      endif
   endif

   if  Query(UseCommonDialogs)
   and list_type > 1
      if standard_type == 2
         PushKey(<CursorDown>)
      elseif standard_type == 3
         PushKey(<CursorDown>)
         PushKey(<CursorDown>)
      endif
      Delay(9)
      configure_standard_type_menu()
      standard_type = MenuOption()
      WriteProfileInt(macroname, "StandardType", standard_type)
      if standard_type == 1
         custom_filter = Chr(0) + Chr(0)
         RemoveProfileItem(macroname, "CustomFilter")
      elseif standard_type == 2
         refresh_open_type()
         GotoBufferId(tmp_id)
         BegFile()
         Delay(9)
         if List("Select an initial File Open filetype",LongestLineInBuffer())
            custom_filter = GetText(1,255) + Chr(0)
                          + add_asterisks(GetText(1,255)) + Chr(0)  + Chr(0)
            WriteProfileStr(macroname, "CustomFilter",
               Trim(StrReplace(Chr(0), custom_filter, " ")))
         endif
         GotoBufferId(org_id)
      elseif standard_type == 3
         Delay(9)
         if Ask("Initial File Open filetype (Optional Description *.ext1;*.ext2;...):",
                new_custom_filter, GetFreeHistory(macroname + ":CustomFilter"))
            new_custom_filter = StrReplace("  #", Trim(new_custom_filter),
                                           " ", "x")
            if NumTokens(new_custom_filter, " ") == 0
               custom_filter = Chr(0) + Chr(0)
            elseif NumTokens(new_custom_filter, " ") == 1
               custom_filter = new_custom_filter + Chr(0) + new_custom_filter
                             + Chr(0) + Chr(0)
            else
               extensions = GetToken(new_custom_filter,
                                    " ",
                                    NumTokens(new_custom_filter,
                                              " "))
               description = Trim(SubStr(new_custom_filter,
                                         1,
                                         Length(new_custom_filter)
                                         - Length(extensions)))
               custom_filter = description + Chr(0)
                             + extensions + Chr(0) + Chr(0)
            endif
            WriteProfileStr(macroname, "CustomFilter",
                            Trim(StrReplace(Chr(0), custom_filter, " ")))
         endif
      endif
   endif

   if  Query(UseCommonDialogs)
   and list_type > 1
      if group_type == 2
         PushKey(<CursorDown>)
      endif
      Delay(9)
      yes_no = YesNo("Group associated filetypes?")
      if yes_no in 1, 2
         group_type = yes_no
         WriteProfileInt(macroname, "GroupType", group_type)
      endif
   endif

   Delay(9)
   open_type_refreshed = FALSE
   UpdateDisplay()
end

proc Main()
   configure()
end

