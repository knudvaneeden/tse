/*
Program....: qftags.inc
Version....: 3.5
Author.....: Randy Wallin & Ryan Katri
Date.......: 07/28/93  07:47 am  Last Modified: 08/30/95 @ 08:10 am
Notice.....: Copyright 1993 COB System Designs, Inc., All Rights Reserved.
QFRestore..: Ø1,1Æ
Compiler...: TSE 2.5
Abstract...: Tags/untag routines for a list mainted by QFPopList().
             Assumes that filenames start at column 4, and tag markers
             are at column 2.
Changes....:

€ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€
€ This program is a part of a series of macros written by COB System Designs€
€ for TSE/*Base users...these are not public domain but are for sale at a   €
€ reasonable price of $69.00. Please support the work involved in writing   €
€ these programs.                                                           €
€ For sales information and technical support, call SEMWARE Corporation:    €
€                                                                           €
€ MAIL: SemWare Corporation               FAX: (770) 640-6213               €
€       730 Elk Cove Court                                                  €
€       Kennesaw, GA  30152-4047  USA                                       €
€                                         InterNet: sales@semware.com       €
€                                                   qf.support@semware.com  €
€ PHONE (SALES ONLY): (800) 467-3692      OTHER VOICE CALLS: (770) 641-9002 €
€          Inside USA, 9am-5pm ET                              9am-5pm ET   €
€‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹€
*/


constant
   TAG_TOGGLE = 0,
   TAG_TAGALL = 1,
   TAG_UNTAGALL = 2,
   TAG_TAG = 3,
   TAG_UNTAG = 4,
   TAG_REVERSE = 5

// Tag a field name
proc QFTag( integer TagType )
   string cLine[12]
   PushPosition()

   cLine = GetText(4, 12)
   case TagType
      when TAG_TOGGLE      // toggle tag on current file
         GotoPos(2)
         if substr(cLine, 1, 1) <> "\" and length(cLine)
            InsertText( iif(isWhite(), "˚", " "), _OVERWRITE_)
         endif
         PushKey(<CursorDown>)
      when TAG_TAGALL, TAG_UNTAGALL    // tag/untag all (1 = tag, 2 = untag)
         BegFile()
         repeat
            cLine = GetText(4, 12)
            GotoPos(2)
            if substr(cLine, 1, 1) <> "\" and length(cLine)
               InsertText( iif( TagType == 1, "˚", " "), _OVERWRITE_)
            endif
         until not down()
      when TAG_TAG      // tag current file
         GotoPos(2)
         InsertText("˚", _OVERWRITE_)
      when TAG_UNTAG      // untag current file
         GotoPos(2)
         InsertText(" ", _OVERWRITE_)
      when TAG_REVERSE      // toggle tag on all files (reverse tag)
         BegFile()
         repeat
            cLine = GetText(4, 40)
            GotoPos(2)
            if substr(cLine, 1, 1) <> "\" and length(cLine)
               InsertText( iif( GetText(2, 1) == " ", "˚", " "), _OVERWRITE_)
            endif
         until not down()

   endcase

   PopPosition()

end QFTag


integer proc QFFilesTagged()
   integer lFound
   PushPosition()
   lFound = lFind("˚", "gq")
   PopPosition()
   return (lFound)
end QFFilesTagged

