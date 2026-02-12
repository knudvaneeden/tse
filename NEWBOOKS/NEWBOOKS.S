/*************************************************************************
  NEWBOOKS.S

  Copyright 1995 James Coffer.  All Rights Reserved Worldwide.

  Author:     James Coffer

  Date:       September 9, 1995 Version 3.00

  Copyright 1995 James Coffer.  All Rights Reserved Worldwide.

          Permission is granted to all persons for non-commercial
          distribution of this file and the macros and ideas contained
          herein provided (a) credit is given to the author and (b) all
          changes not made by the author are attributed.

          Permission is granted to SemWare for commercial distribution
          provided (a) and (b) above.

  Author:     James Coffer

*************************************************************************/
string Lbmc[1] = ''

integer proc mMarkSetup ()
   integer tid
   integer bn = 1
   integer fm = 0
   string s[80]

   PushPosition ()
   tid = CreateTempBuffer ()

   while bn <= 26
      if GotoMark (Chr (64+bn) )
         s = Format ('@', Chr (64+bn), ' ',
           SplitPath (CurrFilename (), _NAME_ | _EXT_):-12,
           CurrLine ():6, ' ',
           GetText (PosFirstNonWhite (), 56) )
         GotoBufferId (tid)
         AddLine (s)
      else
         fm = iif (fm, fm, bn)
      endif
      bn = bn + 1
   endwhile
   GotoBufferId (tid)
   BegFile ()
   if NumLines () == 0
      return (0)
   endif
   return (iif (fm, fm, 27))
end mMarkSetup

proc mNextBookMark ()
   integer bn = Asc ('Z')

   if Lbmc <> ''
      bn = Asc (Upper (Lbmc) )
   endif
   Lbmc = Chr (bn)
   repeat
      bn = iif (bn > Asc ('A'), bn - 1, Asc ('Z'))
      if GotoMark (Chr (bn))
         Lbmc = Chr (bn)
         return ()
      endif
   until bn == Asc (Lbmc)
   Warn ("No Bookmarks found")
end mNextBookMark

proc mPlaceBookMark ()
   integer fm = mMarkSetup ()
   string bmc[1] = ''

   if fm <= 26
      bmc = Chr (iif (fm, 64+fm, Asc ('A')) )

   endif

   AbandonFile ()
   PopPosition ()
   if bmc <> ''
      PlaceMark (bmc)
      Message ("Placed Bookmark @", bmc)
      Lbmc = bmc
   endif
if fm == 27
      Message ("To many Bookmark Please Use DelBookMark To delete any one...")
endif
end

integer tid

proc MarkSetup ()
   integer bn = 1
   integer fm = 0
   string s[80]=''

   PushPosition ()
   tid = CreateTempBuffer ()

         GotoBufferId (tid)
AddLine ("þþþþþþþþþþþþþþþþþþ Please Use Help Line Below Or <F1> For Help þþþþþþþþþþþþþþþþþ")
   while bn <= 26
      if GotoMark (Chr (64+bn) )
         s = Format ('@', Chr (64+bn), ' ',
           SplitPath (CurrFilename (), _NAME_ | _EXT_):-12,
           CurrLine ():6, ' ',
           GetText (PosFirstNonWhite (), 50) )
         GotoBufferId (tid)
         AddLine (s)
      else
         fm = iif (fm, fm, bn)
      endif
      bn = bn + 1
   endwhile
   GotoBufferId (tid)
   BegFile ()
   if NumLines () == 0
   return ()
   endif
   return ()
end MarkSetup

/***************************************************************************/

proc MarkIt()

if CurrLine() == 1
        return()
        endif
    GotoColumn(79)
    If CurrChar() == ASC('')
        InsertText(' ', _OVERWRITE_)
    else
        InsertText('', _OVERWRITE_)
    endif
end MarkIt

proc DelIt()
if CurrLine() == 1
        return()
        endif
        if YesNo('Delete Mark ... ')
            PlaceMark (GetText (2, 1) )
            DelLine()
        endif
end

