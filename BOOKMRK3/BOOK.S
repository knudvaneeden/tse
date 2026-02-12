/**************** Visual Bookmark Macros v3.0 ***************************
 Author:  Sammy Mitchell.  Extensive rewrite by Steve Kraus.
          Original idea by by Jim Susoy and Howard Kapustein.
 Changes:

   1. Uses BookMark letter rather than line number in bookmark buffer
   2. Bookmarks are designated "@A", an at-sign followed by the bookmark
      letter. This designation is based on the <Ctrl 2> key used in
      assigning bookmarks.
   3. Peacefully coexists with regular bookmark commands. mPlaceBookMark
      uses the first available bookmark.
   4. Eliminated use of ListIt due to redundant calculation of width
      and conflict with ListIt defined in default TSE.S
   5. When placing bookmark, display bookmark placed.
   6. Reformat to tab width 3 to fit in messages.
   7. Extensive commenting added.
   8. Fixed Incorrect initialization bmc = "@" (at) in mGotoBookMark,
      then later tested against the null string.
   9. Corrected commenting. An experimental version returned an integer
      giving the mark number; this version does not.
  10. v2.0 May 09, 1993  New mNextBookMark () jumps to the previous used
      bookmark working backwards from mark Z to A with wrap back to Z.
  11. Store Last BookMark Character in LBMC. Macros now remember last used.
  12. New mSelectBookMark opens pick buffer, returns mark selected or ''
  13. v2.1 May 21, 1993  New mDelBookMark selects a bookmark to delete.
  14. v3.0 May 31, 1993  Display first nonblank chars in visual buffer

  Description:

  These macros implement a visual display of active bookmarks. Each
  bookmark is designated "@A", with an at-sign sign followed by the
  bookmark letter. Thus bookmark "C" is described as "at C" and designated
  by @C. This designation is based on the <Ctrl-2> key used in assigning
  bookmarks. This peacefully coexists with regular bookmark commands. The
  bookmark selection temporary buffer is rebuilt with each call.

  mPlaceBookMark () places the next free (lowest available) bookmark at
  the current location. If there are no free marks, a list is displayed,
  prompting for a bookmark to reuse. Press Enter to reuse a bookmark
  or Esc to abort bookmark reuse.

  mGotoBookMark () allows the selection of a bookmark by displaying a list
  of available bookmarks.  Each line displays "@bookmark", filename, line
  number, and the first nonblank portion of the bookmarked line.
  Press Enter to goto the selected mark, or Esc to abort selection.

  mDelBookMark () prompts for a used bookmark to delete from the visual
  visual bookmark buffer, pressing Enter to delete, or Esc to abort. It
  deletes the selected bookmark by replanting the mark in the temporary
  pick buffer, where the mark is deleted when pick buffer is abandoned.

  mNextBookMark () jumps to the previous used bookmark. These macros
  remember the previously placed or jumped bookmark and count backwards.
  Faster than mGotoBookMark, this is used to revisit all declared bookmarks.

  Bookmarks may either be defined automatically assigned by using
  mPlaceBookMark, or a by a PlaceMark call, default <Ctrl 2>. Using the
  new mPlaceBookMark is preferred, since it guarantees a new bookmark or
  a selective pick of marks if all are used.

  Using a key assigned to mGotoBookMark brings up a menu of bookmarks
  assigned. Selecting a bookmark jumps to the file line and column. You can
  still jump to a bookmark using a GotoMark call, default <Ctrl 6>.

  Compile the macro with SC BOOK.S  Load the macro (as an external macro) as
  needed via the LoadMacro command (<ctrl f10><L> or 'menu->macro->load')

  To add these macros to your TSE.S file, move the key assignments to
  your TSE.KEY file, and re-bind the editor using the -b switch of sc:

  SC -b UI\TSE
 ************************************************************************/

string Lbmc[1] = ''                 // Last BookMark Char used

// Common routine to build the 'visual' list of bookmarks. This cycles
// through the list of marks, and returns the first free mark number,
// or 0 if none used, or 27 if all 26 marks used. Leaves position on stack.
integer proc mMarkSetup ()
   integer tid                      // bookmark Temporary buffer ID
   integer bn = 1                   // Bookmark Number -> letter
   integer fm = 0                   // first Free Mark number returned
   string s[80]                     // formatted bookmark line

   PushPosition ()                  // save place, this is left on stack
   tid = CreateTempBuffer ()        // for showing current marks

// Format current marks in buffer TID  "@Mark  File.Ext  Line#  File line"
   while bn <= 26                   // try all bookmark numbers
      if GotoMark (Chr (64+bn) )    // if mark there, add it to the list
         s = Format ('@', Chr (64+bn), ' ',  // format bookmark Letter
           SplitPath (CurrFilename (), _NAME_ | _EXT_):-12, // file name
           CurrLine ():6, ' ',      // file line num & text
           GetText (PosFirstNonWhite (), 56) ) // nonblank text
         GotoBufferId (tid)         // switch to bookmark buffer
         AddLine (s)                // add formatted string
      else                          // else GotoMark failed, mark is free
         fm = iif (fm, fm, bn)      // update fm to first free mark num
      endif
      bn = bn + 1                   // next bookmark
   endwhile
   GotoBufferId (tid)               // returns at the beginning of
   BegFile ()                       // the bookmark buffer file
   if NumLines () == 0              // If no bookmarks given in temp buffer
      return (0)                    // return 0 for no marks
   endif
   return (iif (fm, fm, 27))        // returns free mark or 27 if full
