/************************************************************************
  Author:  SemWare (Sammy Mitchell)

  Date:    November, 1992 - Initial version
           April, 1993  - Revision

  Description:

    Enhanced find package for TSE.  Includes the following commands:

    mfind - regular TSE style find command

    These commands prompt for the find string, and then use the
    previously set find options, and search in the specified direction:

    mfindforward - find forward - uses previous find options
    mfindbackward - find backward - uses previous find options
    mfindreverse - find, in the oposite direction of the last mfind

    These commands do not prompt for the find string, they just repeat
    the last find using previously set find options, and search in the
    specified direction:

    mrepeatfindforward - repeat the last mfind, in a forward direction
    mrepeatfindbackward - repeat the last mfind, in a backward direction
    mrepeatfindreverse - repeat the last mfind, in the reverse direction

    msetfindoptions - allows the user to change current find options.

  Usage notes:

    Be sure to add the following to your WhenLoaded if you use this package:

    _findopts = Query(FindOptions)

    Of course the definition of the variable _findopts must occur
    _before_ the WhenLoaded macro.

    To use, add these macros to your TSE.S file, and key assignments to
    your TSE.KEY file, and re-bind the editor using the -b switch of sc.

    Be sure to delete the main routine if used in TSE.S.

    Example key assignments might be:

    <f12>         mFindMenu()

    Alternatively, add the key assignments to this file, and load the
    macro (as an external macro) as needed via the LoadMacro command
    (<ctrl f10><L> or 'menu->macro->load')

 ************************************************************************/


constant FIND_STR_LEN = 65, FIND_OPT_LEN = 15

string _findstr[FIND_STR_LEN],
    _findopts[FIND_OPT_LEN]

integer proc isBackInOptions()
    return (pos('b', _findopts) or pos('B', _findopts))
end

string proc RemoveBackFromOpts()
    integer p = isBackInOptions()

    return (iif(p, (substr(_findopts, 1, p - 1) + substr(_findopts, p + 1, Length(_findopts) - p + 1)), _findopts))
end

// reset the default find options
proc mSetFindOptions()
    Ask("New find options [BGLIWX]", _findopts, _FIND_OPTIONS_HISTORY_)
end

// issue the find command; save the search string and the options
// Note: starts at the current position
integer proc mFind()
    return (Ask("Search for:", _findstr, _FIND_HISTORY_)
        and Length(_findstr)
        and Ask("Options [BGLIWX]", _findopts, _FIND_OPTIONS_HISTORY_)
        and find(_findstr, _findopts))
end

// find a string, using current options, in a forward direction
// Note: starts at the current position
integer proc mFindForward()
    return (Ask("Forward search for:", _findstr, _FIND_HISTORY_)
        and Length(_findstr)
        and Find(_findstr, RemoveBackFromOpts()))
end

// find a string, using current options, in a backwards direction
integer proc mFindBackward()
    return (Ask("Backward search for:", _findstr, _FIND_HISTORY_)
        and Length(_findstr)
        and Find(_findstr, _findopts + 'b'))
end

// find a string, using current options, oposite the current direction
integer proc mFindReverse()
    return (iif(isBackInOptions(), mFindForward(), mFindBackward()))
end

// repeat the last find command, in a forward direction
// Note: starts at the current position + 1
integer proc mRepeatFindForward()
    if Length(_findstr) == 0
        return (mFindForward())
    endif
    return (Find(_findstr, RemoveBackFromOpts() + '+'))
end

// repeat the last find command, in a backward direction
// Note: starts at the current position - 1
integer proc mRepeatFindBackward()
    if Length(_findstr) == 0
        return (mFindBackward())
    endif
    return (Find(_findstr, _findopts + 'b'))
end

integer proc mRepeatFindReverse()
    if Length(_findstr) == 0
        return (mFind())
    endif
    return (iif(isBackInOptions(), mRepeatFindForward(), mRepeatFindBackward()))
end

menu mFindMenu()
    "&Find",                 mFind()
    "FindForward",          mFindForward()
    "Find&Backward",         mFindBackward()
    "Find&Reverse",          mFindReverse()
    "",                    ,Divide
    "RepeatFindForward",    mRepeatFindForward()
    "RepeatFindBackward",   mRepeatFindBackward()
    "RepeatFindReverse",    mRepeatFindReverse()
    "",                    ,Divide
    "Set find options",     mSetFindOptions()
end

<f12> mFindMenu()

