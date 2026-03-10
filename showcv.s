integer fc,ctab,cl
integer inCVmode=0
integer proc WidthOfShowLineNumbers()
    integer wsln,nls=NumLines()
    wsln=Length(Str(nls))
    if wsln<4
        wsln=4
    elseif nls<10000
        wsln=4
    elseif 10000<=nls and nls<1000000
        wsln=wsln+1 //one comma in line number
    elseif 1000000<=nls and nls<1000000000
        wsln=wsln+2 //two comma in line number
    else
        wsln=wsln+3 //three comma in line number
    endif
    return(wsln+1)
end
proc Tab2Spc()
    ctab=0 cl=CurrLineLen() fc=FileChanged() ExpandTabsToSpaces() FileChanged(fc) if cl<>CurrLineLen() ctab=1 endif
end
proc Spc2Tab()
    if ctab==1 fc=FileChanged() EnTabCurrLine() FileChanged(fc) endif
end
proc showCVmode()
    integer i
    string opt[8],opt1[8],c[1]
    string cvstr[255],cvstr1[255]
    integer x
    integer noskip
    integer xx,yy,att,atl,xl,xe,ln,ye
    string s[1]=" ",a[1]=" "
    integer xoff
    string find1[255],find2[255]

    cvstr=GetHistoryStr(1,1) //_History_1_UI:CompressViewFind
    if cvstr=="" return() endif
    opt=Lower(GetHistoryStr(2,1)) //_History_2_UI:CompressViewFindOptions
    opt1="xc"
    for i=1 to Length(opt)
        c=opt[i]
        if c=="i" or c=="w" or c=="^" or c=="$"
            opt1=opt1+c
        endif
    endfor
//  warn("cvstr:",cvstr," opt:",opt)
    if Pos("x",opt)>0
        cvstr1=cvstr
    else
        cvstr1=""
        for i=1 to Length(cvstr)
            c=cvstr[i]
            if Pos(c,"\[]^$.*+#@|?{}")>0
                cvstr1=cvstr1+"\"+c
            else
                cvstr1=cvstr1+c
            endif
        endfor
    endif
    find1="\c"+cvstr1
    find2=cvstr1+"\c"
    ln=0
    if Query(ShowLineNumbers)
        ln=WidthOfShowLineNumbers()
    endif
    PushPosition()
    xoff=CurrXoffset()
    xe=Query(WindowCols)-ln
    yy=CurrLine()-CurrRow()
    ye=0
    while (1)
        yy=yy+1
        ye=ye+1
        if yy>NumLines() or ye>Query(WindowRows) break endif
        GotoLine(yy)
        Tab2Spc()
        BegLine()
        while (1)
            if lFind(find1,opt1)
                xx=CurrCol()-xoff
                lFind(find2,opt1)
                x=CurrCol()-xoff
                if xx==x break endif
                if 1<=xx and xx<=xe
                    VGotoXY(xx+ln,ye)
                    GetStrAttr(s,a,1)
                    noskip=1
                    atl=iif(Asc(a)==0x47,0x47,iif((Asc(a)&0xF0)==0x70 or (Asc(a)&0xF0)==0x30,(Asc(a)&0x0F|0x80),Asc(a)))
                    xl=xx
                    while xx<=xe
                        if xx>=x break endif
                        VGotoXY(xx+ln,ye)
                        GetStrAttr(s,a,1)
                        att=iif(Asc(a)==0x47,0x47,iif((Asc(a)&0xF0)==0x70 or (Asc(a)&0xF0)==0x30,(Asc(a)&0x0F|0x80),Asc(a)))
                        if att<>atl
                            VGotoXY(xl+ln,ye)
                            if noskip PutAttr(atl,xx-xl) endif
                            VGotoXY(xx+ln,ye)
                            atl=att
                            xl=xx
                        endif
                        xx = xx + 1
                    endwhile
                    VGotoXY(xl+ln,ye)
                    if noskip PutAttr(atl,xx-xl) endif
                else
                    break
                endif
            else
                break
            endif
        endwhile
        Spc2Tab()
    endwhile
    PopPosition()
end
proc OnAfterUpdateDisplay()
    integer OldCursor

    OldCursor = Set(Cursor, OFF)
    if inCVmode showCVmode() endif
    Set(Cursor, OldCursor)
end
proc mCompressView()
    string expression[255], options[12]

    expression = ''
    options = ''
    if not Ask("String to list all occurrences of:", expression, 1) //_History_1_UI:CompressViewFind
        inCVmode=0
        UpdateDisplay(_WINDOW_REFRESH_)
        return()
    endif
    if Length(expression) == 0
        return()
    elseif not Ask("Search options [ALIWX^$]:", options, 2) //_History_2_UI:CompressViewFindOptions
        return()
    endif
    if not lFind(expression, options + 'v')
        Warn(expression, " not found.")
    else
        inCVmode=1
    endif
end
proc WhenLoaded()
    Hook(_AFTER_UPDATEDISPLAY_    , OnAfterUpdateDisplay   )
end
<alt v> mCompressView()
