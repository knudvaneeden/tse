/*************************************************************************
  Compile	  Compiles and marks errors for several compilers.

  Author:	  SemWare

  Date:		  Jul 21, 1993 (Steve Watkins)
			  Jul 28, 1995 (Steve Watkins)
				Added support for macro commands via '@'
				Added support for merging previous compile.dat files
				Added support for macro macro_debugging


  Overview:

  Compiles source code, tags the errors, and allows the user to step
  through errors for compilers whose output files are in a regular
  pattern.

  Keys:
			  <Shift F9>	CompileMenu()
			  <Ctrl F9>		CompileCurrentFile()
			  <Alt F8>		NextErrKey()
			  <Alt F7>		PrevErrKey()

  Usage notes:

  After loading this macro, simply press <Ctrl F9> to compile the
  file being edited.  The current file will be saved (if necessary),
  compiled, and the errors will be marked.  The windows will be set
  up with the source in the top and errors in the bottom window.
  Press <Alt F7> and <Alt F8> to go to the previous/next errors,
  respectively.  Pressing <F1> within the Source window provides
  help on the keys.

  If a TSE macro source files in compiled, the user is asked to
  execute the macro if the compile is successful.

  Invoke <Shift F9> to invoke the Compile Menu() for additional
  selections like selecting alternate compilers and setting up new
  or modifying existing compiler setups.

  Copyright 1992-1994 SemWare Corporation.  All Rights Reserved Worldwide.

  Use, modification, and distribution of this SAL macro is encouraged by
  SemWare provided that this statement, including the above copyright
  notice, is not removed; and provided that no fee or other remuneration
  is received for distribution.  You may add your own copyright notice
  to cover new matter you add to the macro, but SemWare Corporation will
  neither support nor assume legal responsibility for any material added
  or any changes made to the macro.

*************************************************************************/

#define EXTRA_KEYS 1
#define COLOR_ERROR_WINDOW 1

/*
	To customize the compile keys to your liking modify these
	keys and recompile this macro.

*/

// Default compile keys

constant NEXT_ERROR_KEY		= <Alt F8>
constant PREV_ERROR_KEY		= <Alt F7>
constant COMPILE_FILE_KEY	= <Ctrl F9>
constant COMPILE_MENU_KEY	= <Shift F9>
constant SWITCH_WINDOW_KEY	= 0 // not defined

// if a path is not specified for the output_fn or the batch_fn
// those files will be placed in the same load directory of the
// compile macro.

string output_fn[]	= "$$err$$.err"
string batch_fn[]	= "$$tmp$$.bat"
string data_fn[]	= "compile.dat"
string compile_fn[80]
string dbg_ext[4] = ".dbg"

constant NOISE		=  TRUE

// END USER-DEFINABLE VARIABLES

string full_output_fn[80]

integer dbg_enabled

#ifdef COLOR_ERROR_WINDOW
integer HiLiteErrorAttr = Color(bright white on red)
integer ErrorAttr = Color(bright cyan on blue)
#endif

// Helper routines

proc SetXY()
	Set(x1,WhereXAbs())
	Set(y1,WhereYAbs())
end

proc mAlarm()
	if noise
		Alarm()
	endif
end

string press_a_key[] = ". Press a key"

proc Msg(string s)
	integer n

	if dbg_enabled
		n = length(s)
		if n - sizeof(press_a_key) > Query(ScreenCols)
			n = Query(ScreenCols) - sizeof(press_a_key)
		endif
		Message(s:n,press_a_key)
		GetKey()
	else
		Message(s)
	endif
end

proc DbgMsg(string s)
	if dbg_enabled
		Msg(s)
	endif
end

integer batch_id, data_id, work_id, err_id
integer err_no, err_row, err_col, num_errors
integer errors_in_source
string	err_msg[250]

string full_data_fn[80]
integer new_file

integer output_no, output_type

string output_types[] = chr(_DEFAULT_) +
						chr(_DONT_PROMPT_) +
						chr(_DONT_CLEAR_) +
						chr(_TEE_OUTPUT_ | _DONT_PROMPT_)

proc SetOutputType(integer n)
	output_no = n
	output_type = ASC(output_types[n])
end

// data for compiler records

string EyeCatcher[] = "Semware compile macro data file"

constant FIND_WIDTH = 80

integer errs_in_src
string	ext[4]
string	desc[48]
string	flags[8]
string	cmd[128]
string	err_ss[FIND_WIDTH], err_opts[8], err_tag[3]
string	fn_ss [FIND_WIDTH], fn_opts [8], fn_tag [3]
string	ln_ss [FIND_WIDTH], ln_opts [8], ln_tag [3]
string	col_ss[FIND_WIDTH], col_opts[8], col_tag[3]
string	msg_ss[FIND_WIDTH], msg_opts[8], msg_tag[3]

constant LIST_WIDTH = sizeof(desc) + 8

integer compiler_start, compiler_end

proc ReadLn(var string s)
	s = GetText(1,CurrLineLen())
	Down()
end

proc ReadSetupInfo()
	string s[5] = ''

	ReadLn(s)
	ReadLn(desc)
	ReadLn(flags)
	errs_in_src = ASC(flags[1])
	SetOutputType(ASC(flags[2]))

	ext = substr(s,2,sizeof(ext))
end

proc ReadRecord()
	integer id

	id = GotoBufferId(data_id)

	compiler_start = CurrLine()

	ReadSetupInfo()

	ReadLn(cmd)

	ReadLn(err_ss)
	ReadLn(err_opts)
	ReadLn(err_tag)

	ReadLn(fn_ss)
	ReadLn(fn_opts)
	ReadLn(fn_tag)

	ReadLn(ln_ss)
	ReadLn(ln_opts)
	ReadLn(ln_tag)

	ReadLn(col_ss)
	ReadLn(col_opts)
	ReadLn(col_tag)

	ReadLn(msg_ss)
	ReadLn(msg_opts)
	ReadLn(msg_tag)

	compiler_end = CurrLine()
	GotoLine(compiler_start)

	GotoBufferId(id)
end

proc WriteLn(string s)
	// only write if line changed so FileChanged() is accurate

	if GetText(1,CurrLineLen()) <> s
		BegLine()
		KillToEol()
		InsertText(s)
	endif
	if not Down()
		AddLine()
	endif
	BegLine()
