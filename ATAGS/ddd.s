/*
  ATAGS.S     Assembly TAGs file support to TSE
  Author      LeChee.Lai

  Date:       July 29, 1999     - Preliminary Version

  Overview:

     This macro allows the use of TAG files like the ones used with VI etc.

  Keys:       <Ctrl F>    Active AsmTAG under cursor
              <Ctrl B>    Pop Last AsmTAG

  Usage notes:

    NOTE: This macro has been tested ONLY with Atags 1.29 by phoenix

  There is no warranty of any kind related to this file.
  If you don't like that, don't use it.

Requirements --------------------------------------------------------------

ù semware (books.mac)

*/

/*

[File: Source: ATAGS.DOC]

===

ATAGs v1.09  (AsmTAG and CTAG for TsePRO)
Lechee.Lai
lecheel@yahoo.com

Info ----------------------------------------------------------------------

ATAGs is a powerful facility to search symbol for MASM. which build index
file by phoenix Atags utility, it very siminlar like Exuberant Ctags
which can found http://ctags.sourceforge.net/ so far ATAGs v1.09 can support
those two format for ASM and C Language yap you are correct they use the
same key which depend on file name extension

Load the ATAGS macro, or add it to your AutoLoad list.
<Ctrl F>        to active ATAGs under cursor
<Ctrl B>        bring back for last ATAGs
<CtrlAlt '>     Create Index TAGV3.DAT

Some hilights include:

      Create DOS Console Environment SET TAGFILE=X:\PATH first
       which locate the project in you directory

      lack Atags utility it is because ATAGs is not freeware by the
       way you can use internal Atags Creater by hit "CtrlAlt '"
       which will create TAGV3.DAT in you Project directory of course
       their are many feature need to enhance, I'm glad if someone can
       enhacne this feature.


      Works on TSE 2.8 and TSE 3.0
       2.8 need to change cmpistr() to cmpstr() TsePRO 3.0 change internal
       API not full compatible with 2.8

      if you are using C language only you don't need to
       set TAGFILE=X:\PATH

      default ATAGS.MAC compile with TsePRO 3.0

History -------------------------------------------------------------------

v1.09 Build With CTAGS
      so far ATAGs can work as AsmTAG and Ctags depend on file name extension

v1.08 Backward function and Relayout the KeyAssign

v1.07 BugFix for Label And Enhance Find Token Structure

v1.06 BugFix for Duplicate found

v1.05 Add Phoenix ATags 1.29 Backward Compatible TagV2.DAT
      Auto switch if TagV3.DAT not exist

v1.04 todo Make TagV3.DAT

v1.03 Add Duplicate pattern fill in List for select UiN will auto goto target

v1.02 Add Label Support

v1.01 Add GetEnvStr Set Tagfile=[Drive]:\Path

*/

// v1.01 Add GetEnvStr Set Tagfile=[Drive]:\Path
// v1.02 Add Label Support
// v1.03 Add Duplicate pattern fill in List for select UiN will auto goto target
// v1.04 todo Make TagV3.DAT
// v1.05 Add Phoenix ATags 1.29 Backward Compatible TagV2.DAT // Auto switch if TagV3.DAT not exist
// v1.06 BugFix for Duplicate found
// v1.07 BugFix for Label And Enhance Find Token Structure
// v1.08 Backward function and Relayout the KeyAssign
// v1.09 Build With CTAGS

#ifdef WIN32
    constant MAXPATH = 255
#else
    constant MAXPATH = 80
#endif

///////////////////////////////////////////////////////////////////////////

string StVer[]    = "v1.09"             // todo v1.09

string tagsfile[]  = "TagV3.dat"        // default filename
string ctagsfile[] = "Tags"
string escapes[]  = "@#{}[]*+?"         // characters that we must add backslash before
string unescapes[]= "/"                 // characters that ctags got carried away with
string targetfile[MAXPATH]              // file that contains the tag
string object[128]                      // tag that we're looking for
string search[128]
string search1[128]                     // tag label in the atag generated file
string search2[128]                     // tag label in the atag generated file
string myRootDir[MAXPATH]               // where to start looking for tags file

integer idTags,NewId,DirId              // Atags Temporary Buffer
integer CurrId

integer                                 // Last Tags for Backward purpose
    LastTag = Asc('z')

keydef ListKeys
end

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



proc ListStartup()
    Unhook(ListStartup)
    if Enable(ListKeys)
        ListFooter("{Enter}-Goto  {Escape}-Cancel")
    endif
end

proc CheckLastMark()
    integer TmpMark = Asc('A')
    integer i
    for i = 0 to 16
        if isBookMarkSet(Chr(TmpMark))
            TmpMark = TmpMark + 1
        else
            break
        endif
    endfor
    LastTag = TmpMark
end

