/*****************************************************************************
   The following macros and variables:
      - Cause a "beep" to sound whenever NextFile or PrevFile move you
        to the first file that was loaded
      - Change ListFiles so that the first file loaded is always at the
        top of the list
      - The procedure MakeFirst allows you to assign any file as the
        "first" file for the above

 NOTE:  This is not a stand-alone macro file.  At lease the global integer
        declaration and the OnFirstEdit procedure must be included in the
        User-Interface macro file.  I recommend including all of this,
        unless you desire the above effects only for certain editing
        purposes

 *****************************************************************************/


integer firstID=0       // id of the first file loaded, ADD to the
                        // global variables in TSE.S
proc OnFirstEdit()
        if firstID == 0                       //Add this to
                FirstID = getbufferid()       //your OnFirstEdit()
        endif                                 //procedure in TSE.S
end OnFirstEdit

// The following macros cause a short beep when nextfile or prevfile
//   move you to the first file loaded

proc mNextfile()
        nextfile()
                if getbufferid() == firstID
                        SOUND(300)
                        DELAY(1)
                        NOSOUND() //alarm()
                endif
end mNextfile

proc mPrevfile()
        Prevfile()
                if getbufferid() == firstID
                        SOUND(300)
                        DELAY(1)
                        NOSOUND() //alarm()
                endif
end mPrevfile

proc MakeFirst()   // Causes the current file to be considered
                   //  the "first" file
        firstID = GetBufferID()
        Message("Current File Now Marked as the First")
end MakeFirst


// This is a modification of the mListOpenFiles() included in TSE.S
// The file list always starts with the first file that was opened
//     instead of the current file
// My changes are noted

proc mListOpenFiles()
    integer start_file, filelist, id, rc, maxl, total, n
    string fn[65]

    n = NumFiles() + (Query(BufferType) <> _NORMAL_)
    if n == 0
        return ()
    endif
    maxl = 0
    total = 0
    start_file = GetBufferid()                 // Save current
    filelist = CreateTempBuffer()
    if filelist == 0
        warn("Can't create filelist")
        return ()
    endif

// The line below is the only change needed, provided the global
//    variable FirstID has been declared and the OnFirstEdit()
//    procedure has been included and Hooked.
//    Note:  uses ListIT() from TSE.S
    GotoBufferId(FirstID)              // WK Begin list w/the 1st File
//  GotoBufferId(start_file)   // This was the original line

    id = GetBufferid()
    while n
        fn = CurrFilename()
        if length(fn)
            if length(fn) > maxl
                maxl = length(fn)
            endif
            rc = isChanged()
            GotoBufferId(filelist)
            AddLine(iif(rc, '*', ' ') + fn)
            GotoBufferId(id)
        endif
        NextFile(_DONT_LOAD_)
        id = GetBufferid()
        n = n - 1
    endwhile
    GotoBufferId(filelist)
    BegFile()
//    Note:  uses ListIT() from TSE.S  <---------------------
    if ListIt("Buffer List", maxl)
        EditFile(GetText(2, sizeof(fn)))    // Force loading from disk
    else
        GotoBufferId(start_file)
    endif
    AbandonFile(filelist)
end mListOpenFiles

//  Change this to whatever key assignments you have for
//    NextFile() and PrevFile()
<Alt n>                 mNextfile()
<Alt p>                 mPrevfile()

