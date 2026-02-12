/****************************************************************************\

    DC.S

    Dialog resource compiler.

    Version         v2.00/24.10.96
    Copyright       (c) 1995-96 by DiK

    Overview:

    This macro is the dialog resource compiler used with Dialog.S. It
    reads a symbolic description of a dialog (a ".D" file), checks this
    input for errors and produces a binary dialog resource (".DLG" file).

    Command Line Format:

    DC [-b] [-k] [-r] [filename]

    where:

        -b          batch mode (don't test dialog)
        -k          keep and return binary resource (implies -b)
        -r          relaxed mode (don't check position and size of controls)
        filename    name of the dialog resource to be compiled

    Usage notes:

    If a filename is included at the macro command line, DC loads and
    compiles the specified file. Otherwise DC will prompt the user for
    the name of the input file, unless the file extension of the current
    file is ".D".  In this case, DC immediately starts compiling the
    current file. If DC encounters an error while compiling, it stops,
    marks the erroneous portion of the input file and displays a short
    message on what went wrong. After a successful compilation DC produces
    a ".DLG" file of the same name as the input file. Furthermore, the
    user is prompted, if he immediately wants to execute and test the new
    dialog resource. If you don't want to see the dialog for some reason,
    use batch mode. The switches -k and -r are not meant for interactive
    usage.

    See Program.Doc for a more detailed instructions on how to use DC.S
    to write and compile your own dialog resources.

    History

    v2.00/24.10.96  adaption to TSE32
                    þ added handling of default extension
                    þ fixed size of name strings
                    þ fixed quoting long filenames
    v1.20/25.03.96  maintenance
                    þ added commandline arguments
                    þ added return code
                    þ added DD to display dialog
                    þ added DlgOpen interface
                    þ fixed tab handling
                    þ some clean up of source code
    v1.10/12.01.96  maintenance
                    þ fixed word set operations
                    þ fixed custom control painting
    v1.00/11.10.95  first version

\****************************************************************************/

/****************************************************************************\
    constants
\****************************************************************************/

#include "dialog.si"

/****************************************************************************\
    shared code
\****************************************************************************/

#define INC_QUOTE    1
#define INC_NUMTOKEN 1
#define INC_GETTOKEN 1

#include "scruns.si"
#include "sctoken.si"

/****************************************************************************\
    global variables
\****************************************************************************/

string inpname[255]                     // name of input file
string outname[255]                     // name of output file

integer usrfile                         // buffer id (user file)
integer inpfile                         // ditto (input file)
integer outfile                         // ditto (output file)
integer incfile                         // ditto (include files)
integer dlgbuff                         // ditto (binary resource)

integer current                         // flag (compiling current file)
integer keepres                         // flag (keep binary resource)
integer relaxed                         // flag (don't check position)
integer batch                           // flag (batch mode)
integer group                           // flag (compiling grouped controls)
integer def_btn                         // position of default button
integer dx, dy                          // size of dialog window

/****************************************************************************\
    compiler syntax
\****************************************************************************/

string rule1[] = '^[ \t]@{[~ \t]#}\c'                   // key words
string rule2[] = '^[ \t]#{[0-9]#}\c'                    // numbers
string rule3[] = '^[ \t]#{[A-Za-z][0-9A-Z_a-z]#}\c'     // identifiers
string rule4[] = '^[ \t]#"{[~"]@}"$|{,"{[~"]@}"$}'      // title and hint
string rule5[] = '^[ \t]@\#include[ \t]#"\c{.#}"$'      // include statement
string ruleA[] = '^[ \t]@constant[ \t]#'                // partial const defs
string ruleB[] = '\c{[A-Z_a-z][0-9A-Z_a-z]#}'
string ruleC[] = '[ \t]@=[ \t]@{[0-9]#}$'

/****************************************************************************\
    compile error
\****************************************************************************/

proc ErrorMsg( string msg )
    Set(MacroCmdLine,msg)
    Message("Error: ",msg)
end

integer proc Test( integer col, integer err, string msg )
    integer id
    string word_set[32]
    string comp_set[32]

    if err
        id = GotoBufferId(inpfile)

        comp_set = Query(WordSet)
        SetBit(comp_set,Asc("."))
        SetBit(comp_set,Asc("&"))
        SetBit(comp_set,Asc('"'))
        word_set = Set(WordSet,comp_set)

        ErrorMsg(msg)
        GotoPos(PosFirstNonWhite())
        do col-1 times
            WordRight()
        enddo
        case col
            when 8      MarkToEol()
            otherwise   MarkWord()
        endcase

        Set(WordSet,word_set)

        GotoBufferId(id)
    endif
    return (err)
end

/****************************************************************************\
    read include file
\****************************************************************************/

