/*
Program....: qfmsg.inc
Version....: 3.5
Author.....: Randy Wallin & Ryan Katri
Date.......: 08/03/93  10:17 pm  Last Modified: 08/30/95 @ 08:10 am
Notice.....: Copyright 1993 COB System Designs, Inc., All Rights Reserved.
QFRestore..: Ø1,1Æ
Compiler...: TSE 2.5
Abstract...: Displays a message - used instead of Warn or Message.
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

/*
  This is a small routine - to replace message and warn with a popup window
  To call:
       QFMessage(cMessage,nTimeout,nSound)
  The parameters are as follows
  cMessage = Text to be displayed.
  nTimeout = How long do I keep this thing displayed?
  nSound = Make a sound.
*/
proc QFMessage(string cMessage, integer nTimeOut, integer nSound)

   integer nMessageLen=Length(cMessage)  ,
           nUpperLeft= query(screencols) - (nMessageLen + iif(nTimeout,8,5)),
           nUpperRight= query(screencols)-2
   if nSound
      Sound(500, 2)
      Sound(250, 1)
   endif // nSound

   nTimeout = nTimeout * 18
   popwinopen(nUpperLeft, 3, nUpperRight, 5, 4, "QF Message", query(otherwinborderattr))
   clrscr()
   set(cursor, off)
   clrscr()
   VGoToXY(2,1)
   PutLine(cMessage, length(cMessage))

   while  (keypressed() == FALSE)
         if nTimeout
            VGoToXY(2,1)
            if (nTimeout mod 18) == 0
               PutLine(cMessage + format(nTimeout/18:3:"."), length(cMessage) + 3)
            endif
            delay(1)
            nTimeout = nTimeout - 1
            if nTimeout==0
               PushKey(32)
            endif // nTimeout==0
         endif // nTimeout
   endwhile // (keypressed())
   getkey()
   set(cursor, on)
   popwinclose()

end QFMessage
