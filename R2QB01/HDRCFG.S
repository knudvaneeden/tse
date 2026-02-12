//'main' procedure- not assigned to a key. Use LoadMacro, then ExecMacro to run
//forward integer proc ConfigHeaderDataFile()

//procedures list
forward integer proc    GetNewHeader()
forward integer proc    uInsertFile(string fn)
forward integer proc    GetSelectedItem(var string line, var integer linenum, var integer hpos)
forward integer proc    ExitConfig()
forward integer proc    uSaveFile(var string fn, integer how)
forward integer proc    MemError()
forward         proc    HelpHook()
forward         proc    HelpOnHListKeys()
forward         proc    HListStartup()
forward         menu    Config_Header()
forward         HelpDef HListKeysHelp
forward         keydef  HListKeys

constant _OW = _OVERWRITE_,
         _AP = _APPEND_,
         MAX_HTAG = 20,
         HlistESCAPE     =   0,
         HlistENTER      =   1,
         _EXIT           =   0,
         _TO_MAIN_MENU   =   1

//misc variables
string  Header_fn[128] = "",
        Just_fn[12] = "",
        HTagName[MAX_HTAG] = "",
        Select_string[60] = ""
integer HConfigFileExists = 0
integer curr_id                 //buffer of current user file
integer new_header_id           //buffer for header config file data-
                                //loaded from existing file/append or
                                //will create new file
//saved editor variables
integer     OldIndent = 0,
            OldInsert = 0,
            OldLMarg = 0,
            OldPara = 0,
            OldRemWh = 0,
            OldRet = 0,
            OldRMarg = 0,
            OldWrap = 0,
            OldInsLB = 0,
            OldShowHelp = 0

//variables for header lines, line numbers, offsets
string  HFirstLine[80],
        HLastLine[80],
        HAreaLine[80],
        HFromLine[80],
        HToLine[80],
        HSubjLine[80],
        HDateLine[80]

integer HFirstLineNum,
        HLastLineNum,
        HAreaLineNum,
        HFromLineNum,
        HToLineNum,
        HSubjLineNum,
        HDateLineNum,
        HFirstSpos,
        HLastSpos,
        HAreaSpos,
        HAreaEpos,
        HFromSpos,
        HFromEpos,
        HToSpos,
        HToEpos,
        HSubjSpos,
        HSubjEpos,
        HDateSpos,
        HDateEpos


/**************************************************************************
                     This is the 'Main' procedure
 **************************************************************************/
proc Main()
integer success = 0

    curr_id = GetBufferId()
    OldIndent = Set(AutoIndent, ON)
    OldInsert = Set(Insert, ON)
    OldLMarg = Set(LeftMargin, 0)
    OldPara = Set(ParaEndStyle, 1)
    OldRemWh = Set(RemoveTrailingWhite, ON)
    OldRet = Set(ReturnEqNextLine, OFF)
    OldRMarg = Set(RightMargin, 78)
    OldWrap = Set(WordWrap, ON)
    OldInsLB = Set(InsertLineBlocksAbove, OFF)
    OldShowHelp = Set(ShowHelpLine, OFF)

    loop
        success = Config_Header()   //menu: options:  Create header file;
                                    //                Exit config.
        if success == _EXIT
            break
        endif
    endloop

    ExitConfig()
    return()
end

/**************************************************************************
                    integer proc GetNewHeader()
 **************************************************************************/
integer proc GetNewHeader()
integer success = _EXIT, eof_type = _NONE_
string  HeaderPath[128] = ""        //drive\path

    new_header_id = CreateTempBuffer()

    if new_header_id
        HeaderPath = SplitPath(CurrMacroFileName(), _DRIVE_ | _PATH_)
        Just_fn = (SplitPath(CurrMacroFileName(), _NAME_) + ".dat")
        Header_fn = SearchPath(Just_fn, HeaderPath)

        if Header_fn <> ''          //found existing config file
            eof_type = Set(EOFType, _NONE_)
            success = uInsertFile(Header_fn)
            Set(EOFType, eof_type)

            if not success
                Warn("Error loading '",Just_fn,"'")
                return(success)     //return/exit on error
            endif

            HConfigFileExists = 1

        else
            Header_fn = HeaderPath + Just_fn
        endif

    else
        MemError()                //memory error- aborts macro
    endif

    GotoBufferId(curr_id)

