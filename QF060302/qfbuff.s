/*
Program....: qfbuff.s
Version....: 3.5
Author.....: Randy Wallin & Ryan Katri
Date.......: 06/02/93  02:58 pm  Last Modified: 08/30/95 @ 07:58 am
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

#include ["QFRegExp.inc"]
#include ["QFPopLst.inc"]

menu YesNoOnly()  // no cancel
       "&Yes"
       "&No"
end YesNoOnly


menu HelpMenu()
    Title = "QFBuffer Menu"
    X = 48                      // left side
    Y = 3                       // top line
    History = 1
    "&Edit Hilited        <Enter>"
    "&Write Changes       <Ctrl Enter>"
    "&Quit Buffer         <F10>"
    "", , Divide
    "&Delete from project <Del>"
    "&Add to project      <Ins>"
    "&Switch Windows      <Tab>"
    "", , Divide
    "&Cancel"
end HelpMenu



// Although we are hardcoding the keys to the menu, it is just
// too easy to just Push the key to perform the function than
// do it any other way!
proc QFBuffHelp()
   integer nMenu

   nMenu = HelpMenu()

   case nMenu
      when 1
         PushKey(<enter>)
      when 2
         PushKey(<Ctrl Enter>)
      when 3
         PushKey(<F10>)
      when 5
         PushKey(<Del>)
      when 6
         PushKey(<Ins>)
      when 7
         PushKey(<Tab>)
   endcase
end QFBuffHelp



// Don't let the Project Files descriptor line be highlited
proc QFSkipDescript(integer nLastKey)
   if GetText(1,1) == "ƒ"
      if CurrLine() == 1
         PushKey(<CursorDown>)
      elseif CurrLine() == NumLines()
         PushKey(<CursorUp>)
      else
         PushKey(nLastKey)
      endif
   endif

end QFSkipDescript


string proc QFGetCurrFile()
   string cFile[102]

   cFile = GetText(2, 14)
   // Strip off parenthesis if opening a previously un-opened project file
   if substr(cFile, 1, 1) == "("
      cFile = GetText(18, 80) + rtrim(substr(cFile, 2, pos(')' , cFile)-2))
   else
      cFile = GetText(18, 80) + rtrim(substr(cFile, 2, 12))
   endif
   if GetText(1,1) == "ƒ"
      cFile = ""
   endif

   return (cFile)
end QFGetCurrFile


// Create the buffer list of open buffers & current project files
integer proc QFCreateList(integer nCurrID, integer nBuffID, integer nProjID)
   string fn[100], cDefaultDir[80] = "", cSavePos[100]
   string cHeader[30]
   string cTemp1[60]
   string cTemp2[60]
   integer lModified, lProjMember = FALSE
   integer nID
   integer nNumBuffers = 0
   PushBlock()

   GotoBufferID(nBuffID)

   cSavePos = QFGetCurrFile()

   EmptyBuffer()

   // If original file is not open anymore, move to next NON-system buffer
   if not GotoBufferID(nCurrID)
      NextFile()
   endif

   nCurrID = GetBufferID()
   nID = nCurrID


   repeat
      fn = substr(CurrFilename(), 1, 100)
      lModified = FileChanged()

      if GotoBufferId(nProjID)
         lProjMember = lFind(SplitPath(fn, _NAME_ | _EXT_), "ixg")
      endif // GotoBufferID(nProjID)

      // Add buffer information to our buffer list if NOT a project member
      // Project members get added at end of buffer list
      if not lProjMember and SplitPath(fn, _NAME_ | _EXT_) <> "qffake.$$$"
         nNumBuffers = nNumBuffers + 1
         // GotoBufferId(nBuffId)
         // Changed on 09/30/93 RMK to take advantage of new syntax
         AddLine(iif(lModified, '*', ' ') + " " +
                 format(SplitPath(fn, _NAME_ | _EXT_):-13) + "  " +
                 SplitPath(fn, _DRIVE_ | _PATH_), nBuffId)
      endif // not lProjMember

      GotoBufferId(nId)

      // Go to next buffer in cycle
      NextFile(_DONT_LOAD_)
      nId = GetBufferId()

   until nId == nCurrId           // loop through buffer for full cycle

   GotoBufferId(nBuffId)
   BegFile()

   // Sort the list if there are any entries
   // (might not be any if only project files are loaded)
   if NumLines() > 0
      // sort list
      GotoPos(3)
      MarkColumn()
      EndFile()
      GotoPos(100)
      Sort()
   endif // NumLines() > 0

   // Add project files if there is a project open
   if nProjID
      EndFile()
      AddLine("ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ")

      // Add the project members to the end of our buffer list
      GotoBufferID(nProjID)
      BegFile()
      if lFind("QF Project: \c", "igx")
         cHeader = " Project " + ltrim(GetText(CurrCol(), 8)) + " "
         down()
      else
         cHeader = " Project Files "
      endif

      // Center the project header
      GotoBufferID(nBuffID)
      GotoColumn(CurrLineLen()/2 - length(cHeader)/2)
      InsertText(cHeader, _OVERWRITE_)
      GotoBufferID(nProjID)

      repeat
         UnMarkBlock()
         MarkLine()


         // Skip "[DIR=]" directives in the project file
         if lFind("^\[DIR=\c", "ilgx")
            cDefaultDir = GetText(CurrCol(),80)
            cDefaultDir = SplitPath(ExpandPath(substr(cDefaultDir, 1, pos("]", cDefaultDir)-1)),
                                    _DRIVE_ | _PATH_)
         else
            fn = ltrim(GetText(1, 100))
            if length(fn)
               nNumBuffers = nNumBuffers + 1
               fn = ExpandPath(cDefaultDir + GetText(1, 100))
               nID = GetBufferID(fn)

               lModified = FALSE
               if nID
                  GotoBufferID(nID)
                  lModified = FileChanged()
               endif // nID

               // GotoBufferId(nBuffId)
               // Changed on 09/30/93 RMK to take advantage of new syntax
               AddLine(iif(lModified, '*', ' ') + iif(nID, " ", "(") +
                       format(SplitPath(fn, _NAME_ | _EXT_) + iif(nID, "", ")"):-13) + "  " +
                       SplitPath(fn, _DRIVE_ | _PATH_), nBuffId)
            endif // length(fn)
         endif // lFind("^\[DIR=\c", "ilgx")
         GotoBufferID(nProjID)

      until not down()

      GotoBufferID(nBuffID)
      // Sort the project entries
      lFind("^ƒƒƒƒƒƒƒƒƒ", "gx")
      if down()
         GotoPos(3)
         MarkColumn()
         EndFile()
         GotoPos(100)
         Sort()
      endif // down()

   endif

   GotoBufferID(nBuffID)
   cTemp1=QFRegExpr(format(SplitPath(cSavePos, _NAME_ | _EXT_):-12)) + "[ )]" + "  "
   cTemp2= QFRegExpr(SplitPath(cSavePos, _DRIVE_ | _PATH_))
   lFind(cTemp1+cTemp2,"gix")
// Commented out 08/10/94 at 07:08 pm
//   lFind(QFRegExpr(format(SplitPath(cSavePos, _NAME_ | _EXT_):-12)) + "[ )]" + "  " +
//         QFRegExpr(SplitPath(cSavePos, _DRIVE_ | _PATH_)), "gix")

   if substr(GetText(1,1), 1, 1) == "ƒ"
      if not down()
         up()
      endif
   endif // substr(cSavePos,1,1) <> "ƒ"

   PopBlock()

   return (nNumBuffers)
end QFCreateList


// Update buffer position if an entry is deleted
proc QFUpdatePos(integer nBuffID)

   GotoBufferID(nBuffID)
   if not down()
      up()
   endif
   if not length(QFGetCurrFile())
      up()
   endif

end QFUpdatePos


proc QFBuffList()
   string cSpeedKey[12] = ""
   string cFindKey[15]
   integer nLastLine
   string fn[100], cCurrFile[100], cFooter[70]
   integer nCurrID, nBuffID, nProjID, nFakeID
   integer nRow,
           nKey,
           nWinSize,
           nNumBuffers,
           nUpdateType = POP_OPEN
   integer nKeyStat, nMsgLevel


   cCurrFile = CurrFileName()
   nCurrID = GetBufferId()              // save current buffer id
   nBuffID = CreateTempBuffer()
   nProjID = GetGlobalInt("nProjID")


   if nBuffID == 0
      warn("Unable to create buffer list")
      return()
   endif

   nMsgLevel = Set(MsgLevel, _NONE_)
   nKeyStat = Set(EquateEnhancedKbd,ON)



   // Create the buffer list
   nNumBuffers = QFCreateList(nCurrID, nBuffID, nProjID)

   // find the current buffer--make it the initially hilighted one
   lFind(format(SplitPath(cCurrFile, _NAME_ | _EXT_):-13) + "  " +
         SplitPath(cCurrFile, _DRIVE_ | _PATH_), "ig")

   // We create this temp buffer so that if all buffers get closed
   // while in the buffer list, we can still have TSE close properly
   nFakeID = CreateBuffer("QFFAKE.$$$")
   GotoBufferID(nBuffID)

   // set the window size based upon # of items to display and rows available
   nWinSize = iif(NumLines() > Query(ScreenRows)-4, Query(ScreenRows)-4, NumLines())
   nRow = iif(CurrLine() <= nWinSize, CurrLine(), nWinSize / 2)

   nKey = 0
   repeat
      // set the window size based upon # of items to display and rows available
      nWinSize = iif(NumLines() > Query(ScreenRows)-4, Query(ScreenRows)-4, NumLines())

      // Set the row so that all entries may be displayed in the window
      if nWinSize == NumLines()
         nRow = CurrLine()
      endif

      QFSkipDescript(nKey)
      cFooter = " ENTER: Edit  F10: Close  ESC: Cancel  F1: Help "

      message(iif(length(cSpeedKey), "SpeedKey: " + cSpeedKey, ""))
      nKey = QFPopList("QF Buffer List", cFooter,nRow, 5, 2, 65, nWinSize,
       query(MenuBorderAttr), query(MenuSelectAttr), nUpdateType,
       query(MenuTextAttr))
      nUpdateType = POP_NOTHING

      // set up a speedkey routine
      if ((nKey & 0xff) > 47 and (nKey & 0xff) < 123) or
          (nKey == <backspace>) or (nKey == 60) or (nKey == <.>)
         case nKey
            when <backspace>
               cSpeedKey = substr(cSpeedKey, 1, length(cSpeedKey)-1)
            otherwise
               cSpeedKey = cSpeedKey + chr(nKey & 0xff)
               lower(cSpeedKey)
         endcase

         cFindKey = cSpeedKey

         nLastLine = CurrLine()

         // search only the window we're in (Project vs. non-Project)
         if not lFind("^ƒƒƒƒƒƒƒƒƒ", "xb")
            BegFile()
         endif

         if not length(cFindKey) or not lFind("^.." + QFRegExpr(cFindKey), "xqi")
            // Remove speedkey character just typed because it's invalid
            cSpeedKey = substr(cSpeedKey, 1, length(cSpeedKey)-1)
            GotoLine(nLastLine)
         else
            if nLastLine <> CurrLine()
               nUpdateType = POP_REFRESH
            endif
         endif
      else
         // turn off speedkey if an alphanumeric key is not pressed
         cSpeedKey = ""

         // PushPosition()
         case nKey
            when <F1>
               QFBuffHelp()

            when <tab>
               // switch between Project & non-Project windows
               if lFind("^ƒƒƒƒƒƒƒƒƒ", "x")
                  down()
               else
                  BegFile()
               endif
               nUpdateType = POP_REFRESH
            when <ins>, <GreyIns>   // Add file to project
               PushPosition()
               if nProjID and not lFind("^ƒ", "xb")
                  KillPosition()
                  fn = QFGetCurrFile()
                  if YesNoOnly("Add " + fn + " to project?") == 1
                     QFUpdatePos(nBuffID)

                     GotoBufferId(nProjID)
                     // Put it under appropriate directory entry, if there is one
                     // otherwise add it at the end of the project list
                     if not lFind("[DIR=" + SplitPath(fn, _DRIVE_ | _PATH_)+"]", "ig")
                        EndFile()
                        AddLine("[DIR=" + SplitPath(fn, _DRIVE_ | _PATH_) + "]")
                     endif
                     AddLine(SplitPath(fn, _NAME_ | _EXT_))

                     // Re-Create the buffer list
                     nNumBuffers = QFCreateList(nCurrID, nBuffID, nProjID)

                     nUpdateType = POP_REFRESH
                  endif // YesNoOnly("Add " + fn + " to project?")
               else
                  PopPosition()
               endif // lFind("^ƒ", "xb")


            when <del>, <GreyDel>   // Remove file file from project

               PushPosition()
               if nProjID and lFind("^ƒ", "xb")
                  PopPosition()
                  fn = QFGetCurrFile()
                  if YesNoOnly("Remove " + fn + " from project?") == 1
                     QFUpdatePos(nBuffID)

                     // Remove file from project
                     GotoBufferId(nProjID)
                     if lFind(SplitPath(fn, _NAME_ | _EXT_), "gi")
                        delLine()
                     endif // lFind(fn, "gi")

                     // Re-Create the buffer list
                     nNumBuffers = QFCreateList(nCurrID, nBuffID, nProjID)

                     nUpdateType = POP_REFRESH
                  endif
               else
                  KillPosition()
               endif // not lFind("^ƒ", "xb")


            when <Ctrl Enter>, <Ctrl W>     // Write Buffer
               // turn off *modified* indicator
               BegLine()
               InsertText(" ", _OVERWRITE_)
               if GotoBufferID(GetBufferID(QFGetCurrFile()))
                  if FileChanged()
                     SaveFile()
                  else
                     message("No need to save - unchanged.")
                  endif // FileChanged()
               endif // GotoBufferID(GetBufferID(QFGetCurrFile()))

            when <F10>, <Ctrl C>       // Close Buffer
               // Move to the selected buffer
               // If file is modified, ask if we should save it first
               if GotoBufferId(GetBufferID(QFGetCurrFile()))
                  if QuitFile()

                     QFUpdatePos(nBuffID)

                     // Re-Create the buffer list
                     nNumBuffers = QFCreateList(nCurrID, nBuffID, nProjID)

                     nUpdateType = POP_REFRESH
                  endif // QuitFile()
               endif // GotoBufferId(GetBufferID(QFGetCurrFile()))

         endcase // nKey
      endif

      GotoBufferID(nBuffID)

   until nNumBuffers == 0 or nKey == <escape> or nKey == <enter> or nKey == <GreyEnter>

   // close the popup picklist
   QFPopList("", "", nRow, 5, 2, 57, nWinSize, 0, 0, POP_CLOSE, 0)

   // Save our project list if necessary
   if GotoBufferID(nProjID)
      if FileChanged()
         message("Saving project file " + CurrFileName())
         SaveFile()
      endif // FileChanged()
   endif // GotoBufferID(nProjID)

   GotoBufferID(nBuffID)
   fn = QFGetCurrFile()
   if (nKey <> <escape>) and (length(fn))
      EditFile(fn)
      nCurrID = GetBufferID()
   else
      nCurrID = 0
   endif // nKey <> <escape>

   AbandonFile(nBuffID)
   AbandonFile(nFakeID)

   GotoBufferID(nCurrID)

   UpdateDisplay(_HELPLINE_REFRESH_ | _ALL_WINDOWS_REFRESH_)

   Set(EquateEnhancedKbd,nKeyStat)
   Set(MsgLevel, nMsgLevel)
end QFBuffList


proc main()
   QFBuffList()
end main

