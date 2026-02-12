/* IF THIS MAKRO IS USED UNCHANGED, THE CLOSED FOLDS CAN BE OPENED WITH
   CTRL-F12 AND CLOSED WITH CTRL-F11 */

//{{{ Title
//
// FOLD.S
//
// Version: 1.31 english / 06.12.1994
//
// Macro for TSE 2.0 as folding editor
//
// Copyright (C) 1993-1994 by Dirk Wissmann (DW)
//
// Bugfixes / Additional help:
//
// David Mayerovitch (E-Mail: david.mayerovitch@canrem.com):
// ---------------------------------------------------------
//   significant improvements of the handling. Thanks to his assistance,
//   it is no longer necessary to stand ON a foldline, but rather
//   in BETWEEN an opened fold. This avoids the message
//   "I don't like THIS as fold...", it simplifies handling.
//   The filestatus-bug was corrected by him. His changes are marked
//   in the sourcefile with DM, additional changes to his are marked
//   with DW.
//
//}}}
//{{{ Introduction
//
// This Sourcefile ist at the same time an example for WHAT using
// folds is able to do. The structure becomes somehow obvious...
//
// Closed folds are marked by three POINTS followed by a brief
// description. Opening them is done by the procedure OpenFold.
// Open folds are marked by user-defined character-strings.
//
// HINT: Please don't use the character "." (Ascii 46) inside the
// description of any fold - it only causes much much trouble.
//
//}}}
//{{{ Known Bugs
//
// Known Bugs in version 1.31:
//
// If you load a new file, where one or more folds have the identical
// description as in an already loaded file, the contents of the fold
// of the already loaded file are completely lost without a chance of
// restoring. Until now, I don't have any idea how to prevent this.
//
// OpenAllClosedFolds doesn't work correct, when a fold is placed in
// the topmost column (column 1 thus). There is no data lost, but it
// is possible, that this fold is placed at a random place inside the
// text.
//
// There is no protection for the folding-lines, thus if someone changes
// the Line starting with the <closedfold> characters, he should know, that
// TSE is perhaps not in state to find the internal buffer. The reason is,
// that the description of the fold is taken as reference-name for this
// internal system buffer. Overwriting lines starting with <startfold>
// characters is not so harmful, but I advise you, NOT to do this.
// ("Enter at your own risk" - B.Simpson)
//
// Nested folds are not possible yet. It would be too complex for me at the
// moment to implement this feature. But if you absolutely want it, there
// could be a dirty workaround, but I'm not sure, if it really works
// (especially while initial closing or final opening of all folds for
// saving the file): create one fold with a name, let's say "louie". Then,
// WITHIN this fold create some empty lines, and then create another fold
// with another name, let's say "foo". When you finished your work in
// "foo", close this fold, and after finishing work in "louie", close this
// fold too. Opening now must happen in reverse order: first open "louie",
// then open "foo" - voil…, it should have worked. But I recommend you,
// better NOT to do such things - leaving the editor would DEFINITELY
// destroy "foo", I think.
//
//}}}
//{{{ Improvements and new versions
//
// Improvements, new versions:
//
// If I find the time, I'm surely interested in improving my macro.
// But I've given up my idea of perhaps implementing nested folds. One
// reason is definitely, that I don't have enough time to do this. The
// second reason is: David Mayerovitch wrote to me, that TSE would never
// become a perfect "outliner", and that people should be happy, that
// there is at least one macro, that EMULATES this very close. But if
// someone absolutely wants to try this - go ahead, and if there is
// a result, send it to me!
//
// If someone has suggestions or has done changes in sourcecode - please
// send them to me (see below for my email-addresses).
//
// Improvements done so far:
//
// ---------------------------- Version 1.31 ----------------------
// * Adaption for TSE 2.00. No Bugfixes, no new features.
// ---------------------------- Version 1.3 -----------------------
// * Removed the historylist when creating new folds. That was indeed
//   a bad idea, since you could accidentally destroy existing and
//   closed folds by using the same name (DM)
// * An open fold can now be closed from anywhere WITHIN the fold.
//   It is no longer necessary to go onto the startfold for this (DM)
// ---------------------------- Version 1.2 -----------------------
// (this version never saw the light of the world, only the light
// of my own working room)
// * Built in additional help, modified Helplines
// * Menu-driven configuration built in. If you make changes, the whole
//   file is adjusted in the appropriate way. The menu is called
//   with F12 (unless you redefine the keys)
// ---------------------------- Version 1.1 -----------------------
// * David Mayerovitch has fixed the problem, that even if there were
//   no changes at all, the editor always thought, there WERE some
//   changes (caused by the use of system-buffers).
//
// * I slightly changed the key-assignment and added some keys.
//   New: keys to open or close all folds with one keystroke, and
//   a key to deactivate the macro (see below)
//
// * I added a function to deactivate the macro now. Before it is
//   deactivated, all folds are opened, so there should be no loss
//   of data.
//
//}}}
//{{{ Copyright
//
// For those, who didn's open the fold "Title" in this source:
// this macro is Copyrighted. For more details see the file
// READ.ME, which should be found in this archive.
//
//}}}

