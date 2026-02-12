//
//  Name:   LoadList.s
//
//  Author: Ian A Brown, 30-08-94
//
//  Notes:  This was my first hack at a 'complex' TSE macro, so I dare
//          say there are some glaringly awful bits of code in here, but
//          if nothing else, it will give the experienced guys something
//          to laugh at!
//
//  Usage:  Construct a file list of files to be loaded using, for example
//              DIR *.c /b
//              GREP -l "printf" *.c (or whatever lists filenames only)
//
//          Pipe the file list into another, temporary, file - eg:
//              DIR *.c /b >filelist
//
//          Invoke the editor passing this temporary filename, eg:
//              DIR *.c /b >filelist
//              E -pfilelist
//
//          Any other command line parameters will be passed through
//          untouched, ie:
//              E *.cpp -pfilelist *.h
//          would load in all .cpp and .h files, plus whatever was specified
//          within 'filelist'.
//
//          Finally, I believe that all error conditions are either handled
//          explicitly here, or at least safely by TSE itself.
//
//  TSE:    Because I didn't fancy having a standalone macro which I loaded
//          whenever I wanted this facility, I created the two routines
//          below within TSE.S and burned them into the editor. I am sure
//          that if required it could fairly easily be split out into its
//          own file.
//
//  Credits:
//          Although this is my own work, I got the idea from LSTLD. The
//          implementations are completely different, but I must thank the
//          LSTLD author (whose name I don't know) for inspiring me.
//
//  Comments or suggestions to  Ian.Brown@AIT.CO.UK
//


//  LoadFromList takes parameters passed to the editor with a -p switch
//  and loads the files contained in the associated file
//  eg. E -pfilelist.txt
//  nb. The rest of the command line is passed through untouched

proc mLoadFromList( string sCmdLine )
    string  sNewCmdLine[ 128 ]
    string  sListFile[ 128 ]
    integer iPOption
    integer iFileCount = 0

    iPOption = Pos( "-P", sCmdLine )
    if iPOption == FALSE
        iPOption = Pos( "-p", sCmdLine )
    endif

    if iPOption > 0
        //  The -p switch has been found, extract the -p filename from any
        //  other command line parameters, and reconstruct the DosCmdLine
        //  without it.

        if iPOption > 2
            sNewCmdLine = Substr( sCmdLine, 1, iPOption - 1 )
        endif

        if Pos( " ", SubStr( sCmdLine, iPOption, 128 ) )
            sNewCmdLine = sNewCmdLine + Substr( sCmdLine, iPOption + Pos( " ", SubStr( sCmdLine, iPOption, 128 ) ), 128 )
        endif

        Set( DosCmdLine, sNewCmdLine )

        //  Load in the files in the list

        sListFile = Substr( sCmdLine, ipOption + 2, iPOption + Pos( " ", SubStr( sCmdLine, iPOption, 128 ) ) )

        if Length( sListFile )
            EditFile( sListFile )

            Loop
                //  Use a '-a' switch here to load wildcards, not pop up a
                //  selection list

                //  Continue to process the file until there are no more
                //  lines, ignoring any blank lines found along the way.

                sNewCmdLine = "-a " + GetText( 1, 128 )

                if Length( sNewCmdLine ) > 3
                    if EditFile( sNewCmdLine )
                        iFileCount = iFileCount + 1
                    endif

                    EditFile( sListFile )
                endif

                if not Down()
                    Break
                endif
            EndLoop

            AbandonFile()
        endif

        Message( iFileCount, " filespec(s) loaded from file" )
    endif
end


//  ScanCommandLine is called from the WhenLoaded function in TSE.S.
//  If the command line is empty, a default/dummy filename is loaded,
//  otherwise the command line is passed to mLoadFromList for scanning

proc mScanCommandLine()
    string  sCmdLine[ 128 ] = Query( DosCmdLine )

    if Length( sCmdLine )
        //  If -p switch has been used, load the files from the list

        mLoadFromList( sCmdLine )
    else
        //  Set default file to load if none specified

        //  This is not required, but I find myself using TSE as a scratchfile
        //  editor more often than I run it to pop-up a filelist. If not
        //  required, remove the above 'else' line and this 'set' line

        Set( DosCmdLine, "untitled" )
    endif
end
