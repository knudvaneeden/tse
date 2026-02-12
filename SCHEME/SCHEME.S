/*
   Macro.   Scheme.
   Author.  Carlo Hogeveen (hyphen@xs4all.nl)
   Date.    15 June 1999.

   Version. 2.
   Date.    17 June 1999.
      Added the loop and the scheme.ini.

   Version. 3.
   Date.    30 June 1999.
      Moved Scheme.ini to TSE's mac directory for easier installing.

   Scheme allows you to name, save, load and delete the whole of your TSE
   color settings as a scheme.

   Installation: Copy SCHEME.S and SCHEME.INI to TSE's "MAC" directory,
                 and compile SCHEME.S.

   How does it work? Just run it: <escape> <M>macro <E>xecute "scheme".

   This is a good macro to add to the PotPourri menu.

   Scheme does not work for TSE 2.5 and below, and was tested with TSE 2.80b
   and above.

   Most color schemes were supplied by Semware.
   The unofficial profile procedures came from Chris Antos' Gethelp macro.

   As written Scheme uses a file Scheme.ini in TSE's load directory, but I
   know that network users are going to want to put it on a network drive,
   so that users can share their "ultimate" color scheme's with each other.
   Only the first line in the Main procedure needs to be changed for that.
*/

integer scheme_history    = 0
string  scheme_file [255] = ""
string  scheme_name [255] = ""
integer selected_line     = 0

proc list_cleanup()
   selected_line = CurrLine()
   case Query(Key)
      when <enter>
         PushKey(<enter>)
      when <Escape>
         PushKey(<Escape>)
   endcase
end