integer proc GetIncFile()
    integer rc
    string name[255]
    string ident[64]
    string ruleD[255]
    string ruleE[255]

    // parse include statement

    if Test(1, not lFind(rule5,"cgx"), "invalid include statement")
        return (TRUE)
    endif
    MarkFoundText(1)
    name = GetMarkedText()

    // read include file

    Message("Parsing include file ",name)
    GotoBufferId(incfile)
    BegFile()
    rc = not InsertFile(name,_DONT_PROMPT_)
    Test(2, rc, "Cannot open include file: "+name)

    // check for redefined symbols

    if not rc
        ruleD = ruleA + ruleB + ruleC
        BegFile()
        repeat
            if lFind(ruleD,"cgx")
                MarkFoundText(1)
                ident = GetMarkedText()
                ruleE = ruleA + ident + ruleC
                if Test(2, lFind(ruleE,"ix+"), "constant "+ident+" redefined")
                    rc = TRUE
                    break
                endif
            endif
        until not Down()
    endif

    // go back to input file

    GotoBufferId(inpfile)
    return (rc)
end

/****************************************************************************\
    search include files for symbolic constant
\****************************************************************************/

integer proc FindIdent( var integer id )
    integer rc
    string ident[64]
    string ruleE[255]

    MarkFoundText(1)
    ident = GetMarkedText()
    ruleE = ruleA + ident + ruleC
    GotoBufferId(incfile)
    rc = lFind(ruleE,"gix")
    if rc
        MarkFoundText(1)
        id = Val(GetMarkedText())
    endif
    GotoBufferId(inpfile)
    return (not rc)
end

/****************************************************************************\
    handle grouping of controls
\****************************************************************************/

integer proc HandleGroup()
    group = not group
    AddLine(Format(
            Chr(CNTRL_GROUP):-9:Chr(0)," ",Chr(END_OF_TITLE)),
        dlgbuff)
    AddLine(Format(
            "":4,
            "Chr(0x",CNTRL_GROUP:2:"0":16,")+",
            "Chr(0x00)+",
            "Chr(0x00)+",
            "Chr(0x00)+",
            "Chr(0x00)+",
            "Chr(0x00)+",
            "Chr(0x00)+",
            "Chr(0x00)+",
            "Chr(0x00)+",
            "' '+",
            "Chr(0x",END_OF_TITLE:2:"0":16,")"),
        outfile)
    return (FALSE)
end

/****************************************************************************\
    compile one line of resource input
\****************************************************************************/

