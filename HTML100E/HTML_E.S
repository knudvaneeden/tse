/*
  ÚÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÒ¿
  ³º Macro Title: html_e                                                 º³
  ³º Version....: 1.00e (English version) for TSE 2.0                    º³
  ³º Author.....: Peter Weisenstein (EMAIL weisen@rhrk.uni-kl.de)        º³
  ÀĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄĞÙ

  This macro allows to embed HTML-Escape-sequences into an ASCII  textfile.
  You  select  the kind of HTML-formatting by pressing the <F11>-key.  Then
  you are asked for more input if necessary.  The tag is then  inserted  at
  the current cursor position.  You are asked to move to the position where
  the ending tag shall be inserted (possible movement  keys  see  procedure
  "MoveCursor()"). That's all!

      In this context I think it would be a nice feature to "hide" the
      HTML-commands (just like the TSE "tags" - they are  embedded  in
      the text, you can jump to them, but you don't see them). The new
      command could be placed in the FindAndDoMenu as an extension  of
      the mFindAndDo()-command:

        menu FindAndDoMenu()
            History
            Title = "After Find, Do"
            width = 17

            "&Delete Line"
            "C&ut Append"
            "&Copy Append"
            "Cou&nt"
            "&Hide text"
        end


      A corresponding dialog could be:

        Search for:                                --> Screen prompt
        <.*>                                       --> My input

        Options:                                   --> Screen prompt
        GX                                         --> My input

      As a result,  all HTML-commands  and  hyperlinks  are  no  longer
      shown.

      Any suggestions and help is welcome.

*/
      integer
      _JumpPlusMinusHistory=1,
      _AnchorHistory=2,
      _GifHistory=3
//
      integer
      ENGLISCH=1,
      DEUTSCH=2
//
      constant
      TextSearch=1,
      FeatureSearch=2,
      UnitSearch=4
//
      integer
      SearchMode=TextSearch,
      TypeOfLastBlock=FALSE        // Type of last marked block
//
      string
      _HtmlTag[80]=""
//
      string
      LastFind[80]="",            // word last searched for
      LastFindOptions[11]="I+"    // last used find options
//
//
//
      proc pwWordRight()
//    ------------------
//
//    jumps to the beginning of the next word
//
      WordRight()
      while CurrChar()<0 WordRight() endwhile
      end
//
//
//
      proc pwWordLeft()
//    -----------------
//
//    jumps to the beginning of the previous word
//
      WordLeft()
      while CurrChar()<0 WordLeft() endwhile
      end
//
//
//
      proc pwMarkBlockEnd()
//    ---------------------
//
      MarkChar()
      TypeOfLastBlock=_NONINCLUSIVE_
//
      end
//
//
//
      proc pwUnmarkBlock()
//    --------------------
//
      UnmarkBlock()
      TypeOfLastBlock=FALSE
//
      end
//
//
//
      proc pwMarkBlockBegin()
//    -----------------------
//
      pwUnmarkBlock()
      MarkChar()
      TypeOfLastBlock=_NONINCLUSIVE_
//
      end
//
//
//
      integer proc pwUnitSearch(var string Options)
//    ---------------------------------------------
//
//    defines a temporary block from the actual cursor position up to
//    the end of the current "unit" (here searching for the FORTRAN
//    end-statement) and adds the flag "local search" to the find options.
//
//    If this option is already set, nothing happens.
//
      string
      UnitOpt[3]
//
//    War die loakale Suche schon aktiviert ?
      if Pos("L",Options) Return(FALSE) endif
//
      PushBlock()
      PushPosition()
      pwMarkBlockBegin()
      UnitOpt=iif(Pos("B",Options),"IXB","IX+")
      if lFind(" END$",UnitOpt)
//      Ende der Programmeinheit gefunden
        pwMarkBlockEnd()
        iif (Pos("B",Options),GotoBlockEnd(),GotoBlockBegin())
        Options=Options+"L"
      else
//      Kein Ende der Programmeinheit gefunden
        PopBlock()
        Return(FALSE)
      endif
//
      Return(TRUE)
//
      end
//
//
//
      integer proc mFind(string ToFind,string Opt)
//    --------------------------------------------
//
      integer
      Ret=FALSE
//
      string
      Options[20]=Opt
//
      LastFind=ToFind
//
      if (SearchMode&UnitSearch)==UnitSearch and pwUnitSearch(Options)
//      Only search in the actual "unit" (see pwUnitSearch)
        Ret=Find(ToFind,Options)
        PopBlock()
        if Ret
          KillPosition()
        else
          PopPosition()
        endif
        Return(Ret)
      endif
//
      Return(Find(ToFind,Options))
//
      end
//
//
//
      integer proc AskFindOptions(var string opts, integer history)
//    -------------------------------------------------------------
//
      if history
        if not Ask("Options [BGILWX+] (see help for <FindOptions>):",
                   opts,_FINDOPTIONS_HISTORY_)
          Return(FALSE)
        endif
        LastFindOptions=opts
      else
        if not Ask("Optionen [BGILWX+] (siehe Hilfe zu <FindOptions>):",
                   opts)
          Return(FALSE)
        endif
      endif
