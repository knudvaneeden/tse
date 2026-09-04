/*************************************************************************
  Count.S
  Revised By James Coffer

  Overview:  Please position Cursor on the word you want a count of.
  Then Hit the <Alt V> or if you want to Chang e the Key  Assignment
  Then  Load  the  and  use it.  This Count All of the File.  If you
  dont want all of the file to count Just Comment out tke line  with
  BegFile() on it.  Then Position on the and it will count form that
  point to the end of the file.  Have fun Counting.

*************************************************************************/

string proc GetWordAtCursor()
    string word[80] = ''

    PushPosition()
    PushBlock()                     // Save current block status
    if MarkWord() or (Left() and MarkWord())   // Mark the word
        word = GetMarkedText()      // Get it
    endif
    PopBlock()                      // Restore block status
    PopPosition()
    return (word)                   // Thats all, folks!
end GetWordAtCursor

proc mCount()
    integer count = 0
    string s[128] = GetWordAtCursor()
    string opts[12] = Query(FindOptions)

    if Ask("String to count occurrences of:", s) and Length(s) and
        Ask("Options [GLIWX] (Global Local Ignore-case Words reg-eXp):", opts)
        PushPosition()
        BegFile()
        if lFind(s, opts)
            repeat
                count = count + 1
            until not lRepeatFind()
        endif
        PopPosition()
        Message("Found ", count, " occurrence(s)")
    endif
end

PROC Main()
 mCount()
END

<Alt V> mCount()

