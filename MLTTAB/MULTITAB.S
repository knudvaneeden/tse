/******************************************************************************

    MULTITAB: per-file/type tab settings for TSE V2.0
    Version 0.5 beta

    Bound to <Ctrl O><Tab>

    G‚ Weijers 03-DEC-94

******************************************************************************/

integer CurrentBufferID = 0                 //  current file buffer ID

integer DefaultTabwidth = 8                 //  default tab width
integer DefaultWordwrap = FALSE             //  default word wrap setting
integer DefaultTabType = _SOFT_             //  default tab type
integer DefaultIndentType = ON              //  default indent mode
integer DefaultRightMargin = 72             //  default right margin
integer DefaultLeftMargin = 0               //  default left margin

//
//  all settings for one buffer are stored in one global editor variable per
//  buffer to conserve variable space. Some shifting and masking has to be done
//  to achieve that
//

//  variable name
string proc VARN (integer id)
    return ("MT_" + Str(id))
end

//  bit field shifting
integer proc GetField (integer v, integer off, integer wid)
    return ((v shr off) & ((1 shl wid)-1))
end

integer proc SetField (integer v, integer off, integer wid)
    return ((v & ((1 shl wid)-1)) shl off)
end

//
//  coding of tab types
//
integer proc GetTabCode()
    integer t = 0
    case Query(TabType)
        when _HARD_
            t = 0
        when _SOFT_
            t = 1
        when _SMART_
            t = 2
        when _VARIABLE_
            t = 3
    endcase
    return (t)
end

proc SetTabCode(integer t)
    case t
        when 1
            t = _SOFT_
        when 2
            t = _SMART_
        when 3
            t = _VARIABLE_
        otherwise
            t = _HARD_
    endcase
    Set(TabType, t)
end

//
//  coding of indent modes
//
integer proc GetIndentCode()
    integer t = 0
    case Query(AutoIndent)
        when OFF
            t = 0
        when ON
            t = 1
        when _STICKY_
            t = 2
    endcase
    return (t)
end

proc SetIndentCode(integer t)
    case t
        when 1
            t = ON
        when 2
            t = _STICKY_
        otherwise
            t = OFF
    endcase
    Set(AutoIndent, t)
end

//
//  save settings for buffer
//

integer proc Encode_Settings ()
    return ( SetField(Query(WordWrap), 0, 1)
             | SetField(Query(TabWidth), 1, 5)
             | SetField(GetTabCode(), 6, 2)
             | SetField(GetIndentCode (), 8, 2)
             | SetField(Query(RightMargin), 10, 10)
             | SetField(Query(LeftMargin), 20, 10) )
end

proc Save_Settings (integer id)
    SetGlobalInt(VARN(id), Encode_Settings ())
end

//
//  retrieve settings for buffer
//
proc Decode_Settings (integer v)
    Set(WordWrap, GetField(v, 0, 1))
    Set(TabWidth, GetField(v, 1, 5))
    SetTabCode(GetField(v, 6, 2))
    SetIndentCode(GetField(v, 8, 2))
    Set(RightMargin, GetField(v, 10, 10))
    Set(LeftMargin, GetField(v, 20, 10))
end

proc Retrieve_Settings (integer id)
    Decode_Settings(GetGlobalInt(VARN(id)))
end

//
//  current file's extension
//
string proc CurrExt()
    return (SplitPath(CurrFilename(), _EXT_))
end

forward proc Init_Settings ()

//
//  changing files hook
//
proc OnChangingFiles ()
    integer currbufferid = GetBufferId()
    Save_Settings (CurrentBufferID)

    if BufferType () == _NORMAL_
        Retrieve_Settings (currbufferid)
        CurrentBufferID = currbufferid
    endif
end

//
//  new files hook
//
proc OnFirstEdit ()
    integer currbufferid = GetBufferId()
    Save_Settings (CurrentBufferID)

    if BufferType() == _NORMAL_
        Init_Settings ()
        CurrentBufferID = currbufferid
    endif
end

