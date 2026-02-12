/*


    YACS - Yet Another Commenting System

    Author: Michael Graham <magmac@occamstoothbrush.com>

    v1.1.8 - Jun 19, 2002

    Originally loosely based on John D. Goodman's wonderful I_CMMT.S
    package (version 1.0), which I used for many years.  But recently
    I rewrote it more or less from scratch, removing the bits I never
    used and including all the features I have added over the years. I
    don't think any significant pieces of I_CMMT code survived the
    rewrite.

    
    Copyright (c) 2002 - Michael Graham <magmac@occamstoothbrush.com>

    This program is Free Software - you may use it, modify it and
    distribute it under the the terms of the Perl Artistic License,
    which you may find at:

          http://www.perl.com/CPAN/doc/misc/license/Artistic

    In particular, note that you use this software at your own risk!

    The latest version of my TSE macros can be found at:

        http://www.occamstoothbrush.com/tsemac/



*/

#ifndef WIN32
#include ['profile.si']
#endif

#include ['setcache.si']
#include ['pcache.si']
#include ['FindProf.si']

string  Default_Comment[20]               = "# "
string  Comment_String[20]                = ""
string  Comment_String_Trimmed[20]        = ""
string  Comment_Regexp[20]                = ""
string  Comment_Regexp_Trimmed[20]        = ""
string  Line_Begin_Regexp[]               = '^{[ \t]*}'
integer Settings_Serial                   = 0
integer Settings_Loaded                   = 0
string  Language_Extensions[255]          = ''
string  Cmode_Extensions[255]             = ''
integer Language_Mode                     = 0
integer Blank_Before_Duplicate            = 1
integer Comment_History

proc Debug (string msg)
    UpdateDisplay()
    Warn(msg)
    if 0
        Debug('')
    endif
end

proc BuildCommentStrings(string cs)
    integer p = 0
    integer escape_pending = 0
    integer any_escapes    = 0

    Comment_String         = ""
    Comment_String_Trimmed = ""
    Comment_Regexp         = ""
    Comment_Regexp_Trimmed = ""
    escape_pending         = 0
    p                      = 1
    any_escapes            = 0

    while p <= Length(cs)
        if escape_pending
            case cs[p]
            when '\'
                Comment_String = Comment_String + '\'
            when 't'
                Comment_String = Comment_String + Chr(9)
            when 's'
                Comment_String = Comment_String + ' '
            otherwise
                Comment_String = Comment_String + cs[p]
            endcase
            escape_pending = 0
        endif
        if cs[p:1] == '\'
            escape_pending = 1
            any_escapes    = 1
        else
            Comment_String = Comment_String + cs[p]
        endif
        p = p + 1
    endwhile

    // Escape Regexp characters - put a backslash in front of anything
    // that isn't a number or a letter, and convert tab character into \t

    p = 1
    while p <= Length(Comment_String)
        case Asc(Comment_String[p])
            when 48 .. 57, 65 .. 90, 97 .. 122          // 0-9, A-Z, a-z
                Comment_Regexp = Comment_Regexp + Comment_String[p]
            when 9                                      // Tab
                Comment_Regexp = Comment_Regexp + '\t'
            otherwise                                   // some other punctuation
                Comment_Regexp = Comment_Regexp + '\' + Comment_String[p]
        endcase
        p = p + 1
    endwhile

    p = Length(Comment_String)
    while p and ( cs[p] == ' ' or cs[p] == Chr(9))
        p = p - 1
    endwhile

    Comment_Regexp_Trimmed = Comment_Regexp

    if not any_escapes
        Comment_String = Comment_String + ' '
        Comment_Regexp = Comment_Regexp + ' '
    endif

    Comment_String_Trimmed = cs[1:p]

    // Debug("csr:"+Comment_Regexp)
    // Debug("csrt:"+Comment_Regexp_Trimmed)

end

