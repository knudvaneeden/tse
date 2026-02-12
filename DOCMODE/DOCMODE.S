 /****************************************************************************
 *   DOCMODE.S  A Document mode for compatibility with word processors       *
 *   processors.  Proceedures:                                               *
 *       dWrapPara  Wrap delimited by newline markers.                       *
 *       dDocModeFileSetup  Mark line endings and wrap to current margins.   *
 *       dCReturn  add newline markers to normal behavior.                   *
 *       dCheckMarkers Check for Markers with following chars (an error)     *
 *       dGenericize Unwrap delimited by markers and blank lines on saving.  *
 *       dSetDocMode Hook DocMode to .ASC extension _ON_CHANGING_FILES_      *
 *       WhenLoaded Set hooks for DocModeFileSetup & SetDocMode              *
 *   NOTE: This does not convert TSE into a Word Processor.                  *
 *         It is up to the user not to add anything to the end of a line     *
 *         after the newline marker.                                         *
 *         Shift_F1 calls the Help Screen.                                   *
 ****************************************************************************/
 /****************************************************************************
 Notes: the Keydefs are at the end of the File. If you change them you should
 also change them in Menu dDocModeHelp. This is a combination menu - helpscreen.
 The last item calls a Quickhelp containing more detailed explanations of the
 various functions.

 PLEASE NOTE: Some of the keydefs are intended to override the existing
 keystrokes for the modified command. If you have these commands assigned to a
 different key it is important that you modify the assignments accordingly.

 The file DAUTOWRP.S is included in this file for compilation, read the
 introductions in it and AUTOWRAP.S for a complete explanation of the autowrap
 options.

 A Word Processor handles line endings differently than an Editor such as TSE.
 The Word Processor uses internal markings to distinguish between soft and hard
 line endings, and paragraph wrapping stops at the hard line endings, regardless
 of where they appear in the text. An ASCII editor such as TSE relies on either
 a blank line or a well defined indent style to define paragraphs, and has no
 way of telling the wrapping commands to stop until it meets these style
 conditions. The reason that the autowrap command occasionally causes havoc is
 that it is invoked automatically (instead of intentionally by use of a special
 command keystroke) and it does not have a way to know if you've carefully
 formatted a section below the current position unless there's a completely
 blank line to stop it.

 Word Processors also include information meant for the formatting of printing
 in the file, and they generally save all their proprietary internal markings as
 part of the file, which is why they can seldom share files with other
 applications. In recognition of this difficulty, most Word Processors have an
 option to save a file in a generic format, in which each paragraph is saved as
 a single long line, and the print formatting codes, which have no universal
 format, are removed.

 The DocMode macro is meant to provide compatibility with the generic format and
 wrapping behavior, by using a CR marker to define hard endings, stop the wrap
 macros at the CR marker, and provide a way to easily convert the file to and
 from the generic save format. The conversion takes time, so you may not want to
 utilize it when you expect to be the next person working with the file, but it
 will definitely make your life easier when trying to share files with a Word
 Processor user.

 Read the Quickhelp text for a description of the different functions in this
 macro. Note that this setup works for sharing files that are in progress, but
 once they are formatted for printing, they become tied to the program used for
 the formatting, and minor editing should then be done with that program only.

 You may or may not want DocMode invoked automatically when files with a certain
 extension are edited. I have used ".asc" here, and made it a global
 variable so that you can easily change it to whatever you like. It is invoked
 by the proc dSetDocMode(), which is called by a hook in the WhenLoaded(). If
 you don't want it invoked automatically, comment out this hook. This will cause
 a compiler complaint about the proc being declared but never used, but it will
 not cause a problem.

 I have also included a toggle so that you can set DocMode ON or OFF at your
 convenience, without respect to the current file extension, and the proc
 dEditFile() designed to insure you don't accidentally reformat a file you
 didn't want reformatted on loading.

 ****************************************************************************/

integer doc_mode
string marker[2] = "þ"
string dmode_ext[4] = ".asc"    // Use whatever file extension makes sense to
                            // you and doesn't interfere with something else.

// Comment out these 2 lines if you are not including DAUTOWRP.S,
// as well as the four lines indicated in the Whenloaded()
integer wr
#include["dautowrp.s"]  // Check the intro in this file for more information.


