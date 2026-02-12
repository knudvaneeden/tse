
//
// tse2uni.c
// 3-Nov-2000 -chh  40th.com
// (C)2000 Huth
//
//
//
// takes a regular text file (fnA) as input
// writes a unicode file (fnU) as output
// etc.

#define STRICT
#define WIN32_LEAN_AND_MEAN
#include "windows.h"

int APIENTRY TseCopyAsciiToUnicode(const CHAR *srcPtr, const CHAR *destPtr, ULONG flags);
int APIENTRY TseCopyUnicodeToAscii(const CHAR *srcPtr, const CHAR *destPtr, ULONG flags);

// local protos

static int ioDeleteFile(const CHAR *filenamePtr);
static int ioCreateFile(const CHAR *filenamePtr);
static int ioOpenFile(const CHAR *filenamePtr, ULONG mode, HANDLE *handlePtr);
static int ioCloseFile(HANDLE handle);
static int ioReadFile(HANDLE handle, ULONG *bytesPtr, VOID *bufferPtr);
static int ioWriteFile(HANDLE handle, ULONG *bytesPtr, VOID *bufferPtr);
static int ioSeekFile(HANDLE handle, ULONG mode, ULONG *posPtr);
static int LengthFile(HANDLE handle, ULONG *lengthPtr);

#define TSE2UNI_OVERWRITE  1
#define OF_DENY_RW      0x10
#define OF_ACCESS_READ     0
#define OF_ACCESS_WRITE    1
#define OF_ACCESS_RW       2

// DllMain, don't care (just uses CRTL dll startup)


int APIENTRY TseCopyAsciiToUnicode(const CHAR *srcPtr, const CHAR *destPtr, ULONG flags) {

 int rc = 0;
 ULONG fileLen = 0;
 HANDLE srcH = INVALID_HANDLE_VALUE, destH = INVALID_HANDLE_VALUE;

 ULONG bytes, bytesLeft;

 BYTE buffRead[4096];
 BYTE buffWrite[8192];


 if ((UINT_PTR)srcPtr <= 65535 || (UINT_PTR)destPtr < 65535) return 1;


 rc = ioOpenFile(srcPtr, (OF_ACCESS_READ | OF_DENY_RW), &srcH);
 if (rc) goto ExitNow;

 rc = LengthFile(srcH, &fileLen);  // allow 0-length file
 if (rc) goto ExitNow;

 if (flags & TSE2UNI_OVERWRITE) ioDeleteFile(destPtr);

 rc = ioCreateFile(destPtr);
 if (rc) goto ExitNow;

 rc = ioOpenFile(destPtr, (OF_ACCESS_WRITE | OF_DENY_RW), &destH);
 if (rc) goto ExitNow;

 buffWrite[0] = 0xFF;
 buffWrite[1] = 0xFE;

 bytes = 2;
 rc = ioWriteFile(destH, &bytes, buffWrite);

 bytesLeft = fileLen;
 while(rc == 0 && bytesLeft) {

    bytes = sizeof(buffRead);
    if (bytes > bytesLeft) bytes = bytesLeft;

    rc = ioReadFile(srcH, &bytes, buffRead);
    if (rc == 0) {

       ULONG ir, iw;

       for (ir=0, iw=0; ir < bytes; ir++, iw=iw+2) {
          buffWrite[iw] = buffRead[ir];
          buffWrite[iw+1] = 0;
       }

       bytesLeft = bytesLeft - bytes;
       bytes = bytes << 1;

       rc = ioWriteFile(destH, &bytes, buffWrite);
    }
 }

 if (rc == 0 && bytesLeft != 0) rc = 255;

ExitNow:
 if (srcH != INVALID_HANDLE_VALUE) ioCloseFile(srcH);
 if (destH != INVALID_HANDLE_VALUE) ioCloseFile(destH);

 return rc;
}


