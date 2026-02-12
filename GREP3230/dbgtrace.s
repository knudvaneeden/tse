/****************************************************************************\

    DbgTrace.S

    Debugging tool: Tracing macros.

    Version         v2.10/30.11.00
    Copyright       (c) 1996-1999 by DiK

    History

    v2.10/30.11.00  no changes
    v2.02/07.01.99  enhancements and fixes
                    added querying of TracePointKey
                    added dynamic computation of TracePointStackSize
                    fixed TracePointKey (0xFFFF didn't work anymore)
    v2.01/02.04.97  no changes
    v2.00/24.10.96  first version

\****************************************************************************/

/****************************************************************************\
    user definable constants
\****************************************************************************/

constant TraceMenuKey = <CtrlShift F12>

/****************************************************************************\
    tracing constants (!DO NOT CHANGE!)
\****************************************************************************/

constant TracePointKey = 0xFFFE
string DbgTraceArgs[] = "DbgTraceArgs"

/****************************************************************************\
    global variables
\****************************************************************************/

integer TracePointStackSize             // stack size of trace point routine

integer trace_list                      // buffer id: execution trace
integer trace_char                      // flag: trace specific column
integer trace_name                      // flag: trace names of buffers
integer trace_save                      // flag: allways save trace list

/****************************************************************************\
    trace functions
\****************************************************************************/

public proc GetTracePointKey()
    Set(MacroCmdLine,Str(TracePointKey))
end

public proc SetTraceCharPos()
    trace_char = Val(Query(MacroCmdLine))
end

public proc TraceBufferNameOn()
    trace_name = TRUE
end

public proc TraceBufferNameOff()
    trace_name = FALSE
end

public proc TraceSaveOn()
    trace_save = TRUE
end

public proc TraceSaveOff()
    trace_save = FALSE
end

public proc TraceStart()
    integer bid = GetBufferId()

    trace_list = EditFile("dbgtrace.lst")
    if trace_list
        EmptyBuffer()
        BufferType(_HIDDEN_)
    else
        Warn("DbgTrace: Cannot allocate trace buffer.")
        PurgeMacro(CurrMacroFilename())
    endif
    GotoBufferId(bid)
end

public proc TraceStop()
    integer bid = GetBufferId()

    if GotoBufferId(trace_list)
        BufferType(_NORMAL_)
        SaveFile()
        BegFile()
        GotoBufferId(bid)
    endif
end

public proc ShowTrace()
    TraceStop()
    EditFile("dbgtrace.lst")
end

integer proc TracePoint()
    integer stack = MacroStackAvail() - TracePointStackSize
    integer bid = GetBufferId()
    integer c = iif( trace_char, CurrChar(trace_char), CurrChar() )
    integer x = CurrPos()
    integer y = CurrLine()
    string name[32] = SplitPath(CurrFilename(),_NAME_|_EXT_)

    if GotoBufferId(trace_list)
        EndFile()
        BegLine()
        AddLine(Format(
            stack:6,
            bid:6,
            y:6,x:6,
            c:6,iif( c > 31, Chr(c), "" ):2,
            iif( trace_name, Format("":4,name:-32), "" ),
            "":4,
            GetGlobalStr(DbgTraceArgs)
        ))
        if trace_save
            SaveFile()
        endif
        GotoBufferId(bid)
    endif

    return(MacroStackAvail())
end

/****************************************************************************\
    start up and shut down
\****************************************************************************/

proc WhenLoaded()
    TraceStart()
    TracePointStackSize = MacroStackAvail() - TracePoint()
    TraceStart()
end

proc WhenPurged()
    TraceStop()
    DelGlobalVar(DbgTraceArgs)
end

/****************************************************************************\
    editing utility
\****************************************************************************/

proc InsertTracePoint()
    string desc[80], name[80] = ""

    PushPosition()
    if lFind("^{{public}|{integer}|{string} #proc}|{proc} #{.@}(","bx")
        PushBlock()
        MarkFoundText(6)
        name = GetMarkedText() + ": "
        PopBlock()
    endif
    PopPosition()
    PushPosition()
    if Pos("'",name)
        Warn("Single quotes not allowed in description of trace point.")
    else
        desc = name
        if Ask("Description of trace point:",desc)
            if desc == name
                desc = desc[1..Length(desc)-2]
            endif
            BegLine()
            InsertLine(Format("PressKey(0x",TracePointKey:4:"0":16,")"))
            InsertLine("SetGlobalStr('DbgTraceArgs','TracePoint "+desc+"')")
        endif
    endif
    PopPosition()
end

/****************************************************************************\
    user interface
\****************************************************************************/

menu TraceMenu()
    "&Begin Trace",         TraceStart()
    "&End Trace",           TraceStop()
    "",,    Divide
    "&Show Trace",          ShowTrace()
    "",,    Divide
    "&Add Trace Point",     InsertTracePoint()
end

<TraceMenuKey>      TraceMenu()
<TracePointKey>     TracePoint()

/****************************************************************************\
    main program
\****************************************************************************/

proc main()
    Message("Trace module loaded")
end

