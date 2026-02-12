/* Modified By: GDB / RB (SemWare)
 * Date.......: 09/22/95
 * Notes......:
 *
 * Fixes for two problems:
 *
 *  - Chopping off last character of directory / file names.
 *
 *  - Not handling directories with extensions properly.
 *
 * All changes marked with "// !!! GDB" comments
 */

/*
Program....: Quiet Flight Directory Lister - Zipper
Version....: 3.5
Author.....: Randy Wallin & Ryan Katri
Date.......: 05/05/93  08:23 pm  Last Modified: 08/30/95 @ 07:58 am
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
#include ["QFString.INC"]
    // Includes:
    // integer proc rat (string lookfor, string in_text )
    // string proc rtrim( string st )
    // string proc ltrim( string st )
    // string proc QFGetWordAtCursor()
    // string proc QFGetFirstWord()
    // string proc Proper(string cStr)
    // string proc GetWordAtCursor()
#include ["QFRegExp.inc"]
#include ["QFMsg.inc"]
#include ["QFPopLst.inc"]
#include ["QFOption.inc"]
#include ["QFTags.inc"]
#include ["QFAllSav.inc"]
#include ["QFUtil.inc"]

forward integer proc QFDirList(string cSpec, integer lInsert)

constant DIR_POS = 4

string
   TMP_FILE[] = "$qftmp$.tmp"

menu ConfirmMenu()
   X = 65
   Y = 7
   "&Hilited"
   "&Tagged"
   "", , Divide
   "&Cancel"
end ConfirmMenu


menu SortMenu()
   Title = "Sort by"
   X = 65
   Y = 7
   History = 1
   "&Name"
   "&Date"
   "&Extension"
   "&Size"
   "", , Divide
   "&Cancel"
end SortMenu



menu HelpMenu()
    Title = "QFZip Menu"
    X = 48                      // left side
    Y = 3                       // top line
    History = 1
    "&Extract Current    <Enter>"
    "Extract &Tagged     <Ctrl E>"
    "Extract &All        <Ctrl A>"
    "&Insert             <Ins>"
    "&Delete             <Del>"
    "Delete Tagged      <Ctrl D>"
    "&Freshen Zip        <Ctrl F>"
    "", , Divide
    "&View File          <Ctrl V>"
    "&Sort Order         <Ctrl S>"
    "Set &Password       <Ctrl P>"
    "Toggle &Overwrite    <Ctrl O>"
    "", , Divide
    "Toggle Ta&g         <Space>"
    "&Tag All            <Ctrl T>"
    "&Untag All          <Ctrl U>"
    "&Reverse Tags       <Ctrl R>"
    "", , Divide
    "&Cancel"
end HelpMenu

// Although we are hardcoding the keys to the menu, it is just
// too easy to just Push the key to perform the function than
// do it any other way!
proc QFZipHelp()

   case HelpMenu()
      when 1
         PushKey(<enter>)
      when 2
         PushKey(<ctrl e>)
      when 3
         PushKey(<ctrl a>)
      when 4
         PushKey(<Ins>)
      when 5
         PushKey(<Del>)
      when 6
         PushKey(<ctrl d>)
      when 7
         PushKey(<ctrl f>)
      when 9
         PushKey(<ctrl v>)
      when 10
         PushKey(<ctrl s>)
      when 11
         PushKey(<ctrl p>)
      when 12
         PushKey(<ctrl o>)
      when 14
         PushKey(<spacebar>)
      when 15
         PushKey(<ctrl t>)
      when 16
         PushKey(<ctrl u>)
      when 17
         PushKey(<ctrl r>)
   endcase
end QFZipHelp




proc PKZip(string cZipExe, string cZipFile, string cFile, string cCmd, string cPassword)
   string cNewCmd[50]
   cNewCmd = cCmd
   if length(cPassword) and YesNoOnly("Use password?") == 1
      cNewCmd = "-s" + cPassword + " " + cNewCmd
   endif


   PopWinOpen(1, 1, Query(ScreenCols), Query(ScreenRows), 0, "", Query(TextAttr))
   dos(cZipExe+" " + cNewCmd + " " + cZipFile + " " + cFile)
   PopWinClose()
end PKZip

proc PKUnZip(string cUnZipExe, string cZipFile, string cFile, string cCmd, string cPassword)
   PopWinOpen(1, 1, Query(ScreenCols), Query(ScreenRows), 0, "", Query(TextAttr))
   if length(cPassword)
      dos(cUnzipExe+" -s" + cPassword + " " + cCmd + " " + cZipFile + " " + cFile )
   else
      dos(cUnZipExe+" " + cCmd + " " + cZipFile + " " + cFile )
   endif
   PopWinClose()
end PKUnZip


// Build a list of tagged files
integer proc QFGetTagged(string cPath, integer lTagged)

   integer nCurrId, lBackup, nTagID
   integer lOkay = FALSE
   string cFile[50]
   PushPosition()

   nCurrId = GetBufferId()
   nTagID = CreateBuffer(TMP_FILE)
   if nTagID
      GotoBufferId(nTagId)
      EmptyBuffer()

      GotoBufferId(nCurrId)

      // find all the tagged files and add them to the list
      if lTagged
         BegFile()
      endif

      repeat

         GotoPos(2)
         if (Chr(CurrChar()) == "˚") or not lTagged
            cFile = GetText(DIR_POS, 12)
            cFile = substr(cFile, 1, pos(' ', cFile)-1) + "." + substr(cFile,10,3)
            if length(cPath)
               cFile = cPath + cFile
            else
               cFile = GetText(63, 68) + cFile
            endif

//            GotoBufferId(nTagId)
            // Changed on 09/30/93 RMK to take advantage of new syntax
            AddLine(cFile, nTagID)
//            GotoBufferId(nCurrId)
         endif

      until not down() or not lTagged

      // save the tag buffer so we can process it with PKZIP
      GotoBufferId(nTagId)

      lBackup = Set(MakeBackups, FALSE)   // don't make a backup file
      SaveFile()
      Set(MakeBackups, lBackup)

      AbandonFile(nTagID)
      lOkay = TRUE
   endif

   PopPosition()

   return (lOkay)
end QFGetTagged


// View a file contained within the .ZIP
integer proc QFViewZip(string cUnZipEXE, string cZipFile, var string cViewFile, var string cPassword)
   integer nTempId
   integer lOk = TRUE
   integer lError = FALSE
   integer lGetPass = FALSE
   string cNewPW[20]

   cNewPW = cPassword

   upper(cViewFile)
   message("Loading file " + cViewFile + ". . .")

   nTempId = GetBufferId()

   CreateTempBuffer()
   repeat
      EmptyBuffer()

      if length(cNewPW)
         dos(cUnZipEXE+" -c -s" + cNewPW + " " + cZipFile + " " + cViewFile + " > " + TMP_FILE, _DONT_CLEAR_)
      else
         dos(cUnZipEXE +" -c " + cZipFile + " " + cViewFile + " > " + TMP_FILE, _DONT_CLEAR_)
      endif
      lError = not InsertFile(TMP_FILE)
      if not lError
         lGetPass = lFind("^PKUNZIP.@{Skipping encrypted}|{! Incorrect password}", "xg")
         if lGetPass
            lOk = Ask("Password?", cNewPW)
         endif
      endif // not lError
   until (not lOk or not lGetPass or lError)

   if lError
      QFMessage("Problem creating view file", 3, TRUE)
   else
      if lOk
         // set the new password to pass back
         if length(cNewPW)
            cPassword = cNewPW
         endif

         BegFile()
         MarkLine()
         lFind("<to console>", "")
         down()
         DelBlock()

         // View the file in a read-only mode
         lList("Viewing " + cViewFile + " -- Press ESC to exit", Query(ScreenCols), Query(ScreenRows), _ENABLE_SEARCH_)

      endif

   endif // lError
   AbandonFile()
   GotoBufferId(nTempId)


   Set(Attr, Query(TextAttr))
   ClrScr()

   return (lOk and not lError)

end QFViewZip


integer proc QFMakeZip(string cUnZipEXE, string cFileSpec, var string cSortType)
   integer nDirId
   string cLine[80]
   string cPath[80]
   string cFileName[50]

   message("Loading " + cFileSpec + "...")

   // get all directory entries
   if dos(cUnZipEXE+" -vb" + cSortType +  " " + cFileSpec + " > " + TMP_FILE, _DONT_CLEAR_)
      nDirID = CreateTempBuffer()

      Insertfile(TMP_FILE)

      if lFind("No file(s) found.", "")
         warn("Empty ZIP file")
         EmptyBuffer()
         AddLine()
      else
         EndFile()
         DelLine()
         up()
         DelLine()
         BegFile()
         MarkLine()
         lFind("^ ------  ------", "x")
         DelBlock()

         // This little routine puts the zip directory in the order we want
         BegFile()
         repeat
            cFilename = GetText(48, 100)
            lower(cFilename)

            // remove the path, if any
            cPath = ""
            while pos("/", cFilename)
               cPath = cPath + substr(cFilename, 1, pos("/", cFilename))
               cFilename = substr(cFilename, pos("/", cFilename)+1, length(cFilename))
            endwhile

            if pos(".", cFilename)
               cLine = "   " + substr(cFilename, 1, pos(".", cFilename)-1)
               cLine = cLine + substr("            ", 1, 12 - length(cLine)) + substr(cFilename + "   ", pos(".", cFilename)+1, 3) + " "
            else
               cLine = "   " + cFilename + substr("            ", 1, 12 - length(cFilename)) + " "
            endif

            // Filename + Size + Date + Time
            cLine = cLine + GetText(18, 6) + "  " + GetText(31, 8) + "  " + GetText(41, 5) + " "
            // Add  Method + Ratio + Path
            cLine = cLine + GetText(1,16) + GetText(25,4) + "  " + cPath

            BegLine()
            DelToEOL()   // delete the old line so we can insert our modified entry
            InsertText(cLine, _INSERT_)

         until not down()

         BegFile()
      endif

   endif
   return (nDirId)

end QFMakeZip


// Create a new zip out of the files in the editing ring
proc QFNewZip(string cFullPath)
   string cZipExe[12], cBuffer[80]
   integer nError, nTempID, nID

   cZipExe = QFGetOption("ZIP", "ZipFile", nError)
   if NOT Length(cZipExe)
      cZipExe="PkZip"
   endif // NOT Length(cZipExe)

   PushPosition()
   NextFile()
   nID = GetBufferID()
   nTempID = CreateBuffer(TMP_FILE, _SYSTEM_)
   GotoBufferID(nID)
   if nTempID
      repeat
         cBuffer = CurrFilename()
         // GotoBufferID(nTempID)
         // Changed on 09/30/93 RMK to take advantage of new syntax
         AddLine(cBuffer, nTempID)
         NextFile()
      until nID == GetBufferID()
      GotoBufferID(nTempID)
      SaveFile()
      AbandonFile()
      PKZip(cZipEXE, cFullPath, "@"+TMP_FILE, "-a", "")
   endif

   PopPosition()


end QFNewZip



proc QFZipList(string cFullPath)
   string cSpeedKey[12] = ""
   string cFindKey[15]
   string cFile[12]
   string cNewDir[50]
   string cZipExe[12]=""
   string cUnZipExe[12]=""

   integer nRow,
           nKey,
           nWinSize,
           nUpdateType = POP_OPEN,
           nSortOrder,
           nMenu

   string cSortType[1] = "n"
   integer nCurrId
   integer nDirId, nError, lOverWrite = FALSE
   integer lError
   string cPassword[20] = ""

   cZipExe = QFGetOption("ZIP", "ZipFile", nError)
   cUnZipExe = QFGetOption("ZIP", "UnZipFile", nError)
   if NOT Length(cZipExe)
      cZipExe="PkZip"
   endif // NOT Length(cZipExe)
   if NOT Length(cUnZipExe)
      cUnZipExe="PkUnZip"
   endif // NOT Length(cUnZipExe)


   nCurrId = GetBufferId()              // save current buffer id


   nSortOrder = 1
   nRow = 1

   nDirId = QFMakeZip(cUnZipEXE, cFullPath, cSortType)

   // set the window size based upon # of items to display and rows available
   nWinSize = Query(ScreenRows)-12

   nRow = 1
   repeat
      message(iif(length(cSpeedKey), "SpeedKey: " + cSpeedKey, ""))


      // "NAME           SIZE  DATE      TIME   LENGTH  METHOD RATIO PATH          "
      nKey = QFPopList(cFullPath,
       " ENTER: Extract  ESC: Cancel  F1: Help", nRow, 1, 5, 80, nWinSize,
       query(MenuBorderAttr), query(MenuSelectAttr), nUpdateType,
       Query(MenuTextAttr))
      nUpdateType = POP_NOTHING


      cFile = GetText(DIR_POS, 12)
      cFile = substr(cFile, 1, pos(' ', cFile)-1) + "." + substr(cFile,10,3)


      PushPosition()


      // set up a speedkey routine
      if ((nKey & 0xff) > 47 and (nKey & 0xff) < 123) or
          (nKey == <backspace>) or (nKey == 60) or (nKey == <.>)
         case nKey
            when <backspace>
               cSpeedKey = substr(cSpeedKey, 1, length(cSpeedKey)-1)
            when <.>
               cSpeedKey = cSpeedKey + "."
            otherwise
               cSpeedKey = cSpeedKey + chr(nKey & 0xff)
               lower(cSpeedKey)
         endcase

         // do the speedkey search only if sorted by name or searching
         //   for a directory
         if cSortType == "n" or substr(cSpeedKey, 1, 1) == "\"
            cFindKey = cSpeedKey

            // If period is typed, space out the extension
            // ie "file.exe" --> "file     exe"
            if pos(".", cSpeedKey)
               cFindKey = substr(cSpeedKey, 1, pos(".", cSpeedKey) - 1)
               cFindKey = cFindKey + substr("         ", 1, 9-length(cFindKey)) +
                  substr(cSpeedKey, pos(".", cSpeedKey) + 1, length(cSpeedKey))
            endif

            if not lFind("^..." + QFRegExpr(cFindKey), "gxqi")
               // Remove speedkey character just typed because it's invalid
               cSpeedKey = substr(cSpeedKey, 1, length(cSpeedKey)-1)
            else
               nUpdateType = POP_NOTHING
            endif
         else
            cSpeedKey = ""
         endif
      else


         // turn off speedkey if an alphanumeric key is not pressed
         cSpeedKey = ""

         case nKey
         when <F1>           // HELP!
            QFZipHelp()
         when <ctrl t>
            QFTag(TAG_TAGALL)
         when <ctrl u>
            QFTag(TAG_UNTAGALL)
         when <ctrl r>
            QFTag(TAG_REVERSE)
         when <spacebar>
            QFTag(TAG_TOGGLE)

         when <enter>, <greyenter>      // extract hilited file
            if YesNoOnly("Extract " + cFile + "?") == 1
               PKUnZip(cUnZipEXE, cFullPath, cFile, "-e" + iif(lOverwrite, " -o", ""), cPassword)
               nUpdateType = POP_REFRESH
            endif

         when <ctrl e>       // extract tagged file(s)
            if QFFilesTagged() and YesNoOnly("Extract Tagged files?") == 1
               QFGetTagged("", TRUE)
               PKUnZip(cUnZipEXE, cFullPath, "@"+TMP_FILE, "-e" + iif(lOverwrite, " -o", ""), cPassword)
               nUpdateType = POP_REFRESH
            endif

         when <ctrl a>       // extract all
            if YesNoOnly("Extract all files?") == 1
               PKUnZip(cUnZipEXE, cFullPath, "*.*", "-e" + iif(lOverwrite, " -o", ""), cPassword)

               // redraw entire picklist window
               nUpdateType = POP_REFRESH
            endif

         when <ctrl s>       // change sort order
            nSortOrder = SortMenu()
            if nSortOrder <> 6 and nSortOrder <> 0
               cSortType = substr("ndes", nSortOrder, 1)
               nDirId = QFMakeZip(cUnZipEXE, cFullpath, cSortType)
               nUpdateType = POP_REFRESH
            endif

         when <Del>, <GreyDel>          // delete file(s)
            nMenu = ConfirmMenu("Delete")
            if nMenu > 0 and nMenu < 3
               case nMenu
                  when 1
                     PKZip(cZipEXE, cFullPath, cFile, "-d", "")
                     DelLine()
                     nUpdateType = POP_REFRESH
                  when 2
                     if QFFilesTagged() and QFGetTagged("", TRUE)
                        PKZip(cZipEXE, cFullPath, "@"+TMP_FILE, "-d", "")
                        nDirId = QFMakeZip(cUnZipEXE, cFullpath, cSortType)
                        nUpdateType = POP_REFRESH
                     endif
               endcase

            endif

         when <ctrl d>
            if QFFilesTagged() and YesNoOnly("Delete tagged files?") == 1
               if QFGetTagged("", TRUE)
                  PKZip(cZipEXE,  cFullPath, "@"+TMP_FILE, "-d", "")
                  nDirId = QFMakeZip(cUnZipEXE, cFullpath, cSortType)
                  nUpdateType = POP_REFRESH
               endif
            endif

         when <ctrl f>          // freshen files
            if YesNoOnly("Freshen files?") == 1
               PKZip(cZipEXE, cFullPath, "", "-f", "")
               AbandonFile()
               nDirId = QFMakeZip(cUnZipEXE, cFullpath, cSortType)
               nUpdateType = POP_REFRESH
            endif

         when <ctrl o>          // toggle overwrite mode
            lOverwrite = not lOverwrite
            if lOverwrite
               QFMessage("Overwrite mode set ON", 3, TRUE)
            else
               QFMessage("Overwrite mode set OFF", 3, FALSE)
            endif
         when <ctrl p>          // set password
            ask("Password?", cPassword)

         when <Ins>, <GreyIns>          // insert file(s)
            lError = FALSE
            cNewDir = SplitPath(cFullPath, _DRIVE_ | _PATH_)
            if substr(cNewDir, length(cNewDir), 1) <> "\"
               cNewDir = cNewDir + "\" + "*.*"
            endif
            if QFDirList(cNewDir, TRUE)
               if QFFilesTagged()
                  case ConfirmMenu("Add")
                     when 1
                        QFGetTagged("", FALSE)
                     when 2
                        QFGetTagged("", TRUE)
                     when 3
                        lError = TRUE
                  endcase
               else
                  QFGetTagged("", FALSE)
               endif

               AbandonFile()
               if not lError
                  message("Adding files to ZIP. . .")
                  PKZip(cZipEXE, cFullPath, "@"+TMP_FILE, "-a", cPassword)
                  nDirID = QFMakeZip(cUnZipEXE, cFullPath, cSortType)
                  GotoBufferID(nDirID)
                  nUpdateType = POP_REFRESH
               endif
            else
               AbandonFile()
            endif
            GotoBufferID(nDirID)

         when <ctrl v>       // view file
            QFViewZip(cUnZipEXE, cFullPath, cFile, cPassword)
            nUpdateType = POP_REFRESH

         endcase
       endif

   until nKey == <escape>

   GotoBufferId(nCurrId)

   // close the popup picklist
   QFPopList("", "", nRow, 1, 5, 80, nWinSize, 0, 0, POP_CLOSE, 0)

   return ()
end QFZipList



proc QFSortDir(var string cSortType, integer lAsk)
   integer nSortOrder
   string cFile[12]
   string cSearchStr[70], cReplaceStr[70]

   PushBlock()

   if lAsk
      nSortOrder = SortMenu()
      if nSortOrder <> 6 and nSortOrder <> 0
         cSortType = substr("ndes", nSortOrder, 1)
      endif
   endif

   // save the current filename so we can go back to it later
   cFile = GetText(DIR_POS, 13)

   // Sort directory entries separate from the filenames
   BegFile()
   MarkLine()
   lFind("   [~\\]", "ix")
   up()
   sort()
   UnMarkBlock()

   down()
   BegLine()
   PushPosition()

   // Re-order the directory listing based upon the sort key
   // (put sort key at front of listing)
   case cSortType
      when "n"      // sort by name
         lReplace("^{...}{[~\\].......} {...} {.........}.{......}{..} {.....}",
                  "\2 \3 \4 \5\6 \7 \1", "ixn")
         cSearchStr = "^{[~\\].......} {...} {.........} {......}{..} {......} {...}"
         cReplaceStr = "\7\1 \2 \3 \4\5 \6"
      when "e"      // sort by extension
         lReplace("^{...}{[~\\].......} {...} {.........}.{......}{..} {......}",
                  "\3 \2 \4 \5\6 \7 \1", "ixn")
         cSearchStr = "^{...} {[~\\].......} {.........} {......}{..} {......} {...}"
         cReplaceStr = "\7\2 \1 \3 \4\5 \6"
      when "d"      // sort by date
         lReplace("^{...}{[~\\].......} {...} {.........} {......}{..} {......}",
                  "\6\5 \7 \2 \3 \4 \1", "ixn")
         cSearchStr = "^{..}{......} {......} {[~\<].......} {...} {.........} {...}"
         cReplaceStr = "\7\4 \5 \6 \2\1 \3"
      when "s"      // sort by size
         lReplace("^{...}{[~\\].......} {...} {.........}.{......}{..} {.....}",
                  "\4 \2 \3 \5\6 \7 \1", "ixn")
         cSearchStr = "^{.........} {[~\<].......} {...} {......}{..} {......} {...}"
         cReplaceStr = "\7\2 \3 \1 \4\5 \6"
   endcase

   MarkLine()
   EndFile()
   EndLine()
   Sort()

   PopPosition()

   // re-arrange the listing so that it is in proper order after the sort
   lReplace(cSearchStr, cReplaceStr, "igxn")

   // hilite the file that was selected before we re-sorted
   lFind(cFile, "gnq")

   PopBlock()

   return ()
end QFSortDir


integer proc QFMakeDir(var string cFullPath, var string cSortType)
   integer nDirId
   integer nReturnVal
   integer nKillMax

   nKillMax = Set(KillMax, 0)

   message("Loading directory " + cFullPath)
   nDirID = CreateTempBuffer()

   nReturnVal = BuildPickBufferEx(cFullPath, _NORMAL_ | _DIRECTORY_)
   if nReturnVal

      BegFile()

      repeat
         AddLine(pickFileFormat(cFullPath))
         Up()
         DelLine()
         GotoPos(43)
         DelToEol()
      until not down()
//    MarkColumn(1, 13, NumLines(), 13)   // !!! GDB: Removed
//    DelBlock()                          // !!! GDB: Removed
   endif

   Set(KillMax, nKillMax)

   // Sort the entries
   QFSortDir(cSortType, FALSE)
   BegFile()

   message("")

   return (nDirId)

end QFMakeDir



integer proc QFDirList(string cSpec, integer lInsert)
   string cSpeedKey[13] = ""
   string cFindKey[15]
   string cPath[80]=""
   string cFullPath[80]    // fullpath = drive + path + filename + ext
   string cFile[13]               // !!! GDB: Adjust for handling extensions propoerly
   string cDir[13]                // !!! GDB: Adjust for handling extensions propoerly
   string cNewDir[50]
   integer nRow,
           nKey,
           nWinSize,
           nUpdateType = POP_OPEN,
           lDirectory

   string cSortType[1] = "n"
   integer nCurrId
   integer lQuit = FALSE
   integer nLastLine
   integer nRetValue
   integer nDirID

   nCurrId = GetBufferId()              // save current buffer id

   cFullPath = ExpandPath(cSpec)
   cPath = SplitPath(cFullPath, _DRIVE_ | _PATH_)

   nRow = 1

   nDirID = QFMakeDir(cFullPath, cSortType)

   // set the window size based upon # of items to display and rows available
   nWinSize = Query(ScreenRows)-5

   nRow = 1
   repeat
      message(iif(length(cSpeedKey), "SpeedKey: " + cSpeedKey, ""))
      nKey = QFPopList(cFullPath,
       " ENTER: Select  ESC: Cancel ",nRow, 1, 2, 45, nWinSize,
       query(MenuBorderAttr), query(MenuSelectAttr), nUpdateType,
       Query(MenuTextAttr))
      nUpdateType = POP_NOTHING


      cFile = GetText(DIR_POS, 14)   // !!! GDB: Adjusted to get full file name
      // !!! Adjusted below to handle extension correctly.
      cFile = substr(cFile, 1, pos(' ', cFile)-1) + "." + Trim(SubStr(cFile, Pos(" ", cFile), Length(cFile)+1))


      PushPosition()

      // see if this is a directory entry
      lDirectory = GetText(DIR_POS, 1) == "\"

      // set up a speedkey routine
      if ((nKey & 0xff) > 47 and (nKey & 0xff) < 123) or
          (nKey == <backspace>) or (nKey == 60) or (nKey == <.>)
         case nKey
            when <backspace>
               cSpeedKey = substr(cSpeedKey, 1, length(cSpeedKey)-1)
            when <.>
               cSpeedKey = cSpeedKey + "."
            otherwise
               cSpeedKey = cSpeedKey + chr(nKey & 0xff)
               lower(cSpeedKey)
         endcase

         // do the speedkey search only if sorted by name or searching
         //   for a directory
         if cSortType == "n" or substr(cSpeedKey, 1, 1) == "\"
            cFindKey = cSpeedKey

            // If period is typed, space out the extension
            // ie "file.exe" --> "file     exe"
            if pos(".", cSpeedKey)
               cFindKey = substr(cSpeedKey, 1, pos(".", cSpeedKey) - 1)
               cFindKey = cFindKey + substr("         ", 1, 9-length(cFindKey)) +
                  substr(cSpeedKey, pos(".", cSpeedKey) + 1, length(cSpeedKey))
            endif

            nLastLine = CurrLine()
            if not lFind("^..." + QFRegExpr(cFindKey), "gxqi")
               // Remove speedkey character just typed because it's invalid
               cSpeedKey = substr(cSpeedKey, 1, length(cSpeedKey)-1)
            else
               if nLastLine <> CurrLine()
                  nUpdateType = POP_REFRESH
               endif
            endif
         else
            cSpeedKey = ""
         endif
      else


         // turn off speedkey if an alphanumeric key is not pressed
         cSpeedKey = ""

         if lInsert
            case nKey
               when <ctrl t>
                  QFTag(TAG_TAGALL)
               when <ctrl u>
                  QFTag(TAG_UNTAGALL)
               when <ctrl r>
                  QFTag(TAG_REVERSE)
               when <spacebar>
                  QFTag(TAG_TOGGLE)
            endcase
         endif

         case nKey

            when <ctrl l>       // log into new directory
               cNewDir = cFullPath
               if ask("New directory: ", cNewDir)
                  cNewDir = ExpandPath(cNewDir)
                  if FileExists(SplitPath(cNewDir, _DRIVE_ | _PATH_) + "*.*")
                     cPath = SplitPath(cNewDir, _DRIVE_ | _PATH_)
                     cFullPath = cNewDir

                     AbandonFile()
                     nDirID = QFMakeDir(cFullPath, cSortType)
                     nUpdateType = POP_REFRESH
                     nRow = 1
                  else
                     QFMessage("Invalid directory", 3, FALSE)
                  endif
               endif


            when <ctrl s>       // change sort order
               QFSortDir(cSortType, TRUE)
               nUpdateType = POP_REFRESH

            when <enter>,<greyenter>  // if on a directory entry, change directory
               if lDirectory
                  cDir = Trim(GetText(DIR_POS + 1, 13))   // !!! GDB: Adjust to get correct / full name
                  if Pos(" ", cDir) > 1   // !!! GDB: Fix for Dirs with extensions
                      cDir = Trim(SubStr(cDir,1,Pos(" ", cDir)-1)) + "." +
                             Trim(SubStr(cDir, Pos(" ", cDir), Length(cDir)))
                  endif
                  cPath = cPath + cDir + "\" + SplitPath(cFullPath, _NAME_ | _EXT_)

                  AbandonFile()

                  cFullPath = ExpandPath(cPath)
                  cPath = SplitPath(cFullPath, _DRIVE_ | _PATH_)
                  nDirID = QFMakeDir(cFullPath, cSortType)

                  nUpdateType = POP_REFRESH
                  nRow = 1
                  nKey = 1
               else
                  if lInsert
                     lQuit = TRUE
                  else
                     QFZipList(cPath + cFile)
                  endif
               endif

            when <ctrl n>
               // Create a new zip of the files in the current ring
               cNewDir = SplitPath(cFullPath, _DRIVE_ | _PATH_)
               if not lInsert and Ask("ZIP Filename:", cNewDir)
                  QFNewZip(cNewDir)
                  nDirID = QFMakeDir(cFullPath, cSortType)
                  nUpdateType = POP_REFRESH
               endif

            when <escape>
               lQuit = TRUE

           endcase
       endif

   until lQuit


   nRetValue = (nKey <> <escape>)

   if not lInsert
      AbandonFile(nDirID)
      GotoBufferId(nCurrId)
   endif

   // close the popup picklist
   QFPopList("", "", nRow, 1, 2, 66, nWinSize, 0, 0, POP_CLOSE, 0)

   return (nRetValue)
end QFDirList




proc main()
   integer nHistory
   integer nMsgLevel
   integer nKillMax,
           nSaveAttr,
           nModified
   string cFileName[80] = ""
   nModified=QFQuickSave(FALSE)

   if nModified AND YesNoOnly("Save "+ltrim(format(nModified : 3))+" Modified File(s)? ")==1
      QFQuickSave(TRUE)
   endif // nModified

   // turn off undelete for now
   nKillMax = set(KillMax, 0)

   nMsgLevel = SET(MsgLevel, _NONE_)

   nHistory = GetGlobalInt("QFZIP_HISTORY")
   if not nHistory
      nHistory = GetFreeHistory("QFZIP:DIR")
      SetGlobalInt("QFZIP_HISTORY", nHistory)
   endif // not nHistory


   cFileName = ExpandPath("*.ZIP")
//   if askfilename("QFZip Filespec:", cFileName, _FULL_PATH_ | _MUST_EXIST_, nHistory)
   if FileExists(SplitPath(cFileName, _DRIVE_ | _PATH_) + "*.*")

      PushPosition()

      AddHistoryStr(cFileName, nHistory)


      // Clear the background screen to black
      nSaveAttr = Set(Attr, Color(White on Black))
      // ClrScr()
      Set(Attr, nSaveAttr)

      PushBlock()

      if QFDirList(cFileName, FALSE)
         KillPosition()
         PushPosition()
      endif

      PopBlock()


      UpdateDisplay(_HELPLINE_REFRESH_)

      EraseDiskFile(TMP_FILE)

//      else
//          QFMessage("Invalid directory", 3, FALSE)
//      endif

   endif // ask("Filespec?", cFilename)

   // re-enable undelete
   Set(KillMax, nKillMax)
   Set(MsgLevel, nMsgLevel)

   UpdateDisplay(_ALL_WINDOWS_REFRESH_)

   PopPosition()

end main

