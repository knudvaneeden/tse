/*****************************************************************************

      MAKE_PG.s                   ver 1.0                      20 Jan 94
                GRAFCO INC 1994       G. Grafton Cole

                  Macro to paganate an flat ASCII file

    This macro will place a formated header at the top of each page and a an
 optional form feed character can be added at the end of the page.  The number
 of lines for the page break is user specified.  A conditional number of lines
 can also be specified.  If for example, the page break is specified as 65 and
 the conditional as 8, the macro will look for a blank line between 65 and
 65 - 8 lines.  If not found the page break will be placed and 65.

    The second line is added after the header line.  The line defaults to
 ASCII character 205 (อ), but may be filled with any ASCII character.
 The width of the header and second line are calculated according to the
 header width menu entry.

    Due to the nature of code (pascal, assembly, etc.) there is also an
 interactive method of placing page breaks.  The macro will make a guess and
 you are able to place the cursor on the line you want the break to occur. You
 proceed thru the file placing breaks where you want them.  A status line
 shows the cursor line number of the current page.  During interactive mode
 the ONLY keys active are cursor up or ^KE, cursor down or ^KX, Esc (abort),
 and Enter (place header/page break).  If you abort midway in a file, lines
 placed before the abort remain.

    Option leadin characters can be placed in column 1 for the header, fill
 line, and form feed character, ie '//' for tse macros, ';' for assembly, etc.

    A line ID character, ASCII 255, is added to the beginning of all added
 lines, but after the optional leadin characters,  to allow the pre-processor
 to locate these lines if you want to strip them at a later date.

    If page numbers are included in the header, the  macro will, after
 paganation is complete, go back and place the total number of pages in the
 header 'page # of #'.

    The filename defaults to the current file, but you may specify a path and
 filename which the macro will try to open.

    There is a pre-process mode that will strip header lines and form feeds.
 You can exit after the pre-process or continue to place new header and form
 feeds.  All lines to be deleted are located by searching for the line ID
 character, thus the ID must be unique .

    As mentioned, if the interactive process is aborted the lines placed before
 the abort remain.  This should be no problem since the disk file can be
 reloaded over the dirty file.


  20 May 94 add pre-process mode
   4 Mar 94 correct interactive page and line numbers calculations
  18 Oct 94 add line ID character to 2ed line so preprocessor can delete
  20 Oct 94 add path to file spec
   6 Dec 94 put line ID character selection in menu

*****************************************************************************/

  string hsS [25] = "",           // header user string
         hfS [25] = "",           // header file name string
         hdS [8]  = "",           // header date string
        lppS [3]  = "65",         // lines per page
        CpbS [3]  = "8",          // condition page break # of lines
         lID [1]  = "ÿ",          // line ID character, ASCII 255
         lcS [3]  = "",           // leadin characters
         blS [1]  = "อ",          // 2ed line fill character
         cpp [3]  = "75"          // header line width
  integer hdT = 1,                // date toggle
          hpT = 1,                // page toggle
          ffT = 1,                // form feed toggle
          inT = 0,                // interactive mode toggle
          ppT = 0,                // pre-process toggle
          exT = 0,                // exit after pre-process toggle
          ppl = 0,                // interactive mode page line number
           pn = 1,                // page number
          HLT = 0                 // abort = 1

proc Initilize()
  ppT = 0
  exT = 0
  ppl = 1
  pn  = 1
  HLT = 0
end

//========================= Write Header Line =================================
proc PutHeader()
    string hpS[12] = "page "+ Str(pn) + " of"
    integer   w = (Val(cpp) - 74) / 4,      // add space depending on width
             ww = Val(cpp) + w              // fill line width

    hdS = iif(hdT, hdS, "")                 // header date toggle
    hpS = iif(hpT, hpS, "")                 // header page # toggle

    InsertLine(Format(lcS+lID:-(4+w), "file:"+hfS:-(18+w), hsS:-(26+w), hdS:9+w,  hpS:15))
    Addline(iif(Length(lcS)== 0, Format(lID:1,blS:ww:blS), Format(lcS+lID:3,blS:ww-3:blS)))