//{{{ Global variables

// Defaults, please change this for your own purposes, if needed

string closedfold[6] = "ÿ..."  // Alt-255 followed by 3 dots
string startfold[6] = "{{{"
string endfold[6] = "}}}"
string startcomment[6] = "%"
string endcomment[6] = ""
integer StartFoldHistory    = 1
integer EndFoldHistory      = 2
integer ClosedFoldHistory   = 3
integer StartCommentHistory = 4
integer EndCommentHistory   = 5

string newclosedfold[6] = ""
string newstartfold[6] = ""
string newendfold[6] = ""
string newstartcomment[6] = ""
string newendcomment[6] = ""
integer FoldCharsChanged = 0

//}}}

//{{{ Function IsClosedFold

// IsClosedFold determines, if the current Cursorline could be
// a closed fold. Returns 1, if yes, else 0.

integer proc IsClosedFold()
    string foldline[6] = ""
    integer result = 0

    foldline = GetText(1,Length(closedfold))
    result = (foldline == closedfold)
    return(result)
end IsClosedFold

//}}}
//{{{ Function IsOpenFold

// IsOpenFold determines, if the current Cursorline could be
// an opened fold. Returns 1, if yes, else 0.

integer proc IsOpenFold()
    string foldline[12] = ""
    integer result = 0
    string openfold[12] = ""

    openfold = startcomment + startfold
    foldline = GetText(1,Length(openfold))
    result = (foldline == openfold)
    return(result)
end IsOpenFold
//}}}
//{{{ Function ConvertString
// ConvertString makes a string useable for Regular expressions, that
// means, should there occur any "special characters" (such as "{" e.g.)
// they are replaced by the appropriate escape-codes (DW)

string proc ConvertString(string temp)

   string s1[80] = ""
   integer i = 0

   i = Length(temp)
   while (i>0)
         case temp[i]
                 when "."
                      s1 = "\." + s1
                 when "^"
                      s1 = "\^" + s1
                 when "$"
                      s1 = "\$"+s1
                 when "\"
                      s1 = "\\"+s1
                 when "|"
                      s1 = "\|"+s1
                 when "?"
                      s1 = "\?"+s1
                 when "["
                      s1 = "\["+s1
                 when "]"
                      s1 = "\]"+s1
                 when "{"
                      s1 = "\{"+s1
                 when "}"
                      s1 = "\}"+s1
                 when "~"
                      s1 = "\~"+s1
                 when "*"
                      s1 = "\*"+s1
                 when "+"
                      s1 = "\+"+s1
                 when "@"
                      s1 = "\@"+s1
                 when "#"
                      s1 = "\#"+s1
                 when '"'
                      s1 = '\"'+s1
                 otherwise
                      s1 = temp[i] + s1
         endcase
         i = i-1
   endwhile
   return(s1)
