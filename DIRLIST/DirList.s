
/*
   Macro.         DirList.
   Author.        Carlo Hogeveen.
   Date-written.  23 december 1999.
   Version 2.     8 juli 2004.
   Compatibility. TSE Pro 3.0 upwards.

   With direcorynames as input this macro creates a new file inside TSE,
   containing a list of filenames including their full pathname of all
   files in those directories and their subdirectories.

   In case of a problem with the directoryname this macro creates an empty
   file.

   Version 2.
      Starting from commandline didn't work correctly anyway, so deleted that.
      Now also accepts quoted dirs in parameter.
      Added parameter "all" for all files in all directories.
      <Escape> now interrupts the running macro.
      Added windmill.
      Added file-date, -time and -size.
      Known bug: filesize erroneous above 2 GB.
*/

integer ok = TRUE
string windmill [4] = "/-\|"
integer progress = 0

proc DirList(string dirname)
   integer handle = -1
   string separator [1] = "\"
   if dirname[Length(dirname)] == "\"
      separator = ""
   endif
   if progress >= 4
      progress = 1
   else
      progress = progress + 1
   endif
   if  KeyPressed()
   and GetKey() == <Escape>
      ok = FALSE
   endif
   if ok
      Message(windmill[progress], " ", dirname, " ... ")
      handle = FindFirstFile(dirname + separator + "*", -1)
      if handle <> -1
         repeat
            if FFAttribute() & _DIRECTORY_
               if not (FFName() in ".", "..")
                  DirList(dirname + separator + FFName())
               endif
            else
               AddLine(Format(FFDateStr(),
                              " ",
                              FFTimeStr(),
                              " ",
                              FFSize():12,
                              " ",
                              dirname + separator + FFName()))
            endif
         until not ok
            or not FindNextFile(handle, -1)
         FindFileClose(handle)
      endif
   endif
end

proc Main()
   integer old_dateformat = Set(DateFormat, 6)
   integer old_timeformat = Set(TimeFormat, 1)
   integer teller = 0
   string dirnames [255] = Query(MacroCmdLine)
   if GetToken(dirnames, " ", 1) == ""
      Ask("For which directories do you want a list of all filenames:",
          dirnames,
          GetFreeHistory(SplitPath(CurrMacroFilename(), _NAME_) + ":dirnames"))
   endif
   if Lower(Trim(dirnames)) == "all"
      dirnames = ""
      for teller = Asc("a") to Asc("z")
         if FileExists(Chr(teller) + ":\")
            if dirnames == ""
               dirnames = Chr(teller) + ":"
            else
               dirnames = dirnames + " " + Chr(teller) + ":"
            endif
         endif
      endfor
   endif
   if NumFileTokens(dirnames) > 0
      repeat
         teller = teller + 1
      until not GetBufferId("DirList." + Str(teller))
      if CreateBuffer("DirList." + Str(teller))
         SetUndoOff()
         for teller = 1 to NumFileTokens(dirnames)
            DirList(GetFileToken(dirnames, teller))
         endfor
         SetUndoOn()
      else
         Warn("DirList could not create buffer: ", "DirList." + Str(teller))
      endif
   endif
   UpdateDisplay(_ALL_WINDOWS_REFRESH_)
   if ok
      BegFile()
      Message("Ready.")
   else
      Message("DirList aborted.")
   endif
   Set(DateFormat, old_dateformat)
   Set(TimeFormat, old_timeformat)
   PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end


