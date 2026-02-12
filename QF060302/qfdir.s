/*
Program....: Quiet Flight Directory Lister
Version....: 3.5
Author.....: Randy Wallin & Ryan Katri
Date.......: 05/05/93  08:23 pm  Last Modified: 08/30/95 @ 07:58 am
Notice.....: Copyright 1993 COB System Designs, Inc., All Rights Reserved.
QFRestore..: Ø1,1Æ
Compiler...: TSE 2.5
Abstract...: Directory Management Tool
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
#include ["QFTags.inc"]
#include ["QFAllSav.inc"]
#include ["QFOption.inc"]
#include ["QFUtil.inc"]

constant
   DIR_POS = 4


menu QuitCD()
    X = 48                      // left side
    Y = 3                       // top line
    "&Directory Change"
    "&Load Tagged Files"
    "&Quit w/o Loading"
    "", , Divide
    "&Cancel"
end QuitCD

menu QuitMenu()
    Title = "Load?"
    X = 48                      // left side
    Y = 3                       // top line
    "&Tagged"
    "&Cu&rrent"
    "&Quit w/o Loading"
end QuitMenu


menu SortMenu()
    Title = "Sort by"
    X = 48                      // left side
    Y = 3                       // top line
    History = 1
    "&Name"
    "&Date"
    "&Extension"
    "&Size"
    "", , Divide
    "&Cancel"
end SortMenu

menu NoYes()
    "&No"
    "&Yes"
    "&Cancel"
end NoYes



menu HelpMenu()
    Title = "QFDir Menu"
    X = 48                      // left side
    Y = 3                       // top line
    History = 1
    "Load Hilited/Tagged <Enter>"
    "&Delete Current      <Del>"
    "Delete Tagged       <Ctrl D>"
    "&Log New Directory   <Ctrl L>"
    "Set &Home Directory  <Ctrl H>"
    "&View File           <Ctrl V>"
    "View &Binary         <Ctrl B>"
    "&Sort Order          <Ctrl S>"
    "", , Divide
    "Toggle Ta&g          <Space>"
    "&Tag All             <Ctrl T>"
    "&Untag All           <Ctrl U>"
    "&Reverse Tags        <Ctrl R>"
    "", , Divide
    "&Cancel"
end HelpMenu



// Although we are hardcoding the keys to the menu, it is just
// too easy to just Push the key to perform the function than
// do it any other way!
proc QFDirHelp()
   integer nMenu

   nMenu = HelpMenu()

   case nMenu
      when 1
         PushKey(<enter>)
      when 2
         PushKey(<del>)
      when 3
         PushKey(<ctrl d>)
      when 4
         PushKey(<ctrl l>)
      when 5
         PushKey(<ctrl h>)
      when 6
         PushKey(<ctrl v>)
      when 7
         PushKey(<ctrl b>)
      when 8
         PushKey(<ctrl s>)
      when 10
         PushKey(<spacebar>)
      when 11
         PushKey(<ctrl t>)
      when 12
         PushKey(<ctrl u>)
      when 13
         PushKey(<ctrl r>)
   endcase
end QFDirHelp



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
   cFile = GetText(DIR_POS, 12)

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


integer proc QFMakeDir(string cFullPath, var string cSortType)
   integer nDirId
   integer nReturnVal
   integer nKillMax

   nKillMax = Set(KillMax, 0)

   message("Loading directory " + cFullPath)
   nDirID = CreateTempBuffer()

   nReturnVal = BuildPickBufferEx(cFullPath, _NORMAL_ | _DIRECTORY_)
   // cFullPath = SplitPath(cFullPath, _DRIVE_ | _PATH_)
   if nReturnVal

      BegFile()

      repeat
         AddLine(pickFileFormat(cFullPath))
         Up()
         DelLine()
         GotoPos(43)
         DelToEol()
      until not down()
      MarkColumn(1, 13, NumLines(), 13)
      DelBlock()
   endif

   Set(KillMax, nKillMax)

   // Sort the entries
   QFSortDir(cSortType, FALSE)
   BegFile()

   message("")

   return (nDirId)

end QFMakeDir




/* Generic File Viewer */
/* Parameters:
   cFile = File Name
   cType = Description to pass to message as view is created
   cDosCommand = What command to execute to create view
   nDelLines = # of lines to delete before viewing (proper formatting)
*/
proc QFViewMassage(string cFile, string cType, string cDosCommand, integer nDelLines)
   integer nID

   PushPosition()

   // See if file opened already so we don't close it when done
   nId = GetBufferId(cFile)

   message("Creating "+ cType+ " view...")

   dos(cDosCommand +" " + cFile + " > $qfview$.tmp", 2)

   EditFile("$qfview$.tmp")
   DelLine(nDelLines)
   EraseDiskFile("$qfview$.tmp")

   lList("Press ESC to exit VIEW mode", Query(ScreenCols), Query(ScreenRows), _ENABLE_SEARCH_)
   if not nId
      AbandonFile()
   endif

   PopPosition()