//at this point, we either loaded an existing config file and will append,
//or will create a new one.

    GET_CONFIG:
    Select_string = "First line of message header"

    if Enable(HListKeys, _EXCLUSIVE_)
        Hook(_AFTER_UPDATE_DISPLAY_, HListStartup)
        UpdateDisplay()
        success = Process()
        UnHook(HListStartup)
        UpdateDisplay()   //trying to clean up at end
        Disable(HListKeys)
    else
        Warn("Can't load keydef's- aborting!")
        ExitConfig()
    endif

    if success
        success = GetSelectedItem(HFirstLine, HFirstLineNum, HFirstSpos)
        if not success
            goto GET_CONFIG
        endif
    else
        case YesNo("Abort this configuration?")
            when 1              //yes
                return(_TO_MAIN_MENU)
            when 0, 2, 3        //escape, no, cancel
                goto GET_CONFIG //start over
        endcase
    endif

    Select_string = "Last line of message header"

    if Enable(HListKeys, _EXCLUSIVE_)
        Hook(_AFTER_UPDATE_DISPLAY_, HListStartup)
        UpdateDisplay()
        success = Process()
        UnHook(HListStartup)
        Disable(HListKeys)
    else
        Warn("Can't load keydef's- aborting!")
        ExitConfig()
    endif

    if success
        success = GetSelectedItem(HLastLine, HLastLineNum, HLastSpos)
        if not success
            goto GET_CONFIG
        endif
    else
        case YesNo("Abort this configuration?")
            when 1              //yes
                return(_TO_MAIN_MENU)
            when 0, 2, 3        //escape, no, cancel
                goto GET_CONFIG //start over
        endcase
    endif

    Select_string = "Start column of 'area' field data"

    if Enable(HListKeys, _EXCLUSIVE_)
        Hook(_AFTER_UPDATE_DISPLAY_, HListStartup)
        UpdateDisplay()
        success = Process()
        UnHook(HListStartup)
        Disable(HListKeys)
    else
        Warn("Can't load keydef's- aborting!")
        ExitConfig()
    endif

    if success
        success = GetSelectedItem(HAreaLine, HAreaLineNum, HAreaSpos)
        if not success
            goto GET_CONFIG
        endif
    else
        case YesNo("Abort this configuration?")
            when 1              //yes
                return(_TO_MAIN_MENU)
            when 0, 2, 3        //escape, no, cancel
                goto GET_CONFIG //start over
        endcase
    endif

    Select_string = "End column of 'area' field data"

    if Enable(HListKeys, _EXCLUSIVE_)
        Hook(_AFTER_UPDATE_DISPLAY_, HListStartup)
        UpdateDisplay()
        success = Process()
        UnHook(HListStartup)
        Disable(HListKeys)
    else
        Warn("Can't load keydef's- aborting!")
        ExitConfig()
    endif

    if success
        success = GetSelectedItem(HAreaLine, HAreaLineNum, HAreaEpos)
        if not success
            goto GET_CONFIG
        endif
    else
        case YesNo("Abort this configuration?")
            when 1              //yes
                return(_TO_MAIN_MENU)
            when 0, 2, 3        //escape, no, cancel
                goto GET_CONFIG //start over
        endcase
    endif

    Select_string = "Start column of 'From:' field data"

    if Enable(HListKeys, _EXCLUSIVE_)
        Hook(_AFTER_UPDATE_DISPLAY_, HListStartup)
        UpdateDisplay()
        success = Process()
        UnHook(HListStartup)
        Disable(HListKeys)
    else
        Warn("Can't load keydef's- aborting!")
        ExitConfig()
    endif

    if success
        success = GetSelectedItem(HFromLine, HFromLineNum, HFromSpos)
        if not success
            goto GET_CONFIG
        endif
    else
        case YesNo("Abort this configuration?")
            when 1              //yes
                return(_TO_MAIN_MENU)
            when 0, 2, 3        //escape, no, cancel
                goto GET_CONFIG //start over
        endcase
    endif

    Select_string = "End column of 'From:' field data"

    if Enable(HListKeys, _EXCLUSIVE_)
        Hook(_AFTER_UPDATE_DISPLAY_, HListStartup)
        UpdateDisplay()
        success = Process()
        UnHook(HListStartup)
        Disable(HListKeys)
    else
        Warn("Can't load keydef's- aborting!")
        ExitConfig()
    endif

    if success
        success = GetSelectedItem(HFromLine, HFromLineNum, HFromEpos)
        if not success
            goto GET_CONFIG
        endif
    else
        case YesNo("Abort this configuration?")
            when 1              //yes
                return(_TO_MAIN_MENU)
            when 0, 2, 3        //escape, no, cancel
                goto GET_CONFIG //start over
        endcase
    endif

    Select_string = "Start column of 'To:' field data"

    if Enable(HListKeys, _EXCLUSIVE_)
        Hook(_AFTER_UPDATE_DISPLAY_, HListStartup)
        UpdateDisplay()
        success = Process()
        UnHook(HListStartup)
        Disable(HListKeys)
    else
        Warn("Can't load keydef's- aborting!")
        ExitConfig()
    endif

    if success
        success = GetSelectedItem(HToLine, HToLineNum, HToSpos)
        if not success
            goto GET_CONFIG
        endif
    else
        case YesNo("Abort this configuration?")
            when 1              //yes
                return(_TO_MAIN_MENU)
            when 0, 2, 3        //escape, no, cancel
                goto GET_CONFIG //start over
        endcase
    endif

    Select_string = "End column of 'To:' field data"

    if Enable(HListKeys, _EXCLUSIVE_)
        Hook(_AFTER_UPDATE_DISPLAY_, HListStartup)
        UpdateDisplay()
        success = Process()
        UnHook(HListStartup)
        Disable(HListKeys)
    else
        Warn("Can't load keydef's- aborting!")
        ExitConfig()
    endif

    if success
        success = GetSelectedItem(HToLine, HToLineNum, HToEpos)
        if not success
            goto GET_CONFIG
        endif
    else
        case YesNo("Abort this configuration?")
            when 1              //yes
                return(_TO_MAIN_MENU)
            when 0, 2, 3        //escape, no, cancel
                goto GET_CONFIG //start over
        endcase
    endif

    Select_string = "Start column of 'Subject:' field data"

    if Enable(HListKeys, _EXCLUSIVE_)
        Hook(_AFTER_UPDATE_DISPLAY_, HListStartup)
        UpdateDisplay()
        success = Process()
        UnHook(HListStartup)
        Disable(HListKeys)
    else
        Warn("Can't load keydef's- aborting!")
        ExitConfig()
    endif

    if success
        success = GetSelectedItem(HSubjLine, HSubjLineNum, HSubjSpos)
        if not success
            goto GET_CONFIG
        endif
    else
        case YesNo("Abort this configuration?")
            when 1              //yes
                return(_TO_MAIN_MENU)
            when 0, 2, 3        //escape, no, cancel
                goto GET_CONFIG //start over
        endcase
    endif

    Select_string = "End column of 'Subject:' field data"

    if Enable(HListKeys, _EXCLUSIVE_)
        Hook(_AFTER_UPDATE_DISPLAY_, HListStartup)
        UpdateDisplay()
        success = Process()
        UnHook(HListStartup)
        Disable(HListKeys)
    else
        Warn("Can't load keydef's- aborting!")
        ExitConfig()
    endif

    if success
        success = GetSelectedItem(HSubjLine, HSubjLineNum, HSubjEpos)
        if not success
            goto GET_CONFIG
        endif
    else
        case YesNo("Abort this configuration?")
            when 1              //yes
                return(_TO_MAIN_MENU)
            when 0, 2, 3        //escape, no, cancel
                goto GET_CONFIG //start over
        endcase
    endif

    Select_string = "Start column of 'date/time' field data"

    if Enable(HListKeys, _EXCLUSIVE_)
        Hook(_AFTER_UPDATE_DISPLAY_, HListStartup)
        UpdateDisplay()
        success = Process()
        UnHook(HListStartup)
        Disable(HListKeys)
    else
        Warn("Can't load keydef's- aborting!")
        ExitConfig()
    endif

    if success
        success = GetSelectedItem(HDateLine, HDateLineNum, HDateSpos)
        if not success
            goto GET_CONFIG
        endif
    else
        case YesNo("Abort this configuration?")
            when 1              //yes
                return(_TO_MAIN_MENU)
            when 0, 2, 3        //escape, no, cancel
                goto GET_CONFIG //start over
        endcase
    endif

    Select_string = "End column of 'date/time' field data"

    if Enable(HListKeys, _EXCLUSIVE_)
        Hook(_AFTER_UPDATE_DISPLAY_, HListStartup)
        UpdateDisplay()
        success = Process()
        UnHook(HListStartup)
        Disable(HListKeys)
    else
        Warn("Can't load keydef's- aborting!")
        ExitConfig()
    endif

    if success
        success = GetSelectedItem(HDateLine, HDateLineNum, HDateEpos)
        if not success
            goto GET_CONFIG
        endif
    else
        case YesNo("Abort this configuration?")
            when 1              //yes
                return(_TO_MAIN_MENU)
            when 0, 2, 3        //escape, no, cancel
                goto GET_CONFIG //start over
        endcase
    endif

    GET_TAG_ID:
    if not (Ask("Enter unique name (20 char max) for this config: ", HTagName)
            and Length(HTagName))

        case YesNo("Abort this configuration?")
            when 1
                return(_TO_MAIN_MENU)
            when 0, 2, 3
                Goto GET_TAG_ID
        endcase

        HTagName = trim(HTagName)
    endif

    GotoBufferId(new_header_id)
    EndFile()
    AddLine("~~~~~~~~~~")
    AddLine(HTagName)
    AddLine(HFirstLine)
    AddLine(HLastLine)
    AddLine(Str(HLastLineNum - HFirstLineNum))    //offset- last line from startline
    AddLine(HAreaLine)
    AddLine(Str(HAreaLineNum - HFirstLineNum))    //offset- arealine from startline
    AddLine(Str(HAreaSpos))
    AddLine(Str(HAreaEpos))
    AddLine(HFromLine)
    AddLine(Str(HFromLineNum - HFirstLineNum))    //offset- fromline from startline
    AddLine(Str(HFromSpos))
    AddLine(Str(HFromEpos))
    AddLine(HToLine)
    AddLine(Str(HToLineNum - HFirstLineNum))      //offset- toline from startline
    AddLine(Str(HToSpos))
    AddLine(Str(HToEpos))
    AddLine(HSubjLine)
    AddLine(Str(HSubjLineNum - HFirstLineNum))    //offset- subjectline from startline
    AddLine(Str(HSubjSpos))
    AddLine(Str(HSubjEpos))
    AddLine(HDateLine)
    AddLine(Str(HDateLineNum - HFirstLineNum))    //offset- dateline from startline
    AddLine(Str(HDateSpos))
    AddLine(Str(HDateEpos))
    BegFile()
    BegLine()

    if HConfigFileExists
        KillLine()
        InsertLine(HTagName)
    else
        InsertLine(HTagName)
    endif

    success = uSaveFile(Header_fn, _OW)     //save header data

    if not success
        Warn("Error writing to file '", Just_fn, "'- aborting")
        ExitConfig()
    endif

    GotoBufferId(curr_id)
    Return(_TO_MAIN_MENU)

