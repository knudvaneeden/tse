
// to-do:
// ------
// -screen positioning, esp. after wordwrap!?
// -leading and leading/trailing comment string whitespace?
// -id/delete comments w/ date/time embedded by \d and \h?
// -add uncomment mode option = EXACT or FUZZY?
// -check string length integrity
// -look at passed vs. global variables
// -finish documentation


/*----------------------------------------------------------------------

                                I_CMMT.S

             The "Intelligent Commenting" TSE Macro Package
                              Version 1.0


Author:  John D. Goodman

Precis:

   ** See the file I_CMMT.DOC for full documentation **

   The I_CMMT (Intelligent Commenting) package includes macros for
   commenting and uncommenting program source code in a variety of
   context-sensitive and user-configurable ways. There are three
   user-callable procedures in the package:

      InLineCmmt()
      FullLineCmmt()
      CmmtOptsMenu()

   These are bound to the Alt-8, Alt-9, and Alt-0 keys, respectively,
   at the end of the source code.

   InLineCmmt() is used to add in-line comments to or remove in-line
   comments from the beginning of one or more lines of text. In-line
   comment strings (e.g., '//', ';', '&&') can consist of any
   user-defined fixed text, can insert the current date/time, and can
   dynamically prompt the user for text on each use. The macro operates
   on all lines delineated by a marked block or the current line if no
   blocks are marked.  If the first line is already commented, then the
   selected lines are uncommented; otherwise, they are commented.  An
   "end-line" comment can also be typed by invoking the macro at the end
   of an uncommented non-blank line.

   FullLineCmmt() inserts a "full-line" comment above the current line
   or a "block" comment above and below multiple marked lines.  Full-
   line comments consist of the in-line comment string followed by
   user-provided text.  Block comments are delineated by user-defined
   comment begin and end strings (e.g., ) and also include
   user-provided text.  The user-provided text for both full-line and
   block comments can be fixed or prompted for on each use and can
   include special line drawing characters and/or the current date/time.

   For both InLineCmmt() and FullLineCmmt(), if a column or character
   block is used, comments are inserted in the block begin position
   column; otherwise, they are inserted in a user-specified default
   column.  Also, the selected line(s) can optionally be wordwrapped
   when commenting or uncommenting.

   CmmtOptsMenu() displays a menu that is used to change several options
   for how the commenting macros will work.  Options that can be changed
   include the in-line comment string, the beginning and ending comment
   strings for block comments, the default column in which comments will
   be placed, blank line handling mode, and whether or not text lines
   are wordwrapped when commenting and uncommenting. The editor's
   wordwrap settings (right margin, left margin, autoindent,
   paragraph-end style, and normal wordwrap on/off mode are also
   displayed and can be changed using the comment options menu.

   The above description is greatly simplified...

Acknowledgements:

   Many thanks to Tom Hogshead, who collaborated with me on the original
   TSE Jr. version of the InLineCmmt() macro.  Thanks also to Tom Klein,
   Tom Wheeler, Vernon Leonard, and any others who wrote similar
   commenting macros and whose ideas may be reflected herein.  And, of
   course, I greatly appreciate the efforts of the SemWare team

   If I've directly or indirectly used anyone else's code or ideas
   without proper attribution, please let me know.

Revision History:

   ver. 1.0 05/31/94
      -- original issue; written for TSE Pre-Release Ver. 1.0

----------------------------------------------------------------------*/

// =====================================================================
// Constant declarations

constant NONE   = 0,        // values for blank line commenting mode
         NORMAL = 1,        // option (variable iBlnkLnMode)
         SMART  = 2

constant KEEP_MARGIN   = 0, // values to indicate whether or not the
         CHANGE_MARGIN = 1  // the right margin s/b changed when
                            // wordwrapping

constant FULL_LINE = 0,     // full-line or block commenting mode
         BLOCK     = 1

constant NO_TABS       = 0, // options for comment string/comment
         ALLOW_TABS    = 1, // text expansion
         NO_PROMPTS    = 0,
         ALLOW_PROMPTS = 1

// =====================================================================
// Global variable declarations

