/* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ÚÄÙ TSE Structured Text Viewer ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                          ³
 ³ SOFTWARE:    TextView.s                                                  ³
 ³ VERSION:     1.10                                                        ³
 ³ DATE:        07/11/95 08:22 am                                           ³
 ³ REV. DATE:   10/17/95 03:57 pm                                           ³
 ³ AUTHOR:      Mike Chambers                                               ³
 ³ TYPE:        External Macro                                              ³
 ³                                                                          ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Revision History ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                                                                          ³
 ³ REV. HIST:                                                               ³
 ³              1.00 Released for TSE Pro 2.5                               ³
 ³              1.10 Added features to support untagged multifile sources   ³
 ³                                                                          ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Installation & Usage ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                                                                          ³
 ³ TextView is a full-text search and retrieval tool for text files which   ³
 ³ contain a repeated discernible structure.  The tool takes advantage of   ³
 ³ TSE large file and virtual memory capability to allow rapid access to    ³
 ³ a user definable set of text resources.  Examples of common text         ³
 ³ resources include: Ralf Brown's DOS Interrupt List; Tom Klein's          ³
 ³ TSE Tip files; various *.DOC files;  BBS 'Allfiles' listings, etc.       ³
 ³                                                                          ³
 ³ USAGE:  Invoke TextView using  <Ctrl Ins>.  Upon first execution,        ³
 ³ TextView will prompt you to select the  resource you wish to search.     ³
 ³ Highlight the desired resource using the cursor keys and press enter.    ³
 ³ You will then be prompted to supply a search expression and search       ³
 ³ options.  TextView will produce a list of Titled topics containing       ³
 ³ the search expression.  Use the cursor keys to select a topic and        ³
 ³ press enter.  The topic text will be displayed in a work buffer which    ³
 ³ may be edited freely.  Press escape to return to the topic list and      ³
 ³ escape from their to return to your original buffer.  The text of the    ³
 ³ last topic will be stored on your clipboard for easy pasting into your   ³
 ³ current edit session.                                                    ³
 ³                                                                          ³
 ³ The default word will be the word at the cursor location; however,       ³
 ³ TextView maintains a keyword search history which you may choose from.   ³
 ³ To see all list of all topics in a resource, press the space bar to      ³
 ³ answer 'blank' or null to the Search Expression prompt.                  ³
 ³                                                                          ³
 ³ Refer to TEXTVIEW.DOC for more information on configuration & usage.     ³
 ³                                                                          ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Notes ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                                                                          ³
 ³ Portions of this work are derived from copyrighted material and are      ³
 ³ used in accordance with the copyright holder provisions outlined below:  ³
 ³                                                                          ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Copyright Notice ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                                                                          ³
 ³ Copyright 1992-1994 SemWare Corporation.  All Rights Reserved Worldwide. ³
 ³                                                                          ³
 ³ Use, modification, and distribution of this SAL macro is encouraged by   ³
 ³ SemWare provided that this statement, including the above copyright      ³
 ³ notice, is not removed; and provided that no fee or other remuneration   ³
 ³ is received for distribution.  You may add your own copyright notice     ³
 ³ to cover new matter you add to the macro, but SemWare Corporation will   ³
 ³ neither support nor assume legal responsibility for any material added   ³
 ³ or any changes made to the macro.                                        ³
 ³                                                                          ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

constant NewSearch      = 0
constant OldSearch      = 1
constant ADD_RECORD     =   1,
         COPY_RECORD    =   2,
         DELETE_RECORD  =   3

string Search_buffer_name[] = "[<Search>]"
string Topic_buffer_name[]= "[<Topic>]"
string Search_message[] = " {Enter} - View Topic    {Escape} - Cancel    "
integer Search_hist, width
integer Search_id, Text_id, vid, Topic_id, original_id
string expression[100], options[12]

string data_fn[]    = "textview.dat"

integer  data_id, work_id

string full_data_fn[80]
integer new_file

// data for Resource records
string EyeCatcher[] = "TextView Resource config file"
string  tag[9]
string  descr[64]
string  Separator[64]
string  TextFileName[64]
string  sDeltaToTitle[3]
string  sDeltaToTop[3]
integer DeltaToBottom
integer DeltaToTitle

constant LIST_WIDTH = sizeof(descr) + sizeof(tag) + 2

integer Resource_start, Resource_end
integer num_Resources
integer exec_Resource_done

proc SetXY()
    Set(x1,WhereXAbs())
    Set(y1,WhereYAbs())
end


integer proc _InsertFile(string fn)
    integer level, success
    level = Set(MsgLevel, _NONE_)
    success = InsertFile(fn)
    Set(MsgLevel, level)
    return (success)
end


proc ReadLn(var string s)
    s = GetText(1,CurrLineLen())
    Down()
end


proc ReadRecord()
    integer id
    string s[10]=''
    id = GotoBufferId(data_id)

    Resource_start = CurrLine()


    readln(tag)
    readln(TextFileName)
    readln(descr)
    readln(Separator)
    readln(sDeltaToTitle)
    readln(sDeltaToTop)
    if Separator <> ''
       DeltaToTitle = val(sDeltaToTitle)
       DeltaToBottom = val(sDeltaToTop)
    else
       Separator     = '^şşşş '
       sDeltaToTitle = '0'
       DeltaToTitle  = 0
       sDeltatoTop = '-1'
       DeltatoBottom = -1
    endif
    readln(s)

    tag = substr(tag,2,sizeof(tag))

    Resource_end = CurrLine()
    GotoLine(Resource_start)

    GotoBufferId(id)
end


proc WriteLn(string s)
    // only write if line changed so FileChanged() is accurate

    if GetText(1,CurrLineLen()) <> s
        BegLine()
        KillToEol()
        InsertText(s)
    endif
    if not Down()
        AddLine()
    endif
    BegLine()
end


proc SaveResourceData()
    integer id, level, eoltype

    level = Set(MsgLevel, _NONE_)

    eoltype = Set(EOLType, 2)
    id = GotoBufferId(data_id)
    if FileChanged()
        if new_file
            SetXY()
            if YesNo("Create setup file: '"+full_data_fn+"'") == 1
                BegFile()
                InsertLine(EyeCatcher)
                if SaveAs(full_data_fn, _OVERWRITE_)
                    new_file = FALSE
                endif
            endif
        else
            SaveAs(full_data_fn, _OVERWRITE_)
        endif
    endif
    Set(EOLType, eoltype)

    Set(MsgLevel, level)
    GotoBufferId(id)
end


proc WriteRecord()
    integer id

    id = GotoBufferId(data_id)

    WriteLn(''+tag)
    WriteLn(TextFileName)
    Writeln(descr)
    WriteLn(Separator)
    WriteLn(sDeltaToTitle)
    WriteLn(sDeltaToTop)
    WriteLn('')

    GotoBufferId(id)
end


proc GenerateResourceList()
    integer line, level

    EmptyBuffer(work_id)

    GotoBufferId(data_id)
    PushPosition()

    num_Resources = 0

    if not lFind('','^g')
        Addline("        No Structured Text Resources configured", work_id)
    else
        repeat
            line = CurrLine()
            ReadRecord()
            AddLine(format(iif(GetBufferId(tag),'',' '),tag:-10,descr:-sizeof(descr),line:4), work_id)
            num_Resources = num_Resources + 1
        until not lRepeatFind()
    endif

    PopPosition()

    GotoBufferId(work_id)
    MarkColumn(1,11,NumLines(),70)
    level = Set(MsgLevel, _NONE_)
    Sort(_IGNORE_CASE_)
    Set(MsgLevel, level)
    MarkColumn(1,1,NumLines(),LIST_WIDTH)
end

integer proc InsertFiles (string filename)

    string  path[128] = '',  dta[80] = '',   s[80]

            path = splitpath(filename, _drive_ | _path_)
            SetDTA(dta)
            if FindFirst(filename)
                repeat
                    s = DecodeDTA(dta)
                    addline(format('şşşş ',path,s[2:13]))
                    EndFile()
                    creturn()
                    pushBlock()
                    if not insertfile(path+s[2:13])
                       popblock()
                       return(false)
                    endif
                    popblock()
                    SetDTA(dta)
                until not FindNext()
            else
                return(false)
            endif
            return(true)
end


integer proc OpenResource(string tag)
    string  temp_fn[128]=''

    // if no filename specified in resource config, prompt user for it
       if TextFileName == ''
           askfilename(format('Enter (',tag,') filename:'),Temp_fn,
                         (_full_path_ | _must_exist_) )
           if trim(temp_fn) == '' return(false)  endif
       else
           temp_fn = TextFileName
       endif

    // If text buffer exists, use it;  if not, create and insert the
    // TextFileName into it.
       Text_id = CreateBuffer(Tag,_hidden_)
       if Text_id == 0
           Text_id = GetBufferId(Tag)
       endif
       if Text_id == 0 or not GotoBufferId(Text_id)
           return (false)
       endif
       if NumLines() < 2
          if not InsertFiles(temp_fn)
               Warn(' Text File (',TextFileName,')',' not found')
          endif
       endif
       BegFile()
       width = Length(Str(NumLines()))
       return(true)
end


proc CloseResource(string tagname)
    if GetBufferId(trim(tagname))
       abandonfile(GetBufferId(trim(tagname)))
    endif
end


menu ResourceSetupMenu()
    Title = 'Configure Text Resource'

    "&Tag          " [format(tag:-8):-8]           ,
                    Read(tag)      , DontClose     ,
                    "A brief designator for the reference resource"
    "&File Name    " [format(TextFileName:-60):-60]  ,
                    AskFileName('',TextFileName, _full_path_ | _must_exist_), DontClose,
                    "Full path name of the file containing the reference resource"
    "&Description  " [format(descr:-60):-60]       ,
                    Read(Descr)      , DontClose,
                    "Description of the reference resource"
    "&Separator    " [format(Separator:-60):-60]   ,
                    Read(Separator)      , DontClose,
                    "Regular Expression Pattern separating topics in the resource"
    "DeltaToT&itle " [format(sDeltaToTitle:-3):-3] ,
                    ReadNumeric(sDeltaToTitle)      , DontClose,
                    "Number of lines from the separator to a topic title"
    "DeltaTo&Bottom" [format(sDeltaToTop:-3):-3]   ,
                    ReadNumeric(sDeltaToTop)      , DontClose,
                    "Number of lines from the separator to end of previous topic"
end


proc ReadRecordFromList(integer flag)
    integer n = Val(GetText(LIST_WIDTH + 1,8))

    GotoBufferId(data_id)
    GotoLine(iif(flag == ADD_RECORD, NumLines(), n))
    ReadRecord()
end


proc EditResourceCommon(integer flag)
    integer id

    id = GetBufferId()

    ReadRecordFromList(flag)

    SetXY()
    if flag == DELETE_RECORD
        if YesNo("Delete "+descr+"?") == 1
            PushBlock()
            MarkLine(Resource_start, Resource_end)
            KillBlock()
            PopBlock()
        endif
    else
        ResourceSetupMenu()
        if length(tag)
            if flag == COPY_RECORD
                GotoLine(NumLines())
            endif
            WriteRecord()
        endif
    endif

    SaveResourceData()

    GotoBufferId(id)

    EndProcess()
end


proc EditResource()
    EditResourceCommon(0)
end


proc AddResource()
    EditResourceCommon(ADD_RECORD)
end


proc DelResource()
    if num_Resources
        EditResourceCommon(DELETE_RECORD)
    endif
end


proc CopyResource()
    EditResourceCommon(COPY_RECORD)
end


KeyDef ExecResourceKeys
    <Enter>     exec_Resource_done = 1        EndProcess(TRUE)
    <Escape>    exec_Resource_done = -1       EndProcess(TRUE)
    <Ins>       AddResource()
    <GreyIns>   AddResource()
    <Del>       DelResource()
    <GreyDel>   DelResource()
    <Alt E>     EditResource()
    <Alt C>     CopyResource()
    <End>       CloseResource(gettext(2,sizeof(tag))) GenerateResourceList()
end


proc ExecResourceHook()
    if Enable(ExecResourceKeys)
        WindowFooter("{Ins}-Add {Del}-Delete {End}-Close {Alt C}-Copy {Alt E}-Edit")
    endif
end


integer proc SelectResource()
    integer id, exec = FALSE
    string keyword[48] = tag

    id = GotoBufferId(data_id)

    PushBlock()

    exec_Resource_done = 0
    repeat
        GenerateResourceList()
        BegFile()
        lFind(keyword,"")
        Hook(_LIST_STARTUP_,ExecResourceHook)
        Set(Y1, 3)
        lList("Select Resource", LIST_WIDTH, Query(ScreenRows), _ENABLE_SEARCH_ | _BLOCK_SEARCH_)
        UnHook(ExecResourceHook)
        keyword = descr
    until exec_Resource_done
    if exec_Resource_done == 1
        ReadRecordFromList(0)
        exec = TRUE
    endif

    PopBlock()

    GotoBufferId(id)
    return (exec)
end


integer proc SetupResourceFiles()
    integer id

    full_data_fn = SplitPath(CurrMacroFileName(), _DRIVE_ | _PATH_) + data_fn
    if not FileExists(full_data_fn)
        full_data_fn = SearchPath(data_fn, Query(TSEPath), "mac")
    endif
    if full_data_fn == ""
        new_file = TRUE
        full_data_fn = data_fn
    endif

    id = GetBufferId()

    work_id  = CreateTempBuffer()
    data_id  = CreateTempBuffer()

    if data_id and not new_file
        PushBlock()
        _InsertFile(full_data_fn)
        PopBlock()
        BegFile()
    endif
    EndFile()
    if CurrLineLen()
        AddLine()   // make sure there's at least 1 blank line at end
    endif

    FileChanged(FALSE)
    GotoBufferId(id)
    return (data_id)
end


proc WhenLoaded()
    integer save_id = GetBufferId()

    if not SetupResourceFiles()
        PurgeMacro(CurrMacroFileName())
    endif

    Search_hist = GetFreeHistory ("Search")

    // If Topic buffer exists, use it;  if not, create it
       Topic_id = CreateBuffer(Topic_buffer_name,_hidden_)
       if Topic_id == 0
           Topic_id = GetBufferId(Topic_buffer_name)
       endif

    // If our result buffer is there, use it; if not, create it.
       Search_id = CreateBuffer(Search_buffer_name,_hidden_)
       if Search_id == 0
           Search_id = GetBufferId(Search_buffer_name)
       endif

       gotobufferid(save_id)

end


proc WhenPurged()
    integer save_id

    if work_id
        save_id = gotoBufferid(Work_id)
        BegFile()
        repeat
                CloseResource(GetText(1,sizeof(tag)))
        until not Down()
        AbandonFile(work_id)
        AbandonFile(data_id)
        AbandonFile(topic_id)
        AbandonFile(search_id)
        AbandonFile(vid)
        GotoBufferId(save_id)
    endif
end


integer proc mDown(integer x)
    return(iif(x > 0, Down(x), Up(abs(x))))
end


integer proc ListIt(string title, integer width)
    width = width + 4
    if width > Query(ScreenCols)
        width = Query(ScreenCols)
    endif
    return (List(title, width))
end


proc SearchHook()
        WindowFooter(Search_message)
end


keydef BrowseKeys
   <escape>    Endprocess(0)
   <helpline>  '   {Ctrl L} Next Find    {CtrlShift L} Previous Find    {Escape} Return to Topics'
end


integer proc BuildSearchBuffer()
    string  LastLineText[144]=''
    integer Last_Find_Line,   n

    // Various startup processing
       if Tag == ''
           SelectResource()
       endif
       set(break, _on_)

    // Default to a word search for Word At Cursor
       expression = GetWord(1)
       options = 'iw'

       if not ask(Format ("Word or expression to search ",tag," for:"), expression,
           Search_hist)
           return (false)
       endif
       if trim(expression) == ''
           expression = Separator
           options = 'x'
       else
           ask("Search options [IWX] (Ignore-case Words reg-eXp):", options)
       endif

    // Open the selected resource file
       if not OpenResource(tag) return(false) endif

    // Empty the Search buffer
       GotoBufferId(Search_id)
       EmptyBuffer()

    // Search for the expression using lfind v
       GotoBufferId(Text_id)
       BegFile()
       pushkey(<escape>)
       if not lFind(expression, options + 'gv')
           GetKey()
           GotoBufferId(original_id)
           Alarm()
           warn(expression, " not found.")
           return(false)
       endif

    // Use the ViewFinds buffer to create a topic list
           vid = query(viewfindsid)
           GotoBufferId(vid)
           BegFile()
           Down()
           LastLineText = GetText(1,144)
           n = pos(':',LastLineText) - 1
           repeat
               last_find_line = val(GetText(1,n))
               GotoBufferid(Text_Id)
               GotoLine(Last_Find_Line)
               if not lfind(Separator,'cx') lfind(Separator,'bx') endif
               mDown(DeltaToTitle)
               if LastLineText <> GetText(1,144)
                  LastLineText = GetText(1,144)
                  if not AddLine(format(trim(LastLineText):-144,currline():width),
                                 Search_id)
                      break
                  endif
                  Message(format(Last_Find_Line:width, ':',LastLineText))
               endif
               GotoBufferId(vid)
           until not down() or (KeyPressed() and GetKey() == <escape>)
           GotoBufferId(Search_id)
           BegFile()
           abandonfile(vid)
           return(true)
end


proc DisplaySearchBuffer()
    string topic[80]
    integer  list_result,  goto_line_no = 0

     // Display the result buffer and let user navigate the
     // the results.
        GotoBufferId(Search_id)
        ScrollToRow(10)
        repeat
              Hook(_LIST_STARTUP_, SearchHook)
              list_result = ListIt(format('TextView {',tag,'}: ',expression),
                                   70 + width)
              UnHook(SearchHook)
              goto_line_no = 0
              if list_result
               // First, locate the topic line in the text resource
                  goto_line_no = val(GetText(145, width))  // assign goto_line_no
                  GotoBufferId(Text_id)
                  GotoLine(goto_line_no)
                  topic=(GetText(1,80))
               // Next, locate the user-defined top-of-message
                  mDown(-DeltaToTitle + DeltaToBottom + 1)
                  MarkLine()
               // Skip the embedded separator if user wants it included
                  if CurrLine() <= (goto_line_no - DeltaToTitle)
                        lfind(Separator,'fx')
                  endif
               // Find the user-defined bottom-of-message
                  Down()
                  if not lFind(Separator,'fx') EndFile() endif
                  mdown(DeltaToBottom)
                  MarkLine()
                  Copy()
                  GotoBufferId(Topic_id)
               // Use topic name as buffer name for continuous topic display
                  ChangeCurrFileName(trim(topic))
                  Paste()
                  UnMarkBlock()
                  FileChanged(False)
                  Find(expression,options)
                  Enable (BrowseKeys)
                  Process()
                  Disable (BrowseKeys)
               // Reset the buffer name to prevent buffer memory fragmentation
                  ChangeCurrFileName(Topic_buffer_name)
                  EmptyBuffer()
                  UpdateDisplay(_all_windows_refresh_)
                  GotoBufferId(Search_Id)
              endif
        until list_result == 0
    gotobufferid(Text_id)
    Filechanged(false)
    if TextFileName == '' Abandonfile(Text_id) endif
    return()
end


proc mSearchView(integer SearchType)
    original_id = GetBufferId()
    case SearchType
        when OldSearch
                if Tag == '' or Text_id == 0 or Search_id == 0
                        return()
                endif
                DisplaySearchBuffer()
        when NewSearch
                if BuildSearchBuffer()
                        DisplaySearchBuffer()
                endif
    endcase
    gotobufferid(original_id)
    UpdateDisplay(_all_windows_refresh_)
end


<Ctrl Ins>        mSearchView(NewSearch)
<CtrlAlt GreyIns> SelectResource()
<Shift Ins>       mSearchView(OldSearch)

