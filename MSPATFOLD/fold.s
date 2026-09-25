/* Features

FOLD 1.0 by Marc Spruijt (nlklmhzm@ibmmail.com)


FOLD has the following features:
- multiple folds
- nested folds
- same fold names in different files are OK
- starting and ending fold line syntax allows for commenting out the
  fold bounderies in any programming language I know of
- foldnames can be 64 characters long


The starting fold line starts with 4 characters (any) followed by #[
(to identify the start of the fold) followed by the foldname.
The ending fold line starts with 4 characters (any) followed by #]
(to identify the end of the fold) followed by the foldname.
A fold starts at the first character of the start-fold-line and ends
at the last character of the end-fold-line. The last character of the
foldname must be a collon (:). The constant FoldWordSet determines the
valid characters that are allowed in a foldname (apart from the :).
All characters after the : are ingnored.
A closed fold is shown as the start-fold-line with the #[ replaced by ##.

To make fold lines you can use the MakeFoldLines command. On a new line
just put the fold-name-to-be and execute the MakeFoldLines command.


Used keys:
           F11 CloseFold
shift      F11 OpenFold
alt        F11 CloseAllFolds
ctrl       F11 OpenAllFolds
ctrl shift F11 MakeFoldLines

shift      F12 FoldSaveFile
alt        F12 FoldExit
ctrl       F12 FoldSaveAndQuitFile
ctrl shift F12 FoldSaveAllAndExit
ctrl alt   F12 FoldSaveAs
alt  shift F12 FoldSaveBlock

Replaced key defs:

ctrl kq        FoldQuitFile()
ctrl ks        FoldSaveFile(1)
ctrl kx        FoldSaveAndQuitFile()
alt  x         FoldExit()
alt  w         FoldSaveBlock()

Replace the TSE.UI key defs and/or menu entries for SaveFile, Exit,
QuitFile, SaveAndQuitFile, SaveAllAndExit, SaveAs and SaveBlock by
their Fold equivalents as you like.


Known nuisances:
- After OpenAllFolds the cursor is at the begining of the file.
- There is NO safeguard against editing the closed fold line. DON'T
  edit the closed fold line if you want to restore the fold.
- FoldSaveBlock does not act like SaveAs on the entire file when no
  block exists in the current file.
- The original macro did not verify that closed-fold-looking lines had
  matching temporary fold buffers during saving. Version 1.0.0.0.6 now
  performs that verification to avoid false save refusals.
- All commands exept the SaveBlock command will corrupt a marked block
  when the block starts on a closed foldline when the fold is opened.
  I put in a workaround in the SaveBlock command. Note that only when
  the first character of the closed fold line is part of the marked block
  the fold will be opened.

*/

constant foldnamelength=64
integer bufferid
string foldwordset[10]="[\t -9;-~]"   // Do NOT include : in the set
string foldline[255]=""
string foldname[foldnamelength]=""
string foldid[foldnamelength+10]=""
string GSVersion[16]="1.0.0.0.9"
string GSSilent[8]="false"

proc Main()
  GSSilent = GetProfileStr("mspatfold", "silent", "false", "mspatfold.ini")
  if Lower(GSSilent) <> "true"
    Warn("MSPATFOLD ", GSVersion, " (OpenAI Codex): Folding commands operate on the current file; no marked block is required.")
  endif
end

proc Error(integer i)
  alarm()
  case i
    when 1
      popposition()
      message("Cursor not in fold")
    when 2
      message("No open fold found")
    when 3
      message("Cursor not on closed fold")
    when 4
      message("No closed fold found")
    when 5
      popposition()
      message("Out of memory, unable to fold")
    when 6
      message("Unable to open fold")
    when 7
      popposition()
      message("Closed fold with same name allready exists")
    when 8
      message("No proper foldname found")
    when 9
      message("No block in current file")
    otherwise
      warn("INTERNAL ERROR ",i)
  endcase
  popblock()
  halt
end

proc GetFoldInfo() // BufferID, Foldname, Foldline, FoldID
  markfoundtext()
  bufferid=getbufferid()
  foldline=getmarkedtext()
  foldname=substr(foldline,7,foldnamelength)
  foldid=str(bufferid)+foldname
end

integer proc FNCurrentClosedFoldExists()
integer existsI=FALSE
  pushblock()
  getfoldinfo()
  if getbufferid(foldid)
    existsI=TRUE
  endif
  popblock()
  return(existsI)
end

integer proc FNHasActiveClosedFold()
integer activeI=FALSE
integer foundI
  pushblock()
  pushposition()
  begfile()
  foundI=lfind("^....\#\#"+foldwordset+"#:","x")
  while foundI and not activeI
    activeI=FNCurrentClosedFoldExists()
    if not activeI
      if down()
        begline()
        foundI=lfind("^....\#\#"+foldwordset+"#:","x")
      else
        foundI=FALSE
      endif
    endif
  endwhile
  popposition()
  popblock()
  return(activeI)
end

