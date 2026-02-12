 /*
   Macro          Ansi2oem
   Author         Carlo.Hogeveen@xs4all.nl
   Date           10 Februari 2004
   Version 2      9 March 2004
   Version 3      21 JUne 2004
   Compatibility  GUI versions of TSE Pro 4.0 upwards.

   Documentation:
      See the help in the source below, or press F1 after executing the macro.

   Installation:
      This macro only works for the GUI versions of TSE (g32.exe).
      Copy the source file to TSE's "mac" directory, compile it,
      and run it to configure it.

      (Configuring it automatically adds it to or removes it from
       the Macro AutoloadList.)

   History
      Version 1, 10 Februari 2004.
         Initial version.
      Version 2, 9 March 2004.
         Remember and return to last character.
      Version 3, 21 June 2004.
         Minute improvements in the help text.
*/

/*

(06-21-2004) Ansi2oem for GUI versions of TSE Pro. In editing text it
can show ANSI characters as OEM, and line drawing characters in 3D. It
can do this  very configurably. With ANSI fonts get rid of those
control characters all looking like squares, and get line drawing(s)
back! At the same time it serves as an ascii chart which correctly
shows each character's look. Version 3 remembers the last character and
has minute improvements to the help text. Author:
Carlo.Hogeveen@xs4all.nl.

*/

integer curr_char         = 0
integer autoload_id       = 0
integer for_specific_font = FALSE
// Note for macro programmers: these two strings need to be filled to make TSE
// think that their actual length is 32. This is necessary, because setting
// bits in a string does not change its length. Therefore an initial length
// of 32 is necessary for later doing string comparisons with these strings.
string  oem_charset [32]  = "12345678901234567890123456789012"
string  ddd_charset [32]  = "12345678901234567890123456789012"