proc dWrapPara()

    if doc_mode
        PushPosition()
        if CurrPos() > CurrLineLen() and Down()
            if not Currlinelen()
                KillPosition()
                PushPosition()
            endif
        endif
        while not CurrLineLen()
            if not Down()
                return()
            endif
        endwhile
        while CurrLineLen() and not lFind(marker,"gc")
            if not Down()
                break
            endif
        endwhile
        AddLine()
        PopPosition()
        WrapPara()
        DelLine()
    else
       ChainCmd()
    endif
end


proc dDocModeFileSetup()  // Call from Keystroke or hooked proc
    integer ind = Set(Autoindent,ON)

    PushPosition()
    Message("Formatting...")
    BegFile()

    repeat
        if PosLastNonWhite()
            EndLine()
            InsertText(marker,_INSERT_)
            while CurrPos() > Query(RightMargin)
                if not WrapLine()
                    break
                endif
            endwhile
        endif
    until not Down()

    GotoXoffset(0)
    PopPosition()
    Set(Autoindent,ind)
    UpdateDisplay()
end

proc dEditFile() // Assign this proc to the keystroke that invokes EditFile()
    string y_n[1] = "N"

    if Editfile()
        if (CurrExt() == dmode_ext) or doc_mode
            Ask("Reformat for DocMode?  ",  y_n )
            if Lower(y_n) <> "y"
                return()
                if CurrExt() <> dmode_ext
                    doc_mode = 0
                endif
            else
                dDocModeFileSetup()
                if not doc_mode
                    doc_mode = 1
                endif
            endif
        endif
    endif
end


proc dCReturn()
    if doc_mode
        InsertText(marker,_INSERT_)
    endif
    ChainCmd()
end

proc AddCRmarker()
    InsertText("þ",_INSERT_)
    Left(2)
end

integer proc dCheckMarkers()   // Call from Keystroke
    if not lFind(marker + ".+",  'gxv')
        Message("CR Marker error not found.")
        return(0)
    else
        ScrollToTop()
    endif
    return(1)
end


integer proc dParaGenericize()   // Call from Keystroke
    integer wrp = Set(WordWrap, OFF)

    while PosFirstNonWhite() == 0   // pass over blank lines
        if not Down()
            Set(WordWrap, wrp)
            return(0)
        endif
    endwhile

    while CurrLineLen() and not lFind(marker,"gc")
        EndLine()
        if not Right()                       // Leave a space
            Message("MaxLineLength reached!!")
            break
        endif
        if not JoinLine()
            break
        endif

        while isWhite()       // remove any leading indentation.
            DelChar()
        endwhile

        if CurrPos() > CurrLineLen()   // Test for having deleted a blank line
            AddLine()                // If so, replace it
            Up()
            break
        endif

        if lFind(marker, "gc")
            break
        endif
    endwhile

    if lFind(marker, "gbc")      // remove CR marker from line
        DelChar(2)
    endif

    if not Down()               // set up for next round
        Set(WordWrap, wrp)
        return(0)               // and return code for full file Genericize
    endif
    Set(WordWrap, wrp)
    return(1)
end

proc dFileGenericize()  // Call from Keystroke/Hooked Proc
    integer rt = Set(RemoveTrailingWhite,ON)

    Message("Reformatting...")
    BegFile()
    while
        dParaGenericize()
    endwhile
    Set(RemoveTrailingWhite,rt)
    BegFile()
    UpdateDisplay()
end

proc dChoice()  // Hook to _ON_FILE_SAVE_, FileSave Keystrokes

    case YesNo("Save in Generic ForMat")
        when 0,3
            return()
        when 2
            SaveFile()
        when 1
            dFileGenericize()
            SaveFile()
    endcase
end

proc dHookChoice()
    if doc_mode
        dChoice()
    elseif CurrExt() == dmode_ext
        dChoice()
    endif
end

proc dStatusLineMarker()  // Hook to _AFTER_UPDATE_STATUSLINE_
    if doc_mode
        VGoToXYAbs(18,1)
        PutChar("D")
        VGoToXYAbs(18,1)
        PutAttr(Query(StatusLineAttr),1)
    endif
end

proc dSetDocMode()  //Hook to _ON_CHANGING_FILES_

    if CurrExt() == dmode_ext
        doc_mode = 1
    else
        doc_mode = 0
    endif
end

