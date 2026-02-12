//*************************************************************************
/************************  Start Comment Area *****************************
File:  comment5.s                                 Tuesday -  June 22, 1993
                                                 Thursday -  June 24, 1993
                                                   Friday -  June 25, 1993
                               TSE Macro
                         COMMENTER version 0.05
      ÷÷    TAKnet Information Service  Fort Wayne, Indiana    ÷÷
      ÷÷        Thomas A. Klein; a.k.a Tom Klein, tak'y        ÷÷

  Use, abuse or modify this macro to suit your own needs - \\\...tak

  Here's a TSE macro that will place comment characters in front of
  blocked text. It lets you choose from several common comment formats.
  e.g.  `//' `:' `REM' ; or spaces(3-spaces)

  For all commented lines the text is moved over three spaces for all
  comment characters except 'REM' which is moved over four spaces.

=========================================================================
___Original Line above:

   Samples of Commenter Below 
// =========================================================================
:  =========================================================================
:: =========================================================================
REM =========================================================================
;  =========================================================================
   =========================================================================

comment5:
06/25/93:  TAK-  First public offering - version 0.05 as 'comment5.zip'

06/25/93:  TAK - Added <space> as a comment character.  When selected it
                 has the effect of moving columns and wrapping text is
                 WordWrap is selected.  Comment to line now does not
                 require block marking, just press comment 'hot key'.
                 Multiple lines may be marked with multiple presses.

06/24/93:  TAK - general cleanup, '// ' now default with comments added
                 instructing the macro user how to change the source
                 file to select the character on the first_pass through
                 the editor.

comment4:
06/22/93:  TAK - still no fix for no comments on lines added by WrapPara(),
                 comment character is now selected only on the
                 'first_pass' thru the macro, moved ChooseChar() to
                 CommenterMenu.  Also on menu are WordWrap toggle, Set
                 Left & Right margins

comment3:
06/16/93:  TAK - remove BackWrap() & WrapPara() and use the TSE internal
                 WrapPara() instead.  Problems listed below. v0.03
comment2:
06/08/93:  TAK - fix no comments on if line BackWrap()  added lines
06/07/93:  TAK - first revision to add BackWrap() & WrapPara() and spacing.
06/07/93:  TAK - making all revisions from this date forward.

05/30/93:  Bob Campbell's original - both comment and reblock

//*************************************************************************
//*************************************************************************

TAK DEFAULT Key Bindings:

< Shift CursorDown >     CommenterMenu()
< Shift CursorLeft >     mLeftMargin()
< Shift CursorRight>     mRightMargin()

<Shift CenterCursor>     mCommentLines()   //Keypad 5/CenterCursor
                                           //NumLock must be ON

//*************************************************************************

'reblock.s' source is within this file and is not needed externally as
was the case with the orginal version.

//*************************************************************************

\\\...tak Change dates are noted above.  These additions to the basic
          macro for adding comments (//, ::, REM) to block marked text
          were:

 1.  Adding WrapPara() to wrap the paragraph so that commented lines
     would not scroll off the screen.

     PROBLEM 1: ColumnBlock marked does not comment lines that may have
                 been added by WrapPara()

     PROBLEM 2: LineMarked block adds a comment line to the original
                paragraph if no line was added by WrapPara().

 2.  Added a menu item to change the right & left margin, WordWrap()

 3.  CommenterMenu() has selections to Select Comment character, WordWrap
     Toggle(ON/OFF), and items to select the right and left margins with
     the current margins displayed.

 4.  Removed the selection of comment character from the Main() loop so
     now if no comment character is chosen the default is '// ' or user
     may change the source code to enable selection on the first_pass
     thru the macro.

     To change the commenting character at anytime choose 'Select Char.'
     from the CommenterMenu() via <Shift CursorDown> key. Selection is
     never prompted and will remain either the default or previously
     selected character until changed via the Commenter Menu.  Current
     character is also displayed on the menu.

Acknowledgements:  Bob Campbell for the original commenting macro.
                   George J. De Bruin for his selection menu in 'boxit'
                   and several unremembered messagers who's ideas I may
                   have adapted or even used outright <BGWD&R>.
                   All of the SemWare Team for such a great platform.

Thanks to all.
===========================================================================
             Original -- Date: 05-30-93  From: BOB CAMPBELL
   Subj: TSE - Comment.s & Reblock.s  Note: Both within this macro
---------------------------------------------------------------------------

  *************************************************************************/
//tak******************* END of Comment Area ******************************


/************************************************************************
  Comment.s  -   Macro places comment characters in front of blocked text
 *************************************************************************/

