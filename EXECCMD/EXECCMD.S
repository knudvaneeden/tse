// some of these commands may not compile becuase they are only
// in the beta version.  If so, just comment them out.
//
// if this is improved on greatly, please feel free to post the changes!
//
// Peter Birch  12/07/93

proc doCommand (string pcCommand, string pcParam1, string pcParam2)
    string  cCommand[ 80]

    cCommand = upper(pcCommand)

    case (cCommand)     // all internal commands
        when "ABANDONEDITOR"
            ABANDONEDITOR()
        when "ABANDONFILE"
            ABANDONFILE()
        when "ABS"
            warn(ABS(val(pcParam1)))
        when "ADDHISTORYSTR"
            ADDHISTORYSTR(pcParam1, val(pcParam2))
        when "ADDLINE"
            ADDLINE()
        when "ALARM"
            alarm()
        when "ASC"
            warn(ASC(pcParam1))

//         when "ASK"
//             ASK(pcParam1)
//         when "ATTR"
//             ATTR(val(pcParam1))
//         when "ATTRSET"
//             ATTRSET()
//         when "AUTOINDENT"
//             AUTOINDENT()

        when "BACKSPACE"
            BACKSPACE()

//         when "BACKUPEXT"
//             BACKUPEXT(pcParam1)

        when "BEEP"
            warn(query(BEEP))
        when "BEGFILE"
            BEGFILE()
        when "BEGLINE"
            BEGLINE()
        when "BEGWINDOW"
            BEGWINDOW()
        when "BEGWORD"
            BEGWORD()

        when "BLOCKATTR"
            warn(query(BLOCKATTR))
        when "BLOCKBEGCOL"
            warn(query(BLOCKBEGCOL))
        when "BLOCKBEGLINE"
            warn(query(BLOCKBEGLINE))
        when "BLOCKENDCOL"
            warn(query(BLOCKENDCOL))
        when "BLOCKENDLINE"
            warn(query(BLOCKENDLINE))
        when "BLOCKID"
            warn(query(BLOCKID))

//         when "BREAK"
//             BREAK()

        when "BUFFERTYPE"
            warn(query(BUFFERTYPE))

        when "CENTERFINDS"
            warn(query(CENTERFINDS))
        when "CHANGECURRFILENAME"
            CHANGECURRFILENAME()
        when "CHANGESHELLPROMPT"
            warn(query(CHANGESHELLPROMPT))
        when "CHR"
            warn(CHR(val(pcParam1)))

//         when "CHRSET"
//             warn(CHRSET(pcParam1))

        when "CLOSEPRINT"
            CLOSEPRINT()
        when "CLOSEWINDOW"
            CLOSEWINDOW()
        when "CLREOL"
            CLREOL()
        when "CLRSCR"
            CLRSCR()

//         when "COLOR"
//             COLOR(pcParam1)
//         when "COMPRESSVIEW"
//             COMPRESSVIEW()

        when "COPY"
            COPY()
        when "COPYBLOCK"
            COPYBLOCK()

//         when "COUNT"
//             COUNT(pcParam1)

        when "CREATEBUFFER"
            CREATEBUFFER(pcParam1)
        when "CREATETEMPBUFFER"
            CREATETEMPBUFFER()
        when "CRETURN"
            CRETURN()
        when "CURRCHAR"
            CURRCHAR()
        when "CURRCOL"
            CURRCOL()
        when "CURRFILENAME"
            warn(CURRFILENAME())
        when "CURRLINE"
            warn(CURRLINE())
        when "CURRLINELEN"
            warn(CURRLINELEN())
        when "CURRMACROFILENAME"
            warn(CURRMACROFILENAME())
        when "CURRPOS"
            warn(CURRPOS())
        when "CURRROW"
            warn(CURRROW())
        when "CURRVIDEOMODE"
            warn(query(CURRVIDEOMODE))
        when "CURRWINBORDERATTR"
            warn(query(CURRWINBORDERATTR))
        when "CURRWINBORDERTYPE"
            warn(query(CURRWINBORDERTYPE))
        when "CURRXOFFSET"
            warn(CURRXOFFSET())
        when "CURSOR"
            warn(query(CURSOR))
        when "CURSORATTR"
            warn(query(CURSORATTR))

