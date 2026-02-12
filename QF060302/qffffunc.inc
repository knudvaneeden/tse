/*
Program....: qffffunc.inc
Version....: 3.5
Author.....: Randy Wallin & Ryan Katri
Date.......: 08/02/93  03:20 pm  Last Modified: 08/30/95 @ 08:10 am
Notice.....: Copyright 1993 COB System Designs, Inc., All Rights Reserved.
QFRestore..: Ø1,1Æ
Compiler...: TSE 2.5
Abstract...: All these functions depend on Semware's FF.BIN or QFFF.BIN
             All code segments in this file are from the work by Richard
             Blackburn at Semware
Changes....:
€ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€
€ This program is a part of a series of macros written by COB System Designs€
€ for TSE/*Base users...these are not public domain but are for sale at a   €
€ reasonable price of $69.00. Please support the work involved in writing   €
€ these programs.                                                           €
€ For sales information and technical support, call SEMWARE Corporation:    €
€                                                                           €
€ MAIL: SemWare Corporation               FAX: (770) 640-6213               €
€       730 Elk Cove Court                                                  €
€       Kennesaw, GA  30152-4047  USA                                       €
€                                         InterNet: sales@semware.com       €
€                                                   qf.support@semware.com  €
€ PHONE (SALES ONLY): (800) 467-3692      OTHER VOICE CALLS: (770) 641-9002 €
€          Inside USA, 9am-5pm ET                              9am-5pm ET   €
€‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹€
*/

/* Kevin @ Semware's FF.BIN used in QFDISPFILE - thanks Kevin */
binary ['qfff.bin']
    integer proc _CD(string dir) : 0
    integer proc _CurrDir(var string s) : 3
    integer proc _ff(string path, var string ffblk, integer attribs) : 6
    integer proc _fn(var string ffblk) : 9
    integer proc _SetAttrib(string file, integer attrib) : 12
    integer proc _Rename(string oldname, string newname) : 15
end


constant    ffNORMAL    = 0x00,
            ffRDONLY    = 0x01,
            ffHIDDEN    = 0x02,
            ffSYSTEM    = 0x04,
            ffVOLUME    = 0x08,
            ffSUBDIR    = 0x10,
            ffARCH      = 0x20

string ffblk[43]


/* Richard Blackburn, Semware, code block - thanks Richard.
   Thanks to Kevin @ Semware for the FF.Bin too
*/
string proc ffname(string ffblk)
    integer p = pos(chr(0),substr(ffblk,31,13))
    return (substr(ffblk,31,iif(p,p-1,13)))
end

integer proc ffAttr(string ffblk)
    return (Asc(ffblk[22]))
end

string proc ffTime(string ffblk)
    integer t = (Asc(ffblk[24]) shl 8) | Asc(ffblk[23])
    string  s[8] = ''

    s = Format(((t & 0xF800) shr 11):2:"0", ':',
               ((t & 0x07E0) shr  5):2:"0", ':',
               ((t & 0x001F) shl  1):2:"0")
    return (s)
end ffTime

string proc ffDate(string ffblk)
    integer d = (Asc(ffblk[26]) shl 8) | Asc(ffblk[25])
    string  s[8] = ''

    s = Format(((d & 0x01E0) shr 5):2:"0", '-',
               (d & 0x001F):2:"0", '-',
               ((((d & 0xFE00) shr 9)+ 80) mod 100):2:"0")
    return (s)
end ffDate

integer proc ffSize(string ffblk)
    return ((Asc(ffblk[30]) shl 24) | (Asc(ffblk[29]) shl 16) |
            (Asc(ffblk[28]) shl  8) | (Asc(ffblk[27])))
end ffSize

integer proc Find_First(string path, var string ffblk, integer attribs)
    return(_ff(path+Chr(0), ffblk, attribs))
end Find_First

integer proc Find_Next(var string ffblk)
    return(_fn(ffblk))
end Find_Next

// integer proc CD(string dir)
//     return(_CD(dir + Chr(0)))
// end


/* End of Richard's codeblock */