proc ansi2oem_help()
   Set(Attr, Query(TextAttr))
   ClrScr()
   VGotoXY(1,1)
   WriteLine("")
   WriteLine("   ANSI to OEM                                                (screen 1 of 3)")
   WriteLine("")
   WriteLine("   Using this tool, you can select for each character of each ANSI font,")
   WriteLine("   whether TSE in the editing text should show an OEM character instead.")
   WriteLine("")
   WriteLine("   For an ANSI or OEM font you can make TSE show 3D line drawing characters.")
   WriteLine("")
   WriteLine("   You can set this for one specific font, or as a default for all fonts.")
   WriteLine("   The latter is usually sufficient.")
   WriteLine("")
   WriteLine("   ONLY THE DISPLAY IS CHANGED, NOT THE CHARACTER CODES IN THE BUFFER !!!")
   WriteLine("")
   WriteLine("   Somebody else viewing your file might see alternative characters.")
   WriteLine("   Only ASCII characters 32 thru 127 have the same meaning everywhere.")
   WriteLine("   Above character 127 ANSI is the rule (at least in the Windows world),")
   WriteLine("   and you deviate from it at your own peril.")
   WriteLine("")
   WriteLine("   One strategie would be, to only change the display of control characters")
   WriteLine("   below 32, because in ANSI fonts they all look like squares, and to change")
   WriteLine("   the display of line drawing characters to enable line drawing again, but")
   WriteLine("   not to depend on other people and applications to see the same characters")
   WriteLine("   as the ones whose display you changed.")
   WriteLine("")
   Write    ("   Press any key to go to the next help screen ...")
   GetKey()
   ClrScr()
   WriteLine("")
   WriteLine("   ANSI to OEM                                                (screen 2 of 3)")
   WriteLine("")
   WriteLine("   After making changes you will be asked to save the changed settings")
   WriteLine("   as default for all fonts, or specifically for the current font.")
   WriteLine("   Normally the latter isn't useful, but if you want it, it's there.")
   WriteLine("")
   WriteLine("   For TSE 4.0 and 4.2 some line drawing characters cannot be shown in 3D yet.")
   WriteLine("   This should be solved in futere versions of TSE.")
   WriteLine("")
   WriteLine("   The tool shows six columns per character:")
   WriteLine("      The character's ANSI code in decimal.")
   WriteLine("      The character's ANSI code in hexadecimal.")
   WriteLine("      The picture of the character depending on the selected display type.")
   WriteLine("      The selected display type: ANSI, OEM or 3D.")
   WriteLine("      The possible pictures of a character: for [ANSI,] OEM and 3D.")
   WriteLine("      The character description: for control characters only.")
   WriteLine("")
   WriteLine("   This tool cannot show ANSI characters for an OEM font.")
   WriteLine("")
   WriteLine("")
   WriteLine("")
   WriteLine("")
   WriteLine("")
   Write    ("   Press any key to go to the next help screen ...")
   GetKey()
   ClrScr()
   WriteLine("")
   WriteLine("   ANSI to OEM                                                (screen 3 of 3)")
   WriteLine("")
   WriteLine("   Keys:")
   WriteLine("")
   WriteLine("      Arrow up/down, Page up/down, Home, End.")
   WriteLine("")
   WriteLine("      Spacebar      Toggle the setting of the current character.")
   WriteLine("      Enter         Insert the current character into the text.")
   WriteLine("      Escape        Leave the tool.")
   WriteLine("")
   WriteLine("      Digits                                  Go to decimal ASCII code.")
   WriteLine("      Alt KeypadDigits without leading zero   Go to decimal OEM   code.")
   WriteLine("      Alt KeypadDigits with    leading zero   Go to decimal ANSI  code.")
   WriteLine("")
   WriteLine("      Character     Go to that character.")
   WriteLine("")
   WriteLine("      Alt D         Delete saved Ansi2oem settings for the current font.")
   WriteLine("      Alt U         Uninstall Ansi2oem.")
   WriteLine("")
   WriteLine("   Note: Some machines need the NumLock key to be ON")
   WriteLine("         for the Alt KeyPadDigits to work.")
   WriteLine("")
   WriteLine("")
   Write    ("   Press any key to leave the help screens ...")
   GetKey()
   ClrScr()
end


proc set_ascii_descriptions()
   SetGlobalStr("Ansi2oem_0" , "NUL Null")
   SetGlobalStr("Ansi2oem_1" , "SOH Start of Header")
   SetGlobalStr("Ansi2oem_2" , "STX Start of Text")
   SetGlobalStr("Ansi2oem_3" , "ETX End of Text")
   SetGlobalStr("Ansi2oem_4" , "EOT End of Transmission")
   SetGlobalStr("Ansi2oem_5" , "ENQ Enquiry")
   SetGlobalStr("Ansi2oem_6" , "ACK Acknowledge")
   SetGlobalStr("Ansi2oem_7" , "BEL Bell")
   SetGlobalStr("Ansi2oem_8" , "BS  BackSpace")
   SetGlobalStr("Ansi2oem_9" , "HT  Horizontal Tab")
   SetGlobalStr("Ansi2oem_10", "LF  Line Feed")
   SetGlobalStr("Ansi2oem_11", "VT  Vertical Tab")
   SetGlobalStr("Ansi2oem_12", "FF  Form Feed")
   SetGlobalStr("Ansi2oem_13", "CR  Carriage Return")
   SetGlobalStr("Ansi2oem_14", "SO  Shift Out")
   SetGlobalStr("Ansi2oem_15", "SI  Shift In")
   SetGlobalStr("Ansi2oem_16", "DLE Data Link Escape")
   SetGlobalStr("Ansi2oem_17", "DC1 Device Control 1")
   SetGlobalStr("Ansi2oem_18", "DC2 Device Control 2")
   SetGlobalStr("Ansi2oem_19", "DC3 Device Control 3")
   SetGlobalStr("Ansi2oem_20", "DC4 Device Control 4")
   SetGlobalStr("Ansi2oem_21", "NAK Negative Acknowledge")
   SetGlobalStr("Ansi2oem_22", "SYN Synchronous Idle")
   SetGlobalStr("Ansi2oem_23", "ETB End Transmission Block")
   SetGlobalStr("Ansi2oem_24", "CAN Cancel")
   SetGlobalStr("Ansi2oem_25", "EM  End of Medium")
   SetGlobalStr("Ansi2oem_26", "SUB Substitute")
   SetGlobalStr("Ansi2oem_27", "ESC Escape")
   SetGlobalStr("Ansi2oem_28", "FS  File Separator")
   SetGlobalStr("Ansi2oem_29", "GS  Group Separator")
   SetGlobalStr("Ansi2oem_30", "RS  Record Separator")
   SetGlobalStr("Ansi2oem_31", "US  Unit Separator")
