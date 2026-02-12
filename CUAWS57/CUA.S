/*************************************************************************
 CUA.S - (C) 1998-2004 by Bill Stewart (bstewart@iname.com)

 Version 1.1 - Jan 09 1998
 Version 1.2 - Mar 17 2001
 Version 2.0 - Apr 08 2002
 Version 2.1 - Jun 11 2002
 Version 2.2 - Mar 10 2004

 Changes:

 1.2 -

 o  Added a few keystrokes that I forgot (Shift-GreyHome, Shift-GreyEnd,
    Ctrl-G in prompt boxes, Ctrl-QE and Ctrl-QX)
 o  Typing an initial character in a prompt box immediately replaces any
    existing prompt box entry (as documented in the manual)
 o  Fixed bug in mouse marking when block wasn't automatically unmarking
    when it was supposed to
 o  Internal find and incremental search commands now position the cursor
    at the beginning of the found text, not the end (to support
    AgainReverse)
 o  CtrlShift-L does a find in the opposite direction of the last search
 o  CtrlShift-F and CtrlShift-I removed
 o  Ctrl-KR and Ctrl-QM removed (insertfile and gotomark)

 2.0 -

 o  Added the "persistent block" feature, meaning that if you select a
    block and then move the cursor without holding the shift key, the block
    will remain marked
 o  Added configuration menu

 2.1 -

 o  Added Ctrl-A command; it marks the entire file as a CUA-style block.
    To undo, use PrevPosition (Ctrl-QP)

 2.2 -

 o  Ctrl-Ins, Shift-Ins, and Shift+Del use Windows clipboard
 o  Added mReplace() macro; it makes it possible to mark a CUA block, press
    Ctrl-R (or Ctrl-QA) to quickly find and replace a string within just
    that block (it adds options 'gl'), and then continue on with life

 Usage: cua [on | off] [-t[+|-] -p[+|-]] [-c]

 on   enables the macro (used if no parameters specified)
 off  disables the macro
 -t+  enables "typing replaces block" (the default)
 -t-  disables "typing replaces block"
 -t   toggles the "typing replaces block" state
 -p+  enables persistent blocks (disables "typing replaces block")
 -p-  disables persistent blocks
 -p   toggles persistent blocks
 -c   display configuration menu

 If no arguments are specified, the macro assumes "on" and "-t+" the first
 time it is run.

 This macro provides CUA-style block marking for TSE Pro/32. It is loosely
 based on the CUAMARK macro that ships with TSE Pro/32.

 The macro uses a session-global integer variable, "CUA", to indicate
 whether it is enabled or disabled. The session-global variable is removed
 when the macro is purged. Other macros or a UI can use this session-
 global variable to determine if the macro is active and its state. The
 session-global integer will be set as:

 Setting                          Meaning
 --------------------------------------------------------------------------
 (getglobalint("CUA") & 1) <> 0   Macro is enabled
 (getglobalint("CUA") & 2) <> 0   Typing replaces block is enabled
 (getglobalint("CUA") & 4) <> 0   Persistent blocks are enabled

 Hold the <Shift> key when moving the cursor to mark a CUA-style block
 (i.e. if you move the cursor without holding the <Shift> key, the block
 is automatically unmarked). The <Alt> key will mark a column block.

 The mouse behavior has been enhanced:

 o  Click and drag marks a CUA-style character block.
 o  <Shift>+click extends a CUA-style character block.
 o  <Alt>+click extends a CUA-style column block.
 o  <Ctrl>+click extends a CUA-style column block.
 o  Click without dragging unmarks a CUA-style block.

 <Shift> block marking also works inside prompt boxes.

 The following keys are also active:

   Keystroke           Action
   -----------------------------------------------------------------------
   Ctrl-A              Mark entire file as a block

   Ctrl-X              Cut the block to the system clipboard

   Shift-Del           Cut the block to the Windows clipboard

   Ctrl-C              Copy the block to the system clipboard; the block
                       remains marked

   Ctrl-Ins            Copy the block to the Windows clipboard; the block
                       remains marked

   Ctrl-V              Paste contents of the system clipboard; any marked
                       CUA-style block is replaced if "typing replaces
                       block" is active; if the UnmarkAfterPaste variable
                       is ON, the block is inserted into the file and
                       marked as a CUA-style block

   Shift-Ins           Same as Ctrl-V, but uses Windows clipboard

   Del, Backspace,     If a CUA-style block is marked, delete it;
   Shift-Backspace     otherwise, the keystrokes behave as otherwise
                       assigned

   Ctrl-K]             Same as Ctrl-Ins

   Ctrl-K[             Same as Shift-Ins

   Ctrl-F, Ctrl-QF     Find, and mark the found text as a CUA-style block

   Ctrl-L              Repeat find, and mark the found text as a CUA-style
                       block

   CtrlShift-L         Like Ctrl-L, except find goes in the opposite
                       direction

   Ctrl-QA, Ctrl-R     If a CUA-style block is marked, do a "replace"
                       within the marked block ('gl' are added to the
                       replace options); otherwise, normal Replace()

   Ctrl-I              Incremental search, and mark the found text as a
                       CUA-style block

   (any other key)     When "typing replaces block" is active: If a
                       CUA-style block is marked, the next character you
                       type deletes the CUA-style block and replaces it
                       with the character you typed (This does not apply to
                       the Enter key)

   The "typing replaces block" setting is ignored in prompt boxes except
   for the first keystroke after the prompt box appears.

*************************************************************************/

