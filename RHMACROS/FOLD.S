/***********************
            …ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª
            ∫ KEYS:  MENU  <ALT '>  ∫
            »ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº
Author: Dirk Wissmann, Germany.  (See Read.me file for more info)
THIS FILE IS NOW UPDATED FOR TSE VERSION 2.0 !!!
Thanks to: ROB HOWSE,  SASKATOON, SK. (CANADA)  DEC 22, 1994

//{{{ Improvements added by Rob Howse, Dec 94

1. !!!!!!!!!!!!!!!!  Added a MENU  !!!!!!!!!!!!!!!!!!

2. Added PushPosition and PopPosition to several routines to *TRY* to stay in
   a more constant position in file when opening or closing all folds.

3. For an extra margin of safety, I've made the WhenLoaded macro turn
   MAKEBACKUPS on, regardless of current setting.  The WhenPurged macro
   restores the users previous setting.

4. Copied some of the commands in the Main macro to the WhenLoaded macro to
   have `Folding' effective immediately upon loading.

5. Reworded some messages and warnings to (hopefully) be more meaningful.

//}}}
//{{{ CAUTIONS(!) From Rob Howse:

1.  If you read the author's comments contained herein, you will understand
    that if a file is saved while folds are closed ALL INFORMATION INSIDE
    THE FOLDS WILL BE LOST!  Therefore, special Save, Quit and Exit routines
    are needed that will open all folds before saving. These routines are
    contained herein, and should be bound to your normal 'Save', 'Quit' and
    'Exit' Keys while FOLDING.MAC is loaded. (See key bindings at the end of
    this file.)  It is important you set these keys to your own particular
    normal TSE arrangement.

2.  Even after following the above advice, you should NOT USE THE MAIN TSE
    FILE *MENU* for any Save, Quit or Exit procedures on a 'Folded' file
    since the main TSE Menu Commands will not call the special routines
    contained in this file.  (Note that you CAN use the Fold Menu and you
    CAN use TSE's Menu safely for all other features except Saving, Quiting
    or Exiting.  It would also be safe to use it for these things too
    providing you open all folds first.  Also, don't confuse TSE's menu with
    the Fold Menu.  The Fold Menu is safe for all purposes.

3.  To deactivate 'folding', use the 'Deactivate' option from the Fold Menu.
    This option automatically opens all folds before purging.  (If you were
    to Purge 'Fold' first and subsequently save file with any closed folds,
    again all info inside the fold would be lost.

4.  IF you disregard (or forget!) some of the above advice, and get stuck
    with a flashing "ERROR!  (Unable to open one or more folds...)
    Press <Escape>", you can 'get out' by pressing CTRL-BREAK followed by
    <Escape>.  Answer TERMINATE at the prompt.  Then look for remaining
    closed folds ( ... description ).  If only one or two, you may be able
    to delete them and then save the rest of the file.  Otherwise, use the
    TSE File Menu to Exit.  If you answer "NO" to Save Changes?,  with a
    little luck, you may get your file back as it was since it was last
    saved.  The worst scenerio would be that you have lost any information
    that was inside of the 'folds'.  If you find this is indeed the case,
    look for the 'backup' file.  (Extension will be whatever you have
    configured TSE to use as standard backup extension.) Since I HAVE SET UP
    'FOLD' TO AUTOMATICALLY TURN BACKUPS ON whatever your standard TSE
    setting is (and restore your setting when 'Fold' is deactivated),  you
    *SHOULD* have a backup file!

5.  DON'T USE DUPLICATE FOLD NAMES!  (Or contents of the first fold will be
    lost)  (See Author's comments)

6.  DON'T BE SCARED OFF!!  If you observe the above precautions, you will be
    well on your way to enjoying safe folding!      --Rbh  Dec 94
//}}}
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
//{{{ Title
 FOLD.S         Macro for TSE as folding editor

 Version: 1.1 english / 06.08.1993

 Copyright (C) 1993 by Dirk Wissmann

 Bugfixes / Additional help:

 David Mayerovitch (file-status-bug)
    E-Mail: david.mayerovitch@canrem.com

//}}}
//{{{ About The Author: Dirk Wissmann

... is student in Aachen, Germany (computer science)
and can be reached as follows:

1. via Semware BBS in conference TSE questions by public mail.
I will receive this mail through a link into the German TSE Jr. support BBS
appr. once a month.

2. via InterNet/UseNet:  dirk @ pool.informatik.rwth-aachen.de

3. Snail Mail:   Dirk Wissmann
                 Pley 39
                 D-52146 Wuerselen
                 GERMANY
//}}}
//{{{ Introduction

 Open this SourceFile with FOLD.MAC loaded and you will see what
 'folding' is able to do. The 'folding' structure is fairly obvious...

 Closed folds are marked by three POINTS followed by a brief
 description. Opening them is done by the procedure OpenFold.
 Open folds are marked by user-defined character-strings.

 CAUTION: Please don't use the character "." (Ascii 46) inside the
 description of any fold - it only causes much much trouble.

//}}}
//{{{ Known Bugs

 Known Bugs in version 1.1:

 IF YOU LOAD A NEW FILE, WHERE ONE OR MORE FOLDS HAVE THE IDENTICAL
 DESCRIPTION AS IN AN ALREADY LOADED FILE, THE CONTENTS OF THE FOLD
 OF THE ALREADY LOADED FILE ARE COMPLETELY LOST WITHOUT A CHANCE OF
 RESTORING! So far, I don't have any idea how to prevent this.

 OpenAllClosedFolds DOESN'T WORK PROPERLY WHEN A FOLD IS PLACED IN
 THE TOPMOST COLUMN (column 1 thus). There is no data lost, but it
 is possible, that this fold is placed at a random place inside the
 text.

 There is no protection for the folding-lines.  Don't edit the descriptions
 while the fold is closed.  And if you delete the start line of a fold, be
 sure to delete the matching end line.

 Nested folds are not possible.

Anybody programming e.g. in Pascal instead of
TSE-Macros should change the comment-characters as follows:
 startcomment=(*
 endcomment=*)
//}}}
***************************/
//{{{ Global variables