end ConvertString
//}}}
//{{{ Function GoToStartFold
integer proc GoToStartFold()
/*
  Added by DM

  Definition: to be "within an open fold" is to be on the
  startfold line, on the endfold line, or anywhere in between.

  If we are within an open fold, GoToStartFold() moves the
  cursor to the start of the startfold line and returns TRUE.
  If we are not within an open fold, cursor remains where it is
  and the procedure returns FALSE.
*/

  string searchstring[40]
  string foldsign_start[80]  // dw
  string foldsign_end[80]    // dw
  string temp_start[80]      // dw
  string temp_end[80]        // dw

  PushPosition()
  BegLine() // This ensures that if our original position
            // is on an endfold line, it will not be found
            // in our backwards search (this will make sense
            // with a little study - I haven't the time to
            // make it clearer.)

  // See if we are now on the first line of an open fold:

  temp_start = startcomment + startfold      // dw
  foldsign_start = ConvertString(temp_start) // dw
  temp_end = startcomment + endfold          // dw
  foldsign_end   = ConvertString(temp_end)   // dw
  if (GetText(1, Length(temp_start)) == temp_start) // dw
    // we're on the first line of fold, so:
    KillPosition() return(true)
  endif

  // We're not on the first line of an open fold, so:
  // Look backwards for startfold or endfold.
  // If we encounter endfold before encountering startfold, we
  // know we're not within an open fold.

   searchstring = "^" + "{" + foldsign_start + "}|{" + foldsign_end + "}" // dw
    if Lfind(searchstring, "XB")
      if ( GetText(1, length(temp_start)) == temp_start )
      // startfold is found, so we're within an open fold
        KillPosition() return(true)
      endif
    endif
   // If we reach here we are not within an open fold, so:
   PopPosition()
   return(false)
end GoToStartFold
//}}}
//{{{ Function GetFoldDescription

// GetFoldDescription gets the description of a fold
// (I never would have guessed THAT ;-)

string proc GetFoldDescription()
    string result[100] = ""
    string foldsign_start[100] = ""
    integer desc_start, desc_end
    integer noclose = 0

    if NOT IsClosedFold()
       foldsign_start = startcomment + startfold
       noclose = 1
    else
       foldsign_start = closedfold
       noclose = 0
    endif
    desc_start = Length(foldsign_start) + 2 // BEHIND the space, we start!
    PushPosition()
    EndLine()
    if noclose
       desc_end = CurrPos() - Length(endcomment) - desc_start
    else
       desc_end = CurrPos() - desc_start
    endif
    PopPosition()
    result = GetText(desc_start,desc_end)
    return(result)
end GetFoldDescription

//}}}
//{{{ Procedure MarkFold

// MarkFold marks a complete fold. Does'nt work yet for nested folds

proc MarkFold()
     string findstr[18] = ""

     findstr = startcomment + endfold + endcomment
     PushPosition()
     UnmarkBlock()
     MarkLine()
     BegLine()
     // Endmarks only may appear in column 1
     while (lFind(findstr,"")) and (CurrCol()>1)
           Right()
     endwhile
     MarkLine()
     PopPosition()
end MarkFold

//}}}
//{{{ Procedure OpenFold

// OpenFold opens a closed fold (no, say...). Doesn't work yet
// for nested folds.
// File status is not affected now.

proc OpenFold()
     string description[80] = ""
     integer fold_id = 0
     integer SaveClipboardId = 0
     integer fileIsChanged = 0

     PushBlock()
     if IsClosedFold()
        description = GetFoldDescription()
        SaveClipboardId = Query(ClipBoardId)  // save actual Clipboard
        fold_id = GetBufferId(description)
        if fold_id <> 0
           fileIsChanged = FileChanged() // SAVE CURRENT FILE STATUS
           DelLine()
           if (Query(InsertLineBlocksAbove) == OFF)
              Up() // Necessary because of DelLine, but only, if InsertLineBlocksAbove
                   // is OFF (try it yourself - you will see!)
           endif
           Set(ClipBoardId,fold_id)
           Paste()
           FileChanged(fileIsChanged) // RESTORE FILE STATUS
           Set(ClipBoardId,SaveClipBoardId)
           if (Query(InsertLineBlocksAbove) == OFF)
              Down()       // and back (same reason as above)
           endif
        else
           warn("FATAL: Buffer with this line not more available :-(")
        endif
     else
        warn("WARNING: Line isn't a closed fold!")
     endif
     PopBlock()
end OpenFold

//}}}
//{{{ Procedure CloseFold

