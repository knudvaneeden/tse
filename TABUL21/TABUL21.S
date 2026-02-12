/****   TABUL21  Version 2.1    Shows, Sets, and Resets Variable Tabs
        28.09.1995              Deutsche Beschreibung siehe unten!


Macro written  31.8.1993 by: Paul Lenz                proppi@sampo.han.de
                             Friesenstrasse 22
                             D-30161 Hannover
                             Germany


Look at these switches:
=======================
        GERMAN     // Select your language!
       ENGLISH     // Select your language!
   CURSORCOLOR     // color of cursor position
     BOTTOMTOP     // TRUE  = tabulator line above the window
                      FALSE = tabulator line under the window


TABUL21.S contains:  SetTabulator()    sets variable tabs
                     ClrTabulator()    clears variable tabs
                     ShowTabs()        displays tabstops and margins
                     ToggleTabLine()   switches ShowTabs() on or off

SetTabulator() and ClrTabulator() set rsp. reset the TabStops in the way
WordStar did. This means that the ESC key sets rsp. resets the TabStop on
the cursor position; the ESC key does not leave the routine idly, but
RETURN does so!
If you want to enjoy the true WordStar feeling, insert these keys:
<Ctrl o> <i>    SetTabulator()
<Ctrl o> <n>    ClrTabulator()


If you set BOTTOMTOP = TRUE:
============================
ShowTabs() displays the tabstops and the left and the right margin on the
line ABOVE the current window.
This can be the main menu line. Anyway: if you hit ESC, the tabulator
line disappears and the menu line is visible.
If your TSE is configured without a visible main menu line, the tabulator
line covers the status line or the help line, if one of them is above
the text window. If there is no line above the text window, the tabulator
line is invisible.

If you set BOTTOMTOP = FALSE:
=============================
ShowTabs() displays the tabstops and the left and the right margin on the
line BELOW the current window.
This means: If you have a window border with a mouse elevator, this
will be covered. If not, the help line or the status line will be covered,
if the status line is under the editor window. If there is no line under
the editor window, the tab line is invisible.

If the tab line covers the mouse elevator, nevertheless you can use it:
Place the mouse cursor somewhere on the tab line and press the left mouse
key down for 1 or 2 seconds. This will move the mouse elevator
under the mouse cursor. Now release the left mouse key and press
it down again. Now you see that you "catched" the mouse elevator,
and you can move it to shift the text.


The current cursor position gets the CURSORCOLOR color. So you can
see if the cursor is on the left or the right margin.


ToggleTabLine() switches the tab line on or off. It hooks ShowTabs() at
_AFTER_UPDATE_STATUSLINE_ rsp. releases it.



08/31/1993   First version.
v1.0         Special thanx to Kyle Watkins (SemWare)
             for the bit manipulating routines!

12/18/1994   enhancements for TSE 2.0:
v1.1         constantly visible Tabstop Line on the mouse elevator
             hooked at _AFTER_COMMAND_

09/06/1995   enhancements for TSE 2.5:
v2.0         Tabstop Line under or above the window
             colored cursor position
             one file for German and English users

09/28/1995   ShowTabs() now hooked at _AFTER_UPDATE_STATUSLINE_.
v2.1


############################################################################
############################################################################

Bitte diese Schalter beachten:
==============================
        GERMAN     // Sprache auswÑhlen!
       ENGLISH     // Sprache auswÑhlen!
   CURSORCOLOR     // Farbe der Cursorposition
     BOTTOMTOP     // TRUE  = Tabulatorzeile oberhalb des Fensters
                      FALSE = Tabulatorzeile unterhalb des Fensters


TABUL21.S enthÑlt:   SetTabulator()    setzt variable Tabulatoren
                     ClrTabulator()    lîscht variable Tabulatoren
                     ShowTabs()        zeigt Tabulatoren und RÑnder
                     ToggleTabLine()   schaltet ShowTabs() an und aus

SetTabulator() and ClrTabulator() setzt bzw. lîscht Tabulatoren auf die
Weise, wie es in WordStar Åblich war. Das bedeutet, da· die ESC-Taste
den Tabulator an der aktuellen Cursorposition setzt bzw. lîscht; will
man also diese Routinen ohne énderungen verlassen, darf man nicht ESC
drÅcken, sondern RETURN!
Falls man das echte WordStar-Feeling genie·en will, fÅgt man die
folgenden Tastaturzuweisungen an:
<Ctrl o> <i>    SetTabulator()
<Ctrl o> <n>    ClrTabulator()

Falls BOTTOMTOP = TRUE gesetzt ist:
===================================
ShowTabs() zeigt die variablen Tabulatoren sowie den linken und den
rechten Rand auf der Zeile OBERHALB des aktuellen Fensters.
Dies kann das HauptmenÅ sein. Trotzdem: wenn man ESC drÅckt, verschwindet
die Tabulatorzeile, und das HauptmenÅ wird sichtbar.
Wenn der TSE ohne sichtbares HauptmenÅ konfiguriert wurde, bedeckt die
Tabulatorzeile die Statuszeile oder die Hilfezeile, falls eine von ihnen
Åber dem Textfenster ist. Falls keine Zeile Åber dem Textfenster ist,
ist die Tabulatorzeile unsichtbar.

Falls BOTTOMTOP = FALSE gesetzt ist:
====================================
ShowTabs() zeigt die variablen Tabulatoren sowie den linken und den
rechten Rand auf der Zeile UNTERHALB des aktuellen Fensters.
Das bedeutet: Wenn man einen Fensterrahmen mit Rollbalken hat, so
wird dieser bedeckt. Wenn man keinen hat, wird die Hilfezeile oder
die Statuszeile unter dem Fenster bedeckt. Ist Åberhaupt keine Zeile
unterhalb des Fensters, ist die Tabulatorzeile leider unsichtbar.

Wenn die Tabulatorzeile den Mausrollbalken bedeckt, kann man diesen
trotzdem benutzen: Man plaziert den Mauscursor irgendwo auf den
Rollbalken und hÑlt die linke Maustaste 1 bis 2 Sekunden lang
gedrÅckt. Dadurch wird der horizontale Aufzug unter den Mauscursor
bewegt. Jetzt lÑ·t man die Maustaste los und drÅckt sie sofort
wieder. Dadurch hat man den Aufzug gefangen und kann ihn nun bewegen,
um den Text zu verschieben.


Die aktuelle Cursorposition bekommt die Farbe CURSORCOLOR. So kann
man sehen, ob der Cursor an der linken oder rechten Begrenzung steht.


ToggleTabLine() schaltet die Tabulatorzeile ein oder aus. Dieses Macro
hÑngt ShowTabs() an das Ereignis _AFTER_UPDATE_STATUSLINE_ bzw. lîst es
wieder.



31.8.1993    erste Version fÅr TSE Pre-Release
v1.0         mit Hilfe von Bit-Manipulations-
             Routinen von Kyle Watkins (SemWare)

18.12.1994   Erweiterungen fÅr TSE 2.0:
v1.1         stÑndig sichtbare Tabulatorzeile
             durch Verbindung mit _AFTER_COMMAND_

06.09.1995   Erweiterungen fÅr TSE 2.5:
v2.0         Tabulatorzeile unter oder Åber dem Fenster
             farbige Cursorposition
             eine Datei fÅr deutsche und englische Benutzer

28.09.1995   ShowTabs() jetzt mit _AFTER_UPDATE_STATUSLINE_ verbunden.
v2.1

****************************************************************************
***************************************************************************/