//
      Return(TRUE)
      End
//
//
//
      string proc GetWordAtCursor()
//    -----------------------------
//
      string
      word[80]=""
//
      PushBlock()
      if MarkWord()
        word=GetMarkedText()
      endif
      PopBlock()
      Return(word)
//
      end
//
//
//
      proc GoCol(STRING s)
//    --------------------
//
//    Called by GotoTagOrPlusMinusOrLine to position the cursor to a column
//
      integer
      Col=val(SubStr(s,Pos(',',s)+1,4))
//
      if Pos(SubStr(s,Pos(',',s)+1,1),"+-")
//      Spaltendifferenz
        GotoColumn(CurrCol()+Col)
      else
//      Spaltennummer
        GotoColumn(Col)
      endif
//
      end
//
//
//
      proc JumpPlusMinus(string TextConst)
//    ------------------------------------
//
      string
      Text[6]=""
//
      Text=TextConst
      if Text==""
        if not ask("How may lines forward or back ?",Text,
               _JumpPlusMinusHistory) Return() endif
      endif
      GotoLine(CurrLine()+Val(Text))
      Return()
//
      end
//
//
//
      proc GotoTagOrPlusMinusOrLine()
//    -------------------------------
//
      string
          TagOrPlusMinusOrLine[10]=""
      if not ask("Tag [A..Z] or [ñ]line(s)[,[ñ]column(s)] :  ",
         TagOrPlusMinusOrLine,_GOTOLINE_HISTORY_) Return() endif
      Upper(TagOrPlusMinusOrLine)
      if TagOrPlusMinusOrLine[1]>="A" and TagOrPlusMinusOrLine[1]<="Z" or
         TagOrPlusMinusOrLine[1]>="a" and TagOrPlusMinusOrLine[1]<="z"
        GotoMark(TagOrPlusMinusOrLine[1])
      elseif Pos(TagOrPlusMinusOrLine[1],"+-")
        AddHistoryStr(TagOrPlusMinusOrLine,_JumpPlusMinusHistory)
        JumpPlusMinus(TagOrPlusMinusOrLine)
      else
        if TagOrPlusMinusOrLine[1]==","
          GoCol(TagOrPlusMinusOrLine)
        elseif NOT Pos(',',TagOrPlusMinusOrLine)
          GotoLine(Val(TagOrPlusMinusOrLine))
        else
          GotoLine(val(SubStr(TagOrPlusMinusOrLine,1,
                   Pos(',',TagOrPlusMinusOrLine)-1)))
          GoCol(TagOrPlusMinusOrLine)
        endif
      endif
//
      end
//
//
//
      integer proc MoveCursor()
//    -------------------------
//
      integer Taste=0
      repeat
        Message("Move cursor to the end of the block, then press Enter")
        UpDateDisplay()
        Taste=GetKey()
        case Taste
          when <Alt f>
            Find()
          when <Alt j>
            GotoTagOrPlusMinusOrLine()
          when <CursorLeft>
            Left()
          when <CursorRight>
            Right()
          when <Ctrl CursorLeft>
            pwWordleft()
          when <Ctrl CursorRight>
            pwWordright()
          when <CursorUp>
            Up()
          when <CursorDown>
            Down()
          when <PgDn>
            PageDown()
          when <PgUp>
            PageUp()
          when <Ctrl PgDn>
            EndFile()
          when <Ctrl PgUp>
            BegFile()
          when <Escape>
            UnmarkBlock()
            Return(FALSE)
          when <End>,<Ctrl PgDn>
            EndLine()
          when <Home>,<Ctrl PgUp>
            BegLine()
        endcase
        UpDateDisplay()
      until Taste==<enter>
      Return(TRUE)
//
      end
//
//
//
      proc Grp2Txt()
//    --------------
//
//    see: TSE_TIP4.TXT, macro "grp2txt.s".
//
      pushposition()
      begfile()
      replace('[´µ¶·¸¹»¼½¾¿ÀÁÂÃÅÆÇÈÉÊËÌÎÏĞÑÒÓÔÕÖ×ØÙÚÛ]','+','qxnq')
      begfile()
      replace('[º³°±²İŞ]', '|', 'gxnq')
      begfile()
      replace('[ÄÍÜß]', '-', 'gxnq')
      popposition()
      end
//
//
//
      proc SetHtmlTag(integer Num)
//    ----------------------------
//
      string
      Text[60]=""