end

/**************************************************************************
                integer proc _InsertFile(string fn)
 **************************************************************************/
integer proc uInsertFile(string fn)
    integer level, success
    level = Set(MsgLevel, _NONE_)
    success = InsertFile(fn)
    UnmarkBlock()
    Set(MsgLevel, level)
    return (success)
end

/**************************************************************************
                    integer proc GetSelectedItem()
 **************************************************************************/
integer proc GetSelectedItem(var string line, var integer linenum,
                             var integer hpos)
integer id

    id = GotoBufferId(curr_id)
    line = ""
    linenum = CurrLine()
    hpos = CurrPos()
    line = GetText(1, CurrLineLen())

    GotoBufferId(id)
    return(1)
end

/**************************************************************************
                        integer proc ExitConfig()
 **************************************************************************/
integer proc ExitConfig()

    GotoBufferId(curr_id)
    Disable(HListKeys)
    Set(AutoIndent, OldIndent)
    Set(Insert, OldInsert)
    Set(LeftMargin, OldLMarg)
    Set(ParaEndStyle, OldPara)
    Set(RemoveTrailingWhite, OldRemWh)
    Set(ReturnEqNextLine, OldRet)
    Set(RightMargin, OldRMarg)
    Set(WordWrap, OldWrap)
    Set(InsertLineBlocksAbove, OldInsLB)
    Set(ShowHelpLine, OldShowHelp)
    PurgeMacro(CurrMacroFilename())
    return(_EXIT)
