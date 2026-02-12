//// HSK Read-Only macros - Buffer List
////
//// Written by:  Howard Kapustein
////
//// Description: Buffer List for Read-Only macros by Howard Kapustein.
////
//// Recommended key bindings:  <CenterCursor>  mHskListOpenFiles()
////
//// Last Update:
////    02/22/95 10:41 pm HSK0  Created (1.0)
////
//// Credits:
////    mHskListOpenFiles() is based on mListOpenFiles() in TSE.UI and
////        the buffer list display in Sage Professional Editor, plus
////        some encouragement by Mike Brocious.
////
////
//// Permission is granted to SemWare to modify and distribute
//// this macro set with the SemWare Editor product.
////
//// Howard Kapustein, February 22, 1995
////
////
////
// Constants - Buffer List
constant READONLY_BUFFERLIST_MOD_FNAME    = 0
constant READONLY_BUFFERLIST_RO_MOD_FNAME = 1
constant READONLY_BUFFERLIST_MOD_FNAME_RO = 2
////
// Global Variables
integer Setting_BufferList = READONLY_BUFFERLIST_RO_MOD_FNAME
////
// mHskListOpenFiles() - HSK Enhancement to mListOpenFiles()
proc mHskListOpenFiles()
    integer start_file, filelist, maxl, total, n
    string fn[65], prefix[2], suffix[5]

    n = NumFiles() + (BufferType() <> _NORMAL_)
    maxl = 13
    total = 0
    start_file = GetBufferid()                 // Save current
    filelist = CreateTempBuffer()
    if filelist == 0
        warn("Cannot create filelist")
        return ()
    endif
    GotoBufferId(start_file)
    while n
        fn = CurrFilename()
        if length(fn)
            if length(fn) > maxl
                maxl = length(fn)
            endif
            case Setting_BufferList
                when READONLY_BUFFERLIST_MOD_FNAME
                    prefix = iif( FileChanged(), '*', ' ' )
                    suffix = ''
                when READONLY_BUFFERLIST_RO_MOD_FNAME
                    if FindFirst( fn, ffblk, ffALLNV ) AND ( ffAttr(ffblk) & ffRDONLY )
                        prefix = 'R' + iif( FileChanged(), '*', ' ' )
                    else
                        prefix = ' ' + iif( FileChanged(), '*', ' ' )
                    endif
                    suffix = ''
                when READONLY_BUFFERLIST_MOD_FNAME_RO
                    prefix = iif( FileChanged(), '*', ' ' )
                    if FindFirst( fn, ffblk, ffALLNV ) AND ( ffAttr(ffblk) & ffRDONLY )
                        suffix = ' (RO)'
                    else
                        suffix = ''
                    endif
                otherwise
                    prefix = 'ERR'
                    suffix = ' ERROR'
            endcase
            AddLine( prefix + fn + suffix, filelist )
        endif
        NextFile(_DONT_LOAD_)
        n = n - 1
    endwhile
    ListAndGoto(start_file, filelist, maxl, "Buffer List", 1, length(prefix)+1)
    AbandonFile(filelist)
end mHskListOpenFiles
//
string proc BufferListStr()
    case Setting_BufferList
        when READONLY_BUFFERLIST_MOD_FNAME
            return( "*filename" )
        when READONLY_BUFFERLIST_RO_MOD_FNAME
            return( "R*filename" )
        when READONLY_BUFFERLIST_MOD_FNAME_RO
            return( "*filename (RO)" )
    endcase
    return( "***ERROR***" )
end
//
//
proc mToggle_Setting_BufferList()
    case Setting_BufferList
        when READONLY_BUFFERLIST_MOD_FNAME
            Setting_BufferList = READONLY_BUFFERLIST_RO_MOD_FNAME
        when READONLY_BUFFERLIST_RO_MOD_FNAME
            Setting_BufferList = READONLY_BUFFERLIST_MOD_FNAME_RO
        when READONLY_BUFFERLIST_MOD_FNAME_RO
            Setting_BufferList = READONLY_BUFFERLIST_MOD_FNAME
    endcase
end
//
// mHskListOpenFilesMenu() - Display a menu of options
Menu mHskListOpenFilesMenu()
    History
    Title = 'HSK Buffer List Menu'

    "&Buffer List"  [BufferListStr():14]     , mToggle_Setting_BufferList() , DontClose
end
