/***************************************************************
The AutoWrap is a nice addition to TSE's functionality for
working on documentation, and is but one sign of how flexible TSE
is, since it is a function normally found in Word Processors but
not in Text Editors. I have included an AutoWrap version in this
package which is appropriate for normal use with TSE, correcting
some problems with the version included in the stock .UI, but
AutoWrap really is at its best when it also includes the Word
Processor style feature of stopping at any hard line ending.

I have not duplicated much of my explanatory text. Read all of
the text sections in all of the files in this package for a
complete understanding of the different parts of the package.

This file assumes that you will want to keep autowrap as a
feature of your .UI file, whether you replace the stock version
with mine or not, and keep the docmode as an external macro to be
loaded only when you want to use it. Because you can't call a
proc that is part of the .UI from an external macro, most of the
code is duplicated here, but I have included modifications meant
to defeat the stock autowrap when the macro is loaded. If you do
it this way DO NOT use the menu to select autowrap, use the
toggle.

There are other options that you may use if you prefer:

1. You can keep the autowrap function entirely in the .UI file
   and let it look for the CR marker whether you are using
   docmode or not:
     Copy the proc MaybeAutoWrap() from the this file into your
   .UI, remove the line "if doc_mode" and the corresponding lines
        else
           WrapPara()
        endif
   and change
   lFind(marker,"gc") to lFind("þ","gc").
     Then comment out the line
   #include["dautowrp.s"] in docmode.s.
     This is unlikely to cause any trouble, since the CR marker
   was chosen for the probability of not appearing anywhere for
   any other reason.

2. You may choose to include the docmode into your .UI file
   altogehter. Then you would want to use the autowrap files as
   found in AUTOWRAP.S except for the Maybeautowrap(), which
   should be taken from this file.

3. Or you may wish to leave the AutoWrap out of the .UI
   altogether on the assumption that you will only want to use it
   when using docmode anyway, in which case you would compile
   DOCMODE.S including this file as is, just as you would under
   my origional assumption.

***************************************************************/
integer auto_wrap = 0

proc mToggleWordWrap()

    if wr == 0
        wr = 1
        Set(WordWrap, 1)
        auto_wrap = 0
    elseif wr == 1
        wr = 2
        Set(WordWrap, 0)
        auto_wrap = 1
    else
        wr = 0
        Set(WordWrap, 0)
        auto_wrap = 0
    endif
end

// Change the color of the StatusLine "W"
// This proc needs to be hooked to _AFTER_UPDATE_STATUSLINE_
//      in the DocMode's WhenLoaded()
proc ShowAutoWrap()
    if auto_wrap
        VGotoXYAbs(21,1)
        PutChar("W")
        VGotoXYAbs(21,1)
        PutAttr(Color(Bright Yellow on Magenta),1)
    endif
end


proc MaybeAutoWrap()
    integer line

    line = CurrLine()
    PushPosition()
    EndLine()
    if Abs(CurrCol() - Query(RightMargin)) > 1
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
           WrapPara()
        endif
    endif
    PopPosition()
    GotoXoffset(0)
    if line <> CurrLine() and CurrRow() < ((Query(WindowRows) * 2) / 3)
        ScrollUp()
    endif
end

// called on delchar/bs/drw/dlw via a hook in the WhenLoaded
proc OnDelChar()

    if auto_wrap and CurrPos() <= CurrLineLen()
        MaybeAutoWrap()
    endif
end

// Called on each char insert. via a hook in the WhenLoaded
proc OnSelfInsert()

    if wr == 1 and CurrCol() > Query(RightMargin) + 1
        WrapLine()
    elseif  wr > 1
        if (CurrPos() <= CurrLineLen()) or (CurrCol() > Query(RightMargin))
            MaybeAutoWrap()
        endif
    endif
end

// <KeyOfYourChoice>   mToggleWordWrap()
// This is the key I happen to use,
// and is the key bound in the accompanying .MAC file:
<Shift F2>   mToggleWordWrap()
