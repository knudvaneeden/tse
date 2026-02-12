/******************************************************************************
   Replacement Macro for mNextPunc() included in edmac.s sent in about a
   week ago. That one was broken! Sorry about that. This one works.
******************************************************************************/

proc mNextPunc()                       /** <Alt GreyCursorRight> **/
  START:
    Right()                            // begin at char to right
      Case CurrChar()
        when 0x2e,0x2c,0x21,0x3a,0x3b,0x3f   // . , ! : ; ?
          Goto DONE
        when _AT_EOL_,_BEYOND_EOL_     // no more punc on this line
          Alarm()                      // wake up,
          Goto QUIT                    // it's quittin' time
        otherwise
          Goto START                   // no punc here, try again
      EndCase
  DONE:
    Right()                            // now we want to skip whitespace
      Case CurrChar()
        when 0x9,0x20,0x00             // test for space, tab, or NUL
        Goto DONE                      // keep trying
      otherwise                        // stop at first non-whitespace,
        Goto QUIT                      // even if not a 'word' char
      endCase
  QUIT:
end  //  cursor to first non-white char after punctuation
<Alt GreyCursorRight> mNextPunc()