end

proc SaveCompileData()
	integer id, level, eoltype

	level = Set(MsgLevel, _NONE_)

	eoltype = Set(EOLType, 2)
	id = GotoBufferId(data_id)
	if FileChanged()
		if new_file
			SetXY()
			if YesNo("Create setup file: '"+full_data_fn+"'") == 1
				BegFile()
				InsertLine(EyeCatcher)
				InsertLine(format('DBG=',dbg_ext))
				if SaveAs(full_data_fn, _OVERWRITE_)
					new_file = FALSE
				endif
			endif
		else
			SaveAs(full_data_fn, _OVERWRITE_)
		endif
	endif
	Set(EOLType, eoltype)

	Set(MsgLevel, level)
	GotoBufferId(id)
end

proc WriteRecord()
	integer id

	id = GotoBufferId(data_id)

	flags = chr(errs_in_src) + chr(output_no)

	WriteLn(''+ext)
	WriteLn(desc)
	WriteLn(flags)
	WriteLn(cmd)

	WriteLn(err_ss)
	WriteLn(err_opts)
	WriteLn(err_tag)

	WriteLn(fn_ss)
	WriteLn(fn_opts)
	WriteLn(fn_tag)

	WriteLn(ln_ss)
	WriteLn(ln_opts)
	WriteLn(ln_tag)

	WriteLn(col_ss)
	WriteLn(col_opts)
	WriteLn(col_tag)

	WriteLn(msg_ss)
	WriteLn(msg_opts)
	WriteLn(msg_tag)

	WriteLn('')

	GotoBufferId(id)
end

integer num_compilers

proc GenerateCompilerList(string extension)
	integer line, level

	EmptyBuffer(work_id)

	GotoBufferId(data_id)
	PushPosition()

	num_compilers = 0

	if not lFind(''+extension,'^i$g') and not lFind('','^g')
		Addline("        No compilers found", work_id)
	else
		repeat
			line = CurrLine()
			ReadSetupInfo()
			AddLine(format(ext:-8,desc:-sizeof(desc),line:4), work_id)
			num_compilers = num_compilers + 1
		until not lRepeatFind()
	endif

	PopPosition()

	GotoBufferId(work_id)
	MarkColumn(1,1,NumLines(),5)
	level = Set(MsgLevel, _NONE_)
	Sort(_IGNORE_CASE_)
	Set(MsgLevel, level)
	MarkColumn(1,1,NumLines(),LIST_WIDTH)
end

menu OutputMenu()
	history = output_no
	command = SetOutputType(MenuOption())

	"Clear Screen and Prompt After Shell"           ,   ,   CloseBefore
	"Clear Screen but Don't Prompt After Shell"     ,   ,   CloseBefore
	"Don't Clear Screen or Prompt After Shell"      ,   ,   CloseBefore
	"Tee Output and Don't Prompt After Shell"       ,   ,   CloseBefore
end

menu RulesMenu()
	"&Error   " [format(err_ss:-60):-60]  ,Read(err_ss)     , DontClose
	" Options"  [format(err_opts:-8):-8]  ,Read(err_opts)   , DontClose
	"&Filename" [format(fn_ss:-60):-60]   ,Read(fn_ss)      , DontClose
	" Options"  [format(fn_opts:-8):-8]   ,Read(fn_opts)    , DontClose
	" Tag    "  [fn_tag:-3]               ,Read(fn_tag)     , DontClose
	"&Line    " [format(ln_ss:-60):-60]   ,Read(ln_ss)      , DontClose
	" Options"  [format(ln_opts:-8):-8]   ,Read(ln_opts)    , DontClose
	" Tag    "  [ln_tag:-3]               ,Read(ln_tag)     , DontClose
	"&Column  " [format(col_ss:-60):-60]  ,Read(col_ss)     , DontClose
	" Options"  [format(col_opts:-8):-8]  ,Read(col_opts)   , DontClose
	" Tag    "  [col_tag:-3]              ,Read(col_tag)    , DontClose
	"&Message " [format(msg_ss:-60):-60]  ,Read(msg_ss)     , DontClose
	" Options"  [format(msg_opts:-8):-8]  ,Read(msg_opts)   , DontClose
	" Tag    "  [msg_tag:-3]              ,Read(msg_tag)    , DontClose
end

proc ReadExt()
	if read(ext)
		if ext[1] <> '.'
			ext = '.' + ext
		endif
	endif
end

menu CompilerSetupMenu()
	"E&xtension  " [ext:-4]                                         ,ReadExt()      , DontClose
	"&Description" [format(desc:-sizeof(desc)):-sizeof(desc)]       ,Read(desc)     , DontClose
	"&Command    " [format(cmd:-48):-48]                            ,Read(cmd)      , DontClose
	"&Output     " [format(MenuStr(OutputMenu, output_no):-50):-50] ,OutputMenu()   , DontClose
	"&Rules"                                                        ,RulesMenu()    , DontClose
end

constant ADD_RECORD		=	1,
		 COPY_RECORD	=	2,
		 DELETE_RECORD	=	3

// Read record as specified in list file and leave data file current
proc ReadRecordFromList(integer flag)
	integer n = Val(GetText(LIST_WIDTH + 1,8))

	GotoBufferId(data_id)
	GotoLine(iif(flag == ADD_RECORD, NumLines(), n))
	ReadRecord()
end

proc EditCompilerCommon(integer flag)
	integer id

	id = GetBufferId()

	ReadRecordFromList(flag)

	SetXY()
	if flag == DELETE_RECORD
		if YesNo("Delete "+desc+"?") == 1
			PushBlock()
			MarkLine(compiler_start, compiler_end)
			KillBlock()
			PopBlock()
		endif
	else
		CompilerSetupMenu()
		if length(ext)
			if flag == COPY_RECORD
				GotoLine(NumLines())
			endif
			WriteRecord()
		endif
	endif

	SaveCompileData()

	GotoBufferId(id)

	EndProcess()
end

proc EditCompiler()
	EditCompilerCommon(0)
end

proc AddCompiler()
	EditCompilerCommon(ADD_RECORD)
end

proc DelCompiler()
	if num_compilers
		EditCompilerCommon(DELETE_RECORD)
	endif
end

proc CopyCompiler()
	EditCompilerCommon(COPY_RECORD)
