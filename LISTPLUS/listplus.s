/*

This is an enhanced version of the macro that comes with TSE. As the
original, this macro displays a picklist of lines containing a specified
string and allows the user to jump to one of the found lines. Ennhancements
are the following.

The user can specify a second string: if ';' is appended to the first string,
the macro asks for the second string and searches for lines containing both
strings. If ';' is also appended to the second string, the macro asks for the
allowable distance (in lines) and searches for occurences of the first string
where the second string also occurs within such distance of the first. The
picklist displays only the lines containing the first string.

When executed, the macro asks for the search string and displays as the default
the string used for the previous search (history). That is, unless one of the
two following strings is passed to it via the MacroCmdLine. If the string
'cursor' is passed, the macro asks for a string and displays as the default the
marked string or the word at cursor position. If the string 'repeat' is passed,
the macro uses the previous search specification without asking.

The '|' character is considered a logical 'OR'. Either or both strings
may contain a '|', in which case the macro will look for the string
before the '|' OR the string after it. Use '||' for a literal search of the
'|' character.

                          Jean Heroux
                          heroux.jean@videotron.ca

*/

//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄconfigÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

string app_char[]  = ';', // when appended to search string: more to come...
       lineone[]   = '>> Select this line to edit FindList <<',
       list_name[] = 'findlist',

//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄend configÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

       expr1[255]   = '', expr2[255]   = '', dist[3]     = ''

integer expr1_hist=0, expr2_hist=0, dist_hist=0, distance, reg_exp

// In string ORIG_S, *replace* single character in position P by string INS_S
string proc ReplStr(string ins_s, string orig_s, integer p)
    return(SubStr(orig_s, 1, p-1) + ins_s + SubStr(orig_s, p+1, Length(orig_s)))
end

