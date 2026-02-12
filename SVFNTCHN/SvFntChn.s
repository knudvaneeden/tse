/*
   Macro    SvFntChn
   Author   Carlo.Hogeveen@xs4all.nl
   Date     1 March 2004

   SvFntChn for GUI versions of TSE.

   This macro automates optionally saving TSE's settings
   after you have changed a font setting.

   When you have configured TSE's Display Startup Options to use a font's
   "Last Saved Settings", then it is so easy to forget, that after changing
   a font, you have to separately do a "Save Current Settings".
   This macro automates that.

   It is not possible to save only the font settings, neither through
   the TSE menus nor through this macro.

   If you change a font without saving and then change it back to its last
   saved settings, then you get no question to save changed font settings.

   While you might change a font to other styles than Regular or Bold,
   it is not possible to save those other styles: this is a TSE limitation.
   I just mention it to keep you from wondering too, not because I think
   anyone needs to permanently edit in Italic.

   Installation:
      Copy SvFntChn.s to TSE's "mac" directory,
      compile it,
      add "SvFntChn" to TSE's Macro AutoLoad List,
      and restart TSE.
*/

string  svd_font [MAXSTRINGLEN] = ""
integer svd_pointsize = 0
integer svd_flags = 0

string  old_font [MAXSTRINGLEN] = ""
integer old_pointsize = 0
integer old_flags = 0

string  new_font [MAXSTRINGLEN] = ""
integer new_pointsize = 0
integer new_flags = 0

integer system_delay = 0

string proc flags_to_name(integer flags)
   string result [MAXSTRINGLEN] = ""
   if flags & _FONT_BOLD_
      result = "Bold"
   else
      result = "Regular"
   endif
   return(result)
end

proc check_for_font_changes()
   string changes [MAXSTRINGLEN] = ""
   GetFont(new_font, new_pointsize, new_flags)
   new_flags = new_flags & _FONT_BOLD_
   if new_font      <> old_font
   or new_pointsize <> old_pointsize
   or new_flags     <> old_flags
      if new_font == old_font
         changes = old_font
      else
         changes = Format(old_font, " -> ", new_font)
      endif
      if new_flags == old_flags
         changes = Format(changes, "   ", flags_to_name(old_flags))
      else
         changes = Format(changes, "   ", flags_to_name(old_flags),
                                  " -> ", flags_to_name(new_flags))
      endif
      if new_pointsize == old_pointsize
         changes = Format(changes, "   ", old_pointsize)
      else
         changes = Format(changes, "   ", old_pointsize,
                                  " -> ", new_pointsize)
      endif
      if  new_font      == svd_font
      and new_pointsize == svd_pointsize
      and new_flags     == svd_flags
         old_font      = svd_font
         old_pointsize = svd_pointsize
         old_flags     = svd_flags
      else
         if Query(Beep)
            Alarm()
            Delay(2)
         endif
         Message(changes)
         Delay(2)
         Set(X1,10)
         Set(Y1,10)
         if YesNo("Font settings have been changed - Save all settings?") == 1
            SaveSettings()
            svd_font      = new_font
            svd_pointsize = new_pointsize
            svd_flags     = new_flags
         endif
         old_font      = new_font
         old_pointsize = new_pointsize
         old_flags     = new_flags
         Delay(2)
         UpdateDisplay()
      endif
   endif
end

proc on_abandon_editor()
   check_for_font_changes()
end

proc idle()
   system_delay = system_delay + 1
   if system_delay > 17
      system_delay = 0
      check_for_font_changes()
   endif
end

proc WhenLoaded()
   GetFont(svd_font, svd_pointsize, svd_flags)
   svd_flags     = svd_flags & _FONT_BOLD_
   old_font      = svd_font
   old_pointsize = svd_pointsize
   old_flags     = svd_flags
   Hook(_ON_ABANDON_EDITOR_, on_abandon_editor)
   Hook(_IDLE_             , idle             )
end

