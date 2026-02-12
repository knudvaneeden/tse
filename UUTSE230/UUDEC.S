/**************************************************************************/
/*                                                                        */
/*   UU/XX/MIME64 decode macro for TSE 2.50 Pro, TSE32 2.80               */
/*                                                                        */
/*   version 2.30 - by Fabio Ferrero - 1997                               */
/*                                                                        */
/*   Simply load an encoded file and run this macro!                      */
/*                                                                        */
/**************************************************************************/

#define M_UNKN  0
#define M_UU    1
#define M_XX    2
#define M_MIME  3

#define POLY 0x8408

string filecharset[32]= chrset("0-9a-zA-Z_.-~!@#$()")

integer ofile, tot, sum, method, crc, bound= FALSE
string sname[48], boundstr[4]

integer proc xx_dec(integer c)
    if c == asc('+')
        return(0)
    endif
    if c == asc('-')
        return(1)
    endif
    if (c >= asc('0')) and (c <= asc('9'))
        return(c-asc('0')+2)
    endif
    if (c >= asc('A')) and (c <= asc('Z'))
        return(c-asc('A')+12)
    endif
    if (c >= asc('a')) and (c <= asc('z'))
        return(c-asc('a')+38)
    endif
    return(0)
end

integer proc uu_dec(integer c)
    return((c-0x20) & 0x3f)
end

integer proc mime_dec(integer c)
    if (c >= asc('A')) and (c <= asc('Z'))
        return(c-asc('A'))
    endif
    if (c >= asc('a')) and (c <= asc('z'))
        return(c-asc('a')+26)
    endif
    if (c >= asc('0')) and (c <= asc('9'))
        return(c-asc('0')+52)
    endif
    if (c == asc('+'))
        return(62)
    endif
    if (c == asc('/')) or (c == asc('-'))
        return(63)
    endif
    if (c == asc('='))
        return(-2)
    endif
    return(-1)
end

integer proc dec(integer c)
    case method
        when M_XX
            return(xx_dec(c))
        when M_UU
            return(uu_dec(c))
        when M_MIME
            return(mime_dec(c))
    endcase
    return(uu_dec(c))
end

proc calcsum(integer c)
    if sum & 0x01
        sum= (sum shr 1) + 0x8000
    else
        sum= (sum shr 1)
    endif
    sum= sum+(c & 0xff)
    sum= sum & 0xffff
    tot= tot+1
end

integer proc bytecrc16(integer c)
    integer i, data
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

proc outdec(integer n)
    integer c1, c2, c3
    c1= dec(currchar()) shl 2
    right()
    c1= c1 | (dec(currchar()) shr 4)
    c2= dec(currchar()) shl 4
    right()
    c2= c2 | (dec(currchar()) shr 2)
    c3= dec(currchar()) shl 6
    right()
    c3= c3 | dec(currchar())
    right()
    if n >= 1
        fwrite(ofile, chr(c1))
        calcsum(c1)
        bytecrc16(c1)
    endif
    if n >= 2
        fwrite(ofile, chr(c2))
        calcsum(c2)
        bytecrc16(c2)
    endif
    if n >= 3
        fwrite(ofile, chr(c3))
        calcsum(c3)
        bytecrc16(c3)
    endif
end

proc sumcheck()
    string msg[48]
    integer orisum, oritot, chk
    chk= FALSE
    msg= 'Decoded file '+sname+': '
    if lfind("^UUtseCHK: crc16/size {[0-9A-F]#}/{[0-9A-F]#}", "x")
        orisum= val(getfoundtext(1), 16)
        oritot= val(getfoundtext(2), 16)
        sum= crc
        chk= TRUE
    else
        if lfind("^sum -r/size {[0-9]#}/{[0-9]#} entire input file", "ix") or lfind("^sum -r/size {[0-9]#}/{[0-9]#}", "ix")
            orisum= val(getfoundtext(1))
            oritot= val(getfoundtext(2))
            chk= TRUE
        endif
    endif
    if chk
        if (orisum <> sum) and (oritot == tot)
            warn(msg+'Checksum ERROR!')
        endif
        if (orisum == sum) and (oritot <> tot)
            warn(msg+'Size ERROR!')
        endif
        if (orisum <> sum) and (oritot <> tot)
            warn(msg+'Checksum and size ERROR!')
        endif
        if (orisum == sum) and (oritot == tot)
            message(msg+'Checksum and size OK!')
        endif
    else
        message(msg+'NO checksum!')
    endif
end

proc uudecode()
    integer n, l
    l= 0
    while TRUE
        if (currchar() <= 0)
            warn('Short file!')
            return()
        endif
        n= dec(currchar())
        message('Decoding line: '+str(l))
        l= l+1
        right()
        if (n <= 0)
            break
        endif
        while n > 0
            outdec(n)
            n= n-3
        endwhile
        if not down()
            warn('Short file!')
            return()
        endif
        begline()
    endwhile
    down()
    begline()
    if getword() <> "end"
        message('No end line!')
    else
        sumcheck()
    endif