constant
  MACRO_ENABLED         = 1,
  TYPING_REPLACES_BLOCK = 2,
  PERSISTENT_BLOCK      = 4

integer
  cua_marking, keep_marking, editing_key, cursor_moved,
  promptbox, enabled, typing_replaces = TYPING_REPLACES_BLOCK,
  persistent = OFF

forward proc CleanUp()

// Returns TRUE if a CUA block is being marked.
integer proc CUAMarking()
  return(cua_marking and isblockincurrfile() and query(marking))
end

proc AfterCommand()
  integer k

  if cua_marking and keep_marking
    keep_marking = FALSE
  else
    k = query(key)
    if CUAMarking()
      if istypeablekey(k) and editing_key and typing_replaces
        if currcol() == query(blockbegcol)  // marking right to left?
          backspace()                       // get rid of extra character
        endif
        iif(promptbox, killblock(), delblock())
        inserttext(chr(lobyte(k)))
      endif
      if cursor_moved                       // only clean up if the cursor
        CleanUp()                           // was moved
      endif
    endif
  endif
end

proc UnassignedKey()
  if cua_marking
    keep_marking = TRUE
  else
    CleanUp()
  endif
end

proc CleanUp()
  cua_marking = FALSE
  if persistent
    set(marking, OFF)
  else
    unmarkblock()
  endif
  unhook(AfterCommand)
  unhook(UnassignedKey)
end

// This Init() is used when QueryEditState() returns 0; pass it the block
// type you want to use while marking.
proc Init(integer block_type)
  //if not cua_marking or not isblockincurrfile() or not query(marking)
  if not CUAMarking()
    unmarkblock()
    mark(block_type)
    cua_marking = TRUE
    cursor_moved = TRUE
    hook(_AFTER_COMMAND_, AfterCommand)
    hook(_ON_UNASSIGNED_KEY_, UnAssignedKey)
  endif
  keep_marking = TRUE
end

// This proc used inside prompt boxes. It uses MarkChar().
proc PromptInit()
  if not CUAMarking()
    unmarkblock()
    markchar()
    cua_marking = TRUE
    cursor_moved = TRUE
    hook(_AFTER_NONEDIT_COMMAND_, AfterCommand)
    hook(_ON_UNASSIGNED_KEY_, UnAssignedKey)
  endif
  keep_marking = TRUE
end

// Cut the block to the system clipboard, and turn marking off.
proc mCut()
  if isblockincurrfile() or query(usecurrlineifnoblock)
    cut()
    CleanUp()
  endif
end

// Copy the block to the system clipboard.
proc mCopy()
  if isblockincurrfile() or query(usecurrlineifnoblock)
    pushblock()
    copy()
    popblock()
    keep_marking = TRUE
  endif
end