int APIENTRY TseCopyUnicodeToAscii(const CHAR *srcPtr, const CHAR *destPtr, ULONG flags) {

 int rc = 0;
 ULONG fileLen = 0;
 HANDLE srcH = INVALID_HANDLE_VALUE, destH = INVALID_HANDLE_VALUE;

 ULONG bytes, bytesLeft;

 BYTE buffRead[8192];
 BYTE buffWrite[4096];


 if ((UINT_PTR)srcPtr <= 65535 || (UINT_PTR)destPtr < 65535) return 1;


 rc = ioOpenFile(srcPtr, (OF_ACCESS_READ | OF_DENY_RW), &srcH);
 if (rc) goto ExitNow;

 rc = LengthFile(srcH, &fileLen);
 if (rc) goto ExitNow;
 if (fileLen < 2) {
    rc = 1;
    goto ExitNow;
 }

 bytes = 2;
 rc = ioReadFile(srcH, &bytes, buffRead);

 if (buffRead[0] != 0xFF && buffRead[1] != 0xFE) {
    rc = 13;
    goto ExitNow;
 }

 fileLen = fileLen - bytes;

 if (flags & TSE2UNI_OVERWRITE) ioDeleteFile(destPtr);

 rc = ioCreateFile(destPtr);
 if (rc) goto ExitNow;

 rc = ioOpenFile(destPtr, (OF_ACCESS_WRITE | OF_DENY_RW), &destH);
 if (rc) goto ExitNow;

 bytesLeft = fileLen;
 while(rc == 0 && bytesLeft) {

    bytes = sizeof(buffRead);
    if (bytes > bytesLeft) bytes = bytesLeft;

    rc = ioReadFile(srcH, &bytes, buffRead);
    if (rc == 0) {

       ULONG ir, iw;

       for (ir=0, iw=0; ir < bytes; ir=ir+2, iw++) {
          buffWrite[iw] = buffRead[ir];
       }

       bytesLeft = bytesLeft - bytes;
       bytes = bytes >> 1;

       rc = ioWriteFile(destH, &bytes, buffWrite);
    }
 }

 if (rc == 0 && bytesLeft != 0) rc = 255;

ExitNow:
 if (srcH != INVALID_HANDLE_VALUE) ioCloseFile(srcH);
 if (destH != INVALID_HANDLE_VALUE) ioCloseFile(destH);

 return rc;
}


// --------------------------------------------------------
//  in: filenamePtr -> filename to delete
// out: rc
// nts:

static int ioDeleteFile(const CHAR *filenamePtr) {

 int rc = 0, rc2;

 rc2 = DeleteFile(filenamePtr);
 if (rc2 == 0) rc = GetLastError();

 return rc;
}


// --------------------------------------------------------
//  in: filenamePtr -> filename to create
// out: rc
// nts: handle is closed after file is created
//      see OpenFile() for openmode flags
//
//      if file exists, the open returns 183
//
// INVALID_HANDLE_VALUE          = 0FFFFFFFFh ;(-1)
// INVALID_FILE_SIZE             = 0FFFFFFFFh
//
// CREATE_NEW                    = 1
// CREATE_ALWAYS                 = 2
// OPEN_EXISTING                 = 3
// OPEN_ALWAYS                   = 4
// TRUNCATE_EXISTING             = 5
//
// FILE_BEGIN                    = 0
// FILE_CURRENT                  = 1
// FILE_END                      = 2
//
// GENERIC_READ                  = 80000000h
// GENERIC_WRITE                 = 40000000h
//
// FILE_SHARE_READ               = 00000001h
// FILE_SHARE_WRITE              = 00000002h
//
// FILE_ATTRIBUTE_READONLY       = 00000001h
// FILE_ATTRIBUTE_HIDDEN         = 00000002h
// FILE_ATTRIBUTE_SYSTEM         = 00000004h
// FILE_ATTRIBUTE_DIRECTORY      = 00000010h
// FILE_ATTRIBUTE_ARCHIVE        = 00000020h
// FILE_ATTRIBUTE_NORMAL         = 00000080h
// FILE_ATTRIBUTE_TEMPORARY      = 00000100h ;best w/ FILE_FLAG_DELETE_ON_CLOSE
// FILE_ATTRIBUTE_ATOMIC_WRITE   = 00000200h ;don't use
// FILE_ATTRIBUTE_XACTION_WRITE  = 00000400h ;don't use
//
// FILE_FLAG_POSIX_SEMANTICS     = 01000000h ;don't use
// FILE_FLAG_BACKUP_SEMANTICS    = 02000000h ;don't use
// FILE_FLAG_DELETE_ON_CLOSE     = 04000000h ;(can't use since I close on create)
// FILE_FLAG_SEQUENTIAL_SCAN     = 08000000h
// FILE_FLAG_RANDOM_ACCESS       = 10000000h
// FILE_FLAG_NO_BUFFERING        = 20000000h ;NEVER use since needs sector-align (work in index file? memo?)
// FILE_FLAG_OVERLAPPED          = 40000000h ;don't use
// FILE_FLAG_WRITE_THROUGH       = 80000000h

