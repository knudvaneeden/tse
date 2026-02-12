/* Preliminary mail indexing macros based on Tom Hogshead's TSE Jr. mail
   indexing macro. Prepares index of saved mail and finds indexes.
   It works, but it needs commenting and improvement.  Have at it, gang!
   Written  05/09/93 by Steve Kraus.  */

// Debug macro single-step use:  if dbg () goto NoNewMsgs endif
integer proc dbg ()
   UpdateDisplay ()
   Return (283 == getkey ())        // True for Esc
end

public proc mFindMsg ()             // Find Message number at cursor
   string sWordSet[32] = Set (WordSet, ChrSet ( "()0-9" ) )
   string sMsgNum[10]
   PushBlock ()
   BegLine ()
   if MarkWord ()
      sMsgNum = GetMarkedText ()    // Copy msg number
      Copy ()
   endif
   PopBlock ()
   Set (WordSet, sWordSet)
   find (sMsgNum, "+")
end mFindMsg

public proc Mail ()                 // Builds index of Mail messages
   integer save_ins = set (Insert, ON),
           save_ww = set (WordWrap, OFF)
   string MsgNum[6], Dated[6]
   string FromName[28], ToName[28]
   string Subject[28], ConfNum[4]
   integer cnt

   if not lFind ("ber: ", "G")      // Test if any new msgs
      Goto NoNewMsgs
   endif
// Insert Message Header if None
   BegFile ()
   EndLine ()
   if not lFind ("(Numb)", "B")
      BegLine ()
   InsertLine ("(Number) Date Conf         To/From                  Subject")
   endif
   PlaceMark ("Q")
   while lFind ("ber: ", "G")
      WordRight ()
      Backspace ()
      MarkWord ()
      MsgNum = GetMarkedText ()     // Copy message number
      InsertText ("(")
      GoToBlockEnd ()
      InsertText (")")              // Bookmark numb as indexed
      lFind ("Date:", "B")          // Find Date:
      WordRight ()
      MarkWord ()                   // Month
      Dated = GetMarkedText ()      // Store Month
      WordRight ()
      MarkWord ()                   // Day
      Dated = Dated + GetMarkedText () // Store Month+Day
      WordRight ()
      MarkWord ()                   // Year
      Dated = Dated + GetMarkedText () // Store Month+Day+Year
      lFind ("From:", "")           // Find From
      WordRight ()
      UnmarkBlock ()
      MarkStream ()
      Right (25)
      FromName = GetMarkedText ()
      UnmarkBlock ()
      lFind ("To:", "")             // Find To:
      WordRight ()
      MarkChar ()
      Right (25)
      ToName = GetMarkedText ()
      cnt = length( ToName )
      while ToName[ cnt ] == ' '
         cnt = cnt - 1
      endwhile
      ToName = SubStr( ToName, 1, cnt )
      lFind ("Subj:", "")           // Find Subj
      WordRight ()
      UnmarkBlock ()
      MarkChar ()
      GotoColumn (35)
      Subject = GetMarkedText ()
      UnMarkBlock ()
      lFind ("Conf:", "")           // Find Conf
      MarkChar ()
      Right (20)
      MarkChar ()
      PushBlock ()
      GotoBlockBegin ()
      lFind ("(", "L")              // Move to '(' if exist
      WordRight ()
      MarkWord ()                   //   Mark Conf #
      ConfNum = GetMarkedText ()    // Store Conf #
      PopBlock ()
   // Next lines remove "(" and ")" from Conference #
      GotoBlockBegin ()
      lReplace ("(", " ", "LN")
      lReplace (")", " ", "LN")
      UnMarkBlock ()
      PlaceMark ("R")
      GotoMark ("Q")
      AddLine ()
      BegLine ()
      PlaceMark ("Q")
      InsertText ("(" + MsgNum + ")")  // Insert (Number)
      GotoColumn (09)
      InsertText (Dated + " " + ConfNum) // Insert Date, space, Conference #
      GotoColumn (20)
      InsertText (ToName + "/" + FromName) // Insert To / From
      GotoColumn (53)
      DelToEol ()
      GotoColumn (53)
      InsertText (Subject)
      UpdateDisplay ()
      UnMarkBlock ()
      GotoMark ("R")
   endwhile

NoNewMsgs:
   set (Insert, save_ins)
   set (WordWrap, save_ww)
end

<Alt J>   Mail ()
<Alt H>   mFindMsg ()

proc main ()
   message ("Alt J Justifies titles, Alt H indexes message index to Here" )
   Mail ()
end
