/*
Program....: QFAllSav.INC
Version....: 3.5
Author.....: Randy Wallin & Ryan Katri
Date.......: 08/03/93  07:52 am  Last Modified: 08/30/95 @ 08:10 am
Notice.....: Copyright 1993 COB System Designs, Inc., All Rights Reserved.
QFRestore..: ¯16,1®
Compiler...: TSE 2.5
Abstract...: QFAllSav writes all modified files only.  Additionally, we can
             use this function to check how many files are modified prior
             to exiting to DOS.
Changes....:
ÛßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßÛ
Û This program is a part of a series of macros written by COB System DesignsÛ
Û for TSE/*Base users...these are not public domain but are for sale at a   Û
Û reasonable price of $69.00. Please support the work involved in writing   Û
Û these programs.                                                           Û
Û For sales information and technical support, call SEMWARE Corporation:    Û
Û                                                                           Û
Û MAIL: SemWare Corporation               FAX: (770) 640-6213               Û
Û       730 Elk Cove Court                                                  Û
Û       Kennesaw, GA  30152-4047  USA                                       Û
Û                                         InterNet: sales@semware.com       Û
Û                                                   qf.support@semware.com  Û
Û PHONE (SALES ONLY): (800) 467-3692      OTHER VOICE CALLS: (770) 641-9002 Û
Û          Inside USA, 9am-5pm ET                              9am-5pm ET   Û
ÛÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÛ
*/
menu YesNoOnly()  // no cancel
       "&Yes"
       "&No"
end YesNoOnly



// nSave will be true only when we want to force the modified files to
// be saved.
// nSave as False will return # of modified files to calling program
//   integer nModified
//   nModified=QFQuickSave(FALSE)
//   if nModified AND YesNoOnly("Save "+ltrim(format(nModified : 3))+" Modified Files, Save? ")==1
//      QFQuickSave(TRUE)
//   endif // nModified

integer proc QFQuickSave(integer nSave)
   integer n=0,
           nWrote=0,
           nBufferID=GetBufferID()
//   string cFilename[40] = CurrFilename()

//   RemoveUnloadedFiles()
   nWrote=0
   n = NumFiles()
   if BufferType() == _SYSTEM_
      NextFile()
   endif

   while n
      Message("Checking ", CurrFileName())
      if FileChanged()
         if nSave
            Message("Saving...", CurrFileName())
            SaveFile()
         endif // nSave
         nWrote = nWrote + 1
      endif
      nextfile()
      n = n - 1
   endwhile

   GotoBufferId(nBufferID)
   // editfile(cFilename)
   if nSave
      if nWrote > 0
         message(format(nWrote : 3)+ " "+ iif(nWrote>1,"Files","File")+" Saved.")
      else
         message("No files altered.  None written to disk.")
      endif
      // redeclare nWrote so we don't force a modified question in the calling macro.
      nWrote=0
   else
      // null message to clear status line and then refresh screen.
      message("")
      UpdateDisplay()
   endif // nSave

   Return( nWrote )
end QFQuickSave

