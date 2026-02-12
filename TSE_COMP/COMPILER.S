//-----------------------------------------------------------------------//
//-----------------------------------------------------------------------//
//-----------------------------------------------------------------------//
//
//  FILE: COMPILER.S      Copyright 1993,1994 Binary Systems, Inc.
//                        414 West Avenue, East Rochester, NY 14445
//                        CompuServe ID: 70144,2650
//                        All rights reserved
//  We make stuff work.
//  Last Modified: 03/04/94 02:43 pm H. Johnson
//
//
//  DESCRIPTION:
//
//  Complete replacement for SEMWARE mCompile() macro.  User reconfigurable
//  at run-time, provides capability to create/save project based compiler
//  configurations (SAVE routines are external to this file, NOT required for
//  operation)...
//
//  EXPORTED FUNCTIONS:   -->> string proc mSubstitute(string UserString)
//                        -->> proc mCompileCurrentFile(integer COMPILE)
//                        -->> proc mNextERROR(integer option)
//                        -->> menu COMPILESetupMenu()
//                        -->> menu MAKESetupMenu()
//  NARRATIVE:
//
// This package implements support for a variety of MAKE/COMPILE utilities.
// I have tried lay the code out for ease of digestion, modification, and
// reuse.  Hopefully, the user will be able to simply insert the specifics
// for his/her compiler and make utilities, and everything will go happily
// forward from there.
//
// Our in house configuration of TSE includes the capability to save and
// restore compiler command strings to an .INI file.  This allows us to
// make custom MAKE or COMPILE environments for each particular project,
// without having to burn E.EXE each time.
//
// Substitute a call to the function mCompileCurrentFile() for the SEMWARE
// supplied mCompile() function on the desired key in the .KEY file.  The '.S'
// compiler (SC.EXE) is supported identically to the original SEMWARE macro.
//
//--------------------------------------------------------------------------//
//  ** EXPORTED FUNCTIONS: **
//--------------------------------------------------------------------------//
//
// -->> string proc mSubstitute(string UserString)
//
// Preprocessor/substitution routine for user defined command
// strings.   A command string such as 'MAKE @%PATH%%FILE%%EXT%'
// expanded as follows:
//
//   syntax:   MyStringVariable = mSubstitute(MyStringVariable)
//
//   %DRIVE%   ==  Current file's drive letter
//   %PATH%    ==  Current file's full path w/o drive includes trailing backslash
//   %FILE%    ==  Current filename minus extension
//   %EXT%     ==  Current file's extension plus leading period
//
//
// -->> proc mCompileCurrentFile(integer COMPILE)
//
//   parameter COMPILE - TRUE  == run COMPILE for current file extension
//                       FALSE == run MAKE for current file extension
//
//   COMPILE or MAKE current file and and go to first error if any.  If
//   a TSE macro is what is being compiled, call the macro load menu
//   if compile is successful.
//
//   Assign mCompileCurrentFile(TRUE) to your COMPILE current file key
//   Assign mCompileCurrentFile(FALSE) to your MAKE key
//
//
// -->> proc mNextERROR(integer option)
//
// option may be one of the following...
//          1 == search FORWARD for next error
//          2 == search BACKWARD for previous error
//          3 == called internally by mCompileCurrentFile()
//
//   Assign mNextERROR(1) to your 'next error' key
//   Assign mNextERROR(2) to your 'previous error' key
//   mNextERROR(3) should not be assigned...
//
//
// -->> menu COMPILESetupMenu()
// -->> menu MAKESetupMenu()
//
//   These menus allow you to reconfigure your COMPILE and MAKE setups
//   on the fly.  Assign them to an appropriate menu in the main '.S' file.
//
//-----------------------------------------------------------------------//
//
//  Revision History...
//
// 03/04/94 12:05 pm H. Johnson
// Implement as a complete replacement for SEMWARE mCompile...
//
// 03/04/94 09:28 am H. Johnson
// Revised to include COMPILER and MAKE menus, clean up modules
// for ease of use by someone wanting to plug this in somewhere...
//
// 11/24/93 10:58 am H. Johnson
// User defined compiler program/make options...
//
//-----------------------------------------------------------------------//
forward string proc currExt()       //  external routines in TSE main macro
forward menu LoadExec()             //  file supplied by SEMWARE...
//
// The following forwards are all defined in this file.  I did this to enhance
// readability as you scan down through...
//
forward proc mNextERROR(integer option)
forward string proc GetTextUntil(string stopchar)
forward proc GetString(string thePrompt,var string theString,var integer history_number)
forward string proc mSubstitute(string UserString)
//
// Substitute a filename of your choosing into the following 'error_file'
// variable.  To allow MAKEing to return errors, be sure to set your error
// output in the MAKEFILE to the same name defined here, as:
//
string error_file[12]  =  "errors.lst"            // GLOBAL...
//
//  (Example from a .MAK file)
//
//  myfile.prg : myfile.obj
//      clipper  myfile.prg -m -n -b  > errors.lst
//
//  myfile.exe : myfile.obj
//      blinker fi myfile lib clipper,extend > errors.lst
//
// Assign whatever default MAKE utilities or accessories you want
// into THESE strings, thusly.  You could modify the supported compilers
// and extensions throughout...
//                                                      //  ** MAKE **
string UserVar1[60]    =  'RMAKE %FILE%'                //  extension = .prg
string UserVar2[60]    =  'TPC -b %FILE%'               //     ""     = .pas
string UserVar3[60]    =  'MAKE %FILE%'                 //     ""     = .c,.cpp
string UserVar4[60]    =  'MAKE %FILE%'                 //     ""     = .asm
string UserVar5[60]    =  'BLD %FILE%'                  //     ""     = .bld
//
// assign whatever default COMPILER commands are required
// into THESE strings, also thusly...
//                                                      //   ** COMPILE **
string UserVar6[60]    =  'CLIPPER %FILE% -m -n -b'     //  extension = .prg
string UserVar7[60]    =  'TPC -c %FILE%'               //     ""     = .pas
string UserVar8[60]    =  'BCC -c %FILE%'               //     ""     = .c,.cpp
string UserVar9[60]    =  'TASM %FILE%'                 //     ""     = .asm
string UserVar0[60]    =  'BLD %FILE%'                  //     ""     = .bld