end QFViewMassage


proc QFViewFile(string cFile, integer lBinary)
   integer nID

   PushPosition()
   // See if file opened already so we don't close it when done
   nId = GetBufferId(cFile)

   if lBinary
      EditFile("-b70 " + cFile)
   else
      EditFile(cFile)
   endif

   lList("Press ESC to exit VIEW mode", Query(ScreenCols), Query(ScreenRows), _ENABLE_SEARCH_)
   if not nId
      AbandonFile()
   endif
   PopPosition()

end QFViewFile


integer proc QFDelTagged(string cPath)
   integer nMenu, nNoYes
   string cFile[80]
   integer lDeleted = FALSE

   if QFFilesTagged()
      nMenu = YesNo("Confirm before deletion?")
      if nMenu <> 0 and nMenu <> 3
         PushPosition()
         BegFile()
         repeat
            cFile = GetText(DIR_POS, 12)
            cFile = rtrim(substr(cFile, 1, pos(' ', cFile)-1) + "." + substr(cFile,10,3))
            GotoPos(2)
            if (Chr(CurrChar()) == "˚")
               nNoYes = 0
               if nMenu == 1
                  nNoYes = NoYes("Delete " + cFile + "?")
               endif // nMenu == 1
               if nMenu == 2 or nNoYes == 2
                  EraseDiskFile(cPath + cFile)
                  DelLine()
                  up()
               endif // nMenu == 2 or nNoYes == 2
            endif
         until not down()
         PopPosition()
         lDeleted = TRUE
      endif

   endif

   return (lDeleted)
end QFDelTagged

proc QFSetDir(string cPath)

   LogDrive(SplitPath(cPath, _DRIVE_))
   ChDir(SplitPath(cPath, _PATH_))

   return ()
end QFSetDir


