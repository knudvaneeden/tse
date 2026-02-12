
/*
                          QKEYS SAL SOURCE FILE

SOFTWARE:    QKEYS
VERSION:     0.97 Beta for TSE 1.52b Beta (or later)
DATE:        May 29, 1994
REV. DATE:   July 18th, 1994
AUTHOR:      Ian Campbell
TYPE:        External macro
NOTES:       For release to the beta group only, please.

*/

// ---------------------   User Configurable Options   ------------------

// the number of keys that must be pressed before speedup occurs (default=1)
integer KeystrokeCountBeforeSpeedup = 1

// the number of additional Left's() or Right's() (default = 2) that are
// inserted between actual <CursorLeft>, <CursorRight> keyboard keystrokes.
// Minimum value = 0, Maximum value = 7, Default value = 2.
integer AdditionalHorizontalKeys = 2

// the number of additional Up's() or Down's() (default = 1) that are
// inserted between actual <CursorUP>, <CursorDown> keyboard keystrokes.
// Minimum value = 0, Maximum value = 5, Default value = 1.
integer AdditionalVerticalKeys = 1

// 0-31 for keyboard typematic rates of 30cps down to 2cps.  This is the
// repeat rate for keystrokes from the actual keyboard (default = 20?).
integer NativeKBRepeatRate = 0

// 0=250ms, 1=500ms
// This is the actual keyboard delay before the keyboard itself will begin
// repeating a held key (power up default = 1).
integer NativeKeyboardDelay = 0

//--------------------  End of User Configurable Options --------------------

integer CursorKeyPressed = 0,
        StoredClockTicks = 0,
        HorizontalSmoothingDelay = 100,
        VerticalSmoothingDelay = 100,
        OldCursorType = 0,
        StreamingState = FALSE, // protects against keyboard-macro confusion
        TailOffset = 0,         // this tracks the actual bios keyboard tail
        VideoSegment            // the segment of the video buffer

// the binary procedures
//
binary ['qkeys.bin']
    integer proc mBinaryKeyPressed() : 0
    integer proc mBinaryGetKeyTail() : 3
    proc mBinarySpeedUpKeyboard(integer KeyboardTypematics) : 6
    integer proc mBinaryCheckVideoMode() : 9
    integer proc mBinaryPeekData(integer SegmentOffset) : 12
end

/*
   Procedure:   mSpeedUpKeyboard()

   Notes:       Speed up the keyboard via native bios call

   Called by:   WhenLoaded()

   Enter With:  nothing

   Returns:     nothing

*/
proc mSpeedUpKeyboard() integer KeyboardTypematics
    KeyboardTypematics = NativeKBRepeatRate
    KeyboardTypematics = KeyboardTypematics | (NativeKeyboardDelay shl 8)
    mBinarySpeedUpKeyboard(KeyboardTypematics)
end mSpeedUpKeyboard

/*
   Procedure:   mMax()

   Notes:       Return the highest of two integers

   Called by:   mKeySpeedup(), mValueSanityCheck()

   Enter With:  The two integers to evaluate

   Returns:     The value of the largest integer

*/
integer proc mMax(integer value1, integer value2)
    if value2 > value1
        return(value2)
    endif
    return(value1)
end mMax

/*
   Procedure:   mMin()

   Notes:       Return the lowest of the two integers

   Called by:   mValueSanityCheck()

   Enter With:  The two integers to evaluate

   Returns:     The value of the smallest integer

*/
integer proc mMin(integer value1, integer value2)
    if value2 < value1
        return(value2)
    endif
    return(value1)
end mMin

/*
   Procedure:   mDelay()

   Notes:       Accept a delay value, and begin counting out a delay loop.
                Continuously check for a keystroke, and if one is found,
                return the remainder of the timing value, otherwise, return
                zero.  Note the use of mBinaryKeyPressed() instead of
                the SAL equivalent KeyPressed() -- KeyPressed() is just
                too slow for a reliable timing loop, probably because it
                uses the PC's bios.

   Called by:   mKeySpeedup()

   Enter With:  The delay value to count down

   Returns:     The remainder of the delay if interrupted by a keystroke,
                otherwise zero when the delay completes.
*/
integer proc mDelay(integer DelayValue)
    repeat
        DelayValue = DelayValue - 1
        if mBinaryKeyPressed()
            break
        endif
    until DelayValue <= 0
    return(DelayValue)
end mDelay