end

integer exec_compiler_done

KeyDef ExecCompilerKeys
	<Escape>		exec_compiler_done = -1		  EndProcess(TRUE)
	<Ctrl Enter>	exec_compiler_done = -2		  EndProcess(TRUE)
	<Enter>			exec_compiler_done = 1		  EndProcess(TRUE)
	<Ins>			AddCompiler()
	<GreyIns>		AddCompiler()
	<Del>			DelCompiler()
	<GreyDel>		DelCompiler()
	<Alt E>			EditCompiler()
	<Alt C>			CopyCompiler()
	<F1>			Help("Compile from list")
end

proc ExecCompilerHook()
	if Enable(ExecCompilerKeys)
		ListFooter("{F1}-Help")
	endif
end

proc MakePrimary()
	string ext[5]
	integer above

	GotoLine(compiler_start)
	ext = GetText(2,sizeof(ext))
	PushBlock()
	MarkLine(compiler_start, compiler_end)
	BegLine()
	if lFind(''+ext,"bi^$")
		while lRepeatFind()
		endwhile
		above = Set(InsertLineBlocksAbove, TRUE)
		MoveBlock()
		Set(InsertLineBlocksAbove, above)
		SaveCompileData()
	endif
	PopBlock()
end

integer proc GetCompiler(string ext, integer invoke_list)
	integer id, display_full_list, exec = FALSE
	string keyword[48] = ext

	id = GotoBufferId(data_id)

	PushBlock()

	if not invoke_list and lFind(''+ext,"^i$g")
		ReadRecord()
		exec = TRUE
	else
		exec_compiler_done = 0
		display_full_list = FALSE
		repeat
			GenerateCompilerList(iif(display_full_list, '', ext))
			BegFile()
			lFind(keyword,"")
			Hook(_LIST_STARTUP_,ExecCompilerHook)
			Set(Y1, 3)
			lList("Select compiler", LIST_WIDTH, Query(ScreenRows), _ENABLE_SEARCH_ | _BLOCK_SEARCH_)
			UnHook(ExecCompilerHook)
			keyword = desc
			if exec_compiler_done == -2
				display_full_list = not display_full_list
				exec_compiler_done = 0
			endif
		until exec_compiler_done
		if exec_compiler_done == 1
			ReadRecordFromList(0)
			MakePrimary()
			exec = TRUE
		endif
	endif

	PopBlock()

	GotoBufferId(id)
	return (exec)
end

string proc JustDrive(string fn)
	return (Chr(ASC(SplitPath(fn, _DRIVE_))))
end

string proc JustPath(string fn)
	string s[80] = SplitPath(fn, _PATH_)
	integer len

	len = Length(s)
	return (iif(len > 1, SubStr(s,1,len - 1), s))
end

string proc JustExt(string fn)
	return (SubStr(SplitPath(fn, _EXT_),2,3))
end

integer proc _FileExists(string fn)
	return (FileExists(fn) & ~(_VOLUME_ | _DIRECTORY_))
end

integer proc TranslateCommands(string fn)
	string s[128]
	integer id, ok

	ok = TRUE

	id = GotoBufferId(batch_id)

	EmptyBuffer()

	AddLine(cmd)
	BegFile()
	while lFind('[~\\]\c;','x')
		DelChar()
		SplitLine()
	endwhile

	lReplace("\;",";","gn")

	if SplitPath(output_fn,_DRIVE_|_PATH_) == ''
		full_output_fn = SplitPath(CurrMacroFileName(), _DRIVE_|_PATH_) + output_fn
	else
		full_output_fn = output_fn
	endif

	// make replacements within command(s)
	BegFile()
	lReplace('&Fn&'     ,fn                   , 'gin')
	lReplace('&Drive&'  ,JustDrive(fn)        , 'gin')
	lReplace('&Path&'   ,JustPath(fn)         , 'gin')
	lReplace('&Name&'   ,SplitPath(fn,_NAME_) , 'gin')
	lReplace('&Ext&'    ,JustExt(fn)          , 'gin')
	lReplace('&Output&' ,full_output_fn       , 'gin')
	lReplace('&CmdLine&',Query(MacroCmdLine)  , 'gin')

	if lFind("&SCPath&","gi")
		s = SearchPath("sc.exe", Query(TSEPath), '.')
		if s == ''
			s = SearchPath("sc.exe", GetEnvStr("PATH"))
			if s == ''
				ok = Warn("Semware's SAL compiler 'sc.exe' not found")
			endif
		endif
		lReplace("&SCPath&",SplitPath(s,_DRIVE_ | _PATH_),"gin")
	endif

	lReplace("&TSEPath&",LoadDir(),"gin")
	lReplace("&TSEFn&",SplitPath(LoadDir(1),_NAME_ | _EXT_),"gin")

	if ok
		// user variable replacement
		PushBlock()
		while lFind('&{[~ \t]#}&','x')
			MarkFoundText()
			s = GetMarkedText()
			s = Substr(s,2,length(s) - 2)
			KillBlock()
			InsertText(GetGlobalStr(s),_INSERT_)
		endwhile
		PopBlock()
	endif

	GotoBufferId(id)
	return (ok)
end

integer proc DeleteOutputFile()
	if not errors_in_source and _FileExists(full_output_fn) and not EraseDiskFile(full_output_fn)
		return (Warn("Cannot delete output file '",full_output_fn,"'"))
	endif
	return (TRUE)
end

integer macro_debugging