proc load_scheme()
   Hook(_LIST_CLEANUP_, list_cleanup)
   while selected_line > 1
      selected_line = selected_line - 1
      PushKey(<greycursordown>) // This one scrolls in the history list.
   endwhile
   PushKey(<greycursorup>) // This one starts the history list.
   if  Ask("Select and Load a color scheme:", scheme_name, scheme_history)
   and scheme_name <> ""
      PushKey(<l>) // This one makes the Repeat loop back to Load.
      Set(CurrWinBorderAttr  , getprofileint(scheme_name, "CurrWinBorderAttr"  , Query(CurrWinBorderAttr)  , scheme_file))
      Set(OtherWinBorderAttr , getprofileint(scheme_name, "OtherWinBorderAttr" , Query(OtherWinBorderAttr) , scheme_file))
      Set(MenuTextAttr       , getprofileint(scheme_name, "MenuTextAttr"       , Query(MenuTextAttr)       , scheme_file))
      Set(MenuTextLtrAttr    , getprofileint(scheme_name, "MenuTextLtrAttr"    , Query(MenuTextLtrAttr)    , scheme_file))
      Set(MenuGrayAttr       , getprofileint(scheme_name, "MenuGrayAttr"       , Query(MenuGrayAttr)       , scheme_file))
      Set(MenuSelectGrayAttr , getprofileint(scheme_name, "MenuSelectGrayAttr" , Query(MenuSelectGrayAttr) , scheme_file))
      Set(MenuBorderAttr     , getprofileint(scheme_name, "MenuBorderAttr"     , Query(MenuBorderAttr)     , scheme_file))
      Set(MenuSelectAttr     , getprofileint(scheme_name, "MenuSelectAttr"     , Query(MenuSelectAttr)     , scheme_file))
      Set(MenuSelectLtrAttr  , getprofileint(scheme_name, "MenuSelectLtrAttr"  , Query(MenuSelectLtrAttr)  , scheme_file))
      Set(BlockAttr          , getprofileint(scheme_name, "BlockAttr"          , Query(BlockAttr)          , scheme_file))
      Set(CursorInBlockAttr  , getprofileint(scheme_name, "CursorInBlockAttr"  , Query(CursorInBlockAttr)  , scheme_file))
      Set(CursorAttr         , getprofileint(scheme_name, "CursorAttr"         , Query(CursorAttr)         , scheme_file))
      Set(HiLiteAttr         , getprofileint(scheme_name, "HiLiteAttr"         , Query(HiLiteAttr)         , scheme_file))
      Set(TextAttr           , getprofileint(scheme_name, "TextAttr"           , Query(TextAttr)           , scheme_file))
      Set(EOFMarkerAttr      , getprofileint(scheme_name, "EOFMarkerAttr"      , Query(EOFMarkerAttr)      , scheme_file))
      Set(MsgAttr            , getprofileint(scheme_name, "MsgAttr"            , Query(MsgAttr)            , scheme_file))
      Set(StatusLineAttr     , getprofileint(scheme_name, "StatusLineAttr"     , Query(StatusLineAttr)     , scheme_file))
      Set(HelpInfoAttr       , getprofileint(scheme_name, "HelpInfoAttr"       , Query(HelpInfoAttr)       , scheme_file))
      Set(HelpLinkAttr       , getprofileint(scheme_name, "HelpLinkAttr"       , Query(HelpLinkAttr)       , scheme_file))
      Set(HelpSelectAttr     , getprofileint(scheme_name, "HelpSelectAttr"     , Query(HelpSelectAttr)     , scheme_file))
      Set(HelpBoldAttr       , getprofileint(scheme_name, "HelpBoldAttr"       , Query(HelpBoldAttr)       , scheme_file))
      Set(HelpItalicsAttr    , getprofileint(scheme_name, "HelpItalicsAttr"    , Query(HelpItalicsAttr)    , scheme_file))
      Set(HelpTextAttr       , getprofileint(scheme_name, "HelpTextAttr"       , Query(HelpTextAttr)       , scheme_file))
      Set(IncompleteQuoteAttr, getprofileint(scheme_name, "IncompleteQuoteAttr", Query(IncompleteQuoteAttr), scheme_file))
      Set(NumberAttr         , getprofileint(scheme_name, "NumberAttr"         , Query(NumberAttr)         , scheme_file))
      Set(Directive1Attr     , getprofileint(scheme_name, "Directive1Attr"     , Query(Directive1Attr)     , scheme_file))
      Set(Directive2Attr     , getprofileint(scheme_name, "Directive2Attr"     , Query(Directive2Attr)     , scheme_file))
      Set(Directive3Attr     , getprofileint(scheme_name, "Directive3Attr"     , Query(Directive3Attr)     , scheme_file))
      Set(MultiLnDlmt1Attr   , getprofileint(scheme_name, "MultiLnDlmt1Attr"   , Query(MultiLnDlmt1Attr)   , scheme_file))
      Set(MultiLnDlmt2Attr   , getprofileint(scheme_name, "MultiLnDlmt2Attr"   , Query(MultiLnDlmt2Attr)   , scheme_file))
      Set(MultiLnDlmt3Attr   , getprofileint(scheme_name, "MultiLnDlmt3Attr"   , Query(MultiLnDlmt3Attr)   , scheme_file))
      Set(SingleLnDlmt1Attr  , getprofileint(scheme_name, "SingleLnDlmt1Attr"  , Query(SingleLnDlmt1Attr)  , scheme_file))
      Set(SingleLnDlmt2Attr  , getprofileint(scheme_name, "SingleLnDlmt2Attr"  , Query(SingleLnDlmt2Attr)  , scheme_file))
      Set(SingleLnDlmt3Attr  , getprofileint(scheme_name, "SingleLnDlmt3Attr"  , Query(SingleLnDlmt3Attr)  , scheme_file))
      Set(Quote1Attr         , getprofileint(scheme_name, "Quote1Attr"         , Query(Quote1Attr)         , scheme_file))
      Set(Quote2Attr         , getprofileint(scheme_name, "Quote2Attr"         , Query(Quote2Attr)         , scheme_file))
      Set(Quote3Attr         , getprofileint(scheme_name, "Quote3Attr"         , Query(Quote3Attr)         , scheme_file))
      Set(ToEOL1Attr         , getprofileint(scheme_name, "ToEOL1Attr"         , Query(ToEOL1Attr)         , scheme_file))
      Set(ToEOL2Attr         , getprofileint(scheme_name, "ToEOL2Attr"         , Query(ToEOL2Attr)         , scheme_file))
      Set(ToEOL3Attr         , getprofileint(scheme_name, "ToEOL3Attr"         , Query(ToEOL3Attr)         , scheme_file))
      Set(KeyWords1Attr      , getprofileint(scheme_name, "KeyWords1Attr"      , Query(KeyWords1Attr)      , scheme_file))
      Set(KeyWords2Attr      , getprofileint(scheme_name, "KeyWords2Attr"      , Query(KeyWords2Attr)      , scheme_file))
      Set(KeyWords3Attr      , getprofileint(scheme_name, "KeyWords3Attr"      , Query(KeyWords3Attr)      , scheme_file))
      Set(KeyWords4Attr      , getprofileint(scheme_name, "KeyWords4Attr"      , Query(KeyWords4Attr)      , scheme_file))
      Set(KeyWords5Attr      , getprofileint(scheme_name, "KeyWords5Attr"      , Query(KeyWords5Attr)      , scheme_file))
      Set(KeyWords6Attr      , getprofileint(scheme_name, "KeyWords6Attr"      , Query(KeyWords6Attr)      , scheme_file))
      Set(KeyWords7Attr      , getprofileint(scheme_name, "KeyWords7Attr"      , Query(KeyWords7Attr)      , scheme_file))
      Set(KeyWords8Attr      , getprofileint(scheme_name, "KeyWords8Attr"      , Query(KeyWords8Attr)      , scheme_file))
      Set(KeyWords9Attr      , getprofileint(scheme_name, "KeyWords9Attr"      , Query(KeyWords9Attr)      , scheme_file))
      Set(ShowSyntaxHilite   , getprofileint(scheme_name, "ShowSyntaxHilite"   , Query(ShowSyntaxHilite)   , scheme_file))
   endif
   UnHook(list_cleanup)
