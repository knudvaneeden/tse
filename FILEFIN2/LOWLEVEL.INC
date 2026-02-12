// linkage to binary for low-level DOS file functions.
//
//  Peter Birch     08/11/94
//
// These are provided because I don't always want to read in a whole
// file for just a couple of bytes.  For example, reading the header of
// a multi megabyte zip file could take forever if loaded into an editing
// buffer, but this way it's quick and easy.


binary ["lowlevel.bin"]
    integer proc _open(string path)       : 0
    integer proc _seek(integer handle, integer offset, integer method) : 3
    integer proc _read(integer handle, var string buffer, integer bytes) : 6
    integer proc _close(integer handle) : 9
end

// for _seek method
constant    SEEK_SET   =    0       // seek from beginning of file
constant    SEEK_CUR   =    1       // seek from current position
constant    SEEK_END   =    2       // seek from end of file
