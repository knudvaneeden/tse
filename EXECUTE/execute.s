/*
   Macro          Execute
   Author         Carlo.Hogeveen@xs4all.nl
   Date           24 oct 2006.
   Version        1.00
   Date           25 oct 2006.
   Compatability  TSE Pro 2.5e upwards.

   Purpose: Dynamically run a line of TSE's built-in commands
            without having to program a macro for it.

   This macro can be called
   -  From the Macro Execute menu: just run built-in commands interactively!
   -  From the Dos commandline (AFTER any filenames): also interactively!
   -  From the Potpourri menu: with no parameters it gives Help
                               by opening this sourcefile.
   -  From another macro.

   TO USE THIS MACRO FROM THE COMMANDLINE,
   FIRST ADD IT TO THE TOP OF THE MACRO AUTOLOAD LIST.

   When not added to the top, it has been known to be disrupted by other
   autoload macros.

   You can change the name of the macro without disrupting it.
   TSE 2.5 users must not make the macroname longer than 7 characters.
   Don't forget to delete the old name from the Macro AutoLoad List,
   and to add the new name to the top of the Macro AutoLoad List.

   The macro generates a helper-macro named "macroname_" in the same
   directory as itself. You needn't know that, but you might notice it.

   Dos commandline syntax:
      editorcommand filename ... { -e macroname | -emacroname | -x }
                    ["] TSE-statement ... ["]

   Macro commandline syntax:
      execute TSE-statement ...

   Editorcommand can be e, e32, g, g32, depending on your editor version.

   Filename is your regular TSE file, optionally preceded with TSE-options,
   optionally containing wildcards, and there may be more than one filename.

   For this macro the -e macroname option or -x option must come AFTER the
   filename(s). The option may NOT be quoted. You can use one of these
   options only once per commandline.

   The -x option is the handiest one, but it might in theory overlap one
   day with another macro or a new TSE version: removing it from this macro
   would consist of removing one line of code.

   TSE-statements can be anything within these two limits:
   -  The line "proc Main() tse-statements end" must be compileable.
      If it is not, the compile-error is returned as a warning.
   -  After the editorcommand and the spaces after it, the remainder of the
      line may not be longer than 128 characters.

   Windows says an opening quote doesn't need to be closed if at the end of a
   line. A closing quote must of course have been opened.

   Dos commandline examples:

      g32 -x Warn('Hello World!')
      g32 -x "Warn('Hello World!')"
      g32 -x"Warn('Hello World!')"
      g32 -x"Warn('Hello World!')
      g32 cats.txt -x "Warn('Hello World!')"
      g32 cats.txt dogs.txt -x "Warn('Hello World!')"
      g32 -a *.txt -x "Warn('Hello World!')"
      // Illegally over three lines for readability:
      g32 cats.txt -x "BegFile() while lFind('cat','iw')
                       lReplace('cat','dog','inw1') Right(3)
                       InsertText('()',_INSERT_) endwhile"
      // The same properly in one line:
      g32 cats.txt -x "BegFile() while lFind('cat','iw') lReplace('cat','dog','inw1') Right(3) InsertText('()',_INSERT_) endwhile"

      The double quotes keep Windows from turning commas into spaces. (It
      happens even before the commandline reaches the editor: I didn't see
      that one coming.)

      The last example should be one line, and is only 8 characters below the
      maximum.

   Macro commandline examples:

      // After opening TSE's Macro Execute menu:
      execute Warn('Hello World!')
      execute Warn("Hello World!")
      // From another macro:
      execmacro("execute Warn('Hello World!')")
      execmacro('execute Warn("Hello World!")')

*/

// The following determines the editor version at compile-time.
#ifdef EDITOR_VERSION
   // From TSE 3.0 upwards the built-in constant EDITOR_VERSION exists.
#else
   #ifdef WIN32
      // From TSE 2.6 upwards the built-in constant WIN32 exists.
      #define EDITOR_VERSION 0x2800
      // TSE < 2.5e and TSE 2.6 are not supported by this macro.
      // TSE 2.5e (the Dos version of TSE) has existed so long, that almost
      // every Dos user has upgraded to it, so supporting older versions is
      // no longer worth the effort. Due to a bug in TSE 2.5c (and presumably
      // lower versions, which is one of the reasons for not supporting them)
      // the line below is syntax-checked despite the lack of WIN32 in those
      // versions, and generates a desired compiler error.
      // TSE 2.6 was an intermediate 32-bits version from which anyone could
      // freely upgrade to TSE 2.8. The parameter constant _MFSKIP_ exists
      // since TSE 2.8, so the line below will also generate a desired
      // compiler error for TSE 2.6.
      #define UNSUPPORTED_TSE_VERSION _MFSKIP_
   #else
      // Since all other TSE versions were excluded, this must be TSE 2.5e.
      #define EDITOR_VERSION 0x2500
   #endif
#endif

#if EDITOR_VERSION == 0x2500
   #define MAXSTRINGLEN 255
#endif

string  macroname    [MAXSTRINGLEN] = ""
string  error1       [MAXSTRINGLEN] = ""
string  error2       [MAXSTRINGLEN] = ""
integer started_from_commandline    = FALSE
integer macro_id                    = 0
integer wait_for_files_to_be_loaded = FALSE
integer wait_for_files_time         = 0

string proc mTrim(string doublespaced_text)
   string result [MAXSTRINGLEN] = Trim(doublespaced_text)
   while Pos("  ", result)
      result = SubStr(result, 1, Pos("  ", result) - 1)
             + SubStr(result, Pos("  ", result) + 1, MAXSTRINGLEN)
   endwhile
   return(result)
end