end

proc save_scheme()
   PushKey(<greycursorup>)
   if  Ask("Save current color scheme as:", scheme_name, scheme_history)
   and scheme_name <> ""
      PushKey(<l>) // This one makes the Repeat loop back to Load. Yes, Load!
      writeprofileint(scheme_name, "CurrWinBorderAttr"  , Query(CurrWinBorderAttr)  , scheme_file)
      writeprofileint(scheme_name, "OtherWinBorderAttr" , Query(OtherWinBorderAttr) , scheme_file)
      writeprofileint(scheme_name, "MenuTextAttr"       , Query(MenuTextAttr)       , scheme_file)
      writeprofileint(scheme_name, "MenuTextLtrAttr"    , Query(MenuTextLtrAttr)    , scheme_file)
      writeprofileint(scheme_name, "MenuGrayAttr"       , Query(MenuGrayAttr)       , scheme_file)
      writeprofileint(scheme_name, "MenuSelectGrayAttr" , Query(MenuSelectGrayAttr) , scheme_file)
      writeprofileint(scheme_name, "MenuBorderAttr"     , Query(MenuBorderAttr)     , scheme_file)
      writeprofileint(scheme_name, "MenuSelectAttr"     , Query(MenuSelectAttr)     , scheme_file)
      writeprofileint(scheme_name, "MenuSelectLtrAttr"  , Query(MenuSelectLtrAttr)  , scheme_file)
      writeprofileint(scheme_name, "BlockAttr"          , Query(BlockAttr)          , scheme_file)
      writeprofileint(scheme_name, "CursorInBlockAttr"  , Query(CursorInBlockAttr)  , scheme_file)
      writeprofileint(scheme_name, "CursorAttr"         , Query(CursorAttr)         , scheme_file)
      writeprofileint(scheme_name, "HiLiteAttr"         , Query(HiLiteAttr)         , scheme_file)
      writeprofileint(scheme_name, "TextAttr"           , Query(TextAttr)           , scheme_file)
      writeprofileint(scheme_name, "EOFMarkerAttr"      , Query(EOFMarkerAttr)      , scheme_file)
      writeprofileint(scheme_name, "MsgAttr"            , Query(MsgAttr)            , scheme_file)
      writeprofileint(scheme_name, "StatusLineAttr"     , Query(StatusLineAttr)     , scheme_file)
      writeprofileint(scheme_name, "HelpInfoAttr"       , Query(HelpInfoAttr)       , scheme_file)
      writeprofileint(scheme_name, "HelpLinkAttr"       , Query(HelpLinkAttr)       , scheme_file)
      writeprofileint(scheme_name, "HelpSelectAttr"     , Query(HelpSelectAttr)     , scheme_file)
      writeprofileint(scheme_name, "HelpBoldAttr"       , Query(HelpBoldAttr)       , scheme_file)
      writeprofileint(scheme_name, "HelpItalicsAttr"    , Query(HelpItalicsAttr)    , scheme_file)
      writeprofileint(scheme_name, "HelpTextAttr"       , Query(HelpTextAttr)       , scheme_file)
      writeprofileint(scheme_name, "IncompleteQuoteAttr", Query(IncompleteQuoteAttr), scheme_file)
      writeprofileint(scheme_name, "NumberAttr"         , Query(NumberAttr)         , scheme_file)
      writeprofileint(scheme_name, "Directive1Attr"     , Query(Directive1Attr)     , scheme_file)
      writeprofileint(scheme_name, "Directive2Attr"     , Query(Directive2Attr)     , scheme_file)
      writeprofileint(scheme_name, "Directive3Attr"     , Query(Directive3Attr)     , scheme_file)
      writeprofileint(scheme_name, "MultiLnDlmt1Attr"   , Query(MultiLnDlmt1Attr)   , scheme_file)
      writeprofileint(scheme_name, "MultiLnDlmt2Attr"   , Query(MultiLnDlmt2Attr)   , scheme_file)
      writeprofileint(scheme_name, "MultiLnDlmt3Attr"   , Query(MultiLnDlmt3Attr)   , scheme_file)
      writeprofileint(scheme_name, "SingleLnDlmt1Attr"  , Query(SingleLnDlmt1Attr)  , scheme_file)
      writeprofileint(scheme_name, "SingleLnDlmt2Attr"  , Query(SingleLnDlmt2Attr)  , scheme_file)
      writeprofileint(scheme_name, "SingleLnDlmt3Attr"  , Query(SingleLnDlmt3Attr)  , scheme_file)
      writeprofileint(scheme_name, "Quote1Attr"         , Query(Quote1Attr)         , scheme_file)
      writeprofileint(scheme_name, "Quote2Attr"         , Query(Quote2Attr)         , scheme_file)
      writeprofileint(scheme_name, "Quote3Attr"         , Query(Quote3Attr)         , scheme_file)
      writeprofileint(scheme_name, "ToEOL1Attr"         , Query(ToEOL1Attr)         , scheme_file)
      writeprofileint(scheme_name, "ToEOL2Attr"         , Query(ToEOL2Attr)         , scheme_file)
      writeprofileint(scheme_name, "ToEOL3Attr"         , Query(ToEOL3Attr)         , scheme_file)
      writeprofileint(scheme_name, "KeyWords1Attr"      , Query(KeyWords1Attr)      , scheme_file)
      writeprofileint(scheme_name, "KeyWords2Attr"      , Query(KeyWords2Attr)      , scheme_file)
      writeprofileint(scheme_name, "KeyWords3Attr"      , Query(KeyWords3Attr)      , scheme_file)
      writeprofileint(scheme_name, "KeyWords4Attr"      , Query(KeyWords4Attr)      , scheme_file)
      writeprofileint(scheme_name, "KeyWords5Attr"      , Query(KeyWords5Attr)      , scheme_file)
      writeprofileint(scheme_name, "KeyWords6Attr"      , Query(KeyWords6Attr)      , scheme_file)
      writeprofileint(scheme_name, "KeyWords7Attr"      , Query(KeyWords7Attr)      , scheme_file)
      writeprofileint(scheme_name, "KeyWords8Attr"      , Query(KeyWords8Attr)      , scheme_file)
      writeprofileint(scheme_name, "KeyWords9Attr"      , Query(KeyWords9Attr)      , scheme_file)
      writeprofileint(scheme_name, "ShowSyntaxHilite"   , Query(ShowSyntaxHilite)   , scheme_file)
   endif