proc LoadGeneralSettings()
    if (not Settings_Loaded) or NeedToReloadSettings(Settings_Serial)
        Settings_Serial        = GetSettingsRefreshSerial()
        Language_Extensions    = GetProfileStr('UI','language_extensions','',FindProfile()) + ','
        Blank_Before_Duplicate = GetProfileInt('YACS','blank_before_duplicate',0,FindProfile())
        Settings_Loaded        = 1
    endif
end

proc LoadPerFileSettings()
    string cs[20] = ""
    string curr_ext[4] = CurrExt()
    string curr_ext_no_dot[4] = ""

    LoadGeneralSettings()

    if isMacroLoaded('CurrExt')
        curr_ext = GetGlobalStr('CurrExt')
    endif

    curr_ext_no_dot = curr_ext[2..Length(curr_ext)]

    // cs = GetProfileStr('YACS_Comment_Strings',curr_ext_no_dot,Default_Comment,FindProfile())
    cs = GetProfileStrCached('YACS_Comment_Strings',curr_ext_no_dot,Default_Comment,FindProfile())
    cs = Trim(cs)

    if curr_ext <> ''
        if Pos(curr_ext + ',',Language_Extensions)
        or Pos(curr_ext + ',',Cmode_Extensions)
            Language_Mode = TRUE
        endif
    endif

    BuildCommentStrings(cs)
end

proc WhenLoaded()

   Comment_History   = GetFreeHistory('I_CMMT:General')

   AddHistoryStr( "#",   Comment_History )  // common in-line comment
   AddHistoryStr( "//",  Comment_History )  // strings
   AddHistoryStr( ";",   Comment_History )
   AddHistoryStr( "REM", Comment_History )
   AddHistoryStr( "&&",  Comment_History )
   AddHistoryStr( "*",   Comment_History )

   Hook(_ON_CHANGING_FILES_, LoadPerFileSettings)

   // Set(Break, ON)
   LoadPerFileSettings()

end

integer proc isCommented(integer line)
    PushPosition()
    GotoLine(line)

    // Debug('matching on: ' + Line_Begin_Regexp + Comment_Regexp_Trimmed)
    if lFind(Line_Begin_Regexp + Comment_Regexp_Trimmed, 'gxc')
        PopPosition()
        return(1)
    endif

    PopPosition()
    return(0)
end

integer proc isOnlyComment(integer line)
    PushPosition()
    GotoLine(line)

    if lFind(Line_Begin_Regexp + Comment_Regexp_Trimmed + '[ \t]*$' , 'gxc')
        PopPosition()
        return(1)
    endif

    PopPosition()
    return(0)
end

proc lCommentRange(integer c_start, integer c_end, integer col_start)
    integer start_column

    PushPosition()

    GotoLine(c_start)

    start_column = Max(PosFirstNonWhite(),1)

    if col_start
        start_column = col_start
    endif

    GotoColumn(start_column)

    while InsertText(Comment_String, _INSERT_)
      and CurrLine() < c_end
      and Down()
        GotoColumn(start_column)
        if CurrPos() > PosFirstNonWhite()
            and CurrLineLen()
            GotoColumn(PosFirstNonWhite())
        endif
    endwhile

    PopPosition()

end

proc CommentRange(integer c_start, integer c_end)
    lCommentrange(c_start, c_end, 0)
end

proc ContinueCommentRange(integer c_start, integer c_end)
    integer col_start
    PushPosition()
    Up()
    col_start = PosFirstNonWhite()
    PopPosition()
    lCommentrange(c_start, c_end, col_start)
end

proc UnCommentRange(integer c_start, integer c_end)

    PushPosition()

    GotoLine(c_start)

    while 1
        if not lReplace ( Line_Begin_Regexp + Comment_Regexp, '\1', 'gcixn')
            lReplace ( Line_Begin_Regexp + Comment_Regexp_Trimmed, '\1', 'gcixn')
        endif
        if (not down()) or CurrLine() > c_end
            break
        endif
    endwhile

    PopPosition()

