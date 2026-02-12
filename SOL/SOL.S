// Solitaire for TSE
//
// Written by David Goodenough.
// Released to the public domain, 5/22/93

/***************************************************************

You can play from the deck to either the foundation or an ace:

'da' plays deck to ace
'dn' plays from deck to foundation pile n (e.g. d3)

An entire foundation pile can be moved to another:

'25' moves foundation pile 2 to pile 5

Foundation cards can be played to aces:

'6a' takes the bottom card from foundation pile 6, and places it
on the appropriate ace.

Entering no command at all thumbs the next three cards to the
deck, and 'q' quits.

***************************************************************/

string deck[52]
string outtakes[52]     // this could probably be smaller
string clubs[1]
string diamonds[1]
string hearts[1]
string spades[1]
string hidden1[1]
string hidden2[2]
string hidden3[3]
string hidden4[4]
string hidden5[5]
string hidden6[6]
string hidden7[7]
string showing1[14]
string showing2[14]
string showing3[14]
string showing4[14]
string showing5[14]
string showing6[14]
string showing7[14]

integer quit
integer seed
integer cardcol
integer value
integer suit
integer fromto
integer source
integer dest

proc setrand()
    integer h
    integer m
    integer s
    integer hu

    gettime(h, m, s, hu)
    seed = ((h * 60 + m) * 60 + s) * 100 + hu
end

integer proc rand()
    seed = ((seed * 12345) + 7113) & 65535
    return(seed mod 52)
end

proc clearwin(integer rows, integer cols, integer attr)
    integer i

    i = 1
    repeat
        gotoXY(1, i)
        putattr(attr, cols)
        i = i + 1
    until i > rows
end

string proc card2str(string card)
    integer a
    string res[4]

    res = card
    a = asc(card) - 65
    if a > 26
        a = a - 6
    endif

    suit = a / 13
    value = a mod 13
    if value >= 1 and value <= 8
        res = str(value + 1)
    else
        case value
            when 0
                res = "A"
            when 9
                res = "T"
            when 10
                res = "J"
            when 11
                res = "Q"
            when 12
                res = "K"
        endcase
    endif

    case suit
        when 0
            res = res + ""
            cardcol = 112
        when 1
            res = res + ""
            cardcol = 116
        when 2
            res = res + ""
            cardcol = 116
        when 3
            res = res + ""
            cardcol = 112
    endcase

    return(res)
end

string proc getdeck(integer howmany)
    integer len
    string res[8]

    len = length(deck)
    if (len < howmany)
        howmany = len
    endif
    res = substr(deck, len - howmany + 1, howmany)
    deck = substr(deck, 1, len - howmany)
    return(res)
end

string proc reverse(string cards)
    integer i
    string hold[52]

    hold = ""
    i = 1
    while (i <= length(cards))
        hold = substr(cards, i, 1) + hold
        i = i + 1
    endwhile
    return(hold)
end

proc shuffle()
    integer i
    integer j
    integer k
    string hold[52]

    i = 0
    repeat
        repeat
            j = rand()
        until i <> j
        if i < j
            k = i
        else
            k = j
            j = i
        endif
        hold = substr(deck, 1, k)
        hold = hold + substr(deck, j + 1, 1)
        hold = hold + substr(deck, k + 2, j - k - 1)
        hold = hold + substr(deck, k + 1, 1)
        hold = hold + substr(deck, j + 2, 52)
        deck = hold
        i = i + 1
    until i == 52
end

proc deal()
    outtakes = ""
    clubs = ""
    diamonds = ""
    hearts = ""
    spades = ""
    hidden1 = ""
    hidden2 = getdeck(1)
    hidden3 = getdeck(2)
    hidden4 = getdeck(3)
    hidden5 = getdeck(4)
    hidden6 = getdeck(5)
    hidden7 = getdeck(6)
    showing1 = getdeck(1)
    showing2 = getdeck(1)
    showing3 = getdeck(1)
    showing4 = getdeck(1)
    showing5 = getdeck(1)
    showing6 = getdeck(1)
    showing7 = getdeck(1)
end

proc dispout(integer where, integer which)
    string card[2]
    string dispcard[4]

    gotoXY(where, 4)
    if (which + 1 > length(outtakes))
        putstr("--")
        gotoXY(where, 4)
        putattr(126, 2)
    else
        card = substr(outtakes, length(outtakes) - which, 1)
        dispcard = card2str(card)
        putstr(dispcard)
        gotoXY(where, 4)
        putattr(cardcol, 2)
    endif
end

proc dispace(integer where, string which)
    string dispcard[4]

    gotoXY(where, 1)
    if (which == "")
        putstr("--")
        gotoXY(where, 1)
        putattr(126, 2)
    else
        dispcard = card2str(which)
        putstr(dispcard)
        gotoXY(where, 1)
        putattr(cardcol, 2)
    endif
end

proc disphid(integer where, string which)
    string dispnum[4]

    gotoXY(where, 4)
    if (which == "")
        putstr("--")
    else
        dispnum = " " + str(length(which))
        putstr(dispnum)
    endif
    gotoXY(where, 4)
    putattr(126, 2)
