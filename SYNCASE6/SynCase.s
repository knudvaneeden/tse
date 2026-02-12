/*
   Macro:      SynCase
   Author:     Carlo.Hogeveen@xs4all.nl
   Date:       28 Februari 1999
   Version     6


   Purpose: Set known sets of keywords in their correct case,
            the keyword-set depending on the file's extension.
            A default Casing can be specified for words outside the set.
            Comments and quoted strings are not formatted.

            This macro is usefull for languages with large sets of known
            keywords for which you want to see the keywords in a particular
            combination of upper and lower case letters.

            Obviously the TSE macro language SAL is a prime candidate.
            For the word-rich Cobol language I like to set the Cobol words
            in lower case and all other words in upper case.


   Install: Download and install Global.zip, MacPar3.zip and ClipBor2.zip.

            From SynCase.zip copy SynCase.s and SynCase.dat to TSE's "mac"
            directory, compile SynCase.s.

            Only for users of TSE 2.8 upwards:

               Either copy the Sal.syn file from the .zip file to TSE's
               "synhi" directory.

               Or copy the Sal.txt file from the .zip file to TSE's "synhi"
               directory, and convert it to a Sal.syn file by starting TSE
               with a dummy file, and using these menus:
               -  Escape, Options, Full Configuration, Display/Color Options,
                  Configure SyntaxHilite Mapping Sets, Other, "Sal.syn",
                  Overlay Settings from Mapping Text File, Yes,
                  "...\Tse32\SynHi\Sal.txt", Escape.
               -  You should now see a message that a .syn file is written.
               -  Done: Press <Escape> a lot :-)


   Use:     You can LOAD the macro yourself or typically and automatically
            from the Macro AutoloadList to:

             - immediately start syntax casing each line as you type,

            or you can EXECUTE this macro to:

             - syntax case the whole current file,
             - activate the "syntax casing as you type",
             - deactivate the "syntax casing as you type",
             - configure it's options,

            or you can do both.


   Note:    For 32-bit versions of TSE this macro uses the syntax hiliting
            data and keywords whereever possible, so users can configure
            their syntax hiliting and their syntax casing in one place and
            in one way! Currently there is only one syntax casing option
            which is not a syntax hiliting option.

   Note:    Users of 16-bit TSE versions have to resort to editing the
            file SynCase.dat when they want to add or change keywords.

   Note:    This macro doesn't work for TSE 2.6, because that is a 32-bit
            version which doesn't support syntax hiliting. Since the upgrade
            from TSE 2.6 to TSE 2.8 has been freely available from Semware's
            web site, there is no point in supporting that obsolete version.

   Note:    The following TSE variables are NOT supported by this macro.
            You can see them (I did that for future use), but they don't do
            anything as far as this macro is concerned.
               tilleolstartcol1
               tilleolstartcol2
               tilleolstartcol3
               quoteescape1
               quoteescape2
               quoteescape3


   Warning: When configuring TSE32's syntax hiliting keywords, NEVER EVER
            set the option "Ignore Case" to "On": this will also convert
            the syntax hiliting keywords themselves to lower case, so just
            putting the option back to "Off" again won't work.
            Hopefully Semware will fix this in later versions.

            Once the "Ignore Case" option is "On", there are four possible
            remedies:

               Get the original .syn file from Semware's installation
               floppies by installing TSE32 to a temporary directory.
               This only works for TSE 2.8: after that Semware started
               distributing lower-case .syn files.

               Use TSE32's Configuration menu to select the syntax hiliting
               keywords and overtype them in the case you want; this is lots
               of work, and no fun.

               Use TSE32's Configuration menu to write the Syntax Hiliting
               Settings to a Mapping Text File.
               Edit the created Mapping Text File; it is a lot easier to edit
               this file than than to just overtype keywords in the menu.
               Use TSE32's Configuration menu to overlay the Syntax Hiliting
               Settings from the edited Mapping Text File.
               It's still a lot of work.

               Reinstall the Sal.syn or Sal.txt file from syncase.zip.
               This is the easy solution.


   Claimer: This macro contains errors!

            Because of the way use I this macro on MY programs, these errors
            either don't occur or are so minor that they don't bother me.
            I have been a delighted user of SynCase for five years now,
            and have found it to be very stable.

            It probably works just as well for you, but it might not.


   History:

      Version 1, 21 June 1999.

         Initial release.

      Version 2, 28 June 1999.

         Bug solved.
            If you switched from a file with a Syntax Casing
            extension to a file without one, then the second file
            was Syntax Cased according to the first file.

         Bug solved.
            TSE 2.80b looks at syntax hiliting definitions, but
            in TSE 2.80b there isn't a separate syntax hiliting
            WordSet yet. That feature must have been added somewhere
            between TSE 2.80e and 2.80h. Solution for all versions
            of TSE: if the extension specific syntax hiliting WordSet
            is not present or not filled, then the editor's global
            WordSet is used.

         Bug solved.
            In a SAL macro you now can type "maximum" in all lower
            case letters without it being converted to "Maximum"
            because "Max" was a known TSE word.

         Bug solved.
            You could not add a SynCase extension ".s",
            if there already existed a SynCase extension ".si".

      Version 3, 14 May 2001.

         With TSE 3.0 Semware made syntax hilitng default case-
         insensitive, which is a good thing (!), but it is a step back
         for users of the SynCase macro, which "cases" Sal macro words
         to their syntax hiliting definition in the Sal.syn file.

         (For speed reasons, the whole Sal.syn file is lowercased
         as soon as the option "Ignore Case" is set to "On". Ouch!)

         Included is the last "cased" Sal syntax hiliting file that
         Semware distributed with a beta version of TSE 3.0 (2.99q).

         It is TSE 3.0-specific (!), and in text format both for
         compatibility reasons, and because that makes it harder
         to accidentally overwrite.

         TSE 2.8 users have no problem. You can remain using
         the Sal.syn file TSE came with. If necessary (if you did set the
         "Ignore case" option to "On", you can set the "Ignore Case"
         option to "Off", and then get the original Sal.syn file from
         the installation floppies by installing a second copy of TSE
         to a temporary dummy directory.

         TSE 3.0 users should import the Sal.txt that comes with
         version 3 of SynCase as follows, thus overwriting Sal.syn:
         -  Copy the included Sal.txt to e.g. C:\Tse32\SynHi\Sal.txt.
         -  Start TSE 3.0 with a dummy file.
         -  Escape, Options, Full Configuration, Display/Color Options,
            Configure SyntaxHilite Mapping Sets, Other, Sal.syn,
            Overlay Settings from Mapping Text File, Yes,
            (same as above:) C:\Tse32\SynHi\Sal.txt, Escape.
         -  You should now see a message that a .syn file is written.
         -  Done: Press <Escape> a lot :-)

      Version 4, 26 January 2004.

         Added a cased Sal.syn and Sal.txt file for TSE 4.2.

            These will also work for lower versions of TSE downto TSE 2.8.
            They might accidentially case a word that is not in your version
            of TSE yet. Unlikely and harmless. For TSE 2.5 SynCase doesn't
            use Sal.syn, but more of SynCase.dat.

            The keywords in Sal.syn/Sal.txt have been thoroughly researched,
            and I claim them to be even more consistent than the ones
            distributed with the Sal.syn of TSE 4.2.
            See Sal.txt for elaborate comments on this.

         Updated the documentation a bit.

         Added not syntax-casing when BrowseMode is ON for TSE 3.0 upwards.

      Version 5, 22 August 2005.

         Updated the cased Sal.syn and Sal.txt file for TSE 4.4.

      Version 6, 4 September 2005.

         Made SynCase clean up its _edit_file_ history, because for instance
         the OpenType macro would otherwise show the ".syn" filetype as
         default, to the surpise of the user, who never explicitly opened
         such a filetype.
*/