// Default menu option settings ----------------------------------------
//
// Set these values to whatever you'd prefer them to be on macro
// startup.
//

string  sDfltCmmt[20] = "// "  // in-line comment string displayed by
                               // options menu

string  sBlkCmmt[20] = "/*|*/" // block comment begin/end strings

integer iDfltCmmtCol = 1       // default column to insert comments

integer iWordWrap    = OFF     // default commenting wordwrap mode

integer iBlnkLnMode  = SMART   // blank line commenting mode
                               // values: NONE, NORMAL, SMART

// Other global variables used by the macros ---------------------------

integer iStartLine            // start of selected line(s)

integer iEndLine              // end of selected line(s)

integer iCmmtCol              // calculated comment insert column

string  sCmmt[80]             // expanded comment string

string  sCmmtTrim[80]         // the comment string with trailing
                              // whitespace removed

integer iCmmtLen              // length of the expanded comment string

string  sILPrompt[60]  = ""   // user entered text for in-line comment
                              // prompt

string  sFLPrompt[60] = ""    // user entered text for full-line/block
                              // comment prompt

string  sFLMenuText[60] = ""

integer iILCmmtHist           // in-line comment string history list

integer iBlkCmmtHist          // block comment string history list

integer iILPromptHist         // in-line comment prompt text history

integer iFLPromptHist         // block comment prompt text history list

string  sLineDrawChars[9] = "-=*^~.:+#"  // line drawing chars for full-
                                         // line/block comments

// =====================================================================
// Procedures...

// ---------------------------------------------------------------------
proc WhenLoaded()

   // This proc is executed whenever the macro package is loaded by TSE.
   // Initialize history lists for menu options and user prompts.

   iILCmmtHist   = GetFreeHistory()

      AddHistoryStr( "REM ", iILCmmtHist )  // common in-line comment
      AddHistoryStr( "; ",   iILCmmtHist )  // strings
      AddHistoryStr( "&& ",  iILCmmtHist )
      AddHistoryStr( "* ",   iILCmmtHist )
      AddHistoryStr( "// ",  iILCmmtHist )

   iBlkCmmtHist  = GetFreeHistory()

      AddHistoryStr( "/*|*/", iBlkCmmtHist )

   iILPromptHist = GetFreeHistory()
   iFLPromptHist = GetFreeHistory()

end

// =====================================================================
// Utility procs...

// ---------------------------------------------------------------------
string proc RightTrim( string sString )

   // This proc returns sString with trailing whitespace (spaces and
   // tabs) removed.

   integer iPtr = Length( sString )

   while iPtr and ( sString[iPtr] == " " or sString[iPtr] == Chr( 9 ) )
      iPtr = iPtr - 1
   endwhile

   return( Substr( sString, 1, iPtr ) )

end

