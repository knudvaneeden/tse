// AUTOWRAP.S -------------------------------------------------------------


/***************************************************************
INTRODUCTION
The new AutoWrap option is a welcome and useful addition to the
myriad capabilities of TSE, especially for those of us who spend
a lot of time composing or editing text. It has, however, caused
its share of grief due to accidental rewrapping of carefully
formatted text. I've done the same thing to myself with the
regular WrapPara command, of course, when I forgot that I didn't
really have a blank line at what appeared to be the end of a
paragraph, but it's a bit more frustrating when the AutoWrap
causes this effect precisely because it is "Auto-". And the more
so when the separation of paragraphs was properly defined with a
clean blank line, which under certain circumstances the AutoWrap
as provided in the default .UI will traverse.

As a result of several commentaries on the BBS about it I set
myself to finding and controlling the cause of this undesireable
effect (the nature of the native WrapPara command which is the
core of MaybeAutoWrap).

The basic problem is to define when MaybeAutoWrap() is invoked in
such a way that it will NOT affect a following paragraph.
Additionally, as a result of thinking about one of the messages
posted earlier, I have defined OnSelfInsert() in such a way as to
allow entering a new line just above a paragraph without causing
an automatic reformat until the Right Margin is reached. This
will ONLY be the case if the entire line is behind the cursor
position and the cursor position is less than the right margin,
thus allowing the insertion of a title or comment above an
existing paragraph without getting into trouble until you either
get to the end of the line or start to edit the middle of it.

I have also added a proc to change the Color of the Statusline
"W" so as to make the user aware of which state he is currently
in (obviously, change the color to whatever you like).

 At this point it is important to remember that TSE is an
 Editor, not a Word Processor. We are getting close to getting
 the functionalities of both into one extra powerful package,
 which is a bit like having your cake and eating it, too, but if
 you are not aware of the differences in the way they function,
 it will be harder to understand the reasons for the differences
 in the way they behave.

 A Word Processor handles line endings differently than an Editor
 such as TSE. The Word Processor uses internal markings to
 distinguish between soft and hard line endings, and paragraph
 wrapping stops at the hard line endings, regardless of where
 they appear in the text. An ASCII editor such as TSE relies on
 either a blank line or a well defined indent style to define
 paragraphs, and has no way of telling the wrapping commands to
 stop until it meets these style conditions.

Of course, knowing that you can easily switch back and forth
among WordWrap modes as the situation requires (which you can't
do with a Word Processor), this autowrap is a pretty good deal,
if you do a lot of document work (like me), and especially if you
switch back and forth between document work and coding, what we
have going here in TSE is really about the best deal possible.

In genreal I would recommend that WordWrap ON is a better
default setting than AUTO, just because it will cause inadvertant
deformation of unprotected (with a blank line) material less
often. Forcing yourself to deliberately think about when you're
using autowrap and when you're not is the best protection
against this kind of mishap.


Following are the five procs making up the autowrap package:
***************************************************************/

// This one needs to be assigned to a keystroke
proc mToggleWordWrap()
    integer wr = Query(WordWrap)

    if wr == 0
        Set(WordWrap, 1)
    elseif wr == 1
        Set(WordWrap, 2)
    else
        Set(WordWrap, 0)
    endif
end


// Change the color of the StatusLine "W"
// This proc needs to be hooked to _AFTER_UPDATE_STATUSLINE_.
// Add to the hooks section of your Whenloaded() the line:
//    Hook(_AFTER_UPDATE_STATUSLINE_, ShowAutoWrap)

proc ShowAutoWrap()
    if Query(WordWrap) > 1
        VGotoXYAbs(21,1)
        PutAttr(Color(Bright White on Green),1)
    endif
end

/*******************************************************
NOTE: I found it rather disconcerting at first that the
autowrap caused the cursor line to stay at the same screen
row, scrolling the text upward automatically. Once I
discovered what was happening and realized that it was
intentional, I decided I would probably like it better if
the cutoff was farther down the screen. With this version,
the cursor line will shift rows normally till you get two-
thirds of the way down the window, after which it will
remain on the same screen row, allowing you to see several
lines of the text following your current position.

This is not a necessary feature. If you think you don't
want it, remove the remainder of the line that begins:
        if line <> CurrLine()
and this feature should disappear altogether. If you think
you would like it better if the change in behavior were at a
different line, change the math.
********************************************/

/*
integer proc NumNonWhite()
	string s[200]
	integer i, n = 0

	s = GetText(1, 200)
	for i = 1 to Length(s)
		if s[i] <> ' ' and s[i] <> Chr(9)
			n = n+1
		endif
	endfor

	return(n)
end
*/

proc MaybeAutoWrap()
    integer line

    line = CurrLine()
    PushPosition()
    EndLine()
    if Abs(CurrCol() - Query(RightMargin)) > 1
        //ExecMacro("newwrap")
        ExecMacro("bullet WrapPara")
    endif
    PopPosition()
    GotoXoffset(0)
    if line <> CurrLine() and CurrRow() < ((Query(WindowRows) * 2) / 3)
        ScrollUp()
    endif
end

// called on delchar/bs/drw/dlw via a hook in the WhenLoaded
proc OnDelChar()

    // bail if system or hidden buffer, or if short line
    if BufferType() <> _NORMAL_ //or NumNonWhite() <= 30
    	return()
    endif

    if (Query(WordWrap) > ON) and CurrPos() <= CurrLineLen()
        MaybeAutoWrap()
    endif
end

// Called on each char insert. via a hook in the WhenLoaded
proc OnSelfInsert()
    integer qw = Query(WordWrap)

    // bail if no wordwrap, if system or hidden buffer, or if short line
    if qw == 0 or BufferType() <> _NORMAL_ //or NumNonWhite() <= 30
    	return()
    endif

    if qw == 1 and CurrCol() > Query(RightMargin) + 1
        //WrapLine()
        ExecMacro("bullet -l")
    elseif  qw > 1
        if (CurrPos() <= CurrLineLen()) or (CurrCol() > Query(RightMargin))
            MaybeAutoWrap()
	        if CurrCol() == 1
	        	if PosFirstNonWhite()
	        		GotoPos(PosFirstNonWhite())
	        	else
	        		GotoColumn(Query(LeftMargin))
	        	endif
	        endif
        endif
    endif
end

proc WhenLoaded()
	if not LoadMacro("WrapPara")
		PurgeMacro(CurrMacroFilename())
		return()
	endif
	Hook(_ON_DELCHAR_, OnDelChar)
	Hook(_ON_SELFINSERT_, OnSelfInsert)
	Hook(_AFTER_UPDATE_STATUSLINE_, ShowAutoWrap)
end

proc WhenPurged()
	UnHook(OnDelChar)
	UnHook(OnSelfInsert)
	UnHook(ShowAutoWrap)
end

<CtrlShift W>   mToggleWordWrap()    // reassign this to <KeyOfYourChoice>