#define LEFT_MARGIN 4

integer syncase_id                             = 0
integer keyword_id                             = 0
string  init_ext                          [29] = "non eksisting file eksension"
integer whenloaded_clockticks                  = 0
integer main_clockticks                        = 0
integer is_syntax_casing_ext                   = FALSE

string  syncase_ext                      [255] = ""
string  syncase_defaultcasing            [255] = ""
string  syncase_wordset                  [255] = ""
string  syncase_multilinedelimited1_from [255] = ""
string  syncase_multilinedelimited1_to   [255] = ""
string  syncase_multilinedelimited2_from [255] = ""
string  syncase_multilinedelimited2_to   [255] = ""
string  syncase_multilinedelimited3_from [255] = ""
string  syncase_multilinedelimited3_to   [255] = ""
string  syncase_tilleol1                 [255] = ""
string  syncase_tilleol2                 [255] = ""
string  syncase_tilleol3                 [255] = ""
string  syncase_tilleolstartcol1         [255] = ""
string  syncase_tilleolstartcol2         [255] = ""
string  syncase_tilleolstartcol3         [255] = ""
string  syncase_quote1                   [255] = ""
string  syncase_quote2                   [255] = ""
string  syncase_quote3                   [255] = ""
string  syncase_quoteescape1               [1] = ""
string  syncase_quoteescape2               [1] = ""
string  syncase_quoteescape3               [1] = ""

// Global vars for during option configuration.
integer repeat_list           = FALSE
integer redisplay_modify_menu = FALSE
string  recent_ext [255]      = ""

// State fields used when syntax casing the current line.
integer multiline_begin       = 0
integer multiline_end         = 0
integer outside_begin         = 0
integer outside_end           = 0
integer old_numlines          = 0
integer previous_line         = 0
integer previous_column       = 0
string  previous_word   [255] = ""
string  previouser_word [255] = ""

