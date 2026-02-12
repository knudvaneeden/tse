//
//
//note  WARNING:   Do not change any line lengths in the database while
//note              editing
//
//
//  dbfEdit Version 1.2     Peter Birch     02/23/93



// struct DBF_HEADER
// {
//     byte            signature;       // 03 = dBaseIII dbf, 83 = dbf+dbt
//     byte            ymd[ 3];         // Date of last update. year = 1900 + ymd[0]
//     ulong           last_rec;        // number of database records
//     uint            header_bytes;    // Number of bytes in the header
//     uint            rec_size;        // the length of each record (in bytes)
//     byte            reserved1[ 3];   // reserved bytes
//     byte            reserved2[ 13];  // reserved for local area network access info
//     byte            reserved3[ 4];   // reserved bytes
//     struct FIELD    *fields;         // field descriptor array
//     byte            field_terminator;//  0x0d as the field terminator
// };

constant        REC_COUNT_OFFSET    =  5,
                HEADER_SIZE_OFFSET  =  9,
                RECORD_SIZE_OFFSET  = 11,
                SAVE_STATE          = -1,
                RESTORE_STATE       =  1


string  fileName[    64]         // name of dbf to edit
string  newFileName[ 64]
integer recCount
integer recordLength

forward proc saveDBF ()

// **************************************************************************
keydef dbfKeys
  <ctrl z>      saveDBF()
  <alt  z>      endProcess()
end dbfKeys


// **************************************************************************
integer proc getShortInt (integer nStart)

    integer tmpVal

    gotoColumn(nStart)
    tmpVal = currchar()

    right()
    tmpVal = tmpVal + (currchar() shl 8)

    return (tmpVal)
end

// **************************************************************************
integer proc getLongInt (integer nStart)
    integer tmpVal

    gotoColumn(nStart)
    tmpVal = currchar()

    right()
    tmpVal = tmpVal + (currchar() shl 8)

    right()
    tmpVal = tmpVal + (currchar() shl 16)

    right()
    tmpVal = tmpVal + (currchar() shl 24)

    return (tmpVal)
end


// **************************************************************************
proc putLongInt (integer nStart, integer newValue)

    gotoColumn(nStart)
    insertText(chr((newValue)        & 255), _OVERWRITE_)
    insertText(chr((newValue shr  8) & 255), _OVERWRITE_)
    insertText(chr((newValue shr 16) & 255), _OVERWRITE_)
    insertText(chr((newValue shr 24) & 255), _OVERWRITE_)

end


// **************************************************************************
integer proc editDBF ()

    integer oldWrap
    integer oldInsert
    integer oldEOF
    integer oldWhite
    integer oldBuffId

    integer newBuffId
    integer i
    integer headerBytes
    integer retval

    // set up and save state of stuff
    //      I'm not sure about some of these and binary mode edit
    //      I probably don't need to set some of these.
    oldWrap   = query(WordWrap)
    oldInsert = query(Insert)
    oldWhite  = query(RemoveTrailingWhite)
    oldEOF    = query(EofType)
    oldBuffId = getbufferid()   // save the original buffer id

    retval    = True


    // get database name
    if (ask("Enter database name:", fileName) and length(fileName) > 0)

        upper(fileName)

        // add .DBF if the extension was omited
        if (pos(".DBF", fileName) == 0)
            fileName = fileName + ".DBF"
        endif

        if (fileExists(fileName))

            editfile("-b1000 " + filename)

            newBuffId       = getBufferId()
            newFileName = splitpath(fileName, _NAME_)

            // is this a valid dBase file
            if (currchar() <> 3 and currchar() <> 83)
                warn("This is not a valid dBase database file")
                abandonFile(newBuffId)
                gotoBufferId(oldBuffId)
                return (False)
            endif

            // get header size
            headerBytes = getShortInt(HEADER_SIZE_OFFSET)

            // get record length
            recordLength = getShortInt(RECORD_SIZE_OFFSET)
            if (recordLength > MaxLineLen)
                warn("Can not edit because the record length is longer than " + format(MaxLineLen))
                abandonFile(newBuffId)
                gotoBufferId(oldBuffId)
                return (False)
            endif

            // get record count
            recCount = getLongInt(REC_COUNT_OFFSET)

            // mark database header
            gotoLine(1)
            gotoColumn(1)
            markStream()

            i = headerBytes
            while (i > 1000)
                down()
                i = i - 1000
            endwhile
            gotoColumn(i)
            markStream()

            // save header for later retrevial
            saveBlock(newFileName + ".HDR", _OVERWRITE_)

            // make a new file to edit minus the header
            cut()
            saveAs(newFileName + ".TMP", _OVERWRITE_)

            // dump the database before we hurt it
            abandonFile(newBuffId)

            // now edit the new file with the correct line length
            //
            editfile("-b" + format(recordLength) + " " + newFileName + ".TMP")
            newBuffId = getBufferId()

            set(WordWrap,   Off)
            set(Insert,     Off)
            set(EofType,    0)
            set(RemoveTrailingWhite, Off)

            if (Enable(dbfKeys, _DEFAULT_))
                Message("Press <Ctrl Z> to save/exit, <Alt Z> to abort " + fileName)
                process()
                Disable(dbfKeys)
            endif

            // clean up
            abandonFile(newBuffId)
            eraseDiskFile(newFileName + ".TMP")
            eraseDiskFile(newFileName + ".HDR")

        else
            warn(fileName + " does not exist!")
            retval = False
        endif

    endif

    gotoBufferId(            oldBuffId)
    set(EofType,             oldEOF)
    set(RemoveTrailingWhite, oldWhite)
    set(Insert,              oldInsert)
    set(WordWrap,            oldWrap)

    return (retval)
end

// **************************************************************************
proc saveDBF ()

   integer  newRecCount

   // get new record count
   endFile()
   left()
   newRecCount = currLine() - iif(currchar() == 26, 1, 0)  // -1 for ^Z


    // put header back on
    gotoLine(1)
    gotoColumn(1)
    insertFile(newFileName + ".HDR")
    unmarkBlock()

    // update database header with new record count if nessessary
    if (newRecCount <> recCount)
        putLongInt(REC_COUNT_OFFSET, newRecCount)
    endif


    // maybe rename old database for safety


    // save new database
    saveAs(fileName, _DEFAULT_)         // let it prompt to overwrite
    EndProcess()
end


// **************************************************************************
proc main ()
    editDBF()
end
