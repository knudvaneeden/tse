proc main()
    integer j,i,n
    string histstr[255]

    j=MsgBox("","Do you want to export/add all input history to/from history.ini? (Select YES to export/NO to add/cancel)",_YES_NO_CANCEL_)
    if j==1  //export
        EditFile("history.ini")
        EmptyBuffer()
        for i=1 to 255
            n=NumHistoryItems(i)
            case i
            when   1                       AddLine("[_History_"+Str(i)+"_UI:CompressViewFind]")        //  1
            when   2                       AddLine("[_History_"+Str(i)+"_UI:CompressViewFindOptions]") //  2
            when   3                       AddLine("[_History_"+Str(i)+"_MAC:CVE]")                    //  3
            when   4                       AddLine("[_History_"+Str(i)+"_MAC:CVE_options]")            //  4
            when   5                       AddLine("[_History_"+Str(i)+"_UI:vxpath]")                  //  5
            when   6                       AddLine("[_History_"+Str(i)+"_MAC:ADO]")                    //  6
            when   7                       AddLine("[_History_"+Str(i)+"_MAC:bFind]")                  //  7
            when   8                       AddLine("[_History_"+Str(i)+"_MAC:bFind_options]")          //  8
            when   9                       AddLine("[_History_"+Str(i)+"_MAC:BookMarkIO_fi]")          //  9
            when  10                       AddLine("[_History_"+Str(i)+"_MAC:nameclip]")               // 10
            when  11                       AddLine("[_History_"+Str(i)+"_MAC:l_r_align_Gap]")          // 11
            when  12                       AddLine("[_History_"+Str(i)+"_MAC:l_r_align_LR]")           // 12
            when  13                       AddLine("[_History_"+Str(i)+"_MAC:CMPFILE_fn]")             // 13
            when  14                       AddLine("[_History_"+Str(i)+"_MAC:CMPFILE_ign12]")          // 14
            when  15                       AddLine("[_History_"+Str(i)+"_UI:LinkSynFile]")             // 15
            when  16                       AddLine("[_History_"+Str(i)+"_MAC:FSA]")                    // 16
            when  17                       AddLine("[_History_"+Str(i)+"_UI:QuitFiles]")               // 17
            when  18                       AddLine("[_History_"+Str(i)+"_MAC:BookMarkIO_fo]")          // 18
            when  19                       AddLine("[_History_"+Str(i)+"_MAC:Blocks_fo]")              // 19
            when  20                       AddLine("[_History_"+Str(i)+"_MAC:Blocks_fi]")              // 20

            when  51                       AddLine("[_History_"+Str(i)+"_MAC:Capture_OSCmdOutput]")    // 51
            when  52                       AddLine("[_History_"+Str(i)+"_MAC:debug_macro_source]")     // 52
            when  53                       AddLine("[_History_"+Str(i)+"_MAC:debug_]")                 // 53
            when  54                       AddLine("[_History_"+Str(i)+"_MAC:dump_find]")              // 54
            when  55                       AddLine("[_History_"+Str(i)+"_MAC:dump_addr]")              // 55

            when  60                       AddLine("[_History_"+Str(i)+"_MAC:cd_ChangeDir]")           // 60

            when _EDIT_HISTORY_            AddLine("[_History_"+Str(i)+"__EDIT_HISTORY_]")             //128

            when _NEWNAME_HISTORY_         AddLine("[_History_"+Str(i)+"__NEWNAME_HISTORY_]")          //136
            when _EXECMACRO_HISTORY_       AddLine("[_History_"+Str(i)+"__EXECMACRO_HISTORY_]")        //137
            when _LOADMACRO_HISTORY_       AddLine("[_History_"+Str(i)+"__LOADMACRO_HISTORY_]")        //138
            when _KEYMACRO_HISTORY_        AddLine("[_History_"+Str(i)+"__KEYMACRO_HISTORY_]")         //139

            when _GOTOLINE_HISTORY_        AddLine("[_History_"+Str(i)+"__GOTOLINE_HISTORY_]")         //144
            when _GOTOCOLUMN_HISTORY_      AddLine("[_History_"+Str(i)+"__GOTOCOLUMN_HISTORY_]")       //145
            when _REPEATCMD_HISTORY_       AddLine("[_History_"+Str(i)+"__REPEATCMD_HISTORY_]")        //146

            when _DOS_HISTORY_             AddLine("[_History_"+Str(i)+"__DOS_HISTORY_]")              //152

            when _FIND_OPTIONS_HISTORY_    AddLine("[_History_"+Str(i)+"__FIND_OPTIONS_HISTORY_]")     //160
            when _REPLACE_OPTIONS_HISTORY_ AddLine("[_History_"+Str(i)+"__REPLACE_OPTIONS_HISTORY_]")  //161

            when _FIND_HISTORY_            AddLine("[_History_"+Str(i)+"__FIND_HISTORY_]")             //168
            when _REPLACE_HISTORY_         AddLine("[_History_"+Str(i)+"__REPLACE_HISTORY_]")          //169

            when _FILLBLOCK_HISTORY_       AddLine("[_History_"+Str(i)+"__FILLBLOCK_HISTORY_]")        //176

            when 184                       AddLine("[_History_"+Str(i)+"__HELPSEARCH_HISTORY_]")       //184
            otherwise
                if n>0
                    AddLine("[_History_"+Str(i)+"_]")
                endif
            endcase
            if n>0
                for j=n downto 1 //To ensure that AddHistoryStr in mLoadHistory is sorted from old to new
                    AddLine(GetHistoryStr(i,j))
                endfor
            endif
        endfor
        SaveFile()
    elseif j==2  //add
        i=1
        if not FileExists("history.ini") PurgeMacro(CurrMacroFilename()) return() endif
        BufferVideo()
        EditFile("history.ini")
        while (1)
            histstr=GetText(1,255)
            if LeftStr(histstr,10)=="[_History_"
                i=Val(SubStr(histstr,11,3))
//              DelHistory(i) //Do not delete the old global History, but only place the local History at the top
            else
                if i>0
                    AddHistoryStr(histstr,i)
                endif
            endif
            if not Down() break endif
        endwhile
        AbandonFile()
        UnBufferVideo()
    endif
    PurgeMacro(CurrMacroFilename())
    return()
end