/* The following two procedures were copied from a Semware macro.
   Procedure rWordSet returns the editor's WordSet in readable format.
*/
constant DQUOTE = 34, DASH = 45, BACKSLASH = 92
string  code[]   = "dxoxxxabtnvfr"
string proc mChr(integer i)
    case i
        when 0..6, 14..31, 255      // ctrl chars
            return (Format('\d',i:3:'0'))
        when 7..13                  // bell, backspace, tab, lf, vtab, ff, cr
            return ('\'+code[i])
        when DQUOTE, DASH, BACKSLASH    // ", -, \
            return ('\'+Chr(i))
    endcase
    return (Chr(i))
end

string proc  rWordSet()
    string  s[32] = Query(WordSet),
            ws[255] = ''
    integer i = 0, n

    while i < 256
        if GetBit(s,i)
            ws = ws + mChr(i)
            n = i + 1
            while n < 256 and GetBit(s,n)
                n = n + 1
            endwhile
            n = n - 1
            if n - i > 1
                ws = ws + '-' + mChr(n)
                i = n
            endif
        endif
        i = i + 1
    endwhile
    // check for '-' at beginning and remove the '\' from before it
    if (SubStr(ws, 1, 2) == "\-")
        ws = SubStr(ws, 2, 255)
    endif
    return (ws)
end

#ifdef WIN32
#else
   integer proc LongestLineInBuffer()
      integer result = 0
      PushPosition()
      BegFile()
      repeat
         if result < CurrLineLen()
            result = CurrLineLen()
         endif
      until not Down()
      PopPosition()
      return(result)
   end
#endif

string proc regify(string text)
   // Makes a non regular expression string fit for use in a regular expression.
   string result [255] = ""
   integer index = 0
   for index = 1 to Length(text)
      if Pos(text[index], ".^$|?[]-~*+@#{}\'" + '"')
         result = result + "\"
      endif
      result = result + text[index]
   endfor
   return(result)
end

proc unset_syncase_variables()
   syncase_ext                      = ""
   syncase_defaultcasing            = ""
   syncase_wordset                  = ""
   syncase_multilinedelimited1_from = ""
   syncase_multilinedelimited1_to   = ""
   syncase_multilinedelimited2_from = ""
   syncase_multilinedelimited2_to   = ""
   syncase_multilinedelimited3_from = ""
   syncase_multilinedelimited3_to   = ""
   syncase_tilleol1                 = ""
   syncase_tilleol2                 = ""
   syncase_tilleol3                 = ""
   syncase_tilleolstartcol1         = ""
   syncase_tilleolstartcol2         = ""
   syncase_tilleolstartcol3         = ""
   syncase_quote1                   = ""
   syncase_quote2                   = ""
   syncase_quote3                   = ""
   syncase_quoteescape1             = ""
   syncase_quoteescape2             = ""
   syncase_quoteescape3             = ""
   EmptyBuffer(keyword_id)
end

string proc get_syn_value(string var_name)
   string result [255] = ""
   integer offset = Length(var_name) + 1
   if lFind(var_name + "=", "gil")
      result = GetText(CurrPos() + offset, CurrLineLen() - offset)
   endif
   return(result)
end

proc copy_to_syncase_variables(integer divide_and_conquer)
   syncase_defaultcasing               =          get_syn_value("defaultcasing")
   syncase_wordset                     =          get_syn_value("wordset")
   if syncase_wordset == ""
      syncase_wordset = rWordSet()
   endif
   if divide_and_conquer
      syncase_multilinedelimited1_from = GetToken(get_syn_value("multilinedelimited1"), " ", 1)
      syncase_multilinedelimited1_to   = GetToken(get_syn_value("multilinedelimited1"), " ", 2)
      syncase_multilinedelimited2_from = GetToken(get_syn_value("multilinedelimited2"), " ", 1)
      syncase_multilinedelimited2_to   = GetToken(get_syn_value("multilinedelimited2"), " ", 2)
      syncase_multilinedelimited3_from = GetToken(get_syn_value("multilinedelimited3"), " ", 1)
      syncase_multilinedelimited3_to   = GetToken(get_syn_value("multilinedelimited3"), " ", 2)
   else
      syncase_multilinedelimited1_from =          get_syn_value("multilinedelimited1_from")
      syncase_multilinedelimited1_to   =          get_syn_value("multilinedelimited1_to")
      syncase_multilinedelimited2_from =          get_syn_value("multilinedelimited2_from")
      syncase_multilinedelimited2_to   =          get_syn_value("multilinedelimited2_to")
      syncase_multilinedelimited3_from =          get_syn_value("multilinedelimited3_from")
      syncase_multilinedelimited3_to   =          get_syn_value("multilinedelimited3_to")
   endif
   syncase_tilleol1                    =          get_syn_value("tilleol1")
   syncase_tilleol2                    =          get_syn_value("tilleol2")
   syncase_tilleol3                    =          get_syn_value("tilleol3")
   syncase_tilleolstartcol1            =          get_syn_value("tilleolstartcol1")
   syncase_tilleolstartcol2            =          get_syn_value("tilleolstartcol2")
   syncase_tilleolstartcol3            =          get_syn_value("tilleolstartcol3")
   syncase_quote1                      =          get_syn_value("quote1")
   syncase_quote2                      =          get_syn_value("quote2")
   syncase_quote3                      =          get_syn_value("quote3")
   syncase_quoteescape1                =          get_syn_value("quoteescape1")
   syncase_quoteescape2                =          get_syn_value("quoteescape2")
   syncase_quoteescape3                =          get_syn_value("quoteescape3")
end

proc copy_from_syncase_dat_to_syncase_variables()
   integer org_id = GetBufferId()
   GotoBufferId(syncase_id)
   if lFind("^\[" + syncase_ext + "\]", "gix")
      UnMarkBlock()
      MarkLine()
      if lFind("{^\[.#\]}|{^keywords=}", "ix+")
         Up()
      else
         EndFile()
      endif
      MarkLine()
      copy_to_syncase_variables(FALSE)
      GotoBlockEnd()
      UnMarkBlock()
      if  lFind("{^\[.#\]}|{^keywords=}", "ix+")
      and lFind("^keywords=", "cgix")
         Down()
         BegLine()
         MarkLine()
         if lFind("^\[.#\]", "ix")
            Up()
         else
            EndFile()
         endif
         MarkLine()
         Copy()
         GotoBufferId(keyword_id)
         EmptyBuffer()
         Paste()
         UnMarkBlock()
      else
         GotoBufferId(keyword_id)
         EmptyBuffer()
      endif
   else
      unset_syncase_variables()
   endif
   GotoBufferId(org_id)
end

#ifdef WIN32

   proc add_line(string var_name, string var_value)
      if lFind(var_name, "gil")
         Right(Length(var_name))
         KillToEol()
         InsertText(var_value, _INSERT_)
      else
         GotoBlockEnd()
         AddLine(var_name + var_value)
      endif
   end

   proc copy_syncase_variables_to_syncase_dat()
      integer org_id = GetBufferId()
      GotoBufferId(syncase_id)
      if lFind("^\[" + syncase_ext + "\]", "gix")
         UnMarkBlock()
         MarkLine()
         if lFind("^\[.#\]", "ix+")
            Up()
         else
            EndFile()
         endif
         MarkLine()
         if lFind("keywords=", "gil")
            repeat
               KillLine()
            until not isCursorInBlock()
         endif
         add_line("wordset="                 , syncase_wordset)
         add_line("multilinedelimited1_from=", syncase_multilinedelimited1_from)
         add_line("multilinedelimited1_to="  , syncase_multilinedelimited1_to)
         add_line("multilinedelimited2_from=", syncase_multilinedelimited2_from)
         add_line("multilinedelimited2_to="  , syncase_multilinedelimited2_to)
         add_line("multilinedelimited3_from=", syncase_multilinedelimited3_from)
         add_line("multilinedelimited3_to="  , syncase_multilinedelimited3_to)
         add_line("tilleol1="                , syncase_tilleol1)
         add_line("tilleol2="                , syncase_tilleol2)
         add_line("tilleol3="                , syncase_tilleol3)
         add_line("tilleolstartcol1="        , syncase_tilleolstartcol1)
         add_line("tilleolstartcol2="        , syncase_tilleolstartcol2)
         add_line("tilleolstartcol3="        , syncase_tilleolstartcol3)
         add_line("quote1="                  , syncase_quote1)
         add_line("quote2="                  , syncase_quote2)
         add_line("quote3="                  , syncase_quote3)
         add_line("quoteescape1="            , syncase_quoteescape1)
         add_line("quoteescape2="            , syncase_quoteescape2)
         add_line("quoteescape3="            , syncase_quoteescape3)
         GotoBlockEnd()
         UnMarkBlock()
         if lFind("^\[.#\]", "ix+")
            Up()
         else
            EndFile()
         endif
         AddLine("Keywords=")
         AddLine()
         GotoBufferId(keyword_id)
         MarkLine(1, NumLines())
         Copy()
         GotoBufferId(syncase_id)
         Paste()
         UnMarkBlock()
      endif
      GotoBufferId(org_id)
   end

   proc copy_from_synfilename_syn_to_syncase_dat()
      integer org_id = GetBufferId()
      string synfilename [255] = GetSynFilename()
      AbandonFile(GetBufferId(synfilename))
      AbandonFile(GetBufferId(SplitPath(synfilename, _NAME_) + ".txt"))
      EditFile("-b-2 " + synfilename, _HIDDEN_)
      ExecMacro("syncfg2")
      AbandonFile(GetBufferId(synfilename))
      if Pos(".syn", Lower(GetHistoryStr(_EDIT_HISTORY_, 1)))
         DelHistoryStr(_EDIT_HISTORY_, 1)
      endif
      /* We are now in synfilename.txt, a readable form of
         synfilename.syn. We are going to copy the relevant content
         of synfile.txt to macro variables and then the macro
         variables to syncase.dat.
         In the end we will have copied syntax hiliting data to
         the internal version of syncase.dat, and from then on it
         suffices to query only one buffer.
      */
      BegFile()
      UnMarkBlock()
      MarkLine()
      if lFind("^\[keywords", "gix")
         Up()
      else
         EndFile()
      endif
      MarkLine()
      copy_to_syncase_variables(TRUE)
      UnMarkBlock()
      // Copy the keywords to the keyword buffer.
      if lFind("^\[keywords", "gix")
         MarkLine(1, CurrLine())
         KillBlock()
         while lFind("^\[keywords", "gix")
            KillLine()
         endwhile
         MarkLine(1, NumLines())
         Copy()
         AbandonFile()
         GotoBufferId(keyword_id)
         EmptyBuffer()
         Paste()
         UnMarkBlock()
      else
         GotoBufferId(keyword_id)
         EmptyBuffer()
      endif
      GotoBufferId(org_id)
      copy_syncase_variables_to_syncase_dat()
   end

#endif

proc prepare_syncase_buffer()
   /* While the internal SynCase buffer Format is identical for the 16-bit
      and the 32-bit TSE versions, the way this procedure fills that SynCase
      buffer differs.

      TSE 16 only uses SynCase.dat, which means that all SynCase data for
      all extensions can be loaded at once.

      TSE 32 uses both SynCase.dat and the syntax hiliting data, which means
      that it is more efficient to load the syntax hiliting data once per
      each actually used file extension.
   */
   integer org_id               = GetBufferId()
   string  curr_ext       [255] = CurrExt()
   #ifdef WIN32
      string synfilename  [255] = ""
   #endif
   // If the current SynCase data is not for the current (new) file extension.
   if syncase_ext <> curr_ext
      syncase_ext = curr_ext
      ExecMacro("clipbord push")
      PushBlock()
      // If there isn't an internal SynCase.dat buffer yet.
      if syncase_id == 0
         // Create one with a different internal name.
         syncase_id = CreateBuffer("Syntax case data buffer", _SYSTEM_)
         // Load SynCase.dat into it.
         InsertFile(LoadDir() + "mac\syncase.dat", _DONT_PROMPT_)
         UnMarkBlock()
         #ifdef WIN32
            // Signal to reload syntax hiliting data into SynCase.dat.
            BegFile()
            while lFind("^\[.#\] #reloaded$", "ix")
               lFind(" #reloaded$", "ix")
               KillToEol()
            endwhile
         #endif
         // Once create buffer to store keywords for current extension.
         if keyword_id == 0
            keyword_id = CreateBuffer("Syntax case keyword buffer", _SYSTEM_)
         endif
      endif
      GotoBufferId(syncase_id)
      EndFile()
      // If current file extension in syncase.dat.
      if lFind("^\[" + curr_ext + "\]", "gix")
         is_syntax_casing_ext = TRUE
         #ifdef WIN32
            EndLine()
            if GetWord(TRUE) <> "reloaded"
               InsertText(" reloaded", _INSERT_)
            endif
            GotoBufferId(org_id)
            synfilename = GetSynFilename()
            if synfilename == ""
               is_syntax_casing_ext = FALSE
               unset_syncase_variables()
            else
               copy_from_synfilename_syn_to_syncase_dat()
            endif
         #endif
         copy_from_syncase_dat_to_syncase_variables()
      else
         is_syntax_casing_ext = FALSE
         #ifdef WIN32
         #else
            unset_syncase_variables()
         #endif
      endif
      PopBlock()
      ExecMacro("clipbord pop")
   endif
   GotoBufferId(org_id)
end

string proc my_ChrSet(string character_set)
   // in TSE 16 ChrSet only accepts a constant, not a variable.
   // This procedure gets around that.
   // Warning: my_chrset does not support \dnnn and \xnn yet!
   #ifdef WIN32
      return(ChrSet(character_set))
   #else
      integer index = 0
      integer character = 0
      string result [32] = ChrSet("")
      for index = 1 to Length(character_set)
         if character_set[index] <> "-"
         or index == 1
         or index == Length(character_set)
            SetBit(result, Asc(character_set[index]))
         else
            character = Asc(character_set[index - 1])
            repeat
               character = character + 1
               SetBit(result, character)
            until character >= Asc(character_set[index + 1])
         endif
      endfor
      return(result)
   #endif
end

string proc findstr2(string findstr, var integer empty)
   string result [255] = ""
   if findstr <> ""
      result = "{" + regify(findstr) + "}"
      if empty
         empty = FALSE
      else
         result = "|" + result
      endif
   endif
   return(result)
end

string proc findstr(string find1, string find2, string find3,
           string find4, string find5, string find6)
   string result[255] = ""
   integer empty = TRUE
   result = findstr2(find1, empty) + findstr2(find2, empty) + findstr2(find3, empty)
          + findstr2(find4, empty) + findstr2(find5, empty) + findstr2(find6, empty)
   /* An empty search string is always found, which is not what we want,
      so we replace such by what is an unfindable string in non-binary mode,
      and an extremely unlikely to be found string otherwise.
   */
   if result == ""
      result = "\n\n\t\t\f\f\t\n\n"
   endif
   return(result)
end

proc reestablish_multiline_boundaries()
   PushPosition()
   BegLine()
   if lFind(findstr(syncase_multilinedelimited1_from,
                    syncase_multilinedelimited1_to  ,
                    syncase_multilinedelimited2_from,
                    syncase_multilinedelimited2_to  ,
                    syncase_multilinedelimited3_from,
                    syncase_multilinedelimited3_to  ), "bix")
      if lFind(findstr(syncase_multilinedelimited1_from,
                       syncase_multilinedelimited2_from,
                       syncase_multilinedelimited3_from,
                       "", "", ""                      ), "bgcix")
         multiline_begin = CurrLine()
         outside_begin   = FALSE
         outside_end     = FALSE
         if lFind(findstr(syncase_multilinedelimited1_to,
                          syncase_multilinedelimited2_to,
                          syncase_multilinedelimited3_to,
                          "", "", ""                    ), "ix+")
            multiline_end = CurrLine()
         else
            multiline_end = MAXINT
         endif
      else
         Down()
         multiline_begin = MAXINT
         multiline_end   = MAXINT
         outside_begin   = CurrLine()
         if lFind(findstr(syncase_multilinedelimited1_from,
                          syncase_multilinedelimited2_from,
                          syncase_multilinedelimited3_from,
                          "", "", ""                      ), "ix+")
            Up()
            outside_end = CurrLine()
         else
            outside_end = MAXINT
         endif
      endif
   else
      EndLine()
      if lFind(findstr(syncase_multilinedelimited1_from,
                       syncase_multilinedelimited1_to  ,
                       syncase_multilinedelimited2_from,
                       syncase_multilinedelimited2_to  ,
                       syncase_multilinedelimited3_from,
                       syncase_multilinedelimited3_to  ), "ix")
         if lFind(findstr(syncase_multilinedelimited1_from,
                          syncase_multilinedelimited2_from,
                          syncase_multilinedelimited3_from,
                          "", "", ""                      ), "cgix")
            Up()
            multiline_begin = FALSE
            multiline_end   = FALSE
            outside_begin   = MININT
            outside_end     = CurrLine()
         else
            multiline_end   = CurrLine()
            outside_begin   = FALSE
            outside_end     = FALSE
            if lFind(findstr(syncase_multilinedelimited1_from,
                             syncase_multilinedelimited2_from,
                             syncase_multilinedelimited3_from,
                             "", "", ""                      ), "bix")
               multiline_begin = CurrLine()
            else
               multiline_begin = MININT
            endif
         endif
      else
         multiline_begin = 0
         multiline_end   = 0
         outside_begin   = MININT
         outside_end     = MAXINT
      endif
   endif
   PopPosition()
end

proc syntax_case_the_current_line()
   /* Note, that this procedure and all the procedures it calls do not use
      block marking! Because of this it is not necessary to push the
      clipbord here, which would have made the keyboard response very slow!
   */
   integer org_id               = GetBufferId()
   string  old_wordset     [32] = Set(WordSet, my_ChrSet(syncase_wordset))
   string  word           [255] = ""
   string  formatted_word [255] = ""
   string  quote          [255] = ""
   integer current_line = CurrLine()
   if is_syntax_casing_ext
      PushPosition()
      previouser_word = previous_word
      previous_word   = GetWord(TRUE)
      // If current line inside known multiline comment or outside known
      // multiline comments.
      if NumLines() == old_numlines
      and (  (current_line in multiline_begin .. multiline_end)
          or (current_line in outside_begin   .. outside_end  ))
         // Do nothing.
      else
         old_numlines = NumLines()
         reestablish_multiline_boundaries()
      endif
      if current_line in outside_begin .. outside_end
         // From here on we only worry about the current line.
         BegLine()
         while CurrChar() <> _AT_EOL_
         and   CurrChar() <> _BEYOND_EOL_
            word = GetWord(FALSE)
            formatted_word = word
            if  CurrLine()                      == previous_line
            and CurrCol() + Length(word)        == previous_column + 1
            and Lower(Word[1:Length(word) - 1]) == Lower(previouser_word)
            and       Word[1:Length(word) - 1]  <>       previouser_word
               formatted_word = previouser_word + word[Length(word)]
               previous_word  = ""
            endif
            if word == ""
               if quote == ""
                  if     syncase_tilleol1 <> ""
                  and    GetText(CurrPos(), Length(syncase_tilleol1)) == syncase_tilleol1
                     quote = syncase_tilleol1
                     Right(Length(syncase_tilleol1))
                  elseif syncase_tilleol2 <> ""
                  and    GetText(CurrPos(), Length(syncase_tilleol2)) == syncase_tilleol2
                     quote = syncase_tilleol2
                     Right(Length(syncase_tilleol2))
                  elseif syncase_tilleol3 <> ""
                  and    GetText(CurrPos(), Length(syncase_tilleol3)) == syncase_tilleol3
                     quote = syncase_tilleol3
                     Right(Length(syncase_tilleol3))
                  elseif syncase_quote1 <> ""
                  and    GetText(CurrPos(), Length(syncase_quote1)) == syncase_quote1
                     quote = syncase_quote1
                     Right(Length(syncase_quote1))
                  elseif syncase_quote2 <> ""
                  and    GetText(CurrPos(), Length(syncase_quote2)) == syncase_quote2
                     quote = syncase_quote2
                     Right(Length(syncase_quote2))
                  elseif syncase_quote3 <> ""
                  and    GetText(CurrPos(), Length(syncase_quote3)) == syncase_quote3
                     quote = syncase_quote3
                     Right(Length(syncase_quote3))
                  else
                     Right()
                  endif
               else
                  if     quote == GetText(CurrPos(), Length(syncase_tilleol1))
                     quote = ""
                     Right(Length(syncase_tilleol1))
                  elseif quote == GetText(CurrPos(), Length(syncase_tilleol1))
                     quote = ""
                     Right(Length(syncase_tilleol2))
                  elseif quote == GetText(CurrPos(), Length(syncase_tilleol2))
                     quote = ""
                     Right(Length(syncase_tilleol3))
                  elseif quote == GetText(CurrPos(), Length(syncase_tilleol3))
                     quote = ""
                     Right(Length(syncase_quote1))
                  elseif quote == GetText(CurrPos(), Length(syncase_quote1))
                     quote = ""
                     Right(Length(syncase_quote1))
                  elseif quote == GetText(CurrPos(), Length(syncase_quote2))
                     quote = ""
                     Right(Length(syncase_quote1))
                  elseif quote == GetText(CurrPos(), Length(syncase_quote3))
                     quote = ""
                     Right(Length(syncase_quote1))
                  else
                     Right()
                  endif
               endif
            else
               if quote == ""
                  GotoBufferId(keyword_id)
                  if lFind(word, "giw")
                     formatted_word = GetWord(FALSE)
                  else
                     case syncase_defaultcasing
                        when "Upper"
                           formatted_word = Upper(word)
                        when "Lower"
                           formatted_word = Lower(word)
                     endcase
                  endif
                  GotoBufferId(org_id)
                  if word <> formatted_word
                     InsertText(formatted_word, _OVERWRITE_)
                     WordLeft()
                  endif
               endif
               Right(Length(word))
            endif
         endwhile
      endif
      PopPosition()
      previous_line   = CurrLine()
      previous_column = CurrCol()
   endif
   Set(WordSet, old_wordset)
end

proc syntax_case_current_file()
   if is_syntax_casing_ext
      Message("Syntax casing the current file ...")
      PushPosition()
      BegFile()
      repeat
         syntax_case_the_current_line()
      until not Down()
      PopPosition()
      Message("The current file is syntax cased.")
   else
      Message("Cannot Syntax Case a file with this extension")
   endif
end

proc modify_defaultcasing(string casing)
   PushPosition()
   GotoBufferId(syncase_id)
   if lFind("^\[\" + syncase_ext + "\]", "gix")
      EndLine()
      if  lFind("{^[.#]}|{^defaultcasing=}", "ix")
      and lFind("^defaultcasing=", "cgix")
         GotoPos(Length("defaultcasing") + 2)
         KillToEol()
         InsertText(casing, _INSERT_)
      endif
   endif
   PopPosition()
end

menu defaultcasing_menu()
   TITLE       = "Modify the default case"
   X           = 5 // Vertical
   Y           = 5 // Horizontal
   NOKEYS
   "None" , modify_defaultcasing("None")
   "Upper", modify_defaultcasing("Upper")
   "Lower", modify_defaultcasing("Lower")
end

proc defaultcasing_proc()
   redisplay_modify_menu = TRUE
   defaultcasing_menu()
end

proc modify_value(string varname)
   string varvalue [255] = ""
   redisplay_modify_menu = TRUE
   PushPosition()
   GotoBufferId(syncase_id)
   if lFind("^\[\" + syncase_ext + "\]", "gix")
      EndLine()
      PushPosition()
      if  lFind("{^[.#]}|{^" + varname + "=}", "ix")
      and lFind("^" + varname + "=", "cgix")
         KillPosition()
      else
         PopPosition()
         AddLine(varname + "=")
      endif
      GotoPos(Length(varname) + 2)
      varvalue = GetText(CurrPos(), CurrLineLen() - CurrPos() + 1)
      if Ask("New value for " + varname + "?", varvalue)
         KillToEol()
         InsertText(varvalue, _INSERT_)
      else
         Message("Value not changed")
      endif
   endif
   PopPosition()
end

string proc get_value(string varname)
   string result [255] = ""
   PushPosition()
   GotoBufferId(syncase_id)
   if lFind("^\[\" + syncase_ext + "\]", "gix")
      EndLine()
      if  lFind("{^\[.#\]}|{^" + varname + "=}", "ix")
      and lFind("^" + varname + "=", "cgix")
         result = GetText(Length(varname) + 2,
                          CurrLineLen() - Length(varname) - 1)
      endif
   endif
   PopPosition()
   return(result)
end

#ifdef WIN32
   menu modify_menu()
      TITLE       = "Modify syntax case options for extension"
      X           = 5 // Vertical
      Y           = 5 // Horizontal
      NOKEYS
      "Extension                " [syncase_ext                          :25],                                         , _MF_SKIP_|_MF_GRAYED_
      "DefaultCasing            " [get_value("defaultcasing"           ):25], defaultcasing_proc()                    , _MF_CLOSE_AFTER_     , "Modify the value of DefaultCasing"
      "WordSet                  " [get_value("wordset"                 ):25], modify_value("wordset"                 ), _MF_SKIP_|_MF_GRAYED_, "Modify the value of WordSet"
      "MultiLineDelimited1_from " [get_value("multilinedelimited1_from"):25], modify_value("multilinedelimited1_from"), _MF_SKIP_|_MF_GRAYED_, "Modify the value of MultiLineDelimited1_from"
      "MultiLineDelimited1_to   " [get_value("multilinedelimited1_to"  ):25], modify_value("multilinedelimited1_to"  ), _MF_SKIP_|_MF_GRAYED_, "Modify the value of MultiLineDelimited1_to"
      "MultiLineDelimited2_from " [get_value("multilinedelimited2_from"):25], modify_value("multilinedelimited2_from"), _MF_SKIP_|_MF_GRAYED_, "Modify the value of MultiLineDelimited2_from"
      "MultiLineDelimited2_to   " [get_value("multilinedelimited2_to"  ):25], modify_value("multilinedelimited2_to"  ), _MF_SKIP_|_MF_GRAYED_, "Modify the value of MultiLineDelimited2_to"
      "MultiLineDelimited3_from " [get_value("multilinedelimited3_from"):25], modify_value("multilinedelimited3_from"), _MF_SKIP_|_MF_GRAYED_, "Modify the value of MultiLineDelimited3_from"
      "MultiLineDelimited3_to   " [get_value("multilinedelimited3_to"  ):25], modify_value("multilinedelimited3_to"  ), _MF_SKIP_|_MF_GRAYED_, "Modify the value of MultiLineDelimited3_to"
      "TillEol1                 " [get_value("tilleol1"                ):25], modify_value("tilleol1"                ), _MF_SKIP_|_MF_GRAYED_, "Modify the value of TillEol1"
      "TillEol2                 " [get_value("tilleol2"                ):25], modify_value("tilleol2"                ), _MF_SKIP_|_MF_GRAYED_, "Modify the value of TillEol2"
      "TillEol3                 " [get_value("tilleol3"                ):25], modify_value("tilleol3"                ), _MF_SKIP_|_MF_GRAYED_, "Modify the value of TillEol3"
      "TillEolStartCol1         " [get_value("tilleolstartcol1"        ):25], modify_value("tilleolstartcol1"        ), _MF_SKIP_|_MF_GRAYED_, "Modify the value of TillEolStartCol1"
      "TillEolStartCol2         " [get_value("tilleolstartcol2"        ):25], modify_value("tilleolstartcol2"        ), _MF_SKIP_|_MF_GRAYED_, "Modify the value of TillEolStartCol2"
      "TillEolStartCol3         " [get_value("tilleolstartcol3"        ):25], modify_value("tilleolstartcol3"        ), _MF_SKIP_|_MF_GRAYED_, "Modify the value of TillEolStartCol3"
      "Quote1                   " [get_value("quote1"                  ):25], modify_value("quote1"                  ), _MF_SKIP_|_MF_GRAYED_, "Modify the value of Quote1"
      "Quote2                   " [get_value("quote2"                  ):25], modify_value("quote2"                  ), _MF_SKIP_|_MF_GRAYED_, "Modify the value of Quote2"
      "Quote3                   " [get_value("quote3"                  ):25], modify_value("quote3"                  ), _MF_SKIP_|_MF_GRAYED_, "Modify the value of Quote3"
      "QuoteEscape1             " [get_value("quoteescape1"            ):25], modify_value("quoteescape1"            ), _MF_SKIP_|_MF_GRAYED_, "Modify the value of QuoteEscape1"
      "QuoteEscape2             " [get_value("quoteescape2"            ):25], modify_value("quoteescape2"            ), _MF_SKIP_|_MF_GRAYED_, "Modify the value of QuoteEscape2"
      "QuoteEscape3             " [get_value("quoteescape3"            ):25], modify_value("quoteescape3"            ), _MF_SKIP_|_MF_GRAYED_, "Modify the value of QuoteEscape3"
   end
#else
   menu modify_menu()
      TITLE       = "Modify syntax case options for extension"
      X           = 5 // Vertical
      Y           = 5 // Horizontal
      NOKEYS
      "Extension                " [syncase_ext                          :25],                                         , SKIP
      "DefaultCasing            " [get_value("defaultcasing"           ):25], defaultcasing_proc()                    , CLOSEAFTER, "Modify the value of DefaultCasing"
      "WordSet                  " [get_value("wordset"                 ):25], modify_value("wordset"                 ),           , "Modify the value of WordSet"
      "MultiLineDelimited1_from " [get_value("multilinedelimited1_from"):25], modify_value("multilinedelimited1_from"),           , "Modify the value of MultiLineDelimited1_from"
      "MultiLineDelimited1_to   " [get_value("multilinedelimited1_to"  ):25], modify_value("multilinedelimited1_to"  ),           , "Modify the value of MultiLineDelimited1_to"
      "MultiLineDelimited2_from " [get_value("multilinedelimited2_from"):25], modify_value("multilinedelimited2_from"),           , "Modify the value of MultiLineDelimited2_from"
      "MultiLineDelimited2_to   " [get_value("multilinedelimited2_to"  ):25], modify_value("multilinedelimited2_to"  ),           , "Modify the value of MultiLineDelimited2_to"
      "MultiLineDelimited3_from " [get_value("multilinedelimited3_from"):25], modify_value("multilinedelimited3_from"),           , "Modify the value of MultiLineDelimited3_from"
      "MultiLineDelimited3_to   " [get_value("multilinedelimited3_to"  ):25], modify_value("multilinedelimited3_to"  ),           , "Modify the value of MultiLineDelimited3_to"
      "TillEol1                 " [get_value("tilleol1"                ):25], modify_value("tilleol1"                ),           , "Modify the value of TillEol1"
      "TillEol2                 " [get_value("tilleol2"                ):25], modify_value("tilleol2"                ),           , "Modify the value of TillEol2"
      "TillEol3                 " [get_value("tilleol3"                ):25], modify_value("tilleol3"                ),           , "Modify the value of TillEol3"
      "TillEolStartCol1         " [get_value("tilleolstartcol1"        ):25], modify_value("tilleolstartcol1"        ), SKIP      , "Modify the value of TillEolStartCol1"
      "TillEolStartCol2         " [get_value("tilleolstartcol2"        ):25], modify_value("tilleolstartcol2"        ), SKIP      , "Modify the value of TillEolStartCol2"
      "TillEolStartCol3         " [get_value("tilleolstartcol3"        ):25], modify_value("tilleolstartcol3"        ), SKIP      , "Modify the value of TillEolStartCol3"
      "Quote1                   " [get_value("quote1"                  ):25], modify_value("quote1"                  ),           , "Modify the value of Quote1"
      "Quote2                   " [get_value("quote2"                  ):25], modify_value("quote2"                  ),           , "Modify the value of Quote2"
      "Quote3                   " [get_value("quote3"                  ):25], modify_value("quote3"                  ),           , "Modify the value of Quote3"
      "QuoteEscape1             " [get_value("quoteescape1"            ):25], modify_value("quoteescape1"            ), SKIP      , "Modify the value of QuoteEscape1"
      "QuoteEscape2             " [get_value("quoteescape2"            ):25], modify_value("quoteescape2"            ), SKIP      , "Modify the value of QuoteEscape2"
      "QuoteEscape3             " [get_value("quoteescape3"            ):25], modify_value("quoteescape3"            ), SKIP      , "Modify the value of QuoteEscape3"
   end
#endif

proc modify_extension(string ext)
   integer modify_id = 0
   integer line = 0
   PushPosition()
   modify_id = EditFile("c:\dummy" + ext, _NORMAL_)
   ChangeCurrFilename("Changing options for extension " + ext,
                      _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
   EmptyBuffer()
   for line = 1 to 60 // Remove the EOF line out of sight.
      InsertLine()
   endfor
   UpdateDisplay()
   syncase_ext = init_ext
   prepare_syncase_buffer()  // Ensure that internal syncase.dat is up to date.
   repeat
      redisplay_modify_menu = FALSE
      modify_menu()
   until not redisplay_modify_menu
   syncase_ext = init_ext    // Ensure changed settings become active.
   AbandonFile(modify_id)
   PopPosition()
end

proc add_ext_to_syncase(string new_ext)
   PushPosition()
   GotoBufferId(syncase_id)
   EndFile()
   AddLine()
   AddLine("[" + new_ext + "]")
   AddLine("DefaultCasing=None")
   AddLine("Keywords=")
   AddLine()
   modify_extension(new_ext)
   PopPosition()
end

proc insert_extension()
   string answer [255] = CurrExt()
   Ask("New file extension?", answer)
   if answer <> ""
      if answer[1] <> "."
         answer = "." + answer
      endif
      if lFind(answer, "gi$")
         Message("Extension already exists")
         Delay(36)
      else
         AddLine(Format("":LEFT_MARGIN) + answer)
         add_ext_to_syncase(answer)
      endif
      repeat_list = TRUE
      PushKey(<enter>)
   endif
end

proc delete_extension()
   string del_ext [255] = GetText(LEFT_MARGIN + 1, CurrLineLen() - LEFT_MARGIN)
   PushPosition()
   GotoBufferId(syncase_id)
   if lFind("^\[\" + del_ext + "\]", "gix")
      UnMarkBlock()
      MarkLine()
      EndLine()
      if lFind("^\[.#\]", "ix")
         Up()
      else
         EndFile()
      endif
      KillBlock()
   endif
   PopPosition()
   KillLine()
   repeat_list = TRUE
   PushKey(<enter>)
end

Keydef ext_keys
   <del>       delete_extension()
   <greydel>   delete_extension()
   <ins>       insert_extension()
   <greyins>   insert_extension()
   <home>      BegFile()
   <end>       EndFile()
   <greyhome>  BegFile()
   <greyend>   EndFile()
end

proc ext_keys_starter()
   UnHook(ext_keys_starter)
   if Enable(ext_keys)
      ListFooter(" {Del}-Delete {Ins}-Insert {Enter} Modify extension")
   endif
end

proc modify_file_extension()
   recent_ext = CurrExt()
   PushPosition()
   if GotoBufferId(syncase_id)
      // Flush keyboard buffer for our own use.
      while KeyPressed()
         GetKey()
      endwhile
      // Make a list of file extensions.
      PushKey(<alt e>)
      if lFind("^\[.#\]", "givx")
         // Remove the optional (!) line numbers and edit the list.
         BegFile()
         KillLine()
         while lFind("{^ *[0-9]#: }|{ reloaded$}|\[|\]", "ix")
            MarkFoundText()
            KillBlock()
         endwhile
         BegFile()
         repeat
            InsertText(Format("":LEFT_MARGIN), _INSERT_)
            BegLine()
         until not Down()
      else
         GetKey()
         CreateTempBuffer()
      endif
      // Show file extensions and let user select an action.
      repeat
         repeat_list = FALSE
         if lFind("^$", "gix")
            KillLine()
         endif
         MarkColumn(1, LEFT_MARGIN + 1, NumLines(), LongestLineInBuffer())
         Sort(_IGNORE_CASE_)
         UnMarkBlock()
         lFind(recent_ext, "gi")
         Hook(_LIST_STARTUP_, ext_keys_starter)
         if List("Syntax case: supported file extensions", 60)
            Disable(ext_keys)
            recent_ext = GetText(left_margin + 1, CurrLineLen() - left_margin)
            if not repeat_list
               modify_extension(recent_ext)
            endif
         else
            Disable(ext_keys)
         endif
      until not repeat_list
      AbandonFile()
   else
      Warn("Syncase: program error")
   endif
   PopPosition()
end

proc activate_syntax_casing(integer state)
   if state
      main_clockticks = whenloaded_clockticks + 9999
   else
      main_clockticks = whenloaded_clockticks
   endif
end

#ifdef WIN32
   integer proc syntax_casing_activated(integer state)
      integer result
      if ((main_clockticks - whenloaded_clockticks) < 9) == state
         result = _MF_CLOSE_ALL_BEFORE_|_MF_ENABLED_
      else
         result = _MF_GRAYED_|_MF_SKIP_
      endif
      return(result)
   end
#endif

#ifdef WIN32
   menu main_menu()
      TITLE       = "Syntax Case menu"
      X           = 5 // Vertical
      Y           = 5 // Horizontal
      NOKEYS

      "&File       - Case the whole current file",
      syntax_case_current_file(),,
      "Set all known words in the whole current file in their predefined case"

      '&Activate   - Activate   the "as you type" Syntax Casing',
      activate_syntax_casing(ON),
      syntax_casing_activated(ON),
      'Activate   the "as you type" Syntax Casing'

      '&Deactivate - Deactivate the "as you type" Syntax Casing',
      activate_syntax_casing(OFF),
      syntax_casing_activated(OFF),
      'Deactivate the "as you type" Syntax Casing'

      "&Options    - Modify the options for a file extension ...",
      modify_file_extension(),,
      "Add or Delete a file extension or Modify it's casing options ..."
   end
#else
   menu main_menu()
      TITLE       = "Syntax Case menu"
      X           = 5 // Vertical
      Y           = 5 // Horizontal
      NOKEYS

      "&File       - Case the whole current file",
      syntax_case_current_file(),,
      "Set all known words in the whole current file in their predefined case"

      '&Activate   - Activate   the "as you type" Syntax Casing',
      activate_syntax_casing(ON),,
      'Activate the "as you type" Syntax Casing'

      '&Deactivate - Deactivate the "as you type" Syntax Casing',
      activate_syntax_casing(OFF),,
      'Deactivate the "as you type" Syntax Casing'

      "&Options    - Modify the options for a file extension ...",
      modify_file_extension(),,
      "Add or Delete a file extension or Modify it's casing options ..."
   end
#endif

proc after_command()
   #ifdef EDITOR_VERSION
      if not BrowseMode()
         prepare_syncase_buffer()
         syntax_case_the_current_line()
      endif
   #else
      prepare_syncase_buffer()
      syntax_case_the_current_line()
   #endif
end

proc cleanup_after_syncase()
   PushPosition()
   if syncase_id <> 0
      GotoBufferId(syncase_id)
      if FileChanged()
         SaveAs(LoadDir() + "mac\syncase.dat", _DONT_PROMPT_|_OVERWRITE_)
      endif
   endif
   AbandonFile(syncase_id)
   AbandonFile(keyword_id)
   PopPosition()
   UnHook(after_command)
   UnHook(cleanup_after_syncase)
end

proc WhenLoaded()
   if whenloaded_clockticks == 0
      whenloaded_clockticks = GetClockTicks()
      syncase_ext = init_ext
      Hook(_AFTER_COMMAND_, after_command)
      Hook(_ON_ABANDON_EDITOR_, cleanup_after_syncase)
   endif
end

proc WhenPurged()
   cleanup_after_syncase()
end

proc Main()
   main_clockticks = GetClockTicks()

   // Avoid compiler warning for unused variables:
   syncase_tilleolstartcol1 = syncase_tilleolstartcol1
   syncase_tilleolstartcol2 = syncase_tilleolstartcol2
   syncase_tilleolstartcol3 = syncase_tilleolstartcol3
   syncase_quoteescape1     = syncase_quoteescape1
   syncase_quoteescape2     = syncase_quoteescape2
   syncase_quoteescape3     = syncase_quoteescape3

   prepare_syncase_buffer()
   ExecMacro("clipbord push")
   PushBlock()
   #ifdef EDITOR_VERSION
      if BrowseMode()
         Warn("You cannot SynCase this file in BrowseMode")
      else
         main_menu()
      endif
   #else
      main_menu()
   #endif
   PopBlock()
   ExecMacro("clipbord pop")
   // If macro loaded and executed at the same time, then purge macro.
   // Note: this is never true when debugging the macro.
   if main_clockticks - whenloaded_clockticks < 9
      PurgeMacro("syncase")
   endif
end