proc execute_already()
   if error1 == ""
      ExecMacro(SplitPath(CurrMacroFilename(),
                          _DRIVE_|_PATH_|_NAME_)
                + "_.mac")
      UpdateDisplay()
   else
      Warn(macroname, ": ", mTrim(error1), " ", mTrim(error2))
   endif
   PurgeMacro(macroname)
   PurgeMacro(macroname + "_")
end

proc compilation(var string error1, var string error2)
   integer compilation_ok = FALSE
   error1 = ""
   error2 = ""
   SaveFile()
   while KeyPressed() // Discard extraneus key-presses.
       GetKey()
   endwhile
   // Remember: you cannot debug macro-parts that use pushed keys.
   PushKey(<enter>)
   PushKey(<c>)
   ExecMacro("compile " + CurrFilename())
   if  KeyPressed()
   and GetKey()== <enter>
      compilation_ok = TRUE
   endif
   // End of pushed keys part: debug breakpoint could be put hereafter.
   if not compilation_ok
      NextWindow()
      error1 = GetText(1,CurrLineLen())
      if Down()
         error2 = GetText(1,CurrLineLen())
      endif
      PrevWindow()
      OneWindow()
   endif
end

proc xecute(string cmdline)
   integer org_id                       = GetBufferId()
   string  macroname_s   [MAXSTRINGLEN] = SplitPath(CurrMacroFilename(),
                                                    _DRIVE_|_PATH_|_NAME_)
                                          + "_.s"
   #if EDITOR_VERSION > 0x2500
      BufferVideo()
   #endif
   macro_id = EditFile(macroname_s, _DONT_PROMPT_)
   if macro_id
      EmptyBuffer()
      if Trim(cmdline) == ""
         InsertText('EditFile("'
                    + SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_|_NAME_)
                    + '.s")')
      else
         InsertText(cmdline)
      endif
      BegLine()
      InsertText("proc Main() ", _INSERT_)
      EndLine()
      InsertText(" end"   , _INSERT_)
      compilation(error1, error2)
      GotoBufferId(org_id)
      AbandonFile(macro_id)
      UpdateDisplay()
      #if EDITOR_VERSION > 0x2500
         UnBufferVideo()
      #endif
      if started_from_commandline
         wait_for_files_to_be_loaded = TRUE
         wait_for_files_time         = 0
      else
         execute_already()
      endif
   else
      #if EDITOR_VERSION > 0x2500
         UnBufferVideo()
      #endif
      PurgeMacro(macroname)
      PurgeMacro(macroname + "_")
   endif
end

integer proc check_doscmdline(string xecutable)
   integer x_position = 0
   integer x_length   = 0
   integer x_quoted   = 0
   string  cmdline [MAXSTRINGLEN] = ""

   if     Pos(      Lower(xecutable) + ' "', Lower(Query(DosCmdLine))) == 1
      x_position = 1
      x_length   = Length(xecutable) + 2
      x_quoted   = TRUE
   elseif Pos(      Lower(xecutable) + '"' , Lower(Query(DosCmdLine))) == 1
      x_position = 1
      x_length   = Length(xecutable) + 1
      x_quoted   = TRUE
   elseif Pos(      Lower(xecutable) + " " , Lower(Query(DosCmdLine))) == 1
      x_position = 1
      x_length   = Length(xecutable) + 1
      x_quoted   = FALSE
   elseif Pos(" " + Lower(xecutable) + ' "', Lower(Query(DosCmdLine)))
      x_position = Pos(" " + Lower(xecutable), Lower(Query(DosCmdLine)))
      x_length   = Length(xecutable) + 3
      x_quoted   = TRUE
   elseif Pos(" " + Lower(xecutable) + '"', Lower(Query(DosCmdLine)))
      x_position = Pos(" " + Lower(xecutable), Lower(Query(DosCmdLine)))
      x_length   = Length(xecutable) + 2
      x_quoted   = TRUE
   elseif Pos(" " + Lower(xecutable) + " ", Lower(Query(DosCmdLine)))
      x_position = Pos(" " + Lower(xecutable), Lower(Query(DosCmdLine)))
      x_length   = Length(xecutable) + 2
      x_quoted   = FALSE
   endif
   if x_position
      started_from_commandline = TRUE
      cmdline = SubStr(Query(DosCmdLine),
                       x_position + x_length,
                       MAXSTRINGLEN)
      if  x_quoted
      and SubStr(cmdline, Length(cmdline), 1) == '"'
         cmdline = SubStr(cmdline, 1, Length(cmdline) - 1)
      endif
      xecute(cmdline)
      Set(DosCmdLine,
             SubStr(Query(DosCmdLine),
                    1,
                    x_position - 1))
      if Query(DosCmdLine) == ""
         NewFile()
      endif
   endif
   return(x_position)
end

proc idle()
   if wait_for_files_to_be_loaded
      if wait_for_files_time > 0
         wait_for_files_time = wait_for_files_time - 1
      else
         wait_for_files_to_be_loaded = FALSE
         execute_already()
         UnHook(idle)
         if  NumFiles() <= 1
         and Pos("unnamed", Lower(CurrFilename()))
            AbandonEditor()
         endif
      endif
   endif
end

proc WhenLoaded()
//   Warn("doscmdline=", Query(DosCmdLine), ".")
   macroname = SplitPath(CurrMacroFilename(), _NAME_)
   Hook(_IDLE_, idle)
   if check_doscmdline("-e"  + macroname)
   or check_doscmdline("-e " + macroname)
   or check_doscmdline("-x"             )
      macroname = macroname
   endif
end

proc Main()
   if not started_from_commandline
      xecute(Query(MacroCmdLine))
   endif
   PurgeMacro(macroname)
end