end

/**************************************************************************
                integer proc uSaveFile(Header_fn, how)
 **************************************************************************/
integer proc uSaveFile(var string fn, integer how)
integer success = 0, eof_type, level

    eof_type = Set(EOFType, _NONE_)
    level = Set(MsgLevel, _NONE_)
    success = SaveAs(fn, how)
    Set(MsgLevel, level)
    Set(EOFType, eof_type)
    return (success)
end

/**************************************************************************
                    integer proc WhenLoaded()
 **************************************************************************/
/*proc WhenLoaded()
    Set(Break, ON)
end*/

/**************************************************************************
                    integer proc WhenPurged()
 **************************************************************************/
proc WhenPurged()

    AbandonFile(new_header_id)
end

/**************************************************************************
 memory error routine
                        integer proc MemError()
 **************************************************************************/
integer proc MemError()
    Warn("Insufficient Memory Error!")
    GotoBufferId(curr_id)
    Disable(HListKeys)
    Set(AutoIndent, OldIndent)
    Set(Insert, OldInsert)
    Set(LeftMargin, OldLMarg)
    Set(ParaEndStyle, OldPara)
    Set(RemoveTrailingWhite, OldRemWh)
    Set(ReturnEqNextLine, OldRet)
    Set(RightMargin, OldRMarg)
    Set(WordWrap, OldWrap)
    Set(InsertLineBlocksAbove, OldInsLB)
    Set(ShowHelpLine, OldShowHelp)
    PurgeMacro(CurrMacroFilename())
    return(_EXIT)