end

proc lToggleComment(integer leave_block_marked)
    if isCursorInBlock()
        if isCommented(Query(BlockBegLine))
            // Debug('block is commented ('+Str(Query(BlockBegLine)) +':'+Str(Query(BlockEndLine)))
            UnCommentRange(Query(BlockBegLine), Query(BlockEndLine))
            if not leave_block_marked
                UnMarkBlock()
            endif
        else
            // Debug('block is not commented')
            CommentRange(Query(BlockBegLine), Query(BlockEndLine))
            if not leave_block_marked
                UnMarkBlock()
            endif
        endif
    else
        if isCommented(CurrLine())
            // Debug('line is commented')
            UnCommentRange(CurrLine(), CurrLine())
            if PosLastNonWhite() == 0 and CurrPos() > 1
                Left()
            endif
        else
            // Debug('line is not commented')

            if CurrPos() >= CurrLineLen()
                if CurrPos() == CurrLineLen()
                    Right()
                endif
                if CurrPos() == CurrLineLen() + 1
                    and CurrPos() > 1
                    InsertText(' ')
                endif
                if not lFind(Comment_Regexp_Trimmed + '[ \t]*$', 'gxc')
                    InsertText(Comment_String)
                endif
            else
                CommentRange(CurrLine(), CurrLine())
                if not PosFirstNonWhite()
                    Left()
                endif
            endif
        endif
    endif
end

proc ToggleComment()
    lToggleComment(0)
end
proc ToggleCommentLeavingBlockMarked()
    lToggleComment(1)
end

integer proc mcJoinLine()
    // Code for deleting comment on next line goes here
    // If language and next line is commented,
    // Delete comment from next line before join.
    // Including much frumious hackery to suit my own particular
    // style of commenting. One thing this won't handle well is
    // comment sequences that don't end with a space.

    integer prev_pos = Max(CurrLineLen(), CurrPos())

    PushBlock()
    PushPosition()

    if Language_Mode
      and isCommented(CurrLine()) and isCommented(CurrLine()+1)
        UnCommentRange(CurrLine()+1, CurrLine()+1)
        GotoColumn(PosLastNonWhite()+1)
        DelToEol()

        InsertText(" ", _INSERT_)

        JoinLine()

    else
        JoinLine()
    endif

    PopBlock()
    PopPosition()

    GotoColumn(prev_pos)

    return(1)
end

proc MarkParagraph()
    integer para_start  = 0
    integer para_end    = 0
    integer para_indent = 0

    PushPosition()
    while CurrLineLen() == 0 and Down()
    endwhile

    para_start = CurrLine()

    if Query(ParaEndStyle) == 0
        while CurrLineLen() > 0
            para_end = CurrLine()
            if not Down()
                break
            endif
        endwhile
    else
        para_indent = PosFirstNonWhite()
        while PosFirstNonWhite() <> para_indent
            para_end = CurrLine()
            if not Down()
                break
            endif
        endwhile
    endif

    UnmarkBlock()
    MarkLine(para_start, para_end)
    PopPosition()
end

proc mcWrapPara()
    integer para_commented = 0

    if not Language_Mode
        ChainCmd()
        return()
    endif

    PushPosition()
    PushBlock()

    MarkParagraph()

    GotoBlockBegin()

    repeat
        if isCommented(CurrLine())
            para_commented = 1
        endif
    until ((not Down()) or CurrLine() >= Query(BlockEndLine))

    if para_commented
        UnCommentRange(Query(BlockBegLine), Query(BlockEndLine))

        GotoBlockBegin()

        WrapPara()

        KillPosition()
        PushPosition()

        GotoBlockBegin()

        MarkParagraph()

        CommentRange(Query(BlockBegLine), Query(BlockEndLine))

    else
        PopBlock()
        PopPosition()

        ChainCmd()
        return()
    endif

    PopBlock()
    PopPosition()