integer proc ExecuteCommands(string fn)
	integer id, success, level, save_it
	string	exec[128]

	success = TRUE

	id = GetBufferId()

	PushPosition()
	if GetBufferId(fn)
		GotoBufferId(GetBufferId(fn))
		if FileChanged()
			save_it = GetBufferId() == id
			if not save_it
				case YesNo(format("Save changes to '",fn,"'"))
					when 1	// yes
						save_it = TRUE
					when 2	// no... do nothing
						if macro_debugging
							success = FALSE
						endif
					otherwise
						success = FALSE
				endcase
			endif
			if save_it
				if not SaveFile()
					success = Warn("Cannot save file")
				endif
			endif
		endif
	endif
	PopPosition()

	if success
		Msg(format("Compiling '",desc,"'..."))

		id = GotoBufferId(batch_id)
		BegFile()
		if NumLines() > 1
			exec = batch_fn
			if not SaveAs(batch_fn,_OVERWRITE_)
				success = Warn("Error saving batch file '",batch_fn,"'")
			else
				DbgMsg(format("Executing: batch file ",batch_fn))
			endif
		else
			exec = GetText(1,sizeof(exec))
			DbgMsg(format("Executing: ",exec))
		endif
		GotoBufferId(id)

		if success and exec <> ""
			success = DeleteOutputFile()
			if success
				if exec[1] == '@'
					success = ExecMacro(exec[2..sizeof(exec)])
				else
					level = Set(MsgLevel, _WARNINGS_ONLY_)
					success = DOS(exec, iif(dbg_enabled and output_no == 4, _TEE_OUTPUT_, output_type))
					Set(MsgLevel, level)
					UpdateDisplay(_ALL_WINDOWS_REFRESH_)
				endif
				if success and full_output_fn <> '' and not _FileExists(full_output_fn)
					Msg(format("Error executing ", cmd))
					mAlarm()
					success = FALSE
				endif
			endif
		endif
	endif

	return (success)
end

integer abort

// Mark error information
integer proc Search(string description, string search, string options, string tag)
	integer found, x, y, y1, attr

	if abort
		return (FALSE)
	endif

	found = TRUE
	if search <> ''
		if not lFind(search, options + 'x')
			UnMarkBlock()
			found = FALSE
		endif
	endif

	if found
		MarkFoundText(val(tag))
	endif

	if dbg_enabled
		UpdateDisplay()
		x = WhereX()
		y = WhereY()

		y1 = y - Query(WindowY1) + 8
		if y1 + 4 > Query(ScreenRows)
			y1 = Query(ScreenRows) - 4
		endif

		if not found
			mAlarm()
		endif

		if PopWinOpen(10, y1, 70, y1 + 4, 1, description + iif(found, " found"," not found"), Query(MenuBorderAttr))
			attr = Set(Attr, Query(MenuTextAttr))
			ClrScr()
			VHomeCursor()
			WriteLine("Search for: ",search)
			WriteLine("Options:    ",options)
			Write	 ("Tag:        ",tag)

			VGotoXY(5, 4)
			PutHelpLine("{Enter}-Single Step  {C}-Continuous    {Escape}-Abort")

			GotoXY(x - 10, y - y1)

			loop
				case GetKey()
					when <Enter>
						break
					when <Escape>
						abort = TRUE
						break
					when <C>, <Shift C>
						dbg_enabled = FALSE
						break
				endcase
			endloop

			Set(Attr, attr)
			PopWinClose()
		endif
	endif

	return (found)
end

integer proc LineColFixup(string tag, integer n)
	return (iif(val(tag) == -1, n, val(GetMarkedText())))
end


integer proc mSaveFile()
	string fn[80] = CurrFileName()

	if AskFilename("New name for '"+CurrFileName()+"'", fn, _WRITE_ACCESS_)
		return (SaveAs(fn))
	endif
	return (FALSE)
end


menu ReloadMenu()
	"&Abandon Changes and Reload"
	"&Save Changes and Reload"
	"&Ignore Reload"
	"&Cancel Macro"
end

integer proc _InsertFile(string fn)
	integer level, success
	level = Set(MsgLevel, _NONE_)
	success = InsertFile(fn)
	Set(MsgLevel, level)
	return (success)
end

integer proc _EditFile(string fn)
	integer ok = FALSE, msg_level

	msg_level = Set(MsgLevel, _NONE_)
	if _FileExists(fn)	 // This is not the best fix but it should
						 // help reduce the possibility that EditFile()
						 // will pulling up a prompt on error
		ok = EditFile(fn)
	endif
	Set(MsgLevel, msg_level)
	return (ok)
end

integer proc LoadFile(string fn, integer force_reload)

	if _EditFile(fn)
		if FileChanged()
			case ReloadMenu(fn + " has changed")
				when 1
					AbandonFile()
				when 2
					if mSaveFile()
						AbandonFile()
					else
						return (FALSE)
					endif
				when 3
					// do nothing
				when 4
					return (FALSE)
			endcase
		elseif force_reload
			AbandonFile()
		else
			return (TRUE)
		endif
		if _EditFile(fn)
			return (TRUE)
		endif
	endif
	return (Warn("Cannot load file '",fn,"'"))
end

integer proc MarkErrors()
	integer id, success
	integer line, col, work, n
	string fn[80], curr_fn[80], s[250]

	// Clear error buffer
	EmptyBuffer(err_id)

	num_errors =  0
	success = TRUE
	errors_in_source = FALSE

	curr_fn = CurrFileName()
	id = GetBufferId()
	PushBlock()

	if trim(fn_tag) == ''   // errors in source!
		work = id
		errors_in_source = TRUE
		success = LoadFile(curr_fn, TRUE)
		if success and dbg_enabled
			DbgMsg(format("Checking errors in '",curr_fn,"'"))
		endif
	else
		work = work_id
		GotoBufferId(work_id)
		EmptyBuffer()
		success = _InsertFile(full_output_fn)
		if success and dbg_enabled
			DbgMsg(format("Checking errors in '",full_output_fn,"'"))
		endif
	endif

	if not dbg_enabled
		DeleteOutputFile()	// for now, always delete error output file
	endif

	if success and NumLines()
		BegFile()
		Msg("Checking for errors")
		abort = FALSE
		if Search("Error", err_ss, err_opts, '')
			repeat
				PushPosition()
				Search("Filename", fn_ss,  fn_opts,  fn_tag )
				fn = GetMarkedText()
				if fn == '' or trim(fn_tag) == ''
					fn = curr_fn
				endif
				PopPosition()

				PushPosition()
				Search("Line number", ln_ss,  ln_opts,  ln_tag )
				line = LineColFixup(ln_tag, CurrLine())
				PopPosition()

				PushPosition()
				Search("Column number", col_ss, col_opts, col_tag)
				col = LineColFixup(col_tag, CurrCol())
				PopPosition()

				PushPosition()
				Search("Error message", msg_ss, msg_opts, msg_tag)
				s = GetMarkedText()
				PopPosition()

				if abort
					success = FALSE
					break
				else
					if fn == '' or not LoadFile(fn, FALSE)
						break
					else
						PushPosition()	// in case errors in source file
						GotoLine(line)
						GotoPos(col)	// fix BUG - used to be GotoColumn, which doesn't work for hard tabs
						n = PlaceMark(str(num_errors + 1))
						PopPosition()
						if n == 0
							Warn("Max errors reached... Only first ",num_errors," are marked")
							break
						else
							num_errors = num_errors + 1
							AddLine(s, err_id)
						endif
					endif
					GotoBufferId(work)
				endif
			until not Search("Error",err_ss,err_opts+'+','')

			GotoBufferId(err_id)
			FileChanged(FALSE)
		endif
	endif

	PopBlock()
	GotoBufferId(id)
	return (success)