integer proc QFDirList(string cSpec)
   string cSpeedKey[12] = ""
   string cFindKey[15]
   string cPath[80]=""
   string cFullPath[80]    // fullpath = drive + path + filename + ext
   string cFile[80]
   string cLine[40]
   string cDir[12]
   string cNewDir[80]
   string cExt[4]=""
   string cZipExe[12] = ""
   integer nRow,
           nKey,
           nWinSize,
           nUpdateType = POP_OPEN,
           lDirectory,
           nMenu,
           lLoadOne = FALSE,
           nModified,
           nError



   string cSortType[1] = "n"
   integer nCurrId, nLastLine
   integer nDirId

   nCurrId = GetBufferId()              // save current buffer id

   cFullPath = mExpandPath(cSpec)
   cPath = SplitPath(cFullPath, _DRIVE_ | _PATH_)

   // Get the name of the ZIP program
   cZipExe = QFGetOption("ZIP", "ZipFile", nError)
   if NOT Length(cZipExe)
      cZipExe="PkZip"
   endif // NOT Length(cZipExe)


   nRow = 1

   nDirId = QFMakeDir(cFullPath, cSortType)

   // set the window size based upon # of items to display and rows available
   nWinSize = Query(ScreenRows)-5

   nRow = 1
   repeat
      message(iif(length(cSpeedKey), "SpeedKey: " + cSpeedKey, ""))
      nKey = QFPopList(cFullPath,
       " ENTER: Load  ESC: Cancel  F1: Help ",nRow, 1, 2, 45, nWinSize,
       query(MenuBorderAttr), query(MenuSelectAttr), nUpdateType,
       Query(MenuTextAttr))
      nUpdateType = POP_NOTHING


      cFile = GetText(DIR_POS, 12)
      cFile = rtrim(substr(cFile, 1, pos(' ', cFile)-1) + "." + substr(cFile,10,3))


      PushPosition()

      // see if this is a directory entry
      cLine = GetText(DIR_POS, 40)
      lDirectory = substr(cLine, 1, 1) == "\"


      // set up a speedkey routine
      if ((nKey) > 47 and (nKey) < 123) or
          (nKey == <backspace> and length(cSpeedKey)) or
          (nKey == 60) or (nKey == <.>)
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

         case nKey
            when <F1>
               QFDirHelp()
            when <ctrl t>
               QFTag(TAG_TAGALL)
            when <ctrl u>
               QFTag(TAG_UNTAGALL)
            when <ctrl r>
               QFTag(TAG_REVERSE)
            when <spacebar>
               QFTag(TAG_TOGGLE)

            when <del>          // delete file
               if (not lDirectory) and YesNoOnly("Delete " + cFile + "?") == 1
                  EraseDiskFile(cPath + cFile)
                  DelLine()
                  nUpdateType = POP_REFRESH
               endif

            when <ctrl d>            // kill tagged files
               if QFDelTagged(cPath)
                  nUpdateType = POP_REFRESH
               endif

            when <ctrl h>       // log into the selected directory
               QFSetDir(cPath)
               QFMessage("Default directory is now " + cPath, 3, FALSE)

            when <ctrl l>       // log into new directory
               cNewDir = cFullPath
               if ask("New directory: ", cNewDir)
                  cNewDir = mExpandPath(cNewDir)
                  if FileExists(SplitPath(cNewDir, _DRIVE_ | _PATH_) + "*.*")
                     cPath = SplitPath(cNewDir, _DRIVE_ | _PATH_)
                     cFullPath = cNewDir

                     AbandonFile()
                     nDirId = QFMakeDir(cFullPath, cSortType)
                     nUpdateType = POP_REFRESH
                     nRow = 1
                  else
                     QFMessage("Invalid directory", 3, FALSE)
                  endif
               endif


            when <ctrl b>       // view binary file
               if not lDirectory
                  QFViewFile(cPath + cFile, TRUE)
                  nKey = 0  // reset nKey so that we don't exit
                  nUpdateType = POP_REFRESH
               endif

            when <ctrl v>       // view file
               if not lDirectory
                  nKey = 0  // reset nKey so that we don't exit
                  cExt=Lower(SplitPath(cFile, _EXT_))
                  if POS(cExt,".zip,.dbf,.frx,.pjx,.mnx,.cdx,.ndx,.ntx,.idx,.mdx")
                     nModified=QFQuickSave(FALSE)
                     if nModified AND YesNoOnly("Save "+ltrim(format(nModified : 3))+" Modified Files? ")==1
                        QFQuickSave(TRUE)
                     endif // nModified
                  endif // POS(cExt,".zip,.dbf,.frx,.pjx,.mnx,.cdx,...")

                  case cExt
                     when ".zip"
                        QFViewMassage(cPath + cFile,"Zip","PKZIP -V",1)
                     when ".dbf", ".scx", ".frx", ".pjx", ".mnx"
                        QFViewMassage(cPath + cFile,"Database Structure","QFDBF",2)
                     when ".exe", ".com", ".bin", ".mac", ".obj"
                        QFViewFile(cPath + cFile, TRUE)
                     when ".cdx", ".ndx", ".ntx", ".idx", ".mdx"
                        QFViewMassage(cPath + cFile,"INDEX","QFX",0)
                     when ".prj"
                        QFMessage("Cannot View a Project File.",5,TRUE)
                     otherwise
                        QFViewFile(cPath + cFile, FALSE)
                  endcase
               endif


            when <ctrl s>       // change sort order
               QFSortDir(cSortType, TRUE)
               nUpdateType = POP_REFRESH

            when <enter>,<greyenter>  // if on a directory entry, change directory
               if lDirectory
                  nMenu = 1
                  if QFFilesTagged()
                     nMenu = QuitCD()
                  endif
                  case nMenu
                     when 1   // change directory

                        cDir = Trim(GetText(DIR_POS + 1, 12))
                        cPath = cPath + cDir + "\" + SplitPath(cFullPath, _NAME_ | _EXT_)

                        AbandonFile()

                        cFullPath = mExpandPath(cPath)
                        cPath = SplitPath(cFullPath, _DRIVE_ | _PATH_)
                        nDirId = QFMakeDir(cFullPath, cSortType)

                        nUpdateType = POP_REFRESH
                        nRow = 1
                        nKey = 1

                     when 3
                        nKey = <escape>
                     when 5
                        nKey = 0
                  endcase
               endif

           endcase
       endif

   until nKey == <escape> or nKey == <enter> or nKey == <greyenter>

   // open the selected file
   if nKey <> <escape>

      if QFFilesTagged()
         nMenu = 1
         if not lDirectory
            nMenu = QuitMenu()
         endif

         case nMenu
            when 1
               BegFile()
               repeat
                  GotoPos(2)
                  if Chr(CurrChar()) == "˚"
                     cFile = GetText(DIR_POS, 12)
                     cFile = cPath + substr(cFile, 1, pos(' ', cFile)-1) + "." + substr(cFile,10,3)
                     if SPLITPATH(cFile,_EXT_)==".prj"
                        QFMESSAGE("Cannot load Project File within QF Directory",5,FALSE)
                     else
                        EditFile(cFile)
                     endif // SPLITPATH(cFile,_EXT_)==".prj"

                     GotoBufferId(nDirId)
                  endif
               until not down()
            when 2
               lLoadOne = TRUE
         endcase
      else
         lLoadOne = TRUE
      endif


      if lLoadOne
         if SPLITPATH(cFile,_EXT_)==".prj"
            QFMESSAGE("Cannot load Project File within QF Directory",5,FALSE)
         else
            EditFile(cPath + iif(substr(cPath, length(cPath), 1) == "\", "", "\") + cFile)
            nCurrId = GetBufferId()
         endif // SPLITPATH(cFile,_EXT_)==".prj"
      endif


      AbandonFile(nDirId)

   else
      AbandonFile()
   endif // nKey <> <escape>

   GotoBufferId(nCurrId)

   // close the popup picklist
   QFPopList("", "", nRow, 1, 2, 66, nWinSize, 0, 0, POP_CLOSE, 0)

   return (nKey <> <escape>)
end QFDirList




proc main()
   integer nHistory
   integer nMsgLevel
   integer nKillMax,
           nSaveAttr,
           nLoadDir=TRUE
   string cFileName[80] = ""

   // turn off undelete for now
   nKillMax = set(KillMax, 0)

   nMsgLevel = SET(MsgLevel, _NONE_)


   nHistory = GetGlobalInt("QFDIR_HISTORY")
   if not nHistory
      nHistory = GetFreeHistory("QFDIR:DIR")
      SetGlobalInt("QFDIR_HISTORY", nHistory)
   endif // not nHistory

   if Length(GetGlobalStr("gcQFDir"))
      cFileName=GetGlobalStr("gcQFDir")
   else
      cFileName = SplitPath(CurrFileName(), _DRIVE_ | _PATH_) + "*.*"
      if not ask("QFDir Filespec:", cFileName, nHistory)
         nLoadDir=FALSE
      endif // ask("Filespec?", cFilename)
   endif // Length(GetGlobalStr("gcQFDir"))
   if nLoadDir
      if FileExists(SplitPath(cFileName, _DRIVE_ | _PATH_) + "*.*")

         PushPosition()

         AddHistoryStr(cFileName, nHistory)


         // Clear the background screen to black
         nSaveAttr = Set(Attr, Color(White on Black))
         // ClrScr()
         Set(Attr, nSaveAttr)

         PushBlock()
         if QFDirList(cFileName)
            KillPosition()
            PushPosition()
         endif
         PopBlock()

         UpdateDisplay(_HELPLINE_REFRESH_)

      else
          QFMessage("Invalid directory", 3, FALSE)
      endif

   endif // nLoadDir



   // re-enable undelete
   Set(KillMax, nKillMax)
   Set(MsgLevel, nMsgLevel)

   UpdateDisplay(_ALL_WINDOWS_REFRESH_)

   PopPosition()
   if Length(GetGlobalStr("gcQFDir"))
      SetGlobalStr("gcQFDir","")
   endif // Length(GetGlobalStr("gcQFDir"))
end main