proc DelItMarked()
        if YesNo('Delete All marked files') == 1
            if YesNo("Are you sure") == 1
                PushPosition()
                PushBlock()
                UnMarkBlock()
                EndFile()
                GotoColumn(79)
                MarkColumn()
                BegFile()
                MarkColumn()
                if LFind('', 'gl')
                    repeat
                        PlaceMark (GetText (2, 1) )
                        DelLine()
                        GotoBlockBegin()
                    until NOT LRepeatFind()
                endif
                PopPosition()
                PopBlock()
         endif
     endif
end

string bmc[1] = ''

proc mGotoMark ()
bmc = GetText (2, 1)
end

integer proc PutOnStatusLine()
    if Query(StatusLineAtTop)
        VGotoXY(1,1)
    else
        VGotoXy(1,Query(ScreenRows))
    endif
    PutHelpLine(
Format('  The Author of This Ver Of BookMark Is James Coffer (817) 831-1980 Ft Worth Tx '))
    return(TRUE)
end

helpdef BookMarkHelp
    x = 2
    y = 2
    width = 80
    height = 22
    title = "BookMark Help"

    "<F1>                QuickHelp(BookMarkHelp)"
    "<F7>                Delete All Marked Book Marks"
    "<Home>              BegFile()"
    "<CursorDown>        Down()"
    "<CursorLeft>        Left()"
    "<CursorRight>       Right()"
    "<CursorUp>          Up()"
    "<End>               EndFile()"
    "<Del>               DelIt()"
    "<Enter>             mGotoMark ()"
    "<Escape>            EndProcess()"
    "<PgDn>              PageDown()"
    "<PgUp>              PageUp()"
    "<SpaceBar>          MarkIt()"

end

keydef keys

    <HelpLine>          '{<F1>} Help {<Del>} BookMark {<SpaceBar>} MarkIt {<F7>} Del Marked Marks {<Enter>} Goto'
    <F1>                QuickHelp(BookMarkHelp)
    <F2>
    <F3>
    <F4>
    <F5>
    <F6>
    <F7>               DelItMarked()
    <F8>
    <F9>
    <F10>
    <F11>
    <Home>              BegFile()
    <CursorDown>        Down()
    <CursorLeft>        Left()
    <CursorRight>       Right()
    <CursorUp>          Up()
    <Del>               DelIt()
    <End>               EndFile()
    <Enter>             if CurrLine() == 1
                        return(0)
                        endif
                        mGotoMark ()
                        EndProcess()
    <Escape>            EndProcess()
    <PgDn>              PageDown()
    <PgUp>              PageUp()
    <SpaceBar>          MarkIt()
end

proc mListFiles()
    integer ssl     = Set(StatusLineUpdating, Off),
            hl      = Set(ShowHelpLine, ON),
            msgl    = Set(MsgLevel, _WARNINGS_ONLY_),
            scattr  = Set(CursorAttr, iif(Query(AttrSet) == _COLOR_, Color(Bright White on Green), Color(Black on White))),
            seof    = Set(ShowEofMarker, OFF),
            i

         if PutOnStatusLine()
            Enable(keys, _EXCLUSIVE_)
            Set(Cursor,Off)
            MarkSetup ()
            i = Process()
            Set(Cursor,On)
            AbandonFile ()
            Disable(keys)
        endif
    if i == 2
        KillPosition()
    else
        PopPosition()
    endif
    Set(ShowHelpLine, hl)
    Set(StatusLineUpdating, ssl)
    Set(MsgLevel, msgl)
    Set(CursorAttr, scattr)
    Set(ShowEofMarker, seof)
    UpdateDisplay(_ALL_WINDOWS_REFRESH_)
    if Query(Key) == <Enter>
    GotoMark (bmc)
    endif
end

<CtrlShift Z> List ("James Coffer", Query (ScreenCols) - 2)

<Alt b>                 mListFiles()
<Ctrl F>                mListFiles()
<Ctrl e>                mNextBookMark()
<Ctrl q>                mPlaceBookMark()