end

proc SetupErrorWindow()
	integer n = WindowId()

	if not GotoWindow(2) or Query(WindowX1) > 2
		GotoWindow(n)
		OneWindow()
		HWindow()
		GotoBufferId(err_id)
		ResizeWindow(_UP_, Min(NumLines(), Query(ScreenRows)/5) -
				Query(WindowRows))
	endif

	// make sure the error file is in window #2
	GotoBufferId(err_id)
end

string macro_fn[128]
string burnin_fn[128]
integer fatal_errors
integer is_macro_file
integer loadable_macro
integer first_time

integer proc DisplayError()
	integer attr, n, tmp
	integer win1_x1, win1_y1, win1_len
	integer win2_x1, win2_y1, win2_len

	n = WindowId()

	// get error number and message
	GotoWindow(2)

	BegLine()
	// avoid showing <*** End of File ***> if possible
	tmp = CurrLine() - NumLines() + Query(WindowRows)
	if CurrRow() < tmp
		ScrollToRow(tmp)
	endif

	if err_no <> CurrLine() or err_row <> CurrRow() or CurrCol() <> err_col
		err_no	= CurrLine()
		err_row = CurrRow()
		err_col = CurrCol()
		err_msg = GetText(1,sizeof(err_msg))

		win2_x1	 = Query(WindowX1)
		win2_y1	 = Query(WindowY1) + CurrRow() - 1
		win2_len = Query(WindowCols)

		// position at proper location in editing window
		GotoWindow(1)
		GotoMark(str(err_no))
		ScrollToCenter()

		// simple hack for now to set the update flag for this file.
		// Basically, toggle the display mode to hex and back to
		// its original setting
		DisplayMode(DisplayMode(_DISPLAY_HEX_))

		win1_x1	 = Query(WindowX1)
		win1_y1	 = Query(WindowY1) + CurrRow() - 1
		win1_len = Query(WindowCols)

		// restore window and update display with appropriate changes
		GotoWindow(n)
		UpdateDisplay(_WINDOW_REFRESH_)

		#ifdef COLOR_ERROR_WINDOW
		// highlight cursor line in window 1
		VGotoXY(win1_x1, win1_y1)
		PutAttr(HiLiteErrorAttr, win1_len)

		// highlight cursor line in window 2
		VGotoXY(win2_x1, win2_y1)
		PutAttr(HiLiteErrorAttr, win2_len)
		#else
		// highlight cursor line in window 1
		VGotoXY(win1_x1, win1_y1)
		PutAttr(Query(MsgAttr), win1_len)

		// highlight cursor line in window 2
		VGotoXY(win2_x1, win2_y1)
		PutAttr(Query(MsgAttr), win2_len)
		#endif

		// see if we're in or going to window #2
		if n == 2
			attr = Query(Attr)
			if loadable_macro and first_time
				UpdateDisplay(_STATUSLINE_REFRESH_)		// clear message
				first_time = FALSE
				if PopWinOpen(17,6,63,17,2,"",Query(MenuBorderAttr))
					Set(Attr, Query(MenuTextAttr))
					ClrScr()
					WriteLine("Macro compiled with only warnings and notes.")
					Write("That is, no ")
					Set(Attr, Query(MenuTextLtrAttr))
					Write	 ("fatal")
					Set(Attr, Query(MenuTextAttr))
					Writeline(" errors were found.")
					WriteLine("")
					WriteLine("If, upon inspection of the given warnings, it")
					WriteLine("is determined that the macro will perform")
					WriteLine("properly in spite of these warnings, you may")
					WriteLine("load and/or execute the macro by pressing")
					Set(Attr, Query(MenuTextLtrAttr))
					Write	 ("<Ctrl Enter>")
					Set(Attr, Query(MenuTextAttr))
					WriteLine(" while in the Error window.")
					WriteLine("")
					mAlarm()
					Write("         Press any key to continue")
					GetKey()
					PopWinClose()
					Set(Attr, attr)
				endif
			endif
			Set(Attr, Query(CurrWinBorderAttr))
			VGotoXY(Query(WindowX1) + 10, Query(WindowY1) - 1)
			PutStr("<Enter> to select, Cursor keys to move, or <F1> for Help")
			Set(Attr, attr)
		endif
		return (TRUE)
	endif

	GotoWindow(n)
	return (FALSE)
end

constant NO_MSG			= 0x00,
		 NO_PREV_ERR	= 0x01,
		 NO_MORE_ERR	= 0x02

proc LeftBtn()
	integer cursorattr, cursorinblockattr, blockattr

	case MouseHotSpot()
		when _NONE_			,
			 _MOUSE_ZOOM_	,
			 _MOUSE_VWINDOW_,
			 _MOUSE_HWINDOW_

		when _MOUSE_CLOSE_
			 ProcessHotSpot()
			 EndProcess(FALSE)

		when _MOUSE_MARKING_
			if MouseWindowId() == 2
				goto process_mouse
			elseif GotoWindow(MouseWindowId())
				EndProcess(FALSE)
			endif

		otherwise
			process_mouse:

			PushBlock()
			cursorattr		  = Set(CursorAttr,			Query(MsgAttr))
			cursorinblockattr = Set(CursorInBlockAttr,	Query(MsgAttr))
			blockattr		  = Set(BlockAttr,			Query(TextAttr))
			ProcessHotSpot()
			Set(CursorAttr			, cursorattr)
			Set(CursorInBlockAttr	, cursorinblockattr)
			Set(BlockAttr			, blockattr)
			PopBlock()
			DisplayError()
	endcase
end