integer proc CompileLine()
    integer cntrl, id, en, hkpos
    integer x1, y1, x2, y2
    integer len
    string ctype[16]
    string title[255]
    string hline[255]
    string htkey[1] = ""

    // skip comments and blank lines

    while CurrChar(1) < 0 or GetText(PosFirstNonWhite(),2) == "//"
        if not Down()
            return (FALSE)
        endif
    endwhile

    // parse and compile control type

    if Test(1, not lFind(rule1,"cgx"), "invalid control type")
        return (TRUE)
    endif
    MarkFoundText(1)
    ctype = Lower(GetMarkedText())

    case ctype
        when "#include" return (GetIncFile())
        when "group"    return (HandleGroup())
        when "dialog"   cntrl = CNTRL_DIALOG
        when "frame"    cntrl = CNTRL_FRAME
        when "ltext"    cntrl = CNTRL_LTEXT
        when "rtext"    cntrl = CNTRL_RTEXT
        when "ctext"    cntrl = CNTRL_CTEXT
        when "open"     cntrl = CNTRL_OPEN
        when "edit"     cntrl = CNTRL_EDIT
        when "button"   cntrl = CNTRL_BUTTON
        when "defbtn"   cntrl = CNTRL_DEFBTN
        when "radio"    cntrl = CNTRL_RADIO
        when "check"    cntrl = CNTRL_CHECK
        when "combo"    cntrl = CNTRL_COMBO
        when "list"     cntrl = CNTRL_LIST
        when "vscroll"  cntrl = CNTRL_VSCROLL
        when "hscroll"  cntrl = CNTRL_HSCROLL
        when "scredge"  cntrl = CNTRL_SCREDGE
        when "control"  cntrl = CNTRL_CONTROL
        otherwise
            Test(1, TRUE, "unknown control type")
            return (TRUE)
    endcase

    // handle default button

    if cntrl == CNTRL_DEFBTN
        if Test(1, def_btn, "multiple default buttons defined")
            return (TRUE)
        else
            def_btn = CurrLine()
        endif
    endif

    // parse and compile control id

    MarkToEol()
    if lFind(rule2,"lgx")
        MarkFoundText(1)
        id = Val(GetMarkedText())
    elseif lFind(rule3,"lgx")
        if Test(2, FindIdent(id), "symbolic constant not defined")
            return (TRUE)
        endif
    else
        Test(2, TRUE, "invalid control id")
        return (TRUE)
    endif

    // parse and compile enable flag

    MarkToEol()
    if Test(3, not lFind(rule2,"lgx"), "invalid enable flag")
        return (TRUE)
    endif
    MarkFoundText(1)
    en = Val(GetMarkedText())

    // parse and compile coordinates

    MarkToEol()
    if Test(4, not lFind(rule2,"lgx"), "invalid x1 coordinate")
        return (TRUE)
    endif
    MarkFoundText(1)
    x1 = Val(GetMarkedText())

    MarkToEol()
    if Test(5, not lFind(rule2,"lgx"), "invalid y1 coordinate")
        return (TRUE)
    endif
    MarkFoundText(1)
    y1 = Val(GetMarkedText())

    MarkToEol()
    if Test(6, not lFind(rule2,"lgx"), "invalid x2 coordinate")
        return (TRUE)
    endif
    MarkFoundText(1)
    x2 = Val(GetMarkedText())

    MarkToEol()
    if Test(7, not lFind(rule2,"lgx"), "invalid y2 coordinate")
        return (TRUE)
    endif
    MarkFoundText(1)
    y2 = Val(GetMarkedText())

    // check coordinates

    if not relaxed
        if Test(4, x1 < 1, "coordinate X1 too small")
            return (TRUE)
        endif
        if Test(5, y1 < 1, "coordinate Y1 too small")
            return (TRUE)
        endif
        if Test(4, x1 >= dx, "coordinate X1 too large")
            return (TRUE)
        endif
        if Test(5, y1 >= dy, "coordinate Y1 too large")
            return (TRUE)
        endif
        if Test(6, x2 <= x1, "coordinate X2 too small")
            return (TRUE)
        endif
        if Test(7, y2 <= y1, "coordinate Y2 too small")
            return (TRUE)
        endif
        if Test(6, x2 > dx, "coordinate X2 too large")
            return (TRUE)
        endif
        if not (cntrl in CNTRL_EDIT,CNTRL_COMBO)
            if Test(7, y2 > dy, "coordinate Y2 too large")
                return (TRUE)
            endif
        endif
    endif

    // parse and compile title

    MarkToEol()
    if Test(8, not lFind(rule4,"lgx"), "invalid control title and/or help line")
        return (TRUE)
    endif
    MarkFoundText(1)
    title = GetMarkedText()
    MarkFoundText(3)
    hline = GetMarkedText()

    // determine position of hot key

    if cntrl in CNTRL_DIALOG,CNTRL_EDIT
        hkpos = 0
    else
        hkpos = Pos("&",title)
    endif
    if hkpos
        htkey = title[hkpos+1]
        title = DelStr(title,hkpos,1)
    else
        htkey = " "
    endif

    // check length of title

    if not relaxed
        len = x2 - x1
        case cntrl
            when CNTRL_DIALOG                               len = len - 16
            when CNTRL_FRAME                                len = len - 6
            when CNTRL_RADIO,CNTRL_CHECK                    len = len - 4
            when CNTRL_EDIT,CNTRL_HSCROLL,CNTRL_VSCROLL     len = 128
        endcase
        if Test(8, Length(title) > len, "title of control too long")
            return (TRUE)
        endif
    endif

    // write binary info to test buffer

    AddLine(Format(
            Chr(cntrl),
            Chr(id   ),
            Chr(en   ),
            Chr(group),
            Chr(x1   ),
            Chr(y1   ),
            Chr(x2   ),
            Chr(y2   ),
            Chr(hkpos),
            htkey,
            title,
            Chr(END_OF_TITLE),
            hline),
        dlgbuff)

    // write hex info to output file

    AddLine(Format(
            "":4,
            "Chr(0x",cntrl:2:"0":16,")+",
            "Chr(0x",id   :2:"0":16,")+",
            "Chr(0x",en   :2:"0":16,")+",
            "Chr(0x",group:2:"0":16,")+",
            "Chr(0x",x1   :2:"0":16,")+",
            "Chr(0x",y1   :2:"0":16,")+",
            "Chr(0x",x2   :2:"0":16,")+",
            "Chr(0x",y2   :2:"0":16,")+",
            "Chr(0x",hkpos:2:"0":16,")+",
            "'",htkey,title,"'+",
            "Chr(0x",END_OF_TITLE:2:"0":16,")+",
            "'",hline,"'"),
        outfile)

    // indicate success

    return(FALSE)
end

/****************************************************************************\
    compile dialog
\****************************************************************************/