// CloseFold closes an open fold (hey, this guy knows what he says ;-) )
// Doesn't work yet for nested folds.
// File status is not affected now.

proc CloseFold()
     string description[80] = ""
     string cl_fold[80] = ""
     integer fold_id = 0
     integer SaveClipboardId = 0
     integer curr_id = 0
     integer fileIsChanged = 0

  //    Added by DM:
     if (not GoToStartFold())
        Message("We are not inside an open fold!!!")
        return()
     endif
  //    End Added by DM
     description = GetFoldDescription()
     PushBlock()
     MarkFold()
     SaveClipboardId = Query(ClipBoardId)   // Save actual Clipboard
     fold_id = GetBufferId(description)
     if fold_id == 0
        curr_id = GetBufferId()
        fold_id = CreateBuffer(description,_SYSTEM_)
        GotoBufferId(curr_id)
     endif
     if fold_id <> 0                          // put away this fold
        Set(ClipBoardId,fold_id)
        fileIsChanged = FileChanged()  // DM: save file status
        Cut()
        Set(ClipBoardId,SaveClipboardId)
        cl_fold = closedfold + " " + description
        InsertLine(cl_fold)
        FileChanged(fileIsChanged)  // DM: restore file status
     else
        Warn("FATAL: fold could not be saved internally!")
     endif
     PopBlock()
end CloseFold

//}}}
//{{{ Procedure CreateFold

// CreateFold... guess yourself :-) It also creates the description
// and all necessary informations.

proc CreateFold()
    string foldsign_start[100] = ""
    string foldsign_end[18] = ""
    string description[80] = ""

    foldsign_end   = startcomment + endfold + endcomment

    Ask("Description for this fold: ", description) // DM: removed history, didn't make sense.

    foldsign_start = startcomment + startfold + " " + description + endcomment
    AddLine(foldsign_start)
    AddLine(foldsign_end)
end CreateFold

//}}}
//{{{ Function ContainsFileFold

// ContainsFileFold determines, whether a loaded file contains a fold
// or not. (YIKES)

integer proc ContainsFileFold()
    integer result = 0
    integer lastline = 0

    BegFile()
    while (not result) and (not lastline)
          result = IsOpenFold()
          lastline = not Down()
    endwhile
    return(result)
end ContainsFileFold

//}}}
//{{{ Function ContainsFileClosedFold

// ContainsFileClosedFold determines, if in the actual file, there
// is any closed fold. The marking of these folds MUST appear
// at the beginning of the line.

integer proc ContainsFileClosedFold()
    integer result = 0
    integer lastline = 0

    BegFile()
    while (not result) and (not lastline)
          result = IsClosedFold()
          lastline = not Down()
    endwhile
    return(result)
end ContainsFileClosedFold

//}}}
//{{{ Function FindNextClosedFold

// FindNextClosedFold searches from within the cursorline down
// to the next closed fold. Attention: if such a fold is found,
// the following Down() must be omitted, else the cursor would be
// on line too far down for opening this fold. Therefor the if-
// construction marked with (1), also in the next procedure!

integer proc FindNextClosedFold()
    integer result = 0
    integer lastline = 0

    while (not result) and (not lastline)
          result = IsClosedFold()
          if not result                    // (1)
             lastline = not Down()
          endif
    endwhile
    return(result)
end FindNextClosedFold

//}}}
//{{{ Function FindNextOpenFold

// FindNextOpenFold searches from within the cursorline until the next
// open fold. For (1), see FindNextClosedFold.

integer proc FindNextOpenFold()
    integer result = 0
    integer lastline = 0

    while (not result) and (not lastline)
          result = IsOpenFold()
          if not result                    // (1)
             lastline = not Down()
          endif
    endwhile
    return(result)
end FindNextOpenFold

//}}}
//{{{ Procedure OpenAllClosedFolds

// OpenAllClosedFolds opens all closed folds, so that the file is
// ready to be saved. MUST be done, because all folds are stored
// in system-buffers, which are NOT saved automatically!

proc OpenAllClosedFolds()
     BegFile()
     while FindNextClosedFold()
        OpenFold()
     endwhile
end OpenAllClosedFolds

//}}}
//{{{ Procedure CloseAllOpenFolds