//         when "CURSORING"
//             CURSORING()

        when "CUT"
            CUT()
        when "DATEFORMAT"
            warn(query(DATEFORMAT))
        when "DATESEPARATOR"
            warn(query(DATESEPARATOR))

//         when "DEFAULTEXT"    // needs to be a constant
//             warn(query(DEFAULTEXT))

        when "DELAY"
            DELAY(val(pcParam1))
        when "DELBLOCK"
            DELBLOCK()
        when "DELCHAR"
            DELCHAR()
        when "DELHISTORY"
            DELHISTORY(val(pcParam1))
        when "DELLEFTWORD"
            DELLEFTWORD()
        when "DELLINE"
            DELLINE()
        when "DELRIGHTWORD"
            DELRIGHTWORD()
        when "DELTOEOL"
            DELTOEOL()
        when "DELWINDOW"
            DELWINDOW()

//         when "DEVICE"
//             warn(query(DEVICE))
//         when "DISABLE"       // needs a keydef
//             DISABLE(pcParam1)

        when "DISPLAYBOXED"
            warn(query(DISPLAYBOXED))
        when "DISTANCETOTAB"
            warn(DISTANCETOTAB())
        when "DOS"
            DOS()
        when "DOWN"
            DOWN()
        when "DRAWBOX"
            DRAWBOX(val(pcParam1), val(pcParam2))
        when "DUPLINE"
            DUPLINE()
        when "EDITFILE"
            EDITFILE()
        when "ELIMINATESNOW"
            warn(query(ELIMINATESNOW))
        when "EMPTYBUFFER"
            EMPTYBUFFER()

//         when "ENABLE"    // needs a keydef
//             ENABLE()

        when "ENDFILE"
            ENDFILE()
        when "ENDLINE"
            ENDLINE()
        when "ENDPROCESS"
            ENDPROCESS()
        when "ENDWINDOW"
            ENDWINDOW()
        when "ENDWORD"
            ENDWORD()
        when "EOFMARKERATTR"
            warn(query(EOFMARKERATTR))
        when "EOFTYPE"
            warn(query(EOFTYPE))
        when "EOLTYPE"
            warn(query(EOLTYPE))
        when "EQUATEENHANCEDKBD"
            warn(query(EQUATEENHANCEDKBD))
        when "ERASEDISKFILE"
            ERASEDISKFILE(pcParam1)
        when "ESCAPE"
            ESCAPE()
        when "EXECHOOK"
            EXECHOOK(val(pcParam1))
        when "EXECMACRO"
            EXECMACRO()
        when "EXECSCRAPMACRO"
            EXECSCRAPMACRO()
        when "EXIT"
            EXIT()
        when "EXPANDPATH"
            warn(EXPANDPATH(pcParam1))
        when "EXPANDTABS"
            warn(query(EXPANDTABS))
        when "FILEEXISTS"
            warn(FILEEXISTS(pcParam1))
        when "FILLBLOCK"
            FILLBLOCK()
        when "FIND"
            FIND()
        when "FINDOPTIONS"
            warn(query(FINDOPTIONS))

//         when "FINDWORDATCURSOR"
//             FINDWORDATCURSOR()

        when "FLIP"
            FLIP()

//         when "FOOTER"
//             warn(FOOTER)

        when "FORCECHANGED"
            FORCECHANGED(val(pcParam1))
        when "FORMAT"
            FORMAT(pcParam1)
        when "FULLWINDOW"
            FULLWINDOW()

//         when "FUNCTIONLIST"
//             FUNCTIONLIST()

        when "GETBUFFERID"
            warn(GETBUFFERID())
        when "GETCLIPBOARDID"
            warn(GETCLIPBOARDID())