proc Move(integer success, integer flag)
	if not DisplayError() and not success
		case flag
			when NO_PREV_ERR
				mAlarm()
				Message("No previous errors")
			when NO_MORE_ERR
				mAlarm()
				Message("No more errors")
		endcase
	endif
end

KeyDef ErrorKeys
	<PREV_ERROR_KEY>	Move(Up()		, NO_PREV_ERR)
	<CursorUp>			Move(Up()		, NO_PREV_ERR)

	<NEXT_ERROR_KEY>	Move(Down()		, NO_MORE_ERR)
	<CursorDown>		Move(Down()		, NO_MORE_ERR)

	<Home>				Move(Begfile()	, NO_MSG	 )
	<Ctrl PgUp>			Move(Begfile()	, NO_MSG	 )

	<End>				Move(Endfile()	, NO_MSG	 )
	<Ctrl PgDn>			Move(Endfile()	, NO_MSG	 )

	<PgUp>				Move(PageUp()	, NO_PREV_ERR)
	<PgDn>				Move(PageDown() , NO_MORE_ERR)

	<F1>				Help("Compiler Key Assignments")

	<LeftBtn>			LeftBtn()
	<RightBtn>			EndProcess(FALSE)

	#ifdef EXTRA_KEYS
	<CursorLeft>		RollLeft()
	<CursorRight>		RollRight()

	<Alt [>				PrevWindow() EndProcess(4)
	<Alt ]>				NextWindow() EndProcess(4)
	<Ctrl q>			CloseWindow() EndProcess(3)
	<Ctrl F4>			EndProcess(3)
	#endif

	<Enter>				EndProcess(TRUE)
	<Ctrl Enter>		if loadable_macro
							EndProcess(2)
						endif
	<Escape>			EndProcess(FALSE)
end

forward proc ProcessErrorWindow()

// Determine when the user has switched to the Error window.
proc AfterEditingCommand()
	if WindowId() == 2 and GetBufferId() == err_id
		ProcessErrorWindow()
	endif
end
proc CloseErrorWindow()
	integer n = WindowId(), id = GetBufferId()

	if GotoWindow(2) and GetBufferId() == err_id
		CloseWindow()
	endif

	GotoWindow(n)
	GotoBufferId(id)
	ExecHook(_ON_CHANGING_FILES_)
	UpdateDisplay(_WINDOW_REFRESH_)
end

proc LoadCurrMacro(integer execute_it)
	if LoadMacro(macro_fn) and execute_it and isMacroLoaded(macro_fn)
		ExecMacro(macro_fn)
	endif
end

menu ExecLoadMenu()
	"&Execute Macro"  ,   LoadCurrMacro(TRUE)
	"&Load Macro"     ,   LoadCurrMacro(FALSE)
	"&Debug Macro"    ,   ExecMacro("debug "+CurrFilename())
	"&Cancel"
end

proc ProcessErrorWindow()
	integer n, enhanced_keys

	err_col = -1	// force update
	DisplayError()
	if Enable(ErrorKeys, _EXCLUSIVE_)
		UnHook(AfterEditingCommand)

		enhanced_keys = Set(EquateEnhancedKbd, TRUE)
		n = Process()
		Set(EquateEnhancedKbd, enhanced_keys)
		Disable(ErrorKeys)

		if n <> 4
			GotoWindow(1)
		endif
		if n == 2 and loadable_macro
			CloseErrorWindow()
			if macro_debugging
				ExecMacro(format("Debug ",compile_fn))
			else
				ExecLoadMenu("No fatal errors...")
			endif
		elseif n == 3
			CloseErrorWindow()
		else
			DisplayError()
			Message(err_msg)
			Hook(_AFTER_COMMAND_,AfterEditingCommand)
		endif

	endif
end

integer proc isMacroFile()
	integer id

	macro_fn = ''
	burnin_fn = ''
	fatal_errors = 0
	loadable_macro = 0

	case SplitPath(CurrFileName(), _EXT_)
		when ".s",".ui",".cfg",".si"
			PushBlock()
			id = GotoBufferId(work_id)
			BegFile()
			if lFind("SAL Compiler","^c")
				if lFind("^Writing output to file '{.*}'$","xg")
					MarkFoundText(1)
					macro_fn = GetMarkedText()
					macro_fn = SplitPath(macro_fn, _DRIVE_ | _NAME_)
				endif

				if lFind("^Burning configuration into file '{.*}'$","xg")
					MarkFoundText(1)
					burnin_fn = GetMarkedText()
				endif

				fatal_errors = lFind("^Error ","xg")
			endif
			GotoBufferId(id)
			PopBlock()
			loadable_macro = fatal_errors == 0 and burnin_fn == ''
			first_time = TRUE
			return (TRUE)
	endcase
	return (FALSE)
end

proc ProcessErrors()
	integer attr

	is_macro_file = isMacroFile()

	if num_errors > 0
		SetupErrorWindow()
		BegFile()
	else
		CloseErrorWindow()
	endif

	if is_macro_file and fatal_errors == 0 and burnin_fn <> ''
		UpdateDisplay()
		if PopWinOpen(13,6,67,16,2,"",Query(MenuBorderAttr))
			attr = Set(Attr, Query(MenuTextAttr))
			ClrScr()
			WriteLine("")
			WriteLine("New User-Interface has been burned into the editor")
			Write("'")
			Set(Attr, Query(MenuTextLtrAttr))
			Write(burnin_fn)
			Set(Attr, Query(MenuTextAttr))
			WriteLine("'")
			WriteLine("")
			WriteLine("The new configuration will not take effect until")
			WriteLine("the editor is reloaded")
			WriteLine("")
			mAlarm()
			Write("              Press any key to continue")
			GetKey()
			PopWinClose()
			Set(Attr, attr)
			loadable_macro = FALSE
		endif
	endif

	if num_errors > 0
		ProcessErrorWindow()
	elseif is_macro_file and loadable_macro
		if not macro_debugging
			ExecLoadMenu("Compilation Successful... No Errors.")
		endif
	endif
end

proc ExecCompiler(string fn, string ext, integer invoke_list)

	compile_fn = ExpandPath(fn)

	if GetCompiler(ext, invoke_list) and TranslateCommands(compile_fn)
		if ExecuteCommands(compile_fn)
			if MarkErrors()
				ProcessErrors()
			endif
			EmptyBuffer(work_id)
		endif
	endif
