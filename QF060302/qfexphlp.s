/*
Program....: qfexphlp.s
Version....: 3.5
Author.....: Randy Wallin & Ryan Katri
Date.......: 12/18/92  04:33 pm   Last Modified: 08/30/95 @ 07:58 am
Notice.....: Copyright COB System Designs, Inc., All Rights Reserved.
Compiler...: TSE 2.5
Abstract...: QFEXPHlp = Quiet Flight Expand Help - does just that.
QFRestore..: ¯1,1®
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
#include ["QFPATH.INC"]
#include ["QFLOCAL.INC"]

// From QF.S with modification to look for current extension,
// save/reset both the FindOptions and the Delete History.

proc QFOpenCfg(integer lEditCfg, string cExt)
   string cCfgPath[60]="",
          cLookFor[60]="",
          cFindOpts[15]=Query(FindOptions)
   integer nExpandBuf, nSetMessage,
           nKillMax=Set(KillMax,0)             // turning off Delete History

   cCfgPath = QFGetPath("QF.INI")

   if FileExists(cCfgPath + "QF.INI")
      if lEditCfg
         editfile(cCfgPath+"Qf.INI")
         cLookFor = "^\[EXPANSION @=.@\" + cExt + "{]}|{ .@\]}\c"
         BegFile()
         if lFind(cLookFor,"ix")
            ScrollToRow(1)
            down()
            BegLine()
         endif // lFind(cLookFor,"ix")
         message(EDIT_SAVE_EXPHLP_LOC)
      else
         nSetMessage = Set(MsgLevel, _WARNINGS_ONLY_)     // get and save setting
         PushPosition()
         PushBlock()

         if GetGlobalInt("nExpandBuf")
            Message(cCfgPath + "Qf.ini "+ REINIT_EXPHLP_LOC)
            GotoBufferID(GetGlobalInt("nExpandBuf"))
            AbandonFile()
         endif // GetGlobalInt("nExpandBuf")

         nExpandBuf = CreateTempBuffer()
         if nExpandBuf
            InsertFile(cCfgPath + "qf.Ini")
            SetGlobalInt("nExpandBuf", nExpandBuf)
            SetGlobalStr("QfCfg", cCfgPath + "qf.ini")
         endif
         PopBlock()
         PopPosition()
         Set(MsgLevel, nSetMessage)
      endif // lEditCfg
      Set(FindOptions,cFindOpts)
   else
      alarm()
      warn(ERR_EXPHLP_LOC)
   endif // FileExists(cCfgPath + "QF.INI")
   Set(KillMax,nKillMax)

end QFOpenCfg

integer proc ExpFind(var string cLookFor, var string cInsertMsg, var integer nExpandBuf, var integer nExpHelpID)
     string cFindOpts[3]="ix"
     GotoBufferId(nExpandBuf)
     BegFile()
     if lFind(cLookFor, cFindOpts)
          GotoBufferID(nExpHelpID)
          AddLine(cInsertMsg)
          AddLine()
          BegLine()
          GotoBufferID(nExpandBuf)
          Down()
          BegLine()
          PushBlock()
          MarkLine()
          if lFind("^\[",cFindOpts)
             Up()
          else
            EndFile()
          endif // lFind("^\[",cFindOpts)
          lFind("[~ /t]","xb")
          Copy()
          GotoBufferId(nExpHelpID)
          EndFile()
          Paste()
          EndFile()
          Down()
          BegLine()
          GotoBufferID(nExpandBuf)
          PopBlock()
          return(TRUE)
    endif // lFind
    return(FALSE)
end ExpFind

proc CleanUpExp()
   // Clean up - cleans up the expressions for presentation.
   // 2 parts - 1. delete all comments
   //           2. Remove the Curly Brace for
   integer nContinue=TRUE,
           nCurrLine=0
   BegFile()
   while nContinue
         if lFind("^\;","ix")
            DelLine()
         else
            nContinue=FALSE
         endif // lFind("^\;","ix")
   endwhile // nContinue
   nContinue=TRUE
   while nContinue
         BegFile()
         if lFind("\=\{","x")
            right()
            PushPosition()
            DelChar()
            lFind("^[~ ]","x")
            MarkColumn()
            if lFind("^\}","x")
               nCurrLine=CurrLine()
               Up()
               GotoPos(80)
               Set(Marking,OFF)
               down()
               DelLine()
               Cut()
               PopPosition()
               Paste()
               GotoLine(nCurrLine)
               EndLine()
               MarkStream()
               if lFind("^[~ ]","x")
                  up()
               else
                  EndFile()
               endif // lFind("^[~ ]","x")
               DelBlock()
            else
               KillPosition()
               UnMarkBlock()
            endif // lFind()
         else
            nContinue=FALSE
         endif // lFind("\=\{","ix")
   endwhile // nContinue
end CleanUpExp

proc qfexphelp()
     string cExt[4]=SplitPath(CurrFileName(),_EXT_),
            cLookFor[60]="",
            cLine[80]="",
            cFindOpts[15]=Query(FindOptions),
            cInsertMsg[80]=""

     integer  nCurrentID=GetBufferID(),
              nExpandBuf = GetGlobalInt("nExpandBuf"),
              nExpHelpID=0,
              nClipBoardID=Query(ClipBoardId),       //
              nTempBoardID=CreateTempBuffer(),     // opening new Clip/Buffer
              nKillMax=Set(KillMax,0),             // turning off Delete History.
              nPassOne=0,
              nPassTwo=0,
              lEditCFG=0
     GotoBufferID(nCurrentID)
     if nExpandBuf==0
        warn(NOINI_EXPHLP_LOC)
     else
        Set(ClipBoardId,nTempBoardID)
        nExpHelpID=CreateBuffer("4Show")
        if NOT nExpHelpID
           Return()
        else
            EmptyBuffer()
            AddLine(BANNER_EXPHLP_LOC)
            if length(cExt) > 1
               cLookFor = "^\[EXPANSION @=.@\" + cExt + "{]}|{ .@\]}\c"
               cInsertMsg = ASSIST_EXPHLP_LOC
               nPassOne = ExpFind(cLookFor,cInsertMsg,nExpandBuf,nExpHelpID)
            endif
            cLookFor = "^\[EXPANSION=Default\c"
            cInsertMsg = GENERAL_EXPHLP_LOC
            nPassTwo=ExpFind(cLookFor,cInsertMsg,nExpandBuf,nExpHelpID)
            GotoBufferID(nExpHelpID)
            if nPassOne OR nPassTwo
               CleanUpExp()
               BegFile()
               PushKey(<CursorDown>)
               PushKey(<CursorDown>)

               If lList(QFABBR_EXPHLP_LOC + cExt, 80, Query(ScreenRows), _ENABLE_SEARCH_ + _ENABLE_HSCROLL_ )
                   if CurrLine()==1
                      lEditCfg=TRUE

                   else
                      cLine=GetText(1,80)
                      if pos("=",cLine)
                         cLine=SubStr(cLine,1,pos("=",cLine)-1)
                      else
                         cLine=""
                      endif // pos("=",cLine)
                   endif // CurrLine()==1

               Endif // List
            else
               Message(NOEXP_EXPHLP_LOC)
            endif // nPassOne OR nPassTwo
            AbandonFile()
            GotoBufferID(nCurrentID)
            if Length(cLine)
               InsertText(cLine)
            endif // Length(cLine)
            Set(FindOptions,cFindOpts)
            Set(ClipBoardId,nClipBoardID)
        endif // ! nExpHelpID
     endif // nExpandBuf==0
     AbandonFile(nTempBoardID)
     Set(KillMax,nKillMax)
     if lEditCfg
        QFOpenCFG(TRUE,cExt)
     endif // lEditCfg
end qfexpHelp

proc main()
     qfexpHelp()
end main
