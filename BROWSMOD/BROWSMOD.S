/*
   Macro:      BrowsMod
   Author:     Carlo.Hogeveen@xs4all.nl
   Date:       6 jan 2002
   Rewritten:  4 sep 2003

   TSE 3.0 and above. Configurably sets a file in and out of browsmode 
   either for being a read-only diskfile or if a part of its 
   drive/path/name/ext matches one of a configurable set of strings.

   Put this macro in TSE's "mac" directory, compile it,
   and then run it for info and to configure it.

   If either configuration option is used, 
   it puts itself in TSE's Macro AutoLoad List,
   otherwise it removes itself from there.
*/

string last_filename  [255] = ""
string option_diskfiles [1] = ""
string option_strings [255] = ""

integer last_id             = 0
integer past_ids_id         = 0
integer disable_browsemode  = FALSE
integer reconfigure         = FALSE

proc configure_browsemode()
   integer org_id = GetBufferId()
   integer cfg_id = EditFile(QuotePath(LoadDir() + "mac\BrowsMod.cfg"),
                             _DONT_PROMPT_)
   integer inf_id = CreateTempBuffer()
   integer index  = 0
   EmptyBuffer()
   AddLine("")
   AddLine("")
   AddLine("")
   AddLine("")
   AddLine("")
   AddLine("")
   AddLine("")
   AddLine("   ReadOnly files are files you can't write to disk, either because their")
   AddLine("   disk-attribute is read-only, or because their name (possibly intentionally)")
   AddLine("   contains characters not allowed in a diskfilename.")
   AddLine("")
   AddLine("   BrowseMode goes further. It means, that you can browse through the file,")
   AddLine("   but you can't change it inside the editor. This protects you from working")
   AddLine("   on a file before finding out that it is unsavable.")
   AddLine("")
   AddLine("   This macro automatically turns BrowseMode ON for files which have a")
   AddLine("   read-only disk-attribute or the name of which contains one of the user-")
   AddLine("   configurable character(string)s, and otherwise it turns BrowsMode OFF.")
   AddLine("")
   AddLine("   The user can always override the automatically selected BrowseMode for")
   AddLine("   the current file by using the BrowsMode toggle in TSE's menu's.")
   AddLine("")
   AddLine("")
   BegFile()
   UpdateDisplay()
   repeat
      Ask("Set BrowseMode ON for write-protected disk-files (y/n)?",
          option_diskfiles)
      Delay(9)
   until Lower(option_diskfiles) in "y", "n"
   option_diskfiles = Lower(option_diskfiles)
   if option_strings == ""
      option_strings = "* readonly read_only read\only read/only"
   endif
   Ask("Set BrowseMode ON when filename contains one of these strings:",
       option_strings)
   option_strings = Lower(Trim(option_strings))
   index = 1
   while index <= Length(option_strings)
      if  option_strings [index]     == " "
      and option_strings [index + 1] == " "
         option_strings = SubStr(option_strings, 1, index)
                       + SubStr(option_strings, index + 2, 255)
      endif
      index = index + 1
   endwhile
   if option_diskfiles == "y"
   or option_strings   <> ""
      disable_browsemode = FALSE
      if cfg_id
         GotoBufferId(cfg_id)
         EmptyBuffer()
         InsertText(option_diskfiles)
         AddLine(option_strings)
         SaveAs(CurrFilename(), _DONT_PROMPT_|_OVERWRITE_)
         AddAutoLoadMacro("BrowsMod")
         Message("BrowseMode now automatically ON/OFF for ReadOnly/Other files ...")
      else
         Warn("Error editing ", LoadDir(), "mac\BrowsMod.cfg")
      endif
   else
      disable_browsemode = TRUE
   endif
   AbandonFile(inf_id)
   AbandonFile(cfg_id)
   GotoBufferId(org_id)
   Delay(90)
   UpdateDisplay(_WINDOW_REFRESH_)
end

proc show_new_browsemode(integer set_browsemode)
   integer old_textattr = Query(TextAttr)
   UpdateDisplay()
   PopWinOpen(10, 10, 24, 12, 1, "Browse mode", Query(MenuBorderAttr))
   Set(Attr, Query(HelpTextAttr))
   ClrScr()
   if set_browsemode
      Write("   ON")
   else
      Write("   OFF")
   endif
   Delay(36)
   PopWinClose()
   Set(TextAttr, old_textattr)