end

proc mimedecode()
    integer l= 0, accum= 0, shift= 0, value, quit= FALSE
    while not quit
        value= dec(currchar())
        if value < 0
            quit= TRUE
            break
        endif
        right()
        if currchar() < 0
            if not down()
                quit= TRUE
            endif
            begline()
            if currchar() < 0
                quit= TRUE
            endif
            if bound and lfind(boundstr, "c")
                quit= TRUE
            endif
            message('Decoding line: '+str(l))
            l= l+1
        endif
        if value < 64
            accum= accum shl 6
            shift= shift+6
            accum= accum | value
            if shift >= 8
                shift= shift-8
                value= accum shr shift
                value= value & 0xff
                fwrite(ofile, chr(value))
                calcsum(value)
                bytecrc16(value)
            endif
        else
            quit= TRUE
        endif
    endwhile
    sumcheck()
end

proc selectxx()
    method= M_XX
end

proc selectuu()
    method= M_UU
end

proc selectmime()
    method= M_MIME
end

proc selectauto()
    integer lng, lnr
    pushposition()
    if lfind("^begin [0-9]#", "gix")
        down()
        begline()
        lnr= (currlinelen()-1)/4*3
        method= M_UU
        lng= dec(currchar())
        if lng == lnr
            method= M_UU
        else
            method= M_XX
            lng= dec(currchar())
            if lng == lnr
                method= M_XX
            else
                method= M_UNKN
            endif
        endif
    else
        if lfind("name=", "gi")
            method= M_MIME
        else
            method= M_UNKN
        endif
    endif
    popposition()
end

menu selmeth()
    Title= "Select decoded method"
    History= 1

    "&Auto",        selectauto()
    "",             ,   divide
    "&UUdecode",    selectuu()
    "&XXdecode",    selectxx()
    "&Mime64",      selectmime()
end

#ifndef WIN32
string proc normfile(string nm)
    integer cnt
    cnt= numtokens(nm, ".")
    return(substr(gettoken(nm, ".", 1), 1, 8)+"."+substr(gettoken(nm, ".", cnt), 1, 3))
end
#endif

string proc getname()
    string name[32], swordset[32]
    case method
        when M_XX, M_UU
            if lfind("^begin [0-9]#", "gix")
                wordright()
                wordright()
                // Mark filename
                swordset= set(wordset, filecharset)
                name= getword()
                set(wordset, swordset)
                down()
                begline()
            else
                warn('No begin line!')
                name= ''
            endif
        when M_MIME
            if lfind("name=", "gi")
                wordright()
                // Mark filename
                swordset= set(wordset, filecharset)
                name= getword()
                set(wordset, swordset)
                lfind("^$", "x")
                down()
                begline()
            else
                name= splitpath(currfilename(), _NAME_)+'.$$$'
            endif
            pushposition()
            if not lfind("Content-transfer-encoding: base64", "gi")
                warn('Invalid encoding!')
                name= ''
            endif
            if lfind('Content-Type: multipart/mixed; boundary="-"', "gi")
                right(41)
                bound= TRUE
                boundstr= chr(currchar())+chr(currchar())+chr(currchar())
            endif
            popposition()
    endcase
#ifndef WIN32
    return(normfile(name))
#else
    return(name)
#endif
end

proc main()
    integer chk
    message("uuTSE->UU/XX/MIME64 decode v2.30 for TSE, TSE32 - by Fabio Ferrero - 1997")
    tot= 0
    sum= 0
    crc= 0xffff
    method= M_UNKN
    while method == M_UNKN
        selmeth()
        if menukey() == <Escape>
            warn('Aborting...')
            return()
        endif
        if method == M_UNKN
            warn("Unknown coding method or can't autodetect, please select manually.")
        endif
    endwhile
    pushposition()
    sname= getname()
    if sname == ''
        popposition()
        return()
    else
        while fileexists(sname)
            chk= yesno('File '+sname+' exist, overwrite?')
            if chk == 1
                erasediskfile(sname)
            else
                if chk == 2
                    askfilename("Input new name for encoded file:", sname, _WRITE_ACCESS_)
                else
                    warn('Aborting...')
                    popposition()
                    return()
                endif
            endif
        endwhile
        ofile= fcreate(sname, _NORMAL_ | _ARCHIVE_)
        if ofile == -1
            warn('Cannot open file: '+sname)
            popposition()
            return()
        endif
        case method
            when M_UU, M_XX
                uudecode()
            when M_MIME
                mimedecode()
        endcase
        fclose(ofile)
    endif
    popposition()
end

