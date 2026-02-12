/****************************************************************************

        GLOB_FR.s            version 1.0                 10 JAN 94
                   GRAFCO INC 1994   G. Grafton Cole

                  Global FIND / REPLACE with pick list

     A menu allows selection of files to edit, search string, replace string,
  FIND / REPLACE options, and whether GLOB_FR will FIND or FIND / REPLACE.
  When GLOB_FR executes, ALL files in the file ring are sequentially
  processed except the data pick list file.  If you cannot specify all the
  desired files with a wild card expression, load the target files, and
  specify one of them in the menu.  Since my projects can be loaded with a
  wild card expression, I leave expansion of file selection to someone else.

     A data pick file is opened and each FIND / REPLACE hit is logged into
  the pick file as follows:

  BufferID   Buffer-name   Line-#   Find-word   [Replace-word]   Syntax-line

  where: BufferID and Line-# are use to position in the file if the line is
           selected with <enter>.
         Buffer-name identifies the file.
         Find-word and Replace-word contain the hit word
         The Syntax-line is a truncated line containing the expression

     The WordSet is expanded so that the find and replace expressions show
  more than just the search string, ie if the find string is 'g_', the
  find expression could be any string containing 'g_';  g_input, $g_input
  g_Input_Output, etc.  The default WordSet is unaltered.

     Since a global replace does not allow grabbing line number, hit
  expressions, etc., a combination of Find and Replace is used.

     When GLOB_FR is done processing, it returns to the starting file.  The
  cursor position in all processed files is left unaltered.  GLOB_FR can be
  invoked any number of times, each time a new pick list is generated.  The
  pick list can be displayed at anytime after GLOB_FR has run.  Placing the
  cursor on any line in the pick list and pressing enter will place the editor
  in the file and on the line specified in the pick list.  The first line in
  the pick file is the starting file data.  The second line in the pick list
  is the data pick list file itself and contains data about the last time
  GLOB_FR was run.

      Two additions Find / Replace options are implemented.  A 'y' will delete
  the hit line and a 'c' will place a string of up to 20 characters at the
  beginning of the hit line.  They may be used in the Find mode so that, as
  with the other options,  the effects of a Replace can be examined before the
  changes are made.

      In the event of total disaster, there is an option to reload the file
  ring from disk.

  Key Bindings:
       F3 starts GLOB_FR after it is loaded
       F4 invokes the pick list

****************************************************************************/

constant  _FIND  = 0, _REPL  = 1, _TXT  = 2, // Get_Data
          _WHEAD = 0, _WDATA = 1,            // Write_Data
          _NOAD  = 0, _DLINE = 1, _CLINE = 2 // AD_mode

string  find_str[40],                        // find string
        repl_str[40],                        // replace string
        fr_opt[40],                          // options for find / replace
        file_spec[40],                       // filespec for target files
        f_exp[40],                           // find hit word
        fr_exp[40],                          // find/replace hit word
        txt_line[120],                       // find/replace text line
        c_str[20],                           // line comment characters
        Data_Buffer[12] = "GLOB_FR,pik",     // name of pick list buffer
        Base_Buffer[12]                      // name of starting file

integer fr_mode     = _FIND,                 // 1 = find / replace
        AD_mode     = _NOAD,                 // 1 = delete entire hit line
                                             // 2 = comment line
        HLT         = 0,                     // 1 = abort
        file_reload = 0,                     // 1 = reload file ring
        Data_BufferID,                       // pick list ID
        Base_BufferID,                       // starting file ID
        Count                                // # of hits

//proc Debug()
//     if Keypressed()
//        HLT = GetKey()                        // look for escape key
//        case HLT
//           when <escape>
//           halt
//        endcase
//      endif
//end

proc Tone(integer sel)
     case sel
     when 0
        Sound(700)  Delay(3)  Sound(500)  Delay(3)  Sound(700) Delay(3)
     when 1
        Sound(700)  Delay(3)
     endcase
     NoSound()
end

proc Quit()
     HLT = 1
     Return()
end

proc Abort()
     message(" ********* GLOB_FR GLOB_FR ABORTED *********")
     Tone(0)
     Quit()
     GotoBufferID(Base_BufferID)
     PopPosition()
end

proc TogMode() fr_mode  = iif(fr_mode, _FIND, _REPL)   end  // mode toggle

string proc AnsMode(integer tog)                            // menu mode string
     return  (iif(tog,"FIND / REPLACE", " FIND "))
end

proc Reload()
     file_reload = 1
end