// user defined history handles

integer UserHist1     = 0                     // make up history refer-
integer UserHist2     = 0                     // ences for each string
integer UserHist3     = 0
integer UserHist4     = 0
integer UserHist5     = 0
integer UserHist6     = 0
integer UserHist7     = 0
integer UserHist8     = 0
integer UserHist9     = 0
integer UserHist0     = 0

//  various GLOBALS

string supported_extensions[]    = '.s/.prg/.pas/.c/.cpp/.asm/.bld'
string last_file_ext_compiled[4] = ''   // pickup for most recent extension
string last_search_ext_found[4]  = ''   // pickup for '.INC' type files
                                        // found during mNextERROR session...

//--------------------------------------------------------------------------//
//--------------------------------------------------------------------------//
// Begin subroutines...
//--------------------------------------------------------------------------//
//--------------------------------------------------------------------------//
//  11/23/93 10:07 am H. Johnson
//  Macro to compile the file currently addressed by the editor.
//  Assumes the required program(s) are somewhere in the path.  Assign to
//  key(s) in the .KEY file.
//--------------------------------------------------------------------------//
proc mCompileCurrentFile(integer COMPILE)   // TRUE or FALSE, COMPILE or MAKE
string CommandLine[150]
integer command
   //
   // Force a single window
   //
   OneWindow()
   PlaceMark('Z')
   if isChanged()
      if not SaveFile()               //  abort if file is read-only, etc...
         return()
      endif
   endif
   //
   // Remove the error file if we're already editing it
   //
   AbandonFile(GetBufferId(ExpandPath(error_file)))
   EraseDiskFile(error_file)
   //
   //  Check out what kind of file we are editing,
   //  put in any appropriate compiler command lines...
   //
   command     = _DONT_PROMPT_       // display handling default...
   //
   case CurrExt()
   when '.s'
      command = _DONT_CLEAR_
      CommandLine = "sc " + CurrFileName() + " > " + error_file
   when '.prg'
      CommandLine =  iif(COMPILE,
                         mSubstitute(UserVar6) + " > " + error_file,
                         mSubstitute(UserVar1)
                        )
   when '.pas'
      CommandLine =  iif(COMPILE,
                         mSubstitute(UserVar7) + " > " + error_file,
                         mSubstitute(UserVar2)
                        )
   when '.c','.cpp'
      CommandLine =  iif(COMPILE,
                         mSubstitute(UserVar8) + " > " + error_file,
                         mSubstitute(UserVar3)
                        )
   when '.asm'
      CommandLine =  iif(COMPILE,
                         mSubstitute(UserVar9) + " > " + error_file,
                         mSubstitute(UserVar4)
                        )
   when '.bld'
      command     = _DONT_CLEAR_
      CommandLine =  iif(COMPILE,
                         mSubstitute(UserVar0) + " > " + error_file,
                         mSubstitute(UserVar5)
                        )
   otherwise
      Warn("Extension not supported")
      return()
   endcase
   //
   Dos(CommandLine,command)         //  run the compiler
   mNextError(3)                    //  find the first error, if any...
   EraseDiskFile(error_file)        //  get rid of temp file, already in buffer