proc StoreFold()
  getfoldinfo()
  endline()
  markchar()
  if not lfind("^....\#\["+foldname,"bix")
    killposition()
    error(1)
  endif
  markstream()
  popposition()
  if iscursorinblock()
    if getbufferid(foldid)
      error(7)
    endif
    if not createbuffer(foldid,_SYSTEM_)
      error(5)
    endif
    moveblock()
    markline()
    foldline=getmarkedtext()
    gotobufferid(bufferid)
    inserttext(substr(foldline,1,5)+"#"+substr(foldline,7,255))
  else
    error(1)
  endif
end

proc CloseFold()
integer nested
integer found
integer linenumber=currline()
  pushblock()
  pushposition()
  begline()
  pushposition()
  nested=1
  repeat
    found=lfind("^....\#\]|\["+foldwordset+"#:","x")
    if found
      if currchar(6)==asc("]")
        nested=nested-1
      elseif (linenumber<>currline()) // When NOT invoked on Open Fold Line
          nested=nested+1
      endif
    endif
    if nested
      down()
    endif
  until (not nested) or (not found)
  if nested
    killposition()
    error(1)
  endif
  storefold()
  popposition()
  begline()
  popblock()
end

proc CloseAllFolds()
integer foldsfound=0
  pushblock()
  pushposition()
  begfile()
  while lfind("^....\#\]"+foldwordset+"#:","x")
    pushposition()
    storefold()
    foldsfound=foldsfound+1
  endwhile
  popposition()
  if not foldsfound
    error(2)
  endif
  popblock()
  begline()
  message(foldsfound," folds closed")
end

proc RestoreFold()
  getfoldinfo()
  if not gotobufferid(getbufferid(foldid))
    killposition()
    error(6)
  endif
  begfile()
  markstream()
  endfile()
  markchar()
  gotobufferid(bufferid)
  killtoeol()
  moveblock()
  abandonfile(getbufferid(foldid))
end

proc OpenFold()
integer linenumber=currline()
  pushblock()
  pushposition()
  begline()
  if not lfind("^....\#\#"+foldwordset+"#:","x") or (linenumber<>currline())
    popposition()
    popblock()
    alarm()
    message("Cursor not on a closed fold")
    return()
  endif
  if not FNCurrentClosedFoldExists()
    popposition()
    popblock()
    alarm()
    message("This line looks closed, but no active fold buffer exists")
    return()
  endif
  restorefold()
  killposition()
  popblock()
end

proc OpenAllFolds(integer savecall)
integer foldsfound=0
integer found
integer searchline
  pushblock()
  pushposition()
  begfile()
  found=lfind("^....\#\#"+foldwordset+"#:","x")
  while found
    searchline=currline()
    if FNCurrentClosedFoldExists()
      restorefold()
      foldsfound=foldsfound+1
    endif
    gotoline(searchline)
    if down()
      begline()
      found=lfind("^....\#\#"+foldwordset+"#:","x")
    else
      found=FALSE
    endif
  endwhile
  popposition()
  popblock()
  if not foldsfound
    if not savecall
      alarm()
      message("No closed fold found")
    endif
  elseif not savecall
    message(foldsfound," folds opened")
  endif
end

proc MakeFoldLines()
integer linenumber=currline()
string remarkstart[4]="----"
string remarkend[4]=""
  pushblock()
  pushposition()
  begline()
  if not lfind("^"+foldwordset+"#","x")
    popposition()
    error(8)
  endif
  if ((currline()<>linenumber) or (currpos()<>1))
    popposition()
    error(8)
  endif
  markfoundtext()
  foldname=getmarkedtext()
  killtoeol()
  case lower(splitpath(currfilename(),_EXT_))
    when ".c",".cpp"                 // C, C++
      remarkstart="/*  "
      remarkend="*/"
    when ".s",".ui"                  // TSE SAL
      remarkstart="//  "
    when ".pas"                       // Delphi, Pascal
      remarkstart="{   "
      remarkend="}"
    when ".bas",".bat"               // BASIC, Batch
      remarkstart="REM "
    when ".ini"                       // INI
      remarkstart=";   "
    when ".abap"                      // ABAP
      remarkstart="*   "
    when ".ada",".adb",".ads"         // Ada
      remarkstart="--  "
    when ".asm"                       // Assembly language
      remarkstart=";   "
    when ".cs"                        // C#
      remarkstart="//  "
    when ".ml",".mli"                 // CAML, OCaml
      remarkstart="(*  "
      remarkend="*)"
    when ".cob",".cbl",".cpy"         // COBOL
      remarkstart="*>  "
    when ".dart"                      // Dart
      remarkstart="//  "
    when ".erl",".hrl"                 // Erlang
      remarkstart="%   "
    when ".f",".for",".f77",".f90",".f95",".f03",".f08" // Fortran
      remarkstart="!   "
    when ".prg"                       // FoxPro
      remarkstart="*   "
    when ".go"                        // Go
      remarkstart="//  "
    when ".hs",".lhs"                 // Haskell
      remarkstart="--  "
    when ".java"                      // Java
      remarkstart="//  "
    when ".jl"                        // Julia
      remarkstart="#   "
    when ".kt",".kts"                 // Kotlin
      remarkstart="//  "
    when ".lua"                       // Lua
      remarkstart="--  "
    when ".mpl",".maple"              // Maple source
      remarkstart="#   "
    when ".m"                         // MatLab
      remarkstart="%   "
    when ".pl",".pm"                  // Perl
      remarkstart="#   "
    when ".php",".php3",".php4",".php5",".phtml" // PHP
      remarkstart="//  "
    when ".ps1",".psm1",".psd1"      // PowerShell
      remarkstart="#   "
    when ".pro",".prolog"             // Prolog; .pl remains Perl
      remarkstart="%   "
    when ".py",".pyw"                 // Python
      remarkstart="#   "
    when ".r"                         // R
      remarkstart="#   "
    when ".rb",".rake"                // Ruby
      remarkstart="#   "
    when ".rs"                        // Rust
      remarkstart="//  "
    when ".sas"                       // SAS
      remarkstart="/*  "
      remarkend="*/"
    when ".scala",".sc"               // Scala
      remarkstart="//  "
    when ".scratch"                   // Scratch text or pseudocode
      remarkstart="//  "
    when ".sql"                       // SQL
      remarkstart="--  "
    when ".swift"                     // Swift
      remarkstart="//  "
    when ".ts",".tsx"                 // TypeScript
      remarkstart="//  "
    when ".vhd",".vhdl"               // VHDL
      remarkstart="--  "
    when ".xsl",".xslt"               // XSLT
      remarkstart="<!--"
      remarkend="-->"
  endcase
  inserttext(remarkstart+"#] "+foldname+" : "+remarkend)
  insertline()
  insertline(remarkstart+"#[ "+foldname+" : "+remarkend)
  begline()
  down()
  popblock()
  killposition()
