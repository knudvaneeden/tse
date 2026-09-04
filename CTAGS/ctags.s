// -*- C -*-
/*************************************************************************
  CTAGS       Adds TAG file support to TSE

  Date:       January 24, 1997  - Original Version
              January 27, 1997  - Keep "TAGS" file in hidden buffer
                                  instead of closing every search
              August 06, 1997   - Use source file path for root of
                                  'tag' file search algorithm instead
                                  of CurrDir() which has problems in
                                  Win32 version (2.6, 2.8)
              August 29, 1997   - Fixed minor bug with WordSets that
                                  was causing problems with C++ member
                                  functions (they were being found, but
                                  errors were reported)
                                - Fixed nastly little problem with spaces
                                  in filenames (seems like this one would
                                  have popped up sooner)

  Overview:

    This macro allows the use of TAG files like the ones used with VI etc.

  Keys:       <CtrlShift Enter>

  Usage notes:

    The TAG file can be in the current directory or in any directory above
    the current directory.

    NOTE: This macro has been tested ONLY with Exuberant Ctags 1.5 & 1.6

  There is no warranty of any kind related to this file.
  If you don't like that, don't use it.

*/

#ifdef WIN32
    constant MAXPATH = 255
#else
    constant MAXPATH = 80
#endif

string tagsfile[] = "tags"          // default filename
string escapes[]  = "@#{}[]*+?"     // characters that we must add backslash before
string unescapes[]= "/"             // characters that ctags got carried away with
string targetfile[MAXPATH]          // file that contains the tag
string object[128]                  // tag that we're looking for
string search[128]                  // tag label in the ctag generated file
string myRootDir[MAXPATH]           // where to start looking for tags file

// Try to find the 'tag' file
// Look in current directory first, then start looking up the tree