end

string proc get_font(string property)
   string  result    [255] = ""
   string  font_name [255] = ""
   integer font_pointsize  = 0
   integer font_flags      = 0
   string  font_type [255] = ""
   GetFont(font_name, font_pointsize, font_flags)
   if (font_flags & _FONT_OEM_)
      font_type = "OEM"
   else
      font_type = "ANSI"
   endif
   case Lower(property)
      when "name"
         result = font_name
      when "size"
         result = Str(font_pointsize)
      when "type"
         result = font_type
   endcase
   return(result)
end

proc redisplay()
   integer old_hookstate = SetHookState(OFF)
   string s  [255] = ""
   string a  [255] = ""
   string char [1] = ""
   integer x = 0
   integer y = 0
   integer x_len = 0
   integer use_3d = FALSE
   for y = 1 to Query(PopWinRows)
      GetStrAttrXY(1, y, s, a, Query(PopWinCols))
      x_len = Length(RTrim(s))
      for x = 1 to x_len
         char = s[x]
         use_3d = iif(GetBit(ddd_charset, Asc(char)), _USE_3D_, FALSE)
         if use_3d
         or GetBit(oem_charset, Asc(char))
            PutOemStrXY(x, y, char, Asc(a[x]), use_3d)
         endif
      endfor
   endfor
   SetHookState(old_hookstate)
end

integer proc is_autoloaded()
   integer result = FALSE
   integer org_id = GetBufferId()
   PushBlock()
   if not autoload_id
      autoload_id = CreateTempBuffer()
   endif
   if autoload_id
      GotoBufferId(autoload_id)
      EmptyBuffer()
      InsertFile(LoadDir() + "TseLoad.dat", _DONT_PROMPT_)
      UnMarkBlock()
      if  CurrLineLen() > 1
      and lFind(SplitPath(CurrMacroFilename(), _NAME_), "giw")
         result = TRUE
      endif
   endif
   PopBlock()
   GotoBufferId(org_id)
   return(result)
end

string proc get_section_name()
   string section_name [255] = "Ansi2oem for " + get_font("name")
   if  not for_specific_font
   and not LoadProfileSection(section_name)
      section_name = "Ansi2oem default font settings"
   endif
   return(section_name)
end

proc chars_to_bits(string item_name, integer offset, var string charset)
   string zero_and_one_chars [128] = GetProfileStr(get_section_name(), item_name, "")
   integer i = 0
   for i = offset to offset + 127
      if zero_and_one_chars[i - offset + 1] == "1"
         SetBit(charset, i)
      else
         ClearBit(charset, i)
      endif
   endfor
end

proc load_settings()
   curr_char = Val(GetProfileStr(get_section_name(), "last_char", ""))
   chars_to_bits("oem_000_127",   0, oem_charset)
   chars_to_bits("oem_128_255", 128, oem_charset)
   chars_to_bits("ddd_000_127",   0, ddd_charset)
   chars_to_bits("ddd_128_255", 128, ddd_charset)
end

