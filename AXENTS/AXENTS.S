/****************************************************************************
 MACRO:       AXENTS

 AUTHOR:      Luigi M Bianchi

 DATE:        04-09-94

 DESCRIPTION: These macros turn <` > <'> <"> <^> into dead keys: when pressed,
              if the following key is a vowel, the accented vowel is inserted,
              otherwise the accent is inserted followed by the non-vowel.
              Il the following key is Spacebar the is accent is inserted.

 PARAMETERS:  none

 RETURNS:     nothing

 GLOBAL VARS: none

***************************************************************************/

proc Grave()
    integer key
    string ch[1]
    loop
    key = GetKey()
    ch = Chr(key & 0xff)
        case key
            when <a>
                InsertText("Ö")
            when <e>
                InsertText("ä")
            when <i>
                InsertText("ç")
            when <o>
                InsertText("ï")
            when <u>
                InsertText("ó")
            when <Enter>
                InsertText("`")
                mCReturn()
            when <Spacebar>
                InsertText("`")
            otherwise
                InsertText("`" + ch)
        endcase
        break
    endloop
end

proc Acute()
    integer key
    string ch[1]
    loop
    key = GetKey()
    ch = Chr(key & 0xff)
        case key
            when <a>
                InsertText("†")
            when <e>
                InsertText("Ç")
            when <i>
                InsertText("°")
            when <o>
                InsertText("¢")
            when <u>
                InsertText("£")
            when <Enter>
                InsertText("'")
                mCReturn()
            when <Spacebar>
                InsertText("'")
            otherwise
                InsertText("'" + ch)
        endcase
        break
    endloop
end

proc Umlaut()
    integer key
    string ch[1]
    loop
    key = GetKey()
    ch = Chr(key & 0xff)
        case key
            when <a>
                InsertText("Ñ")
            when <e>
                InsertText("â ")
            when <i>
                InsertText("ã")
            when <o>
                InsertText("î")
            when <u>
                InsertText("Å")
            when <Enter>
                InsertText('"')
                mCReturn()
            when <Spacebar>
                InsertText('"')
            otherwise
                InsertText('"' + ch)
        endcase
        break
    endloop
end

proc Circumflex()
    integer key
    string ch[1]
    loop
    key = GetKey()
    ch = Chr(key & 0xff)
        case key
            when <a>
                InsertText("É")
            when <e>
                InsertText("à ")
            when <i>
                InsertText("å")
            when <o>
                InsertText("ì")
            when <u>
                InsertText("ñ")
            when <Enter>
                InsertText('^')
                mCReturn()
            when <Spacebar>
                InsertText("^")
            otherwise
                InsertText("^" + ch)
        endcase
        break
    endloop
end

<`>                     Grave()
<'>                     Acute()
<Shift '>               Umlaut()
<Shift 6>               Circumflex()