/*
proc DeleteMark()
    integer i
    for i = LastTag to 64+16       // Reserve Last 10 Mark for manual use
        DelBookMark(Chr(i))
    endfor
end
*/

proc GotoLastPosition()
    if LastTag > 64
        GotoMark(Chr(LastTag))
        DelBookMark(Chr(LastTag))
        LastTag = LastTag - 1
    else
        Message("TAG Buffer is Empty.")
    endif
end

proc cmain()
    integer id
    integer lineNumber
    string  tagF[MAXPATH]
    string  orgSearch[128]

    string fileWordSet[32] = ChrSet("0-9A-Z_a-z.&+=:\\\-/")
    string longfileWordSet[32] = ChrSet(" 0-9A-Z_a-z.&+=:\\\-/")
    string objectWordSet[32] = ChrSet("0-9A-Z_a-z")

    string OrgWordSet[32] = Set(WordSet, objectWordSet)

    myRootDir = CurrDir()
    CheckLastMark()

    PlaceMark(Chr(LastTag))

    object = GetWord()                  // get current word

    if(length(object)==0)
        Set(WordSet, OrgWordSet)        // restore word set
        return()
    endif

    id = GetBufferid()                  // Save current buffer id

    // Try to file tags file
    tagF = findTagsfile(ctagsfile)
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

proc amain()
    integer id, EditId, i,  iCount = 0
    integer SearchOK = 0
    integer Finish   = 0
    string  tagF[MAXPATH]
    string  orgSearch[128]
    string  TmpStr[128]

    string longfileWordSet[32] = ChrSet(" 0-9A-Z_a-z.&+=:\\\-/@")
    string objectWordSet[32] = ChrSet("0-9A-Z_a-z@")

    string OrgWordSet[32] = Set(WordSet, objectWordSet)
    CheckLastMark()

//    DeleteMark()
    PlaceMark(Chr(LastTag))

    object = GetWord(TRUE)              // get current word Token

    if(length(object)==0)
        Set(WordSet, OrgWordSet)        // restore word set
        return()
    endif

    id = GetBufferid()                  // Save current buffer id

    if FileExists(myRootDir + tagsfile) // Check tags file exist
        tagF = myRootDir + tagsfile
    else
        tagsfile = "TagV2.DAT"          // Check Backward Compatible TagV2.DAT
        if FileExists(myRootDir + tagsfile)
            tagF = myRootDir + tagsfile
        else
            Set(WordSet, OrgWordSet)    // restore word set
            Message("TagV3.DAT not found at "+ myRootDir)  // show reqrets
            return()
        endif
    endif

    if not GotoBufferId(idTags)
//        idTags = CreateBuffer("SearchResult",_NORMAL_)
        idTags = CreateTempBuffer()
    else
        EmptyBuffer(idTags)
    endif

    // switch to the tags file (open if needed)
    PushPosition()
    EditId=EditFile(tagF)
    BufferType(_HIDDEN_)
    if lFind("|" + object + "|", "ig")  // try to find tag (at beginning of line)
        PushPosition()
        if (idTags<>0)
           AddLine(DelStr(GetText(1,CurrLineLen()),1,Length(object)+3),idTags)
           iCount = iCount + 1
        endif
        PopPosition()
        repeat
              if lRepeatFind(_FORWARD_)
                 PushPosition()
                     AddLine(DelStr(GetText(1,CurrLineLen()),1,Length(object)+3),idTags)
                     iCount = iCount + 1
                  PopPosition()
              else
                  Finish = 1
              endif
        until (Finish)
    endif

    if (iCount == 1)
        TmpStr = Lower(GetText(1,CurrLineLen()))
        BegLine()
        if 1
            // Replace by GetToken
            if NumTokens(TmpStr," ") == 1
                search1    = object+":"
                search2    = ""
                Targetfile =  TmpStr
            else
               targetfile = GetToken(TmpStr," ",2)
               search1    = GetToken(TmpStr," ",3)
               search2    = GetToken(TmpStr," ",4)
            endif
        endif

        if(not FileExists(targetfile))
            Set(WordSet,longfileWordSet)// long filename type wordset
            targetfile = GetWord()      // copy filename
        endif

        if(not FileExists(targetfile))
            Message("Bad Filename in tag file")
            return()
        else
            targetfile = '"' + targetfile + '"'    // Make string "xxx" define
        endif