menu MainMenu()
  history
  NoEscape
  x = 8
  y = 2

  "         ษอออออออออออออออ GLOB_FR ออออออออออออออออป"        ,, Skip
  "         บ    Global Find and Find / Replace      บ"        ,, Skip
  "         ศออออออออออออออออออออออออออออออออออออออออผ"        ,, Skip
  "&Abort"                                    , Quit()          , CloseBefore
  "e&Xecute"                                  ,                 , CloseBefore
  "HEADER OPTIONS"                            ,                 , Divide
  "&Mode toggle     " [AnsMode(fr_mode):14]   , TogMode()       , DontClose
  "&Target file spec" [file_spec:40]          , Read(file_spec) , DontClose
  "&Find String     " [find_str:40]           , Read(find_str)  , DontClose
  "&Replace String  " [repl_str:40]           , Read(repl_str)  , DontClose
  "&Options         " [fr_opt:40]             , Read(fr_opt)    , DontClose
  " Valid options:    [iwx]  Ignore-case  Words  reg-word "    ,, Skip
  " Addition options:   [y] delete lines  Find will show hits" ,, Skip
  "                     [c] Comment lines Find will show hits" ,, Skip
  "&Comment chars   " [c_str:20]              , Read(c_str)     , DontClose
  "Panic Time"                                                 ,, Divide
  "Reload filering from disk"                 , Reload()        , CloseBefore
end

proc Write_data(integer select)
     string CF[12] = SplitPath(CurrFilename(),_NAME_|_EXT_)  // current buffer
     integer CID   = GetBufferID(),                          // current buffer ID
             curln = CurrLine()

     case select
     when _WHEAD
        GotoBufferID(Data_BufferID)
        BegFile()
        InsertLine(Format("(",Base_BufferID:3:"0", ") ",Base_Buffer:-13,
                          curln:4:"0", ": ", "***** STARTING FILE *****"))

        case AD_mode and fr_mode
        when _DLINE
           AddLine(Format("(", Data_BufferID:3:"0", ") ",
                          "SEARCH STRING "  + "'" + find_str + "'   " +
                          "HIT LINE DELETED " + "  TOTAL HITS ", count))
        when _CLINE
           AddLine(Format("(", Data_BufferID:3:"0", ") ",
                          "SEARCH STRING "  + "'" + find_str + "'   " +
                          "COMMENT ADDED TO HIT LINE " + "  TOTAL HITS ", count))
        otherwise
           AddLine(Format("(", Data_BufferID:3:"0", ") ",
                       iif(fr_mode, "SEARCH STRING "  + "'" + find_str + "'   " +
                                    "REPLACE STRING " + "'" + repl_str + "'",
                                    "SEARCH STRING "  + "'" + find_str + "'"),
                                    "  TOTAL HITS ", count))

        endcase
        GotoBufferID(CID)
     when _WDATA
        AddLine(Format("(", CID:3:"0" , ") ", CF:-13,  CurrLine():4:"0",": ",
                       f_exp, iif(fr_mode," ฏ ","  "), fr_exp,"    ", txt_line),
                       Data_BufferID )
     endcase
end

proc Get_data(integer select)
     string   cWs[32] = ""                        // current wordset
     integer  i = 0

     PushBlock()
     cWS = Set(Wordset,ChrSet("A-Za-z0-9!@#$%&_-"))  // expand wordset

     case select
     when _REPL
        Left()                                 // find cursor: on begin word
        MarkWord()                             // replace cursor: at end word
        fr_exp = Trim(GetMarkedText())
        Right()
     When _FIND
        Count = count + 1                         // number of hits
        MarkWord()
        f_exp  = Trim(GetMarkedText())
     when _TXT
          i = CurrPos()
        if i - 30 <= 0                             // truncate line
          txt_line = Trim(GetText(1,50))
        else
          txt_line = "... " + Trim(GetText(i-30,i+20))
        endif
        if AD_mode == _DLINE  txt_line = "LINE DEL: " + Trim(GetText(1,120)) endif
        if AD_mode == _CLINE  txt_line = Trim(GetText(1,120))  endif
        Write_Data(_WDATA)
     endcase

     Set(WordSet, cWS)                         // restore default wordset
     PopBlock()
end


proc Replace_It()
     message(Format(" working ", Count))
     case AD_mode
     when _NOAD
        Replace(find_str, repl_str, fr_opt+"1")
     when _DLINE
        DelLine()
        if Up() endif
     when _CLINE
        BegLine()
        InsertText(c_str, _INSERT_)
        Down()
     endcase
     Get_Data(_REPL)
     Get_Data(_TXT)
end


proc Do_It()
     message(" Begin processing")
     GotoBufferID(Base_BufferID)                     // start from base
     repeat
        PushPosition()
        if fr_mode                                   // ---- FIND REPLACE
           if lFind(find_str,fr_opt+"g")             // find/replace 1st hit
              Get_Data(_FIND)                        // get find expression
              Replace_It()
              while lFind(find_str,fr_opt)           // Do it for rest
                message(Format(" working ", Count))
                Get_data(_FIND)                      //  of buffer
                Replace_It()
              endwhile
           endif
        else                                         // ---- FIND
           if lFind(find_str, fr_opt+"g")
              Get_data(_FIND)
              Get_Data(_TXT)
              while lFind(find_str,fr_opt+'+')
                message(Format(" working ", Count))
                Get_data(_FIND)
                Get_Data(_TXT)
              endwhile
           endif
        endif

        PopPosition()
        NextFile()

        if GetBufferID() == Data_BufferID     // don't look in data buffer
           NextFile()
        endif
     until GetBufferID() == Base_BufferID
end

