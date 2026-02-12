/**************************************************************************/
/*                                                                        */
/*   UU/XX/MIME64 encode macro for TSE 2.50 Pro, TSE32 2.80               */
/*                                                                        */
/*   version 2.30 - by Fabio Ferrero - 1997                               */
/*                                                                        */
/*   Simply run this macro!                                               */
/*                                                                        */
/**************************************************************************/

#define M_UU    1
#define M_XX    2
#define M_MIME  3

#define POLY 0x8408

integer ifile, tot, sum, crc, method
string buf[64], exts[4]
string alphabet[64]= "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

integer proc xx_enc(integer c)
    if c == 0
        return(asc('+'))
    endif
    if c == 1
        return(asc('-'))
    endif
    if (c >= 2) and (c <= 11)
        return(c+asc('0')-2)
    endif
    if (c >= 12) and (c <= 37)
        return(c+asc('A')-12)
    endif
    if (c >= 38) and (c <= 63)
        return(c+asc('a')-38)
    endif
    return(asc('+'))
end

integer proc uu_enc(integer c)
    if c & 0x3f
        return((c & 0x3f) + 0x20)
    endif
    return(0x60)
end

integer proc enc(integer c)
    case method
        when M_XX
            return(xx_enc(c))
        when M_UU
            return(uu_enc(c))
    endcase
    return(uu_enc(c))
end

proc calcsum(string cc)
    if sum & 0x01
        sum= (sum shr 1) + 0x8000
    else
        sum= (sum shr 1)
    endif
    sum= sum+asc(cc)
    sum= sum & 0xffff
    tot= tot+1
end

integer proc bytecrc16(string cc)
    integer i, data, c
    c= asc(cc)
    data= 0x00ff & c
    for i= 0 to 7
        if (crc & 0x0001) ^ (data & 0x0001)
            crc= (crc shr 1) ^ POLY
        else
            crc= (crc shr 1)
        endif
        data= (data shr 1)
    endfor
    crc= ~crc
    data= crc
    crc= (crc shl 8) | ((data shr 8) & 0x00ff)
    crc= crc & 0xffff
    return(crc)
end

proc outdec(integer ps)
    integer c1, c2, c3, c4
    string t[4]
    c1= asc(buf[ps]) shr 2
    c2= ((asc(buf[ps]) shl 4) & 0x30) | ((asc(buf[ps+1]) shr 4) & 0x0f)
    c3= ((asc(buf[ps+1]) shl 2) & 0x3c) | ((asc(buf[ps+2]) shr 6) & 0x03)
    c4= asc(buf[ps+2]) & 0x3f
    t= chr(enc(c1))+chr(enc(c2))+chr(enc(c3))+chr(enc(c4))
    inserttext(t, _INSERT_)
end

proc sumadd()
    addline("")
    begline()
    inserttext("sum -r/size "+str(sum)+"/"+str(tot)+" entire input file", _INSERT_)
    addline("")
    begline()
    inserttext("UUtseCHK: crc16/size "+str(crc, 16)+"/"+str(tot, 16), _INSERT_)
end

proc mimeline(integer index)
    buf= buf[1..index-1]
    inserttext(buf, _INSERT_)
    addline("")
    begline()
end