end
//--------------------------------------------------------------------------//
// 03/04/94 10:56 am H. Johnson
// Generic "finds" for many compiler error messages, add your own. Used
// by mNextERROR()
//
// _find  =   inital find for errors / error strings...
// _start =   character(s) which start the bracketing of line information
// _comma =   delimiter for line AND column of error if both present
// _stop  =   character(s) which end the bracketing of line information
//
//  Here is what we are doing in ENGLISH:
//
//   look at the error list
//   locate next/previous error message by searching with _FIND
//   if a _START character is in the message, line number of error is next
//   if a _COMMA is in the message, the column number of error is next
//   if a _STOP character is in the message, we have hit the end of information
//
proc set_search_parms(string ext, var string _find, var string _comma,
                  var string _start, var string _stop)
//
string NONE[1] = ''
//
case ext
when '.prg'                                    // CLIPPER 5.1 / 5.2
   _find  = "{Error}|{Warning}|{Fatal} \c"
   _comma = NONE
   _start = "("
   _stop  = ")"
when '.s'                                      // SemWare SAL...
   _find  = "^{Note}|{Error}|{Warning} #[0-9]# #\c"
   _comma = ','
   _start = "("
   _stop  = ")"
when '.bld'                                    // BUILDER Install Compiler...
   _find = "{^[0-9]#}|{Error}"
   _comma = NONE
   _start = ":"
   _stop  = ":"

otherwise                                      // GENERIC compiler...
   _find  = "{Note}|{Error}|{Warning}|{Fatal} \c"
   _comma = NONE
   _start = "("
   _stop  = ")"

endcase
end
// --------------------------------------------------------------- //
menu MAKESetupMenu() // menu used to assign new values to default MAKE commands
   history           // strings can then be saved and restored...
   x = 48
   Title = "MAKE Setup Strings"
   Width = 20

   "C&LIPPER   - *.prg",GetString("CLIPPER MAKE command:",
                          UserVar1,UserHist1),CloseBefore

   "&Pascal    - *.pas",GetString("PASCAL MAKE command:",
                          UserVar2,UserHist2),CloseBefore

   "&C/C++     - *.c  ",GetString("C/C++ MAKE command:",
                          UserVar3,UserHist3),CloseBefore

   "&Assembler - *.asm",GetString("ASSEMBLER MAKE command:",
                          UserVar4,UserHist4),CloseBefore

   "&Builder   - *.bld",GetString("BUILDER MAKE command:",
                          UserVar5,UserHist5),CloseBefore
end
//---------------------------------------------------------------------------//
menu COMPILESetupMenu() // menu used to assign new values to COMPILE commands
   history              // strings can then be saved and restored...
   x = 48
   Title = "COMPILE Setup Strings"
   Width = 20

   "C&LIPPER   - *.prg",GetString("CLIPPER COMPILE command:",
                          UserVar6,UserHist6),CloseBefore

   "&Pascal    - *.pas",GetString("PASCAL COMPILE command:",
                          UserVar7,UserHist7),CloseBefore

   "&C/C++     - *.c  ",GetString("C/C++ COMPILE command:",
                          UserVar8,UserHist8),CloseBefore

   "&Assembler - *.asm",GetString("ASSEMBLER COMPILE command:",
                          UserVar9,UserHist9),CloseBefore

   "&Builder   - *.bld",GetString("BUILDER COMPILE command:",
                          UserVar0,UserHist0),CloseBefore
