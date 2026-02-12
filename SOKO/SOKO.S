// ----------------------------------------------------------------------
//                     SOKOBAN game, SAL style
//                      Gilles Kohl, 12.06.94
//                             enjoy!
// ----------------------------------------------------------------------

//
// Define the characters used for better readability. If you change this,
// you will have to change the level files too so that they match
//
constant BLANK  = 32,
         ACTOR  = 4,   // 
         BOX    = 42,  // *
         WALL   = 177, // ±
         STORE  = 250, // ú
         SBOX   = 15,  // 
         SACTOR = 5    // 

integer show_statusline, show_eofmarker

forward proc QuitSoko()

//
// FindActor finds the 'moving' character - used on startup
//
integer proc FindActor()
   if CurrChar() == ACTOR or CurrChar() == SACTOR 
      return(1)
   endif
   if Find("["+Chr(ACTOR)+CHR(SACTOR)+"]", "gx") == 0
      warn("Actor not found - not a SOKO File")
      QuitSoko()
      return(0)
   endif
   return(1)
end

//
//
proc CheckOver()
   PushPosition()
   if lFind(Chr(BOX), "g") == 0
      warn("Congratulations - you solved it!")
      QuitSoko()
   endif
   PopPosition()
end

//
// Move cursor into a given direction (angle DIV 90)
//
proc MoveDir(integer dir)
   case dir
      when 0 Right()
      when 1 Up()
      when 2 Left()
      when 3 Down()
      otherwise warn("Internal error: invalid dir")
   endcase
end

//
// This is the working horse. It moves the character the cursor is on
// (either the 'actor' or a box) into a given direction, and takes care
// of all special handling required. If moving the actor and the target
// position is occupied by a box, this routine is called recursively to
// move that box itself.
//
proc Move(integer dir)
   integer A, O       // A == what we move (actor), 
                      // O == object on target cell.

   A = CurrChar()     // get actor (may also be a box)
   PushPosition()     // remember where we were
   MoveDir(dir)       // move into indicated direction
   O = CurrChar()     // get object on target cell
   if (A == ACTOR or A == SACTOR) and (O == BOX or O == SBOX)
      // in this case, try to move a box by a recursive call !
      Move(dir)
      O = CurrChar()  // get object on target cell again, may have changed
   endif
   if O == BLANK or O == STORE // valid target cell to move onto ?
      InsertText(Chr(iif(A == ACTOR or A == SACTOR,
                        iif(O == BLANK, ACTOR, SACTOR),
                        iif(O == BLANK, BOX,   SBOX)
                    )), _OVERWRITE_) // insert target character
      PopPosition()   // return where we came from, and
      PushPosition()  // immediately save it again
      InsertText(Chr(iif(A == ACTOR or A == BOX, BLANK, STORE)), 
                 _OVERWRITE_) // remove moving character
      PopPosition()   // return to modified position
      if(A == ACTOR or A == SACTOR) 
         MoveDir(dir) // if actor, do move
      endif
   else // target position wasn't valid, simply return
      PopPosition()
   endif
end

// 
// SokoMove does a complete move in the indicated direction, and also
// checks for level completion.
//
proc SokoMove(integer dir)
   Move(dir)
   CheckOver() // check if level completed
end

//
// Tie the SOKOBAN keys to the corresponding macros
//
keydef SokoKeys
   <CursorRight> SokoMove(0)
   <CursorUp>    SokoMove(1)
   <CursorLeft>  SokoMove(2)
   <CursorDown>  SokoMove(3)
   <Escape>      QuitSoko()
end

//
// QuitSoko simply switches off the keykef, returning to normal editing
// again.
// 
proc QuitSoko()
   Set(ShowStatusLine, show_statusline)
   Set(ShowEofMarker, show_eofmarker)
   UpdateDisplay()
   Message("Sokoban mode off")
   Disable(SokoKeys)
end

//
// The entry point. State that we're in SOKOBAN mode, actually enable it,
// and try to find the actor - the rest is up to the keydefs and the user.
//
proc Main()
   string fn[80]

   if not FileExists("level.*")
      Warn("Can't find level files.")
      return ()
   endif
   fn = PickFile("level.*")
   if Length(fn) == 0
      return ()
   endif
   EditFile(fn)
   show_statusline = Set(ShowStatusLine, off)
   show_eofmarker = Set(ShowEofMarker, off)
   UpdateDisplay()
   Message("In Sokoban mode")
   Enable(SokoKeys, _EXCLUSIVE_)
   FindActor()
end