// Replace regular expression characters in the passed string by their
// token hex value \xnn, so that the string can be used as a regular expression
// in a Find() or Replace() operation
string proc Regular(string input_s)
    string reg[16] = "\.^$|?[]-~*=@#{}", work_s[255]=input_s, token_s[4]=''
    integer i
    for i = 1 to Length(reg)
        while Pos(reg[i], work_s)
            token_s = 'ûx' + Str(Asc(reg[i]), 16)
            work_s = ReplStr(token_s, work_s, Pos(reg[i], work_s))
        endwhile
    endfor
    while Pos('û', work_s)
        work_s = ReplStr('\', work_s, Pos('û', work_s))
    endwhile
    return(work_s)
end

// Return TRUE if expr2 is found within less than 'distance' of current line
integer proc mFindSecond(string expr2)
    integer found = FALSE
    PushPosition()
    PushBlock()
    UnmarkBlock()
    Up(distance)
    MarkLine()
    PopPosition()
    PushPosition()          // if starting pos is less than distance
    Down(distance)          // from beginning or end of file, we don't
    MarkLine()              // know exactly how many lines we marked
    if LFind(expr2, iif(reg_exp, 'glix', 'gli'))
        found = TRUE
    endif
    UnmarkBlock()
    PopBlock()
    PopPosition()
    return(found)
end

// Returns the last character of the passed string
string proc mTail(string passed_str)
    return(passed_str[Length(passed_str)])
end

// Returns the passed string minus the last character
string proc mTruncate(string passed_str)
   return(SubStr(passed_str, 1, Length(passed_str)-1))
end

// Returns a text string describing the search parameters
string proc mSearchDef()
    return(expr1 + iif(expr2=='','',' & '+expr2) + iif(expr2=='', '',
           iif(distance<>0, '  ['+str(distance)+']', '  [same line]')))
end

// Asks for 1st string, and for a second string if the 1st ends with
// app_char. Asks for distance if second string also ends with app_char.
integer proc mAskStrings()
    string expr1_brut[255] = '', expr2_brut[255] = ''

// Case 1: one string
    if not (Ask('String[|'+app_char+'] ?', expr1_brut, expr1_hist)
                        and Length(expr1_brut))
        return(FALSE)
    endif
    if mTail(expr1_brut) <> app_char
        expr1 = expr1_brut
        expr2 = ''
        distance = 0
        return(TRUE)
    endif

// Case 2: two strings on the same line
    if not (Ask('2nd string[|'+app_char+'] ?',expr2_brut,expr2_hist)
                            and Length(expr2_brut))
        return(FALSE)
    endif
    if mTail(expr2_brut) <> app_char
        expr1 = mTruncate(expr1_brut)
        expr2 = expr2_brut
        distance = 0
        return(TRUE)
    endif

// Cas 3: two strings separated by distance
    if not (Ask("Distance in lines?", dist, dist_hist) and Length(dist))
        return(FALSE)
    endif
    expr1 = mTruncate(expr1_brut)
    expr2 = mTruncate(expr2_brut)
    distance = Val(dist)
    return(TRUE)
end

proc Main()
    string search_type[6]=Lower(Query(MacroCmdLine)), // line[255]='',
           expr1a[128]   = '', expr1b[128]   = '',
           expr2a[128]   = '', expr2b[128]   = ''

    integer found_line,      // saved CurrLine() for compressed view
            list_no,         // line we exited on
            startup_line,    // line number we were on
            hilite_line,
            width,
            mk,
            pos_or1,
            pos_or2,
            list_id,
            old_clip_id,
            maxlen = Length(lineone),
            current_id = GetBufferId(),
            line_id = CreateTempBuffer()

    GotoBufferId(current_id)
    Set(Break, ON)
// Initialize histories
    if expr1_hist == 0   // This must be first time - initialize
        expr1_hist = GetFreeHistory('ui:expr1')
        expr2_hist = GetFreeHistory('ui:expr2')
        dist_hist = GetFreeHistory('ui:dist')
        AddHistoryStr('5', dist_hist)
    endif

// Get string(s) and distance
    if search_type == 'cursor'
        case isCursorInBlock()
            when _COLUMN_, _INCLUSIVE_
                AddHistoryStr(GetMarkedText(), expr1_hist)
                UnmarkBlock()
            otherwise
                AddHistoryStr(GetWord(), expr1_hist)
        endcase
    endif
    if ( search_type<>'repeat' or expr1=='' ) and not mAskStrings()
        return()
    endif
    if NumLines() == 0
        return ()
    endif

// If either string contains '|', it is an OR  a|o
   reg_exp = FALSE
   pos_or1 = Pos('|', expr1)
   pos_or2 = Pos('|', expr2)
   if pos_or1
       expr1a = Substr(expr1, 1, (pos_or1 - 1))
       expr1b = Substr(expr1, (pos_or1 + 1), Length(expr1))
       if Pos('|', expr1b)==1                    // literal search for '|'
           expr1 = expr1a + expr1b
           pos_or1 = FALSE
       elseif not (Length(expr1a) and Length(expr1b))
           pos_or1 = FALSE
       endif
   endif
   if pos_or2
       expr2a = Substr(expr2, 1, (pos_or2 - 1))
       expr2b = Substr(expr2, (pos_or2 + 1), Length(expr2))
       if Pos('|', expr2b)==1       // literal search for '|'
           expr2 = expr2a + expr2b
           pos_or2 = FALSE
       elseif not (Length(expr2a) and Length(expr2b))
           pos_or1 = FALSE
       endif
   endif
   if pos_or1>1 or pos_or2>1
       reg_exp = TRUE
       if pos_or1
           expr1 = '{'+Regular(expr1a)+'}|{'+Regular(expr1b)+'}'
       endif
       if pos_or2
           expr2 = '{'+Regular(expr2a)+'}|{'+Regular(expr2b)+'}'
       endif
   endif

// Find or create compress buffer
    list_id = CreateBuffer(list_name)
    if not list_id
        list_id = GetBufferId(list_name)
        if list_id == current_id
            warn("Can't use this buffer")
            return ()
        else
            GotoBufferId(list_id)
        endif
    endif
    EmptyBuffer()
    InsertText(lineone)
    GotoBufferId(current_id)

// Initialize search variables
    width = Length(Str(NumLines()))
    startup_line = CurrLine()
    list_no = 0
    found_line = 0
    hilite_line = 1

// Search for string(s)
    PushPosition()
    PushBlock()
    UnmarkBlock()
    old_clip_id = Query(ClipBoardId)
    Set(ClipBoardId, line_id)
    BegFile()
    Message('Searching...')
    while LFind(expr1, iif(reg_exp, 'ix', 'i'))
        if expr2=='' or mFindSecond(expr2)
            EndLine()
            MarkColumn()
            BegLine()
            Copy()
            found_line = CurrLine()
            if CurrLineLen() > maxlen
                maxlen = CurrLineLen()
            endif
            GotoBufferId(list_id)
            AddLine()
            BegLine()
            Paste()
            UnmarkBlock()
            InsertText(Format(found_line:width, ': '))
            if hilite_line==1 AND found_line > startup_line
                hilite_line = CurrLine() - 1
            endif
            GotoBufferId(current_id)
        endif
        EndLine()
    endwhile
    AbandonFile(line_id)
    PopPosition()
    PopBlock()
    Set(ClipBoardId, old_clip_id)


// Display search results
    UpdateDisplay(_STATUSLINE_REFRESH_ | _WINDOW_REFRESH_)
    if not found_line
        GotoBufferId(current_id)
        AbandonFile(list_id)
        Message('Not found:  '+mSearchDef())
        return()
    endif
    GotoBufferId(list_id)
    GotoLine(hilite_line)
    if List('Search for: '+ mSearchDef(), maxlen+width+4)
        if CurrLine() == 1
            mk = Set(KillMax, 0)
            DelLine()
            Set(KillMax, mk)
            FileChanged(FALSE)
            return ()
        endif
        list_no = val(GetText(1, width))    // if CurrLine() <> 1
    endif

// Jump to selected line
    GotoBufferId(current_id)
    AbandonFile(list_id)
    if list_no
        GotoLine(list_no)
        ScrollToRow(Query(WindowRows)/2)
    endif
end