end
//--------------------------------------------------------------------------//
//  11/30/93 02:55 pm H. Johnson  - low level string insert/replace...
string proc lStuff(string Target, integer Position,integer Delete,
                   string Insert)
   string work[255]
   work = substr(Target,1,Position-1)
   work = work + Insert
   work = work + substr(Target,Position+Delete,255)
   return(work)
end
//--------------------------------------------------------------------------//
// 11/30/93 03:18 pm H. Johnson   -  substitute for our string macros...
string proc mSubstitute(string UserString)
   string Local[255] = UserString
   //
   Upper(Local)
   if Pos("%DRIVE%",Local)
      Local = lStuff(Local,Pos("%DRIVE%",Local),7,
                       SplitPath(CurrFileName(), _DRIVE_ ))
   endif
   if Pos("%PATH%",Local)
      Local = lStuff(Local,Pos("%PATH%",Local),6,
                       SplitPath(CurrFileName(), _PATH_))
   endif
   if Pos("%FILE%",Local)
      Local = lStuff(Local,Pos("%FILE%",Local),6,
                       SplitPath(CurrFileName(), _NAME_))
   endif
   if Pos("%EXT%",Local)
      Local = lStuff(Local,Pos("%EXT%",Local),5,
                       SplitPath(CurrFileName(), _EXT_))
   endif
   //
   return(Local)
end
//---------------------------------------------------------------------------//
// 12/08/93 12:17 pm H. Johnson
//
integer proc IsAlpha(string char)
   case char
      when 'A'..'Z','a'..'z'
      return(TRUE)
   endcase
   return(FALSE)
end
//---------------------------------------------------------------------------//
// 12/08/93 12:17 pm H. Johnson
//
integer proc IsInFNAmeSet(integer char)
   case Chr(char)
      when 'A'..'Z','a'..'z','_','$','0'..'9'
      return(TRUE)
   endcase
   return(FALSE)