proc LoadFiles()
     integer LW = Query(LoadWildFromInside)

     Set(LoadWildFromInside, ON)
     EditFile(file_spec)                    // let TSE handle errors
     Set(LoadWildFromInside, LW)
end


proc ReLoad_Files()
     string  cfn[40] = CurrFilename(),
             rfn[40] = ""
     integer    cfLP = CurrLine(),
                rfLP = 0,
                i    = 0

     BegWindow()
     i = cfLP - CurrLine()
     AbandonFile()
     EditFile(cfn)
     NextFile()
     repeat
       rfn  = CurrFilename()
       rfLP = CurrLine()
       AbandonFile()
       EditFile(rfn)
       GotoLine(rfLP)
       NextFile()
     until CurrFilename() == cfn
     AbandonFile(Data_BufferID)             // get rid of pick file
     GotoLine(cfLP)
     while i
       Scrollup()
       i = i-1
     endwhile
     ScrollToRow(i)
end

proc Initialize()

     Base_BufferID = GetBufferID()
     Data_BufferID = CreateBuffer(Data_Buffer)

     if Data_BufferID == 0
         Data_BufferID = GetBufferId(Data_Buffer)
     endif
     if Data_BufferID == Base_BufferID
         warn("Can't use this buffer")
         return ()
     endif
     if Data_BufferID == 0 or not GotoBufferId(Data_BufferID)
         return ()
     endif
     EmptyBuffer()

     GotoBufferID(Base_BufferID)
     HLT         = 0
     Count       = 0
     AD_mode     = _NOAD
     file_reload = 0
end

proc CK_opt()
     integer i = Pos('G',Upper(fr_opt))

     if i
       fr_opt = SubStr(fr_opt,1,i-1) + SubStr(fr_opt,i+1,Length(fr_opt)-i)
     endif

     i = Pos('L',Upper(fr_opt))
     if i
       fr_opt = SubStr(fr_opt,1,i-1) + SubStr(fr_opt,i+1,Length(fr_opt)-i)
     endif

     i = Pos('B',Upper(fr_opt))
     if i
       fr_opt = SubStr(fr_opt,1,i-1) + SubStr(fr_opt,i+1,Length(fr_opt)-i)
     endif
     // comment line takes precedence over delete line

     i = Pos('Y',Upper(fr_opt))
     if i
       fr_opt = SubStr(fr_opt,1,i-1) + SubStr(fr_opt,i+1,Length(fr_opt)-i)
       AD_mode = _DLINE
     endif

     i = Pos('C',Upper(fr_opt))
     if i
       fr_opt = SubStr(fr_opt,1,i-1) + SubStr(fr_opt,i+1,Length(fr_opt)-i)
       AD_mode = _CLINE
     endif
end

proc Error_CK()
     CK_opt()
     if AD_mode == _CLINE and Length(Trim(c_str)) == 0
        HLT = 1
        Tone(0)
        warn(" ERROR: NO Comment String Specified")
     endif
     if Length(Trim(find_str)) == 0
        HLT = 1
        Tone(0)
        warn(" ERROR: NO FIND STRING SPECIFIED")
     endif
     if AD_mode  return()  endif
     if Length(Trim(repl_str)) == 0 and fr_mode
        HLT = 1
        Tone(0)
        warn(" NO REPLACE STRING SPECIFIED *** FIND STRING WILL BE DELEATED")
        message(" <escape> to ABORT ---- <return> to CONTINUE")
        Tone(0)
        case GetKey()
          when <enter>
            HLT = 0
        endcase
     endif
end

proc Start()
     Base_Buffer = SplitPath(CurrFilename(),_NAME_|_EXT_)
     PushPosition()
     Initialize()
     MainMenu()
       if HLT  Abort() return() endif
       if file_reload Reload_Files() Quit() return() endif
     Error_CK()
       if HLT  Abort() return() endif
     LoadFiles()
       if HLT  Abort() return() endif
     Do_It()
     Write_Data(_WHEAD)
     Tone(1)
     Message("      ALL DONE  F4 for data pick list")
     PopPosition()
     Quit()
     return()
end

proc main()
     message("      GLOB_FR.mac loaded, Press F3 to start")
     Tone(1)
end


proc Data_Pick()
     string sID[30] = ""            // target file ID, string
     integer ID     = 0,            // target file ID
             sPos   = 0,
             Lnum   = 0

     if length(trim(file_spec)) <> 0
        GotoBufferID(Data_BufferID)
        BegFile()
        if lList("GLOBAL " +  " PICK LIST", 75, 25,
                                          _ENABLE_SEARCH_|_ENABLE_HSCROLL_)
           sID  = GetText(1, 30)               // string containing buffer ID #
           sPos = Pos(")", sID) - 1            // end position of ID #
           ID   = Val( SubStr(sID, 2, sPos) )  // get it and convert to integer
           Lnum = Val( Substr(sID, Pos(":", sID) - 5, 5) )  // line number
           GotoBufferID(ID)
           GotoLine(Lnum)
        else
           GotoBufferID(Base_BufferID)         // starting file
        endif
     endif
     return()
end

<F3>  Start()
<F4>  Data_Pick()