// CloseAllOpenFolds is called upon first time loading a file:
// contained folds are closed, so that the user directly sees the
// structure of the file.

proc CloseAllOpenFolds()
    BegFile()
    while FindNextOpenFold()
          CloseFold()
    endwhile
end CloseAllOpenFolds

//}}}
//{{{ Procedure mExitAndSave

// mExitAndSave is an extended Exit-procedure, because there could
// be closed folds in the system-buffers. They must be opened before
// saving, otherwise you would have massive Data-loss.

proc mExitAndSave()
    if ContainsFileClosedFold()
       Message("One moment please...")
       OpenAllClosedFolds()
    endif
    Exit()
end mExitAndSave

//}}}
//{{{ Procedure mQuitFile

// mQuitFile replaces QuitFile, because this procedure works only
// for the part you SEE on screen. This can naturally cause heavy
// loss of data, which I hope will be prevented by this procedure here.

proc mQuitFile()
    if ContainsFileClosedFold()
       Message("One moment please...")
       OpenAllClosedFolds()
    endif
    QuitFile()
end mQuitFile

//}}}
//{{{ Prozedur mSaveFile

// mSaveFile replaces SaveFile, because this procedure works only
// for the part you SEE on screen. This can naturally cause heavy
// loss of data, which I hope will be prevented by this procedure here.

proc mSaveFile()
    if ContainsFileClosedFold()
       Message("One moment please...")
       OpenAllClosedFolds()
    endif
    SaveFile()
end mSaveFile

//}}}
//{{{ Prozedur mSaveAndQuitFile

// mSaveAndQuitFile replaces SaveAndQuitFile, because this procedure
// works only for the part you SEE on screen. This can naturally cause
// heavy loss of data, which I hope will be prevented by this
// procedure here.

proc mSaveAndQuitFile()
    if ContainsFileClosedFold()
       Message("One moment please...")
       OpenAllClosedFolds()
    endif
    SaveAndQuitFile()
end mSaveAndQuitFile

//}}}
//{{{ Procedure PrepareLoadedFile

// PrepareLoadedFile checks, if a loaded file contains folds. If yes,
// all folds are closed, so that the structure of the file can be seen.
// Using hooking-technique, this procedure is called every time you
// load a new file.

proc PrepareLoadedFile()
    if ContainsFileFold()
       CloseAllOpenFolds()
    else
       Message("INFO: File doesn't contain folds yet!")
    endif
end PrepareLoadedFile

//}}}
//{{{ Procedure ReadConfigFile

// ReadConfigFile reads an eventually existing Configurationfile.
// What you can see here: normally, the use of macro-instructions
// for reading DOS-Files is not necessary, you can get everything
// as shown here.
// ReadConfigFile is called automatically upon start of macro.
// The configurationfile MUST be named FOLD.CFG.

proc ReadConfigFile()
     EditFile("fold.cfg")
     BegFile()
     lfind("startfold=","")
     startfold = GetText(11,6)
     BegFile()
     lfind("endfold=","")
     endfold = GetText(9,6)
     BegFile()
     lfind("startcomment=","")
     startcomment = GetText(14,6)
     BegFile()
     lfind("endcomment=","")
     endcomment = GetText(12,6)
     BegFile()
     lfind("closedfold=","")
     closedfold = GetText(12,6)
     AbandonFile()
end ReadConfigFile

//}}}
//{{{ Procedure SaveConfigFile

// SaveConfigFile writes a configurationfile to disk (not used yet).
// You could apply this procedure to a special key. In a later version,
// this procedure will be used from within an interactive menu.
// Interesting: the file is built like a LIFO-buffer. This is caused
// by the InsertLine-command.

proc SaveConfigFile()
     integer id

     id = CreateBuffer("fold.cfg")
     if id
        InsertLine("closedfold="+closedfold)
        InsertLine("endcomment="+endcomment)
        InsertLine("startcomment="+startcomment)
        InsertLine("endfold="+endfold)
        InsertLine("startfold="+startfold)
        EraseDiskFile("fold.cfg")
        SaveAs("fold.cfg")
        AbandonFile()
     else
        Warn("WARNING: Couldn't create configuration-file in memory!")
     endif
