/*
Program....: qfnote.s
Version....: 3.5
Author.....: Randy Wallin & Ryan Katri
Date.......: 12/06/92  06:52 am  Last Modified: 08/30/95 @ 07:58 am
Notice.....: Copyright COB System Designs, Inc., All Rights Reserved.
Compiler...: TSE 2.5
Abstract...: QFNote allows for a local/global Note File.
QFRestore..: Ø1,1Æ
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

FORWARD Proc CloseNote()


proc QFNLeftBtn()
    integer n=MouseWindowID()
    if (MouseWindowID()) AND (n <> WindowID())
        CloseNote()
     else
        case MouseHotSpot()
           when _MOUSE_CLOSE_
                CloseNote()
           when _MOUSE_ZOOM_
                alarm()
           when _MOUSE_ZOOM_
           otherwise
                if Query(MouseY) == 1
                else
                   MouseMarking(_NONINCLUSIVE_)
                endif

        endcase // MouseHotSpot()

         // if not ProcessHotSpot()
     endif
end

integer proc mbackspace()
    integer p

    if Query(Insert)    // Real programmers are always in insert mode...
        if CurrPos() > 2 and Query(AutoIndent)
            p = PosFirstNonWhite()
            if p == 0 or p == CurrPos()   // if white between cursor and col 1
                return (TabLeft())     // then do an outdent
            endif
        endif
        return (iif(Left(), DelChar(), PrevChar() and JoinLine()))
    else
        if Left()
            InsertText(" ", _OVERWRITE_)
            return (Left())
        else
            return (PrevChar())
        endif
    endif
    Return(0)
end

menu YesNoOnly()  // no cancel
       "&Yes"
       "&No"
end YesNoOnly

menu QFNoteSite()
    Title="QF NotePad Site"
    "&Local NotePad"
    "&Global"
    "", , Divide
    "&Cancel"
end QFNoteSite

proc QFInsFileName()
     string cFileName[14]=""
     integer nCurrentID=GetBufferID()
     UnHook(CloseNote)
     PopPosition()
     cFileName=SplitPath(CurrFileName(),_NAME_|_EXT_)
     Upper(cFileName)
     PushPosition()
     GotoBufferID(nCurrentID)
     InsertText(cFileName +" ")
     Hook(_ON_CHANGING_FILES_,CloseNote)
end QFInsFileName

proc QFTimeDate()
    string cWhat2add[40]
    cWhat2Add=GetDateStr() + " @ "+GetTimeStr()+ " - "
    InsertLine(cWhat2Add)
    EndLine()
end QFTimeDate


proc QFNoteHelp()
   integer nColorSave = 0
   popwinopen( 1,1,38,11,1, "Quiet Flight Note Help",color (bright yellow on cyan))
   nColorSave = Set(Attr, Color(black on white))
   clrscr()
   Set(Cursor,OFF)
   Writeline( " Press           Result ")
   Writeline( " --------------------------------")
   Writeline( " <Ctrl F>        Insert File Name")
   Writeline( " <Ctrl T>        Insert Time/Date")
   Writeline( " <Escape>        Quit Note       ")
   Writeline( " <F1>            Note Help       ")
   Writeline( "  ")
   Writeline( " Press Any Key to continue......  ")
   getkey()
   Set(Cursor,ON)
   popwinclose()
   Set(Attr, nColorSave)

end QFNoteHelp

// HideFileList and RestoreFileList
// These next two procedures are Richard Blackburn's from SEMWARE.
// They enable us to keep control localized in the Note until it's
// time to move on.
// Thanks Richard for letting us use this code.

proc HideFileList(integer nBuffer, integer nNoteID)
    integer nBufferID = 0
    GotoBufferID(nbuffer)
    NextFile()
    repeat
        nBufferID = GetBufferId()
        if nNoteID<>nBufferID
           // PushPosition()
           // GotoBufferId(nBuffer)
           // Changed on 09/30/93 RMK to take advantage of new syntax
           AddLine(Format(nBufferID:-10), nBuffer)
           // PopPosition()
           BufferType( _HIDDEN_)
        endif // nNoteID<>
        NextFile(_DONT_LOAD_)
    until GetBufferId() == nbuffer
    BufferType( _HIDDEN_)
    BegFile()
    while NOT CurrLineLen()
        DelLine()
    endwhile
    GotoBufferID(nNoteID)
    BufferType( _NORMAL_)
end

proc RestoreFileList(integer nBuffer)
    GotoBufferId(nBuffer)
    repeat
        if GotoBufferId(Val(GetText(1,10)))
            BufferType( _NORMAL_)
        endif
        GotoBufferId(nBuffer)
    until NOT Down()
    AbandonFile()
end

proc CloseNote()
     integer nChoice=0
     if FileChanged()
        nChoice=YesNoOnly("Notes Altered. Save?")
       if nChoice==1
          SaveFile()
       endif // nChoice==1
     else
        nChoice=YesNoOnly("Confirm NotePad Exit?")
     endif // FileChanged()
     if nChoice==1
        EndProcess()
     endif //nchoice<>0
end CloseNote

KeyDef Notekeys
   <Escape>                        CloseNote()
   <F1>                            QFNoteHelp()
   <Ctrl F>                        QFInsFileName()
   <Ctrl T>                        QFTimeDate()
   <LeftBtn>                       QFNLeftBtn()
   <BackSpace>                     mBackSpace()
end Notekeys

proc QFNote()
   integer nCurrentBufferID=GetBufferID(),
           nWindowID,
           nMenuChoice,
           nWordWrap,
           nNoteID,
           nNumFiles,
           nBufferID

   string  cPath[60]="",
           cMessage[60]="",
           cNotepad[80]=""
      nMenuChoice=QFNoteSite()
      case nMenuChoice
           when 1  // Local
                cPath=SplitPath(CurrFileName(),_DRIVE_ | _PATH_)
                cMessage="Local "+cPath+"Notes.dat loaded. Press F1 for Help."
           when 2  // Global
                cPath=SplitPath(GetGlobalStr("QfCfg"),_DRIVE_ | _PATH_)
                cMessage="Global "+cPath+"Notes.dat loaded. Press F1 for Help."
      endcase // nMenuChoice
      if nMenuChoice<>4 AND nMenuChoice <> 0
         PushPosition()
         HWindow()
         cNotePad=cPath+"Note.Pad"
         if EditFile(cNotePad)
            nNoteID=GetBufferID()
            UpdateDisplay(_ALL_WINDOWS_REFRESH_)
            nNumFiles=NumFiles()
            nBufferID=CreateTempBuffer()
            BufferType( _NORMAL_)
            HideFileList(nBufferID,nNoteID)
            Message(cMessage)
            nWindowID=WindowID()
            nWordWrap=Query(WordWrap)
            Set(Wordwrap,1)
            Hook(_ON_CHANGING_FILES_,CloseNote)
            if Enable(Notekeys,_DEFAULT_)
               process()
            endif
            unHook(CloseNote)
            RestoreFileList(nBufferID)
            Disable(Notekeys)
            GotoBufferID(nNoteID)
            AbandonFile()
            CloseWindow()
            Message(CurrFileName()+" is Closed.")
            Set(Wordwrap,nWordWrap)
            GotoBufferID(nCurrentBufferID)
            UpdateDisplay(_ALL_WINDOWS_REFRESH_)
            PopPosition()
         else
            DelWindow()
          endif // EditFile
      else
         Message("Quiet Flight Note Cancelled.")
      endif // nMenuChoice<>4 AND nMenuChoice <> 0
end QFNote

proc main()
   QFNote()
end main
