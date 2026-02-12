/*
   Macro          Database
   Author         Carlo.Hogeveen@xs4all.nl
   Date           13 September 2005
   Version        0.01
   Compatibility  TSE Pro 4.0 upwards

   With this macro and an Oracle MsDos SqlPLus client TSE can be used from
   the commandline to view or edit database objects.

   That in itself is not very practical, but you can for instance use this
   to configure TSE as an external tool of PL/SQL Developer.
   When you are logged in in PL/SQL Developer, and an Oracle database-
   object is active (not necessarily opened) in the browser-pane,
   then PL/SQL Developer knows enough to call TSE for that object.
   PL/SQL Developer: http://www.allroundautomations.com .

   With this macro TSE can be called with the commandline-parameters:
      database action object_type schema object_name full_connect_string
   These parameters have to be entered without quotes, and are case-
   insensitive:
      database             "database", the name of this macro.
      action               "view" or "edit".
      object_type          "package" or "package body". No others for now.
      schema               The owner of the database-object.
      object_name          The name of the database-object.
      full_connect_string  "user/password@database_name".

   Installation:
      Copy this macro to TSE's "mac" directory.
      In the macro source change the value of the "SqlPlus" string at the top
      to the Dos (!) version of SqlPlus that is appropriate for your system.
      Add the macro to the top of your Macro AUtoLoad List: it must be the
      top, so that it can hide its commandline-parameters from other macros
      that process the commandline.

   Known bugs:
      The macro doesn't clean up all of it's temporary files yet, though it
      does clean up the ones with passwords in it.
      The macro doesn't use the "schema" parameter yet, but assumes that the
      object that the "user" sees is the correct one.

   History:
      0.01  13 September 2005
         This initial version "only" supports the viewing (action = "view")
         or editing (action = "edit") of database package specifications
         (object_type = "package") or package bodies (object_type =
         "package body"). Other object_types are not supported yet.
         All parameters are to be entered without quotes.
*/

string SqlPlus [255] = "plus80"

#ifdef EDITOR_VERSION
   #if EDITOR_VERSION < 4200h
      #define EDITOR_VERSION_LT_42 TRUE
   #endif
#else
   #define EDITOR_VERSION_LT_42 TRUE
#endif

#ifdef EDITOR_VERSION_LT_42
   integer proc MkDir(string dir)
      integer result = TRUE
      Delay(1)
      Dos("mkdir " + QuotePath(dir), _DONT_PROMPT_|_DONT_CLEAR_)
      Delay(1)
      return(result)
   end
#endif

integer ok               = TRUE
string  macro_name [255] = ""
string  tmp_dir    [255] = ""
integer bat_id           = 0
string  bat_file   [255] = ""
integer sql_id           = 0
string  sql_file   [255] = ""