end

/**************************************************************************
 Stuff for online help
 **************************************************************************/
HelpDef HListKeysHelp
    title = "   Header Configuration Help   "
    x = 23
    y = 2

    "<Enter>      Mark character (or line) requested       "
    ""
    "<Escape>     Exit/abort                               "
    ""
    ""
    "The item needed will be listed on the bottom line of  "
    "the screen. If a whole line is requested, just move   "
    "the cursor to the appropriate line and press <Enter>. "
    "If the requested item is a field, place the cursor at "
    "the start/end of the field and press <Enter>.         "
    ""
    "NOTE: when the start or end of a specific field is    "
    "requested, select the first/last character of the     "
    "field *data* not including any header info- ex: if    "
    "'Start From: Field' is requested, select the first    "
    "character of the contributors name, not the word      "
    "'from'. For the ending column, select a position which"
    "will be long enough to accomodate the longest expected"
    "data field width. This may be several columns past the"
    "end of the displayed field data.                      "
    ""
    "After the last required entry is made, you will be    "
    "prompted to enter a 'unique name (20 char max) for    "
    "this config: '. This name should be a single word     "
    "which describes the message area just configured. For "
    "example, I use: 'GECooking' for GoldED, Cooking area, "
    "'GEHomeCooking' for GoldED, Home_Cooking area,        "
    "'BWCooking' for Blue Wave Cooking area, etc.          "
    ""