end
//---------------------------------------------------------------------------//
// 12/08/93 09:58 am H. Johnson
// Search out a filespec on a line, a little 'IF - EE'...
//
string proc mFindFileNameOnLine()
string _filename[100] = ''
integer _pos
   //
   IsAlpha(Chr(CurrChar()))
   PushPosition()
   _pos = Pos('\',GetText(1,1008))           // locate possible filespec
   if _pos                                   // find backslash, probably means
      GotoColumn(_pos - 2)                   // a path is present...
   else
      _pos =  Pos('.',GetText(1,1008))       // find a period, hope for an
      if _pos                                // extension. Go backwards until
         GotoColumn(_pos - 1)                // probably have a file name...
         //
         while IsInFNameSet(CurrChar()) and (CurrCol() > 1)
            Left()
         endwhile
         //
         while not IsInFNameSet(CurrChar()) and not (CurrChar()==_BEYOND_EOL_)
            Right()       // assume the name has some valid characters...
         endwhile
         //
      endif
   endif
   //
   if _pos
      //
      _filename = GetTextUntil('.')          // filename portion...
      //                                     // extension portion...
      _pos = 1
      while (CurrChar() <> 32) and (_pos <= 4)
         _filename =  _filename + Chr(CurrChar())
         _pos = _pos + 1
         Right()
      endwhile
      //
      AddHistoryStr(_filename,_EDIT_HISTORY_)
   endif
   PopPosition()
   return(_filename)
end
//---------------------------------------------------------------------------//
// 12/01/93 10:47 am H. Johnson
// Generic find NEXT / PREVIOUS error message in error_file
//
// This subroutine attempts to sort out the filename the error occured in
// as well as the line numbers.  This will hopefully catch errors generated
// in .INC or other associated files, as well as the current file...
//
//                                    // option:
proc mNextERROR(integer option)       // 1==search FORWARD, 2==search BACKWARD,
                                      // 3==called by mCompileCurrentFile()
//
integer   line, col, _x, _ErrBuffNum, _FileBuffNum
string    ext[4] = CurrExt(), _find[100] = '', _start[1] = '', _comma[1] = '',
          _stop[1] = '', _BufferName[65] = '',_CurrentFile[65] = CurrFileName()

   if not Pos(ext,supported_extensions+'/'+last_search_ext_found)
      Warn("Extension not supported")     // determine if we
      return ()                           // can search this file...
   endif
   if not Pos(ext,supported_extensions)   // if the extension is odd,
      ext = last_file_ext_compiled        // set it to pick up the last
   endif                                  // file type we ran compile on...
   //
   //  Go get the search parameters for the current extension. See proc above
   //  SET_SEARCH_PARMS().
   //
   set_search_parms(ext,_find,_comma,_start,_stop)
   //
   OneWindow()
   line = CurrLine()                      // capture original spot...
   col  = CurrCol()
   EditFile(error_file)                   // get error file handle
   _ErrBuffNum = GetBufferId()

   if option==1 and CurrChar()==Asc(_stop)
      Down()                           // we have completed a previous find,
   endif                               // and now are skipping to next error
   BegLine()                           // FORWARD. Reset to start of line...
   //
   // find our keyword AND delimiter(s)...
   //
   if lFind(_find,iif(option==1 or option==3,"ix","ibx"))
          and Pos(_start,GetText(1,1008)) and Pos(_stop,GetText(1,1008))
      //
      // got a hit OK, get buffer name from error line if available...
      //
      if not Pos(ext,'.bld')   // this extension can't use stuff in here...
         //
         _BufferName = mFindFileNameOnLine()   // search for possible filename...
         //
      endif
      last_search_ext_found = SplitPath(_BufferName,_EXT_)
      if Length(_BufferName)
         EditFile(_BufferName)
      else
         PrevFile()
      endif
      //
      HWindow()
      GotoBufferId(_ErrBuffNum)
      ScrollToRow(Query(WindowRows) / 2)
      BegLine()
      //
      // locate start of delimited string...
      //
      if _start == _stop       // not really a delimiter, just an indicator,
                               // DO NOT reset position on line...
      else
         while (CurrChar() <> Asc(_start)) and Right()  // find the delimiter
         endwhile
         if (CurrChar() == Asc(_start))                 // got a hit
            Right()                                     // skip the delimiter...
         endif
      endif
      //
      // get source file line and column info...
      //
      if Length(_comma)                      // line _&_ column number present
         line = Val(GetTextUntil(_comma))
         Right()                             // skip the comma
         col  = Val(GetTextUntil(_stop))
      else
         line = Val(GetTextUntil(_stop))     // column number NOT present
         col  = 1                            // default to column 1
      endif
      //
      // reposition files...
      //
      PrevWindow()                           // errors found, reposition
      GotoLine(line)
      GotoColumn(col)
      ScrollToRow(Query(WindowRows) / 2)
      UpdateDisplay()
      //
   else
      //
      // At this point no error/warning messages found in the error file.
      // If it's empty we either have not yet attempted a compile, or Dos()
      // failed to execute the compiler directive(s)...
      //
      if NumLines() == 0      // error_file is loaded, disk file is not present
         AbandonFile()        // or is empty..
         UpdateDisplay()
         Warn("Error running COMPILER, or errors not available")
         //
      else           //   actions for SUCCESS...
         //
         if ((ext=='.s') and (option==3))   // Successful TSE Macro compile...
            AbandonFile()                   // implemented as in old
            PurgeMacro(_CurrentFile)
            UpdateDisplay()
            _CurrentFile = SplitPath(_CurrentFile, _DRIVE_ | _NAME_)
            case LoadExec("Compile successful")
            when 1
               LoadMacro(_CurrentFile)
            when 2
               ExecMacro(_CurrentFile)
            endcase
         else
            PrevFile()                      // Successful OTHER compile...
            HWindow()
            PrevWindow()
            UpdateDisplay()
            Message(iif(option==3,"No errors detected","No more errors"))
         endif
      endif
   endif
   return()
end

//--------------------------------------------------------------------------//
// 12/01/93 11:22 am H. Johnson - An 'ask()' with history...
proc GetString(string thePrompt, var string theString, var integer history_number)
  if history_number == 0   // This must be first time thru - initialize...
      history_number = GetFreeHistory()
      AddHistoryStr(theString,history_number)
  endif
  ask(thePrompt,theString,history_number)
end

