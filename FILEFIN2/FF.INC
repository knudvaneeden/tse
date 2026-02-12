// string      ffblk[ 43]      // space for new DTA

constant    _A_NORMAL   = 0        // Normal file-No read/write restrictions
constant    _A_RDONLY   = 1        // Read only file
constant    _A_HIDDEN   = 2        // Hidden file
constant    _A_SYSTEM   = 4        // System file
constant    _A_VOLID    = 8        // Volume ID file
constant    _A_SUBDIR   = 16       // Subdirectory
constant    _A_ARCH     = 32       // Archive file


constant    ALL_ATTRIBS = (_A_HIDDEN|_A_SYSTEM|_A_ARCH|_A_RDONLY|_A_SUBDIR)

// linkage to the binary
binary ["ff.bin"]
    integer proc _ff(string path, var string ffblk, integer attr) : 0
    integer proc _fn(var string ffblk) : 3
end


// **************************************************************************
integer proc FindFirst(string path, var string ffblk, integer attr)
    return(_ff(format(path, chr(0)), ffblk, attr))
end


// **************************************************************************
integer proc FindNext(var string ffblk)
    return(_fn(ffblk))
end


// **************************************************************************
string proc ffName(string ffblk)
    integer p = pos(chr(0),substr(ffblk,31,13))
    return (substr(ffblk,31,iif(p,p-1,13)))
end


// **************************************************************************
integer proc ffAttr (string ffblk)
    return (asc(ffblk[ 22]))
end


// // **************************************************************************
// string proc ffDate (string ffblk)
//     integer d = bin2i(substr(ffblk, 25, 2))
//     return (Format(((d & 0x01E0) shr 5)               :2:'0', '/',
//                     (d & 0x001F)                      :2:'0', '/',
//                  ((((d & 0xFE00) shr 9) + 80) mod 100):2:'0'))
// end
//
//
// // **************************************************************************
// string proc ffTime (string ffblk)
//     integer t = bin2i(substr(ffblk, 23, 2))
//     return (Format( ((t & 0xf800) shr 11):2:'0', ':',
//                     ((t & 0x07e0) shr  5):2:'0', ':',
//                     ((t & 0x001f) shl  1):2:'0'))
// end
//
//
//
// // **************************************************************************
// integer proc ffSize(string ffblk)
//     return ((asc(ffblk[ 30]) shl 24) |
//             (asc(ffblk[ 29]) shl 16) |
//             (asc(ffblk[ 28]) shl  8) |
//             (asc(ffblk[ 27])))
// end
//
// // **************************************************************************
// string proc ffAttributes (string ffblk)
//     string  cAttr[ 5] = ""
//
//     cAttr = format(cAttr, iif(ffAttr(ffblk) & _A_SUBDIR, 'd', '-'))
//     cAttr = format(cAttr, iif(ffAttr(ffblk) & _A_RDONLY, 'r', '-'))
//     cAttr = format(cAttr, iif(ffAttr(ffblk) & _A_HIDDEN, 'h', '-'))
//     cAttr = format(cAttr, iif(ffAttr(ffblk) & _A_SYSTEM, 's', '-'))
//     cAttr = format(cAttr, iif(ffAttr(ffblk) & _A_ARCH,   'a', '-'))
//
//     return (cAttr)
// end

