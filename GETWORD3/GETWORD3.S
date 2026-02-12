/*  GetWord.  Completes the word being typed with the last word
    in the text starting with the string just typed.  Suggested
    by a VI macro posted on Internet.

    Finds word with leading space, tab, ', ", (, {, [, |, or line begining.

    Use.  Say you want to type "supercalafragilisticexpedalioucious"
    and the word already exists in your text.  Type "superc", press
    the key bound to this macro and the complete word is typed with
    your cursor at the end.

    Mel Hulse and Richard Hendricks, June 19, 1993  v.3
    Thanks to Richard for pounding the RegEx's into my thick scull!
*/

PROC GetWord()
    String  TheWord[40] = "",           // holds the part word
            BigWord[40] = "",           // holds the found word
            Quote[1]    = " "

    Left()                              // cursor back into the word
    MarkWord()                          // mark it
    TheWord = GetMarkedText()           // copy it into a variable
    DelBlock()                          // delete it to make room
    PushPosition()                      // save our position in the file

    If Find("{ }|{\x09}|{'}|{\x22}|{\x28}|{\{}|{\[}|{^}|{\|}"
            + TheWord, "BIX")           // try to find the word
        Right()
        MarkWord()                      // mark the found word
        BigWord = GetMarkedText()       // replace part word with the variable
        UnMarkBlock()                   // the found word
        PopPosition()                   // go to saved position
        If ASK("Is This It: ", BigWord) // Does the user like it?
            InsertText(BigWord, _INSERT_) // yes, insert it
        Else                            // pressed <Esc>
            InsertText(TheWord, _INSERT_) // put original back
        EndIf
        Return()                        // quit
    EndIf
    Message("No Matching Word...")      // tell the user
    PopPosition()                       // clear saved position
    InsertText(TheWord, _INSERT_)       // put the original back
END