proc bits_to_chars(var string charset, string item_name, integer offset)
   string zero_and_one_chars [128] = ""
   integer i = 0
   for i = offset to offset + 127
      if GetBit(charset, i)
         zero_and_one_chars = zero_and_one_chars + "1"
      else
         zero_and_one_chars = zero_and_one_chars + "0"
      endif
   endfor
   WriteProfileStr(get_section_name(), item_name, zero_and_one_chars)
end

proc save_settings(integer specifically)
   for_specific_font = specifically
   bits_to_chars(oem_charset, "oem_000_127",   0)
   bits_to_chars(oem_charset, "oem_128_255", 128)
   bits_to_chars(ddd_charset, "ddd_000_127",   0)
   bits_to_chars(ddd_charset, "ddd_128_255", 128)
   for_specific_font = FALSE
   if not is_autoloaded()
      AddAutoLoadMacro(SplitPath(CurrMacroFilename(), _NAME_))
   endif
end

proc WhenPurged()
   UnHook(redisplay)
   UnHook(WhenPurged)
   if curr_char <> 0
      WriteProfileStr(get_section_name(), "last_char", Str(curr_char))
   endif
end

proc WhenLoaded()
   load_settings()
   Hook(_POST_UPDATE_ALL_WINDOWS_, redisplay)
   Hook(_ON_ABANDON_EDITOR_, WhenPurged)
end

menu save_settings_menu()
   title = "You changed Ansi2oem settings:"
   history
   "Save settings as &default   for all         fonts", save_settings(FALSE)
   "Save settings &specifically for the current font ", save_settings(TRUE)
   "Escape, do &not save settings"
end

proc un_install()
   integer done = FALSE
   string section_name [255] = ""
   if YesNo("Really uninstall Ansi2oem?") == 1
      curr_char = 0
      LoadProfileSectionNames()
      repeat
         if GetNextProfileSectionName(section_name)
            if Lower(SubStr(section_name, 1, 9)) == "ansi2oem "
               if RemoveProfileSection(section_name)
                  LoadProfileSectionNames()
               else
                  Warn("Could not remove profile: ", section_name)
                  done = TRUE
               endif
            endif
         else
            done = TRUE
         endif
      until done
      DelAutoLoadMacro(SplitPath(CurrMacroFilename(), _NAME_))
      PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
   else
      Set(Attr, Query(TextAttr))
      ClrScr()
   endif
end

