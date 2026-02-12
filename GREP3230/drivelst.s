/****************************************************************************\

    DriveLst.S

    List of available drives.

    Version         v2.10/11.06.01
    Copyright       (c) 1995-2001 by DiK

    Usage Notes:

    This macro is part of the OpenFile dialog and it is not necessary
    to execute it manually.

    History

    v2.10/11.06.01  adaption to TSE32 v3.0
                    þ added drive type info
                    þ named drive list buffer
                    þ centered splash screen
    v2.01/10.11.97  adaption to TSE32
                    þ minor bug fix
    v2.00/24.10.96  adaption to TSE32
                    þ wrote 32-bit portion using kernel32 functions
    v1.21/17.05.96  maintenance
                    þ use Set(MsgLevel) instead of PushKey(<Escape>)
    v1.20/25.03.96  maintenance
    v1.10/12.01.96  maintenance
                    þ fixed splash box color
    v1.00/11.10.95  first version

    Problems:

    Volume label for network drives broken.

\****************************************************************************/

/****************************************************************************\
    global variables
\****************************************************************************/

integer drvsbuff                        // drive list

/****************************************************************************\
    externals
\****************************************************************************/

#IFDEF WIN32

constant
    DRIVE_UNKNOWN       = 0,
    DRIVE_NO_ROOT_DIR   = 1,
    DRIVE_REMOVABLE     = 2,
    DRIVE_FIXED         = 3,
    DRIVE_REMOTE        = 4,
    DRIVE_CDROM         = 5,
    DRIVE_RAMDISK       = 6

dll "<kernel32.dll>"

    integer proc GetLogicalDriveStrings(
        integer     nBufferLength,
        string      lpBuffer                    : StrPtr
    )
    : "GetLogicalDriveStringsA"

    integer proc GetVolumeInformation(
        string      lpRootPathName              : CStrVal,
        string      lpVolumeNameBuffer          : StrPtr,
        integer     nVolumeNameSize,
        var integer lpVolumeSerialNumber,
        var integer lpMaximumComponentLength,
        var integer lpFileSystemFlags,
        string      lpFileSystemNameBuffer      : StrPtr,
        integer     nFileSystemNameSize
    )
    : "GetVolumeInformationA"

    integer proc GetDriveType(
        string      lpRootPathName              : CStrVal
    )
    : "GetDriveTypeA"
end

#ENDIF

/****************************************************************************\
    get drive info: low level search routine
\****************************************************************************/

#ifdef WIN32

proc lSearchDrives()
    constant SIZE = 128
    integer i, dl, vl
    integer dummy
    string drives[SIZE] = ""
    string sysname[SIZE] = ""
    string volname[SIZE] = ""
    string voltype[32] = ""

    dl = GetLogicalDriveStrings(SIZE,drives)
    PokeWord(Addr(drives),dl)
    for i = 1 to dl by 4
        if Lower(drives[i]) in "a","b"
            volname = ""
            voltype = "[floppy]"
        else
            vl = GetVolumeInformation(
                    drives[i:3],volname,SIZE,dummy,dummy,dummy,sysname,SIZE)
            if vl
                PokeWord(Addr(volname),SIZE)
                vl = Pos(Chr(0),volname) - 1
            endif
            PokeWord(Addr(volname),vl)
            if Length(volname)
                volname = volname + " "
            endif
            vl = GetDriveType(drives[i:3])
            case vl
                when DRIVE_FIXED      voltype = "[fixed]"
                when DRIVE_REMOTE     voltype = "[remote]"
                when DRIVE_CDROM      voltype = "[cdrom]"
                when DRIVE_RAMDISK    voltype = "[ramdisk]"
                otherwise             voltype = "[unknown]"
            endcase
        endif
        AddLine(Format(drives[i],":\  ",volname,voltype))
    endfor
end

#else

proc lSearchDrives()
    register r
    integer rc, drive, count
    string label[16], dta[48] = ""

    // check floppy drives

    Intr(0x11,r)
    if r.ax & 0x01
        count = ((r.ax & 0xC0) shr 6) + 1
    else
        count = 0
    endif
    for drive = 1 to count
        AddLine(Format(Chr(Asc('a')+drive-1),":"))
    endfor

    // check non-floppy drives

    for drive = 3 to 26
        r.ax = 0x3600
        r.dx = drive
        Intr(0x21,r)
        if r.ax <> 0xFFFF
            label = ""
            SetDTA(dta)
            rc = FindFirst(Chr(Asc('a')+drive-1)+":\*.*",_VOLUME_)
            while rc
                if Asc(dta[22]) & _VOLUME_
                    label = Lower(Trim(SubStr(DecodeDTA(dta),2,12)))
                    break
                endif
                rc = FindNext()
            endwhile
            if Length(label) > 8
                label = DelStr(label,9,1)
            endif
            AddLine(Format(Chr(Asc('a')+drive-1),":":-2,label))
        endif
    endfor
end

#endif

/****************************************************************************\
    get drive info: message panel routine
\****************************************************************************/

proc SearchDrives()
    constant width = 50
    integer splash_color = Color( bright white on white )
    integer box, crs, msg, x1, x2

    // get display color

    msg = Set(MsgLevel,_NONE_)
    if ExecMacro("DlgGetColor Dialog_Normal")
        splash_color = Val(Query(MacroCmdLine))
    endif
    Set(MsgLevel,msg)

    // warn user about delay

    x1 = (Query(ScreenCols) - width) / 2
    x2 = x1 + width

    box = PopWinOpen(x1,7,x2,11,1,"",splash_color)
    if box
        crs = Set(Cursor,OFF)
        Set(Attr,splash_color)
        ClrScr()
        PutCtrStr("Reading drive info. Please wait.",2)
    endif

    // search available drives

    lSearchDrives()

    // close message box

    if box
        PopWinClose()
        Set(Cursor,crs)
    endif
end

/****************************************************************************\
    setup
\****************************************************************************/

proc WhenLoaded()
    integer bid

    bid = GetBufferId()
    drvsbuff = CreateTempBuffer()
    ChangeCurrFilename("*Dialogs Drive List*", _DONT_PROMPT_|_DONT_EXPAND_)
    if drvsbuff
        SearchDrives()
    else
        Warn("DriveLst: Cannot allocate work space")
        PurgeMacro(CurrMacroFilename())
    endif
    GotoBufferId(bid)
end

/****************************************************************************\
    shutdown
\****************************************************************************/

proc WhenPurged()
    AbandonFile(drvsbuff)
end

/****************************************************************************\
    scan drives
\****************************************************************************/

public proc ScanDrives()
    integer bid

    bid = GotoBufferId(drvsbuff)
    EmptyBuffer()
    SearchDrives()
    GotoBufferId(bid)
end

/****************************************************************************\
    main program
\****************************************************************************/

proc Main()
    Set(MacroCmdLine,Str(drvsbuff))
end