string proc findTagsfile(string basename)
    string dir[MAXPATH]

    string org[MAXPATH] = CurrDir()

    if FileExists(myRootDir + basename)           // see if there is a tags file
        return('"' + myRootDir + basename + '"')  // give it
    endif

    dir = myRootDir
    while(length(dir) > 3)              // only three letters would be the root
        Chdir("..\")                    // move back up the tree
        dir = CurrDir()                 // get current dir
        if FileExists(dir + basename)   // see if there is a tags file
            dir = dir + basename        // make full filename
            break
        endif
    endwhile

    ChDir(org)                          // restore original directory
    if(length(dir) == 3)                // check for complete failure
        return("")                      // failed
    endif
    return('"' + dir + '"')             // found one
end

// Check to see if a file is in the ring buffer
// if found, return it's buffer ID

integer proc mIsFileOpen(string name)
    integer start_file, id, n
    string fn[65]
    string full[65]

    n = NumFiles() + (BufferType() <> _NORMAL_)
    if n == 0
        return (0)
    endif
    start_file = GetBufferid()          // Save current
    GotoBufferId(start_file)
    id = GetBufferid()
    full = ExpandPath(name)
    while n
        fn = CurrFilename()
        id = GetBufferid()
        if(fn == full) break
        endif
        NextFile(_DONT_LOAD_)
        n = n - 1
    endwhile
    GotoBufferId(start_file)
    if(fn == full) n = id
    else n = 0
    endif
    return(n)
end mIsFileOpen


// This isn't doing anything any more, maybe it should be removed?    
proc switchFiles(string filename)
    integer id = mIsFileOpen(filename)
    if id
//        GotoBufferId(id)
        EditFile(filename)
    else
        EditFile(filename)
    endif
end

// See of the character is in a set of characters

integer proc isIn(string s, integer c)
    integer i = 1
    while(i <= length(s))
        if(s[i] == Chr(c))
            return(1)
        endif
        i = i + 1
    endwhile
    return(0)
end

// Look for characters we must add '\' to

integer proc checkEscape(integer c)
    return(isIn(escapes,c))
end

// Look for character we must remove a '\' from in front of

integer proc checkUnescape(integer c)
    return(isIn(unescapes,c))
end

// Add '\' to entire string
string proc escapeString(string s)
    integer i, i2
    string s2[90]
    i  = 1
    i2 = 1
    while(i <= length(s))
        if(checkEscape(Asc(s[i])))  // check for escapeable char
            s2[i2] = '\'            // escape it
            i2 = i2 + 1
        endif
        s2[i2] = s[i]               // copy the character
        i = i + 1
        i2 = i2 + 1
    endwhile

    return(s2)
end

// Remove unwanted '\'s from entire string
string proc unescapeString(string s)
    integer i, i2
    string s2[90]
    i  = 1
    i2 = 1
    while(i <= length(s))
        if(s[i] == '\' and
           checkUnescape(Asc(s[i+1])))
            i = i + 1                   // skip it
        else
            s2[i2] = s[i]               // copy it
            i = i + 1
            i2 = i2 + 1
        endif
    endwhile

    return(s2)
end


proc main()
    integer id
    integer lineNumber
    string  tagF[MAXPATH]
    string  orgSearch[128]

    string fileWordSet[32] = ChrSet("0-9A-Z_a-z.&+=:\\\-/")
    string longfileWordSet[32] = ChrSet(" 0-9A-Z_a-z.&+=:\\\-/")
    string objectWordSet[32] = ChrSet("0-9A-Z_a-z")

    string OrgWordSet[32] = Set(WordSet, objectWordSet)

    object = GetWord()                  // get current word

    if(length(object)==0)
        Set(WordSet, OrgWordSet)        // restore word set
        return()
    endif

    id = GetBufferid()                  // Save current buffer id

    // Try to file tags file
    tagF = findTagsfile(tagsfile)
    if(length(tagF)==0)
        Set(WordSet, OrgWordSet)        // restore word set
        Message("Can't file Tag File")  // show reqrets
        return()
    endif

    // switch to the tags file (open if needed)
    switchFiles(tagF)
    BufferType(_HIDDEN_)

    if lFind("^" + object, "xgw")       // try to find tag (at beginning of line)
        lFind("\t\c","xc")              // move to target filename
        Set(WordSet,fileWordSet)        // set wordset for files
        targetfile = GetWord()          // copy filename
        if(not FileExists(targetfile))
            Set(WordSet,longfileWordSet)// long filename type wordset
            targetfile = GetWord()      // copy filename
        endif
        if(not FileExists(targetfile))
            Message("Bad Filename in tag file")
            return()
        else
            targetfile = '"' + targetfile + '"'
        endif
        Right()
        lFind("\t\c","xc")              // move to next field (line number or regex)
        lineNumber = Val(GetWord())     // try to convert the line number

        if(lineNumber)                  // If we have a line number, goto line in file
            switchFiles(targetfile)     // change to the target file
            GotoLine(lineNumber)        // goto the line
            BegLine()
            Set(WordSet, objectWordSet)
            lFind(object,"cw")          // find the object
        else                            // else get regex
            Right()                     // move past '/'
            MarkToEol()                 // mark to the end of the line
            search = GetMarkedText()    // get the text

            // remove trailing '/'
            search = DelStr(search, length(search), 1)

            search = escapeString(search)   // add extra '\'s where needed
            search = unescapeString(search) // remove extra '\'s where NOT needed
            switchFiles(targetfile)         // change to the target file

            if lFind(search,"xg")           // find the line
                BegLine()
                Set(WordSet, objectWordSet)
                lFind(object,"cw")          // find the object
            else

                orgSearch = search          // save original string

                // this is nasty, but it works
                // Just keep hacking the search string down until we file something
                while(length(search))
                    search = DelStr(search, length(search), 1)
                    if(lFind(search,"xg"))
                        BegLine()
                        Set(WordSet, objectWordSet)
                        Find(object,"cw")   // find the object
                        break
                    endif
                endwhile

                // stuck out?
                if(length(search) == 0)
                    warn("Not Found:" + orgSearch)  // not found at all
                endif
            endif

        endif

        Set(WordSet, OrgWordSet)    // restore word set
        ScrollToCenter()            // put it in the center of screen
        return()                    // leave with cursor at tag

    endif

    Set(WordSet, OrgWordSet)                    // restore word set
    GotoBufferId(id)                            // switch back to original file and location
    Message("Tag <" + object + "> not found")   // show reqrets
    return()
end

proc WhenLoaded()
    // identify my place to start looking for the tags file
    myRootDir = CurrDir()
end

<CtrlShift Enter>   main()