static int ioCreateFile(const CHAR *filenamePtr) {

 int rc = 0, rc2;
 HANDLE handle;
 SECURITY_ATTRIBUTES sa;

 sa.nLength = sizeof(SECURITY_ATTRIBUTES);
 sa.lpSecurityDescriptor = (SECURITY_DESCRIPTOR *)0;
 sa.bInheritHandle = 0;

 handle = CreateFile(filenamePtr,
                     GENERIC_READ | GENERIC_WRITE,
                     0,         // share mode 0=deny all
                     &sa,
                     CREATE_NEW,
                     FILE_ATTRIBUTE_NORMAL,
                     0);

 if (handle == INVALID_HANDLE_VALUE) {
    rc = GetLastError();        // 183 = ERROR_ALREADY_EXISTS
 }
 else {
    rc2 = CloseHandle(handle);
    if (rc2 == 0) rc = GetLastError();
 }

 return rc;
}


// --------------------------------------------------------
//  in: filenamePtr -> filename to open
//      mode = open mode (see below)
//      handlePtr -> var to store handle
// out: rc
// nts: for opening, not creating
//
// mode modified before getting here to the following (bit forms not specified are likely invalid):
//
//   bit15=0
//   bit14=1 write through                      (INT21/6C bit14=1 OPEN_FLAGS_COMMIT      4000h)
//   bit13=1 I/O errors returned to caller      (INT21/6C bit13=1 OPEN_FLAGS_NOCRIT_ERR  2000h)
//   bit12=1 (FAT32) extended size (allow 4GB files instead of 2GB)
//            otherwise: bypass cache entirely  (not specifically used by INT21/6C)
//   bit11=0
//   bits10-8:  000 no locality                 (not specifically used by INT21/6C)
//              001 mainly sequential
//              010 mainly random
//              011 random with some locality
//   bit 7=1 no inherit to child prgs
//   bit 6-4:   000 no share specified (aka 'compatibility' mode, should -not- be used)
//              001 share deny read/write
//              010 share deny write
//              011 share deny read
//              100 share deny none
//   bit 3=0
//   bit 2-0:  000 access read only
//             001 access write only
//             010 access read/write
//             100 access read-only, do not modify file's last-access time (DOS 7.0)
//
// GENERIC_READ                   = 80000000h
// GENERIC_WRITE                  = 40000000h
// FILE_SHARE_READ                = 00000001h
// FILE_SHARE_WRITE               = 00000002h
//
// FILE_ATTRIBUTE_READONLY        = 00000001h
// FILE_ATTRIBUTE_HIDDEN          = 00000002h
// FILE_ATTRIBUTE_SYSTEM          = 00000004h
// FILE_ATTRIBUTE_DIRECTORY       = 00000010h
// FILE_ATTRIBUTE_ARCHIVE         = 00000020h
// FILE_ATTRIBUTE_NORMAL          = 00000080h
// FILE_ATTRIBUTE_TEMPORARY       = 00000100h ;best w/ FILE_FLAG_DELETE_ON_CLOSE
// FILE_ATTRIBUTE_ATOMIC_WRITE    = 00000200h ;don't use
// FILE_ATTRIBUTE_XACTION_WRITE   = 00000400h ;don't use
// FILE_FLAG_POSIX_SEMANTICS      = 01000000h ;don't use
// FILE_FLAG_BACKUP_SEMANTICS     = 02000000h ;don't use
// FILE_FLAG_DELETE_ON_CLOSE      = 04000000h ;(can't use since I close on create)
// FILE_FLAG_SEQUENTIAL_SCAN      = 08000000h
// FILE_FLAG_RANDOM_ACCESS        = 10000000h
// FILE_FLAG_NO_BUFFERING         = 20000000h ;NEVER use since needs sector-align
// FILE_FLAG_OVERLAPPED           = 40000000h ;don't use
// FILE_FLAG_WRITE_THROUGH        = 80000000h
//
// Win32: these access/share modes are translated as best as is possible
//  if bit14=1 80000000h  FILE_FLAG_WRITE_THROUGH
//  if bit13=1 n/a
//  if bit12=1 n/a
//  if bits10-8:
//     0100h=  08000000h  FILE_FLAG_SEQUENTIAL_SCAN
//     0200h=  10000000h  FILE_FLAG_RANDOM_ACCESS
//     0300h=  18000000h  (both?)
//  if bit7:
//     0080h=  if set sa inherit set to false
//  if bits4-6:
//     0010h=  00000000h  Deny_All (Win32=deny read/write)
//     0020h=  00000001h  FILE_SHARE_READ (deny write)
//     0030h=  00000002h  FILE_SHARE_WRITE (deny read)
//     0040h=  00000003h  Deny_None
//  if bits0-2:
//     0000h=  80000000h  GENERIC_READ (read only)
//     0001h=  40000000h  GENERIC_WRITE (write only)
//     0002h=  C0000000h  (both?)

