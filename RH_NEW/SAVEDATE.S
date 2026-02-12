/***
SAVEDATE.S

OVERVIEW:
Have you ever wanted to edit a file on disk, but have the original date
retained when you save it?  (For example, a 'Doc' file for a program or
utility that you want to retain the same date as the program...)  Of course,
if you have a 'file dater' like Norton Utilities FD, you can take note of
the original file date and redate the file manually afterwards, but wouldn't
it be nice if you could simply load a file that, while loaded, would look
after it automatically?  SAVEDATE will do exactly that!

If you decide you'd rather not restore the original date of a particular
file, just press <Escape> at the "fd..." prompt for that particular file.
When you no longer want to retain original dates for any more files, simply
purge SAVEDATE to return to normal operation.


NOTES:  To work, you must have a 'file dater' utility in your path.  If named
differently than FD, modify "fd" in the following code accordingly, then
recompile.  I have assigned this to my usual `QuitFile' key, <F7>, and my
`Exit' <Alt X>.  To choose a different key, simply change the <Key> at the
end of this file and recompile.  SAVEDATE also assumes you have FIND.EXE in
C:\DOS.  Change path if necessary.

Also note that SAVEDATE only offers to restore original dates on files that
are marked as being *changed*.  Thus, if you issue a SaveFile command, you
need to make at least one small change (eg. add a space and delete it again)
to remark it changed from the version on disk if you want to save the
original date.

If you are editing multiple files with the same rootname but differing
extensions, SAVEDATE will save all with the date of the first file with
rootname.  If this isn't acceptable, you may have to manually redate the
files.  (If you are using NDOS or 4DOS, this restriction doesn't apply.
Either of these vastly superior replacements to COMMAND.COM can optionally
put out an unjustified `dir' output that includes the `dot' and no spaces.
If using either of these, just `uncomment' the two seperate lines
preceding "//(NDOS & 4DOS " and `comment out' the two lines following, and
recompile.)

Finally, note that SAVEDATE shows you that each file has been successfully
redated and prompts you to press a key to continue.  If you want all this to
happen automatically in the background, just `uncomment' the two seperate
lines preceding "//(Automatic..." and `comment out' the two lines ( "Dos()" )
following, and recompile.)



created: Jan 11, 1995
author: Rob Howse, Saskatoon, SK (CAN)
***/

string origdate[8] = ""
string origtime[6] = ""
string fullname[65] = ""
string filename[13] = ""
string rootname[8] = ""
integer curr_id, temp_id

proc mStorOrigDate()
    if FileExists(CurrFileName())
       curr_id = GetBufferId()
//       Dos('*Dir '+CurrFileName()+'|c:\dos\find "-" >D:\tsetmp', _DONT_CLEAR_)
//(NDOS & 4DOS    DOS COMMAND.COM )
       Dos('Dir '+CurrFileName()+'|c:\dos\find "-" >D:\tsetmp', _DONT_CLEAR_)
       GotoBufferId(temp_id)
       EndFile()  BegLine()
       InsertFile("D:\tsetmp")
       GotoBufferId(curr_id)
    endif
end

proc mSavWitOrigDate()
    curr_id = GetBufferId()
    fullname = CurrFileName()
    filename = SplitPath(CurrFileName(), _NAME_|_EXT_)
    rootname = SplitPath(CurrFileName(), _NAME_)
    if FileExists(fullname) AND FileChanged()
       GotoBufferId(temp_id)
//       if LFind(filename, "igw")
//(NDOS & 4DOS    DOS COMMAND.COM )
       if LFind(rootname, "igw")
       BegLine()
       origdate = Trim(GetText(24, 31))
       origtime = Trim(GetText(33, 38))
       AddHistoryStr('fd '+Upper(fullname)+' /d:'+origdate+'/t:'+origtime, _DOS_HISTORY_)
       else Warn("Original Date & Time Not Found")
       endif
       GotoBufferId(curr_id)
       if Numfiles() == 1
       case YesNo("Save  "+Upper(filename)+"  with original date before exiting editor?")
       when 0, 3   //Esc or Cancel
       return()
       when 1      //yes selected
       SaveFile()
//       Dos('fd '+filename+'/d:'+origdate+' /t:'+origtime, _DONT_CLEAR_)
//(Automatic    To see what's happening & be able to <ESC> if desired...  )
       Dos()
       AbandonFile()
       goto quit_TSE
       endcase
       endif
       if QuitFile()
//       Dos('fd '+filename+'/d:'+origdate+' /t:'+origtime, _DONT_CLEAR_)
//(Automatic    To see what's happening & be able to <ESC> if desired...  )
       Dos()
       endif
    else QuitFile()
    endif
  quit_TSE:
end

proc WhenLoaded()
     curr_id = GetBufferId()
     temp_id = CreateTempBuffer()
     GotoBufferId(curr_id)
     Hook(_ON_FIRST_EDIT_, mStorOrigDate)
     if Numfiles() < 1   //initial startup, files not loaded yet
     Warn("Execute SAVEDATE once to save orig date of first file")
     else mStorOrigDate()
     endif
end

proc Main()
     mStorOrigDate()  //store stats for first file
     Message("Edited files may now be saved with their original diskfile Date.")
end

<F7>    mSavWitOrigDate()
<Alt X> mSavWitOrigDate()
