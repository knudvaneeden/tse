/*
Program....: qfx.s
Version....: 3.5
Author.....: Randy Wallin & Ryan Katri
Date.......: 08/03/93  06:56 am  Last Modified: 08/30/95 @ 07:58 am
Notice.....: Copyright 1993 COB System Designs, Inc., All Rights Reserved.
QFRestore..: ¯1,1®
Compiler...: TSE 2.5
Abstract...: QFX calls our QFX.EXE to build or display index keys.
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
#include ["QFString.INC"]
    // Includes:
    // integer proc rat (string lookfor, string in_text )
    // string proc rtrim( string st )
    // string proc ltrim( string st )
    // string proc QFGetWordAtCursor()
    // string proc QFGetFirstWord()
    // string proc Proper(string cStr)
    // string proc GetWordAtCursor()
#include ["QFPATH.INC"]
#include ["QFAllSav.INC"]
#include ["QFMSG.INC"]
constant
   SCREEN_OUT  = 1,
   PRINTER_OUT = 2,
   QFX_LIST  = 3


menu QFFullPartial()
       "&Full Listing"
       "&Partial"
       "&Cancel"
end QFFullPartial


Menu QFXMenu()
   "&Screen Output"
   "&Printer Output"
   "Build &Index Key List"
   "",, Divide
   "&Cancel"
end



// Display a browse list of the database fields
integer proc MakeKey(string cFileSpec, string cOutput)
   string cPath[60]=""
   integer nModified=0
   message("Loading Index Key Listing. . .")
   cPath=QFGetPath("QFX.EXE")
   if FileExists(cPath+"QFX.EXE")
      // get all directory entries
      nModified=QFQuickSave(FALSE)
      if nModified AND YesNoOnly("Save "+ltrim(format(nModified : 3))+" Modified File" +iif(nModified>1,"s?","?"))==1
         QFQuickSave(TRUE)
      endif // nModified
      if pos(">",cOutPut)
         dos(cPath+"QFX " + cFileSpec + cOutPut, 2)
      else
         dos(cPath+"QFX " + cFileSpec + " > " + cOutPut, 2)
      endif // pos(">",cOutPut)
      if FileExists(cOutPut)
         EditFile(cOutput)
         EraseDiskFile(cOutput)
      endif // FileExists(cOutPut)
      message("")

      return (GetBufferId())
   endif // FileExists(cPath+"QFX.EXE")

   QFMESSAGE("QFX.EXE File was not found.",TRUE,10)
   return(0)

end MakeKey


proc DIRList(string cSpec)
   integer nListType,
           nCurrID
   integer lQuit = FALSE
   integer nWarnStmt=0,
           nChoice=0
   string cFile[80]="",
          cSafeName[120]=""

   nCurrId = GetBufferId()              // save current buffer id

   while not lQuit
      lQuit = TRUE
      if Pos("*",cSpec) OR POS("?",cSpec)
         nChoice=QFFullPartial("Process All or one?")
         case nChoice
            when 1   // Full
                 cFile=cSpec
                 cSafeName=SplitPath(cFile,_DRIVE_ | _PATH_)+"ALL.KEY"
            when 2   // Partial
                 cFile = PickFile(cSpec)
                 cSafeName=SplitPath(cFile, _DRIVE_ | _PATH_ | _NAME_)+".KEY"
            otherwise
                 cFile=""
         endcase // nChoice
      else
         cFile = cSpec
         cSafeName=SplitPath(cFile, _DRIVE_ | _PATH_ | _NAME_)+".KEY"
      endif // Pos("*",cSpec) OR POS("?",cSpec)

      if length(cFile)

         nListType = QFXMenu()
         case nListType
            when QFX_LIST
               if MakeKey(cFile,  " /B >" + cSafeName)
                  lQuit = TRUE
                  QFMessage("Key List is saved in "+cSafeName,0,0)
               endif
            when SCREEN_OUT
               nWarnStmt=MakeKey(cFile, cSafeName)
               IF nWarnStmt
                  // At this point we can SaveFile() or do this forceChange(FALSE)
                  // What do you think?
                  FileChanged(FALSE)
                  // GotoBufferID(nCurrId)
                  if isZoomed()
                     ZoomWindow()
                  endif // isZoomed()
                  nWarnStmt = WindowID()
                  HWindow()  // maybe make this VWINDOW() ???
                  PrevFile()
                  GotoWindow(nWarnStmt)
               Endif // MakeKey()
            when PRINTER_OUT
               if MakeKey(cFile, cSafeName)
                  PrintFile()
                  AbandonFile()
               endif // MakeKey()
         endcase
      endif
   endwhile
end DirList

proc main()
   string cDrive[2]
   string cPath[60]
   string cSpec[60]
   integer nCurrId
   integer nMsgLevel
   integer nKillMax
   integer nHistory

   // turn off undelete for now
   nKillMax = set(KillMax, 0)
   nMsgLevel = SET(MsgLevel, _NONE_)

   nCurrId = GetBufferId()              // save current buffer id

   PushBlock()

   nHistory = GetGlobalInt("QFX_HISTORY")
   if not nHistory
      nHistory = GetFreeHistory("QFX_HISTORY")
      SetGlobalInt("QFX_HISTORY", nHistory)
   endif // not nHistory


   cDrive = SplitPath(CurrFilename(), _DRIVE_)
   cPath = SplitPath(CurrFilename(), _PATH_)
   cSpec = cDrive + cPath + "*.?dx"

   if AskFileName("Index Key Listing for:", cspec, _FULL_PATH_ | _MUST_EXIST_, nHistory)

      AddHistoryStr(cSpec, nHistory)

      DIRList(cSpec)

   endif // Ask

   PopBlock()


   // move to original buffer
   GotoBufferId( nCurrId )

   // re-enable undelete
   set(KillMax, nKillMax)
   Set(MsgLevel, nMsgLevel)

   UpdateDisplay(_ALL_WINDOWS_REFRESH_)

end main