end

proc ChooseCommentString ()
    string cs_prompt[255]=Default_Comment
    if Ask("Comment Character:", cs_prompt, Comment_History)
        BuildCommentStrings(Trim(cs_prompt))
    endif
end

proc CommentAndDuplicate()

    integer block_start = 1
    integer block_end   = 1

    LoadGeneralSettings()

    if not isBlockMarked()
        block_start = CurrLine()
        block_end   = CurrLine()
    else
        block_start = Query(BlockBegLine)
        block_end   = Query(BlockEndLine)
    endif

    UnmarkBlock()

    MarkLine(block_start,block_end)

    GotoLine(block_end)

    if (Blank_Before_Duplicate)
        Down()
        InsertLine()
    endif

    if Query(InsertLineBlocksAbove)
        Down()
    endif

    CopyBlock()

    CommentRange(block_start, block_end)

    UnmarkBlock()
end

// Enter
//     erases comment if line contains only comment string
//     continues comment on next line if this line begins with comment
proc mcCReturn()
    if isCommented(CurrLine())
        // debug("iscommented")
        if isOnlyComment(CurrLine())
            // debug("isonlycommented")
            UnCommentRange(CurrLine(), CurrLine())
            if not PosFirstNonWhite()
                Left()
            endif
        else
            // debug("isnotonlycommented")
            if GetText(CurrPos(), Length(Comment_String_Trimmed)) == Comment_String_Trimmed
                ChainCmd()
                return()
            else
                CReturn()
                ContinueCommentRange(CurrLine(), CurrLine())
                GotoColumn(PosFirstNonWhite() + Length(Comment_String))
            endif
        endif
    else
        // debug("notcommented")
        ChainCmd()
        return()
    endif
end

integer proc mcDelChar()
    UpdateDisplay()
    return(iif(CurrChar() >= 0, DelChar(), mcJoinLine()))
    // ChainCmd()
end

proc mcBackSpace()
    if CurrPos() == 1
        if PrevChar()
            mcJoinLine()
        endif
    else
        ChainCmd()
        return()
    endif
end

integer proc mcDelRightWord()
    PushBlock()
    PushPosition()

    if Language_Mode and CurrPos() > CurrLineLen()
        return(mcJoinLine())
    else
        return(DelRightWord())
    endif
    return(0)
end

// ------------------------------------------------------------
// Keydefs.  You probably don't want to change these first three,
// because these just override built in behaviour, and then Chain
// to the builtin behaviour when they're done.

<enter>     mcCReturn()
<BackSpace> mcBackSpace()
<Del>       mcDelChar()

// ------------------------------------------------------------
// Here are the keys you can change:

// ToggleComment: This is the main one!
<ctrl n>    ToggleComment()

// The following are basic editor functions, so assign them
// to whatever you normally use.

<Ctrl t>    mcDelRightWord()
<Ctrl Del>  mcDelRightWord()
<Alt z>     mcWrapPara()


// // A bonus feature, CommentAndDuplicate takes a block,
// // makes a duplicate, and then comments out the first
// // copy.  It lets you hack some code while keeping a commented
// // copy.
// <ctrlshift n> CommentAndDuplicate()
//
// // Same thing as ToggleComment but leaves the block marked.
// <ctrlalt n> ToggleCommentLeavingBlockMarked()
//
// // Brings up the Choose Comment String menu.  Slightly broken,
// // because it will forget your choice when you switch files.
// // For more permanent results, edit TSE.INI
//
// <ctrlshift 0> ChooseCommentString()


// My Keys
<ctrl n>    ToggleComment()
<Ctrl o>    mcDelChar()
<Ctrl Del>  mcDelRightWord()
<Alt z>     mcWrapPara()
<ctrl g><m> CommentAndDuplicate()
<ctrlshift n> ToggleCommentLeavingBlockMarked()
<ctrlshift 0> ChooseCommentString()



