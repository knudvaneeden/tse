   /*
   Macro          DontOpen
   Author         Carlo.Hogeveen@xs4all.nl
   Date           8 aug 2007
   Compatibility  TSE Pro 3 upwards
   Version        1.0.0
   Date           12 aug 2007

   This macro protects you against (accidentally) opening unwanted files,
   like "*.bak" files, or like files in Subversion's "\.svn\"
   meta-directories, or whatever.

   Especially when you use TSE's -a and -s options and wildcards you can
   and want to open whole direcories or directorytrees of files, but without
   those pesky exceptions.

   This macro notices it when you try to open such files, and asks your
   confirmation to NOT open them.

   You get one question for each File Open command that results in opening
   such files, and your answer applies to all files opened by that specific
   File Open command.

   You are asked the question only when the editor is otherwise idle,
   so that the macro doesn't interfere with other macros.

   For the same reason the macro internally works by letting TSE open the
   files, and then closing the unwanted ones.

   The macro works by matching the names of opened files against a TSE
   regular expression, and asks the user a question to confirm to not
   open the matching files.

   You can configure your own regular expression and question by executing
   the macro. The default configuration is for .bak and Subversion metafiles.

   Note:
      If you don't want to exclude certain files by default, but only
      occasionally, then take a look at the AbanName macro instead.

   Installation:
      Put and compile this macro in TSE's "mac" directory.

      Execute the macro at least once to activate and/or reconfigure it.

   Test:
      Try to open a .bak file: it should fail, and when no other files are
      open it should open a new empty file.

*/

string  default_dontopen_question [255] = "Don't open .bak files and Subversion's meta-files?"
string  default_dontopen_regexp   [255] = "{\\\.svn\\}|{\.bak$}"

string  dontopen_question [255] = ""
string  dontopen_regexp   [255] = ""
integer match_id = 0
string  macro_name [255] = ""

integer proc regexp_matches_string(string regexp, string text)
   integer result = FALSE
   integer org_id = GetBufferId()
   if match_id
      GotoBufferId(match_id)
   else
      match_id = CreateTempBuffer()
   endif
   EmptyBuffer()
   InsertLine(text)
   if lFind(regexp, "gix")
      result = TRUE
   endif
   GotoBufferId(org_id)
   return(result)
end

proc unload_unwanted_files()
   integer start_id = 0
   integer curr_id = 0
   integer ignore_asked = FALSE
   integer ignore_answer = 0
   if NumFiles()
      PrevFile(_DONT_LOAD_)
      NextFile(_DONT_LOAD_)
      start_id = GetBufferId()
      repeat
         NextFile(_DONT_LOAD_)
         curr_id = GetBufferId()
         if regexp_matches_string(dontopen_regexp, CurrFilename())
            if not GetBufferInt(macro_name + ":keep_open")
               if not ignore_asked
                  ignore_asked = TRUE
                  UpdateDisplay()
                  Set(X1, 10)
                  Set(Y1, 10)
                  ignore_answer = YesNo(dontopen_question)
               endif
               if ignore_answer <= 1
                  PrevFile(_DONT_LOAD_)
                  AbandonFile(curr_id)
               else
                  SetBufferInt(macro_name + ":keep_open", TRUE)
               endif
            endif
         endif
      until curr_id == start_id
      if GetBufferId() == start_id
         PrevFile(_DONT_LOAD_)
      endif
      NextFile()
      if NumFiles() == 0
         // I would have liked to have other options, but NewFile() is the
         // only concluding action that works OK from an _idle_ hook.
         // Note: PushKey() and PressKey() don't work from an _idle_ hook
         //       either.
         NewFile()
      endif
      UpdateDisplay()
   endif
end

integer timer = 0

proc idle()
   if timer
      timer = timer - 1
      if not timer
         unload_unwanted_files()
      endif
   endif
end

proc on_first_edit()
   if BufferType() == _NORMAL_
      timer = 2
   endif
end

proc WhenLoaded()
   macro_name = SplitPath(CurrMacroFilename(), _NAME_)
   dontopen_question = GetProfileStr(macro_name, "question",
                        "Don't open .bak files and Subversion's meta-files?")
   dontopen_regexp   = GetProfileStr(macro_name, "question",
                                                      "{\\\.svn\\}|{\.bak$}")
   Hook(_IDLE_, idle)
   Hook(_ON_FIRST_EDIT_, on_first_edit)
end

proc configure()
   integer original_id        = GetBufferId()
   integer autoload_id        = 0
   integer is_autoload_macro  = FALSE
   string  changes   [255]    = "No changes."
   string  question   [25]    = ""
   string  old_value [255]    = ""
   string  new_value [255]    = ""
   integer answer             = 0
   autoload_id = EditBuffer(LoadDir() + "tseload.dat", _SYSTEM_)
   if autoload_id
      is_autoload_macro = lFind(macro_name, "giw")
      GotoBufferId(original_id)
      AbandonFile(autoload_id)
   endif
   if is_autoload_macro
      question = "Keep this macro active?"
   else
      question = "Activate this macro?"
   endif
   Set(X1, 10)
   Set(Y1, 10)
   answer = YesNo(question)
   if  answer <> 1
   and answer <> 2
   and is_autoload_macro
      answer = 1
      Message("You escaped!")
      Delay(18)
      Message("")
   endif
   if     answer == 1
      if not is_autoload_macro
         changes = "Changed."
         AddAutoLoadMacro(macro_name)
      endif
      old_value = GetProfileStr(macro_name, "regexp", default_dontopen_regexp)
      new_value = old_value
      Set(X1, 10)
      Set(Y1, 10)
      if Ask("Don't open files with names matching this regular expression:",
             new_value)
         if old_value <> new_value
            changes = "Configuration changed."
            WriteProfileStr(macro_name, "regexp", new_value)
            dontopen_regexp = new_value
         endif
      else
         Message("You escaped!")
         Delay(18)
         Message("")
      endif
      old_value = GetProfileStr(macro_name, "question",
                                                   default_dontopen_question)
      new_value = old_value
      Set(X1, 10)
      Set(Y1, 10)
      if Ask("Which question asks confirmation to not open matching files:",
             new_value)
         if old_value <> new_value
            changes = "Configuration changed."
            WriteProfileStr(macro_name, "question", new_value)
            dontopen_question = new_value
         endif
      else
         Message("You escaped!")
         Delay(18)
         Message("")
      endif
   elseif answer == 2
      RemoveProfileSection(macro_name)
      DelAutoLoadMacro(macro_name)
      PurgeMacro(macro_name)
      changes = "Not opening certain files is deactivated."
   else
      Message("You escaped!")
      Delay(18)
   endif
   Message(changes)
end

proc Main()
   configure()
end