end SaveConfigFile

//}}}
//{{{ Startup Macro WhenLoaded

// Executed upon start of TSE, but before the commandline is completely
// evaluated and before any file is loaded.

proc WhenLoaded()
        if FileExists("fold.cfg")   // Read configuration, if existing
           ReadConfigFile()
        endif
        AddHistoryStr(startfold,StartFoldHistory)       // Defaults
        AddHistoryStr(endfold,EndFoldHistory)           // for every
        AddHistoryStr(closedfold,ClosedFoldHistory)     // history buffer
        AddHistoryStr(startcomment,StartCommentHistory)
        AddHistoryStr(endcomment,EndCommentHistory)
        Set(Break,ON)
        Hook(_ON_FIRST_EDIT_,PrepareLoadedFile)
end WhenLoaded

//}}}

//{{{ÿProcedure DeactivateMacro

// With DeactivateMacro, the macro fold is fully disabled. But before
// doing this, all folds are opened, so that there is no loss of data.

proc DeactivateMacro()
     Message("The folding macro finishes his work. Live long and prosper!")
     OpenAllClosedFolds()
     PurgeMacro("fold")
end DeactivateMacro

//}}}

//{{{ Startup Macro Main

// Main is executed upon start of macro, but AFTER a file named in the
// command-line is loaded.

proc Main()
        UpdateDisplay()
        BegFile()
        if (ContainsFileFold())
           Message("One moment please, the file contains folds and is prepared...")
           PrepareLoadedFile()
        endif
        Message("TSE is now configured as folding editor! (c) dw 93")
end Main

//}}}

//{{{ Helplines

// Please define the helplines according to your keys!

<HelpLine>        "{F2}-New Line {F6}-Del to End of line {F9}-Shell {F12}-Configuration-Menu"
<Shift HelpLine>  "ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ {Shift: F1}-Draw Boxes       {F12}-Deactivate Macro  ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ"
<Ctrl HelpLine>   "ÛÛÛÛ {Ctrl F3}-all opened ณ{F4}-all closed ณ{F10}-new foldณ {F11}-close ณ {F12}-open ÛÛÛÛÛ"
<Alt HelpLine>    "ÛÛÛÛÛÛÛÛÛÛ {Alt F2}-Help with FOLD.S {F3}-Matching mode {F4}-Lowercase      ÛÛÛÛÛÛÛÛÛÛÛ"

helpdef FoldHelp

     width  = 64
     height = 21
     x = 6
     y = 2
     title  = "Help for the folding macro FOLD.S ฤฤฤ Version 1.31"

     "FOLD.S is a macro, whiche emulates a folding editor ('outliner')"
     "This sort of editor makes large files, which might be"
     "structured, very easy to read and edit."
     "Right now, in version 1.31, it is NOT possible to use nested"
     "folds, as you can expect it from professional outliners."
     "This would be very hard to implement, you could do this only"
     "with tremendous efforts."
     ""
     "Here is a list of keys, which are assigned by the macro as"
     "'factory settings':"
     ""
     "F12       Opens the configuration-menu"
     "ALT   F2  shows you THIS helptext"
     "SHIFT F12 deactivates the macro, after having opened all folds."
     "CTRL  F3  closes all open folds on one keystroke."
     "CTRL  F4  opens all closed folds on one keystroke."
     "CTRL  F10 creates a new fold with description."
     "CTRL  F11 closes the fold, inside which the cursor is placed."
     "CTRL  F12 openes the fold, on which the cursor is placed."
     ""
     "About the configuration-menu"
     "============================"
     ""
     "The configuration will only be saved, if you really have"
     "changed the signs for opened folds, closed folds etc. If you"
     "did NOT do this, there is no reason to save anything, so"
     "this macro won't do it!"
     ""
     "FOLD.S: written and (C) by Dirk Wissmann."
     "        E-Mail: dirk_wissmann @ ac3.maus.de"
     "        Sign in sourcecode if necessary: DW"
     ""
     "        Significant bugfixes and improvements:"
     "                   David Mayerovitch"
     "        E-Mail: david.mayerovitch @ canrem.com"
     "        Sign in sourcecode: DM"
     ""
     "        Additional authors, who worked on bugfixes etc.,"
     "        are listed in the file READ.ME in the archive."
     ""
     "      ีอออออออออออออออออออออออออออออออออออออออออออออออธ         "
     "      ณVersion: 1.31 english of 06.12.1994 for TSE 2.0ณ         "
     "ีอออออออออออออออออออออออออออออออออออออออออออออออออออออฯออออออออธ"
     "ณÛÛฒฒฑฑฐฐ             Have fun with FOLD.S             ฐฐฑฑฒฒÛÛณ"
     "ิออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ"
