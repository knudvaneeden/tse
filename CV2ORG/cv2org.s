// ***********************************************************
// CV2ORG.S MACRO                                            *
//                                                           *
// author:    Richard Lassan MSN: RLASSAN                    *
//                           CIS: 76103,1010                 *
//            7570 King Road                                 *
//            Fairview, TN                                   *
//            Work: 615 377-2937 x220                        *
//                                                           *
// date:      10/15/95 07:19 pm                              *
//                                                           *
// overview:  Save compressed view changes to original       *
//            source file.                                   *
//                                                           *
// how to:    Load the source file, execute compressed view. *
//            Select ALT+E to edit source file, make any     *
//            changes, then execute CV2ORG to save changes   *
//            back to the original source file.              *
//                                                           *
// NOTE:      For this to work properly the beginning line   *
//            number and colon must NOT be removed from      *
//            compressed view.                               *
// ***********************************************************

constant N     = 78
constant Q     = 81
constant R     = 82
constant Y     = 89
constant ESC   = 27
constant UCASE = 223

forward integer proc GetKeyPress()
forward proc ReplaceLine()

proc main()

   integer nPrompt = 1
   integer nKey = 0
   integer nMaxLines = 0
   string szLineBuf[10] = ""

   if FileChanged()
      if VWindow()
         PrevWindow()
         nMaxLines = Query(WindowRows)
         BegFile()
         while nMaxLines > 0                // start reading each line
            BegLine()
            nMaxLines = nMaxLines - 1
            if Find(":","c")
               szLineBuf = GetText(1,CurrPos()-1)

               NextChar()                   // mark line and skip past
               NextChar()                   // first white space
               MarkColumn()
               EndLine()
               MarkColumn()

               PrevWindow()                 // position in original window
               GotoLine(Val(szLineBuf))
               BegLine()

               if nPrompt                   // was rest selected?
                  nKey = GetKeyPress()      // what are we going to do?
               endif

               case (nKey)                  // determine the key
                  when Y
                     ReplaceLine()
                  when Q, ESC
                     Message("Replace cancelled!")
                     return()
                  when R
                     ReplaceLine()
                     nPrompt = 0            // set for rest (non prompt)
               endcase

               PrevWindow()
               UnMarkBlock()
            else
               Message("Cannot find line number.")
               return()
            endif
            Down()
         endwhile
      else
         Message("Cannot open source window.")
         return()
      endif
   else
      Message("File contents have not changed.")
      return()
   endif
   Message("Done!")

end

integer proc GetKeyPress()

   integer nKey = 0

   Message("Yes/No/Rest/Quit: ")
   loop
      nKey = GetKey()
      nKey = nKey & 0xff               // strip scan code
      nKey = nKey & UCASE              // force upper case char

      case nKey                        // check for valid keys
         when Y, N, R, Q, ESC
            break
      endcase
   endloop

   return(nKey)                        // return valid key

end

proc ReplaceLine()

   KillToEOL()
   CopyBlock()

end