end

proc NextPrevErr(integer next)
	integer moved, line

	SetupErrorWindow()
	moved = iif(next, Down(), Up())
	GotoWindow(1)

	if num_errors == 1
		err_col = -1	// force update
		line = CurrLine()
		DisplayError()
		if CurrLine() <> line
			return()
		endif
	endif
	Move(moved, iif(next, NO_MORE_ERR, NO_PREV_ERR))
end

public proc PrevErr()
	NextPrevErr(FALSE)
end

public proc NextErr()
	NextPrevErr(TRUE)
end

proc PrevErrKey()
	iif(num_errors, PrevErr(), ChainCmd())
end

proc NextErrKey()
	iif(num_errors, NextErr(), ChainCmd())
end

/*
public proc CompileExt()
	string ext[4] = ''

	if Query(MacroCmdLine) == "" and Ask("Specify extension to compile", ext)
		Set(MacroCmdLine, ext)
	endif
	if Query(MacroCmdLine) <> ""
		ext = GetToken(Query(MacroCmdLine),' ',1)
		Set(MacroCmdLine, SubStr(Query(MacroCmdLine),Length(ext),255))
		ExecCompiler(ext, FALSE)
	endif
end
*/

string proc mCurrExt()
	string ext[4] = CurrExt()
	if ext[1] <> '.'
		ext = '.' + ext
	endif
	#ifdef INHOUSE
	if ext == ".si" and SubStr(SplitPath(CurrFileName(),_NAME_),1,4) == "bind"
		ext = ".bnd"
	endif
	#endif
	return (ext)
end

public proc CompileCurrentFile()
	ExecCompiler(CurrFileName(), mCurrExt(), FALSE)
end

string proc StripToken(var string s, string deli, integer relax)
	integer len,p
	string token[255]

	len = length(deli)

	if relax
		p = 1
		while s[p:len] == deli
			p = p + len
		endwhile
		s = s[p:sizeof(s)]
	endif

	p = pos(deli, s)
	if p == 0
		p = length(s) + 1
	endif
	token = s[1:p - 1]
	s = s[p + len:sizeof(s)]

	return (token)
end

public proc DebugCompilerSetup()
	dbg_enabled = TRUE
	ExecCompiler(CurrFileName(), mCurrExt(), TRUE)
	dbg_enabled = FALSE
end

proc SwitchWindow()
	if WindowId() == 2
		GotoWindow(1)
	else
		SetupErrorWIndow()
	endif
end

integer proc InsertCompileData(string fn, integer error)
	integer success

	PushBlock()
	success = _InsertFile(fn)
	PopBlock()
	BegFile()
	if GetText(1,CurrLineLen()) <> EyeCatcher
		success = FALSE
		if error
			Warn("Invalid data file '",fn,"'")
		endif
	endif
	if lFind("^DBG={.*}$","xg")
		dbg_ext = GetFoundText(1)
	endif
	return (success)
end


integer proc LoadPrevDataFile(var string prev_data_fn)
	integer id, ok

	PushPosition()
	if CreateTempBuffer()
		id = GetBufferId()
		ok = InsertCompileData(prev_data_fn, FALSE)
		if not ok
			prev_data_fn = ExpandPath(prev_data_fn)
			if SplitPath(prev_data_fn, _NAME_) == "*"
				prev_data_fn = SplitPath(prev_data_fn, _DRIVE_ | _PATH_) + SplitPath(data_fn,_NAME_) + SplitPath(prev_data_fn, _EXT_)
			endif
			if SplitPath(prev_data_fn, _EXT_) in ".*", ""
				prev_data_fn = SplitPath(prev_data_fn, _DRIVE_ | _PATH_ | _NAME_) + SplitPath(data_fn, _EXT_)
			endif
			ok = InsertCompileData(prev_data_fn, FALSE)
		endif

		if ok
			KillPosition()
		else
			PopPosition()
			AbandonFile(id)
			id = 0
		endif
	else
		PopPosition()
	endif
	return (id)
end

integer proc isSetupSame(integer id)
	integer n
	string data[255], merge[255]

	for n = 1 to 20
		GotoBufferId(data_id)
		data  = GetText(1,sizeof(data))
		Down()
		GotoBufferId(id)
		merge = GetText(1,sizeof(merge))
		Down()
		if data <> merge
			return (FALSE)
		endif
	endfor
	return (TRUE)
end



proc RemoveDuplicateSetups(integer merge_id)
	integer data_line, merge_line

	GotoBufferId(data_id)
	BegFile()
	if lFind('',"^")
		repeat
			data_line = CurrLine()
			Down()
			Message("Checking: ",GetText(1,132))
			Up()
			GotoBufferId(merge_id)
			BegFile()
			while lRepeatFind()
				merge_line = CurrLine()
				GotoBufferId(data_id)
				GotoLine(data_line)
				if isSetupSame(merge_id)
					GotoLine(merge_line)
					KillLine(20)
					Up()
				endif
			endwhile
			GotoBufferId(data_id)
		until not lRepeatFind()
	endif
	GotoBufferId(merge_id)
end

proc MergeDataFile()
	integer attr, id, merge_id
	string path[80] = '', prev_data_fn[128]

	id = GetBufferId()

	if PopWinOpen(8, 4, 72, 9, 1, "Merge compiler data", Query(MenuBorderAttr))
		attr = Set(Attr, Query(MenuTextAttr))
		ClrScr()
		WriteLine("To merge compiler setups from a previous version of TSE,")
		WriteLine("Enter the path to the previous version of the compile macro")
		WriteLine("")
		if Read(path)
			prev_data_fn = path
			merge_id = LoadPrevDataFile(prev_data_fn)
			if merge_id
				RemoveDuplicateSetups(merge_id)
				BegFile()
				if lFind('',"^g")
					PushBlock()
					UnMarkBlock()
					MarkLine()
					EndFile()
					GotoBufferId(data_id)
					EndFile()
					AddLine()
					CopyBlock()
					SaveCompileData()
					Message("Compile data file updated")
				else
					Message("Compile data already up-to-date")
				endif
				AbandonFile(merge_id)
			else
				Warn("Cannot locate 'compile.dat' in '",path,"'")
			endif
		endif
		PopWinClose()
		Set(Attr, attr)
	endif
	GotoBufferId(id)