/*
   Procedure:   mStopHook

   Notes:       This procedure stops a hook from chaining through the system.

   Called by:   mCareFullUpdateDisplay()

   Enter With:  nothing

   Returns:     nothing

*/
proc mStopHook()
    BreakHookChain()
end mStopHook

/*
   Procedure:   mCareFullUpdateDisplay()

   Notes:       For horizontal cursor types, this macro will issue
                an UpdateDisplay() with the "_AFTER_UPDATEDISPLAY_" hook
                disabled.  This will prevent another macro (such as COLORS)
                from needlessly responding to the hook, and wasting time.

   Called by:   mKeySpeedup()

   Enter With:  The type of cursor key

   Returns:     nothing

*/
proc mCareFullUpdateDisplay(integer CursorType)
    case CursorType
        when <CursorRight>, <CursorLeft>
            if CurrXoffset()
                UpdateDisplay()
            else
                // stop possible COLORS macro from activating
                Hook(_AFTER_UPDATEDISPLAY_, mStopHook)
                UpdateDisplay()
                UnHook(mStopHook)
            endif
        when <CursorUP>, <CursorDown>
            UpdateDisplay()
    endcase
end mCareFullUpdateDisplay


/*
   Procedure:   mKeySpeedup()

   Notes:       This is the main macro.  It adds the extra cursor key
                functions, and it sorts out the smoothing mechanism for
                performing these functions at the appropriate time.

   Called by:   Assigned to the cursor keys by a direct key assignment
                at the bottom of this macro.

   Enter With:  The cursor keystroke

   Returns:     nothing

*/
proc mKeySpeedup(integer CursorType)
    integer KeyCount = AdditionalHorizontalKeys         // number of extra keys to duplicate
    integer DelayCount, DelayReturn

    if CursorType <> OldCursorType
        CursorKeyPressed = 0
    endif
    OldCursorType = CursorType
    case CursorType
        when <CursorRight>, <CursorLeft>
            case CursorType
                when <CursorRight>
                    Right()
                when <CursorLeft>
                    Left()
            endcase
            if AdditionalHorizontalKeys == 0
                return()
            endif
            KeyCount = AdditionalHorizontalKeys
            DelayCount = HorizontalSmoothingDelay
        when <CursorUp>, <CursorDown>
            case CursorType
                when <CursorUp>
                    Up()
                when <CursorDown>
                    Down()
            endcase
            if AdditionalVerticalKeys == 0
                return()
            endif
            KeyCount = AdditionalVerticalKeys
            DelayCount = VerticalSmoothingDelay
    endcase

    if (GetClockTicks() > StoredClockTicks + 2)
        StreamingState = FALSE
        CursorKeyPressed = 0
    endif

    mCareFullUpdateDisplay(CursorType)

    if GetClockTicks() <= StoredClockTicks + 1 and StreamingState
        while KeyCount and GetClockTicks() <= StoredClockTicks + 1
            DelayReturn = mDelay(DelayCount)
            if DelayReturn
                // count not zero, keystroke pressed
                case CursorType
                    when <CursorRight>, <CursorLeft>
                        HorizontalSmoothingDelay = HorizontalSmoothingDelay
                            - (HorizontalSmoothingDelay / (AdditionalHorizontalKeys + 1))
                    when <CursorUp>, <CursorDown>
                        VerticalSmoothingDelay = VerticalSmoothingDelay
                            - (VerticalSmoothingDelay / (AdditionalVerticalKeys + 1))
                endcase
                Goto ExitKeySpeedup
            endif
            if (CursorKeyPressed >= KeystrokeCountBeforeSpeedup)
                case CursorType
                    when <CursorRight>
                        Right()
                    when <CursorLeft>
                        Left()
                    when <CursorUp>
                        Up()
                    when <CursorDown>
                        Down()
                endcase
            endif
            KeyCount = KeyCount - 1
        endwhile
        mCareFullUpdateDisplay(CursorType)
        DelayReturn = mDelay(DelayCount)
        if DelayReturn
            case CursorType
                when <CursorRight>, <CursorLeft>
                    HorizontalSmoothingDelay = HorizontalSmoothingDelay
                        - (DelayReturn / (AdditionalHorizontalKeys + 1))
                when <CursorUp>, <CursorDown>
                    VerticalSmoothingDelay = VerticalSmoothingDelay
                        - (DelayReturn / (AdditionalVerticalKeys + 1))
            endcase
        else        // no keystroke yet encountered
            DelayReturn = mDelay(DelayCount)
            case CursorType
                when <CursorRight>, <CursorLeft>
                    HorizontalSmoothingDelay = HorizontalSmoothingDelay
                        + ((DelayCount - DelayReturn) / (AdditionalHorizontalKeys + 1))
                when <CursorUp>, <CursorDown>
                    VerticalSmoothingDelay = VerticalSmoothingDelay
                        + ((DelayCount - DelayReturn) / (AdditionalVerticalKeys + 1))
            endcase
        endif
    endif