proc mimeencode(string nm)
    integer f_feof= FALSE, shift= 0, accum= 0, index= 1, quit= FALSE
    integer save_shift, value, l= 0
    string blivit[3]
    blivit[1]= ""
    inserttext("Mime-Version: 1.0")
    addline("")
    begline()
    inserttext('Content-Type: multipart/mixed; boundary="-"')
    addline("")
    begline()
    inserttext("---")
    addline("")
    begline()
    inserttext("Content-Type: text/plain; charset=US-ASCII; name="+nm, _INSERT_)
    addline("")
    begline()
    inserttext("Content-transfer-encoding: base64", _INSERT_)
    addline("")
    addline("")
    begline()
    while not f_feof or shift
        if not f_feof and not quit
            if fread(ifile, blivit, 1) <= 0
                f_feof= TRUE
            else
                calcsum(blivit[1])
                bytecrc16(blivit[1])
            endif
            if f_feof
                quit= TRUE
                save_shift= shift
                blivit= chr(0)
            endif
        else
            quit= TRUE
            save_shift= shift
            blivit= chr(0)
        endif
        if not quit or shift
            value= asc(blivit)
            accum= accum shl 8
            shift= shift+8
            accum= accum|value
        endif
        while shift >= 6
            shift= shift-6
            value= (accum shr shift) & 0x3f
            blivit= alphabet[value+1]
            buf[index]= blivit
            index= index+1
            if index >= 61
                mimeline(index)
                l= l+1
                message('Encoding line: '+str(l))
                index= 1
            endif
            if quit
                shift= 0
            endif
        endwhile
    endwhile
    if save_shift == 2
        buf[index]= '='
        index= index+1
        if index >= 61
            mimeline(index)
            index= 1
        endif
        buf[index]= '='
        index= index+1
        if index >= 61
            mimeline(index)
            index= 1
        endif
    endif
    if save_shift == 4
        buf[index]= '='
        index= index+1
        if index >= 61
            mimeline(index)
            index= 1
        endif
    endif
    if index <> 1
        mimeline(index)
    endif
    inserttext("---")
    addline("")
    begline()
    sumadd()
end

proc uuencode(string nm)
    integer n, l, i
    l= 0
    inserttext("begin 644 "+nm, _INSERT_)
    while TRUE
        n= fread(ifile, buf, 45)
        if n <= 0
            break
        endif
        addline("")
        begline()
        inserttext(chr(enc(n)), _INSERT_)
        message('Encoding line: '+str(l))
        l= l+1
        for i= 1 to n by 3
            outdec(i)
        endfor
        for i= 1 to n
            calcsum(buf[i])
            bytecrc16(buf[i])
        endfor
    endwhile
    addline(chr(enc(0)))
    addline("")
    begline()
    inserttext("end", _INSERT_)
    sumadd()
end

proc selectxx()
    method= M_XX
    exts= ".xxe"
end

proc selectuu()
    method= M_UU
    exts= ".uue"
end

proc selectmime()
    method= M_MIME
    exts= ".m64"
end

menu selmeth()
    Title= "Select encoded method"
    History= 1

    "&UUencode",    selectuu()
    "&XXencode",    selectxx()
    "&Mime64",      selectmime()
end

proc main()
    string sname[64]= "", fname[64]
    integer bid, chk
    string txt[73]= "uuTSE->UU/XX/MIME64 encode v2.30 for TSE, TSE32 - by Fabio Ferrero - 1997"
    message(txt)
    tot= 0
    sum= 0
    crc= 0xffff
    selmeth()
    if menukey() == <Escape>
        warn('Aborting...')
        return()
    endif
    pushposition()
    if askfilename("File to encode:", sname, _MUST_EXIST_)
        // Open file to encode
        ifile= fopen(sname+chr(0), _OPEN_READONLY_)
        if ifile == -1
            warn('Error opening file: '+sname)
            popposition()
            return()
        endif
        // Open text file
        fname= splitpath(sname, _NAME_)+exts
        while fileexists(fname)
            chk= yesno('File '+fname+' exist, overwrite?')
            if chk == 1
                erasediskfile(fname)
            else
                if chk == 2
                    askfilename("Input new name for encoded file:", fname, _WRITE_ACCESS_)
                else
                    warn('Aborting...')
                    popposition()
                    return()
                endif
            endif
        endwhile
        bid= editfile(fname, _DONT_PROMPT_)
        if bid == 0
            warn("Error opening file: "+fname)
            popposition()
            return()
        endif
        if numlines() > 0
            if yesno('You are editing '+fname+', clear it?') == 1
                emptybuffer()
            else
                warn('Aborting...')
                popposition()
                return()
            endif
        endif
        inserttext(txt)
        addline("")
        addline("")
        begline()
        case method
            when M_UU, M_XX
                uuencode(splitpath(sname, _NAME_|_EXT_))
            when M_MIME
                mimeencode(splitpath(sname, _NAME_|_EXT_))
        endcase
        addline("")
        begline()
        fclose(ifile)
        savefile()
        quitfile()
        addhistorystr(fname, _EDIT_HISTORY_)
        message('Successful encoded file '+sname+' into '+fname)
    endif
    popposition()
end