end

proc dispshow(integer where, string which, integer showall)
    integer i
    string card[2]
    string dispcard[4]

    i = 1
    while (i <= length(which))
        gotoXY(where, 4 + i)
        card = substr(which, i, 1)
        dispcard = card2str(card)
        putstr(dispcard)
        gotoXY(where, 4 + i)
        putattr(cardcol, 2)
        i = i + 1
    endwhile
    if showall
        while (i <= 13)
            gotoXY(where, 4 + i)
            putstr("  ")
            gotoXY(where, 4 + i)
            putattr(127, 2)
            i = i + 1
        endwhile
    endif
end

proc display()
    string card[2]
    string dispcard[4]

    gotoXY(17, 3)
    putstr("Deck          1    2    3    4    5    6    7")
    gotoXY(17, 3)
    putattr(127, 45)

    gotoXY(9, 4)
    if deck == ""
        putstr("--")
    else
       putstr("##")
    endif
    gotoXY(9, 4)
    putattr(126, 2)

    dispout(15, 2)
    dispout(18, 1)
    dispout(21, 0)

    dispace(45, clubs)
    dispace(50, diamonds)
    dispace(55, hearts)
    dispace(60, spades)

    disphid(30, hidden1)
    disphid(35, hidden2)
    disphid(40, hidden3)
    disphid(45, hidden4)
    disphid(50, hidden5)
    disphid(55, hidden6)
    disphid(60, hidden7)

    dispshow(30, showing1, 0)
    dispshow(35, showing2, 0)
    dispshow(40, showing3, 0)
    dispshow(45, showing4, 0)
    dispshow(50, showing5, 0)
    dispshow(55, showing6, 0)
    dispshow(60, showing7, 0)
end

integer proc str2where(string place)
    integer test
    integer res

    source = val(place)
    if source >= 1 and source <= 7
        res = 1
    else
        source = 0
        res = 0
        test = asc(place) | 32
        case test
            when 100
                res = 2
            when 97
                res = 3
            when 113
                res = 4
        endcase
    endif
    return(res)
end

proc getcommand()
    string invar[2]
    string work[2]

    gotoXY(6, 10)
    putstr("Command:")
    gotoXY(6, 10)
    putattr(127, 12)
    gotoXY(16, 10)
    invar = ""
    read(invar)
    gotoXY(4, 12)
    putstr("               ")
    gotoXY(4, 12)
    putattr(127, 15)

    if invar == ""
        fromto = 100
    else
        work = substr(invar, 2, 1)
        invar = substr(invar, 1, 1)
        fromto = str2where(work)
        dest = source
        fromto = fromto + 10 * str2where(invar)
    endif
end

proc assign2show(integer which, string newshow)
    integer column

    case which
        when 1
            showing1 = newshow
            column = 30
        when 2
            showing2 = newshow
            column = 35
        when 3
            showing3 = newshow
            column = 40
        when 4
            showing4 = newshow
            column = 45
        when 5
            showing5 = newshow
            column = 50
        when 6
            showing6 = newshow
            column = 55
        when 7
            showing7 = newshow
            column = 60
    endcase
    dispshow(column, newshow, 1)
end

string proc getshow(integer which)
    string res[14]

    case which
        when 1
            res = showing1
        when 2
            res = showing2
        when 3
            res = showing3
        when 4
            res = showing4
        when 5
            res = showing5
        when 6
            res = showing6
        when 7
            res = showing7
        otherwise
            res = ""
    endcase
    return(res)
end

string proc gethidden(integer which)
    string res[2]

    case which
        when 1
            res = substr(hidden1, 1, 1)
            hidden1 = substr(hidden1, 2, 7)
        when 2
            res = substr(hidden2, 1, 1)
            hidden2 = substr(hidden2, 2, 7)
        when 3
            res = substr(hidden3, 1, 1)
            hidden3 = substr(hidden3, 2, 7)
        when 4
            res = substr(hidden4, 1, 1)
            hidden4 = substr(hidden4, 2, 7)
        when 5
            res = substr(hidden5, 1, 1)
            hidden5 = substr(hidden5, 2, 7)
        when 6
            res = substr(hidden6, 1, 1)
            hidden6 = substr(hidden6, 2, 7)
        when 7
            res = substr(hidden7, 1, 1)
            hidden7 = substr(hidden7, 2, 7)
        otherwise
            res = ""
    endcase
    return(res)
end

string proc getace(integer suit)
    string res[2]

    res = ""
    case suit
        when 0
            res = clubs
        when 1
            res = diamonds
        when 2
            res = hearts
        when 3
            res = spades
    endcase
    return(res)
end

proc assign2ace(integer suit, string src)
    case suit
        when 0
            clubs = substr(src, 1, 1)
        when 1
            diamonds = substr(src, 1, 1)
        when 2
            hearts = substr(src, 1, 1)
        when 3
            spades = substr(src, 1, 1)
    endcase
end

proc hiddenup(integer which)
    string hold[2]

    hold = gethidden(which)
    assign2show(which, hold)
end

