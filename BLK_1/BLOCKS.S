/****************************************************************************
 *   FILENAME:  C:\TSE\WRK\BLOCKS.S                                         *
 *   AUTHOR  :  "Buddy" E. Ray Asbury, Jr.                                  *
 *   DATE    :  Fri 07-30-1993 11:02:48                                     *
 *   PURPOSE :  Provides a user prompt for the Copy(), Cut(), Paste(),      *
 *              CopyBlock(), & MoveBlock() commands, to determine whether   *
 *              the default action of these is commands is desired, or if   *
 *              the user wishes for the other action.  For example, the     *
 *              default action of Copy() is to overwrite any existing text  *
 *              in the clipboard.  Rather than binding Copy() to two keys   *
 *              (one of which allows appending), these macros only use one  *
 *              binding for each of the five commands and prompts the user  *
 *              when necessary.  The prompts occur as follows:              *
 *                                                                          *
 *                  Copy()                                                  *
 *                  Cut()       - to ask whether to overwrite or to append  *
 *                                any text that may already be in the       *
 *                                clipboard                                 *
 *                  Paste()                                                 *
 *                  CopyBlock()                                             *
 *                  MoveBlock() - to ask, only when the block is a column   *
 *                                block, whether to overwrite the existing  *
 *                                text or to insert the block               *
 *                                                                          *
 *              This set of macros was developed to solve two problems:     *
 *                                                                          *
 *                  þ  I wanted all five commands to be fully functional in *
 *                     my TSE configuration, but that required 10 key       *
 *                     bindings                                             *
 *                  þ  I could not remember the key bindings, which         *
 *                     commands differed depending on whether the block was *
 *                     a column or not, nor what those differences were.    *
 *                                                                          *
 *              I hope these can be of help to you.  Please feel free to    *
 *              modify these at will.  I am releasing them into the public  *
 *              domain.                                                     *
 *                                                                          *
 *              Many thanks to David Marcus for suggesting a way to         *
 *              determine the block type of the text contained with the     *
 *              clipboard.  Without his suggestion, this set of macros      *
 *              was incomplete.                                             *
 *                                                                          *
 ****************************************************************************/

// FORWARD DECLARATIONS ARE REQUIRED SINCE THESE THREE MACROS/MENUS ARE
// CALLED BEFORE THEY HAVE BEEN DEFINED

FORWARD         MENU menuOverWriteAppend()
FORWARD         MENU menuOverWriteInsert()

FORWARD INTEGER PROC mOWAIPrompt(INTEGER whichType)

// THE FOLLOWING CONSTANTS ARE USED TO INDICATE WHICH VERSION OF THE
// PROMPT TO USE, DEPENDING ON WHETHER TEXT CAN BE APPENDED OR INSERTED

CONSTANT    kAPPEND = 1,
            kINSERT = 2

// REPLACEMENT FOR Copy(), WHICH PROMPTS TO OVERWRITE OR APPEND TO THE
// CLIPBOARD

PROC mCopy()
    IIF(mOWAIPrompt(kAPPEND), Copy(), Copy(_APPEND_))
END mCopy

// REPLACEMENT FOR CopyBlock(), WHICH PROMPTS TO OVERWRITE OR INSERT COLUMN
// BLOCKS, INSERTS OTHER TYPE BLOCKS, AND DUPLICATES THE PREVIOUS CHARACTER
// IF A BLOCK IS NOT MARKED

PROC mCopyBlock()
    CASE (isBlockMarked())
        WHEN _COLUMN_
            IIF(mOWAIPrompt(kINSERT),
                CopyBlock(_OVERWRITE_),
                CopyBlock())
        WHEN _INCLUSIVE_, _NONINCLUSIVE_, _LINE_
            CopyBlock()
        OTHERWISE
            IF Left()
                MarkChar()
                Right()
                CopyBlock()
                Right()
                UnMarkBlock()
            ENDIF
    ENDCASE