//
      Text=""
      case Num
        when 1
          _HtmlTag='TITLE'
        when 2
          _HtmlTag='P'
        when 3
          Ask("Please enter name of named anchor :",
              Text,_AnchorHistory)
          _HtmlTag='A'
          Text=' NAME="'+Text+'"'
        when 4
          Ask("Please enter [document][#named_anchor] :",
              Text,_AnchorHistory)
          _HtmlTag='A'
          Text=' HREF="'+Text+'"'
        when 5
          _HtmlTag='UL'
        when 6
          _HtmlTag='OL'
        when 7
          _HtmlTag='LI'
        when 8
          _HtmlTag='DL'
        when 9
          _HtmlTag='DT'
        when 10
          _HtmlTag='DD'
        when 11
          _HtmlTag='PRE'
        when 12
          _HtmlTag='BR'
        when 13
          _HtmlTag='HR'
        when 14
          _HtmlTag='BLOCKQUOTE'
        when 15
          _HtmlTag='ADDRESS'
        when 17
          _HtmlTag='IMG'
          Ask("Please enter name of the picture :",Text,_GifHistory)
          Text=' SRC="'+Text+'" ALIGN={TOP|MIDDLE|BOTTOM} ALT="(alt_text)"'
          Ask("Please enter options :",Text,_GifHistory)
        when 101
          _HtmlTag='H1'
        when 102
          _HtmlTag='H2'
        when 103
          _HtmlTag='H3'
        when 104
          _HtmlTag='H4'
        when 105
          _HtmlTag='H5'
        when 106
          _HtmlTag='H6'
        when 201
          lReplace("<","&lt;","GN")
          lReplace(">","&gt;","GN")
          lReplace("&","&amp;","GN")
          lReplace('"',"&quot;","GN")
          lReplace('„',"&auml;","GN")
          lReplace('”',"&ouml;","GN")
          lReplace('',"&uuml;","GN")
          lReplace('á',"&szlig;","GN")
          lReplace('',"&Auml;","GN")
          lReplace('™',"&Ouml;","GN")
          lReplace('š',"&Uuml;","GN")
          lReplace('',"&#167;","GN")
//        ... list can be continued ...
          Grp2Txt()
          Return()
        when 202
          lReplace("<.*>","","GNX")
          lReplace("&lt;","<","GN")
          lReplace("&gt;",">","GN")
          lReplace("&amp;","&","GN")
          lReplace("&quot;",'"',"GN")
          lReplace("&auml;",'„',"GN")
          lReplace("&ouml;",'”',"GN")
          lReplace("&uuml;",'',"GN")
          lReplace("&szlig;",'á',"GN")
          lReplace("&Auml;",'',"GN")
          lReplace("&Ouml;",'™',"GN")
          lReplace("&Uuml;",'š',"GN")
          lReplace("&#167;",'',"GN")
//        ... list can be continued ...
          Return()
        when 302
          _HtmlTag='DFN'
        when 303
          _HtmlTag='EM'
        when 304
          _HtmlTag='STRONG'
        when 305
          _HtmlTag='CITE'
        when 306
          _HtmlTag='CODE'
        when 307
          _HtmlTag='KBD'
        when 308
          _HtmlTag='SAMP'
        when 309
          _HtmlTag='VAR'
        when 311
          _HtmlTag='B'
        when 312
          _HtmlTag='I'
        when 313
          _HtmlTag='TT'
      endcase
      InsertText("<"+_HtmlTag+Text+">",_INSERT_)
      if MoveCursor()
        InsertText("</"+_HtmlTag+">",_INSERT_)
      endif
//
      Return()
      end
//
//
//
      Menu HeaderLevelMenu()
//    ----------------------
//
      history
      Title="Level of headings"
      command = SetHtmlTag(100+MenuOption())
//
      "&1  heading level 1"
      "&2  heading level 2"
      "&3  heading level 3"
      "&4  heading level 4"
      "&5  heading level 5"
      "&6  heading level 6"
//
      end HeaderLevelMenu
//
//
//
      Menu EscapeSequMenu()
//    ---------------------
//
      history
      Title="HTML escape sequences for special characters"
      command = SetHtmlTag(200+MenuOption())
//
      "ASCII -> &HTML        replaces ASCII text with HTML escape sequences"
      "HTML -> &ASCII        replaces HTML escape sequences with ASCII text"
//
      end EscapeSequMenu
//
//
//
      Menu CharFormatMenu()
//    ---------------------
//
      history
      Title="character formatting for HTML"
      command = SetHtmlTag(300+MenuOption())
//
      "logical styles (preferred)",,Divide
      "&word definition"
      "&emphasis"
      "&strong emphasis"
      "&title"
      "c&ode"
      "&keyboard entry"
      "Computer status &message"
      "&Variable"
      "physical styles (do not use if possible)",,Divide
      "&Bold"
      "&Italic"
      "T&ypewriter Text"
//
      end CharFormatMenu
//
//
//
      Menu HtmlMenu()
//    ---------------
//
      history
      Title="HTML-formattings"
      command = SetHtmlTag(MenuOption())
//
      "&Title"
      "&Paragraph"
      "Anchor &NAME"
      "Anchor &HREF"
      "&Unnumbered List"
      "&Ordered List"
      "  &List Item"
      "&Description List"
      "  Description T&itle"
      "  Des&cription"
      "Pre&formatted Text"
      "Line Brea&k"
      "Horizontal &rule"
      "&Blockquote"
      "&Address"
      "H&eader ",HeaderLevelMenu(),DontClose
      "Inline I&mage "
      "character formatting ",CharFormatMenu(),DontClose
      "Escape-Se&quences ",EscapeSequMenu(),DontClose
//
      end HtmlMenu
//
//
//
      proc Main()
//    -----------
//
      HtmlMenu()
//
      Return()
      end
//
<F11> HtmlMenu()
