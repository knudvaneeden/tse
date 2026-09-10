
/*****************************************************************************
   Uses ShareSpell to check a single word as defined by current word set. The
     new (or same) word is insert blind inplace of the checked word.  If the
     source word is spelled correctly, ShareSpell simply exits.  Have not
     figured out how to test and put up message "Word spelled correctly".

   If the cursor is not on a word, will ask for a word and then ask if the new
     word should be inserted into the file.  If ShareSpell is aborted with F10
     or <cr>, will still ask to insert word, need a test.
 *****************************************************************************/

proc Main()
  string  ckWord[20] = "",                  // word to spell check
         newWord[50] = "",                  // spell checked word
          ckFile[12] = "J'K'",              // name of check word file
           macEV[30] = GetEnvStr("SEMAC")   // EV path to SE macros
  integer   spell_id,                       // file for word check
             curr_id = GetBufferID(),       // source buffer
              onWord = FALSE                // true if cursor on word

    GotoBufferId(curr_id)                   // point to source buffer
    PushBlock()                             // save any marked blocks

    MarkWord()                              // mark word to check
    onWord = iif(isBlockInCurrFile(),TRUE,FALSE) // is word marked ??

    spell_id = CreateBuffer(ckFile)         // get buffer to check word
    if spell_id == FALSE                    // if can't do it - bye bye
       Return()
    endif

    if onWord                               // HAVE WORD
          CopyBlock()                       // copy the word
    else                                    // DONT HAVE WORD
        Ask("Enter word to check ",ckWord)  // no word, ask for one
        if Length(ckWord) == 0              // ah!, a mistake - get out
            AbandonFile()
            return()
        endif
        InsertText(ckWord)                  // put word in check buffer
        WordLeft()                          // step back onto word
    endif

    // This is the same code a mExecMacro().  Can existing code in SE somehow
    //   be called from an external macro ???
    if Length(macEV)                        // is there an EV path
       ExecMacro(macEV+"\SS")
    elseif  FileExists(LoadDir()+"SS")      // if not in environment assume
       ExecMacro(LoadDir()+"SS")            //   SS in same directory as SE
    else
       ExecMacro("SS")                      // hope it's on the path
    endif

    ////// test for correctly spelled word
    MarkColumn()                            // begin block
    while CurrChar() >= 0                   //  (maybe more than one word)
      Right()
    endwhile
    Left()                                  // get back on last char
    MarkColumn()                            // end block
    newWord = GetMarkedText()               // get the word
    AbandonFile()                           // close the check buffer
    GotoBufferId(curr_id)                   // back to source buffer
    UpdateDisplay()

    if onWORD
        MarkWord()                          // get rid of word and
        DelBlock()                          //   insert new one
        InsertText(newWord,_INSERT_)
    else
        ////// need check to bypass
        if YesNo('Insert "'+newWord+'" at cursor') == 1
          InsertText(newWord,_INSERT_)
        endif
    endif

    EraseDiskFile(ckFile)               // get rid of ShareSpell files
    EraseDiskFile(ckFile+".bak")
    PopBlock()                          // put back any previous block
end