integer proc show2show()
    string src[14]
    string targ[14]
    string dummy[4]
    integer srccol
    integer srcvalue

    if source == dest
        return(1)
    endif
    src = getshow(source)
    targ = getshow(dest)
    src = substr(src, 1, 1)
    targ = substr(targ, length(targ), 1)
    if src == ""
        return(1)
    endif
    dummy = card2str(src)
    if targ == ""
        if value <> 12
            return(1)
        endif
    else
        srcvalue = value
        srccol = cardcol
        dummy = card2str(targ)
        if srcvalue <> value - 1 or srccol == cardcol
            return(1)
        endif
    endif
    targ = getshow(dest) + getshow(source)
    assign2show(dest, targ)
    assign2show(source, "")
    hiddenup(source)
    return(0)
end

integer proc show2ace()
    string src[14]
    string targ[2]
    string dummy[4]
    integer srcvalue

    src = getshow(source)
    src = substr(src, length(src), 1)
    if (src == "")
        return(1)
    endif
    dummy = card2str(src)
    targ = getace(suit)
    if targ == ""
        if value <> 0
            return(1)
        endif
    else
        srcvalue = value
        dummy = card2str(targ)
        if srcvalue <> value + 1
            return(1)
        endif
    endif
    assign2ace(suit, src)
    src = getshow(source)
    src = substr(src, 1, length(src) - 1)
    assign2show(source, src)
    if (src == "")
        hiddenup(source)
    endif
    return(0)
end

integer proc deck2show()
    string src[4]
    string targ[14]
    string dummy[4]
    integer srccol
    integer srcvalue

    src = substr(outtakes, length(outtakes), 1)
    if (src == "")
        return(1)
    endif
    targ = getshow(dest)
    targ = substr(targ, length(targ), 1)
    dummy = card2str(src)
    if targ == ""
        if value <> 12
            return(1)
        endif
    else
        srcvalue = value
        srccol = cardcol
        dummy = card2str(targ)
        if srcvalue <> value - 1 or srccol == cardcol
            return(1)
        endif
    endif
    targ = getshow(dest) + src
    assign2show(dest, targ)
    outtakes = substr(outtakes, 1, length(outtakes) - 1)
    return(0)
end

integer proc deck2ace()
    string src[4]
    string targ[2]
    string dummy[4]
    integer srcvalue

    src = substr(outtakes, length(outtakes), 1)
    if (src == "")
        return(1)
    endif
    dummy = card2str(src)
    targ = getace(suit)
    if targ == ""
        if value <> 0
            return(1)
        endif
    else
        srcvalue = value
        dummy = card2str(targ)
        if srcvalue <> value + 1
            return(1)
        endif
    endif
    assign2ace(suit, src)
    outtakes = substr(outtakes, 1, length(outtakes) - 1)
    return(0)
end

// I'd like to figure this out but can't think how to specify which ace to use
// when two can play: 3S up, 2D and 2H on the aces, how do I tell which of
// these to play down. Maybe in the next version .....

integer proc ace2show()
    return(1)
end

integer proc thumb()
    string cards[4]

    cards = getdeck(3)
    if cards == ""
        deck = reverse(outtakes)
        outtakes = ""
    else
        outtakes = outtakes + reverse(cards)
    endif
    return(0)
end

proc processcommand()
    integer waserror
    string result[11]

    waserror = 1
    case fromto
        when 11
            waserror = show2show()
        when 13
            waserror = show2ace()
        when 21
            waserror = deck2show()
        when 23
            waserror = deck2ace()
        when 31
            waserror = ace2show()
        when 100
            waserror = thumb()
    endcase
    if fromto / 10 == 4
        waserror = 0
        quit = 1
    endif
    if waserror
        gotoxy(4, 12)
        putstr("Invalid Command")
        gotoxy(4, 12)
        putattr(127, 15)
    endif
end

integer proc finished()
    integer res

    res = 1
    if clubs <> "M"
        res = 0
    endif
    if diamonds <> "Z"
        res = 0
    endif
    if hearts <> "m"
        res = 0
    endif
    if spades <> "z"
        res = 0
    endif
    return(res)
end

proc congrats()
    integer dummy

    PopWinOpen(20, 10, 60, 16, 4, '', 79)
    ClrScr()
    clearwin(5, 39, 79)
    gotoxy(6, 2)
    putstr("CONGRATULATIONS -- YOU WON!")
    gotoxy(6, 2)
    putattr(79, 27)
    gotoxy(6, 4)
    putstr("Press any key to continue...")
    gotoxy(6, 4)
    putattr(79, 28)
    dummy = GetKey()
    PopWinClose()
end

proc mSolitaire()
    setrand()
    PopWinOpen(3, 3, 77, 21, 4, 'Solitaire', 127)
    ClrScr()
    clearwin(17, 73, 127)
    deck = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    quit = 0
    shuffle()
    shuffle()
    deal()
    repeat
        display()
        getcommand()
        processcommand()
    until finished() or quit
    if finished()
        congrats()
    endif
    PopWinClose()
end

<ctrl F1>       mSolitaire()