integer proc Compile()

    // translate dialog header

    Message("Compiling dialog header")
    dx = 80
    dy = 25
    GotoBufferId(inpfile)
    BegFile()
    if CompileLine()
        return (FALSE)
    endif
    GotoBufferId(dlgbuff)
    BegFile()
    if CurrChar(POS_CNTRL) <> CNTRL_DIALOG
        ErrorMsg("First statement must be DIALOG")
        return (FALSE)
    endif
    if CurrChar(POS_ID) <> 0
        ErrorMsg("ID of DIALOG must be ZERO")
        return (FALSE)
    endif
    dx = CurrChar(POS_X2) - CurrChar(POS_X1)
    dy = CurrChar(POS_Y2) - CurrChar(POS_Y1)

    // translate remaining controls

    GotoBufferId(inpfile)
    while Down()
        Message("Compiling line ",CurrLine())
        if KeyPressed() and GetKey() == <Escape>
            ErrorMsg("Interrupted by user")
            return (FALSE)
        endif
        if CompileLine()
            return (FALSE)
        endif
    endwhile
    UnmarkBlock()

    // check for matching group statements

    if Test(1, group, "last group statement missing")
        return (FALSE)
    endif

    // add datadef declaration

    GotoBufferId(outfile)
    BegFile()
    InsertLine("datadef "+SplitPath(inpname,_NAME_))
    EndFile()
    AddLine("end")

    // indicate success

    Message("Succesfully compiled ",inpname)
    return (TRUE)
end

/****************************************************************************\
    save and test dialog
\****************************************************************************/

integer proc SaveDlg()
    GotoBufferId(outfile)
    if SaveAs(outname,_OVERWRITE_|_DONT_PROMPT_)
        return (TRUE)
    endif
    ErrorMsg("Cannot save output file")
    return (FALSE)
end

proc TestDlg()
    if not batch
        Set(X1,(Query(ScreenCols)-16)/2)
        Set(Y1,(Query(ScreenRows)- 5)/2)
        if YesNo("Test dialog?") == 1
            ExecMacro("DD "+outname)
        endif
    endif
end

/****************************************************************************\
    show compile error
\****************************************************************************/

proc ShowError()
    GotoBufferId(inpfile)
    ScrollToCenter()
    KillPosition()
    PushPosition()
    current = TRUE
    keepres = FALSE
end

/****************************************************************************\
    setup
\****************************************************************************/

integer proc Init()
    integer i
    integer hist
    string token[255]
    string cmdline[255] = Query(MacroCmdLine)
    string msg[48] = "Enter name of dialog resource file:"

    // save position

    usrfile = GetBufferId()

    // compute command line

    for i=1 to NumQuotedTokens(cmdline)
        token = GetQuotedToken(cmdline,i)
        case token
            when "-b"
                batch = TRUE
            when "-k"
                batch = TRUE
                keepres = TRUE
            when "-r"
                relaxed = TRUE
            otherwise
                inpname = token
        endcase
    endfor

    // determine filenames

    if Length(inpname) and SplitPath(inpname,_EXT_) == ""
        inpname = inpname + ".d"
    endif

    if not (Length(inpname) and FileExists(inpname))
        hist = GetFreeHistory("DLG:txt")
        current = CurrExt() == ".d"
        if current
            PushPosition()
            if FileChanged()
                SaveFile()
            endif
            inpname = CurrFileName()
        elseif ExecDialog("DlgOpen -x -t -c")
            if Val(Query(MacroCmdLine)) == 2
                inpname = GetHistoryStr(hist,1)
            else
                return (FALSE)
            endif
        else
            inpname = "*.d"
            if not AskFilename(msg,inpname,_MUST_EXIST_,hist)
                return (FALSE)
            endif
        endif
    endif
    outname = SplitPath(inpname,_DRIVE_|_PATH_|_NAME_) + ".dlg"

    // load input file and create output file

    inpfile = EditFile(QuotePath(inpname))
    outfile = CreateBuffer(outname)
    incfile = CreateTempBuffer()
    dlgbuff = CreateTempBuffer()
    if not (inpfile and outfile and incfile and dlgbuff)
        ErrorMsg("Cannot allocate work space")
        return (FALSE)
    endif

    return (TRUE)
end

/****************************************************************************\
    shutdown
\****************************************************************************/

proc Done( integer ok )

    // set return code and handle resource file

    if ok
        if keepres
            Set(MacroCmdLine,Str(dlgbuff))
        else
            Set(MacroCmdLine,"0")
            AbandonFile(dlgbuff)
        endif
    else
        AbandonFile(dlgbuff)
    endif

    // clear work space

    AbandonFile(outfile)
    AbandonFile(incfile)

    // clear input and resource file

    if current
        PopPosition()
    else
        AbandonFile(inpfile)
        GotoBufferId(usrfile)
    endif

    // purge self

    PurgeMacro(CurrMacroFileName())
end

/****************************************************************************\
    main program
\****************************************************************************/

proc Main()
    integer ok = FALSE

    if Init()
        if Compile()
            if SaveDlg()
                ok = TRUE
                TestDlg()
            endif
        else
            ShowError()
        endif
    endif
    Done(ok)
end

