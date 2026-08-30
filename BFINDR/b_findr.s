
   /*=================================================
      b_FindAndReplace()

      Author: Brian Abbott

      Date  : 04-05-94 Submitted to SemWare

      Description:

      Uses ASCII word lists to drive the find/replace.

      If cursor is in a marked block, operation occurs
      in the block only, otherwise the entire current file.

      Word lists are loaded from by results of
      SearchPath(name, TSEPath, "FINDR\")

      Word Lists ( with ".FAR" fileExt)

      If "FINDOPTS = ???" is found, the find options are
      set/reset to the ???. The find opts can be reset as
      many times in the file as needed. The default find option
      is "iwn".

      If there is no ";" in a line, the word/phrase is searched
      for according to the find opts and replaced with the
      word/phrase as typed.

      If there is a ";" in a line, the word/phrase before the
      ";" is searched for according to the find opts, and
      replaced with the word/phrase after the ";"

      Lines begining with "/", and blank lines, are ignored.

      EXAMPLE.FAR
      -----------
      FINDOPTS = inw
      if
      do while       ; while
      endif          ; end
      append blank   ; dbAppend()

      FINDOPTS = in
      set(
      ascan(

   =================================================*/

proc b_FindAndReplace()

   integer  nFarId                              // wordlist file id
   integer  nSemiColon                          // col pos of semicolon
   integer  nSavId         = GetBufferId()      // current file id
   integer  nIsInBlock     = IsCursorInBlock()  // are we in a block

   string   cWordFile[65]                       // wordlist file name
   string   cSrchExp[30]                        // expression to search for
   string   cReplExp[30]                        // expression to replace
   string   cString[80]                         // line read in from wordlist
   string   cFileList[65]  = ""                 // list of files for pickfile
   string   cFindOpts[12]  = "iwn" +            // default find options
                             iif(nIsInBlock, "l", "")

   cFileList   = SearchPath("*.far", Query(TSEPATH), "FINDR\")
   // ----------- if we didn't find any files, return
   if length( cFileList ) == 0
      Warn( "I couldn't find *.FAR files" )

   else
      // ----------- if we don't pick a file, return
      cWordFile = pickfile( cFileList )
      if length(cWordFile) > 0

         // ----------- ok, we got a FAR file, lets get started

         OneWindow()
         pushPosition()
         BegLine()
         nFarId  = EditFile( cWordFile )

         // ----------- goto words file
         GoToBufferId( nFarId )
         BegFile()

         repeat
            cString  = GetText(1,80)                  // read line from far

            // ----------- we only want non-blank lines
            //             that _don't_ start with "/"
            if length( trim( cString ) ) > 0 and
               substr( trim( cString ), 1, 1) <> "/"

               cString=Lower(cString)
               if Pos("findopts =", cString ) > 0
                  // ----------- change opts if "findopts" found
                  cFindOpts   = trim( substr(cString, Pos("=", cString) +1, 80 ) )
                                + iif(nIsInBlock, "l", "")

               else
                  // ----------- got a word, process it
                  nSemiColon  = Pos( ";", cString )

                  if nSemiColon
                     cSrchExp = trim( substr(cString, 1, nSemiColon -1) )
                     cReplExp = trim( substr(cString, nSemiColon +1, 80) )
                  else
                     cSrchExp = trim( substr(cString, 1, 80) )
                     cReplExp = cSrchExp
                  endif

                  Message("Searching/Replacing " +cSrchExp )

                  GoToBufferId( nSavId )
                  if nIsInBlock
                     GotoBlockBegin()           // start from block beg
                  else                          // or
                     BegFile()                  // file beg
                  endif

                  if not lReplace( cSrchExp, cReplExp, cFindOpts )
                     repeat
                     until not lRepeatFind()
                  endif
               endif
            endif

            GoToBufferId( nFarId )
         until not Down()

         Message( "Done......." )

         AbandonFile(nFarId)
         GoToBufferId( nSavId )
         popPosition()

      endif    // picked a file from the list
   endif       // found a .far file

   return ()
end

////////////////////////////////////////////////////////////////
proc main()
   b_FindAndReplace()
end

