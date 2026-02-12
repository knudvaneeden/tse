/*
   Macro    Hlp2txt
   Author   Carlo.Hogeveen@xs4all.nl
   Date     17 Februari 2003
   TSE      2.6 upwards
*/
   string macro_version [7] = "2.4.4"

datadef info1
   ""
   ""
   "Hlp2txt   -   convert Help system to Text file"
   ""
   ""
   ""
   "This macro converts TSE's internal Help system into a text file"
   ""
   "based on TSE's internal Help Index."
   ""
   ""
   ""
   "The text file can be generated in several text formats."
   ""
   "The text file is created in TSE's 'Help' directory."
   ""
   ""
   ""
   "Press ESCAPE to abort Hlp2txt at any time."
end

/*
   This macro is not compatible with TSE 2.5, because TSE 2.5 ignores
   PushKey() commands inside the Help system.


   Installation: Just copy this macro to TSE's "mac" directory, compile it,
                 execute it, and answer its questions.

                 If you need help with that, consult your operating system's
                 or TSE's internal Help system.


   About Chris Antos' GetHelp extension for TSE's Help system:
   This macro will not show the extra Help from GetHelp.
   Whats more, Hlp2txt would be incompatible with GetHelp's HelpHelp macro
   if it didn't temporarily disable it.
   HelpHelp isn't included in Semware's distribution of TSE.
   It mainly occurs through its inclusion in Chris Antos' GetHelp macros,
   which might be downloaded from Semware's website.
   HelpHelp is a special macro that TSE knows about, and that TSE autoloads
   when we access the Help system. Therefore the only way that Hlp2txt can
   (temporarily!) disable it is by renaming HelpHelp.mac (to HelpHelp.nomac).
   That this also temporarily disables GetHelp across TSE-sessions is
   unavoidable. Aborting Hlp2txt with <Escape> will not leave HelpHelp
   disabled. Crashing TSE or your machine during one specific part of Hlp2txt
   will leave HelpHelp disabled, but even then, just running Hlp2txt again
   through completion will reenable HelpHelp.


   History:

      1.0   Initial version. Plain text only.

      2.0   Adds the ability to also create an html file.
            Alas, some html links are still buggy.
            Txt and html: subtopics (which are described in main topics)
            cause multiple inserts of the main topics into the generated
            file: because this occurs frequently in TSE's Help system, the
            generated file is probably several times it's necessary size.

      2.0.1 Added a copyright notice on Sammy's request.
            Removed the screen flickering, thanks to Sammy.
            Made Hlp2txt recognize and handle subtopics,
            making the generated file about 5 times smaller.
            Removed updating the display while running, which makes each
            macro part a lot faster, but the new version has more parts,
            so the end result isn't faster after all.

            Intermediately released. No known bugs any more, but not pretty
            enough yet: There is no textual link in the index from subtopics
            to main topics. That is especially clumsy for the .txt version.
            Also, there are overlapping links.

      2.1   Solved overlapping hyperlinks in the html format.
            Added a main topic reference to subtopics in the index,
            this was a must for the text version.
            Added a copyright notice and intro-text to the text version too.
            Added rough TSE version recognition.

      2.2   Added a small header at subtopics and a procedure description
            above to add a Word user in converting the html file to a pretty
            printable format.

      2.2.1 Removed NUL characters for Netscape users.
            Thanks to John Kopp.

      2.2.2 Solved a bug for when TSE resides in a directory with a space in
            it's name.

      2.2.3 Solved a bug indexing and generating topics with long similar
            topic names, like the ones starting with "Summary of New/Enhanced
            features of The Semware Editor Professional ...". Only the first
            of such topics was generated. The solution came from John Kopp.
            I also used some of his suggestions for improving the code.

            For HTML files the number of generated hyperlinks from the text
            to the (sub)topics is reduced and smarter. Formerly hyperlinks
            were always generated, also when TSE words that are also English
            words were used in a normal English sentence. Now the macro does
            this smarter following some simple rules. For instance, you won't
            see every occurrence of "to", "in", "and" and many others
            hyperlinked in plain English sentences any more. Since a macro
            can't equal human intelligence in understanding text, there still
            are and always will be some superfluous hyperlinks. They are few,
            harmless, and at worst "not pretty".

      2.4   Added informational screens to increase user-friendliness.

            Added two new textformats to generate: Word and Generic.

            Added optionally calling Word or the browser afterwards.

      2.4.1 When saving a generated and user-modified Word file, Word still
            knows that it's originally an html file, despite the .doc
            extension. Changed the user instructions to compensate for this.

            Bug found which will not be solved. In TSE 3.0 and possibly other
            older versions of TSE the macro will not show its version
            information if it was started from the commandline with
            "e32 -eHlp2txt". This seems to be a problem in TSE's lVersion()
            command which is solved in later versions of TSE.

      2.4.2 Because ASCII files are probably viewed in an ANSI font,
            characters with a code below 32 or above 127 should be
            converted for the ASCII format too.

      2.4.3 Hlp2txt used to abort when the HelpHelp macro is present in TSE's
            "mac" directory, resulting in a Help file with just heading
            information. The HelpHelp macro mainly gets distributed with
            Chris Antos' GetHelp macro, and is often not deleted if a user
            uninstalls GetHelp.
            Hlp2txt now temporarily uninstalls HelpHelp, and aborts no more.

      2.4.4 For TSE 4.4 upwards Hlp2Txt can automatically determine TSE's
            correct version string, using the new VersionStr() function.
*/

