// *--------------------------------------------------------------------*
integer proc bin2i (string cTemp)
    return ((asc(cTemp[ 2]) shl 8) | asc(cTemp[ 1]))
end

// *--------------------------------------------------------------------*
integer proc bin2l (string cTemp)
    return ((asc(cTemp[ 4]) shl 24) |
            (asc(cTemp[ 3]) shl 16) |
            (asc(cTemp[ 2]) shl  8) |
            (asc(cTemp[ 1])))

end

// **************************************************************************
string proc dosDate (string pcDate)
    string  cDate[ 8]
    integer d = bin2i(pcDate)
    cDate = (Format(((d & 0x01E0) shr 5)               :2:'0', '/',
                     (d & 0x001F)                      :2:'0', '/',
                  ((((d & 0xFE00) shr 9) + 80) mod 100):2:'0'))
    return (cDate)
end


// **************************************************************************
string proc dosTime (string pcTime)
    string  cTime[ 8]
    integer t = bin2i(pcTime)
    cTime = (Format( ((t & 0xf800) shr 11):2:'0', ':',
                    ((t & 0x07e0) shr  5):2:'0', ':',
                    ((t & 0x001f) shl  1):2:'0'))
    return (cTime)
end