// constants:

#ifndef GERMAN
    constant        GERMAN = TRUE     // Sprache auswÑhlen!
#endif
#ifndef ENGLISH
    constant       ENGLISH = FALSE    // Select your language!
#endif

    constant   CURSORCOLOR = 30       // color of cursor position
    constant     BOTTOMTOP = TRUE     // TRUE  = above the window
                                      // FALSE = under the window

/**************************************************************************/


// Bit manipulation routines:

integer t_unit, t_bit
string vtab[32], s_unit[1]


string proc GetValue(integer colu)
    t_unit=(colu/8)+1             //Get vartab string element
    t_bit=(colu mod 8)            //Get bit of vartab string element
    vtab=query(vartabs)
    return(vtab[t_unit])
end


proc SetTab(integer colu)
    s_unit = GetValue(colu)
    s_unit = chr(asc(s_unit)|(1 shl t_bit))
    vtab=substr(vtab,1,t_unit-1)+s_unit+substr(vtab,t_unit+1,32)
    set(vartabs,vtab)
end


proc ClrTab(integer colu)
    s_unit = GetValue(colu)
    s_unit = chr(asc(s_unit)&(~(1 shl t_bit)))
    vtab=substr(vtab,1,t_unit-1)+s_unit+substr(vtab,t_unit+1,32)
    set(vartabs,vtab)
