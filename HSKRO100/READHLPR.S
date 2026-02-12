//// *** From WP.UI *** BEGIN
////
/***********************************************************************
  The following commands are included via this set of DOS calls:

  FindFirst --  Find the first matching file

                integer proc FindFirst(string path, var string ffblk, integer attribs)

  FindNext  --  Find the next matching file

                integer proc FindNext(var string ffblk)

  SetAttrib --  Set the attributes of the file passed

                integer proc SetAttrib(string file, integer attrib)

 ***********************************************************************/
binary ['..\ui\wp.bin']
    integer proc _ff(string path, var string ffblk, integer attribs) : 0
    integer proc _fn(var string ffblk) : 3
    integer proc _SetAttrib(string file, integer attrib) : 6
end

constant    ffNORMAL    = 0x00,
            ffRDONLY    = 0x01,
            ffHIDDEN    = 0x02,
            ffSYSTEM    = 0x04,
            ffVOLUME    = 0x08,
            ffSUBDIR    = 0x10,
            ffARCH      = 0x20,
            ffALL       = 0x3f,
            ffALLNV     = 0x37       // All except ffVOLUMNE

string ffblk[43]

//UNUSED//integer proc SetAttrib(string file, integer attrib)
//UNUSED//    return(_SetAttrib(file + Chr(0), attrib))
//UNUSED//end

//UNUSED//string proc ffName(string ffblk)
//UNUSED//    integer p = Pos(Chr(0),SubStr(ffblk,31,13))
//UNUSED//    return (SubStr(ffblk,31,iif(p,p-1,13)))
//UNUSED//end

integer proc ffAttr(string ffblk)
    return (Asc(ffblk[22]))
end

//UNUSED//string proc ffAttrStr(string ffblk)
//UNUSED//    string  s[5] = ''
//UNUSED//    integer a = ffAttr(ffblk)
//UNUSED//
//UNUSED//    s = iif(a & ffRDONLY, 'R', '_')
//UNUSED//    s = s + iif(a & ffHIDDEN, 'H', '_')
//UNUSED//    s = s + iif(a & ffSYSTEM, 'S', '_')
//UNUSED//    s = s + iif(a & ffARCH,   'A', '_')
//UNUSED//    s = s + iif(a & ffSUBDIR, 'D', '_')
//UNUSED//    return (s)
//UNUSED//end ffAttrStr

//UNUSED//string proc ffTime(string ffblk)
//UNUSED//    integer t = (Asc(ffblk[24]) shl 8) | Asc(ffblk[23])
//UNUSED//    string  s[8] = ''
//UNUSED//
//UNUSED//    s = Format(((t & 0xF800) shr 11):2:'0', ':',
//UNUSED//               ((t & 0x07E0) shr  5):2:'0', ':',
//UNUSED//               ((t & 0x001F) shl  1):2:'0')
//UNUSED//    return (s)
//UNUSED//end ffTime

//UNUSED//string proc ffDate(string ffblk)
//UNUSED//    integer d = (Asc(ffblk[26]) shl 8) | Asc(ffblk[25])
//UNUSED//    string  s[8] = ''
//UNUSED//
//UNUSED//    s = Format(((d & 0x01E0) shr 5):2:'0', '-',
//UNUSED//               (d & 0x001F):2:'0', '-',
//UNUSED//               ((((d & 0xFE00) shr 9)+ 80) mod 100):2:'0')
//UNUSED//    return (s)
//UNUSED//end ffDate

//UNUSED//integer proc ffSize(string ffblk)
//UNUSED//    return ((Asc(ffblk[30]) shl 24) | (Asc(ffblk[29]) shl 16) |
//UNUSED//            (Asc(ffblk[28]) shl  8) | (Asc(ffblk[27])))
//UNUSED//end ffSize

integer proc FindFirst(string path, var string ffblk, integer attribs)
    return(_ff(path+Chr(0), ffblk, attribs))
end FindFirst

//UNUSED//integer proc FindNext(var string ffblk)
//UNUSED//    return(_fn(ffblk))
//UNUSED//end FindNext

/****************** end of binary helper routines ********************/
////
//// *** From WP.UI *** END
////
////
//// *** From TSE.UI ***BEGIN
////
integer proc ListIt(string title, integer width)
    width = width + 4
    if width > Query(ScreenCols)
        width = Query(ScreenCols)
    endif
    return (List(title, width))
end

/****************************************************************************
   Returns the string "On" or "Off" based on the logical value of i.
 ***************************************************************************/
string proc OnOffStr(integer i)
    return (iif(i, "On", "Off"))
end

/****************************************************************************
  List Files placed in the editor's internal ring of files.

  Notes:
    System buffers are _not_ intended for interactive editing.  Therefore,
    this command will exit if it is determined that the current buffer is a
    system buffer.
 ***************************************************************************/
integer proc ListAndGoto(integer start_id, integer list_id, integer maxl, string title, integer start_line, integer fn_start_col)
    string fn[80]

    if GotoBufferId(list_id)
        BegFile()
        if maxl == 0
            repeat
                if CurrLineLen() > maxl
                    maxl = CurrLineLen()
                endif
            until not down()
        endif
        if maxl < Length(title)
            maxl = Length(title) + 2
        endif
        GotoLine(start_line)

        if ListIt(title, maxl)
            fn = GetText(fn_start_col, CurrLineLen() - fn_start_col + 1)
            if ExpandPath(fn) == fn
                EditFile(fn)
            else
                GotoBufferId(GetBufferId(fn))
                ExecHook(_ON_CHANGING_FILES_)
            endif
            return (TRUE)
        endif
        GotoBufferId(start_id)
    endif
    return (FALSE)
end
////
//// *** From TSE.UI ***END