end

proc delete_scheme()
   Hook(_LIST_CLEANUP_, list_cleanup)
   PushKey(<greycursorup>)
   if  Ask("Delete which color scheme:", scheme_name, scheme_history)
   and scheme_name <> ""
      PushKey(<d>) // This one makes the Repeat loop back to Delete.
      removeprofilesection(scheme_name, scheme_file)
   endif
   UnHook(list_cleanup)
end

menu scheme_menu()
   TITLE = "Color scheme - Load, Save or Delete ?"
   "&Load", load_scheme(), _mf_closebefore_, "Select and load a color scheme"
   "&Save", save_scheme(), _mf_closebefore_, "Save the current colors as a color scheme"
   "&Delete", delete_scheme(), _mf_closebefore_, "Delete the selected scheme"
end

proc Main()
   scheme_file    = LoadDir() + "mac\scheme.ini"
   scheme_history = GetFreeHistory("color_scheme")
   repeat
      while DelHistoryStr(scheme_history, 1)
      endwhile
      if loadprofilesectionnames(scheme_file)
         while getnextprofilesectionname(scheme_name)
            AddHistoryStr(scheme_name, scheme_history)
         endwhile
      endif
      case Lower(GetToken(Query(MacroCmdLine), " ", 1))
         when "save"
            save_scheme()
         when "load"
            load_scheme()
         when "delete"
            delete_scheme()
         otherwise
            scheme_menu()
      endcase
      UpdateDisplay(_ALL_WINDOWS_REFRESH_)
   until not KeyPressed()
   PurgeMacro("scheme")
end