// Check for Label Support ":"

        if Length(search1) == 0
            search1 = object+":"
            search2 = ""
        endif

    endif

      if EditId <> 0                    // Abandon TagBuffer
         i=AbandonFile(EditId)
      endif

      if (i==0) Message("Fail") endif
      if iCount <> 0 and iCount <> 1
          GotoBufferId(idTags)

          Hook(_LIST_STARTUP_, ListStartup)
          if List("["+Str(iCount)+"] Duplicate Atag Lists",Query(ScreenCols))
              ListFooter("{Enter}-Goto {Escape}-Cancel")
              TmpStr = Lower(GetText(1,CurrLineLen()))

              if 1
                  // Replace by GetToken
                  if NumTokens(TmpStr," ") == 1
                      search1    = object+":"
                      search2    = ""
                      Targetfile = TmpStr
                 else
                     targetfile = GetToken(TmpStr," ",1)
                     search1    = GetToken(TmpStr," ",2)
                     search2    = GetToken(TmpStr," ",3)
                  endif
              endif

              if idTags <> 0
                  AbandonFile(idTags)
              endif
          else
              if idTags <> 0
                  AbandonFile(idTags)
              endif
            KillPosition()
            Message("ATag <"+object+"> Cancel")
            return()
          endif
      endif
      PopPosition()

      if (iCount>=1)                    // Full Item Support
            if FileExists(targetfile)   // Check taget file exist
                EditFile(targetfile)    // change to the target file            Bufid = GetBufferid()       // Save current buffer id for self Check
            else
                GotoBufferId(id)
                Message("Target File <"+targetfile+"> is lost, Try to Update the TagV3.DAT plz.")
                return()
            endif

            if search1[1] == "@"     // Fix for Special Search @
                search1 = "\"+search1
            endif


            if Length(search2)<>0
               SearchOK = lFind(search1+"[ \t]+"+search2,"igwx")
            else
               SearchOK = lFind(search1,"igwx")
            endif

            if (SearchOk==0)
                GotoMark("p")          // Restore Orgin Status
                Message("Tag is define but not find better to update TagV2/3 file")
                return()
            endif
            if (SearchOK==1)
                   BegLine()
                   Set(WordSet, objectWordSet)
                   lFind(object,"cw")          // find the object

//                   SetBookMark()               // LeChee990810 Multi BackCall
//                   PlaceMark("z")
            else
                orgSearch = search1          // save original string

                // this is nasty, but it works
                // Just keep hacking the search string down until we file something
                while(length(search1))
                    search1 = DelStr(search1, length(search1), 1)
                    if(lFind(search1,"xg"))
                        BegLine()
                        Set(WordSet, objectWordSet)
                        Find(object,"cw")   // find the object
                        break
                    endif
                endwhile

                // stuck out?
                if(length(search1) == 0)
                    warn("Not Found:" + orgSearch)  // not found at all
                endif
            endif
         Set(WordSet, OrgWordSet)    // restore word set
         ScrollToCenter()            // put it in the center of screen
         if idTags <> 0
           AbandonFile(idTags)
         endif
         return()                    // leave with cursor at tag
      endif

    Set(WordSet, OrgWordSet)                    // restore word set
    GotoBufferId(id)                            // switch back to original file and location
    Message("Tag <" + object + "> not found")   // show reqrets
    DelBookMark(Chr(LastTag))

    return()
end

proc WhenLoaded()
    // identify my place to start looking for the tags file
    string Vendor[128]
    string SetPath[128]
    Vendor = GetEnvStr("Vendor")
    if Vendor == "Insyde"               // Vendor Support
        SetPath = GetEnvStr("iTagFile")
    else
        SetPath = GetEnvStr("TagFile")
    endif
    if SetPath[Length(SetPath)] == "\"
        SetPath = DelStr(SetPath,Length(SetPath),1)
    endif
    if SetPath <> ""
       myRootDir = SetPath+"\"
    else
       myRootDir = CurrDir()
    endif
    Set(WordSet,ChrSet("0-9A-Z_a-z@"))
end

proc AtagStat()

    MsgBox("Atags Copyright 1999",
           "Ctrl F                    Active Atags" + chr(13) +
           "Ctrl B                   Backward Tags" + chr(13) +
           "CtrlAlt '             Create TagV3.DAT" + chr(13) +
           "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ" + chr(13) +
           "TagFile Dirs " + Upper(myRootDir) + chr(13) +
           "     Atags Version " + StVer + chr(13) + "",_OK_ )
end