end

proc SetDbgExt()
	if Read(dbg_ext)
		PushPosition()
		if GotoBufferId(data_id)
			if not lReplace("{^DBG=}{.*}$","\1"+dbg_ext,"xg1")
				BegFile()
				AddLine("DBG="+dbg_ext)
			endif
			SaveCompileData()
		endif
		PopPosition()
	endif
end

menu AdvancedSetupMenu()
	"TSE Debugger E&xtension" [dbg_ext:4] ,SetDbgExt()    ,CloseAfter ,"Specify extension to use for compiling TSE macros for macro_debugging"
	"&Merge Data File"                    ,MergeDataFile(),CloseBefore,"Merge compiler data file with previous data file"
end

menu TheCompileMenu()
	title = "Compile Menu"

	"&Compile Current File" ,CompileCurrentFile()         ,CloseAllBefore
	"Compile from &List"    ,ExecCompiler(CurrFileName(), mCurrExt(), TRUE),CloseAllBefore
	"&Previous Error"       ,PrevErr()                    ,CloseBefore
	"&Next Error"           ,NextErr()                    ,CloseBefore
	"&Switch Window"        ,SwitchWindow()               ,CloseBefore
	"Close Error &Window"   ,CloseErrorWindow()           ,CloseAllBefore
	"&Help on Keys"         ,Help("Compiler Key Assignments"), DontClose
	""                      ,                             ,Divide
	"&Advanced Setup"       ,AdvancedSetupMenu()          ,DontClose
	"&Debug Compiler Setup" ,DebugCompilerSetup()         ,CloseAllBefore
end

public proc CompileMenu()
	TheCompileMenu()
end


integer proc SetupCompileFiles()
	integer id, ok

	ok = FALSE

	full_data_fn = SplitPath(CurrMacroFileName(), _DRIVE_ | _PATH_) + data_fn
	if not _FileExists(full_data_fn)
		full_data_fn = SearchPath(data_fn, Query(TSEPath), "mac")
	endif
	if full_data_fn == ""
		new_file = TRUE
		full_data_fn = data_fn
	endif

	id = GetBufferId()

	work_id	 = CreateTempBuffer()
	err_id	 = CreateTempBuffer()
	batch_id = CreateTempBuffer()
	data_id	 = CreateTempBuffer()

	if data_id and not new_file
		ok = InsertCompileData(full_data_fn, TRUE)
		dbg_ext = iif(lFind("^DBG={.*}$","xgi"),GetFoundText(1),".dbg")
		BegFile()
	endif
	EndFile()
	if CurrLineLen()
		AddLine()	// make sure there's at least 1 blank line at end
	endif

	FileChanged(FALSE)
	GotoBufferId(id)
	return (ok)
end


string cmdline[255]

proc Main()
	integer extension_specified

	string ext[4]
	string fn[80], s[80]

	extension_specified = FALSE
	num_errors = -1

	cmdline = Query(MacroCmdLine)
	if trim(cmdline) == ''
		cmdline = CurrFileName()
		if not AskFilename("File to compile", cmdline, 0, GetFreeHistory("Compile:cmdline"))
			return ()
		endif
	endif

	if cmdline == '-m'
		TheCompileMenu()
		return ()
	endif

	if trim(cmdline) <> ''
		loop
			s = lower(StripToken(cmdline,' ',TRUE))
			if s == '-d'
				extension_specified = TRUE
				macro_debugging = TRUE
				ext = dbg_ext
			elseif s[1:2] == "-x"
				extension_specified = TRUE
				ext = s[3:4]
				if ext[1] <> '.'
					ext = '.' + ext
				endif
			else
				fn = s
				break
			endif
		endloop
		if not extension_specified
			ext = SplitPath(fn,_EXT_)
		endif
		ExecCompiler(fn, ext, FALSE)
	endif
	Set(MacroCmdLine, str(num_errors))
	macro_debugging = FALSE
end

proc DefineKey(string name, string key)
	SetGlobalStr("Compile->" + name, iif(key <> '',key, "Undefined"))
end

#ifdef COLOR_ERROR_WINDOW
integer fInUpdate = FALSE
integer ta, ca
proc BeforeColors()
	if WindowId() == 2 and GetBufferId() == err_id
		// color the error window with pretty colors
		fInUpdate = TRUE
		ta = Set(TextAttr, ErrorAttr)
		ca = Set(CursorAttr, HiLiteErrorAttr)
	endif
end

proc AfterColors()
	if fInUpdate
		fInUpdate = FALSE
		Set(TextAttr, ta)
		Set(CursorAttr, ca)
	endif
end
#endif

proc WhenLoaded()
	DefineKey("PrevErrorKey",    KeyName(<PREV_ERROR_KEY>))
	DefineKey("NextErrorKey",    KeyName(<NEXT_ERROR_KEY>))
	DefineKey("SwitchWindowKey", KeyName(<SWITCH_WINDOW_KEY>))
	DefineKey("CompileMenuKey",  KeyName(<COMPILE_MENU_KEY>))
	DefineKey("CompileFileKey",  KeyName(<COMPILE_FILE_KEY>))
	LocalHelp(TRUE)
	if not SetupCompileFiles()
		PurgeMacro(CurrMacroFileName())
	endif

	#ifdef COLOR_ERROR_WINDOW
	Hook(_BEFORE_UPDATE_DISPLAY_, BeforeColors)
	Hook(_AFTER_UPDATE_DISPLAY_, AfterColors)
	#endif
end

proc WhenPurged()
	DefineKey("PrevErrorKey",    "")
	DefineKey("NextErrorKey",    "")
	DefineKey("SwitchWindowKey", "")
	DefineKey("CompileMenuKey",  "")
	DefineKey("CompileFileKey",  "")

	AbandonFile(batch_id)
	AbandonFile(work_id)
	AbandonFile(data_id)
	AbandonFile(err_id)
end

// key assignments

<COMPILE_MENU_KEY>		CompileMenu()
<COMPILE_FILE_KEY>		CompileCurrentFile()
<NEXT_ERROR_KEY>		NextErrKey()
<PREV_ERROR_KEY>		PrevErrKey()
<SWITCH_WINDOW_KEY>		SwitchWindow()