end

//=================== End interactive process and Abort macro =================
proc Abort()
    EndProcess()
      GotoXY(2, 3)
      WriteLine(Format("":23," PROCESS ENDED -- MACRO ABORTED ","":23))
      Sound(800) Delay(6) NoSound()
    HLT = 1
end

//========================= Interactive process procs =========================
proc Move(integer n)        // calc page line #, move cursor and display stats
    case n
    when 1
      Up()
      ppl = ppl - 1
      Message("")
      GotoXY(1,1)
       WriteLine( Format("*** INTERACTIVE PROCESS ACTIVE *** ",
                         "file line: ", Str(currline()):-5, "":5,
                         "PAGE: ",Str(pn):-4, " LINE: ",Str(ppl):-3,
                         "":10) )
    when 2
      Down()
      ppl = ppl + 1
      Message("")
      GotoXY(1,1)
       WriteLine( Format("*** INTERACTIVE PROCESS ACTIVE *** ",
                         "file line: ", Str(currline()):-5, "":5,
                         "PAGE: ",Str(pn):-4, " LINE: ",Str(ppl):-3,
                         "":10) )
    endcase
end

keydef ProcessKeys
      <enter>       EndProcess()
      <escape>      Abort()
      <ctrl e>      Move(1)
      <cursorup>    Move(1)
      <ctrl x>      Move(2)
      <cursordown>  Move(2)
end

proc Interactive()

     if Enable(ProcessKeys,_EXCLUSIVE_)     // set process key bindings
       Message("")                          // setup for video messages ??
       ppl = CurrLine() - ppl               // update for next process
       GotoXY(1, 1)                         // position for vid messages
       WriteLine( Format("*** INTERACTIVE PROCESS ACTIVE *** ",
                         "file line: ", Str(currline()):-5, "":5,
                         "PAGE: ",Str(pn):-4, " LINE: ",Str(ppl):-3,
                         "":10) )

       GotoXY(2, 1)
       Write("Position with cursor, place page break with ENTER key, ESCAPE to abort ")

       Process()
       ppl = CurrLine()                     // get current line
       Disable(ProcessKeys)                 // END PROCESS
     endif
end

//======================== Do a Conditional Page Break ========================
integer proc ConditionalPB(integer mln)     // mln = max current line #

     PushPosition()                         // save current position
     lFind("^$","xb")                       // find blank line
     if CurrLine() >= mln - Val(CpbS)       // if within conditional range
        KillPosition()                      // use it
        return(CurrLine())
     endif
     PopPosition()
     return(mln)                            // else use current line
end

proc DoIt()
    integer pb   = Val(lppS),                      // # lines between page breaks
            ln   = pb                              // current line


    hdS = GetDateStr()
    GotoLine(1)                                    // position top of file

    while ln < NumLines()
      PutHeader()                                  // insert header line
      GotoLine(ln)                                 // goto next page break
      ln  = iif(CpbS <> "0",ConditionalPB(ln),ln)  // condition page break line

      if inT
        Interactive()                              // go interactive
        ln = ppl                                   // update line #
      endif

      if   HLT   return()                 endif    // abort

      if   ffT   InsertLine(lID+Chr(12))  endif    // inset formfeed

      Down()                                       // position for next header
      pn = pn + 1                                  // increment page number
      ln = ln + pb                                 // increment line
    endwhile
    PutHeader()                                    // last page
    EndFile()
    AddLine(lID+Chr(12))

    if hpT                                         // if header page numbers
       BegFile()
       while lFind("page [0-9]* of","x")           // find header lines and
         lFind("of","")                            // insert total number of
         GotoColumn(CurrCol() + 3)                 // pages
         InsertText(Str(pn))
       endwhile
    endif
end