end

proc HelpHook()
    BreakHookChain()
end

proc HelpOnHListKeys()
    if Hook(_LIST_STARTUP_, HelpHook)
        QuickHelp(HListKeysHelp)
        UnHook(HelpHook)
        UpdateDisplay(_HELPLINE_REFRESH_)
    endif
end

keydef HListKeys
    <F1>                    HelpOnHListKeys()
    <Escape>                EndProcess(HlistESCAPE)
    <CenterBtn>             EndProcess(HlistENTER)
    <LeftBtn>               EndProcess(HlistENTER)
    <RightBtn>              EndProcess(HlistENTER)
    <Enter>                 EndProcess(HlistENTER)
    <GreyEnter>             EndProcess(HlistENTER)
    <CursorRight>           Right()
    <GreyCursorRight>       Right()
    <Ctrl CursorRight>      WordRight()
    <Ctrl GreyCursorRight>  WordRight()
    <CursorLeft>            Left()
    <GreyCursorLeft>        Left()
    <Ctrl CursorLeft>       WordLeft()
    <Ctrl GreyCursorLeft>   WordLeft()
    <CursorUp>              Up()
    <GreyCursorUp>          Up()
    <Ctrl CursorUp>         RollUp()
    <Ctrl GreyCursorUp>     RollUp()
    <CursorDown>            Down()
    <GreyCursorDown>        Down()
    <Ctrl CursorDown>       RollDown()
    <Ctrl GreyCursorDown>   RollDown()
    <Home>                  BegLine()
    <GreyHome>              BegLine()
    <Ctrl Home>             BegWindow()
    <Ctrl GreyHome>         BegWindow()
    <End>                   EndLine()
    <GreyEnd>               EndLine()
    <Ctrl End>              EndWindow()
    <Ctrl GreyEnd>          EndWindow()
    <PgUp>                  PageUp()
    <GreyPgUp>              PageUp()
    <Ctrl PgUp>             BegFile()
    <Ctrl GreyPgUp>         BegFile()
    <PgDn>                  PageDown()
    <GreyPgDn>              PageDown()
    <Ctrl PgDn>             EndFile()
    <Ctrl GreyPgDn>         EndFile()
end

/**************************************************************************
                        proc HListStartup()
 **************************************************************************/
proc HListStartup()
    string hstring[80] = ""
    integer oldx, oldy, hlen

        hstring = "          Select: " + Select_string
        hlen = Length(hstring)
        hstring = Format(hstring : -(hlen), "[F1]-Help   " : (80 - hlen))
        hstring = Format(hstring : 80)
        oldx = WhereXAbs()
        oldy = WhereYAbs()
        VGotoXYAbs(1, Query(ScreenRows))
        PutHelpLine(hstring)
        VGotoXYAbs(oldx, oldy)
        BreakHookChain()
end

/**************************************************************************
                                 Menu
 **************************************************************************/
menu Config_Header()
    x = 1
    y = 2
    title = "Configure Header Info"
    "&New Configuration",           GetNewHeader(),,        "Configure a new message reader/area"
    "&Exit Configuration Utility",   ExitConfig(),,          "Exit the header configuration utility"

end Config_Header