// If CUA marking is active, delete the block, then paste the contents of
// the system clipboard in its place. Then turn marking off.
proc mPaste()
  if CUAMarking() and typing_replaces
    iif(promptbox, killblock(), delblock())
  endif
  if paste()
    if query(unmarkafterpaste)
      CleanUp()
    else
      pushblock()
      Init(_NONINCLUSIVE_)
      popblock()
      set(marking, ON)
    endif
  endif
end

// If CUA marking is active and we can find a block, delete the block and
// stop marking.
proc mDelete()
  if CUAMarking()
    iif(promptbox, killblock(), delblock())
    CleanUp()
  else
    chaincmd()
  endif
end

// Same as mCopy(), but to Windows clipboard.
proc mCopyToWinClip()
  if isblockincurrfile() or query(usecurrlineifnoblock)
    pushblock()
    copytowinclip()
    popblock()
    keep_marking = TRUE
  endif
end

// Same as mPaste(), but to Windows clipboard.
proc mPasteFromWinClip()
  if CUAMarking() and typing_replaces
    iif(promptbox, killblock(), delblock())
  endif
  if pastefromwinclip()
    if query(unmarkafterpaste)
      CleanUp()
    else
      pushblock()
      Init(_NONINCLUSIVE_)
      popblock()
      set(marking, ON)
    endif
  endif
end

// Go back and forth between column 1 and first non-white char on line.
//proc mBegLine()
//  if not begline()
//    gotopos(posfirstnonwhite())
//  endif
//end

// BegFile() that maintains the current column if a column block is open.
proc mBegFile()
  integer col = currcol(), xoff = currxoffset()

  begfile()
  if query(marking) and isblockincurrfile() == _COLUMN_
    gotocolumn(col)
    gotoxoffset(xoff)
  endif
end

// EndFile() that maintains the current column if a column block is open.
proc mEndFile()
  integer col = currcol(), xoff = currxoffset()

  endfile()
  if query(marking) and isblockincurrfile() == _COLUMN_
    gotocolumn(col)
    gotoxoffset(xoff)
  endif
end

proc mBegWindow()
  begwindow()
  begline()
end

proc mEndWindow()
  endwindow()
  endline()
end

// CUA-sensitive Find/IncrementalSearch commands.

proc CommonFind()
  CleanUp()
  Init(_NONINCLUSIVE_)
  markfoundtext()
  set(marking, ON)
end

proc mFind()
  if find()
    CommonFind()
  endif
end

proc mRepeatFind(integer reverse)
  if reverse
    if repeatfind(_REVERSE_)
      CommonFind()
    endif
  else
    if repeatfind()
      CommonFind()
    endif
  endif
end

proc mIncrementalSearch()
  integer state = sethookstate(OFF, _AFTER_GETKEY_),
    cline = currline(), cpos = currpos()

  if execmacro("ISRCH")
    if (cline <> currline()) or (cpos <> currpos())   // cursor moved
      lfind(gethistorystr(_FIND_HISTORY_, 1), "cig")  // find the text
      CommonFind()
    endif
  else
    CleanUp()
  endif

  sethookstate(state, _AFTER_GETKEY_)
end

proc mReplace()
  integer persistence, blocktype
  string roh[14] = ""

  if CUAMarking()
    persistence = persistent        // save the "persistent block" state
    persistent = PERSISTENT_BLOCK   // enable persistent blocks
    blocktype = isblockmarked()     // save block type
    pushblock()
    pushposition()
    CleanUp()                       // disable CUA marking
    roh = lower(gethistorystr(_REPLACEOPTIONS_HISTORY_, 1))
    if pos("g", roh) == 0
      roh = roh + "g"
    endif
    if pos("l", roh) == 0
      roh = roh + "l"
    endif
    //uncomment the below 3 lines if you want 'x' to be a standard option
    //if pos("x", roh) == 0
    //  roh = roh + "x"
    //endif
    addhistorystr(roh, _REPLACEOPTIONS_HISTORY_)
    replace()
    delhistorystr(_REPLACEOPTIONS_HISTORY_, 1)
    persistent = persistence        // restore "persistent block" state
    Init(blocktype)                 // re-initialize marking
    popblock()
    popposition()
  else
    replace()
  endif