proc after_file_save()
   integer org_id            = GetBufferId()
   string  org_file    [255] = CurrFilename()
   string  org_connect [255] = GetBufferStr(macro_name + ":Connect")
   string  org_action  [255] = GetBufferStr(macro_name + ":Action" )
   string  result_file [255] = SplitPath(CurrFilename(), _DRIVE_|_PATH_|_NAME_)
                             + iif(CurrExt() == "",
                                   "",
                                   "_" + SubStr(CurrExt(), 2, 255)
                             + ".log")
   integer quitting          = GetBufferInt(macro_name + ":Quitting")
   if  GetBufferStr(macro_name + ":Action"  ) == "edit"
   and GetBufferStr(macro_name + ":Filename") == CurrFilename()
      if Query(Beep)
         Alarm()
      endif
      UpdateDisplay(_ALL_WINDOWS_REFRESH_)
      if MsgBox("", "Save changes to database?", _YES_NO_) == 1
         GotoBufferId(bat_id)
         EmptyBuffer()
         AddLine(SubStr(tmp_dir,1,1) + ":")
         AddLine(Format("cd ", QuotePath(tmp_dir)))
         AddLine(Format(sqlplus,
                        " -s ",
                        org_connect,
                        ' @',
                        macro_name,
                        ".sql > ",
                        macro_name,
                        ".lst 2>&1"))
         AddLine("exit")
         if SaveAs(CurrFilename(), _OVERWRITE_|_DONT_PROMPT_)
            GotoBufferId(sql_id)
            EmptyBuffer()
            AddLine(Format("@",
                           org_action,
                           "\",
                           SplitPath(org_file, _NAME_|_EXT_)))
            AddLine("exit")
            if SaveAs(CurrFilename(), _OVERWRITE_|_DONT_PROMPT_)
               Delay(1)
               EraseDiskFile(QuotePath(tmp_dir + macro_name + ".lst"))
               Delay(1)
               Dos(QuotePath(bat_file), _DONT_PROMPT_|_DONT_CLEAR_)
               Delay(1)
               if EditFile(QuotePath(tmp_dir + macro_name + ".lst"), _DONT_PROMPT_)
                  if GetBufferId(result_file)
                     AbandonFile(GetBufferId(result_file))
                  endif
                  ChangeCurrFilename(result_file, _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
                  FileChanged(FALSE)
                  if quitting
                     List("Also quitting new " +
                          SplitPath(CurrFilename(), _NAME_|_EXT_),
                          LongestLineInBuffer())
                     GotoBufferId(org_id)
                  endif
               endif
            else
               Warn(macro_name, ": Cannot save ", CurrFilename())
               ok = FALSE
            endif
         else
            Warn(macro_name, ": Cannot save ", CurrFilename())
            ok = FALSE
         endif
      endif
   endif
end

proc on_file_quit()
   if GetBufferStr(macro_name + ":Action") == "edit"
      SetBufferInt(macro_name + ":Quitting", TRUE)
   endif
end

proc on_exit_called()
   integer org_id   = GetBufferId()
   integer start_id = 0
   PrevFile(_DONT_LOAD_)
   NextFile(_DONT_LOAD_)
   if BufferType() == _NORMAL_
      start_id = GetBufferId()
      repeat
         if GetBufferStr(macro_name + ":Action") == "edit"
            on_file_quit()
         endif
         NextFile(_DONT_LOAD_)
      until GetBufferId() == start_id
   endif
   GotoBufferId(org_id)
end

proc do_action(string action,
               string object_type,
               string schema,
               string object_name,
               string connect_string)
   integer org_id = GetBufferId()
   string  object_file [255] = ""
   if ok
      if not (Lower(action) in 'view', 'edit')
         Warn(macro_name, ": Action not supported by TSE: ", Lower(action))
         ok = FALSE
      endif
   endif
   if ok
      if not (Lower(object_type) in 'package', 'package body')
         Warn(macro_name, ": Object_type not supported by TSE: ", Lower(object_type))
         ok = FALSE
      endif
   endif
   if ok
      if not FileExists(tmp_dir + Lower(action) + "\")
         if not MkDir(tmp_dir + Lower(action) + "\")
            Warn(macro_name, ": Cannot create ", tmp_dir + Lower(action) + "\")
            ok = FALSE
         endif
      endif
   endif
   if ok
      GotoBufferId(bat_id)
      EmptyBuffer()
      AddLine(SubStr(tmp_dir,1,1) + ":")
      AddLine(Format("cd ", QuotePath(tmp_dir)))
      AddLine(Format(sqlplus,
                     " -s ",
                     connect_string,
                     ' @',
                     macro_name,
                     ".sql > ",
                     macro_name,
                     ".lst 2>&1"))
      AddLine("exit")
      SaveAs(CurrFilename(), _OVERWRITE_|_DONT_PROMPT_)
      GotoBufferId(org_id)
   endif
   if ok
      GotoBufferId(sql_id)
      EmptyBuffer()
      AddLine("set echo off")
      AddLine("set escape off")
      AddLine("set pagesize 0")
      AddLine("set feedback off")
      AddLine("set linesize 1000")
      AddLine("set serveroutput on size 1000000 format wrapped")
      AddLine("set trim on")
      AddLine("set trims on")
      AddLine("set verify off")
      AddLine("set wrap on")
      AddLine("")
      case Lower(object_type)
         when "package"
            object_file = Format(Lower(action),
                                 "\",
                                 Lower(object_name),
                                 ".pks")
         when "package body"
            object_file = Format(Lower(action),
                                 "\",
                                 Lower(object_name),
                                 ".pkb")
      endcase
      AddLine("spool " + QuotePath(object_file))
      AddLine("prompt set echo off")
      AddLine("prompt set escape off")
      AddLine("prompt set pagesize 0")
      AddLine("prompt set feedback off")
      AddLine("prompt set linesize 1000")
      AddLine("prompt set long 2000000000")
      AddLine("prompt set longc 2000000000")
      AddLine("prompt set serveroutput ON size 1000000 format wrapped")
      AddLine("prompt set trim on")
      AddLine("prompt set trims on")
      AddLine("prompt set verify off")
      AddLine("prompt set wrap on")
      AddLine("prompt")
      AddLine("prompt create or replace")
      AddLine("select text from all_source")
      AddLine("   where name  = '" + Upper(object_name) + "'")
      AddLine("     and owner = '" + Upper(schema)      + "'")
      AddLine("     and type  = '" + Upper(object_type) + "'")
      AddLine("   order by line;")
      AddLine("prompt /")
      AddLine("prompt sho err")
      AddLine("prompt")
      AddLine("spool off")
      AddLine("exit")
      SaveAs(CurrFilename(), _OVERWRITE_|_DONT_PROMPT_)
      GotoBufferId(org_id)
      Delay(1)
      Dos(QuotePath(bat_file), _DONT_PROMPT_|_DONT_CLEAR_)
      Delay(1)
      if FileExists(QuotePath(tmp_dir + object_file))
         if EditFile(QuotePath(tmp_dir + object_file), _DONT_PROMPT_)
            SetBufferStr(macro_name + ":Action"  , Lower(action))
            SetBufferStr(macro_name + ":Filename", CurrFilename())
            SetBufferStr(macro_name + ":Connect" , connect_string)
         else
            Warn(macro_name, ": Cannot open: ", object_name)
            ok = FALSE
         endif
      else
         Warn(macro_name, ": Cannot unload: ", object_name)
         ok = FALSE
      endif
   endif
   EraseDiskFile(sql_file)
   EraseDiskFile(bat_file)
end

proc WhenLoaded()
   integer org_id = GetBufferId()
   string parameters[255] = Query(DosCmdLine)
   macro_name = SplitPath(CurrMacroFilename(), _NAME_)
   tmp_dir    = GetEnvStr("tmp")
   if not FileExists(tmp_dir)
      tmp_dir = GetEnvStr("temp")
      if not FileExists(tmp_dir)
         tmp_dir = "c:\"
         if not FileExists(tmp_dir)
            Warn(macro_name, ": Cannot find a place to create a temporary directory")
            ok = FALSE
         endif
      endif
   endif
   if ok
      tmp_dir = tmp_dir + "\Tse\"
      if not FileExists(tmp_dir)
         if not MkDir(tmp_dir)
            Warn(macro_name, ": Cannot create ", tmp_dir)
            ok = FALSE
         endif
      endif
   endif
   if ok
      tmp_dir = tmp_dir + macro_name + "\"
      if not FileExists(tmp_dir)
         if not MkDir(tmp_dir)
            Warn(macro_name, ": Cannot create ", tmp_dir)
            ok = FALSE
         endif
      endif
   endif
   if ok
      bat_file = tmp_dir + macro_name + ".bat"
      bat_id   = EditFile(QuotePath(bat_file), _DONT_PROMPT_)
      if bat_id
         BufferType(_HIDDEN_)
         GotoBufferId(org_id)
      else
         Warn(macro_name, ": Cannot create temporary .bat file")
         ok = FALSE
      endif
   endif
   if ok
      sql_file = tmp_dir + macro_name + ".sql"
      sql_id   = EditFile(QuotePath(sql_file), _DONT_PROMPT_)
      if sql_id
         BufferType(_HIDDEN_)
         GotoBufferId(org_id)
      else
         Warn(macro_name, ": Cannot create temporary .sql file")
         ok = FALSE
      endif
   endif
   if ok
      if Pos(Lower(macro_name), Lower(parameters)) == 1
         Set(DosCmdLine, "")
         // DelHistoryStr(_EDIT_HISTORY_, 1)
         if  Lower(GetToken(parameters, " ", 3)) == "package"
         and Lower(GetToken(parameters, " ", 4)) == "body"
            do_action(GetToken(parameters, " ", 2),
                      GetToken(parameters, " ", 3) + " " +
                      GetToken(parameters, " ", 4),
                      GetToken(parameters, " ", 5),
                      GetToken(parameters, " ", 6),
                      GetToken(parameters, " ", 7))
         else
            do_action(GetToken(parameters, " ", 2),
                      GetToken(parameters, " ", 3),
                      GetToken(parameters, " ", 4),
                      GetToken(parameters, " ", 5),
                      GetToken(parameters, " ", 6))
         endif
      endif
      Hook(_ON_FILE_QUIT_   , on_file_quit   )
      Hook(_ON_EXIT_CALLED_ , on_exit_called )
      Hook(_AFTER_FILE_SAVE_, after_file_save)
   endif
   if not ok
      PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
      AbandonEditor()
   endif
end