/************************************************************************

05-30-93: 'comment.s' & 'reblock.s' submitted by Bob Campbell

           Code for LongestLine() is barrowed from LONGSTLN.S by Ray Asbury

   ASSUMPTIONS: ReBlock.s must be available for compiling the original
                'comment.s' but is within this comment# macro so the
                code is standalone and requires nothing else to function.

   GLOBAL VARS: integer h
                string char[1]
                string character1[1]
                string character2[1]
                string character3[1]
                integer first_line, line_no

   LOCAL VARS:
                integer n
                integer Tp=0
                integer Bm=0
                integer h2

 **************************************************************************/

//*************************************************************************
// #include "reblock.s"  // Instead of #include source code is here
//*************************************************************************

/**************************************************************************
  File:  a:\reblock.s         Tuesday -  June 1, 1993 at 0733 hrs.
===========================================================================
  Date: 05-30-93 (23:05) From: BOB CAMPBELL Subj: TSE - Reblock.s
---------------------------------------------------------------------------

ReBlock() will probably come in handy for a lot of macros that use
blocking so I wrote it as an #include file.

It converts MarkLine to Column Blocking.  <-------- important

I plan to improve it by making it work both ways, Column to MarkLine and
MarkLine to Column .

 ************************************************************************/
//tak******************* END of Comment Area ******************************

/************************************************************************
         Reblocks MarkLine blocked text to Column Blocked
*************************************************************************/

/* 05-30-93: Submitted by Bob Campbell

   Code for BigestLine() is barrowed from LONGSTLN.S by Ray Asbury

   LOCAL VARS:
            BiggesttLine():
                integer max_len
                integer last_line
                integer line_no
            ReBlock():
                integer LastCol
**************************************************************************/
//tak******************* END of Comment Area *****************************

//  Code for BiggestLine() is barrowed from LONGSTLN.S by Ray Asbury

Integer first_line, last_line

proc BiggestLine()

     integer         max_len = 0,
                     line_no,
                     first_col

    GotoBlockBegin()
    last_line = Query(BlockEndLine)
    max_len = CurrLineLen()
    line_no = CurrLine()
    first_line = line_no

    while Down() and (CurrLine() <= last_line)
        if CurrLineLen() > max_len
            max_len = CurrLineLen()
            line_no = CurrLine()
        endif
    endwhile

        KillPosition()          // kill pushed position since
        GotoLine(line_no)       // we're going to the new line
    return ()

end BiggestLine

/*************************************************************************/

proc ReBlock()           // ReBlocks  _LINE_ block with _COLUMN_ block
    integer LastCol
    BiggestLine()
    EndLine()
    LastCol=CurrCol()
    GotoBlockEnd()
    GotoColumn(LastCol)
    PushPosition()
    GotoBlockBegin()
    BegLine()
    UnMarkBlock()
    MarkColumn()
    PopPosition()
end ReBlock
/**************************************************************************
    TSE reblock() for changing BlockMarking to ColumnMarking
 **************************************************************************/

//*************************************************************************
//GLOBAL VARIABLES:

    integer h
    string char[1]=" ",
           character1[1]=" ",
           character2[1]=" ",
           character3[1]=" "

//Global Variables for menus 06/24/93 & 06/25/93

string symbol[3]="// "       //Used display current selection in menu
integer first_pass = 0       //0 on first run to select comment character

//*************************************************************************
menu Charmenu()

    Title = "Character Selections"
    Width = 26
    History                         // Added this line rev. 06/01/93
    "&// "
    "&:     Colon"
    ":: "
    "&REM "
    "&;     Semicolon"              // Added '; ' for asm   06/24/93
    "<&sp>  3 spaces"
    "&Quit"

end

//*************************************************************************
proc ChooseChar()

    integer n=Charmenu()

//Global String Variable 'symbol' added for displaying current selection

    case(n)
        when 1
            character1="/"
            character2="/"
            character3=" "
            symbol=character1+character2+character3
        when 2
            character1=":"
            character2=" "
            character3=" "
            symbol=character1+character2+character3
        when 3
            character1=":"
            character2=":"
            character3=" "
            symbol=character1+character2+character3
        when 4
            character1="R"
            character2="E"
            character3="M"
            symbol=character1+character2+character3
        when 5
            character1=";"
            character2=" "
            character3=" "
            symbol=character1+character2+character3
        when 6
            character1=" "
            character2=" "
            character3=" "
            symbol="sp "

        when 7
            character3="Q"
    endcase
first_pass=99
end

//*************************************************************************
Integer proc BoxHeight() // Returns Height of Block

    integer Tp=0, Bm=0
    GotoBlockBegin()
    Tp = CurrLine()
    GotoBlockEnd()
    Bm = CurrLine()
    return(Bm-Tp+1)

end BoxHeight

//*************************************************************************
///Original code with tak revision to add BackWrap            June 22, 1993

proc MoveOver()            // Move block Right by three spaces

    integer col_location
