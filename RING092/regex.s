
/*

    Macro for matching regular expressions against strings

*/

#ifndef MAXSTRINGLEN
#define MAXSTRINGLEN 255
#endif

integer Regex_Buffer = 0

constant MAX_FIND_OPTS = 15

// IN:  Regex::String
// IN:  Regex::Expr
// IN:  Regex::Opts
// OUT: Regex::Matched
// OUT: Regex::Match_All
// OUT: Regex::Match_1
// OUT: Regex::Match_2
// OUT: Regex::Match_3
// OUT: Regex::Match_4
// OUT: Regex::Match_5
// OUT: Regex::Match_6
// OUT: Regex::Match_7
// OUT: Regex::Match_8
// OUT: Regex::Match_9

proc Regex_Match ()
    string opts[MAX_FIND_OPTS] = GetGlobalStr('Regex::Opts')

    opts = opts + 'x'

    PushPosition()
    GotoBufferID(Regex_Buffer)
    EmptyBuffer()
    if AddLine(GetGlobalStr('Regex::String'))
        if lFind(GetGlobalStr('Regex::Expr'), opts)
            SetGlobalInt('Regex::Matched', TRUE)

            SetGlobalStr('Regex::Match_All', GetFoundText())
            SetGlobalStr('Regex::Match_1',   GetFoundText(1))
            SetGlobalStr('Regex::Match_2',   GetFoundText(2))
            SetGlobalStr('Regex::Match_3',   GetFoundText(3))
            SetGlobalStr('Regex::Match_4',   GetFoundText(4))
            SetGlobalStr('Regex::Match_5',   GetFoundText(5))
            SetGlobalStr('Regex::Match_6',   GetFoundText(6))
            SetGlobalStr('Regex::Match_7',   GetFoundText(7))
            SetGlobalStr('Regex::Match_8',   GetFoundText(8))
            SetGlobalStr('Regex::Match_9',   GetFoundText(9))
        else
            SetGlobalInt('Regex::Matched', FALSE)

            SetGlobalStr('Regex::Match_All', '')
            SetGlobalStr('Regex::Match_1',   '')
            SetGlobalStr('Regex::Match_2',   '')
            SetGlobalStr('Regex::Match_3',   '')
            SetGlobalStr('Regex::Match_4',   '')
            SetGlobalStr('Regex::Match_5',   '')
            SetGlobalStr('Regex::Match_6',   '')
            SetGlobalStr('Regex::Match_7',   '')
            SetGlobalStr('Regex::Match_8',   '')
            SetGlobalStr('Regex::Match_9',   '')
        endif
    endif
    PopPosition()
end

// IN:  Regex::String
// IN:  Regex::Expr
// IN:  Regex::Opts
// IN:  Regex::Replacement
// OUT: Regex::Matched
// OUT: Regex::String

proc Regex_Subst ()
    string opts[MAX_FIND_OPTS] = GetGlobalStr('Regex::Opts')

    opts = opts + 'xn'

    PushPosition()
    GotoBufferID(Regex_Buffer)
    EmptyBuffer()

    if AddLine(GetGlobalStr('Regex::String'))
        if lReplace(GetGlobalStr('Regex::Expr'), GetGlobalStr('Regex::Replacement'), opts)
            BegLine()

            SetGlobalStr('Regex::String', GetText(1, Min(MAXSTRINGLEN, CurrLineLen())))
            SetGlobalInt('Regex::Matched', TRUE)
        else
            SetGlobalInt('Regex::Matched', FALSE)
        endif
    endif
    PopPosition()
end

proc WhenLoaded ()
    PushPosition()
    Regex_Buffer = CreateTempBuffer()
    PopPosition()
end

proc WhenPurged ()
    AbandonFile(Regex_Buffer)
end

proc Main ()
    string cmd[2]

    cmd  = SubStr(Query(MacroCmdLine), 1, 2)

    case cmd
        when "-m" // Match
            Regex_Match()

        when "-s" // Subst
            Regex_Subst()

        otherwise // Default to Match
            Regex_Match()

    endcase
end