end FoldHelp

//}}}

//{{{ Menus and their procedures

// ============= GetNewFoldSign =============
// Asks for a new foldsign
proc GetNewFoldsign(string hint,var string foldsign, integer historyNum)
     integer result

     result = Ask(hint,foldsign,historyNum)
     if result <> 0
        FoldCharsChanged = 1
     endif
end GetNewFoldsign

// ============= SetNewFoldSign =============
// Sets a new foldsign
proc SetNewFoldsign(var string name, string sign)
     name = sign
     FoldCharsChanged = 1
end SetNewFoldsign

// ============= GetCommentSigns =============
// Asks for new commentsigns
proc GetCommentSigns(var string anf, var string ende, integer anfhist, integer endhist)
     integer result

     result = Ask("Comment-Start:",anf,anfhist)
     if result <> 0
        FoldCharsChanged = 1
     endif
     result = Ask("Comment-End:",ende,endhist)
     if result <> 0
        FoldCharsChanged = 1
     endif
end GetCommentSigns

// ============= SetCommentSigns =============
// Sets commentsigns
proc SetCommentSigns(var string anf, string sign1, var string ende, string sign2)
    anf = sign1
    ende = sign2
    FoldCharsChanged = 1
end SetCommentSigns

// ============= SaveChanges =============
// Changes the file if necessary, closes all folds, saves the
// configuration if necessary.
proc SaveChanges(integer saveconfig)
     string oldsign[12]
     string newsign[12]

     if (FoldCharsChanged)         // Changes were made
        CloseAllOpenFolds()
        BegFile()
        lReplace(closedfold,newclosedfold,"gn")
        OpenAllClosedFolds()
        BegFile()
        while FindNextOpenFold()
              MarkLine()
              MarkLine()
              oldsign = startcomment+startfold
              newsign = newstartcomment+newstartfold
              lReplace(oldsign,newsign,"ln")
              oldsign = endcomment
              newsign = newendcomment
              if Length(oldsign)==0
                 PushPosition()
                 EndLine()
                 InsertText(newsign,_INSERT_)
                 PopPosition()
              else
                lReplace(oldsign,newsign,"ln")
              endif
              UnmarkBlock()
              Down()
        endwhile
        BegFile()
        oldsign = startcomment+endfold+endcomment
        newsign = newstartcomment+newendfold+newendcomment
        lReplace(oldsign,newsign,"gn")
        CloseAllOpenFolds()
        if saveconfig==1
           SaveConfigFile()
        endif
        closedfold = newclosedfold
        startfold = newstartfold
        endfold = newendfold
        startcomment = newstartcomment
        endcomment = newendcomment
     endif // if (FoldCharsChanged)
end SaveChanges

// ============= Menu StartFoldMenu =============
Menu StartFoldMenu()
     title = "Define the fold-startsign"
     history = 1

     "&Standardsign '{{{'" ,SetNewFoldsign(newstartfold,"{{{"), CloseAfter
     "&Userdefined",GetNewFoldsign("Foldstart:",newstartfold,StartFoldHistory), CloseAfter
end

// ============= Menu EndFoldMenu =============
Menu EndFoldMenu()
     title = "Define the fold-endsign"
     history = 1

     "&Standardsign '}}}'", SetNewFoldsign(newendfold,"}}}"), CloseAfter
     "&Userdefined",GetNewFoldsign("Foldend:",newendfold,EndFoldHistory)           , CloseAfter
end