ExitKeySpeedup:
    HorizontalSmoothingDelay = mMax(HorizontalSmoothingDelay, 10)
    VerticalSmoothingDelay = mMax(VerticalSmoothingDelay, 10)
    StoredClockTicks = GetClockTicks()
    CursorKeyPressed = CursorKeyPressed + 1
end mKeySpeedup

/*
   Procedure:   mValueSanityCheck()

   Notes:       Makes sure that all of the integers in the User
                Configurable Options section are within acceptable range
                limits.

   Called by:   WhenLoaded()

   Enter With:  nothing

   Returns:     nothing

*/

proc mValueSanityCheck()
    KeystrokeCountBeforeSpeedup = mMax(KeystrokeCountBeforeSpeedup, 1)
    AdditionalVerticalKeys = mMax(AdditionalVerticalKeys, 0)
    AdditionalVerticalKeys = mMin(AdditionalVerticalKeys, 5)
    AdditionalHorizontalKeys = mMax(AdditionalHorizontalKeys, 0)
    AdditionalHorizontalKeys = mMin(AdditionalHorizontalKeys, 7)
    NativeKBRepeatRate = mMin(NativeKBRepeatRate, 0x1f)
    NativeKBRepeatRate = mMax(NativeKBRepeatRate, 0)
    NativeKeyboardDelay = mMin(NativeKeyboardDelay, 1)
    NativeKeyboardDelay = mMax(NativeKeyboardDelay, 0)
end mValueSanityCheck

/*
   Procedure:   mCheckForCursorKeys()

   Notes:       Check to see if the previous command was a cursor key
                command, and if not, then clear some flags.

   Called by:   Hooked to _AFTER_COMMAND_ via WhenLoaded()

   Enter With:  nothing

   Returns:     nothing

*/
proc mCheckForCursorKeys()
    integer CurrentTailOffset = mBinaryGetKeyTail()
    integer MacroRecordByte = mBinaryPeekData((VideoSegment shl 16) + ((22 - 1) * 2))
    integer MacroRecordState = FALSE

    if MacroRecordByte & 0x8000                     // bit 16 means blink is set
        if (MacroRecordByte & 0x00ff) == Asc('R')   // macro 'R' is flashing
            MacroRecordState = TRUE
        endif
    endif

    case Query(Key)
        when <CursorLeft>, <CursorRight>, <CursorUp>, <CursorDown>,
                <GreyCursorLeft>, <GreyCursorRight>, <GreyCursorUp>,
                <GreyCursorDown>
            if (CursorKeyPressed > 1)
                    and (CurrentTailOffset <> TailOffset)
                    and (not MacroRecordState)
                StreamingState = TRUE
            endif
        otherwise
            StreamingState = FALSE
            CursorKeyPressed = 0
    endcase
    TailOffset = CurrentTailOffset      // track the KB tail
end mCheckForCursorKeys

/*
   Procedure:   WhenLoaded()

   Notes:       Called by TSE after it loads the macro.

   Called by:   TSE

   Enter With:  nothing

   Returns:     nothing

*/
proc WhenLoaded()
    if mBinaryCheckVideoMode() == 7
        VideoSegment = 0xB000
    else
        VideoSegment = 0xB800
    endif
    Hook(_AFTER_COMMAND_, mCheckForCursorKeys)
    // make sure all User Configurable Options are in range
    mValueSanityCheck()
    // reprogram the keyboard with an appropriate bios call
    mSpeedUpKeyboard()
end WhenLoaded

// the cursor keys
<CursorRight>       mKeySpeedup(<CursorRight>)
<GreyCursorRight>   mKeySpeedup(<CursorRight>)
<CursorLeft>        mKeySpeedup(<CursorLeft>)
<GreyCursorLeft>    mKeySpeedup(<CursorLeft>)
<CursorUp>          mKeySpeedup(<CursorUp>)
<GreyCursorUp>      mKeySpeedup(<CursorUp>)
<CursorDown>        mKeySpeedup(<CursorDown>)
<GreyCursorDown>    mKeySpeedup(<CursorDown>)

