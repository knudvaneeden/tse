//
//  File$Id: dspell.s 0.12.0.1 1995/07/15 14:38:04 drm Exp $
//  $Source: C:/USR/TSE/RCS/dspell.s $
//
//  Alternative Spelling Checker for TSE by Dave Monksfield
//  (uses the TSE spell checking engine spellbin.bin)
//
//  Comments or suggestions to: drm@myob.demon.co.uk
//
//  Copyright (c) 1995  D.R.Monksfield
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
//

// External spell checking engine
binary ['spellbin.bin']
    integer proc OpenSpell(string fn) : 0
    integer proc CloseSpell() : 3
    integer proc SpellCheckWord(string word) : 6
    integer proc SuggestWord(string word) : 9
    proc GetSuggestion(var string word, integer n) : 12
end

// Global constants
string WordPattern[] = "[A-Za-z][A-Za-z]#"

// Global variables
string FindScope[4]
integer WordListBuf
integer DocumentWindow, WordListWindow

// Function prototypes
forward proc mSpellCheck()
forward integer proc mCreateWordlist()
forward proc mViewWordlist()
forward proc mLocateWord()
forward proc mChangeWord()
forward integer proc mNeedToRemoveWord()
forward integer proc mRemoveThisWord()
forward integer proc mGetCurrWord(var string word)
forward proc mInitProgress()
forward proc mDisplayProgress()

// Invocations keys
<F8> mSpellCheck()


proc mSpellCheck()
    string fn[128]

    fn = SearchPath("semware.lex", Query(TSEPath), "SPELL\")
    if Length(fn) == 0 or not OpenSpell(fn)
        Warn("ERROR: cannot locate dictionary")
        return()
    endif
    PushPosition()
    WordListBuf = CreateBuffer("*WL*")
    PopPosition()
    if not WordListBuf
        CloseSpell()
        Warn("ERROR: cannot create buffer for word list")
        return()
    endif
    Set(Marking, off)
    FindScope = iif(isBlockInCurrFile(), "l", "")

    if mCreateWordlist()
        mViewWordlist()
    else
        Message("No unrecognized words found")
    endif

    AbandonFile(WordListBuf)
    CloseSpell()
    return()
end

integer proc mCreateWordlist()
    integer wc
    string word[80]
    string find_opt[8]

    PushPosition()
    mInitProgress()
    find_opt = "gwx"
    while lFind(WordPattern, find_opt + FindScope)
        PushBlock()
        MarkFoundText()
        word = GetMarkedText()
        PopBlock()
        if not SpellCheckWord(word)
            PushPosition()
            GotoBufferId(WordListBuf)
            if not lFind(word, "g^$")
                EndFile()
                AddLine(word)
            endif
            PopPosition()
        endif
        mDisplayProgress()
        find_opt = "+wx"
    endwhile
    GotoBufferID(WordListBuf)
    wc = NumLines()
    PopPosition()
    return(wc)
end

keydef SpellKeys
    <Tab> EndProcess()
    <F8>  EndProcess()
end

proc mViewWordlist()
    OneWindow()
    DocumentWindow = WindowID()
    VWindow()
    ResizeWindow(_LEFT_, 16-Query(WindowCols))
    UpdateDisplay(_WINDOW_REFRESH_)
    WordListWindow = WindowID()
    BegFile()
    mLocateWord()
    loop
        case GetKey()
        when <CursorUp>
            Up()
            mLocateWord()
        when <CursorDown>
            Down()
            mLocateWord()
        when <PgUp>
            PageUp()
            mLocateWord()
        when <PgDn>
            PageDown()
            mLocateWord()
        when <Home>
            BegFile()
            mLocateWord()
        when <End>
            EndFile()
            BegLine()
            mLocateWord()
        when <n>, <CursorRight>
            GotoWindow(DocumentWindow)
            RepeatFind(_FORWARD_)
            GotoWindow(WordListWindow)
        when <p>, <CursorLeft>
            GotoWindow(DocumentWindow)
            RepeatFind(_BACKWARD_)
            GotoWindow(WordListWindow)
        when <c>
            mChangeWord()
            if mNeedToRemoveWord()
                if mRemoveThisWord()
                    break
                endif
                mLocateWord()
            endif
        when <d>, <Del>
            if mRemoveThisWord()
                break
            endif
            mLocateWord()
        when <1>, <f>
            mLocateWord()
        when <Enter>, <tab>
            GotoWindow(DocumentWindow)
            Enable(SpellKeys)
            PushBlock()
            Process()
            PopBlock()
            Disable(SpellKeys)
            GotoWindow(WordListWindow)
            mLocateWord()
        when <Escape>
            break
        endcase
    endloop
    GotoWindow(DocumentWindow)
    OneWindow()
end

proc mLocateWord()
    string word[80] = ""

    mGetCurrWord(word)
    GotoWindow(DocumentWindow)
    Find(word, "gw" + FindScope)
    GotoWindow(WordListWindow)
end

proc mChangeWord()
    string curr_word[80] = ""
    string new_word[80] = ""
    string suggest[80] = ""
    integer hist, n

    mGetCurrWord(curr_word)
    hist = GetFreeHistory()
    if hist
        n = SuggestWord(curr_word)
        while n > 0
            GetSuggestion(suggest, n)
            AddHistoryStr(suggest, hist)
            n = n - 1
        endwhile
    endif
    new_word = curr_word
    if Ask('Change "' + curr_word + '" (press <CursorUp> for suggestions)', new_word, hist)
    and new_word <> curr_word
        GotoWindow(DocumentWindow)
        lReplace(curr_word, new_word, "gwn" + FindScope)
        GotoWindow(WordListWindow)
        lReplace(curr_word, new_word, "gwn")
    endif
    DelHistory(hist)
    UpdateDisplay(_ALL_WINDOWS_REFRESH_)
end

integer proc mNeedToRemoveWord()
    string word[80] = ""

    if not mGetCurrWord(word)
    or word <> GetText(1, CurrLineLen())
    or Length(word) < 2
    or SpellCheckWord(word)
        return(1)
    endif
    return(0)
end

integer proc mRemoveThisWord()
    KillLine()
    if NumLines() < 1
        return(1)
    endif
    if CurrLine() > NumLines()
        Up()
    endif
    UpdateDisplay(_WINDOW_REFRESH_)
    return(0)
end

integer proc mGetCurrWord(var string word)
    if not lFind(WordPattern, "wxc")
        return(0)
    endif

    PushBlock()
    MarkFoundText()
    word = GetMarkedText()
    PopBlock()

    return(1)
end

// Progress display during spell check

integer SPstartLine, SPlineCount, SPlastLine

proc mInitProgress()
    if isBlockInCurrFile()
        SPstartLine = Query(BlockBegLine)
        SPlineCount = Query(BlockEndLine) - SPstartLine + 1
        SPlastLine = 0
    else
        SPstartLine = 1
        SPlineCount = NumLines()
        SPlastLine = 0
    endif
end

proc mDisplayProgress()
    if CurrLine() > SPlastLine
        Message("Checking spelling: ",
            (100*(CurrLine()-SPstartLine))/SPlineCount, "% complete")
        SPlastLine = CurrLine()
    endif
end