#define DEBUG FALSE

#define PUSHLIMIT 64


#ifdef WIN32

string textformat [8] = ""

datadef info2
   "OK, let's get to work:"
   ""
   "It is not possible to determine TSE's version number completely"
   "automatically. It can be done roughly, and is done roughly, but to get it"
   "in detail (for all versions of TSE) we have to use a kludge."
   ""
   "While a macro cannot determine TSE's detailed version number directly,"
   "it does have the ability to show it to you, the user."
   ""
   "Therefore after this screen, TSE is made to show its version details."
   ""
   "Look for something like 'v4.00e'."
   ""
   "After that you will be asked to enter TSE's detailed version number."
   ""
   "This entered version number will be shown in the generated help text."
end

datadef info3
   "The next screen is a menu, where you will have to choose the text format"
   "to be generated."
   ""
   "ASCII format is plain text, without any formatting with special codes."
   "It can be viewed with TSE."
   ""
   "HTML format is great for viewing the resulting document in a browser."
   "The text is thoroughly hyperlinked: wherever a topic is referenced in the"
   "text, selecting (clicking on) the reference will take you to the topic."
   ""
   "WORD format is html without hyperlinks, and with Word-specific things added:"
   "a .doc extension, extra headers for subtopics from which Word can create"
   "an index, Word-specific embellishment-tips."
   "A document generated in this textformat can be embellished with Word"
   "into a very professional looking printable manual."
   ""
   "GENERIC format is html without hyperlinks and without Word additions."
   "It is intended for other applications that can print html documents."
end

integer proc info_screen(integer temp_id, integer info_number)
   integer result = TRUE
   Delay(18)
   PushPosition()
   PushBlock()
   GotoBufferId(temp_id)
   EmptyBuffer()
   case info_number
      when 1
         InsertData(info1)
      when 2
         InsertData(info2)
      when 3
         InsertData(info3)
      otherwise
         AddLine("Hlp2txt program error: illegal info_number")
   endcase
   lReplace("^","   ","gnx")
   EndFile()
   AddLine()
   AddLine()
   BegFile()
   InsertLine()
   InsertLine()
   if not List("Hlp2txt Info Screen          Press ENTER to continu or Escape to abort", 80)
      result = FALSE
   endif
   PopPosition()
   PopBlock()
   Delay(18)
   return(result)
end

proc debug_signal()
   if DEBUG
      Alarm()
      Delay(18)
      Alarm()
      Delay(18)
      Alarm()
      Delay(18)
   endif
end

proc update_display()
   if DEBUG
      UpdateDisplay()
      Delay(1)
   endif
end

proc rename_qualified_macro(string old_name, string new_name)
   if FileExists(old_name)
      if Lower(SplitPath(old_name, _EXT_)) == ".mac"
         Message("Disabling HelpHelp   ...   ")
      else
         Message("Reenabling HelpHelp   ...   ")
      endif
      if FileExists(new_name)
         EraseDiskFile(new_name)
      endif
      Delay(1)
      Dos("copy " + QuotePath(old_name) + " " + QuotePath(new_name),
          _DONT_PROMPT_|_DONT_CLEAR_)
      Delay(1)
      EraseDiskFile(old_name)
      Delay(36)
   endif
end