proc BuildTag(string LoadName)

     integer EditId,iCount,i
     integer Finish = 0
     string  S1[64],S2[64]
     string  SearchItem[32]
     String  SearchOpt[10]
     string  AsmDef[255] = "proc dw db equ label macro dd"

       EditId = EditFile(LoadName)

       GotoBufferId(EditId)
       for iCount = 1 to NumTokens(AsmDef," ") + 1
       BegFile()
           if iCount <> NumTokens(AsmDef," ") +1
               SearchItem=GetToken(AsmDef," ",iCount)
               SearchOpt="igxw"
           else
               SearchItem=":"     // Label Support  ps.Label not define as a token
               SearchOpt="igx"
           endif

           if lFind(SearchItem,SearchOpt)
               PushPosition()
               BegLine()

               S1 = GetToken(GetText(1,CurrLineLen())," ",1)
               S2 = GetToken(GetText(1,CurrLineLen())," ",2)
               if S1[1]==";"   // Check for Remark
                  S2 = ""
               else
                  if SearchItem == ":"     // Label Support
                     i = Length(S1)
                     if CmpiStr(S1[i],SearchItem) == 0
                          if S1 <> "@@:"
                             InsertLine("|"+DelStr(S1,Length(S1),1)+"|"+"   "+CurrFileName(),NewId)
                          endif
                     endif
                  else
                     if CmpiStr(S2,SearchItem)==0          // 0 : Equal
                         InsertLine("|"+S1+"|"+"   "+CurrFileName()+"   "+S1+"   "+S2,NewId)
                     endif
                  endif
               endif
               PopPosition()
               Finish = 0           // Initialize for Each Case
               repeat
                   if lRepeatFind(_FORWARD_) <> 0
                       PushPosition()
                       BegLine()
                       S1 = GetToken(GetText(1,CurrLineLen())," ",1)
                       S2 = GetToken(GetText(1,CurrLineLen())," ",2)
                       if S1[1]==";"   // Check for Remark
                          S2 = ""
                       else
                          if SearchItem == ":"    // Label Support
                             i = Length(S1)
                               if CmpiStr(S1[i],SearchItem) == 0
                                  if S1 <> "@@:"
                                     InsertLine("|"+DelStr(S1,Length(S1),1)+"|"+"   "+CurrFileName(),NewId)
                                  endif
                               endif
                          else
                               if CmpiStr(S2,SearchItem)==0          // 0 : Equal
                                   InsertLine("|"+S1+"|"+"   "+CurrFileName()+"   "+S1+"   "+S2,NewId)
                               endif
                          endif
                       endif
                       S1=""
                       S2=""
                       PopPosition()
                   else
                      Finish = 1
                   endif
               until Finish
           endif
       endfor
       if EditId <> 0
          AbandonFile(EditId)
       endif

       GotoBufferId(NewId)
end

proc MakeTag()
     integer i
     string  path[128] = GetEnvStr("TagFile")+"\"
     string  AsmStr[255] = "*.asm *.inc *.equ *.h"
     string  TmpStr[255]

   TmpStr = myRootDir
   if MsgBox("Atags Creator",
          "Summary:                             " + Chr(13) +
          "   Create TagV3.DAT in " + TmpStr      + Chr(13) +
          "       Copyright 1999 " + StVer        + Chr(13) +
          "   TAG only Compatible with MASM     " + Chr(13) +
          "",_OK_) == 0
      return()
   endif

    CurrId = GetBufferId()

    if not GotoBufferId(NewId)
       NewId = CreateBuffer("TagV3.DAT")
    endif

    if not GotoBufferId(DirId)
       DirId = CreateTempBuffer()
    else
       EmptyBuffer(DirId)
    endif


   GotoBufferId(DirId)

   PushPosition()
   for i = 1 to NumTokens(AsmStr," ")
         if (BuildPickBufferEx(path+GetToken(AsmStr," ",i),_NORMAL_,_RECURSE_DIRS_|_INSERT_PATH_) )
            Set(PickFileFlags,_DIRS_AT_TOP_)
            Sort(_PICK_SORT_)
            DisplayMode(_DISPLAY_PICKFILE_)
            BegFile()
         endif
   endfor

   PopPosition()

   BegFile()
   do NumLines() times
        TmpStr = PBName()
        PushPosition()
           BuildTag(TmpStr)
        PopPosition()
        Down()
   enddo
   GotoBufferId(NewId)

   if DirId <> 0
      AbandonFile(DirId)
   endif

   TmpStr = Upper(path+tagsfile)

   if SaveAs(path+tagsfile,_DEFAULT_)
      MsgBox("Atags Report",
             TmpStr+chr(13)+
             "is Created" )
   else
      Message("Create TagV3.DAT Cancel")
   endif

   GotoBufferId(CurrId)
   if NewId <> 0
      AbandonFile(NewId)
   endif

end

proc main()
string ExtName[10]
    ExtName = Upper(CurrExt())
    case  ExtName
        when ".ASM",".INC",".EQU"
            amain()              // AsmTAG
        when ".C",".H",".CPP"
            cmain()              // CTAG
        otherwise
            amain()              // Default is AsmTAG
    endcase
end


// Repuirement: Atags v1.29 Compatible
//              Set Tagfile=[Drive]:\Path     Where the TagV3.DAT is locate

<Ctrl F>            main()
<Ctrl B>            GotoLastPosition()

<Alt '>             AtagStat()
<CtrlAlt '>         MakeTag()
