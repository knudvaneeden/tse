//
// Macro to Process files listed in a text file
//
// ASSUMPTIONS: The LISTFILE is an ascii text list of all files to be
//              loaded.  Each entry must be on a separate line and must
//              be in the current directory or alternatively have a full path
//              notation. e.g.  C:\TSE\MYFILE.S
//              There should be no blank lines in the list file.
//
// PARAMETERS:  none
//
// RETURNS:     nothing
//
// GLOBAL VARS: none
//
// LOCAL VARS:  sfilename   - string that is loaded with the current filename
//              cline       - current line in file
//              totline     - total lines in file
//              cnxtfile     - filename at cline
//
// SYNTAX to load and process a listfile->  E [LISTFILE name] -ELISTLOAD.MAC

proc MAIN()
        integer cline,totline
        string sfilename[38],cnxtfile[38]
        cline = 1                      // this saves our position on line 1
        totline=numlines()             // count all the lines in the file
        sfilename = CurrFileName()     // save the current list file name
        loop
                GotoLine(cline)        // jump to line
                GotoPos(1)
                //if not isWord()
                   //break
                //endif
                cnxtfile=GetText(1,38)  // get the file name
                EditFile(cnxtfile)      // load this file
                EditFile(sfilename)    // go back to list file
                if cline==totline      // break out if at end of file
                        break
                endif
                cline=cline+1          // advance to next line
        endloop
        AbandonFile()                  // close the list file

end

//
// End of Listload
//