proc Main()
   integer stop = FALSE
   integer first_char = 0
   integer y = 0
   integer c = 0
   integer use_3d = FALSE
   integer action = 0
   string  font_type [255] = ""
   string  char_type [8] = ""
   string old_ddd_charset [32] = ddd_charset
   string old_oem_charset [32] = oem_charset
   string decimal_code [3] = ""
   PushPosition()
   PushBlock()
   set_ascii_descriptions()
   Set(Cursor, OFF)
   Set(Attr, Query(TextAttr))
   ClrScr()
   repeat
      font_type = get_font("type")
      PutStrXY(1, 1, Format(  get_section_name(),
                              "   (font=",
                              get_font("name"),
                              ", size=",
                              get_font("size"),
                              ", type=",
                              font_type,
                              ")":-255))
      if curr_char <= (Query(ScreenRows) - 4) / 2
         first_char = 0
      elseif curr_char >= 255 - ((Query(ScreenRows) - 4) / 2)
         first_char = 255 - Query(ScreenRows) + 4 + 1
      else
         first_char = curr_char - ((Query(ScreenRows) - 4) / 2)
      endif
      c = first_char
      for y = 3 to Query(ScreenRows) - 2
         use_3d = iif(GetBit(ddd_charset, c), _USE_3D_, FALSE)
         if font_type == "OEM"
            if use_3d
               char_type = "3d"
            else
               char_type = "-"
            endif
         else
            if use_3d
               char_type = "3d"
            elseif GetBit(oem_charset, c)
               char_type = "oem"
            else
               char_type = "ansi"
            endif
         endif
         PutStrXY(4, y, Format(c:3,c:4:" ":16,char_type:12, "        ",
                               GetGlobalStr("Ansi2oem_"+ Str(c)):-255))
         if c == curr_char
            PutStrXY(16, y,"<-")
         endif
         if use_3d
         or GetBit(oem_charset, c)
            PutOemStrXY(14, y, Chr(c), Query(Attr), use_3d)
         else
            PutStrXY   (14, y, Chr(c))
         endif
         if font_type == "OEM"
            PutStrXY   (26, y, Chr(c))
            PutOemStrXY(27, y, Chr(c), Query(Attr), _USE_3D_)
         else
            PutStrXY   (25, y, Chr(c))
            PutOemStrXY(26, y, Chr(c))
            PutOemStrXY(27, y, Chr(c), Query(Attr), _USE_3D_)
         endif
         c = c + 1
      endfor
      PutStrXY(4, Query(ScreenRows), "Press F1 for Help")
      action = GetKey()
      if not (action in <0> .. <9>, <keypad0> .. <keypad9>)
         decimal_code = ""
      endif
      case action
         when <0> .. <9>, <keypad0> .. <keypad9>
            decimal_code = decimal_code + Chr(action mod 256)
            curr_char = Val(decimal_code)
            if curr_char == 0
               decimal_code = ""
            endif
         when <Alt D>
            if LoadProfileSection(get_section_name())
               if YesNo("Really delete saved '" + get_section_name() + "'?") == 1
                  RemoveProfileSection(get_section_name())
                  Message("Done ...")
                  Delay(36)
               endif
            else
               Warn("Error: '" + get_section_name() + "' not saved yet.")
            endif
            Set(Attr, Query(TextAttr))
            ClrScr()
         when <Alt U>
            un_install()
            stop = TRUE
         when <f1>
            ansi2oem_help()
         when <Escape>
            stop = TRUE
         when <CursorUp>, <GreyCursorUp>
            if curr_char > 0
               curr_char = curr_char - 1
            endif
         when <CursorDown>, <GreyCursorDown>
            if curr_char < 255
               curr_char = curr_char + 1
            endif
         when <Home>, <GreyHome>
            curr_char = 0
         when <end>, <GreyEnd>
            curr_char = 255
         when <PgUp>, <GreyPgUp>
            if curr_char < Query(ScreenRows) - 5
               curr_char = 0
            else
               curr_char = curr_char - Query(ScreenRows) + 5
            endif
         when <PgDn>, <GreyPgDn>
            if curr_char > 255 - Query(ScreenRows) + 5
               curr_char = 255
            else
               curr_char = curr_char + Query(ScreenRows) - 5
            endif
         when <Enter>, <GreyEnter>
            PushKey(curr_char)
            PushKey(<Escape>)
         when <Spacebar>
            if font_type == "OEM"
               if GetBit(ddd_charset, curr_char)
                  ClearBit(ddd_charset, curr_char)
               else
                  SetBit(ddd_charset, curr_char)
               endif
            else
               if GetBit(oem_charset, curr_char)
                  if GetBit(ddd_charset, curr_char)
                     ClearBit(oem_charset, curr_char)
                     ClearBit(ddd_charset, curr_char)
                  else
                     SetBit(ddd_charset, curr_char)
                  endif
               else
                  SetBit  (oem_charset, curr_char)
                  ClearBit(ddd_charset, curr_char)
               endif
            endif
         otherwise
            curr_char = action mod 256
      endcase
   until stop
   if oem_charset <> old_oem_charset
   or ddd_charset <> old_ddd_charset
      save_settings_menu()
      if MenuOption() in 0, 3
         curr_char = 0
      endif
   endif
   Set(Cursor, ON)
   PopBlock()
   PopPosition()
   UpdateDisplay(_ALL_WINDOWS_REFRESH_)
end