string closedfold[6] = "ˇ..."  // Alt-255 followed by 3 dots
string startfold[6] = "{{{"
string endfold[6] = "}}}"
string startcomment[6] = "//"
string endcomment[6] = ""
integer create_history_num = 1

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
  when "."    s1 = "\." + s1
  when "^"    s1 = "\^" + s1
  when "$"    s1 = "\$"+s1
  when "\"    s1 = "\\"+s1
  when "|"    s1 = "\|"+s1
  when "?"    s1 = "\?"+s1
  when "["    s1 = "\["+s1
  when "]"    s1 = "\]"+s1
  when "{"    s1 = "\{"+s1
  when "}"    s1 = "\}"+s1
  when "~"    s1 = "\~"+s1
  when "*"    s1 = "\*"+s1
  when "+"    s1 = "\+"+s1
  when "@"    s1 = "\@"+s1
  when "#"    s1 = "\#"+s1
  when '"'    s1 = '\"'+s1
  otherwise   s1 = temp[i] + s1
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

// MarkFold marks a complete fold.

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

// File status is not affected.

proc OpenFold()
     string description[80] = ""
     integer fold_id = 0
     integer SaveClipboardId = 0
     integer Changed = 0

     PushBlock()
     if IsClosedFold()
        description = GetFoldDescription()
        SaveClipboardId = Query(ClipBoardId)  // save actual Clipboard
        fold_id = GetBufferId(description)
        if fold_id <> 0
           Changed = FileChanged() // SAVE CURRENT FILE STATUS
           DelLine()
           if (Query(InsertLineBlocksAbove) == OFF)
              Up() // Necessary because of DelLine, but only, if InsertLineBlocksAbove
                   // is OFF (try it yourself - you will see!)
           endif
           Set(ClipBoardId, fold_id)
           Paste()
           FileChanged(Changed) // RESTORE FILE STATUS
           Set(ClipBoardId, SaveClipBoardId)
           if (Query(InsertLineBlocksAbove) == OFF)
              Down()       // and back (same reason as above)
           endif
        else
          warn("ERROR!  (Unable to open one or more folds...)")
        endif
     else
        Message("Can't open a line that isn't a closed fold!")
     endif
     PopBlock()