proc Pre_process()

     BegFile()
     while lFind(lID,"")                        // look for line ID
       DelLine()                                // delete line
     endwhile
     if exT  HLT = 1  endif
end

string proc YN(integer tog)                     // Menu YES NO
    return(iif(tog,"YES","NO"))
end

proc TogDate()  hdT  = iif(hdT,0,1)   end       // date toggle

proc TogPgNum() hpT  = iif(hpT,0,1)   end       // page number toggle

proc TogFF()    ffT  = iif(ffT,0,1)   end       // form feed toggle

proc TogIM()    inT  = iif(inT,0,1)   end       // interactive mode toggle

proc TogPP()    ppT  = iif(ppT,0,1)   end       // pre-process toggle

proc TogEX()    exT  = iif(exT,0,1)   end       // exit after pre-process


proc QUIT()                                     // Menu abort
    HLT = 1
end

//======================== Menu ===============================================
menu PageMenu()
  history
  NoEscape
  x = 8
  y = 2

  "ษอออออออออออออออ MAKE_PG 1.0    HEADER FORMAT ออออออออออออออป",, Skip
  "บ     file:filename  USER COMMENT       DATE page # of #    บ",, Skip
  "บ          Second line -- space or fill character           บ",, Skip
  "ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ",, Skip
  "&Abort"                                   , Quit()             , CloseBefore
  "e&Xecute"                                 ,                    , CloseBefore
  "&Target file spec           " [hfS:25]    , Read(hfS)          , DontClose
  "HEADER OPTIONS"                           ,                    , Divide
  "&User comment       optional" [hsS:25]    , Read(hsS)          , DontClose
  "&Date               optional" [YN(hdT):3] , TogDate()          , DontClose
  "&Page Numbers       optional" [YN(hpT):3] , TogPgNum()         , DontClose
  "&Leadin for header, page break, and second line"
                                 [lcS:3]     , Read(lcS)          , DontClose
  "&Second line fill character " [blS:1]     , Read(blS)          , DontClose
  "&Header width       (for spacing, 74 is the min) "
                                 [cpp:3]     , Read(cpp)          , DontClose
  "PAGE BREAKS"                              ,                    , Divide
  "&Number of Lines per page"    [lppS:3]    , Read(lppS)         , DontClose
  "&Condition Page Break offset   (0 for none)"
                                 [CpbS:3]    , Read(CpbS)         , DontClose
  "&Write Form Feed Characters in file"
                                 [YN(ffT):3] , TogFF()            , DontClose
  "&INTERACTIVE mode    "        [YN(inT):3] , TogIM()            , DontClose
  "PRE-PROCESS"                              ,                    , Divide
  "&Remove all lines with line ID character"
                                 [YN(ppT):3] , TogPP()            , DontClose
  "&Exit after pre_process"      [YN(exT):3] , TogEX()            , DontClose
  "&# Line ID character -- default is ASCII 255"
                                 [lID:1]     , Read(lID)          , DontClose
end

proc CheckFile(string fn)
    string pl[30] = SplitPath(hfS,_DRIVE_|_PATH_)          // target

     if Upper(hfS) <> Upper(SplitPath(fn,_NAME_|_EXT_))    // target <> current
        if FileExists(hfS)                                  // if target exists
           EditFile(hfS)                                    // OPEN else
        else
           EditFile(pl)                                    // open picklist
        endif
        hfS = SplitPath(hfS,_NAME_|_EXT_)                  // set header name
     endif
end

proc main()
    string cfs[30] = SplitPath(CurrFilename(),_DRIVE_|_EXT_), // current filspec
           cfn[12] = SplitPath(CurrFilename(),_NAME_|_EXT_)   // current filename ext

    hfS = cfn
    Initilize()
    PageMenu()
      if  HLT  return()       endif        // abort
    CheckFile(cfs)                         // check current against menu entry
      if  HLT  return()       endif        // abort
    if ppT  Pre_process()     endif
      if  HLT  return()       endif        // abort
    DoIt()
      if  HLT  return()       endif        // abort
end
