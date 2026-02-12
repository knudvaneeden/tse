/*
   Macro          sFind
   Author         Carlo.Hogeveen@xs4all.nl
   Date           12 November 2006
   Compatibility  None
   Website        http://www.xs4all.nl/~hyphen/tse
   Version        0.0.1

   Purpose        Search for a string which might span lines.

   This is not a working macro! It is only half built.

   This macro's theory is, that you can search for a string which spans lines
   by putting a "slide" of lines under a "microscope", and moving the slide
   from the beginning to the end of the file in such a way, that the macro
   can use TSE's own Find command can be used to search each slide as if it
   was one line!

   Well, the slide part is largely implemented, the search part not at all.
   When implementing the search part, it will have impact on the slide part,
   which probably needs a little extending then.
*/

// The slide size is user changeable.
// If slide_size is zero, then the default is two times the longest line,
// plus one.
// A mandatory limit is that the maximum slide size is MAXLINELEN.
// An optional limit is that for the macro to search across two lines,
// the two lines plus a separator must fit in one line: the macro will
// continue, but it will miss the results across each two too long lines.
integer slide_size = 0

// These are internal global variables; do not change them:
integer ok         = TRUE
integer finished   = FALSE
integer org_id     = 0
integer slide_id   = 0
integer slide_from = 0
integer slide_to   = 0

proc fill_slide_till_its_full()
   integer org_linelen = 0
   slide_to = 0
   repeat
      MarkLine(CurrLine(), CurrLine())
      org_linelen = CurrLineLen()
      GotoBufferId(slide_id)
      if org_linelen > slide_size
         EmptyBuffer()
         Paste()
         UnMarkBlock()
         GotoBufferId(org_id)
         slide_to = CurrLine()
      elseif CurrLineLen() + org_linelen < slide_size
         EndLine()
         InsertText(Chr(13), _INSERT_)
         EndLine()
         Paste()
         UnMarkBlock()
         GotoBufferId(org_id)
      else
         GotoBufferId(org_id)
         Up()
         slide_to = CurrLine()
      endif
   until slide_to <> 0
      or not Down()
end

proc init_slide()
   if slide_size == 0
      slide_size = LongestLineInBuffer() * 2 + 1
      if slide_size > MAXLINELEN
         slide_size = MAXLINELEN
      endif
   endif
   if slide_size > MAXLINELEN
      if Query(Beep)
         Alarm()
      endif
      Warn("Error: slide size > ", MAXLINELEN, " ")
      ok = FALSE
   elseif LongestLineInBuffer() * 2 + 1 > slide_size
      if Query(Beep)
         Alarm()
      endif
      Warn("Warning: lines too long for slide size ")
   endif
   if ok
      GotoBufferId(org_id)
      PushPosition()
      PushBlock()
      BegFile()
      slide_from = 1
      fill_slide_till_its_full()
   endif
end

proc shift_slide()
   integer org_linelen   = 0
   integer slide_linelen = 0
   // Find out what the length of next line will be.
   GotoBufferId(org_id)
   if Down()
      org_linelen = CurrLineLen()
      // Remove lines from the left of the slide until there is enough room
      // on the right of the slide for the new line to be added.
      GotoBufferId(slide_id)
      repeat
         if lFind(Chr(13), "g")
            MarkColumn(1, 1, 1, CurrCol())
            KillBlock()
         else
            EmptyBuffer()
         endif
         slide_linelen = CurrLineLen()
         slide_from    = slide_from + 1
      until slide_linelen              == 0
         or slide_linelen + org_linelen < slide_size
      // Add lines to the right of slide until no more fit.
      fill_slide_till_its_full()
   endif
end

integer proc done()
   integer result = (not ok) or finished
   return(result)
end

proc search_slide()
end

proc Main()
   org_id = GetBufferId()
   slide_id = CreateTempBuffer()
   init_slide()
   while not done()
      search_slide()
      if not done()
         shift_slide()
      endif
   endwhile
   PopBlock()
   PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end

