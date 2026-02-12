// emtoems

/* File Name...: Pctags.s         															*/
/* Program Name: PCTags macro procedures for The SemWare Editor      */
/* Version.....: 0.10																			      */
/* Author......: Ron Hockemeier													  */

/************************************************************************

TSE macros to search a PC-TAGS generated tagfile; retrieve the file_name
and function_info; edit the file_name; and position the cursor at the
row where the function is located.

Works with ONE tagfile

!!! NOTE: !!! If you add this to yout TSE.S file remove the procedures
"GetWordAtCursor()" and "GetTextUntil()" as they duplicate procedures in
the default TSE.S file.

You must change the sting assigned to "s_tagfile" (in proc pctags_main)
to match the path and file name of your tagfile.

As written, the find used in these PC-TAGS procedures
is case insensitive.

*************************************************************************/

proc Pctags_main( string s_word )
// common procedure called by:
//   Pctags_Auto()
//   Pctags_Prompt()

string s_file[80]     // target file name to edit (including dir and path)
string s_phrase[20]   // the target phrase
string s_prefix[20]   // prefix of the the target phrase
string s_suffix[20]   // suffix of the target phrase

string s_tagfile[30]  // path and name for the tagfile

s_tagfile = "pctags.tag"   // <==-- change for *YOUR* path and file
 set( beep, off )
if not editfile( s_tagfile )
  message( "Can't find "+s_tagfile)
else

  begfile()   // position to the start of the file
              // paranoia error trap in case the file is in memory
  if not lFind( s_word ,"i")
    abandonfile()
    message( "Can't find: "+s_word )
  else
    // position to the file name
    wordright()
    // grab the file name
    s_file = GetTextUntil(' ')

    // position to the carat
    lFind( '^',"i")
    // position to the phrase
    wordright()

    // grab the phrase in *two* ways
    s_phrase = gettext( currpos(), 255 )
    s_prefix = getwordatcursor()

    // position to the suffix
    wordright()

    // grab the suffix
    s_suffix = getwordatcursor()

    // bail out of the tagfile
    abandonfile()

    if not editfile( s_file )
      alarm()
      message( "Can't find file: "+s_file )
    else
      begfile()   // position to the start of the file
      // these finds are case insensitive               <==--
      if find( s_phrase , "i" )  // use find to highlight
        // Bingo!
        ScrollToRow(Query(WindowRows)/2)

      // error trap -- try a different find in case non-relevant info
      // on line was changed since PC-Tags was run
      elseif find( s_prefix+" "+s_suffix  , "i" )  // use find to highlight
        // Bingo!
        ScrollToRow(Query(WindowRows)/2)
      else
        alarm()
        message( "Can't find: "+s_phrase )
      endif
    endif
  endif
endif

end Pctags_main

proc pctags_auto()
//  uses word at cursor for search

string s_cur_word[30]     // word we'll get at cursor

if not Length(GetWordAtCursor())
  message( "Cursor is not on a word" )
else
  s_cur_word = GetWordAtCursor()
  // give the rest of the task to our common procedure
  Pctags_main( s_cur_word )
endif
end pctags_auto

proc pctags_prompt()
//  prompts for a word to use in search
string s_prom_word[30] = ""    // word you'll type-in

if Ask('PC-TAGS word? ', s_prom_word) AND Length( s_prom_word )
  // give the rest of the task to our common procedure
  // note: we're adding a space as we pass the word <==--
  // delete the space if you want to use partial function names
  Pctags_main( s_prom_word + " " )
else
  message( "Sorry.  Need a word" )
endif
 set( beep, on )
end pctags_prompt

// WP4PROG keys
 <Ctrl ]>    pctags_auto()
 <Alt  ]>    pctags_prompt()
