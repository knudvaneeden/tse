/*
  To use:

  Type the abbreviation, and press <f12>

  Format of the abbreviation data is:
    $abbreviation1$
    text
    text
    ...
    text

    $abbreviation2$

    etc

    Last entry _must_ be terminated by a $

    Place the '~' character where the final cursor position should be.
    Each entry _must_ have the '~' character.
 */
datadef abbreviations
"$b$"
"binary ['~']"
"    proc foo() : 0"
"end"

"$c$"
"case ~"
"    when"
"    otherwise"
"endcase"

"$d$"
"data ~"
"end"

"$h$"
"help ~"
"end"

"$i$"
"if ~"
"endif"

"$ie$"
"if ~"
"else"
"endif"

"$iee$"
"if ~"
"elseif"
"else"
"endif"

"$ii$"
"iif(~, , )"

"$k$"
"keydef ~"
"end"

"$l$"
"loop"
"    ~"
"endloop"

"$p$"
"proc ~()"
"end"

"$r$"
"repeat"
"until ~"

"$w$"
"while ~"
"endwhile"
"$"
end

integer def_id

proc WhenLoaded()
    PushPosition()
    def_id = CreateTempBuffer()
    InsertData(abbreviations)
    PopPosition()
end

proc Abbreviate()
    string word[32]
    integer indent, i

    // see if there is a word to the left of the cursor
    PushPosition()
    if not Left()           // error if in column 1
        PopPosition()
        return ()
    endif
    // get the word/abbreviation
    PushBlock()
    MarkWord()
    word = '$' + GetMarkedText() + '$'
    // search for abbreviation in the abbreviation list
    GotoBufferId(def_id)
    if not lFind(word, "g^$")
        PopPosition()
        PopBlock()
        return ()
    endif
    // copy the expansion in place of the abbreviation
    UnmarkBlock()
    Down()
    MarkLine()
    while Chr(CurrChar()) <> '$' and Down()
    endwhile
    Up()
    EndLine()
    MarkChar()
    PopPosition()
    WordLeft()
    DelChar(Length(word) - 2)
    CopyBlock()
    // fixup indentation if needed
    indent = CurrCol() - 1
    if indent
        i = indent
        word = ''
        while i
            word = word + ' '
            i = i - 1
        endwhile
        BegLine()
        while Down() and isCursorInBlock()
            InsertText(word, _INSERT_)
            BegLine()
        endwhile
    endif
    GotoBlockBegin()
    // finally, position the cursor and exit
    lFind('~','gl')
    DelChar()
    PopBlock()
end

<f12> Abbreviate()