end

proc mMarkFile()
  if numlines()
    CleanUp()
    unmarkblock()
//  pushposition()
    begfile()
    markchar()
    endfile()
//  markchar()
//  popposition()
    cua_marking = TRUE
    cursor_moved = TRUE
    hook(_AFTER_COMMAND_, AfterCommand)
    hook(_ON_UNASSIGNED_KEY_, UnAssignedKey)
    keep_marking = TRUE
  endif
end

// CUA-like mouse button.
proc mMouseButton()
  case mousehotspot()
    when _NONE_
      chaincmd()                      // or MainMenu(), in a UI
    when _MOUSE_MARKING_
      if not isblockincurrfile()      // there's no block in this file
        mousemarking(_NONINCLUSIVE_)
        pushblock()                   // save what we've been marking
        Init(_NONINCLUSIVE_)          // initialize CUA block (it unmarks)
        popblock()                    // put back what we've been marking
        set(marking, ON)              // turn marking on for non-mouse
      else                            // there's a block in this file
        CleanUp()                     // clean up
        processhotspot()              // and do whatever
      endif
    otherwise
      processhotspot()                // other hot spot: simply process
  endcase
end

// CUA block extension using the mouse.
proc mExtendBlock(integer block_type)
  integer cline = currline(), cpos = currpos(), forwards = TRUE
  // forwards indicates if we should extend the block forwards or not.

  if isblockincurrfile()   // there's a block in this file
    pushposition()         // keep track of where we are
    if gotomousecursor()
      forwards = not ((currline() < cline) or
        ((currline() == cline) and (currpos() < cpos)))
        // extend the block forwards or not?
    endif
    popposition()          // go back to where we were
    iif(forwards, gotoblockbegin(), gotoblockend())
    unmarkblock()          // unmark the block
  endif
  Init(block_type)         // start a new CUA-style block
  if gotomousecursor()     // and go to the cursor
    trackmousecursor()
  endif
end