//
//  in case this macro file is loaded after files were opened the variables
//  have to be initialised
//
proc initExistingBuffers ()
    integer nbuf = NumFiles ()

    integer curr = GetBufferID ()

    if BufferType () <> _NORMAL_
        nbuf = nbuf + 1
    endif

    while nbuf > 0
        nbuf = nbuf - 1
        if BufferType () == _NORMAL_
            Save_Settings(GetBufferID())
        endif

        if not NextFile(_DONT_LOAD_)
            break
        endif

    endwhile
    GotoBufferID(curr)
end

integer lookupBuffer = 0

string proc GetLookupTableName ()
    return (SplitPath(CurrMacroFileName(), _DRIVE_ | _NAME_) + ".cfg")
end

datadef InitLookup
"// MULTITAB config file, EDIT WITH CARE"
end

proc InitLookupTable ()
    integer cur = GetBufferID ()
    string fn[80] = GetLookupTableName()
    PushPosition ()
    PushBlock()
    lookupBuffer = CreateBuffer("*MULTITAB*", _SYSTEM_)
    if lookupBuffer
        Save_Settings(lookupBuffer)
        if FileExists(fn) and InsertFile(fn)
            FileChanged(FALSE)
        else
            InsertData(InitLookup)
            FileChanged(FALSE)
        endif
        GotoBufferID(cur)
    endif
    PopBlock()
    PopPosition ()
end

integer proc GetLookup (string ext)
    integer r = -1
    string s[20] = ""
    integer cur = GetBufferID()
    PushPosition ()
    PushBlock ()
    if lookupBuffer
        GotoBufferID(lookupBuffer)
        if lFind(ext + "=", "^gi")
            s = GetText(1,999)
            s = SubStr(s,Pos("=",s)+1,999)
            r = Val(s,16)
        endif
        GotoBufferID(cur)
    endif
    PopBlock ()
    PopPosition ()
    return (r)
end

proc SetLookup (string ext, integer v)
    integer cur = GetBufferID()
    PushPosition ()
    PushBlock ()
    if lookupBuffer
        GotoBufferID(lookupBuffer)
        if lFind(ext + "=", "^gi")
            KillLine()
        endif
        AddLine(Format(ext, '=', Str(v,16):8:"0"))
        if FileChanged()
            SaveAs(GetLookupTableName(), _OVERWRITE_)
        endif
        GotoBufferID(cur)
    endif
    PopBlock ()
    PopPosition ()
end

proc DeleteLookupTable ()
    AbandonFile(lookupBuffer)
end

//
//  Init
//
proc whenLoaded ()
    DefaultTabwidth = Query(TabWidth)
    DefaultWordwrap = Query(WordWrap)
    DefaultTabType = Query(TabType)
    DefaultIndentType = Query(AutoIndent)
    DefaultRightMargin = Query(RightMargin)
    DefaultLeftMargin = Query(LeftMargin)
    InitExistingBuffers ()
    Hook(_ON_CHANGING_FILES_, OnChangingFiles)
    Hook(_ON_FIRST_EDIT_, OnFirstEdit)
    InitLookupTable()
end

//
//  Restore to original settings after purge
//
proc whenPurged ()
    DeleteLookupTable()
    Set(TabWidth, DefaultTabwidth)
    Set(WordWrap, DefaultWordwrap)
    Set(TabType, DefaultTabType)
    Set(AutoIndent, DefaultIndentType)
    Set(RightMargin, DefaultRightMargin)
    Set(LeftMargin, DefaultLeftMargin)
end

//
//  enable/disable autoloading
//
proc AutoLoad(integer add)
    string fn[128]

    fn = CurrMacroFileName()
    if add
        AddAutoLoadMacro(fn)
    else
        DelAutoLoadMacro(fn)
    endif
end

//
//  Some rudimentary help
//
helpdef AboutHelp
    y = 2
   " MULTITAB implements separate tab settings for every file edited. "
   " Different defaults can be set for every file type. "
   " The affected settings are:"
   "     Tab Width "
   "     Tab Type "
   "     Auto Indent mode "
   "     Word Wrap "
   "     Right Margin "
   "     Left Margin "
   ""
   " The program implements a menu to alter the tab settings, but the "
   " Options menu will work as well. "
   ""
   " Author: G‚ Weijers. Placed in public domain. "