proc dToggleDocMode()
    if doc_mode
        doc_mode = 0
    else
        doc_mode = 1
    endif
    UpDateDisplay(_STATUSLINE_REFRESH_)
end

proc WhenLoaded()
    // Comment out if you don't want automatic mode change.
    Hook(_ON_CHANGING_FILES_,dSetDocMode)
    Hook(_ON_FILE_SAVE_,dHookChoice)
    Hook(_AFTER_UPDATE_STATUSLINE_,dStatusLineMarker)
    // Comment out these 4 lines if you are not including DAUTOWRP.S
    Hook(_AFTER_UPDATE_STATUSLINE_,ShowAutoWrap)
    Hook(_ON_SELFINSERT_,       OnSelfInsert)
    Hook(_ON_DELCHAR_,          OnDelChar)
    wr = Query(WordWrap)
end

helpdef HelpText
    title = "Doc Mode"
    x=10
    y=10

"DocMode is intended for working with files that must be shared"
"with someone using a Word Processor, allowing each person to use"
"the program of his preference without causing undue difficulty."
"For this to work the person using the Word Processor must use"
"his/her Generic save option."
""
"File Save Setup (DocMode to Generic) Changes each paragraph to a"
"single line. The Word Processor, on loading a generic file, will"
"wrap it to the current margin settings, without regard to how it"
"was wrapped when it was written (which is what causes half of the"
"problems in the first place)."
""
"File Setup (Generic to DocMode) does the same thing that the"
"Word Processor does - wraps all lines to the current margin"
"settings, and marks the end of paragraphs with a special CR"
'marker ("þ", chosen because it is unlikely to be found in any'
"other use)."
""
"The DocMode WordWrap will stop at the CR marker, as it would in"
"a Word Processor. The DocMode <CR> will act as it normally"
"would, but it also adds the visible CR marker. Additionally, for"
"editing purposes, a keystroke is provided for inserting the CR"
"marker without performing the associated actions."
""
"The Single Paragraph Genericize is provided in case for any"
"reason you may want to unwrap only one paragraph at a time."
"Occassionally you may want to leave a SMALL Table or some such"
"item formatted (repeat SMALL, as in not very wide, or else you"
"_WILL_ run into trouble with the Word Processor). The auto"
"processing would destroy this formatting."
"          ONLY DO THIS IF YOU ARE SURE!!"
""
"NOTE: THE DOCMODE DOES NOT CONVERT TSE INTO A WORD PROCESSOR. It"
"is up to the user not to add anything to the end of a line after"
"the CR marker. A Specialized Compressview is provided for the"
"purpose of locating marker errors, so that they can be corrected"
"if necessary before saving the file."
""
"Regardless of whether you Hooked your DocMode to a File"
"Extension, Toggle DocMode is provided as a convenience. The"
"DocMode setting directly affects the behavior of the <ENTER> key"
"and the behavior of the Paragraph Wrap."
""
'An indicator "D" is provided on the StatusLine, at Column 18'
"before the InsertMode indicator, when DocMode is ON, so that you"
"may be shure of what the current setting is."

end

menu dDocModeHelp()
    title = "Doc Mode KeyStrokes"
    x = 5
    history = 0
    y = 2
    NoKeys

"File Setup (Generic to DocMode)     :  ^K_A(scii)"   , dDocModeFileSetup()
"File Save Setup (DocMode to Generic):  ^K_F(ile)"    , dFileGenericize()
"Single Paragraph Genericize         :  ^K_G(eneric)" , dParaGenericize()
"",,Divide
"                Insert CR marker    :  ^K_I(nsert)"  , AddCRmarker()
"                Locate Marker Errors:  ^K_C(heck)"   , dCheckMarkers()
"                Toggle DocMode      :  ^K_D(ocMode)" , dToggleDocMode()
"                                 &Show Detailed Help", QuickHelp(HelpText),DontClose
end


<Shift F1>   dDocModeHelp()
<Alt b>      dWrapPara() // needs to overlap the regular wrappara key assignment
<Ctrl k><a>  dDocModeFileSetup()
<Enter>      dCReturn()
<Ctrl k><i>  AddCRmarker()
<Ctrl k><g>  dParaGenericize()
<Ctrl k><f>  dFileGenericize()
<Ctrl k><c>  dCheckMarkers()
<Ctrl k><d>  dToggleDocMode()
<Alt E>      dEditFile() // needs to overlap the regular EditFile key assignment