// Make sure to account for LineDrawing mode.
proc AfterGetKey()
//if (queryeditstate() <> 0) or (queryeditstate() <> _NONEDIT_IDLE_) or (query(linedrawing) == ON)
  if (queryeditstate() <> 0) or (query(linedrawing) == ON)
    editing_key = FALSE
    return()
  endif

  editing_key = TRUE
  case query(key)
    // Cursor movement without marking a block.
    when <cursorup>, <greycursorup>                           if cua_marking CleanUp() endif up()
    when <cursordown>, <greycursordown>                       if cua_marking CleanUp() endif down()
    when <cursorleft>, <greycursorleft>                       if cua_marking CleanUp() endif left()
    when <cursorright>, <greycursorright>                     if cua_marking CleanUp() endif right()
    when <ctrl cursorup>, <ctrl greycursorup>                 if cua_marking CleanUp() endif rollup()
    when <ctrl cursordown>, <ctrl greycursordown>             if cua_marking CleanUp() endif rolldown()
    when <ctrl cursorleft>, <ctrl greycursorleft>             if cua_marking CleanUp() endif wordleft()
    when <ctrl cursorright>, <ctrl greycursorright>           if cua_marking CleanUp() endif wordright()
    when <home>, <greyhome>                                   if cua_marking CleanUp() endif begline()
    when <end>, <greyend>                                     if cua_marking CleanUp() endif endline()
    when <ctrl home>, <ctrl greyhome>                         if cua_marking CleanUp() endif mBegFile()
    when <ctrl end>, <ctrl greyend>                           if cua_marking CleanUp() endif mEndFile()
    when <pgup>, <greypgup>                                   if cua_marking CleanUp() endif pageup()
    when <pgdn>, <greypgdn>                                   if cua_marking CleanUp() endif pagedown()
    when <ctrl pgup>, <ctrl greypgup>                         if cua_marking CleanUp() endif rollleft()
    when <ctrl pgdn>, <ctrl greypgdn>                         if cua_marking CleanUp() endif rollright()
    when <ctrl w>                                             if cua_marking CleanUp() endif scrollup()
    when <ctrl z>                                             if cua_marking CleanUp() endif scrolldown()

    // Use the <Shift> key to mark a regular block.
    when <shift cursorup>, <shift greycursorup>               Init(_NONINCLUSIVE_) up()
    when <shift cursordown>, <shift greycursordown>           Init(_NONINCLUSIVE_) down()
    when <shift cursorleft>, <shift greycursorleft>           Init(_NONINCLUSIVE_) if not prevchar() left() endif
    when <shift cursorright>, <shift greycursorright>         Init(_NONINCLUSIVE_) if not nextchar() right() endif
    when <ctrlshift cursorup>, <ctrlshift greycursorup>       Init(_NONINCLUSIVE_) rollup()
    when <ctrlshift cursordown>, <ctrlshift greycursordown>   Init(_NONINCLUSIVE_) rolldown()
    when <ctrlshift cursorleft>, <ctrlshift greycursorleft>   Init(_NONINCLUSIVE_) wordleft()
    when <ctrlshift cursorright>, <ctrlshift greycursorright> Init(_NONINCLUSIVE_) wordright()
    when <shift home>, <shift greyhome>                       Init(_NONINCLUSIVE_) begline()
    when <shift end>, <shift greyend>                         Init(_NONINCLUSIVE_) endline()
    when <ctrlshift home>, <ctrlshift greyhome>               Init(_NONINCLUSIVE_) mBegFile()
    when <ctrlshift end>, <ctrlshift greyend>                 Init(_NONINCLUSIVE_) mEndFile()
    when <shift pgup>, <shift greypgup>                       Init(_NONINCLUSIVE_) pageup()
    when <shift pgdn>, <shift greypgdn>                       Init(_NONINCLUSIVE_) pagedown()
    when <ctrlshift pgup>, <ctrlshift greypgup>               Init(_NONINCLUSIVE_) rollleft()
    when <ctrlshift pgdn>, <ctrlshift greypgdn>               Init(_NONINCLUSIVE_) rollright()
    when <ctrlshift w>                                        Init(_NONINCLUSIVE_) scrollup()
    when <ctrlshift z>                                        Init(_NONINCLUSIVE_) scrolldown()

    // Use <Alt> to mark a column block.
    when <alt cursorup>, <alt greycursorup>                   Init(_COLUMN_) up()
    when <alt cursordown>, <alt greycursordown>               Init(_COLUMN_) down()
    when <alt cursorleft>, <alt greycursorleft>               Init(_COLUMN_) left()
    when <alt cursorright>, <alt greycursorright>             Init(_COLUMN_) right()
    when <ctrlalt cursorup>, <ctrlalt greycursorup>           Init(_COLUMN_) rollup()
    when <ctrlalt cursordown>, <ctrlalt greycursordown>       Init(_COLUMN_) rolldown()
    when <ctrlalt cursorleft>, <ctrlalt greycursorleft>       Init(_COLUMN_) wordleft()
    when <ctrlalt cursorright>, <ctrlalt greycursorright>     Init(_COLUMN_) wordright()
    when <alt home>, <alt greyhome>                           Init(_COLUMN_) begline()
    when <alt end>, <alt greyend>                             Init(_COLUMN_) endline()
    when <ctrlalt home>, <ctrlalt greyhome>                   Init(_COLUMN_) mBegFile()
    when <ctrlalt end>, <ctrlalt greyend>                     Init(_COLUMN_) mEndFile()
    when <alt pgup>, <alt greypgup>                           Init(_COLUMN_) pageup()
    when <alt pgdn>, <alt greypgdn>                           Init(_COLUMN_) pagedown()
    when <ctrlalt pgup>, <ctrlalt greypgup>                   Init(_COLUMN_) rollleft()
    when <ctrlalt pgdn>, <ctrlalt greypgdn>                   Init(_COLUMN_) rollright()
    otherwise
      cursor_moved = FALSE     // some other key pressed; cursor NOT moved
      return()
  endcase
  set(key, -1)                 // key value of -1 calls NoOp()
end