//         when "GETDATE"   // too many parameters
//             GETDATE()

        when "GETDATESTR"
            warn(GETDATESTR())
        when "GETDRIVE"
            warn(GETDRIVE())
        when "GETENVSTR"
            warn(GETENVSTR(pcParam1))
        when "GETFREEHISTORY"
            warn(GETFREEHISTORY())
        when "GETGLOBALINT"
            warn(GETGLOBALINT(pcParam1))
        when "GETGLOBALSTR"
            warn(GETGLOBALSTR(pcParam1))
        when "GETKEY"
            warn(GETKEY())
        when "GETMARKEDTEXT"
            warn(GETMARKEDTEXT())
        when "GETTEXT"
            warn(GETTEXT(val(pcParam1), val(pcParam2)))

//         when "GETTIME"   // too many parameters
//             GETTIME()

        when "GETTIMESTR"
            warn(GETTIMESTR())
        when "GLOBALUNDELETE"
            GLOBALUNDELETE()
        when "GOTOBLOCKBEGIN"
            GOTOBLOCKBEGIN()
        when "GOTOBLOCKEND"
            GOTOBLOCKEND()
        when "GOTOBUFFERID"
            GOTOBUFFERID(val(pcParam1))
        when "GOTOCOLUMN"
            GOTOCOLUMN()
        when "GOTOLINE"
            GOTOLINE()
        when "GOTOMARK"
            GOTOMARK()
        when "GOTOMOUSECURSOR"
            GOTOMOUSECURSOR()
        when "GOTOPOS"
            GOTOPOS(val(pcParam1))
        when "GOTOROW"
            GOTOROW(val(pcParam1))
        when "GOTOWINDOW"
            GOTOWINDOW(val(pcParam1))
        when "GOTOXOFFSET"
            GOTOXOFFSET(val(pcParam1))
        when "GOTOXY"
            GOTOXY(val(pcParam1), val(pcParam2))

//         when "HEADER"
//             HEADER()

        when "HELP"
            HELP(pcParam1)
        when "HIDEMOUSE"
            HIDEMOUSE()
        when "HILITEATTR"
            warn(query(HILITEATTR))
        when "HILITEFOUNDTEXT"
            HILITEFOUNDTEXT()

//         when "HOOK"  // won't work like this
//             HOOK(val(pcParam1), pcParam2)

        when "HWINDOW"
            HWINDOW()
        when "INSERT"
            warn(query(INSERT))
        when "INSERTCURSORSIZE"
            warn(query(INSERTCURSORSIZE))

//         when "INSERTDATA"    // needs a data name
//             INSERTDATA()

        when "INSERTFILE"
            INSERTFILE()
        when "INSERTLINE"
            INSERTLINE()

        when "INSERTLINEBLOCKSABOVE"
            warn(query(INSERTLINEBLOCKSABOVE))

        when "INSERTTEXT"
            INSERTTEXT(pcParam1)
        when "ISBLOCKINCURRFILE"
            warn(ISBLOCKINCURRFILE())
        when "ISBLOCKMARKED"
            warn(ISBLOCKMARKED())
        when "ISCHANGED"
            warn(ISCHANGED())
        when "ISCURSORINBLOCK"
            warn(ISCURSORINBLOCK())
        when "ISMACROLOADED"
            warn(ISMACROLOADED(pcParam1))
        when "ISWHITE"
            warn(ISWHITE())
        when "ISWORD"
            warn(ISWORD())
        when "ISZOOMED"
            warn(ISZOOMED())
        when "JOINLINE"
            JOINLINE()
        when "KBDPATH"
            warn(query(KBDPATH))
        when "KEY"
            warn(query(KEY))
        when "KEYPRESSED"
            warn(KEYPRESSED())
        when "KILLFILE"
            KILLFILE()
        when "KILLMAX"
            warn(query(KILLMAX))
        when "KILLPOSITION"
            KILLPOSITION()
        when "LEFT"
            LEFT()
        when "LEFTHANDEDMOUSE"
            warn(query(LEFTHANDEDMOUSE))
        when "LEFTMARGIN"
            warn(query(LEFTMARGIN))
        when "LENGTH"
            warn(LENGTH(pcParam1))
        when "LFIND"
            LFIND(pcParam1, pcParam2)
        when "LINEDRAW"
            LINEDRAW(val(pcParam1))
        when "LINEDRAWCHAR"
            warn(query(LINEDRAWCHAR))
        when "LINEDRAWING"
            warn(query(LINEDRAWING))
        when "LINEDRAWTYPE"
            warn(query(LINEDRAWTYPE))
        when "LINETYPEMENU"
            LINETYPEMENU()
        when "LIST"
            LIST(pcParam1, val(pcParam2))
        when "LITERAL"
            LITERAL()

