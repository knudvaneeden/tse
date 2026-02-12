/**********************************************************************
           ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
           ³        Released into the public domain        ³
           ³  20 April 1993 by the author, Rick VanNorman  ³
           ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

This set of macros will save and restore editor status, including all
bookmarks set and files in the edit ring.

Editor status, including video mode, bookmarks, and all files currently
being edited, is saved on exit via mSaveStatAndExit().

On startup, if there are no parameters on the command tail and the file
STATUS.TSE is available, the full editor status described by STATUS.TSE
will be restored.  If no command tail and no STATUS.TSE the user will be
prompted for a file to edit (as normal TSE).  If a command tail is
present, STATUS.TSE is ignored and the editor is started fresh with the
files specified by the user.

The startup sequence requires access to the dos command tail, gained via
the DosCmdLine editor variable.

These routines could be extended to rebuild a multi-window display,
restore command histories, or almost everything else; I don't need that
level of functionality so I won't do it.

20 April 1993
Rick VanNorman
Route 1 Box 294
Glenwood, WV 25520

**********************************************************************/

// restore a file for editing
proc RestoreEdit()
        integer theline,therow

        theline = val(GetText(8,5))
        therow  = val(GetText(14,2))
        editfile(GetText(17,64))
        GotoLine(theline)
        ScrollToRow(therow)
end


// restore a bookmark
proc RestoreMark()
        string themark[1]

        themark = gettext(6,1)
        restoreedit()
        PlaceMark(themark)
end


// restore the video mode
proc RestoreVid()
        set(CurrVideoMode,Val(GetText(8,5)))
end

// parse the STATUS.TSE file and restore the status of the editor
proc mRestoreEdit()
        integer statfile,i=1
        string mode[4]

        editfile("status.tse")
        statfile = getbufferid()
        while (i <= numlines())
                gotoline(i)
                mode = gettext(1,4)
                case mode
                        when "edit"
                                RestoreEdit()
                        when "mark"
                                RestoreMark()
                        when "vid "
                                RestoreVid()
                endcase
                gotobufferid(statfile)
                i = i + 1
        endwhile
        abandonfile()
end


// if there is a file STATUS.TSE, use it to restore the editor
proc mLoadFromStat()

        if fileexists("status.tse")
                mrestoreedit()
        endif
end


// save the current bookmarks. flist is the buffer id of the output file
proc mSaveMarks(integer flist)
    integer i=1
    string themark[1]
    string s[80]

    while i <= 26
        themark = (Chr(Asc('a') + i - 1))
        if GotoMark(themark)
            // if mark there, add it to list of marks
            s = Format('mark ', themark:1,' ', currline():5,' ',
                       currrow():2,' ',currfilename())
            GotoBufferId(flist)
            AddLine(s)
        endif
        i = i + 1
    endwhile
end


// save the currently open files and their positions
proc mSavePositions(integer flist, integer start)
        integer temp
        string s[80]

        gotobufferid(start)
        repeat
                if (query(buffertype) == _NORMAL_)
                        temp = getbufferid()
                        s = format('edit   ',currline():5,' ',currrow():2,' ',currfilename())
                        gotobufferid(flist)
                        addline(s)
                        gotobufferid(temp)
                endif
                nextfile()
        until (getbufferid() == start)
        gotobufferid(flist)
end


// save all status and save all files and exit
proc mSaveStatAndExit ()
        integer start, flist, temp
        string s[80]

        start = getbufferid()
        flist = createtempbuffer()
        s = format('vid   ',query(currvideomode):5)
        addline(s)
        mSaveMarks(flist)
        mSavePositions(flist,start)
        saveas("status.tse",_OVERWRITE_)
        abandonfile()
        saveallandexit()
end

// --------------------------------------------------------------------

// this is the modified WHENLOADED()

proc WhenLoaded()
    integer cid = GetBufferId()

    pick_buffer = CreateTempBuffer()
    GotoBufferId(cid)
    Hook(_ON_CHANGING_FILES_, OnChangingFiles)
    Hook(_ON_FIRST_EDIT_, OnFirstEdit)

    if (length(query(doscmdline)) == 0)
        mloadfromstat()
    endif
end