end

//
//  helper to edit number in a menu
//
integer proc ReadNum (integer v)
    string s[8] = Str(v)
    if Read(s)
        return (Val(s))
    endif
    return (v)
end

//
//  decode tab type to string
//
string proc GetTabType()
    string t[10] = "???"
    case Query(TabType)
        when _HARD_
            t = "Hard"
        when _SOFT_
            t = "Soft"
        when _SMART_
            t = "Smart"
        when _VARIABLE_
            t = "Variable"
    endcase
    return (t)
end

//
//  switch to next tab type
//
proc NextTabType ()
    SetTabCode(GetTabCode()+1)
end

//
//  decode indent mode to string
//
string proc GetIndentType()
    string t[10] = "???"
    case Query(AutoIndent)
        when OFF
            t = "Off"
        when ON
            t = "On"
        when _STICKY_
            t = "Sticky"
    endcase
    return (t)
end

//
//  switch to next indent mode
//
proc NextIndentType ()
    SetIndentCode(GetIndentCode()+1)
end

proc SaveDefSettings ()
    if BufferType () == _NORMAL_
        SetLookup(CurrExt(), Encode_Settings())
    endif
end

Menu TabMenu()
    Title = "MULTITAB"
    history = 1
    "Tab &Width:" [Query(TabWidth): 5],
        Set(TabWidth,ReadNum(Query(TabWidth))),
        DontClose,
        "Alter tab setting"
    "&Word wrap"    [iif(Query(WordWrap),"Yes","No"):5],
        Toggle(WordWrap),
        DontClose,
        "Toggle word wrap"
    "&Right margin:" [Query(RightMargin): 5],
        Set(RightMargin,ReadNum(Query(RightMargin))),
        DontClose,
        "Set right margin"
    "&Left margin:" [Query(LeftMargin): 5],
        Set(LeftMargin,ReadNum(Query(LeftMargin))),
        DontClose,
        "Set left margin"
    "Tab &Type:" [GetTabType(): 8],
        NextTabType (),
        DontClose,
        "Set tabulator type"
    "&Auto Indent:" [GetIndentType(): 8],
        NextIndentType (),
        DontClose,
        "Set indent mode"
    "",
        ,
        Divide
    "Set as &Default for type " [CurrExt(): 4],
        SaveDefSettings(),
        ,
        "Save settings for file type"
    "&Undo changes",
        Retrieve_Settings(0),
        CloseAfter,
        "Restore settings"
    "",
        ,
        Divide
    "Abou&t MULTITAB...",
        QuickHelp (AboutHelp),
        DontClose,
        "Show credits"
end

proc RunTabMenu ()
    Save_Settings(0)
    TabMenu ()
end

Menu InstallMenu()
    Title = "MULTITAB Install"
    "&Add MULTITAB to AutoLoad list",
        AutoLoad(TRUE),
        CloseAfter
    "&Remove MULTITAB from AutoLoad list",
        AutoLoad(FALSE),
        CloseAfter
    "",
        ,
        Divide
    "&Change tab settings    ",
        RunTabMenu (),
        DontClose
    "",
        ,
        Divide
    "Abou&t MULTITAB...",
        QuickHelp (AboutHelp),
        DontClose
end

//
//  run install menu
//
proc Main ()
    InstallMenu()
end

proc Init_Settings ()
    integer currbufferid = GetBufferID ()
    integer code = -1

    if BufferType() == _NORMAL_
        code = GetLookup(CurrExt())
        if code <> -1
            Decode_Settings(code)
            return ()
        endif

        Set(WordWrap, DefaultWordWrap)
        Set(TabWidth, DefaultTabWidth)
        Set(TabType, DefaultTabType)
        Set(AutoIndent, DefaultIndentType)
        Set(LeftMargin, DefaultLeftMargin)
        Set(RightMargin, DefaultRightMargin)

        CurrentBufferID = currbufferid
    endif
end

//
//  key
//
<Ctrl o><Tab>       RunTabMenu ()