static int ioOpenFile(const CHAR *filenamePtr, ULONG mode, HANDLE *handlePtr) {

 int rc = 0;
 ULONG access = 0, share, attr, tMode;
 HANDLE handle;
 SECURITY_ATTRIBUTES sa;

 sa.nLength = sizeof(SECURITY_ATTRIBUTES);
 sa.lpSecurityDescriptor = 0;
 sa.bInheritHandle = 0;

 tMode = mode & 7;
 switch(tMode) {
 case 0:
    access = GENERIC_READ;
    break;
 case 1:
    access = GENERIC_WRITE;
    break;
 case 2:
 case 4:
    access = GENERIC_READ | GENERIC_WRITE;
    break;
 default:
    rc = 12; //EXB_INVALID_ACCESS
 }
 if (rc) goto ExitNow;

 share = (mode >> 4) & 7;
 if (share) share--;      // make 1 to 4 into 0 to 3

 attr = 0;
 if (mode & (1 << 8))  attr = attr | FILE_FLAG_SEQUENTIAL_SCAN;
 if (mode & (1 << 9))  attr = attr | FILE_FLAG_RANDOM_ACCESS;
 if (mode & (1 << 14)) attr = attr | FILE_FLAG_WRITE_THROUGH;

 handle = CreateFile(filenamePtr,
                      access,
                      share,
                      &sa,
                      OPEN_EXISTING,
                      attr,
                      0);

 if (handle == INVALID_HANDLE_VALUE) {
    rc = GetLastError();
    goto ExitNow;
 }

 *handlePtr = handle;

ExitNow:
 return rc;
}


// --------------------------------------------------------
//  in: handle = handle to close
// out: rc
// nts:

static int ioCloseFile(HANDLE handle) {

 int rc = 0, rc2;

 rc2 = CloseHandle(handle);
 if (rc2 == 0) rc = GetLastError();

 return rc;
}