//         when "LLIST"         // too many parameters
//             LLIST()

        when "LOADDIR"
            warn(LOADDIR())
        when "LOADKEYMACRO"
            LOADKEYMACRO()
        when "LOADMACRO"
            LOADMACRO()
        when "LOADWILDFROMDOS"
            warn(query(LOADWILDFROMDOS))
        when "LOADWILDFROMINSIDE"
            warn(query(LOADWILDFROMINSIDE))
        when "LOCASE"
            warn(LOCASE(pcParam1))
        when "LOGDRIVE"
            LOGDRIVE(pcParam1)
        when "LOWER"
            warn(LOWER(pcParam1))
        when "LREAD"
            warn(LREAD(pcParam1, val(pcParam2)))
        when "LREPEATFIND"
            LREPEATFIND()

//         when "LREPLACE"      // too many options
//             LREPLACE()

        when "MAKEBACKUPS"
            warn(query(MAKEBACKUPS))
        when "MARKCHAR"
            MARKCHAR()
        when "MARKCOLUMN"
            MARKCOLUMN()
        when "MARKING"
            warn(query(MARKING))
        when "MARKLINE"
            MARKLINE()
        when "MARKSTREAM"
            MARKSTREAM()
        when "MARKWORD"
            MARKWORD()

//         when "MATCH" // a macro, not a command
//             MATCH()

        when "MAXEMS"
            warn(query(MAXEMS))
        when "MAXHISTORYSIZE"
            warn(query(MAXHISTORYSIZE))
        when "MAXXMS"
            warn(query(MAXXMS))
        when "MENUBORDERATTR"
            warn(query(MENUBORDERATTR))
        when "MENUKEY"
            warn(MENUKEY())
        when "MENUOPTION"
            warn(MENUOPTION())
        when "MENUSELECTATTR"
            warn(query(MENUSELECTATTR))
        when "MENUSELECTLTRATTR"
            warn(query(MENUSELECTLTRATTR))

//         when "MENUSTR"   // needs a menu name
//             MENUSTR()

        when "MENUTEXTATTR"
            warn(query(MENUTEXTATTR))
        when "MENUTEXTLTRATTR"
            warn(query(MENUTEXTLTRATTR))
        when "MESSAGE"
            MESSAGE(pcParam1)

//         when "MOUSE"     // not a command
//             MOUSE()

        when "MOUSEENABLED"
            warn(query(MOUSEENABLED))
        when "MOUSEHOLDTIME"
            warn(query(MOUSEHOLDTIME))
        when "MOUSEHOTSPOT"
            warn(MOUSEHOTSPOT())
        when "MOUSEKEY"
            warn(query(MOUSEKEY))
        when "MOUSEKEYHELD"
            warn(MOUSEKEYHELD())
        when "MOUSEMARKING"
            MOUSEMARKING(val(pcParam1))
        when "MOUSEREPEATDELAY"
            warn(query(MOUSEREPEATDELAY))
        when "MOUSESTATUS"
            MOUSESTATUS()
        when "MOUSEWINDOWID"
            warn(MOUSEWINDOWID())
        when "MOUSEX"
            warn(query(MOUSEX))
        when "MOUSEY"
            warn(query(MOUSEY))
        when "MOVEBLOCK"
            MOVEBLOCK()
        when "MSGATTR"
            warn(query(MSGATTR))
        when "MSGLEVEL"
            warn(query(MSGLEVEL))
        when "NEXTCHAR"
            NEXTCHAR()
        when "NEXTFILE"
            NEXTFILE()
        when "NEXTWINDOW"
            NEXTWINDOW()
        when "NOSOUND"
            NOSOUND()
        when "NUMFILES"
            warn(NUMFILES())
        when "NUMLINES"
            warn(NUMLINES())
        when "ONEWINDOW"
            ONEWINDOW()
        when "OTHERWINBORDERATTR"
            warn(query(OTHERWINBORDERATTR))
        when "OTHERWINBORDERTYPE"
            warn(query(OTHERWINBORDERTYPE))
        when "OVERWRITECURSORSIZE"
            warn(query(OVERWRITECURSORSIZE))
        when "PAGEDOWN"
            PAGEDOWN()
        when "PAGEUP"
            PAGEUP()
        when "PARAENDSTYLE"
            warn(query(PARAENDSTYLE))
        when "PASTE"
            PASTE()
        when "PASTEUNDELETE"
            PASTEUNDELETE()
        when "PICKFILE"
            PICKFILE(pcParam1)
        when "PLACEMARK"
            PLACEMARK()
        when "POPBLOCK"
            POPBLOCK()
        when "POPPOSITION"
            POPPOSITION()
        when "POPWINCLOSE"
            POPWINCLOSE()