end

integer proc FoldSaveFile(integer filesave)
  if not filechanged()
    return(1)
  endif
  if FNHasActiveClosedFold()
    case yesno("Open closed folds before save?")
      when 1
        openallfolds(1)
        if FNHasActiveClosedFold()
          alarm()
          message("Unable to open every active closed fold; file not saved")
          return(0)
        endif
      when 0,3
        return(0)
    endcase
  endif
  if filesave
    return(savefile())
  else
    updatedisplay()
    return(saveas())
  endif
  return(1)         // Put here only to avoid compile warning
end

proc FoldExit()
  bufferid=getbufferid()
  repeat
    if filechanged()
      updatedisplay()
      case yesno("Save changes?")
        when 1
          if not foldsavefile(1)
            return()
          endif
        when 2
          filechanged(FALSE)
        when 0,3
          return()
      endcase
    endif
    nextfile(_DONT_LOAD_)
  until (bufferid==getbufferid())
  exit()
end

proc FoldSaveAllAndExit()
  bufferid=getbufferid()
  repeat
    if filechanged()
      updatedisplay()
      if not foldsavefile(1)
        return()
      endif
    endif
    nextfile(_DONT_LOAD_)
  until (bufferid==getbufferid())
  exit()
end

proc FoldQuitFile()
  if filechanged()
    case yesno("Save changes?")
      when 1
        if not foldsavefile(1)
          return()
        endif
      when 2
        filechanged(FALSE)
      when 0,3
        return()
    endcase
  endif
  quitfile()
end

proc FoldSaveAndQuitFile()
  if not foldsavefile(1)
    return()
  endif
  quitfile()
end

proc FoldSaveBlock()
integer x
integer y
integer blockstatus
  blockstatus=isblockincurrfile()
  if blockstatus
    pushposition()
    gotoblockbegin()
    x=currpos()
    y=currline()
    if (lfind("^....\#\#"+foldwordset+"#:","x") and iscursorinblock())
      case yesno("Open closed folds in block before save?")
        when 1
          while (lfind("^....\#\#"+foldwordset+"#:","x") and
                 iscursorinblock())
            pushblock()
            restorefold()
            popblock()
          endwhile
        when 0,3
          popposition()
          return()
      endcase
      gotoline(y)
      gotopos(x)
      if not iscursorinblock()
        mark(blockstatus)
      endif
    endif
    popposition()
    updatedisplay()
    saveblock()
  else
    error(9)
  endif
end

proc FoldSaveAs()
  foldsavefile(0)
end


// Key defs

<          F11> CloseFold()
<shift     F11> OpenFold()
<alt       F11> CloseAllFolds()
<ctrl      F11> OpenAllFolds(0)
<ctrlshift F11> MakeFoldLines()

<shift     F12> FoldSaveFile(1)
<alt       F12> FoldExit()
<ctrl      F12> FoldSaveAndQuitFile()
<ctrlshift F12> FoldSaveAllAndExit()
<ctrlalt   F12> FoldSaveAs()
<altshift  F12> FoldSaveBlock()

// Replaced key defs

<ctrl k><q> FoldQuitFile()
<ctrl k><s> FoldSaveFile(1)
<ctrl k><x> FoldSaveAndQuitFile()
<alt x>     FoldExit()
<alt w>     FoldSaveBlock()
