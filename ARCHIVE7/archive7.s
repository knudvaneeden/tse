/****************************************************************************
    Program: archive7.s
    By John Barbee,  JYB Developments
    Date: 07/11/93 08:49 pm, Windy Hill Software
    Place in the Public Domain
    Version:0.7

****************************************************************************/
/****************************************************************************
    BEGIN CHANGE LOG
        07/11/93 Begin Log
        07/11/93 08:50 pm  Changed mSaveasZip() so that you can archive
                       files into either a separate file or back into another zip.
    END CHANGE LOG
****************************************************************************/


/****************************************************************************
    mDelDir()- Used by mEditfile() to delete the temporary directory.  For DOS
            6.0 leave as is.  For previous versions of DOS comment out the
            line:

                dos("deltree /Y " + path + ">NUL",_DONT_PROMPT_)

            and uncomment:

                dos("del " + path + "\*.*",_DONT_PROMPT_)
                DOS("rd " + path + ">NUL",_DONT_PROMPT_)

    mEditfile()- This is used to retrieve an archived file for editing in the
            the current directory. The unarchive programs must be in the DOS
            path.

    mSaveAsZip()- This is used to save a file in to the current directory as
            an archived file using the three most common archive programs. It
            can also add a file into an existing archive file.  The archive
            programs must be in the DOS path.

    MenuZip()- Menu for mSaveAsZip().
****************************************************************************/

/****************************************************************************
    mDelDir
****************************************************************************/

proc mDelDir(string path)
    // dos("del " + path + "\*.*",_DONT_PROMPT_)
    // DOS("rd " + path + ">NUL",_DONT_PROMPT_)
    IF YesNo( Format( "Are you sure you want to completely delete this file path", ":", " ", path ) ) == 1
     IF YesNo( Format( "Really sure?" ) ) == 1
      dos("deltree /Y " + path + ">NUL",_DONT_PROMPT_)
     ENDIF
    ENDIF
end mDelDir


/****************************************************************************
    mEditfile
****************************************************************************/

proc mEditfile()

    string fn1[65] = PickFile(""),
           name1[65] = "",
           name2[12] = "",
           p_fn1[65] = SplitPath(CurrFileName(),_DRIVE_|_PATH_),
           p_fn2[65] = p_fn1 + "tmp",
           f_ext[65] = SubStr(SplitPath(fn1,_EXT_), 2, 3)

    if not length(fn1)
        return()
    endif
    if not FileExists(fn1)
        Warn(fn1, " does not exist; can't delete")
        halt
    endif
    case f_ext
        when "zip"
            dos("md " + "TMP",_DONT_PROMPT_)  // create TMP directory
            dos("pkunzip -o " + fn1 + " TMP>NUL",_DONT_PROMPT_) // unzip to TMP
        when "lzh"
            dos("md " + "TMP",_DONT_PROMPT_)                     // create TMP directory
            dos("lha -e -w" + " TMP>NUL",_DONT_PROMPT_ )         // unzip to TMP
        when "arj"
            dos("md " + "TMP",_DONT_PROMPT_)                     // create TMP directory
            dos("arj -e -w" + " TMP>NUL",_DONT_PROMPT_)
        otherwise
            EditFile(fn1)
            return()
    endcase
    EditFile(p_fn2 )        // select the unziped file to edit
    mdeldir(p_fn2)    // delete the temporary directory and erase files
    name1 = SplitPath(CurrFilename(),_DRIVE_|_PATH_)
    name2 = SplitPath(CurrFilename(),_NAME_|_EXT_)
    ChangeCurrFilename(SubStr(name1,1,length(name1)-4) + name2)

end mEditfile

/****************************************************************************
    Archive Menu
****************************************************************************/

menu menuzip()
    title = 'Archiving Menu'
    command = MenuOption()

    "&Zip"
    "&ARJ"
    "&LHA"

end menuzip



/****************************************************************************
    Save file as a zip file to current directory.
****************************************************************************/

proc mSaveAsZip()
    string fn1[65] = CurrFilename(),
           fn2[65],
           name1[8] = SplitPath(fn1,_NAME_),
           name2[12] = SplitPath(fn1,_NAME_|_EXT_),
           name3[3]


    SaveFile()
    if not length(fn1)
        return()
    endif
    if not FileExists(fn1)
        Warn(fn1, " does not exist; can't archive.")
        halt
    endif

    case YesNo("Do you want to archive " + fn1 + " to another archive file? (Y?N)")
        when 0,3                    // if escape or cancel press
            return()

        when 2
            case menuzip()           // if no, will archive to the same directory.
                when 1
                    dos("pkzip " + name1 + " " + name2 + " -!") // zip file to current directory.
                when 2
                    dos("arj a " + name1 + " " + name2) // use ARJ to archive file.
                when 3
                    dos("lha a " + name1 + " " + name2) // use LHA to archive file.
            endcase
            KillFile()
            return()

        when 1                 // if yes will reintroduce to the selected archive file.

            fn2 = PickFile("")
            name3 = SubStr(SplitPath(fn2,_EXT_), 2, 3)
            case name3
                when "zip","ZIP"
                    dos("pkzip " + fn2 + " " + name2)
                when "arj", "ARJ"
                    dos("arj -a " + fn2 + " " + name2)
                when "lha", "LHA"
                    dos("lha -a " + fn2 + " " + name2)
            endcase
            KillFile()
            return()
    endcase

end

