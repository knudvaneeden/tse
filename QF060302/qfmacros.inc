/*
Program....: qfmacros.inc
Version....: 3.5
Author.....: Randy Wallin & Ryan Katri
Date.......: 08/03/93  09:13 am  Last Modified: 08/30/95 @ 08:10 am
Notice.....: Copyright 1993 COB System Designs, Inc., All Rights Reserved.
QFRestore..: Ø1,1Æ
Compiler...: TSE 2.5
Abstract...: qfmacros.inc called by QF.S and any other macro that requires
             macro expansion.
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

string proc QFDateStr(string cDateInfo)
     integer nMonth, nDay, nYear, ndow
     string cmonth[12]="",
            cMonths[90]="January;Feburary;March;April;May;June;July;August;September;October;November;December;",
            cBreak[2]=""

     if Length(cDateInfo)
        cBreak = Chr(Query(DateSeparator)) // 12-06-95: Use TSE DateSeparator
        nMonth=VAL(SUBSTR(cDateInfo,1,POS(cBreak,cDateInfo)-1))
        nDay=VAL(SUBSTR(cDateInfo,POS(cBreak,cDateInfo)+1,RAT(cBreak,cDateInfo)+1))
        nYear=VAL(SUBSTR(cDateInfo,RAT(cBreak,cDateInfo)+1,4))
        nYear=IIF(nYear<1900,1900+nyear,nyear)
     else
        GetDate(nMonth, nDay, nYear, nDow)
     endif // LEN(cDateInfo)

    // 12-06-95: GDB - use GetToken to remove While loop
     cMonth = format(GetToken(cMonths, ';', nMonth), " ")
     Return(cMonth + format(nDay:iif(nDay>9,2,1))+ ", " + format(nYear:4))
end QFDateStr


string proc QFFileDate()
    string cFdate[12]=""
    integer oldDateFormat

    if not FindThisFile(CurrFilename(), _READONLY_ | _HIDDEN_ | _SYSTEM_)
        return (QFDateSTR(""))
    endif

    oldDateFormat = Set(DateFormat, 1)  // 12-06-95: GDB Set Date format
    cFDate = FFDateStr()
    Set(DateFormat, oldDateFormat)      // 12-06-95: GDB Restore Date format

    return (QFDateStr(cFDate))
end QFFileDate

string proc QFDOW()
     integer nMonth, nDay, nYear, nDow
     string cDays[60]="Sunday;Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;"
     GetDate(nMonth, nDay, nYear, nDow)
     // 12-6-95: GDB - Use GetToken to remove While loop
     Return(format(GetToken(cDays, ';', nDow), " "))
end QfDOW


string proc QFYear()
     // Returns Year only for Copyright or as needed.
     integer nMonth, nDay, nYear, ndow
     GetDate(nMonth, nDay, nYear, nDow)
     Return(format(nYear:4))
end QFYEAR




integer proc QFMacroReplace(integer lLocalBlock)
   string cMacro[40], cValue[59], cOptions[5]
   integer lOkay = TRUE
   integer nError = 0
   string cAbbrevStart[5] = ""
   string cAbbrevEnd[5] = ""
   string cEnvStart[5] = ""
   string cEnvEnd[5] = ""

   if lLocalBlock
      cOptions = "lgn"
   else
      cOptions = "gn"
   endif

   // delimiters for the macro expansions -- these are set as global
   // variables in Main() in QF.S -- read in from the config file
   cAbbrevStart = GetGlobalStr("gcAbbrevStart")
   cAbbrevEnd = GetGlobalStr("gcAbbrevEnd")
   cEnvStart = GetGlobalStr("gcEnvStart")
   cEnvEnd = GetGlobalStr("gcEnvEnd")

   // do the internal replacements
   lReplace(cAbbrevStart + "DATE" + cAbbrevEnd, GetDateStr(), cOptions)
   lReplace(cAbbrevStart + "FILEDATE" + cAbbrevEnd, QFFileDate(), cOptions)
   lReplace(cAbbrevStart + "DATESTR" + cAbbrevEnd, QFDateStr(""), cOptions)
   lReplace(cAbbrevStart + "DOW" + cAbbrevEnd, QFDOW(), cOptions)
   lReplace(cAbbrevStart + "EXT" + cAbbrevEnd, CurrExt(), cOptions)
   lReplace(cAbbrevStart + "FILE" + cAbbrevEnd, SPLITPATH(CurrFilename(), _NAME_) + CurrExt(), cOptions)
   lReplace(cAbbrevStart + "FULLFILE" + cAbbrevEnd, CurrFilename(), cOptions)
   lReplace(cAbbrevStart + "PATH" + cAbbrevEnd, SPLITPATH(CurrFilename(), _PATH_), cOptions)
   lReplace(cAbbrevStart + "TIME" + cAbbrevEnd, GetTimeStr(), cOptions)
   lReplace(cAbbrevStart + "YEAR" + cAbbrevEnd, QFYear(), cOptions)

   // fill-in any environment variable - we look for
   // values surrounded by % - so %AUTHOR% will be replaced
   // by the whatever you have set the DOS Environment
   // Variable Author set to be.
   // If we don't find it - we prompt you.
   while lFind(QFRegExpr(cEnvStart) + ".@" + QFRegExpr(cEnvEnd),
               iif(lLocalBlock, "l", "")+"gx") AND lOkay

      cMacro = GetText(CurrCol()+Length(cEnvStart), 40)

      cMacro = substr(cMacro, 1, pos(cEnvEnd, cMacro)-1)


      cValue = GetEnvStr(cMacro)
      if not Length(cValue)
         cValue = ""
         lOkay = ask("Environment Variable " + cMacro + " not found. What is it?", cValue)
      endif // not Length(cValue)
      lReplace(cEnvStart+cMacro+cEnvEnd, cValue, "ilgn")
   endwhile

   // prompt for the replacements we don't know about
   while lFind(QFRegExpr(cAbbrevStart) + ".@" +
               QFRegExpr(cAbbrevEnd),
               iif(lLocalBlock, "l", "")+"gx") AND lOkay

      // Changed on 05/05/93
      // nError must be re-initialized before each time through the loop
      nError = 0

      cMacro = GetText(CurrCol()+Length(cAbbrevStart), 40)

      cMacro = substr(cMacro, 1, pos(cAbbrevEnd, cMacro)-1)

      cValue = QFGetOption("EXPANSION", cMacro, nError)

      if nError
         cValue = QFGetOption("EXPANSION=Defaults", cMacro, nError)
      endif
      if nError
         cValue = ""
         lOkay = ask(cMacro + "?", cValue)
      endif
      lReplace(cAbbrevStart+cMacro+cAbbrevEnd, cValue, iif(lLocalBlock, "l", "")+"ign")
   endwhile

   return (lOkay)
end QFMacroReplace