//         when "POPWINOPEN"        // way too many parameters
//             POPWINOPEN()

        when "POS"
            warn(POS(pcParam1, pcParam2))
        when "POSFIRSTNONWHITE"
            warn(POSFIRSTNONWHITE())
        when "POSLASTNONWHITE"
            warn(POSLASTNONWHITE())
        when "PREVCHAR"
            PREVCHAR()
        when "PREVFILE"
            PREVFILE()
        when "PREVPOSITION"
            PREVPOSITION()
        when "PREVWINDOW"
            PREVWINDOW()
        when "PRINTADDFF"
            warn(query(PRINTADDFF))
        when "PRINTBLOCK"
            PRINTBLOCK()
        when "PRINTBOTMARGIN"
            warn(query(PRINTBOTMARGIN))
        when "PRINTCHAR"
            PRINTCHAR(pcParam1)
        when "PRINTCOPIES"
            warn(query(PRINTCOPIES))
        when "PRINTDEVICE"
            warn(query(PRINTDEVICE))
        when "PRINTFILE"
            PRINTFILE()
        when "PRINTFIRSTPAGE"
            warn(query(PRINTFIRSTPAGE))
        when "PRINTFOOTER"
            warn(query(PRINTFOOTER))
        when "PRINTHEADER"
            warn(query(PRINTHEADER))

//         when "PRINTING"      // not a command
//             PRINTING()

        when "PRINTINIT"
            warn(query(PRINTINIT))
        when "PRINTLASTPAGE"
            warn(query(PRINTLASTPAGE))
        when "PRINTLEFTMARGIN"
            warn(query(PRINTLEFTMARGIN))
        when "PRINTLINENUMBERS"
            warn(query(PRINTLINENUMBERS))
        when "PRINTLINESPACING"
            warn(query(PRINTLINESPACING))
        when "PRINTLINESPERPAGE"
            warn(query(PRINTLINESPERPAGE))
        when "PRINTPAUSE"
            warn(query(PRINTPAUSE))
        when "PRINTRIGHTMARGIN"
            warn(query(PRINTRIGHTMARGIN))
        when "PRINTTOPMARGIN"
            warn(query(PRINTTOPMARGIN))
        when "PRINTUSEFF"
            warn(query(PRINTUSEFF))
        when "PROCESS"
            PROCESS()
        when "PROCESSHOTSPOT"
            warn(PROCESSHOTSPOT())
        when "PROTECTEDSAVES"
            warn(query(PROTECTEDSAVES))
        when "PURGEKEYMACRO"
            PURGEKEYMACRO()
        when "PURGEMACRO"
            PURGEMACRO()
        when "PUSHBLOCK"
            PUSHBLOCK()
        when "PUSHKEY"
            PUSHKEY(val(pcParam1))
        when "PUSHPOSITION"
            PUSHPOSITION()
        when "PUTATTR"
            PUTATTR(val(pcParam1), val(pcParam2))
        when "PUTCHAR"
            PUTCHAR(pcParam1)
        when "PUTCHARH"
            PUTCHARH(pcParam1, val(pcParam2))
        when "PUTCHARV"
            PUTCHARV(pcParam1, val(pcParam2))
        when "PUTLINE"
            PUTLINE(pcParam1, val(pcParam2))
        when "PUTSTR"
            PUTSTR(pcParam1)

