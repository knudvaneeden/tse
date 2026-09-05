/*
   Macro.      Edebug.
   Author.     Carlo Hogeveen (hyphen@xs4all.nl)
   Date.       29 September 1998.

   Version 2, 14 October 1998.
      Bug solved.
         There was an incorrect current file at the start of a debug session.
*/
/*
   TSE 2.5 upto and including version 2.5e cannot debug macroes that
   use #include files correctly. In later versions this should be fixed.

   This macro "Edebug" (extended debug) is a quick workaround.

   You call it via the menu's Macro Execute or with the execmacro() command:

      edebug my_macro my_macro_parameters

   Edebug without parameters debugs the current file.
   Of course Edebug also works for macroes without #include files.

   Edebug acts as a shell around the regular Debug macro, by first creating
   a temporary source file, in which all "#includes" are expanded.

   Because Edebug also builds in comments in the temporary source,
   it is still possible to see which (#include) file you are debugging.
*/
/*
   Installation:

      Put edebug.s in TSE's mac directory and compile the macro Edebug.

      You might want to change the TSE *.ui file you are using,
      by changing 'execmacro("debug ...' to 'execmacro("edebug ...'.
*/

proc main()
   string old_wordset [32] = set(wordset, chrset("\d033-\d255"))
   string mcl [128] = query(macrocmdline)
   string macro [128] = gettoken(mcl, " ", 1)
   string tempname [255] = ""
   string ifile [255] = ""
   string comment [255] = ""
   integer temp_id = 0
   integer abandon_later = true
   integer error = 0
   integer number = 0
   integer old_ilba = set(insertlineblocksabove, on)
   integer old_uap = set(unmarkafterpaste, on)
   pushposition()
   if macro == ""
      macro = currfilename()
   else
      mcl = substr(mcl, pos(macro, mcl) + length(macro) + 1, 128)
   endif
   if getbufferid(macro)
      gotobufferid(getbufferid(macro))
      abandon_later = false
   elseif getbufferid(macro + ".s")
      gotobufferid(getbufferid(macro + ".s"))
      abandon_later = false
   elseif getbufferid(loaddir() + "mac\" + macro)
      gotobufferid(getbufferid(loaddir() + "mac\" + macro))
      abandon_later = false
   elseif getbufferid(loaddir() + "mac\" + macro + ".s")
      gotobufferid(getbufferid(loaddir() + "mac\" + macro + ".s"))
      abandon_later = false
   elseif fileexists(macro)
      editfile(macro, _dont_prompt_)
   elseif fileexists(macro + ".s")
      editfile(macro, _dont_prompt_)
   elseif fileexists(loaddir() + "mac\" + macro)
      editfile(loaddir() + "mac\" + macro, _dont_prompt_)
   elseif fileexists(loaddir() + "mac\" + macro + ".s")
      editfile(loaddir() + "mac\" + macro, _dont_prompt_)
   endif
   macro = currfilename()
   repeat
      number = number + 1
      tempname = format(loaddir(), "mac\edebug", number:2:"0", ".s")
   until number > 99
      or not fileexists(tempname)
   if number > 999
      warn("Edebug cannot create tempfile: ", tempname)
      error = 1
   else
      pushblock()
      markline(1,numlines())
      copy()
      if abandon_later
         abandonfile()
      endif
      if editfile(tempname, _dont_prompt_)
         temp_id = getbufferid()
         paste()
         insertline("// Begin macro " + macro)
         endfile()
         addline("// End macro " + macro)
         if lfind("[ \t]*proc[ \t]+main", "gix")
            insertline("// Main procedure of macro " + macro)
         endif
         if lfind("[ \t]*proc[ \t]+whenloaded", "gix")
            insertline("// Whenloaded procedure of macro " + macro)
         endif
         begfile()
         while error == 0
         and   lfind("^[ \t]*\#include", "ix")
         and   lfind("include","cgi")
            wordright()
            ifile = getword()
            if ifile [1] == "["
               ifile = splitpath(currfilename(), _drive_|_path_)
                       + substr(ifile, 3, length(ifile) - 4)
            else
               ifile = substr(ifile, 2, length(ifile) - 2)
            endif
            if getbufferid(ifile)
               abandon_later = false
            else
               abandon_later = true
            endif
            comment = gettext(1, currlinelen())
            begline()
            inserttext("// Begin ", _insert_)
            addline("// End " + comment)
            if editfile(ifile, _dont_prompt_)
               markline(1, numlines())
               copy()
               if abandon_later
                  abandonfile()
               else
                  gotobufferid(temp_id)
               endif
               paste()
               begline()
            else
               error = 2
            endif
         endwhile
      else
         warn("Edebug cannot create tempfile: ", tempname)
         error = 1
      endif
      popblock()
   endif
   set(wordset, old_wordset)
   set(insertlineblocksabove, old_ilba)
   set(unmarkafterpaste, old_uap)
   if error == 0
      gotobufferid(temp_id)
      savefile()
      abandonfile()
      popposition()
      pushposition()
      execmacro("debug " + tempname + " " + mcl)
   endif
   for number = 0 to 99
      if fileexists(format(loaddir(), "mac\edebug", number:2:"0", ".s"))
         erasediskfile(format(loaddir(), "mac\edebug", number:2:"0", ".s"))
      endif
      if fileexists(format(loaddir(), "mac\edebug", number:2:"0", ".mac"))
         erasediskfile(format(loaddir(), "mac\edebug", number:2:"0", ".mac"))
      endif
   endfor
   abandonfile(temp_id)
   popposition()
   purgemacro("edebug")
end