proc rename_macro_in_dir(string old_name, string new_name, string dir_in)
   string dir [255] = dir_in
   string backslash [1] = "\"
   while SubStr(dir, Length(dir), 1) in "\", "/"
      dir = SubStr(dir, 1, Length(dir) - 1)
   endwhile
   if dir_in == ""
      backslash = ""
   endif
   rename_qualified_macro(dir + backslash + old_name,
                          dir + backslash + new_name)
   rename_qualified_macro(dir + backslash + "mac\" + old_name,
                          dir + backslash + "mac\" + new_name)
end

proc rename_macro(string old_name, string new_name)
   integer token_no = 0
   rename_macro_in_dir(old_name, new_name, "")
   for token_no = 1 to NumTokens(Query(TSEPath), ";")
      rename_macro_in_dir(old_name, new_name,
                          Trim(GetToken(Query(TSEPath), ";", token_no)))
   endfor
   rename_macro_in_dir(old_name, new_name, LoadDir())
end

proc disable_helphelp()
   rename_macro("HelpHelp.mac", "HelpHelp.nomac")
   PurgeMacro("HelpHelp")
end

proc reenable_helphelp()
   rename_macro("HelpHelp.nomac", "HelpHelp.mac")
end

string proc topic_to_tag(string topic)
   string  tag [255] = topic
   integer i         = 0
   for i = 1 to Length(tag)
      if tag [i] == "#"
         tag [i] = "_"
      elseif not (tag [i] in "0" .. "9", "a" .. "z", "A" .. "Z", "$", "-",
                             "_", ".", "+", "!", "*", "'", "(", ")", ",")
         tag = SubStr(tag, 1, i - 1) + SubStr(tag, i + 1, 255)
      endif
   endfor
   return(tag)
end

string proc de_regexp(string regexp)
   string result [255] = regexp
   integer i
   for i = 1 to Length(result)
      if Pos(result [i], ".^$|?[]-~*+@#{}\")
         result = Format(SubStr(result, 1, i - 1),
                         "\",
                         SubStr(result, i, 255))
         i = i + 1
      endif
   endfor
   return(result)
end

proc find_subtopic(string text, string options, var integer found_line)
   GotoMark("m")
   if lFind(text, options)
      if CurrLine() < found_line
         found_line = CurrLine()
      endif
   endif
end

proc insert_hyperlink_address(string main_topic, string sub_topic)
   string w_option [1] = ""
   integer found_line = FALSE
   if GotoMark("m")
      if  Lower(sub_topic) <> Lower(main_topic)
      and (        SubStr(sub_topic, Length(sub_topic) - 1, 2)  <> "()"
          or Lower(SubStr(sub_topic, 1, Length(sub_topic) - 2)) <> Lower(main_topic))
         // This is not a main topic but a subtopic.
         // Find (the optimal jump address for) the sub_topic.
         // Testing suggests the following search strategie.
         find_subtopic("^[ \d128-\d255]*" + de_regexp(sub_topic) + " *$", "ix", found_line)
         find_subtopic(" syntax .*[~a-zA-Z]" + de_regexp(sub_topic) + "[~a-zA-Z]|$", "ix", found_line)
         find_subtopic(" format .*[~a-zA-Z]" + de_regexp(sub_topic) + "[~a-zA-Z]|$", "ix", found_line)
         find_subtopic("[~a-zA-Z]" + de_regexp(sub_topic) + "[~a-zA-Z].* syntax[~a-zA-Z]|$", "ix", found_line)
         find_subtopic("[~a-zA-Z]" + de_regexp(sub_topic) + "[~a-zA-Z].* Format[~a-zA-Z]|$", "ix", found_line)
         if not found_line    // No finds succeeded.
            find_subtopic('  ' + sub_topic + '  ', "i", found_line)
         endif
         if not found_line    // No finds succeeded.
            find_subtopic('"' + sub_topic + '"', "i", found_line)
         endif
         if found_line        // Some find succeeded.
            GotoLine(found_line)
         else
            GotoMark("m")     // No finds succeeded.
            if NumTokens(sub_topic, " ") == 1
               w_option = "w"
            endif
            if not lFind(sub_topic, "i" + w_option)
               lFind(sub_topic, "i")
            endif
         endif
         // Go a little back to show some context.
         // First go to a line starting at column 1.
         while CurrLine() <> 1
         and   (GetText(1, 1) in "", " ")
            Up()
         endwhile
         // Then go to an empty line or one with an html tag.
         while CurrLine() <> 1
         and   NumTokens(GetText(1, CurrLineLen()), " ") <> 0
         and   GetText(1, 1) <> "<"
            Up()
         endwhile
         // Go down because of the InsertLine()s.
         Down()
         if  textformat == "word"
            // Add an small html header for the subtopic to assist a Word user
            // in converting the html file to a pretty printable format.
            InsertLine(Format("<h5> ", sub_topic, " </h5>"))
         endif
      endif
      if textformat == "html"
         InsertLine(Format('<a name="', topic_to_tag(sub_topic), '"><a>'))
      endif
      EndFile()
   else
      Warn("Hlp2txt programming error: bookmark missing")
      Warn("No hyperlink address will be generated for this sub_topic")
      Warn("Maintopic=", main_topic)
      Warn("Sub topic=",  sub_topic)
   endif
end

string proc current_month_name()
   string month_names [255] =
      "Januari Februari March April May June July August September October November December"
   return(GetToken(month_names, " ", Val(GetToken(GetDateStr(), "-", 2))))
end

proc txt_paste()
   Paste()
   if textformat <> "ascii"
      lReplace("<", "&lt;", "gln")
      lReplace(">", "&gt;", "gln")
   endif
   UnMarkBlock()
end

proc choose_textformat(string chosen_textformat)
   textformat = chosen_textformat
end

menu textformat_menu()
   TITLE = "Choose the textformat to generate"
   "&Ascii     for viewing in TSE"                    ,choose_textformat("ascii"  ),,"Generate plain unformatted text for viewing in TSE"
   "&Html      for viewing in browser"                ,choose_textformat("html"   ),,"Generate thoroughly hyperlinked HTML to view in browser"
   "&Word      for embellishing and printing in Word" ,choose_textformat("word"   ),,"Generate HTML without hyperlinks with embellishments for Word"
   "&Generic   for another html application"          ,choose_textformat("generic"),,"Generate HTML without hyperlinks for other applications"
end

string proc delete_parentheses(string sub_topic)
   string result [255] = sub_topic
   if SubStr(sub_topic, Length(sub_topic) - 1, 2) == "()"
      result = SubStr(sub_topic, 1, Length(sub_topic) - 2)
   endif
   return(result)
end

proc test_for_ok(var integer ok)
   while KeyPressed()
      if GetKey() == <Escape>
         ok = FALSE
      endif
   endwhile
end

integer proc words_in_frase(string words_in, string frase_in)
   string  words [255] = Lower(words_in)
   string  frase [255] = Lower(frase_in)
   integer result      = FALSE
   integer word_no     = 0
   string  word  [255] = ""
   integer word_length = 0
   integer start_pos   = 0
   for word_no = 1 to NumTokens(words, " ")
      word = GetToken(words, " ", word_no)
      word_length = Length(word)
      for start_pos = 1 to Length(frase) - word_length + 1
         if       SubStr(frase, start_pos, word_length) == word
         and not (SubStr(frase, start_pos - 1          , 1) in "a" .. "z")
         and not (SubStr(frase, start_pos + word_length, 1) in "a" .. "z")
            result = TRUE
         endif
      endfor
   endfor
   return(result)
end

integer proc linkable_context(string sub_topic)
   integer result = TRUE
   if (GetText(CurrCol() - 1, 1)                                     in "<", "#", "_", "A" .. "Z", "a" .. "z", "0" .. "9")
   or (GetText(CurrCol() + Length(delete_parentheses(sub_topic)), 1) in           "_", "A" .. "Z", "a" .. "z", "0" .. "9")
      // Note 1: There are topics starting with a "#".
      // Note 2: The ">" left of a topic means it is html-tagged, and is
      //         excluded to avoid topics referencing themselves.
      result = FALSE
   elseif SubStr(sub_topic, Length(sub_topic) - 1, 2) == "()"
      if GetText(CurrCol() + Length(sub_topic) - 2, 1) <> "("
         // A function not used as a function should not be linked.
         result = FALSE
      endif
   elseif GetText(CurrCol() - 1, 1) == '"'
      // A quoted word is definitely a candidate for linking.
   else
      /*
         Reduce the linking of TSE words that are also normal English words
         when they are used in plain English text. This cannot be done
         perfectly, so just reduction will do, and still generating too many
         links is chosen to be preferrable over generating too few links.
      */
      // A line containing the word "a", "an" or "the" is probably just
      // plain English, except when the topic contains it too.
      PushPosition()
      if  not words_in_frase("a an the", Lower(sub_topic))
      and lFind(" |^{an}|{a}|{the} |$", "cgx")
         result = FALSE
         PopPosition()
      else
         KillPosition()
      endif
      // If these words don't match the exact case
      // then they are probably used in plain English.
      if sub_topic in   "and",
                        "by",
                        "do",
                        "for",
                        "if",
                        "or",
                        "repeat",
                        "to",
                        "until",
                        "when",
                        "while",
                        "ON",
                        "OFF",
                        "TRUE",
                        "FALSE"
         if sub_topic <> GetText(CurrCol(), Length(sub_topic))
            result = FALSE
         endif
      endif
      // If these words are not at the first word in a line,
      // then they are probably used in plain English.
      if sub_topic in   "do",
                        "end",
                        "for",
                        "if",
                        "repeat",
                        "until",
                        "when",
                        "while"
         if PosFirstNonWhite() <> CurrCol()
            result = FALSE
         endif
      endif
      // If "to" or "downto" are used not after "for",
      // then they are probably used in plain English.
      if sub_topic in "to", "downto", "by"
         PushPosition()
         if lFind("for", "bcw")
            PopPosition()
         else
            KillPosition()
            result = FALSE
         endif
      endif
      // If "times" is not used after "do",
      // then it is probably used in plain English.
      if sub_topic == "times"
         PushPosition()
         if lFind("do", "bcw")
            PopPosition()
         else
            KillPosition()
            result = FALSE
         endif
      endif
      // If these words aren't preceded or followed by a number, quote,
      // or round bracket, then they are probably used in plain English.
      if sub_topic in "and", "or", "in"
         PushPosition()
         while Left()
         and   CurrChar() == 32
         endwhile
         if not (Chr(CurrChar()) in "0" .. "9", '"', ")")
            result = FALSE
         endif
         PopPosition()
      endif
   endif
   return(result)
end

proc Main()
   integer old_break             = Set(Break, ON)
   integer old_ilba              = Set(InsertLineBlocksAbove, FALSE)
   integer old_uap               = Set(UnMarkAfterPaste, FALSE)
   integer old_dateformat        = Set(DateFormat, 3)
   integer old_dateseparator     = Set(DateSeparator, Asc("-"))
   integer org_id                = GetBufferId()
   integer temp_id               = CreateTempBuffer()
   integer index_id              = CreateTempBuffer()
   integer topics_id             = CreateTempBuffer()
   integer debug_id              = CreateTempBuffer()
   integer help_id               = 0
   integer ok                    = TRUE
   integer inside_tag            = FALSE
   integer between_tags          = FALSE
   integer i                     = 0
   integer helphelp_reenabled    = FALSE
   integer tse_version_lt_4300   = TRUE
   string  prev_main_topic [255] = ""
   string  main_topic      [255] = ""
   string  sub_topic       [255] = ""
   string  help_filename   [255] = ""
   string  tse_version_hint [25] = ""
   string  tse_version     [255] = ""
   ClrScr()
   DelBookMark("m")
   if not temp_id
   or not index_id
   or not topics_id
   or not debug_id
      ok = FALSE
      Warn("Hlp2txt error creating temporary files in memory.")
   endif
   if ok
      ok = info_screen(temp_id, 1)
   endif
   if ok
      #ifdef EDITOR_VERSION
         #if EDITOR_VERSION >= 0x4300
            tse_version_lt_4300 = FALSE
            tse_version_hint = Format("TSE Pro ", VersionStr())
         #endif
      #endif
   endif
   if  ok
   and tse_version_lt_4300
      ok = info_screen(temp_id, 2)
   endif
   if  ok
   and tse_version_lt_4300
      // Determine TSE's version roughly.
      #ifdef EDITOR_VERSION
         Set(DateFormat, 6)
         tse_version_hint = Format("TSE Pro v", EDITOR_VERSION:4:" ":16)
         tse_version_hint = SubStr(tse_version_hint,  1,  10) + "."
                          + SubStr(tse_version_hint, 11, 255)
      #else
         if EditFile(QuotePath(LoadDir() + "PotPourr.dat"), _DONT_PROMPT_)
            if lFind("^Uniq", "gix")
               tse_version_hint = Format("TSE Pro v2.8")
            else
               tse_version_hint = Format("TSE Pro v2.6")
            endif
            AbandonFile()
         else
            tse_version_hint = Format("TSE Pro v2.6")
         endif
      #endif
   endif
   if  ok
   and tse_version_lt_4300
      // Make TSE show detailed version info to the user.
      lVersion()
   endif
   if ok
   and tse_version_lt_4300
      tse_version = tse_version_hint
      Set(Y1, 10)
      ok = Ask('Optionally refine the version description:',
              tse_version)
      if Trim(tse_version) == ""
         tse_version = tse_version_hint
      endif
   endif
   if ok
      ok = info_screen(temp_id, 3)
      if ok
         Set(X1, 10)
         Set(Y1, 10)
         textformat_menu()
         if textformat == ""
            ok = FALSE
         endif
      endif
   endif
   if not ok
      GotoBufferId(org_id)
   endif
   if ok
      if NumTokens(tse_version, " ") == 0
         tse_version = tse_version_hint
      else
         if  Pos("tse"               , Lower(tse_version)) == 0
         and Pos("the semware editor", Lower(tse_version)) == 0
            tse_version = "TSE " + tse_version
         endif
      endif
      case textformat
         when "ascii"
            help_filename = LoadDir() + "Help\TseHelp.txt"
         when "word"
            help_filename = LoadDir() + "Help\TseHelp.doc"
         when "generic"
            help_filename = LoadDir() + "Help\TseHelp.htm"
         when "html"
            help_filename = LoadDir() + "Help\TseHelp.html"
         otherwise
            ok = FALSE
            Warn("Hlp2txt programming error: unknown textformat.")
      endcase
   endif
   if ok
      help_id = EditFile(QuotePath(help_filename), _DONT_PROMPT_)
      if not help_id
         ok = FALSE
         Warn("Cannot (re)create ", help_filename)
         GotoBufferId(org_id)
      endif
   endif
   if ok
      disable_helphelp()
   endif
   if ok
      EmptyBuffer()
      UnMarkBlock()
      update_display()
      Message("Generating title page ... ")
      Delay(36)
      debug_signal()
      if textformat == "ascii"
         AddLine("")
         AddLine("")
         AddLine("")
         AddLine(Format("":15, "The Semware Editor Professional Manual"))
         AddLine("")
         AddLine("")
         AddLine("")
         AddLine("")
         AddLine("")
         AddLine(Format("":30, tse_version))
         AddLine("")
         AddLine("")
         AddLine("")
         AddLine("")
         AddLine("")
         AddLine("")
         AddLine(Format("":18, "Copyright by SemWare Corporation."))
         AddLine(Format("":19, "All rights reserved worldwide."))
         AddLine("")
         AddLine("")
         AddLine("")
         AddLine("")
         AddLine("")
         AddLine("Visit http://www.semware.com for lots of TSE info and additional macros,")
         AddLine("or to join the mailing list to exchange info with TSE users worldwide.")
         AddLine("")
         AddLine(Format("This manual was generated on ",
                        GetToken(GetDateStr(), "-", 3),
                        " ",
                        current_month_name(),
                        " ",
                        GetToken(GetDateStr(), "-", 1),
                        " from TSE's interactive Help"))
         AddLine("system with version "
                 + macro_version
                 + " of Carlo Hogeveen's Hlp2txt macro.")
         AddLine("")
         AddLine("")
         AddLine("")
         AddLine("")
         AddLine("")
         AddLine("")
         AddLine("")
         AddLine("")
         AddLine("")
         AddLine("")
         AddLine("--- INDEX ---")
         AddLine("")
         AddLine("")
         AddLine("")
      else
         AddLine("<html>")
         AddLine(Format("<center><h1>The Semware Editor Professional Manual</h1></center>"))
         AddLine("<br>")
         AddLine("<br>")
         AddLine("<br>")
         AddLine("<br>")
         AddLine("<br>")
         AddLine(Format("<center><h1>", tse_version, "</h1></center>"))
         AddLine("<br>")
         AddLine("<br>")
         AddLine("<br>")
         AddLine("<br>")
         AddLine("<br>")
         AddLine("<center>&copy; SemWare Corporation.</center>")
         AddLine("<center>All rights reserved worldwide.</center>")
         AddLine("<br>")
         AddLine("<br>")
         AddLine("<br>")
         AddLine("<br>")
         AddLine("<br>")
         AddLine('Visit <a href="http://www.semware.com">www.semware.com</a>')
         AddLine("for lots of TSE info and additional macros, or to join the ")
         AddLine("mailing list to exchange info with TSE users worldwide.")
         AddLine("<br>")
         AddLine("<br>")
         AddLine("This manual was generated on")
         AddLine(Format(GetToken(GetDateStr(), "-", 3),
                        " ",
                        current_month_name(),
                        " ",
                        GetToken(GetDateStr(), "-", 1)))
         AddLine("from TSE's interactive Help")
         AddLine("system with version "
                 + macro_version
                 + " of Carlo Hogeveen's Hlp2txt macro.")
         AddLine("<br>")
         AddLine("<br>")
         AddLine("Characters with an ascii code below 32 and above 127 were ")
         AddLine("converted to readable alternatives.")
         AddLine("You will especially notice this in box drawings.")
         AddLine("The result is not as pretty as the original,")
         AddLine("but quite readable.")
         AddLine("<br>")
         AddLine("<br>")
         if textformat == "html"
            AddLine("This html manual was tested with Internet Explorer 6.")
         elseif textformat == "word"
            AddLine("<pre>")
            AddLine("To assist a Word user in converting this manual into a pretty and")
            AddLine("printable format, small headers were added to subtopics in the text.")
            AddLine("This will let Word create a Table Of Contents with page numbers!")
            AddLine("The procedure for Word 2000 is:")
            AddLine("-  Load TseHelp.doc into Word 2000.")
            AddLine("-  Set View to Print Layout.")
            AddLine("-  You can now Insert, Page Numbers.")
            AddLine("-  Go to the text, a good place would be 'A Walk-Through of Windows Commands',")
            AddLine("   and you might see that long lines are broken up, or that lines fill only")
            AddLine("   the left side of the 'paper'.")
            AddLine("-  If so, then resize the Left and Right Margin in File, Page Setup.")
            AddLine("   It is not recommended to change the font, because that is likely to loose")
            AddLine("   the proportional character spacing, which distorts indents and 'pictures'.")
            AddLine("   For the latter check 'Accessing Sub-Menu Commands and Options' a bit lower.")
            AddLine("-  In the text: delete the old index.")
            AddLine("-  Put the cursor where the new Table Of Contents is going to be.")
            AddLine("-  Insert, Index and Tables, Table Of Contents.")
            AddLine("   Set 'Show levels' to 5, press OK, and wait.")
            AddLine("   You should now see a two-level index: topics having subtopics.")
            AddLine("-  Do any other prettying up: make headers, footers, etc.")
            AddLine("-  Remove this block of text you are reading now.")
            AddLine("-  SaveFile won't work: Word knows the contents of the file are")
            AddLine("   actually HTML despite the extension being .DOC.")
            AddLine("   So do a SAVE AS and select extension .DOC.")
            AddLine("The procedure for Word 97 is alike, with one difference:")
            AddLine("-  You might have to SAVE AS a .DOC before everything else,")
            AddLine("   despite the extesion already being .DOC.")
            AddLine("-  When generating a Table Of Contents: set Levels to 6!")
            AddLine("</pre>")
         endif
         AddLine("<br>")
         AddLine("<br>")
         AddLine("<br>")
         AddLine("<br>")
         AddLine("<br>")
         AddLine("<br>")
         AddLine("<br>")
         AddLine("<br>")
         AddLine("<br>")
         AddLine("<br>")
         AddLine("<dl>")
         AddLine("<dt>")
         AddLine("<h1>Index</h1>")
         AddLine("</dt>")
         AddLine("<dd>")
         AddLine("<pre>")
      endif
      PushKey(<Escape>)
      PushKey(<grey+>)              // copy entire index to clipboard
      PushKey(<alt i>)
      Help()
      GotoBufferId(index_id)
      txt_paste()                   // paste clipboard into index buffer
      if lFind("^Index$", "gx")
         KillLine()
      endif
      while lFind("^\-\-\-", "gx")
      or    lFind("^ *$", "gx")
         KillLine()
      endwhile
      BegFile()
      GotoBufferId(help_id)
      txt_paste()                   // paste clipboard into help buffer
      if lFind("^Index$", "gx")
         KillLine()
      endif
      EndFile()
      if textformat == "html"
         update_display()
         Message("Generating hyperlinks from index to future (sub)topics ... ")
         Delay(36)
         debug_signal()
         AddLine("</pre>")
         AddLine("</dd>")
         lFind("Index", "g")
         Down()
         repeat
            sub_topic = GetText(1, CurrLineLen())
            if not (sub_topic [1] in "", "-", "<")
               BegLine()
               InsertText(Format('<a href="#', topic_to_tag(sub_topic), '">'), _INSERT_)
               EndLine()
               InsertText('</a>', _INSERT_)
            endif
            Message("Generating hyperlinks from index to future (sub)topics   ", CurrLine() * 100 / NumLines(), " % " )
            update_display()
            test_for_ok(ok)
         until not ok
            or not Down()
      endif
      GotoBufferId(index_id)
      BegFile()
      update_display()
      Message("Determining main topics ... ")
      Delay(36)
      debug_signal()
      BufferVideo()
      repeat
         sub_topic = GetText(1, CurrLineLen())
         test_for_ok(ok)
         PushKey(<Escape>)
         PushKey(<grey+>)
         Help(delete_parentheses(sub_topic))
         GotoBufferId(temp_id)
         EmptyBuffer()
         Paste()
         main_topic = GetText(1, CurrLineLen())
         GotoBufferId(topics_id)
         AddLine(Format(main_topic, "", sub_topic))
         GotoBufferId(index_id)
         update_display()
         Message("Determining main topics   ", CurrLine() * 100 / NumLines(), " % ")
      until not ok
         or not Down()
      UnBufferVideo()
      GotoBufferId(topics_id)
      MarkLine(1, NumLines())
      Sort(_IGNORE_CASE_)
      UnMarkBlock()
      BegFile()
      update_display()
      Message("Generating main topics ... ")
      Delay(36)
      debug_signal()
      BufferVideo()
      prev_main_topic = ""
      repeat
         main_topic = GetToken(GetText(1, CurrLineLen()), "", 1)
         sub_topic  = GetToken(GetText(1, CurrLineLen()), "", 2)
         if main_topic == prev_main_topic
            if textformat in "html", "word"
               PushPosition()
               insert_hyperlink_address(main_topic, sub_topic)
               PopPosition()
            endif
         else
            prev_main_topic = main_topic
            test_for_ok(ok)
            PushKey(<Escape>)
            PushKey(<grey+>)
            Help(delete_parentheses(sub_topic))
            GotoBufferId(help_id)
            if textformat == "ascii"
               AddLine("")
               AddLine("")
               AddLine("")
               AddLine("")
               AddLine(main_topic)
               AddLine(Format("":Length(main_topic):"="))
               AddLine("")
               AddLine("")
               txt_paste()          // paste clipboard into help buffer
               Down()
               KillLine()
               EndFile()
            else
               AddLine("<dt>")
               BegLine()
               PlaceMark("m")
               AddLine(Format("<h3>",main_topic,"</h3>"))
               AddLine("</dt>")
               AddLine("<dd>")
               AddLine("<pre>")
               txt_paste()          // paste clipboard into help buffer
               Down()
               KillLine()
               EndFile()
               AddLine("</pre>")
               AddLine("</dd>")
               if textformat in "html", "word"
                  insert_hyperlink_address(main_topic, sub_topic)
               endif
            endif
         endif
         GotoBufferId(topics_id)
         update_display()
         Message("Generating main topics   ", CurrLine() * 100 / NumLines(), " % ")
      until not ok
         or not Down()
      UnBufferVideo()
      reenable_helphelp()
      helphelp_reenabled = TRUE
      GotoBufferId(help_id)
      BegFile()
      if  ok
//    and textformat <> "ascii"     See History 2.4.2.
         update_display()
         Message("Replacing characters above 127 with readable characters   ...   ")
         Delay(36)
         debug_signal()
         lReplace("\d179", "|", "gnx")    // Draw vertical line.
         lReplace("\d196", "-", "gnx")    // Draw horizontal line.
         lReplace("\d218", "+", "gnx")    // Draw upper left corner.
         lReplace("\d192", "+", "gnx")    // Draw lower left corner.
         lReplace("\d191", "+", "gnx")    // Draw upper right corner.
         lReplace("\d217", "+", "gnx")    // Draw lower right corner.
         lReplace("\d194", "+", "gnx")    // Draw strait T shape.
         lReplace("\d195", "+", "gnx")    // Draw left T shape.
         lReplace("\d180", "+", "gnx")    // Draw right T shape.
         lReplace("\d193", "+", "gnx")    // Draw inverted T shape.
         lReplace("\d249", "-", "gnx")    // Double bullet.
         for i = 128 to 255               // Everything else above 127.
            lReplace("\d" + Str(i), "*", "gnx")
         endfor
         update_display()
         Message("Replacing characters below 32 with readable characters   ...   ")
         debug_signal()
         Delay(36)
         lReplace("\d000", "", "gnx")      // Remove NUL for Netscape users.
         lReplace("\d016", "\&gt;", "gnx") // Replace left and right triangles
         lReplace("\d017", "\&lt;", "gnx") // by "<" and ">".
         lReplace("\d030", "^", "gnx")     // Replace up and down triangles
         lReplace("\d031", "v", "gnx")     // by "^" and "v".
         lReplace("\d024", "^", "gnx")     // Replace up and down arrows
         lReplace("\d025", "v", "gnx")     // by "^" and "v".
      endif
      if  ok
      and textformat == "html"
         BegFile()
         update_display()
         Message("Generating hyperlinks from text to (sub)topics ... ")
         Delay(36)
         debug_signal()
         // Sort the index on size so bigger topic titles get preference.
         GotoBufferId(index_id)
         BegFile()
         repeat
            InsertText(Format(Length(GetText(1,CurrLineLen())):10, " "), _INSERT_)
            BegLine()
         until not Down()
         MarkColumn(1, 1, NumLines(), 11)
         Sort(_DESCENDING_)
         KillBlock()
         BegFile()
         repeat
            sub_topic = GetText(1, CurrLineLen())
            GotoBufferId(help_id)
            lFind("--- Z ---", "gi") // Start after the index.
            lFind("</pre>", "gi")
            while lFind(delete_parentheses(sub_topic), "i")
               if Lower(sub_topic) == "executing macros (overview)"
                  old_break = old_break
               endif
               if linkable_context(sub_topic)
                  inside_tag   = FALSE
                  between_tags = FALSE
                  PushPosition()
                  if lFind("<|>", "bcx")
                     if GetText(CurrCol(), 1) == "<"
                        inside_tag = TRUE
                     else
                        if  lFind("<", "bc")
                        and GetText(CurrCol() + 1, 1) <> "/"
                           between_tags = TRUE
                        endif
                     endif
                     PopPosition()
                     PushPosition()
                  endif
                  if lFind("<|>", "cx+")
                     if GetText(CurrCol(), 1) == ">"
                        inside_tag = TRUE
                     else
                        if GetText(CurrCol() + 1, 1) == "/"
                           between_tags = TRUE
                        endif
                     endif
                     PopPosition()
                  else
                     KillPosition()
                  endif
                  if  not inside_tag
                  and not between_tags
                     Right(Length(delete_parentheses(sub_topic)))
                     InsertText("</a>", _INSERT_)
                     Left(Length(delete_parentheses(sub_topic)) + 4)
                     InsertText(Format('<a href="#',
                                       topic_to_tag(sub_topic),
                                       '">'),
                                _INSERT_)
                     Right(4)
                  endif
               endif
               Right(Length(delete_parentheses(sub_topic)))
            endwhile
            GotoBufferId(index_id)
            Message("Generating hyperlinks from text to (sub)topics   ", CurrLine() * 100 / NumLines(), " % ")
            update_display()
            test_for_ok(ok)
         until not ok
            or not Down()
         GotoBufferId(help_id)
         BegFile()
      endif
      update_display()
      Message("Adding a topic-reference to subtopics in the index ... ")
      Delay(36)
      debug_signal()
      GotoBufferId(topics_id)
      BegFile()
      repeat
         main_topic = GetToken(GetText(1, CurrLineLen()), "", 1)
         sub_topic  = GetToken(GetText(1, CurrLineLen()), "", 2)
         if  Lower(sub_topic) <> Lower(main_topic)
         and (        SubStr(sub_topic, Length(sub_topic) - 1, 2)  <> "()"
             or Lower(SubStr(sub_topic, 1, Length(sub_topic) - 2)) <> Lower(main_topic))
            GotoBufferId(help_id)
            if textformat == "ascii"
               if lFind("^" + de_regexp(sub_topic) + "$", "gix")
                  AddLine(Format("   See: ", main_topic))
               endif
            else
               if lFind(">" + sub_topic + "<", "gi")
                  AddLine(Format('   Subtopic of: <a href="#',
                                 topic_to_tag(main_topic),
                                 '">',
                                 main_topic,
                                 "</a>"))
               endif
            endif
            GotoBufferId(topics_id)
         endif
         update_display()
         Message("Adding a topic-reference to subtopics in the index   ", CurrLine() * 100 / NumLines(), " % ")
         test_for_ok(ok)
      until not ok
         or not Down()
      GotoBufferId(help_id)
      BegFile()
      Alarm()
      update_display()
   endif
   if not helphelp_reenabled
      reenable_helphelp()
   endif
   if ok
      Message("Ready.")
   else
      Warn("Hlp2txt was aborted.")
   endif
   if ok
      case textformat
         when "html"
            if YesNo("Start the default .HTML browser?") == 1
               SaveFile()
               Dos(CurrFilename(), _DONT_PROMPT_)
            endif
         when "word"
            if YesNo("Start the default .DOC wordprocessor?") == 1
               SaveFile()
               Dos(CurrFilename(), _DONT_PROMPT_)
            endif
      endcase
   endif
   debug_signal()
   if DEBUG
      GotoBufferId(debug_id)
      ChangeCurrFilename(Format("Debug_", GetDateStr(), "_", GetTimeStr()),
                        _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
      BufferType(_NORMAL_)
   endif
   Set(DateSeparator, old_dateseparator)
   Set(DateFormat, old_dateformat)
   Set(InsertLineBlocksAbove, old_ilba)
   Set(UnMarkAfterPaste, old_uap)
   Set(Break, old_break)
   UpdateDisplay(_ALL_WINDOWS_REFRESH_)
   PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
   if  NumFiles() == 1
   and Lower(SubStr(CurrFilename(), 2, 7)) == "unnamed"
      AbandonEditor()
   endif
end

#else
   proc Main()
      Warn("Sorry, this macro does not work for TSE 2.5 and below.")
   end
#endif