//         when "QUERY"         // wants a literal
//             warn(QUERY(val(pcParam1)))
//         when "QUICKHELP"     // needs
//             QUICKHELP()      // needs a helpdef type

        when "QUITFILE"
            QUITFILE()
        when "QUITTOPROMPT"
            warn(query(QUITTOPROMPT))

//         when "READ"          // won't work like this
//             READ(pcParam1)

        when "RECORDKEYMACRO"
            RECORDKEYMACRO()
        when "REMOVETRAILINGWHITE"
            warn(query(REMOVETRAILINGWHITE))
        when "REMOVEUNLOADEDFILES"
            REMOVEUNLOADEDFILES()
        when "REPEATCMD"
            REPEATCMD()
        when "REPEATFIND"
            REPEATFIND()
        when "REPLACE"
            REPLACE()
        when "REPLACEOPTIONS"
            warn(query(REPLACEOPTIONS))
        when "RESIZEWINDOW"
            RESIZEWINDOW()
        when "RESTORECURSORLINE"
            RESTORECURSORLINE()
        when "RETURNEQNEXTLINE"
            warn(query(RETURNEQNEXTLINE))
        when "RIGHT"
            RIGHT()
        when "RIGHTMARGIN"
            warn(query(RIGHTMARGIN))
        when "ROLLDOWN"
            ROLLDOWN()
        when "ROLLLEFT"
            ROLLLEFT()
        when "ROLLRIGHT"
            ROLLRIGHT()
        when "ROLLUP"
            ROLLUP()
        when "SAVEALLANDEXIT"
            SAVEALLANDEXIT()
        when "SAVEALLFILES"
            SAVEALLFILES()
        when "SAVEANDQUITFILE"
            SAVEANDQUITFILE()
        when "SAVEAS"
            SAVEAS()
        when "SAVEBLOCK"
            SAVEBLOCK()
        when "SAVEFILE"
            SAVEFILE()
        when "SAVEKEYMACRO"
            SAVEKEYMACRO()
        when "SAVESETTINGS"
            SAVESETTINGS()
        when "SCREENCOLS"
            warn(query(SCREENCOLS))
        when "SCREENROWS"
            warn(query(SCREENROWS))
        when "SCROLLDOWN"
            SCROLLDOWN()
        when "SCROLLLEFT"
            SCROLLLEFT()
        when "SCROLLRIGHT"
            SCROLLRIGHT()
        when "SCROLLTOROW"
            SCROLLTOROW(val(pcParam1))
        when "SCROLLUP"
            SCROLLUP()

//         when "SEARCHING"     // not a command
//             SEARCHING()

        when "SEARCHPATH"
            warn(SEARCHPATH(pcParam1, pcParam2))

//         when "SELFINSERT"    // needs to be bound to a key
//             SELFINSERT()

//         when "SET"       // like query(), this will need its own function
//             SET()

        when "SETCLIPBOARDID"
            SETCLIPBOARDID(val(pcParam1))
        when "SETGLOBALINT"
            SETGLOBALINT(pcParam1, val(pcParam2))
        when "SETGLOBALSTR"
            SETGLOBALSTR(pcParam1, pcParam2)
        when "SHELL"
            SHELL()
        when "SHIFTTEXT"
            SHIFTTEXT(val(pcParam1))
        when "SHOWENTRYSCREEN"
            SHOWENTRYSCREEN()
        when "SHOWEOFMARKER"
            warn(query(SHOWEOFMARKER))
        when "SHOWHELPLINE"
            warn(query(SHOWHELPLINE))
        when "SHOWMOUSE"
            SHOWMOUSE()
        when "SHOWSTATUSLINE"
            warn(query(SHOWSTATUSLINE))

//         when "SIZEOF"        // needs a literal
//             warn(SIZEOF(pcParam1))

        when "SORT"
            SORT()
        when "SOUND"
            SOUND(val(pcParam1))
        when "SPLITLINE"
            SPLITLINE()
        when "SPLITPATH"
            warn(SPLITPATH(pcParam1, val(pcParam2)))