keydef CUAKeys
  // Cut/Copy/Paste/Delete keys
  <ctrl a>          mMarkFile()
  <ctrl x>          mCut()
  <shift del>       cuttowinclip()
  <shift greydel>   cuttowinclip()
  <ctrl c>          mCopy()
  <ctrl ins>        mCopyToWinClip()
  <ctrl greyins>    mCopyToWinClip()
  <ctrl v>          mPaste()
  <shift ins>       mPasteFromWinClip()
  <shift greyins>   mPasteFromWinClip()
  <del>             mDelete()
  <greydel>         mDelete()
  <backspace>       mDelete()
  <shift backspace> mDelete()
  <ctrl g>          mDelete()
  <ctrl h>          mDelete()

  // WordStar block/file keys
  <ctrl k><]>       mCopyToWinClip()
  <ctrl k><ctrl ]>  mCopyToWinClip()
  <ctrl k><[>       mPasteFromWinClip()
  <ctrl k><ctrl [>  mPasteFromWinClip()

  // WordStar two-key cursor movement without CUA marking
  <ctrl q><c>       if cua_marking CleanUp() endif mEndFile()
  <ctrl q><d>       if cua_marking CleanUp() endif endline()
  <ctrl q><p>       if cua_marking CleanUp() endif prevposition()
  <ctrl q><r>       if cua_marking CleanUp() endif mBegFile()
  <ctrl q><s>       if cua_marking CleanUp() endif begline()
  <ctrl q><e>       if cua_marking CleanUp() endif mBegWindow()
  <ctrl q><x>       if cua_marking CleanUp() endif mEndWindow()

  // Extended find commands
  <ctrl f>          mFind()
  <ctrl i>          mIncrementalSearch()
  <ctrl l>          mRepeatFind(FALSE)
  <ctrlshift l>     mRepeatFind(TRUE)
  <ctrl q><a>       mReplace()
  <ctrl q><f>       mFind()
  <ctrl r>          mReplace()

  // Mouse
  <leftbtn>         mMouseButton()
  <shift leftbtn>   mExtendBlock(_NONINCLUSIVE_)
  <alt leftbtn>     mExtendBlock(_COLUMN_)
  <ctrl leftbtn>    mExtendBlock(_LINE_)
end

keydef PromptKeys
  // marking keys
  <cursorleft>                CleanUp()    left()
  <greycursorleft>            CleanUp()    left()
  <cursorright>               CleanUp()    right()
  <greycursorright>           CleanUp()    right()
  <shift cursorleft>          PromptInit() left()
  <shift greycursorleft>      PromptInit() left()
  <shift cursorright>         PromptInit() right()
  <shift greycursorright>     PromptInit() right()
  <ctrlshift cursorleft>      PromptInit() wordleft()
  <ctrlshift greycursorleft>  PromptInit() wordleft()
  <ctrlshift cursorright>     PromptInit() wordright()
  <ctrlshift greycursorright> PromptInit() wordright()
  <shift home>                PromptInit() begline()
  <shift greyhome>            PromptInit() begline()
  <shift end>                 PromptInit() endline()
  <shift greyend>             PromptInit() endline()

  // Cut/Copy/Paste/Delete keys
  <ctrl x>                    mCut()
  <shift del>                 cuttowinclip()
  <shift greydel>             cuttowinclip()
  <ctrl c>                    mCopy()
  <ctrl ins>                  mCopyToWinClip()
  <ctrl greyins>              mCopyToWinClip()
  <ctrl v>                    mPaste()
  <shift ins>                 mPasteFromWinClip()
  <shift greyins>             mPasteFromWinClip()
  <del>                       mDelete()
  <greydel>                   mDelete()
  <backspace>                 mDelete()
  <ctrl g>                    mDelete()
  <ctrl h>                    mDelete()

  // WordStar keys
  <ctrl k><]>                 mCopyToWinClip()
  <ctrl k><ctrl ]>            mCopyToWinClip()
  <ctrl k><[>                 mPasteFromWinClip()
  <ctrl k><ctrl [>            mPasteFromWinClip()
  <ctrl q><d>                 if iscursorinblock() CleanUp() endif endline()
  <ctrl q><s>                 if iscursorinblock() CleanUp() endif begline()
end

// Used in prompt box processing
integer markstate, cua_markstate

proc PromptStartup()
  integer k

  pushblock()                     // save any currently active block
  markstate = set(marking, OFF)   // turn marking off
  cua_markstate = cua_marking     // save the CUA block-marking state

  updatedisplay()                 // so we can see the prompt box!
  k = getkey()                    // get a keystroke
  case k
    when <del>, <greydel>, <backspace>, <ctrl h>
      // note: have to use begline()/killtoeol() here; if you use
      // killline(), the prompt box buffer retrieves invalid data as
      // the next line of the prompt box
      begline()                 // go to beginning of line
      killtoeol()               // kill to eol
      pushkey(<del>)            // so the block highlight disappears
      updatedisplay()           // now let's see what's going on
    otherwise
      pushkey(k)
  endcase

  enable(PromptKeys)
  promptbox = TRUE

//pushkey(<shift end>)
//pushkey(<home>)
//updatedisplay()
end

proc PromptCleanup()
  set(marking, markstate)         // restore saved block stuff
  cua_marking = cua_markstate
  popblock()
  promptbox = FALSE
end

proc Start()
  if not enabled
    enabled = enable(CUAKeys)
    if enabled
      hook(_AFTER_GETKEY_, AfterGetKey)
      hook(_PROMPT_STARTUP_, PromptStartup)
      hook(_PROMPT_CLEANUP_, PromptCleanup)
    endif
  endif
end

integer proc MFCUATyping()
  integer ret
  if enabled
    ret = iif(typing_replaces, _MF_CHECKED_, _MF_UNCHECKED_)
    if persistent
      ret = ret | _MF_GRAYED_
    endif
  else
    ret = iif(typing_replaces, _MF_CHECKED_, _MF_UNCHECKED_) | _MF_GRAYED_
  endif
  return(ret)
end

integer proc MFCUAPersistent()
  integer ret
  if enabled
    ret = iif(persistent, _MF_CHECKED_, _MF_UNCHECKED_)
  else
    ret = iif(persistent, _MF_CHECKED_, _MF_UNCHECKED_) | _MF_GRAYED_
  endif
  return(ret)
end

menu ConfigMenu()
  "&CUA marking enabled",   iif(enabled, execmacro(currmacrofilename() + " off"), execmacro(currmacrofilename() + " on")), iif(enabled, _MF_CHECKED_, _MF_UNCHECKED_) | _MF_CLOSE_BEFORE_
  "",,                      _MF_DIVIDE_
  "&Typing replaces block", execmacro(currmacrofilename() + " -t"), MFCUATyping() | _MF_CLOSE_BEFORE_
  "&Persistent block",      execmacro(currmacrofilename() + " -p"), MFCUAPersistent() | _MF_CLOSE_BEFORE_
end

proc Main()
  string cmdline[_MAXPATH_] = query(macrocmdline),
    s[_MAXPATH_] = ""
  integer i

  if length(cmdline)
    for i = 1 to numtokens(cmdline, " ")
      s = gettoken(cmdline, " ", i)
      case lower(s)
        when "on"
          Start()
        when "off"
          disable(CUAKeys)
          enabled = FALSE
          unhook(AfterGetKey)
          unhook(PromptStartup)
          unhook(PromptCleanup)
        when "-c", "/c"
          ConfigMenu()
        when "-t", "/t"
          if typing_replaces
            typing_replaces = OFF
          else
            typing_replaces = TYPING_REPLACES_BLOCK
          endif
        when "-t+", "/t+"
          typing_replaces = TYPING_REPLACES_BLOCK
        when "-t-", "/t-"
          typing_replaces = OFF
        when "-p", "/p"
          if persistent
            persistent = OFF
          else
            persistent = PERSISTENT_BLOCK
          endif
        when "-p+", "/p+"
          persistent = PERSISTENT_BLOCK
        when "-p-", "/p-"
          persistent = OFF
      endcase
    endfor
  else
    Start()
  endif

  if enabled
    setglobalint("CUA", MACRO_ENABLED | typing_replaces | persistent)
  else
    setglobalint("CUA", 0)
  endif
end

proc WhenLoaded()
  Main()
end

proc WhenPurged()
  delglobalvar("CUA")
end
