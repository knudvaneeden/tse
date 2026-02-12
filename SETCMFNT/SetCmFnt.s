/*
   Macro    SetCmFnt
   Author   Carlo.Hogeveen@xs4all.nl
   Date     17 January 2004

   This macro will ensure that WinDlgs' DlgAscii and Dos()
   start the tool CharMap for the current TSE font.

   It only works for the GUI versions of TSE.
   Tested with Windows 98 SE, NT SP6, 2000 Pro, XP Pro.

   DlgAscii is a public proc in Dieter Koessl's WinDlgs.
   CharMap is a standard Windows command.

   For example, you can use these lines in a key assignment or macro:
      ExecMacro("SetCmFnt") ExecMacro("DlgAscii")
   or:
      ExecMacro("SetCmFnt") Dos("start CharMap", _dont_prompt_|_dont_clear_)
*/

proc Main()
   integer org_id = GetBufferId()

   string  font_name [255] = ""
   integer pointsize       = 0
   integer flags           = 0

   string win_dir         [255] = ""
   string profile_name    [255] = ""
   string profile_section [255] = ""

   if isGUI()
      GetFont(font_name, pointsize, flags)
      if font_name == ""
         Message("Cannot determine TSE font ...")
         Delay(36)
      else
         win_dir = GetEnvStr("windir")
         if win_dir == ""
            win_dir = "c:\winnt"
         endif
         if     FileExists(win_dir + "\win.ini")   // Irrelevant.
            profile_name = win_dir + "\win.ini"
         elseif FileExists("c:\winnt\win.ini")     // Windows NT, Windows 2000.
            profile_name = "c:\winnt\win.ini"
         elseif FileExists("c:\windows\win.ini")   // Windows 98, Windows XP.
            profile_name = "c:\windows\win.ini"
         endif
         if profile_name == ""
            Message("Win.ini not found")
            Delay(36)
         else
            if LoadProfileSection("MSUCE", profile_name)
               profile_section = "MSUCE"
            elseif LoadProfileSection("MSCharMap", profile_name)
               profile_section = "MSCharMap"
            endif
            if profile_section == ""
            or GetProfileStr(profile_section, "Font", "", profile_name) == ""
               Message("Wrong font: just close CharMap and retry ...")
               Delay(72)
            else
               WriteProfileStr(profile_section, "Font", font_name, profile_name)
            endif
         endif
      endif
   endif
   GotoBufferId(org_id)
   PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end