// ============= Menu ClosedFoldMenu =============
Menu ClosedFoldMenu()
     title = "Define the sign for a closed fold"
     history = 1

     "&Standardsign 'ÿ...'", SetNewFoldsign(newclosedfold,"ÿ..."), CloseAfter
     "&Userdefined",GetNewFoldsign("Closed Fold:",newclosedfold,ClosedFoldHistory), CloseAfter
end

// ============= Menu StartCommentMenu =============
Menu StartCommentMenu()
     title = "Define the signs for comments"
     history = 5

     "&C/C++  '/*' and '*/'" , SetCommentSigns(newstartcomment,"/*",newendcomment,"*/"), CloseAfter
     "&Pascal '(*' and '*)'" , SetCommentSigns(newstartcomment,"(*",newendcomment,"*)"), CloseAfter
     "P&ascal '{'  and '}'"  , SetCommentSigns(newstartcomment,"{",newendcomment,"}"), CloseAfter
     "&TeX    '%'  and empty" , SetCommentSigns(newstartcomment,"%",newendcomment,""), CloseAfter
     "TS&E/C++ '//' and empty", SetCommentSigns(newstartcomment,"//",newendcomment,""), CloseAfter
     "&Userdefined", GetCommentSigns(newstartcomment,newendcomment,StartCommentHistory,EndCommentHistory), CloseAfter
end

// ============= Menu ConfigureMenu =============
Menu ConfigureMenu()               // Main-configuration-menu for FOLD.S
     title = "Configuration-Menu for FOLD"
     x = 10
     y = 3
     width = 55
     history
     NoEscape

     "Fold-&Startsign"       [newstartfold:6]   ,StartFoldMenu()   , DontClose, "Definition of the sign for the begin of an open fold"
     "Fold-&Endsign"         [newendfold:6]     ,EndFoldMenu()     , DontClose, "Definition of the sign for the end of an open fold"
     "Sign for &closed fold" [newclosedfold:6]  ,ClosedFoldMenu()  , DontClose, "Definition of the sign for a closed fold"
     ""                                                ,                  , Divide
     "C&omment-signs" ["'"+newstartcomment+"' and '"+newendcomment+"'":22],StartCommentMenu(), DontClose, "Definition of the comment-signs to use"
     ""                                                ,                  , Divide
     "S&ave configuration"                          ,SaveConfigFile()  , DontClose, "If signs are changed: Write configuration to disk, do NOT leave this menu"
     "&Read configuration"                            ,ReadConfigFile()  , DontClose, "Read configuration from disk, do NOT leave this menu"
     ""                                                ,                  , Divide
     "Save configuration, e&xit this menu"          ,SaveChanges(1)    , CloseAfter, "If signs are changed: Write configuration to disk, return to the Editor"
     "Do NOT save configuration, &quit this menu"    ,SaveChanges(0)    , CloseAfter, "Return to the editor WITHOUT writing the configuration to disk"
end

// ============= DoConfiguration =============
proc DoConfiguration()
     newstartfold = startfold
     newendfold = endfold
     newclosedfold = closedfold
     newstartcomment = startcomment
     newendcomment = endcomment
     ConfigureMenu()
     if FoldCharsChanged == 1
        Warn("Configuration changed but NOT saved!!!")
     endif
end DoConfiguration
//}}}

//{{{ Keydefinitions

// Keydefinitions for testing purposes.
// Please change them following your own wishes.
// I recommend the redefinition of Alt-x, and perhaps the new definition
// of Ctrl F11 und Ctrl F12.

<Ctrl F3>      CloseAllOpenFolds()
<Ctrl F4>      OpenAllClosedFolds()
<Ctrl F6>      SaveConfigFile()
<Ctrl F8>      ReadConfigFile()
<Alt x>        mExitAndSave()
<Ctrl F10>     CreateFold()
<Ctrl F11>     CloseFold()
<Ctrl F12>     OpenFold()
<Alt F2>       QuickHelp(FoldHelp)
<Shift F12>    DeactivateMacro()
<F12>          DoConfiguration()

// necessary new assignments

<Ctrl k><q>          mQuitFile() CloseWindow()
<Ctrl k><d>          mQuitFile() CloseWindow()
<Ctrl k><s>          mSaveFile()
<Ctrl k><x>          mSaveAndQuitFile()

//}}}