END mCopyBlock

// REPLACEMENT FOR Cut() WHICH PROMPTS WHETHER TO OVERWRITE OR APPEND TO
// THE CLIPBOARD

PROC mCut()
    IIF(mOWAIPrompt(kAPPEND), Cut(), Cut(_APPEND_))
END mCut

// REPLACEMENT FOR MoveBlock() WHICH PROMPTS FOR COLUMN BLOCKS AS TO
// WHETHER THE BLOCK SHOULD OVERWRITE EXISTING TEXT OR SHOULD BE INSERTED

PROC mMoveBlock()
    CASE (isBlockMarked())
        WHEN _COLUMN_
            IIF(mOWAIPrompt(kINSERT),
                MoveBlock(_OVERWRITE_),
                MoveBlock())
        WHEN _INCLUSIVE_, _NONINCLUSIVE_, _LINE_
            MoveBlock()
    ENDCASE
END mMoveBlock

// MACRO TO CALLED THE APPROPRIATE MENU AND RETURN THE USER'S CHOICE
// TO THE CALLING MACRO

INTEGER PROC mOWAIPrompt(INTEGER whichType)
    IF (whichType == kAPPEND)
        menuOverWriteAppend()
    ELSE
        menuOverWriteInsert()
    ENDIF
    CASE (MenuOption())
        WHEN 1
            Return(TRUE)
        WHEN 2
            Return(FALSE)
    ENDCASE
    Halt            // THIS IS REACHED WHENEVER THE USER PRESSES <Escape>
    Return(FALSE)   // NEVER EXECUTED, BUT PREVENTS A COMPILE TIME WARNING
END mOWAIPrompt

// REPLACEMENT FOR Paste() WHICH DETERMINES IF THE CLIPBOARD CONTAINS A
// A COLUMN BLOCK OR NOT.  IF SO, THEN USER IS PROMPTED WHETHER TO OVERWRITE
// ANY EXISTING TEXT OR TO INSERT THE BLOCK.  IF THE CLIPBOARD CONTAINS A
// NON-COLUMN BLOCK, THEN IT IS AUTOMATICALLY INSERTED.  NOTE:  ALTHOUGH
// mPaste() RETAINS THE USER'S SETTING FOR UnMarkAfterPaste, IT WILL REMOVE
// A MARKED BLOCK, IF ONE EXISTS WHEN mPaste() IS CALLED.

PROC mPaste()

    INTEGER cid = GetBufferID(),
            clpBrdBlkType,
            cUMAPSetting = Set(UnMarkAfterPaste, FALSE),
            tid

    IF (IsBlockMarked() <> FALSE)
        UnMarkBlock()
    ENDIF
    tid = CreateTempBuffer()
    Paste()
    clpBrdBlkType = IsBlockMarked()
    Set(UnMarkAfterPaste, cUMAPSetting)
    GotoBufferID(cid)
    AbandonFile(tid)
    IF (clpBrdBlkType == _COLUMN_)
        IIF(mOWAIPrompt(kINSERT), Paste(_OVERWRITE_), Paste())
    ELSE
        Paste()
    ENDIF
END mPaste

// MENUS - ALTHOUGH THEY ARE FUNCTIONALLY IDENTICAL, THE SECTION OPTION
// USES A DIFFERENT WORD WHICH IS MORE APPROPRIATE FOR THE ACTION WHICH
// WHICH IS AVAILABLE

MENU menuOverWriteAppend()
    Title = "Choose Method"
    "&OverWrite"
    "&Append"
END menuOverWriteAppend

MENU menuOverWriteInsert()
    Title = "Choose Method"
    "&OverWrite"
    "&Insert"
END menuOverWriteInsert

// SAMPLE KEY BINDINGS

<Ctrl F1>                  mCopy()
<Ctrl F2>                  mCut()
<Ctrl F4>                  mPaste()
<Alt c>                    mCopyBlock()
<Alt m>                    mMoveBlock()