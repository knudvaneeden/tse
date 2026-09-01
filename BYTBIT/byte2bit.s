/******************************************************************************/
/* Macro      : BYTE2BIT.S                                                    */
/* Programmer : Todd Fiske [70451,1424]                                       */
/*                                                                            */
/* Purpose    : Routines to convert between bytes and binary strings          */
/*                                                                            */
/* Revision   : 09/10/1993 - first version                                    */
/* History      09/14/1993 - added globals sOneChar and sZeroChar             */
/*                           added routines to edit them, Main() help line    */
/*                           cleaned up and commented for distribution        */
/*                                                                            */
/* Language   : SAL 1.0 (Pre-Release)                                         */
/*                                                                            */
/******************************************************************************/

string
   sOneChar[1]  = 'x', //                        default values for "1" and "0"
   sZeroChar[1] = '.'

integer
   iInvalidChar = 256 //                         Bits2Byte error return value

/******************************************************************************/
/* Byte2Bits - return the passed in byte as a string of eight "bits"          */
/******************************************************************************/
string proc Byte2Bits(integer i)
   string s[8] = '' //                           return string
   integer mask = 128 //                         x.......

   while mask //                                 while mask <> 0
      if (mask & i) == mask //                   if the current bit is on
         s = s + sOneChar //                        add a "1" to the string
      else
         s = s + sZeroChar //                       else, add a "0"
      endif
      mask = mask shr 1 //                       .x......, ..x....., etc
   endwhile //     eventually, the 1 is shifted out, making Mask = 0

   return(s)
end

/******************************************************************************/
/* Bits2Byte - return the passed in bit-string as a byte                      */
/******************************************************************************/
integer proc Bits2Byte(string s)
   integer
      i = 0, //                                  return byte (integer)
      mask = 128, //                             x.......
      bit  = 1 //                                string position

   while mask //                                 while mask <> 0
      if s[bit] == sOneChar //                   if current bit is a "one"
         i = i + mask //                         add the mask value to the byte
      elseif s[bit] <> sZeroChar
         i = iInvalidChar //                     something other than "1" or "0"
         return(i)
      endif
      mask = mask shr 1 //                       next mask - .x......, ..x....., etc
      bit = bit + 1 //                           next bit
   endwhile

   return(i)
end

/******************************************************************************/
/* Show Bit - show current character converted to bit-string in Message line  */
/******************************************************************************/
proc ShowBit()
   Message( Byte2Bits( CurrChar() ) )
end

/******************************************************************************/
/* Show Byte - show current bit-string converted to a byte in Message line    */
/******************************************************************************/
proc ShowByte()
   integer c = Bits2Byte( GetText(CurrPos(), 8) )
   Message(iif (c == iInvalidChar, "Invalid character found", chr(c) ) )
end

/******************************************************************************/
/* Char 2 Bits - replace current character with corresponding bit-sting       */
/******************************************************************************/
proc Char2Bits()
   integer c = CurrChar() //                     get current character
   string  s[8] //                               define result string

   if ((c == _AT_EOL_) or (c == _BEYOND_EOL_)) // if not within the text
      return() //                                exit without doing anything
   else
      s = Byte2Bits(c) //                        convert current character
      DelChar() //                               delete it
      InsertText(s, _INSERT_) //                 insert bit-string
   endif
end

/******************************************************************************/
/* Bits 2 Char - replace current bit-string with corresponding character      */
/******************************************************************************/
proc Bits2Char()
   string s[8] = GetText(CurrPos(), 8) //        get current bit-string
   integer c, i //                               define result byte, deletion counter

   if length(s) <> 8 //                          if we couldn't get 8 characters
      Message("Couldn't get 8 characters")
   else
      c = Bits2Byte(s) //                        convert bit-string to byte
      if c<>iInvalidChar
         i = 8
         while i //                              delete next 8 characters
            DelChar()
            i = i - 1
         endwhile
         InsertText(chr(c), _INSERT_) //         insert character
      else
         Message('Something other than "'+sOneChar+'" (1) or "'+sZeroChar+'" (0) found')
      endif
   endif
end

/******************************************************************************/
/* Set One Char - get new value for "1", can't be same as "0" char            */
/******************************************************************************/
proc SetOneChar()
   string sEditOne[1] = sOneChar
   if Ask('Enter new "1" character', sEditOne)
      if sEditOne <> sZeroChar
         sOneChar = sEditOne
      else
         Message("Can't " + 'set "1" and "0" to the same character - "1"='+sOneChar+' "0"='+sZeroChar)
      endif
   endif
end

/******************************************************************************/
/* Set Zero Char - get new value for "0", can't be same as "1" char           */
/******************************************************************************/
proc SetZeroChar()
   string sEditZero[1] = sZeroChar
   if Ask('Enter new "0" character', sEditZero)
      if sEditZero <> sOneChar
         sZeroChar = sEditZero
      else
         Message("Can't " + 'set "1" and "0" to the same character - "1"='+sOneChar+' "0"='+sZeroChar)
      endif
   endif
end

/******************************************************************************/
/* Main - just show current "1" and "0" chars, basic keystrokes               */
/******************************************************************************/
proc main()
   Warn('Byte2Bit "1"='+ sOneChar +' "0"='+ sZeroChar +' ShF9=SetOne ShF10=SetZero AltF8=Char2Bits AltF9=Bits2Char')
   Char2Bits()
end

/******************************************************************************/
/* Example key assignments - these keys are "transient" in my configuration   */
/******************************************************************************/

<Shift F6>    ShowByte()
<Alt F7>      ShowBit()

<Alt F8>      Char2Bits()
<Alt F9>      Bits2Char()

<Shift F9>    SetOneChar()
<Shift F10>   SetZeroChar()

/******************************************************************************/
/* EOF                                                                        */
/******************************************************************************/

