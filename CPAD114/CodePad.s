/*

    CodePad - Line up code nicely into columns

    v1.1.4 - Jun 19, 2002

    
    Copyright (c) 2002 - Michael Graham <magmac@occamstoothbrush.com>

    This program is Free Software - you may use it, modify it and
    distribute it under the the terms of the Perl Artistic License,
    which you may find at:

          http://www.perl.com/CPAN/doc/misc/license/Artistic

    In particular, note that you use this software at your own risk!

    The latest version of my TSE macros can be found at:

        http://www.occamstoothbrush.com/tsemac/



*/


integer pad_history

string auto_pad_set[32]     = '= => ) if # ,'
string default_pad_set1[32] = '='
string default_pad_set2[32] = '=>'
string default_pad_set3[32] = ')'
string default_pad_set4[32] = ') = =>'
string default_pad_set5[32] = ''

integer Settings_Loaded = 0
integer Settings_Serial = 0

proc Debug (string msg)
    UpdateDisplay()
    Warn(msg)
    if FALSE
        Debug('')
    endif
end

#ifndef WIN32
#include ['profile.si']
#endif

#include ['findprof.si']
#include ["setcache.si"]

proc LoadPadSets()
    if (not Settings_Loaded) or NeedToReloadSettings(Settings_Serial)
        Settings_Serial  = GetSettingsRefreshSerial()
        auto_pad_set     = trim(GetProfileStr('CodePad','auto_pad_set',auto_pad_set, FindProfile()))
        default_pad_set1 = trim(GetProfileStr('CodePad','default_pad_set1',default_pad_set1, FindProfile()))
        default_pad_set2 = trim(GetProfileStr('CodePad','default_pad_set2',default_pad_set2, FindProfile()))
        default_pad_set3 = trim(GetProfileStr('CodePad','default_pad_set3',default_pad_set3, FindProfile()))
        default_pad_set4 = trim(GetProfileStr('CodePad','default_pad_set4',default_pad_set4, FindProfile()))
        default_pad_set5 = trim(GetProfileStr('CodePad','default_pad_set5',default_pad_set5, FindProfile()))
        Settings_Loaded = 1
    endif
end

integer proc FindNearestWhite(string find_text)
    if lFind(find_text,'c')
        Left()

        while IsWhite() and CurrPos() > 1
            Left()
        endwhile

        if not IsWhite()
            Right()
            Right()
        endif
        // don't go furthur left than first character
        GotoColumn(max(CurrCol(),PosFirstNonWhite()))
        // debug('find_text ' + find_text + '; currcol: ' + Str(CurrCol()))
        return(1)
    endif
    return (0)
end