// ---------------------------------------------------------------------
string proc ExpandSpecInds( string sOrigStr, integer iAllowTabs,
                            integer iAllowPrompt, var integer iExpandLen )

   // This proc expands the special indicators for comment strings and
   // comment prompt text.  The original string (which may contain the
   // special indicators) is passed as sOrigStr and the expanded string
   // is returned by the proc.  The integer iExpandLen will be the true
   // length of the string (with tabs expanded based on current editor
   // settings).  The parameters iAllowTabs and iAllowPrompt indicate
   // whether the original string can contain the '\t' and '\p' special
   // indicators.

   string  sExpandedStr[80]
   integer iSaveRTW = Set( RemoveTrailingWhite, OFF )

   UnmarkBlock()           // do all this on an inserted blank line
   InsertLine( sOrigStr )
   MarkLine()

   // replace special indicator for backslash
   lReplace( "\\", "\",          "nilg" )

   if iAllowTabs
      lReplace( "\t", Chr(9),       "nilg" )   // expand tabs
   endif

   // prompt for dynamic comment string text
   if iAllowPrompt and lFind( "\p", "ilg" )

      if Ask( "Text to insert into comment string:   (" + chr( 24 ) +
         " for history list)", sILPrompt, iILPromptHist )

         lReplace( "\p", sILPrompt, "nilg" )
      else
         lReplace( "\p", "", "nilg" )
      endif

   endif

   // replace current date/time indicators (doing this here lets them
   // be included in prompted text! -- use of '\\' ??)

   lReplace( "\d", GetDateStr(), "nilg" )
   lReplace( "\h", GetTimeStr(), "nilg" )

   EndLine()
   iExpandLen   = CurrCol() - 1               // true string length
   sExpandedStr = GetText( 1, CurrLineLen() ) // return expanded string

   DelLine()
   Set( RemoveTrailingWhite, iSaveRTW )

   return( sExpandedStr )

end

// =====================================================================
// Procs for the InLineCmmt() driver...

// ---------------------------------------------------------------------
integer proc isCommented( integer iLineNo )

   // This proc determines if the line iLineNo is already commented by
   // looking for the comment string (or comment string with trailing
   // whitespace removed) at the beginning of the line.  Return the
   // column of the comment string if found; otherwise 0.

// see questions under DelComments...

   UnmarkBlock()
   GotoLine( iLineNo )
   MarkLine()

   // search for the comment string or the trimmed comment string
   if lFind( sCmmt, "ilg" )
      or lFind( sCmmtTrim, "ilg" )

      if CurrPos() <= PosFirstNonwhite()  // at the beginning
         return( CurrCol() )              // of the line?
      endif

   endif

   return( 0 )    // iLineNo is not already commented
end

// ---------------------------------------------------------------------
integer proc isCharToLeft()

   // This proc determines if there are any non-whitespace characters to
   // the left of where the comment strings will be inserted.  This is
   // done to ensure that comments will not be inserted into the middle
   // of any text.

   if iCmmtCol > 1    // don't bother if inserting at column 1

      UnmarkBlock()
      GotoLine( iStartLine )

      repeat   // loop for each selected line

         if PosFirstNonwhite()

            GotoPos( PosFirstNonwhite() )
            if CurrCol() < iCmmtCol       // return TRUE if the column
               return( TRUE )             // of the first nonwhite char
            endif                         // is less than the comment
                                          // column
         endif

      until not Down() or CurrLine() > iEndLine

   endif

   return( FALSE )

end

// ---------------------------------------------------------------------
proc AddComments()

   // This proc is used to add in-line comments to each selected line --
   // a pretty simple matter of inserting the comment string at the
   // appropriate column of each line.

   UnmarkBlock()
   GotoLine( iStartLine )

   repeat   // loop for each selected line

      // skip blank lines if Blank Line Mode = NONE
      if PosFirstNonwhite() or iBlnkLnMode <> NONE

         GotoColumn( iCmmtCol )         // insert the comment string in
         InsertText( sCmmt, _INSERT_ )  // the appropriate column and
                                        // go down
      endif

   until not Down() or CurrLine() > iEndLine

   GotoColumn( iCmmtCol )

end

// ---------------------------------------------------------------------
proc DelComments()

   // This proc is used to delete the in-line comments from each
   // selected line.  Search for and replace the comment string or the
   // trimmed comment string on each selected line. Replace only if the
   // string is found at the beginning of the text portion of the line.

// Q: include id/deletion with leading whitespace and leading and
//    trailing whitespace removed?  Add configuration option
//    uncomment mode = EXACT or FUZZY?  How to id/delete comments
//    w/ date/time inserted by \d and \h?

   UnmarkBlock()
   GotoLine( iStartLine )

   repeat    // loop for each selected line

      MarkLine()
      if lFind( sCmmt, "ilg" )
         if CurrPos() <= PosFirstNonwhite()
            lReplace( sCmmt, "", "1ilg" )
         endif
      else
         if lFind( sCmmtTrim, "ilg" )
            if CurrPos() <= PosFirstNonwhite()
               lReplace( sCmmtTrim, "", "1ilg" )
            endif
         endif
      endif

      UnmarkBlock()

   until not Down() or CurrLine() > iEndLine

end

// ---------------------------------------------------------------------
proc WrapLines( integer iChgMargin )

   // This proc is used to paragraph-wrap the selected line(s) either
   // before they are commented or after they have been uncommented. The
   // editor's current settings for left/right margin, autoindent, and
   // paragraph end style are used (these can be reset using the options
   // menu).  However, when adding comments, the right margin is reduced
   // by the length of the comment string so that the right margin of
   // the post-commented lines will be correct.

   integer iSaveRM = Query( RightMargin )

   if iChgMargin == CHANGE_MARGIN
      iSaveRM = Set( RightMargin, iSaveRM - iCmmtLen )
   endif

   UnmarkBlock()           // add a line to the end of the selected
   GotoLine( iEndLine )    // line(s) and create a line block
   AddLine()               // encompassing the lines
   MarkLine()
   GotoLine( iStartLine )
   MarkLine()
   BegLine()

   // Continue wrapping paragraphs until we're beyond the marked block
   // or there are no more non-whitespace characters left in the block

   repeat
   until CurrLine() >= Query( BlockEndLine )
         or not lFind( "[~ \t]", "lx" )
         or not WrapPara()

   if CurrLineLen() == 0             // delete the added line (if safe)
       DelLine()
   endif

   iEndLine = Query( BlockEndLine )  // reset the endline because it
   GotoLine( iEndLine + 1 )          // may have changed after wrapping
   UnmarkBlock()

   Set( RightMargin, iSaveRM )       // reset the right margin setting

end

// ---------------------------------------------------------------------
proc ExpandInLineCmmt()

   // This proc expands the special indicators for the in-line comment
   // string, gets the expanded comment string's true length (with tab
   // characters expanded), a gets a version of the comment string with
   // trailing whitespace removed.

//    integer iSaveRTW = Set( RemoveTrailingWhite, OFF )
//
//    sCmmt = sDfltCmmt      // insert a copy of the raw in-line comment
//    UnmarkBlock()          // string on a new blank line
//    InsertLine( sCmmt )
//    MarkLine()
//
//    // replace special indicators for backslash, current date,
//    // current time, and tab character
//    lReplace( "\\", "\", "nilg" )
//    lReplace( "\d", GetDateStr(), "nilg" )
//    lReplace( "\h", GetTimeStr(), "nilg" )
//    lReplace( "\t", Chr(9),       "nilg" )
//
//    // prompt for dynamic comment string text
//    if lFind( "\p", "ilg" )
//       if Ask( "Text to insert into comment string:   (" + chr( 24 ) +
//               " for history list)", sILPrompt, iILPromptHist )
//
//          lReplace( "\p", sILPrompt, "nilg" )
//       else
//          lReplace( "\p", "", "nilg" )
//       endif
//    endif
//
//    EndLine()
//    iCmmtLen  = CurrCol() - 1
//    sCmmt     = GetText( 1, CurrLineLen() )
//    sCmmtTrim = GetText( 1, PosLastNonWhite() )
//    DelLine()
//
//    Set( RemoveTrailingWhite, iSaveRTW )

// Test using common proc...

   sCmmt     = ExpandSpecInds( sDfltCmmt, ALLOW_TABS, ALLOW_PROMPTS,
                               iCmmtLen)
   sCmmtTrim = RightTrim( sCmmt )

end

// ---------------------------------------------------------------------
proc SetInLineVars( var integer isEndLineCmmt )

   // This proc sets a number of variables for the in-line commenting/
   // uncommenting, including the default comment column, the starting
   // and ending line numbers, and an end-line comment indicator.  The
   // proc also calls ExpandInLineCmmt() to get the run-time version of
   // the comment string.

   integer iBlockType
   integer iOrigCol
   integer isBlankLine = FALSE

   // if the default comment column setting is 0, set it to the left
   // margin setting; if the left margin is also 0, set it to 1

   iCmmtCol = iif( iDfltCmmtCol, iDfltCmmtCol, Query( LeftMargin ) )
   iCmmtCol = iif( iCmmtCol, iCmmtCol, 1 )

   iBlockType = isCursorInBlock()
   if iBlockType

      GotoBlockBegin()
      iStartLine = CurrLine()
      iEndLine   = Query( BlockEndLine )
      if iBlockType <> _LINE_        // use block begin column if a
         iCmmtCol = CurrCol()        // column or char block marked
      endif

   else  // no block marked or cursor not in block

      iStartLine = CurrLine()        // process current line only
      iEndLine   = iStartLine
      if CurrChar() < 0              // beyond line end?
         iOrigCol = CurrCol()
         if PosFirstNonWhite()
            isEndLineCmmt = TRUE     // a true end-line comment
            iCmmtCol      = iOrigCol
         else
            isBlankLine = TRUE
         endif
      endif

   endif

   ExpandInLineCmmt()   // expand the in-line comment string

   // finally, set vars correctly for a blank line w/ smart mode On

   if isBlankLine and iBlnkLnMode == SMART
      iCmmtCol = isCommented( iStartLine - 1 )
      if not iCmmtCol
         isEndLineCmmt = TRUE
         iCmmtCol      = iOrigCol
      endif
   endif

end

// ---------------------------------------------------------------------
proc InLineCmmt()

   // This proc is the main driver for the in-line commenting/
   // uncommenting.

   integer isEndLineCmmt = FALSE
   integer iSaveKM = Set( KillMax, 0 )

   SetInLineVars( isEndLineCmmt ) // set the global and passed vars

   if isCommented( iStartLine )   // check if 1st line already commented

      DelComments()               // delete comments and wordwrap if
      if iWordWrap                // option set On
         WrapLines( KEEP_MARGIN )
      endif

   else
      if isEndLineCmmt

         UnmarkBlock()            // insert comment at original position
         GotoColumn( iCmmtCol )   // if an end-line comment
         InsertText( sCmmt, _INSERT_ )

      else   // add comments to beginning of selected line(s)

         if iWordWrap             // wordwrap lines first if option On
            WrapLines( CHANGE_MARGIN )
         endif

         // reset comment column to 1 if we'll overwrite any text
         iCmmtCol = iif( isCharToLeft(), 1, iCmmtCol )

         AddComments()            // add 'em!

      endif
   endif

   Set( KillMax, iSaveKM )   // restore editor settings

end

// =====================================================================
// The procs from here down are used for full-line/block commenting
// and are called directly or indirectly from proc FullLineCmmt().

// ---------------------------------------------------------------------
integer proc GetCmmtText( integer iFLMode, var string sText )

   // This proc gets the user text to be inserted in the full-line/
   // block comment.  If a non-null string is entered for the comment
   // text menu option this string is used; otherwise, the user is
   // prompted for the text.  Whichever string is to be used is returned
   // in sText.  The proc also returns FALSE if the user aborts the
   // text entry by pressing Escape.

   string  sMode[10] = iif( iFLMode, "block ", "full-line " )

   if Length( sFLMenuText )  // use the text from the menu option
      sText = sFLMenuText    // if not null

   else   // otherwise, prompt the user for the text

      Message( "Special Indicators: '\d'=date '\h'=time '\\'='\'" )
      if Ask( "Text to insert in " + sMode + "comment:   (" + Chr(24) +
         " for history list)", sFLPrompt, iFLPromptHist )

         sText   = sFLPrompt
      else
         Message( sMode + "comment insertion aborted..." )
         return( FALSE )   // return FALSE if user Esc'ed prompt
      endif
   endif

   return( TRUE )  // valid text received, continue processing
end

// ---------------------------------------------------------------------
proc ExpandCmmtText( var string sRptChar1, var string sText,
                     var string sRptChar2 )

   // This proc processes the user-provided comment text string by
   // pulling off the line draw repeating characters (if present) and
   // expanding the special date/time indicators.

   integer iLength
   integer iDummy = 0
//    integer iSaveRTW

   sRptChar1 = ""
   sRptChar2 = ""
   iLength   = Length( sText )

   if iLength

//       iSaveRTW = Set( RemoveTrailingWhite, OFF )

      // determine if the first and last chars are line-drawing chars
      if Pos( sText[1], sLineDrawChars )
         sRptChar1 = sText[1]
      endif

      if iLength > 1 and Pos( sText[ iLength ], sLineDrawChars )
         sRptChar2 = sText[ iLength ]
      endif

//       UnmarkBlock()             // expand the comment string special
//       InsertLine( sText )       // indicators
//       MarkLine()
//       lReplace( "\\", "\",          "nilg" )
//       lReplace( "\d", GetDateStr(), "nilg" )
//       lReplace( "\h", GetTimeStr(), "nilg" )
//
//       sText = GetText( 1, CurrLineLen() )
//       DelLine()
//       Set( RemoveTrailingWhite, iSaveRTW )

      sText = ExpandSpecInds( sText, NO_TABS, NO_PROMPTS, iDummy )

   endif
end

// ---------------------------------------------------------------------
proc TypeFullLineCmmt( string sBegCmmt, string sRptChar1, string sText,
                       string sRptChar2, string sEndCmmt )

   // This proc types a full-line or block comment on a blank line.  The
   // five parameters are the possible components of the comment line
   // (beginning comment string, 1st repeating character, user text, 2nd
   // repeating character, and ending comment string), any of which may
   // be null depending on the type of line and user-provided text.

   integer iRemain
   integer iLenRpt2 = 0
   integer iLenRpt1 = 0

   UnmarkBlock()                     // insert the begin comment string
   GotoColumn( iCmmtCol )            // at the comment column
   InsertText( sBegCmmt, _INSERT_ )

   // how many chars available for the repeat chars?
   iRemain = Query( RightMargin ) - Length(sEndCmmt) - Length( sText ) -
             CurrCol() + 1

   if iRemain > 0

      if Length( sRptChar1 )              // determine repeat counts
         if Length( sRptChar2 )           // for the leading and
            iLenRpt1 = iRemain / 2        // trailing repeat chars
            iLenRpt2 = iRemain - iLenRpt1
         else
            iLenRpt1 = iRemain
         endif
      else
         if Length( sRptChar2 )
            iLenRpt2 = iRemain
         endif
      endif

   endif

   // insert the remaining components of the comment on the line

   if iLenRpt1
      InsertText( Format( sRptChar1 : iLenRpt1 : sRptChar1 ), _INSERT_ )
   endif

   InsertText( sText, _INSERT_ )

   if iLenRpt2
      InsertText( Format( sRptChar2 : iLenRpt2 : sRptChar2 ), _INSERT_ )
   endif

   InsertText( sEndCmmt, _INSERT_ )  // insert block end comment string

end

// ---------------------------------------------------------------------
proc SetFullLineVars( var integer iFLMode )

   // This proc sets the start and end line numbers, comment column, and
   // full-line or block mode.

   integer iBlockType

   // if the default comment column setting is 0, set it to the left
   // margin setting; if the left margin is also 0, set it to 1

   iCmmtCol = iif( iDfltCmmtCol, iDfltCmmtCol, Query( LeftMargin ) )
   iCmmtCol = iif( iCmmtCol, iCmmtCol, 1 )

   iBlockType = isCursorInBlock()
   if iBlockType

      GotoBlockBegin()
      iStartLine = CurrLine()
      iEndLine   = Query( BlockEndLine )
      if iBlockType <> _LINE_
         iCmmtCol = CurrCol()
      endif

   else
      iStartLine = CurrLine()   // process current line only
      iEndLine   = iStartLine
   endif

   if iStartLine <> iEndLine or iBlockType == _LINE_
      iFLMode = BLOCK
   endif

end

// ---------------------------------------------------------------------
proc ExpandBlkCmmt( var string sBegCmmt, var string sEndCmmt )

   // This proc expands the block comment special indicators and
   // separates the block comment string into it's begin and end comment
   // strings.

   integer iSplitPos
   integer iDummy = 0

//    integer iSaveRTW = Set( RemoveTrailingWhite, OFF )

   sEndCmmt = ""

//    UnmarkBlock()
//    InsertLine( sBlkCmmt )
//    MarkLine()
//    lReplace( "\\", "\",          "nilg" )
//    lReplace( "\d", GetDateStr(), "nilg" )
//    lReplace( "\h", GetTimeStr(), "nilg" )
//
//    sBegCmmt = GetText( 1, CurrLineLen() )
//    DelLine()
//    Set( RemoveTrailingWhite, iSaveRTW )

   sBegCmmt = ExpandSpecInds( sBlkCmmt, ALLOW_TABS, NO_PROMPTS, iDummy )

   iSplitPos = Pos( "|", sBegCmmt )
   if iSplitPos
      sEndCmmt = Substr( sBegCmmt, iSplitPos + 1,
                         Length( sBegCmmt ) - iSplitPos )
      sBegCmmt = Substr( sBegCmmt, 1, iSplitPos - 1 )
   endif

end

// ---------------------------------------------------------------------
proc FullLineCmmt()

   // This proc is the main driver for the full-line/block commenting.

   integer iFLMode      = FULL_LINE
   string  sRptChar1[1] = ""
   string  sRptChar2[1] = ""
   string  sText[60]    = ""
   string  sBegCmmt[80] = ""
   string  sEndCmmt[80] = ""

   integer iSaveKM      = Set( KillMax, 0 )

   PushPosition()
   PushBlock()

   SetFullLineVars( iFLMode )    // set global and passed variables

   // if the comment text menu option string is null, prompt
   // the user for the text string to be inserted in the comment.

   if GetCmmtText( iFLMode, sText )

      ExpandCmmtText( sRptChar1, sText, sRptChar2 )

      if iFLMode == BLOCK        // insert a block comment

         if iWordWrap            // optionally wordwrap the lines
            WrapLines( KEEP_MARGIN )
         endif

         // get the block comment begin and end comment strings
         ExpandBlkCmmt( sBegCmmt, sEndCmmt )

         // insert comment lines above and below selected line(s)

         GotoLine( iStartLine )
         InsertLine()
         TypeFullLineCmmt( sBegCmmt, sRptChar1, sText, sRptChar2, "" )

         GotoLine( iEndLine + 1 )
         AddLine()
         TypeFullLineCmmt( "", sRptChar1, "", sRptChar2, sEndCmmt )

      else  // insert a full-line comment above selected line

         ExpandInLineCmmt()   // expand the in-line comment string
         InsertLine()
         TypeFullLineCmmt( sCmmt, sRptChar1, sText, sRptChar2, "" )

      endif

      KillPosition()
      GotoColumn( iCmmtCol )     // position correctly and clean-up
      Down()

   else    // user aborted (Esc'ed) comment text entry prompt

      PopPosition()
      PopBlock()

   endif

   Set( KillMax, iSaveKM )
end

// =====================================================================
// Utility procs to support menu option processing
//
// The first two procs, DispOnOff and ReadInteger, are clones of
// SemWare's standard TSE.S procs OnOffStr and ReadNum and can be
// replaced if the code is merged into or #included in TSE.S.  The
// other procs display or set the value of menu items.
//

string proc DispOnOff( integer iOnOff )
   // return description of on/off state variable

   return( iif( iOnOff, "On", "Off" ) )
end

integer proc ReadInteger( integer n )
   // read an integer value at the current logical cursor position

   string s[5] = Str( n )
   return( iif( Read( s ), Val( s ), n ) )
end

proc SetILCmmtStr()   // prompt for the in-line/full-line comment string

   string  sCmmtTemp[20] = sDfltCmmt

   Message( "Special Indicators: '\t'=tab '\d'=date '\h'=time " +
      "'\p'=prompt for text '\\'='\' " )

   if Ask("In-Line Comment String:", sCmmtTemp, iIlCmmtHist )
      and Length( sCmmtTemp )

      sDfltCmmt = sCmmtTemp
   endif
end

proc SetBlkCmmtStr()    // prompt for the block begin/end comment string

   string sCmmtTemp[30] = sBlkCmmt

   Message( "Separate begin/end strings with '|'; Spec Inds: " +
            "'\d' '\h' '\\' '\t'" )

   if Ask("Block Comment Begin|End String:", sCmmtTemp, iBlkCmmtHist )
      and Length( sCmmtTemp )

      sBlkCmmt = sCmmtTemp
   endif
end

proc SetFLText()        // prompt for the full-line/block comment text

   string sCmmtTemp[30] = sFLMenuText

   Message( "Special Indicators: '\d'=date '\h'=time '\\'='\';" +
            " Leave blank for prompting" )

   if Ask("Full-Line/Block Comment Text:", sCmmtTemp, iFLPromptHist )

      sFLMenuText = sCmmtTemp
   endif
end


proc SetInteger( var integer iVar, integer iValue )
   // set an integer variable to a specific value

   iVar = iValue
end

proc RotateInteger( var integer iVariable, integer iMin, integer iMax )
   // rotate the value of an integer variable between the min
   // and max values

   if iVariable == iMax
      iVariable = iMin
   else
      iVariable = iVariable + 1
   endif
end

string proc DispBlnkLnMode()     // display blank line processing mode

   case iBlnkLnMode
      when SMART    return( "Smart" )
      when NORMAL   return( "Normal" )
      when NONE     return( "None" )
   endcase

   return( "?" )
end

string proc DispAutoIndent()    // display AutoIndent setting

   case Query( AutoIndent )
      when OFF       return( "Off" )
      when ON        return( "On" )
      when _STICKY_  return( "Sticky" )
   endcase

   return( "?" )
end

proc ChangeAutoIndent()         // rotate Autoindent setting

   case Query( AutoIndent )
      when OFF       Set( AutoIndent, ON )
      when ON        Set( AutoIndent, _STICKY_ )
      when _STICKY_  Set( AutoIndent, OFF )
   endcase
end

string proc DispPES()           // display paragraph-end style setting

   return( iif( Query( ParaEndStyle ),
      "Equal In/Outdent", "Blank Line" ) )
end

// =====================================================================
// Menus...
//
// Note that the editor wordwrap menu options have been cloned from
// SemWare's standard TSE.S source (although modified slightly to
// toggle state variables (e.g., AutoIndent) rather than displaying
// a submenu).
//

menu CmmtOptsMenu()
   history
   title = " Commenting/Uncommenting Options Menu "

   "&In-Line/Full-Line Comment String" [ sDfltCmmt : 20 ],
      SetILCmmtStr(),
      dontclose,
      "Comment string for in-line and full-line comments"

   "&Block Comment Begin|End String"   [ sBlkCmmt : 20 ],
      SetBlkCmmtStr(),
      dontclose,
      "Begin and end string for block comments"

   "&Full-Line/Block Comment Text"     [ sFLMenuText : 30 ],
      SetFLText(),
      dontclose

   "Default Comment &Column" [ iDfltCmmtCol : 5 ],
      SetInteger( iDfltCmmtCol, ReadInteger( iDfltCmmtCol ) ),
      dontclose,
      "Default Column to Insert Comment Strings; 0 = Use Current Left Margin"

   "&Blank Line Commenting Mode" [ DispBlnkLnMode() : 6],
      RotateInteger( iBlnkLnMode, 0, 2 ),
      DontClose

   "&Wordwrap When Commenting/Uncommenting" [ DispOnOff( iWordWrap ) : 3 ],
      RotateInteger( iWordWrap, 0, 1 ),
      dontclose,
      "Wordwrap selected line(s) before commenting or after uncommenting"

   " Editor Wordwrap Settings ", , Divide

   "&Right Margin"         [ Query( RightMargin ) : 5 ],
      Set( RightMargin, ReadInteger( Query( RightMargin ) ) ),
      DontClose

   "&Left Margin"          [ Query( LeftMargin ) : 5 ],
      Set( LeftMargin, ReadInteger( Query( LeftMargin ) ) ),
      DontClose

   "&AutoIndent"           [ DispAutoIndent() : 6 ],
      ChangeAutoIndent(),
      DontClose

   "&Paragraph-End Style"  [ DispPES() : 16 ],
      Set( ParaEndStyle, iif( Query( ParaEndStyle ), 0, 1 ) ),
      DontClose

   "&Normal Wordwrap Mode" [ DispOnOff( Query( WordWrap ) ) : 3 ],
      Toggle( WordWrap ),
      DontClose
end

// =====================================================================
// Key bindings...

<alt 8> InLineCmmt()
<alt 9> FullLineCmmt()
<alt 0> CmmtOptsMenu()