end mMarkSetup

// mNextBookMark jumps to previous used bookmark with wrap.
proc mNextBookMark ()
   integer bn = Asc ('Z')           // Bookmark Number -> letter

   if Lbmc <> ''                    // If last bookmark char defined
      bn = Asc (UpCase (Lbmc) )     // save last bookmark value used
   endif
   Lbmc = Chr (bn)                  // save last bookmark used
   repeat                           // while no end in bookmark search
      bn = iif (bn > Asc ('A'), bn - 1, Asc ('Z')) // Decr bookmark number
      if GotoMark (Chr (bn))        // if bookmark exists
         Lbmc = Chr (bn)            // then update saved bookmark number
         return ()                  // and break
      endif
   until bn == Asc (Lbmc)           // while no end in bookmark search
   Warn ("No Bookmarks found")
end mNextBookMark

// Place a bookmark at the current location. Calls mMarkSetup to build the
// mark buffer and find the first free mark number, then sets a bookmark
// using that number. If all marks used, a list is displayed, prompting for
// a bookmark to reuse.
proc mPlaceBookMark ()
   integer fm = mMarkSetup ()       // Create bookmark list in temp buffer
   string bmc[1] = ''               // Bookmark character, null for none

   if fm <= 26                      // If not all bookmarks used, none = @A
      bmc = Chr (iif (fm, 64+fm, Asc ('A')) ) // set bmc to first free mark
// else all bookmarks used. Ask which one to replace
   elseif List ("Replace Bookmark", Query (ScreenCols) - 2) // Else all used
      bmc = GetText (2, 1)          // Operator flagged which to replace
   endif
// Place a bookmark - abandon the temporary 'visual' list of bookmarks first.
   AbandonFile ()                   // Quit bookmark buffer
   PopPosition ()                   // Restore to text file position
   if bmc <> ''                     // if bookmark flagged
      PlaceMark (bmc)               // then place mark
      Message ("Placed Bookmark @", bmc) // and report in message
      Lbmc = bmc                    // save for mNextBookMark
   endif
end

// mSelectBookmark brings up a list of bookmarks to be selected. It returns
// the letter of the bookmark selected, or null '' if aborted or no marks
string proc mSelectBookMark (string Action)
// Create bookmark list in temp buffer. Returns 0 (none) or free mark number
   if mMarkSetup () == 0            // If no bookmarks given in temp buffer
      Warn ("No Bookmarks found")   // then warn, else pick bookmark from
   elseif List (Action + " Bookmark", Query (ScreenCols) - 2) // pick list
      return (GetText (2, 1) )       // Bookmark character, null for none
   endif
   return ("")
end

// mGotoBookMark brings up a menu of bookmarks assigned.
// Selecting a bookmark jumps to the file line and column.
proc mGotoBookMark ()
   string bmc[1]                    // Bookmark character, null for none

// Create bookmark list in temp buffer, select and return bookmark char
   bmc = mSelectBookMark ("Goto")   // Bookmark character, null for none
   if bmc <> ''                     // If bookmark selected to go to
      AbandonFile ()                // Delete the bookmark buffer
      KillPosition ()               // Kill position, we do not return to it
      GotoMark (bmc)                // Go to bookmark letter selected
      Lbmc = bmc                    // save for mNextBookMark
   else                             // else no bookmark selected
      AbandonFile ()                // Delete the bookmark buffer
      PopPosition ()                // return to original position
   endif
end

// mDelBookMark deletes a bookmark from a menu of bookmarks assigned.
proc mDelBookMark ()
   string bmc[1]                    // Bookmark character, null for none

// Create bookmark list in temp buffer, select and return bookmark char
   bmc = mSelectBookMark ("Delete") // Bookmark character, null for none
   if bmc <> ''                     // If bookmark selected re-plant it
      PlaceMark (bmc)               // in temporary bookmark buffer
   endif                            // Deleting buffer (below) kills mark
   AbandonFile ()                   // Delete the bookmark pick buffer
   PopPosition ()                   // return to original position
end

// Substitute key assignments of your own.
<Alt `>         mPlaceBookMark ()
<Alt \>         mGotoBookMark ()
<Ctrl \>        mNextBookMark ()
<Ctrl 8>        mDelBookMark ()

/************** I added these to my Search submenu *****************

    "Place next &Bookmark..."       ,   mPlaceBookMark ()
    "&Go to Bookmark..."            ,   mGotoBookMark ()
    "&2Prev Bookmark"               ,   mNextBookMark ()
    "&Del Bookmark..."              ,   mDelBookMark ()
    "Place Book&mark..."            ,   placemark()
    "G&o to Bookmark..."            ,   gotomark()

********************************************************************/