// --------------------------------------------------------
//  in: handle to read from
//      bytesPtr -> bytes to read/bytes read (set bytesRead = 0 if fails other than EOF)
//      bufferPtr -> buffer to store to
// out: rc
// nts: returns EXB_UNEXPECTED_EOF if bytes requested not same
//      as bytes read (still did read for count in bytesPtr)
//
//      sets *bytesPtr to 0 if fails other than EOF

static int ioReadFile(HANDLE handle, ULONG *bytesPtr, VOID *bufferPtr) {

 int rc = 0, rc2;
 ULONG bytesRead;

 rc2 = ReadFile(handle, bufferPtr, *bytesPtr, &bytesRead, 0); // 0=no overlap
 if (rc2) {
    if (*bytesPtr != bytesRead) {
       rc = 38; //EXB_UNEXPECTED_EOF
    }
    *bytesPtr = bytesRead;
 }
 else {
    rc = GetLastError();
    *bytesPtr = 0;
 }

 return rc;
}


// --------------------------------------------------------
//  in: handle to write to
//      bytesPtr -> bytes to write/bytes written (only if successful, left as-is if fails)
//      bufferPtr -> buffer to write from (if bytes==0 and this is -1, using 64-bit file I/O)
// out: rc
// nts: if *bytesPtr = 0 (bytes to write = 0) then bufferPtr -must- be NULL
//      -- truncate file at current file ptr (must be null as of 3.1, previously just may have been)
//      if not enough space to write all bytes, then no bytes are written
//      and sBytesWritten=0 (in which case I set eax=39 and CF=1)
//      Truncation is not done by Write, but by SetFileSize, so it is vectored to if *bytesPtr=0

static int ioWriteFile(HANDLE handle, ULONG *bytesPtr, VOID *bufferPtr) {

 int rc = 0, rc2;
 ULONG bytesWritten;

 if (*bytesPtr) {
    rc2 = WriteFile(handle, bufferPtr, *bytesPtr, &bytesWritten, 0);
    if (rc2 == 0) {
       rc = GetLastError();
    }
    else if (bytesWritten != *bytesPtr) {
       rc = 39; //EXB_DISK_FULL
    }
    else {
       *bytesPtr = bytesWritten;
    }
 }
 else {
    //if (bufferPtr == NEG_ONE) bufferPtr = 0;    // linux needs notice for its seek64, not needed here

    // note: "current position" is going to be the last position+1
    // bufferPtr not used when bytes (when truncating)
    // -- sets EOF at current position

    rc2 = SetEndOfFile(handle);
    if (rc2 == 0) rc = GetLastError();
 }

 return rc;
}


// --------------------------------------------------------
//  in: handle = handle of file to seek on
//      mode = 0=seek from start, 1=seek from current pos, 2=seek from end (31-bit max size)
//      *posPtr -> (signed)amount to seek/(unsigned)var to store position
// out: rc
// nts: 0=start move at the beginning of file
//      1=start move at the current file pointer location
//      2=start move at the endof the file

static int ioSeekFile(HANDLE handle, ULONG mode, ULONG *posPtr) {

 int rc = 0;

 LONG newPos;
 LONG *newPosPtr = (LONG *)posPtr;   // alias posPtr to LONG type

 newPos = SetFilePointer(handle, *newPosPtr, 0, mode);
 if (newPos == -1) {
    rc = GetLastError();
 }
 else {
    *newPosPtr = newPos;
 }

 return rc;
}


// --------------------------------------------------------
//  in: handle = handle of file to get length of
//      *length -> var to store length
// out: rc
// nts:

static int LengthFile(HANDLE handle, ULONG *lengthPtr) {

 int rc;
 ULONG orgPos = 0;

 if (lengthPtr == 0) return 1; //EXB_NULLPTR;

 *lengthPtr = 0;
 rc = ioSeekFile(handle, 1, &orgPos);      // get curr pos
 if (rc == 0) {
    rc = ioSeekFile(handle, 2, lengthPtr); // from end of file, get pos (i.e., length)
    ioSeekFile(handle, 0, &orgPos);        // restore original pos
 }

 return rc;
}