end OpenFold

//}}}
//{{{ Procedure CloseFold

// File status is not affected.

proc CloseFold()
     string description[80] = ""
     string cl_fold[80] = ""
     integer fold_id = 0
     integer SaveClipboardId = 0
     integer curr_id = 0
     integer Changed = 0
     if (not GoToStartFold())
        Message("We are not inside an open fold!!!")
        return()
     endif
        description = GetFoldDescription()
        PushBlock()
        MarkFold()
        SaveClipboardId = Query(ClipBoardId)   // save actual Clipboard
        fold_id = GetBufferId(description)
        if fold_id == 0
           curr_id = GetBufferId()
           fold_id = CreateBuffer(description,_SYSTEM_)
           GotoBufferId(curr_id)
        endif
        if fold_id <> 0                          // put away this fold
           Set(ClipBoardId, fold_id)
        Changed = FileChanged()  // DM: save file status
           Cut()
           Set(ClipBoardId, SaveClipboardId)
           cl_fold = closedfold + " " + description
           InsertLine(cl_fold)
           FileChanged(Changed) // RESTORE FILE STATUS
        else
           Warn("FATAL: fold could not be saved internally!")
//      else
//        Message("Current Line is not start of a fold...") --Rbh
        endif
        PopBlock()
end CloseFold

//}}}
//{{{ Procedure CreateFold

// CreateFold creates the description and all necessary information.

proc CreateFold()
    string foldsign_start[100] = ""
    string foldsign_end[18] = ""
    string description[80] = ""

    foldsign_end   = startcomment + endfold + endcomment
    Message("Reminder:  Don't repeat any previous description!!")
    Ask("Description for this fold: ", description, create_history_num)
    foldsign_start = startcomment + startfold + " " + description + endcomment
    AddLine(foldsign_start)
    AddLine()
    AddLine(foldsign_end)
    Up()  BegLine()
end CreateFold

//}}}
//{{{ Function ContainsFileFold

// ContainsFileFold determines, whether a loaded file contains a fold

integer proc ContainsFileFold()
    integer result = 0
    integer lastline = 0

    PushPosition()
    BegFile()
    while (not result) and (not lastline)
          result = IsOpenFold()
          lastline = not Down()
    endwhile
    PopPosition()
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

    PushPosition()
    BegFile()
    while (not result) and (not lastline)
          result = IsClosedFold()
          lastline = not Down()
    endwhile
    PopPosition()
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
// ready to be saved. MUST BE DONE, BECAUSE ALL FOLDS ARE STORED
// IN SYSTEM-BUFFERS, WHICH ARE ***NOT SAVED*** AUTOMATICALLY!

proc OpenAllClosedFolds()
     PushPosition()
     BegFile()
     while FindNextClosedFold()
        OpenFold()
     endwhile
     PopPosition()
end OpenAllClosedFolds

//}}}
//{{{ Procedure CloseAllOpenFolds

// CloseAllOpenFolds is called upon first time loading a file:
// contained folds are closed, so that the user directly sees the
// structure of the file.

proc CloseAllOpenFolds()
    PushPosition()
    BegFile()
    while FindNextOpenFold()
          CloseFold()
    endwhile
    PopPosition()
end CloseAllOpenFolds

//}}}
//{{{ Procedure mExitAndSave

// mExitAndSave is an extended Exit-procedure, because there could
// be closed folds in the system-buffers. THEY MUST BE OPENED BEFORE
// SAVING, OTHERWISE ALL INFO IN THE FOLDS WILL BE LOST! (ie otherwise file
//will be saved EXACTLY AS SHOWN ON SCREEN.

