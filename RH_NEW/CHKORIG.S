/*****************************************************
   CHKORIG    by Rob Howse, Saskatoon, SK (CAN) DEC 94

Overview: Check current file being edited against most recently saved
          version on disk. (ie the 'Original')
          Really just a small (but handy!) variation on the EXCELLENT
          CMP2BKUP file comparison utility by IAN CAMPBELL

Word of Explanation:

Sometimes when I am about to exit or quit from a file Ive been editing, and
I'm being asked "Save Changes? ", I feel like answering (tongue-in-cheek)
"Well I'm not sure.  Let me see the changes first!!!"  This little macro
allows you to do exactly that!  It first changes the Current File Name to
the same 'root' name with extension ".xyz".  Then it calls TSE's excellent
CMP2BKUP macro and automatically presents the original filename as the
backup file to compare to.  (This assumes that the current file actually
does exist on disk.  If it didn't, there would be no point in calling
CMP2BKUP, would there?!)

Once in CMP2BKUP, you can get extra help on how to hi-lite differences by
pressing F1. Finally, when you escape from CMP2BKUP, you are prompted as to
whether you want to change the "xyz" file back to it's original name.
(Even though the prompt says "Overlay existing file?", nothing is actually
overwritten at this point even by answering Yes.  Answering Yes merely
changes the current filename (in memory) back to its original extension.)

If you decide you DO want to save the file and update the file on disk,
answer 'Yes' and then Save, Quit or Exit, answering (without hesitation
now!) a definite 'Yes' to the familiar "Save Changes? " prompt.

If you decide you don't want to overwrite the file on disk, you can keep the
"xyz" name and save with that name, and/or continue editing or simply
discard the new version you've worked so hard on (and apparently 'screwed
up'!) by choosing quit or exit and answering "No" to "Save Changes? ".
*******************************************************/

proc mCompareCurrFile2DiskFile()
    string origname[40] = CurrFileName()
    case YesNo("Compare edited  `"+CurrFileName()+"'  to same file on disk? ")
        when 0, 2, 3  //Esc, No or Cancel
        return()
    endcase
    ChangeCurrFileName(SplitPath(CurrFileName(), _NAME_)+".XYZ")
    UpDateDisplay()
    Message("Current edited FileName has been temporarily changed to ` .xyz' (for comparison)")
    BegFile()
    AddHistoryStr(origname, 114)  //so cursor down gives diskfile name
    Pushkey(<Enter>)
    Pushkey(<CursorDown>)
    Pushkey(<CursorDown>)
    ExecMacro("Cmp2BkUp")
    Message("Change "+CurrFileName()+" back to "+origname+"? (y/n/c  or <Esc> )")
    ChangeCurrFileName(origname)
    UpDateDisplay()
end

/*if you wish, you can include the above proc in your UI file and assign it
  to a key.  In that case, remove the 'main' below  */

Proc main()
        mCompareCurrFile2DiskFile()
        PurgeMacro("Chkorig")
end
