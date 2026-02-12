1. -To install

     1. -Take the file archive7_knud.zip

     2. -And unzip it in any arbitrary directory

     3. -Then run the file zipinstallarchive7.bat

     4. -That will create a new file archive7_knud.zip
         in that directory

     5. -Unzip that latest file in a new arbitrary directory

     6. -Then run the file

          archive7.mac

2. -The .ini file is the local file 'archive7.ini'
    (thus not using tse.ini)


****************************************************************************
    Program: archive7.s
    By John Barbee,  JYB Developments
    Date: 07/11/93 08:49 pm, Windy Hill Software
    Placee in the Public Domain
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
