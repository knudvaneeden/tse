/*
   Macro          ChAlName
   Author         Carlo.Hogeveen@xs4all.nl
   Date           26 jun 2007
   Compatibility  TSE Pro 2.5e upwards
   Version        1.0.0

   Change All Filenames for all loaded files.

      With one command you can replace the drive, path and/or filename
      for all loaded files.

      You cannot use wildcards or regular expressions.

   Installation.
      Copy this file to TSE's "mac" directory, and compile it.

      Optionally add it to the Potpourri menu, or attach it to a key.

   Use:
      Just execute the macro anyway you like.
*/

proc Main()
   integer org_id = GetBufferId()
   integer pos_fr = 0
   integer pos_to = 0
   string old_part [255] = ""
   string new_part [255] = ""
   string new_name [255] = ""
   Ask("Replace which part of each loaded drive:\path\filename:", old_part)
   if old_part <> ""
      if Ask("Replace this by:", new_part)
         repeat
            pos_fr = Pos(Lower(old_part), Lower(CurrFilename()))
            if pos_fr > 0
               pos_to = pos_fr + Length(old_part) - 1
               new_name = SubStr(CurrFilename(), 1, pos_fr - 1)
                        + new_part
                        + SubStr(CurrFilename(),
                                 pos_to + 1,
                                 Length(CurrFilename()) - pos_to)
               ChangeCurrFilename(new_name,
                  _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
            endif
            NextFile()
         until GetBufferId() == org_id
      endif
   endif
   PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end