end

/***************************************************************************
***************************************************************************/

proc ShowTabs()
    string show[80] = "∞"
    integer z

    if Query(LeftMargin) == 0
        Set(LeftMargin,1)               // we can't show position "0"
    endif
    z = CurrXoffset() + 1               // count from left window border
    repeat                              // build tabulator line:
        s_unit = GetValue(z)
        if z == Query(LeftMargin)               // left margin
            show = show + "L"
        elseif z == Query(RightMargin)          // right margin
            show = show + "R"
        elseif (asc(s_unit)&(1 shl t_bit))      // Tabulator position:
            if z == CurrCol()
                show = show + "Œ"                   // Tabulator + Cursor
            else
                show = show + "∫"                   // Tabulator
            endif
        else                                    // no Tabulator position:
            if z == CurrCol()
                show = show + "Õ"                   // Cursor position
            else
                show = show + "∞"                   // no tab, no cursor
            endif
        endif
        z = z + 1
    until z == CurrXoffset() + Query(WindowCols) + 1 OR z > 255
    // fill the rest:
    show = show + "∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞"

    // to remove the TabLine from a non-current window:
    UpdateDisplay(_ALL_WINDOWS_REFRESH_)

    #if BOTTOMTOP
            // display tabulator line above the window:
        VGotoXY(Query(Windowx1) - 1, Query(Windowy1) - 2)
        PutLine(Show,Query(WindowCols) + 2)
            // change color to window border color:
        VGotoXY(Query(Windowx1) - 1, Query(Windowy1) - 2)
        PutAttr(Query(CurrWinBorderAttr), Query(WindowCols) + 2)
            // change color of cursor position:
        VGotoXY(Query(Windowx1) + CurrCol() - CurrXoffset() - 1, Query(Windowy1) - 2)
        PutAttr(CURSORCOLOR, 1)
    #else
            // display tabulator line under the window:
        VGotoXY(Query(Windowx1) - 1, Query(Windowy1) + Query(WindowRows))
        PutLine(Show,Query(WindowCols) + 2)
            // change color to window border color:
        VGotoXY(Query(Windowx1) - 1, Query(Windowy1) + Query(WindowRows))
        PutAttr(Query(CurrWinBorderAttr), Query(WindowCols) + 2)
            // change color of cursor position:
        VGotoXY(Query(Windowx1) + CurrCol() - CurrXoffset() - 1, Query(Windowy1) + Query(WindowRows))
        PutAttr(CURSORCOLOR, 1)
    #endif

end

/**************************************************************************/

proc SetTabulator()
    string tb[3] = ""
    string msg[50] = ""

    #if GERMAN
        msg = "Setze Tabulator auf Spalte (ESC fÅr Cursorspalte)?"
    #endif
    #if ENGLISH
        msg = "Set tab at column (ESC for cursor column)?"
    #endif

    Set(TabType,_VARIABLE_)
    if Ask(msg,tb)
        if val(tb) > 0
            SetTab(val(tb))
        endif
    else
        SetTab(CurrCol())
    endif
end

/**************************************************************************/

proc ClrTabulator()
    string tb[3] = ""
    string msg[65] = ""

    #if GERMAN
        msg = "Lîsche Tabulator von Spalte (ESC fÅr Cursorspalte; A fÅr alle)?"
    #endif
    #if ENGLISH
        msg = "Clear tab at col (ESC for cursor col; A for all)?"
    #endif

    Set(TabType,_VARIABLE_)
    if Ask(msg,tb)
        if tb=="a" OR tb=="A"
            set(VarTabs,TabSet(""))
        endif
        if val(tb) > 0
            ClrTab(val(tb))
        endif
    else
        ClrTab(CurrCol())
    endif
end

/**************************************************************************/

integer TabLine = 0                    // global variable (TabLine status)

proc ToggleTabLine()
    TabLine = NOT TabLine
    if TabLine
        Set(TabType,_VARIABLE_)
        Hook(_AFTER_UPDATE_STATUSLINE_, ShowTabs)
    else
        UnHook(ShowTabs)
        UpdateDisplay(_ALL_WINDOWS_REFRESH_)
    endif
end


// <alt w>   ToggleTabLine()           // key to switch TabLine on/off