//         when "STARTUPATTRSET"    // no good outside of config
//             warn(query(STARTUPATTRSET))
//         when "STARTUPVIDEOMODE"  // no good outside of config
//             STARTUPVIDEOMODE()

        when "STATUSLINEATTOP"
            warn(query(STATUSLINEATTOP))
        when "STATUSLINEATTR"
            warn(query(STATUSLINEATTR))
        when "STATUSLINEFILLCHAR"
            warn(query(STATUSLINEFILLCHAR))
        when "STR"
            warn(STR(val(pcParam1)))

//         when "SUBSTR"    // too many parameters
//             SUBSTR()

        when "SWAPPATH"
            warn(query(SWAPPATH))
        when "TABLEFT"
            TABLEFT()
        when "TABRIGHT"
            TABRIGHT()

//         when "TABSET"    // i don't know
//             warn(TABSET(pcParam1))

        when "TABTYPE"
            warn(query(TABTYPE))
        when "TABWIDTH"
            warn(query(TABWIDTH))
        when "TEXTATTR"
            warn(query(TEXTATTR))
        when "TIMEFORMAT"
            warn(query(TIMEFORMAT))
        when "TIMESEPARATOR"
            warn(query(TIMESEPARATOR))

//         when "TOGGLE"    // wants a literal
//             TOGGLE()

        when "TOGGLEINSERT"
            TOGGLEINSERT()
        when "TRACKMOUSECURSOR"
            TRACKMOUSECURSOR()
        when "UNDELETE"
            UNDELETE()

//         when "UNHOOK"    // won't work like this
//             UNHOOK()

        when "UNMARKAFTERPASTE"
            warn(query(UNMARKAFTERPASTE))
        when "UNMARKBLOCK"
            UNMARKBLOCK()
        when "UP"
            UP()
        when "UPCASE"
            warn(UPCASE(pcParam1))
        when "UPDATEDISPLAY"
            UPDATEDISPLAY()
        when "UPPER"
            UPPER()
        when "USECURRLINEIFNOBLOCK"
            warn(query(USECURRLINEIFNOBLOCK))
        when "USEENHANCEDKBD"
            warn(query(USEENHANCEDKBD))
        when "USEMOUSE"
            warn(query(USEMOUSE))
        when "VAL"
            warn(VAL(pcParam1))
        when "VARTABS"
            warn(query(VARTABS))
        when "VGOTOXY"
            VGOTOXY(val(pcParam1), val(pcParam2))
        when "VHOMECURSOR"
            VHOMECURSOR()
        when "VWINDOW"
            VWINDOW()
        when "WAITFORMOUSEEVENT"
            WAITFORMOUSEEVENT(val(pcParam1))
        when "WARN"
            WARN(pcParam1)
        when "WHEREX"
            warn(WHEREX())
        when "WHEREY"
            warn(WHEREY())

//         when "WINDOW"        // too many parameters
//             WINDOW()

        when "WINDOWCOLS"
            warn(query(WINDOWCOLS))
        when "WINDOWID"
            warn(WINDOWID())
        when "WINDOWROWS"
            warn(query(WINDOWROWS))

//         when "WINDOWS"       // no help available
//             WINDOWS()

        when "WINDOWX1"
            warn(query(WINDOWX1))
        when "WINDOWY1"
            warn(query(WINDOWY1))
        when "WORDLEFT"
            WORDLEFT()
        when "WORDRIGHT"
            WORDRIGHT()
        when "WORDSET"
            warn(query(WORDSET))
        when "WORDWRAP"
            warn(query(WORDWRAP))
        when "WRAPPARA"
            WRAPPARA()
        when "WRITE"
            WRITE(pcParam1)
        when "WRITELINE"
            WRITELINE(pcParam1)
        when "YESNO"
            warn(YESNO(pcParam1))
        when "ZOOMWINDOW"
            ZOOMWINDOW()

    endcase

end

proc main ()

    string cCommand[ 80] = ""
    string  cParam1[ 80] = ""
    string  cParam2[ 80] = ""

    if (ask("Command: ", cCommand) and length(cCommand) > 0)
        if (ask("1st Parameter: ", cParam1) and ask("2st Parameter: ", cParam2))
            doCommand(cCommand, cParam1, cParam2)
        endif
    endif
end