//    string  debug_info[40]

    GotoBlockBegin()
    Cut()
    BegLine()
    if character3 == " "
        Right(3)
    else
        Right(4)
    endif
    Paste()

// UnMarkBlock()                        //original location
// end                                  //MoveOver()
// END MoveOver()                       //original END


//**************************************************************************
//tak <start of changes>                            Tuesday -  June 22, 1993
      if Query(WordWrap)==ON
      WrapPara()
      endif
      GoToLine(first_line)
      UnMarkBlock()                       //From original code

end MoveOver

// ************************************************************************
// New end of MoveOver()  Tuesday -  June 22, 1993
// ************************************************************************

proc fillchar()          // Fill vertical block with comment character

    integer h2=h
    MarkColumn()
       While(h2>=1)
           Down()
           h2=h2-1
       Endwhile
    FillBlock(char)
    UnMarkBlock()
end

//*************************************************************************
proc Comment()           // Selects columns for comment characters

    char=character1      // fills column one
    BegLine()
    pushposition()
    FillChar()

    char=character2      // fills column two
    UnMarkBlock()
    popposition()
    pushposition()
    Right(1)
    FillChar()

    char=character3      // fills column three
    UnMarkBlock()
    popposition()
    Right(2)
    FillChar()
    UnMarkBlock()
end


//*************************************************************************
//Previously main() macro
//*************************************************************************

proc mCommentLines()

// On the first pass select the default comment characters and
// thereafter don't ask.  To change character use the CommenterMenu.

if first_pass==0

// Sets default comment character to '// '

      character1="/"
      character2="/"
      character3=" "
      symbol=character1+character2+character3

//  If you want to select the comment character the first time the macro
//  is run the comment out the above default and uncomment the items
//  below. A selection will occur only on the first_pass.  If you want
//  to change the after the first pass then use the menu 'Select Char.'
//  item.

//      ChooseChar()
//          if character3=="Q"
//          return()
//      endif

   first_pass=99

endif

    if isBlockInCurrFile() == FALSE
        markline()
    endif
    ReBlock()
    h=BoxHeight()
    if h>=1
        h=h-1
        MoveOver()      //now contains WrapPara()
        Comment()
        Copy(_append_)
    endif
    BegLine()
    GoToLine(last_line +1)    //This allows marking single lines without
                              //having to mark any block. Uses CurrLine

end  mCommentLines

// <Shift CenterCursor>  mCommentLines()   //Keypad 5/CenterCursor

//***********************************************************************/
// Monday -  June 7, 1993  Macros to view and/or set Right & Left Margins
// mRightMargin()-keypad 6/CursorRight; mLeftMargin()-keypad 4/CursorLeft
//***********************************************************************/


Proc mRightMargin()
    string fn[3] = ""
    Message("Current Right Margin: ",Query(RightMargin))
    if Ask("Right Margin: ",fn) and Length(fn)
        Set(Rightmargin,Val(fn))
    endif
End  // bound to keypad 6/CursorRight

Proc mLeftMargin()
    string fn[3] = ""
    Message("Current Left Margin: ",Query(LeftMargin))
    if Ask("Left Margin: ",fn) and Length(fn)
        Set(LeftMargin,Val(fn))
    endif
End  // bound to keypad 4/CursorLeft

//*************************************************************************
//*************************************************************************

/* ------------------------------------------------------------------- */
// Used for CommenterMenu ON/OFF Toggle                       06/17/93
        string proc OnOffStr(integer i)
            return (iif(i, "On", "Off"))
end
/* ------------------------------------------------------------------- */

menu CommenterMenu()

    Title = 'Commenter 0.05 Menu'
    NoKeys
    History
    "",,Skip
    "&Add comment to Block", mCommentLines()
    "&Select Char.  Now -->"[Symbol:3],ChooseChar()
    "&PURGE This Macro", PurgeMacro(CurrMacroFileName())
    "",,divide
    "        SET Options",,Skip
    "",,divide
    "&WordWrap"   [OnOffStr(Query(WordWrap)):3], Toggle(WordWrap),
           DontClose
    "&RIGHT Margin"  [Query(RightMargin):3], mRightMargin(), DontClose
    "&Left Margin"   [Query(LeftMargin):3],  mLeftMargin() , DontClose

end // CommenterMenu()

// TAK keypresses: NumLock=ON and use Keypad with no Shift key press

< Shift CursorDown >     CommenterMenu()
< Shift CursorLeft >     mLeftMargin()
< Shift CursorRight>     mRightMargin()

<Shift CenterCursor>     mCommentLines()   //Keypad 5/CenterCursor
                                           //NumLock must be ON
/**************************************************************************
 Two macros:  reblock.s and comment.s - combined for comment#.s   06/22/93
 Thursday -  June 24, 1993;
**************************************************************************/