proc Pad(string text)
    string ask_text[80]        = ''
    integer startblock         = IsCursorInBlock()
    string find_text[10]       = ''
    integer furthest_column    = 0
    integer token              = 1
    integer passed_up_blanks   = 0
    integer passed_down_blanks = 0
    integer answered           = 0
    integer matches            = 0
    integer lines              = 0

    LoadPadSets()

    if text == ""
        if not pad_history
            pad_history = GetFreeHistory("PAD:find")
            AddHistoryStr(auto_pad_set, pad_history)
            if default_pad_set5 <> ''
                AddHistoryStr(default_pad_set5, pad_history)
            endif
            if default_pad_set4 <> ''
                AddHistoryStr(default_pad_set4, pad_history)
            endif
            if default_pad_set3 <> ''
                AddHistoryStr(default_pad_set3, pad_history)
            endif
            if default_pad_set2 <> ''
                AddHistoryStr(default_pad_set2, pad_history)
            endif
            if default_pad_set1 <> ''
                AddHistoryStr(default_pad_set1, pad_history)
            endif
        endif

        PushPosition()
        BegWindow()
        BegLine()
        answered = Ask('Pad whitespace around what string(s)? (separate multiple strings with spaces)', ask_text, pad_history)
        PopPosition()

    else
        ask_text = text
        answered = 1
    endif

    if answered

        if ask_text == ' ' or not Pos(' ', ask_text)
            find_text = ask_text
            ask_text  = ''
        else
            find_text = Trim(GetToken(ask_text,' ',token))
        endif

        while find_text <> ""

            lines   = 0
            matches = 0

            furthest_column = 0
            BegLine()

            PushPosition()

            // debug('find_text: ' + find_text)

            if startblock or FindNearestWhite(find_text)
                furthest_column = 0
                if startblock
                    GotoBlockBegin()
                    BegLine()
                    repeat
                        BegLine()
                        Right()
                        lines = lines + 1
                        if FindNearestWhite(find_text)
                            furthest_column = max(furthest_column, CurrPos())
                            matches = matches + 1
                        endif
                    until (not IsCursorInBlock()) or (not Down())

                    if matches < lines - 1
                        matches = 0
                    endif
                else
                    passed_up_blanks = 0
                    passed_down_blanks = 0

                    PushPosition()

                    Up()
                    while CurrLineLen() == 0 and Up()
                        passed_up_blanks = 1
                    endwhile

                    Begline()
                    if lFind(find_text,'c')
                        matches = 1
                        furthest_column = max(furthest_column, CurrPos())
                    endif

                    PopPosition()

                    PushPosition()

                    Down()
                    while CurrLineLen() == 0 and Down()
                        passed_down_blanks = 1
                    endwhile

                    Begline()
                    if lFind(find_text,'c')
                        matches = 1
                        if not passed_down_blanks or passed_up_blanks
                            furthest_column = max(furthest_column, CurrPos())
                        endif
                    endif

                    PopPosition()

                endif

                if furthest_column and matches

                    PopPosition()
                    PushPosition()

                    if startblock
                        GotoBlockBegin()
                    endif
                    BegLine()
                    repeat
                        if FindNearestWhite(find_text)
                            while IsWhite()
                                DelChar()
                            endwhile
                            while CurrPos() < furthest_column
                                InsertText(' ',_INSERT_)
                            endwhile
                        endif
                    until not startblock or not IsCursorInBlock() or not (Down() and Right() and BegLine())
                endif

            endif
            PopPosition()
            token = token + 1
            find_text = Trim(GetToken(ask_text,' ',token))

        endwhile
        if startblock
            UnmarkBlock()
        endif
    else
        return()
    endif
end

proc AutoPad()
    integer top_line = CurrLine()
    integer end_line = CurrLine()
    // integer this_line_indent = 0
    integer last_line_indent = 0

    LoadPadSets()

    if not isCursorInBlock()
        PushPosition()
        PushBlock()

        UnmarkBlock()
        BegLine()
        Up()

        last_line_indent = PosFirstNonWhite()
        while CurrLineLen() > 0
          and last_line_indent == PosFirstNonWhite()
          and lFind('[a-zA-Z_]+','xc')
            BegLine()
            last_line_indent = PosFirstNonWhite()

            top_line = CurrLine()
            if not Up()
                break
            endif
        endwhile

        PopPosition()
        PushPosition()

        last_line_indent = PosFirstNonWhite()
        BegLine()
        Down()
        while CurrLineLen() > 0
          and last_line_indent == PosFirstNonWhite()
          and lFind('[a-zA-Z_]+','xc')
            BegLine()
            last_line_indent = PosFirstNonWhite()
            end_line = CurrLine()
            Down()
        endwhile

        PopPosition()
        PushPosition()

        MarkLine(top_line,end_line)

        Pad(auto_pad_set)

        PopBlock()
        PopPosition()
    else
        Pad(auto_pad_set)
    endif

end

proc Main()
    string cmd[2] = Lower(Query(MacroCmdLine))

    Set(Break, ON)
    LoadPadSets()

	case cmd
    when "-a"
        AutoPad()
    when ""
        Pad('')
    endcase
    return()
end

// Add Key commands here if desired
// <Ctrl g><d> AutoPad()
// <Ctrl g><s> Pad('')