proc mExitAndSave()
    if ContainsFileClosedFold()
       Message("One moment please...")
       OpenAllClosedFolds()
     endif
    Exit()
end mExitAndSave

//}}}
//{{{ Procedure mQuitFile

// mQuitFile replaces QuitFile. See comment for mExitAndSave
proc mQuitFile()
    if ContainsFileClosedFold()
       Message("One moment please...")
       OpenAllClosedFolds()
     endif
    QuitFile()
end mQuitFile

//}}}
//{{{ Procedure mSaveFile
// mSaveFile replaces SaveFile. See comment for mExitAndSave

proc mSaveFile()
    PushPosition()
    if ContainsFileClosedFold()
       Message("One moment please...")
       OpenAllClosedFolds()
    endif
    PopPosition()
    SaveFile()
end mSaveFile

//}}}
//{{{ Procedure mSaveAndQuitFile
// mSaveAndQuitFile replaces SaveAndQuitFile. See comment for mExitAndSave

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
       Message("FYI:   No folds contained in this file.")
    endif
end PrepareLoadedFile
//}}}
//{{{ˇProcedure DeactivateMacro

// With DeactivateMacro, the macro fold is fully disabled.
// Before doing this, all folds are opened, so that there is no loss of data.

proc DeactivateMacro()
     PushPosition()
     Message("All 'Folds' are left Open when FOLD is deactivated.")
     OpenAllClosedFolds()
     PurgeMacro("fold")
     PopPosition()
end DeactivateMacro
//}}}

//{{{ MENU! (Added by Rob Howse, Saskatoon, SK Canada  Dec 22, 1994)
Menu FoldMenu()
  Title = "`Folding' Menu  < Alt ' >"
  x = 44
  y = 3
  history
  "&Open Fold"           , OpenFold()
  "&CloseFold"           , CloseFold()
  "Create &Fold"         , CreateFold()
  "O&pen All Folds"      , OpenAllClosedFolds()
  "C&lose All Folds"     , CloseAllOpenFolds()
  "&SaveFile"            , mSaveFile()
  "Close F&ile"          , mQuitFile()
  "Save and &Quit File"  , mSaveAndQuitFile()
  "Save and &Exit"       , mExitAndSave()
  "&Deactivate Folding"  , DeactivateMacro()
end
//}}}
//{{{ Startup Macro WhenLoaded

// Executed upon start of FOLD

integer backup = 0

proc WhenLoaded()
     backup = Query(MAKEBACKUPS)
     set(MakeBackups, ON)  //for more safety with folded files
        Set(Break,ON)
        Hook(_ON_FIRST_EDIT_,PrepareLoadedFile)
        UpdateDisplay()
        BegFile()
        if (ContainsFileFold())
           PrepareLoadedFile()
        endif
end WhenLoaded

//}}}
//{{{ Startup Macro (Main)

// Main is executed upon start of macro, but AFTER a file named in the
// command-line is loaded.

proc Main()   //statements moved to Whenloaded
        UpdateDisplay()
        BegFile()
        if (ContainsFileFold())
           PrepareLoadedFile()
        endif
        Message("TSE is now configured as folding editor!  <ALT-'> for Menu:")
        FoldMenu()
end Main
//}}}
//{{{ WhenPurged Macro
proc WhenPurged()
        Set(MakeBackUps, backup)  //restore prev state
end
//}}}
//{{{ Keydefinitions

<Alt '>        FoldMenu()
<Ctrl F> <C>   CloseFold()
<Ctrl F> <O>   OpenFold()
<Ctrl F> <R>   CreateFold()
<Ctrl F> <D>   DeactivateMacro()
<Ctrl F> <X>   mSaveAndQuitFile()
<F7>           mQuitFile()
<F10>          mSaveFile()
<Alt X>        mExitAndSave()
//}}}