end

proc idle()
   integer determine_browsemode = FALSE
   integer statusline_row     = 0
   integer token_no           = 0
   integer set_browsemode     = FALSE
   string statusline_char [1] = ""
   string statusline_attr [1] = ""
   if reconfigure
      reconfigure        = FALSE
      disable_browsemode = FALSE
      configure_browsemode()
   else
      if disable_browsemode
         EraseDiskFile(LoadDir() + "mac\BrowsMod.cfg")
         DelAutoLoadMacro("BrowsMod")
         Message("BrowseMode no longer automatically ON/OFF for ReadOnly/Other files ...")
         PurgeMacro("BrowsMod")
         Delay(90)
         UpdateDisplay(_WINDOW_REFRESH_)
      else
         if BufferType() == _NORMAL_
            if last_id == GetBufferId()
               if last_filename <> CurrFilename()
                  last_filename =  CurrFilename()
                  determine_browsemode = TRUE
               endif
            else
               last_id       = GetBufferId()
               last_filename = CurrFilename()
               if past_ids_id == 0
                  past_ids_id = CreateBuffer("BrowsMod:past_ids", _HIDDEN_)
                  if past_ids_id == 0
                     Message('Failed: CreateBuffer("BrowsMod:past_ids", _HIDDEN_)')
                     Delay(54)
                  endif
               else
                  GotoBufferId(past_ids_id)
               endif
               if not lFind("^" + Str(last_id) + "$", "gx")
                  determine_browsemode = TRUE
                  BegFile()
                  InsertLine(Str(last_id))
               endif
               GotoBufferId(last_id)
            endif
            if determine_browsemode
               if option_diskfiles == "y"
                  if FileExists(CurrFilename()) & _READONLY_
                     set_browsemode = TRUE
                  endif
               endif
               for token_no = 1 to NumTokens(option_strings, " ")
                  if Pos(Lower(GetToken(option_strings, " ", token_no)),
                         Lower(CurrFilename()))
                     set_browsemode = TRUE
                  endif
               endfor
               if BrowseMode() <> set_browsemode
                  BrowseMode(set_browsemode)
                  if Query(MsgAttr) <> Query(StatusLineAttr)
                     if Query(StatusLineAtTop)
                        statusline_row = 1
                     else
                        statusline_row = Query(WindowRows)
                     endif
                     GetStrAttrXY(1, statusline_row, statusline_char, statusline_attr, 1)
                     if Asc(statusline_attr) == Query(StatusLineAttr)
                        UpdateDisplay(_STATUS_LINE_REFRESH_)
                     endif
                  endif
                  show_new_browsemode(set_browsemode)
               endif
            endif
         endif
      endif
   endif
end

proc WhenPurged()
   AbandonFile(past_ids_id)
end

proc WhenLoaded()
   integer org_id = GetBufferId()
   integer cfg_id = 0
   integer index  = 0
   if FileExists(LoadDir() + "mac\BrowsMod.cfg")
      cfg_id = EditFile(QuotePath(LoadDir() + "mac\BrowsMod.cfg"),
                        _DONT_PROMPT_)
      BegFile()
      option_diskfiles = GetWord()
      if Down()
         option_strings = GetText(1, CurrLineLen())
      else
         // This is probably the old one-line .cfg file of the previous
         // version of BrowsMod. Therefore reconfigure BrowsMod.
         reconfigure = TRUE
         option_diskfiles = ""
         option_strings   = ""
      endif
      AbandonFile(cfg_id)
   else
      disable_browsemode = TRUE
   endif
   if not (option_diskfiles in "y", "n")
      option_diskfiles = "y"
   endif
   option_strings = Lower(Trim(option_strings))
   index = 1
   while index <= Length(option_strings)
      if  option_strings [index]     == " "
      and option_strings [index + 1] == " "
         option_strings = SubStr(option_strings, 1, index)
                        + SubStr(option_strings, index + 2, 255)
      endif
      index = index + 1
   endwhile
   Hook(_IDLE_, idle)
   GotoBufferId(org_id)
end

proc Main()
   reconfigure = TRUE
end

