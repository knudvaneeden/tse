/*
Program....: qfbyte.inc
Version....: 3.5
Author.....: Randy Wallin & Ryan Katri
Date.......: 05/19/95  12:35 am  Last Modified: 08/30/95 @ 08:10 am
Notice.....: Copyright 1995 COB System Designs, Inc., All Rights Reserved.
QFRestore..: Ø1,1Æ
Compiler...: TSE v2.50
Abstract...: QFByte Contains all of our binary manipulation macros.
Abstract...:
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

// *
// * cData = data to be read and convert back to Decimal.
integer proc ReadByte(string cData)
   integer nNumber = 0,
           nReadLength = Length(cData)
   case str(nReadLength)
        when "4"
           nNumber = (asc ( substr (cData, 4, 1)) shl + 24) +
           (asc ( substr (cData, 3, 1)) shl + 16) +
           (asc ( substr (cData, 2, 1)) shl + 8 ) + asc ( substr (cData, 1, 1))
        when "3"
           nNumber =  (asc ( substr (cData, 3, 1)) shl + 16) +
           (asc ( substr (cData, 2, 1)) shl + 8 ) + asc ( substr (cData, 1, 1))
        when "2"
           nNumber = (asc ( substr (cData, 2, 1)) shl + 8) + asc ( substr (cData, 1, 1))
        when "1"
           nNumber = asc ( substr (cData, 1, 1))
   endcase
   Return(nNumber)
end ReadByte




// returns either Hex / Decimal of string value
string proc GetHexDec(string cTestChar, integer HexBack)
   integer ival = 0
   string cReturnChar[4] = ""
   ival = 1
   while ival < 255
      iVal = iVal + 1
      if (format(chr(iVal):1) == cTestChar)
         if HexBack
            cReturnChar = format(iVal:2)
         else
            cReturnChar = str(iVal,16)
         endif // HexBack
         iVal = 999
      endif //
   endwhile
   Return(cReturnChar)
end GetHexDec

integer proc GetNull(string cByteblock, integer NotNull)
   integer ival = 1
   integer nRepetition = Length(cByteblock)
   while ival < nRepetition
         if NotNull
            if asc ( substr (cByteBlock, ival, 1)) == 0
               break
            endif // asc ( substr (cByteBlock, ival, 1)) == "0"
         else
            if asc ( substr (cByteBlock, ival, 1)) <> 0
               break
            endif // asc ( substr (cByteBlock, ival, 1)) <> "0"
         endif // NotNull
         ival = ival + 1
   endwhile
   Return( ival )
end GetNull


