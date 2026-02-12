/*
Program....: qfoption.inc
Version....: 3.5
Author.....: Randy Wallin & Ryan Katri
Date.......: 07/29/93  03:33 pm  Last Modified: 08/30/95 @ 08:10 am
Notice.....: Copyright 1993 COB System Designs, Inc., All Rights Reserved.
QFRestore..: Ø1,1Æ
Compiler...: TSE 2.5
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


string proc QFGetOption(string cSection, string cOption, var integer nError)
   integer nExpandBuf
   string cFindStr[40] = ""
   string cPhrase[200] = ""
   integer lDefaults = FALSE
   string cExt[4]

   nExpandBuf = GetGlobalInt("nExpandBuf")

   if nExpandBuf
      PushPosition()

      cExt = CurrExt()
      if length(cExt)
         cFindStr = "^\[" + cSection + " @=.@\" + cExt + "{]}|{ .@\]}\c"
      else
         nError = 2
      endif // length(SplitPath(CurrFilename(), _EXT_)

      repeat
         if nError  // this is our second time through, so look for defaults
            lDefaults = TRUE
            cFindStr = "^\[" + cSection + "]\c"
         endif
         nError = 0

         GotoBufferId(nExpandBuf)
         if lFind(cFindStr, "igx") // locate the config section
            // mark the entire config section so we can search only it
            PushBlock()
            MarkLine()
            if not lFind("^\[", "x")    // locate the end of the section
               EndFile()
            endif // not lFind("^\[", "x")


            // Find the option within the config section
            if lFind("^"+cOption+" @=\c", "ixlg")
               cPhrase = GetText(CurrCol(), 200)

            else
               nError = 3
            endif // lFind("^"+cGotcha+"=\c", "ixlg")

            PopBlock()
         else
            nError = 2
         endif // lFind(cFindStr, "igx")


      until (not nError or lDefaults)

      PopPosition()
   else
      nError = 1
   endif // nExpandBuf

   return (cPhrase)
end QFGetOption


integer proc QFGetOnOff(string cSection, string cOption, var integer nError)
   string cStatus[2]=""
   cStatus = substr(QFGetOption(cSection, cOption, nError), 1, 2)
   upper(cStatus)
   Return(cStatus == "ON")
end QFGetOnOff

