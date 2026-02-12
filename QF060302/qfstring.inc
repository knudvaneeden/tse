/*
Program....: qfstring.inc
Version....: 3.5
Author.....: Randy Wallin & Ryan Katri
Date.......: 08/04/93  11:21 am  Last Modified: 08/30/95 @ 08:10 am
Notice.....: Copyright 1993 COB System Designs, Inc., All Rights Reserved.
QFRestore..: ¯1,1®
Compiler...: TSE 2.5
Abstract...: QFString Contains all of our string manipulation macros.
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

// RAT returns last position of given text
// ie  rat("\","c:\windows\system\toolkit.dll")  returns 18
integer proc rat (string lookfor, string in_text )
    integer len
    len = Length(in_text)
    repeat
        if substr(in_text,len,1)==lookfor
            return (len)
          else
            len = len - 1
        endif
    until len == 0
    return (0)
end rat




string proc QFGetFirstWord()
    string cWord[12] = ''
    PushPosition()                  // Save where we're at
    GotoPos(PosFirstNonWhite())     // At first non white
    cWord = GetWord()
    PopPosition()                   // Restore position
    return (cWord)                  // And return the word
end QFGetFirstWord


string proc Proper(string cStr)
      string cInitChar[1]=" ",
             cLateChar[50]=" "

      if length(cStr) > 1
          cInitChar=substr(cStr,1,1)
          upper(cInitChar)
          cLateChar=substr(cStr,2,length(cStr))
          lower(cLateChar)
          return((cInitChar)+(cLateChar))
      endif // length(cStr) > 1
      return(cStr)
end Proper


