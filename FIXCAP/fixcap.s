// This macro corrects a CAPSLOCK reversal situation (present in WIN95 OSR2
// (reported to SemWare (and noted in UseGroup messages), but not verified
// first hand by SemWare) and WIN98 (first release.. verified first hand by
// SemWare) that affects WIN32 console applications that call the
// ReadConsoleInput API (as does TSE Pro/32).  The situation appears not to
// affect WIN32 console applications that call the ReadConsole API, which
// TSE Pro/32 cannot use (unless we are willing to give up some
// critical functionality (which is not available if we use the other call),
// which we are not).  However, the ReadConsoleInput call we make also returns
// the "state" (which does appear to be CORRECT) of the CAPSLOCK key, ALT key,
// CTRL key, SHIFT key, NUMLOCK key, and SCROLLLOCK key that were active at
// the time the key was pressed (we just need the state of the CAPSLOCK and
// SHIFT keys for what follows), so at least (using additional overhead that
// should normally NOT be necessary) we can "correct" the "incorrect" keys
// with some logic.
//
// The situation occurs if CAPSLOCK is ON (active) at the time of starting
// the WIN32 console application (no problem if CAPSLOCK is OFF (inactive))
// by any of the following:
//
// 1 - Activating an icon shortcut to launch the WIN32 console application.
//
// 2 - Starting the WIN32 console application Via "Run" from WINDOW's
//     "START MENU".
//
// 3 - Starting the WIN32 console application via the START command.
//
// 4 - Launching the WIN32 console application from another application.
//
// 4 - Opening a command prompt window that the WIN 32 console application
//     will be run from.
//
// When the WIN32 console application is launched (as above):
//
// Once within the WIN32 console application, alpha UPPERCASE characters
// that are typed from the keyboard will be returned by the system as
// lowercase characters AND alpha lowercase characters will be returned
// as alpha UPPERCASE characters.  Toggling the CAPSLOCK would "fix" the
// situation (keeping in mind that the characters are opposite to what
// the CAPSLOCK state would indicate) while you are within the application,
// but you would need to potentially toggle the CAPSLOCK when switching to
// another application's window.
//
// To correct this, the macro hooks the editor's _AFTER_GETKEY_ event to
// correct the keycode, if necessary (which means the macro can be active
// even if there is no problem), before the key is passed on through for
// normal processing, and "sync" the characters with the state you would
// expect based on the current "indication" of the CAPSLOCK.
//
// By examining the "alpha" character and the state of the CAPSLOCK and
// SHIFT key (either shift being pressed) we can determine if the current
// "state" is logical (in which case we pass it on through) or illogical,
// in which case we "fix" it.

// Consider the following:
//
// We receive an UPPERCASE "A" , with CAPSLOCK reported as OFF and no SHIFT key
// is being pressed. The key "should" have been reported as lowercase
// (based on the shift states), so the macro translates it to a lowercase "a".
//
// We receive an UPPERCASE "A" , with CAPSLOCK reported as ON and a SHIFT key
// is being pressed. The key "should" have been reported as lowercase
// (based on the shift states), so the macro translates it to a lowercase "a".
//
// We receive an UPPERCASE "A" , with CAPSLOCK reported as ON and no SHIFT key
// is being pressed. This is correct (based on the shift states), so no
// translation is necessary.
//
// We receive an UPPERCASE "A" , with CAPSLOCK reported as OFF and a SHIFT key
// is being pressed. This is correct (based on the shift states), so no
// translation is necessary.
//
// We receive a lowercase "a" , with CAPSLOCK reported as ON and a SHIFT key
// is NOT being pressed. The key "should" have been reported as UPPERCASE
// (based on the shift states), so the macro translates it to an UPPERCASE "A".
//
// We receive a lowercase "a" , with CAPSLOCK reported as OFF and a SHIFT key
// is being pressed.  The key "should" have been reported as UPPERCASE
// (based on the shift states), so the macro translates it to an UPPERCASE "A".
//
// We receive a lowercase "a" , with CAPSLOCK reported as OFF and no SHIFT key
// is being pressed. This is correct (based on the shift states), so no
// translation is necessary.
//
// We receive a lowercase "a" , with CAPSLOCK reported as ON and a SHIFT key
// is being pressed. This is correct (based on the shift states), so no
// translation is necessary.
//
// The following constants are used in what follows:
//
// _CAPS_LOCK_DEPRESSED_    (currently 128)
// _RIGHT_SHIFT_KEY_        (currently 16)
// _LEFT_SHIFT_KEY_         (currently 16)
//
// Since _RIGHT_SHIFT_KEY_ = _LEFT_SHIFT_KEY_, we are using _RIGHT_SHIFT_KEY_
// in what follows.  If this ever changed, additional logic would need to be
// added to the routine.

proc SwitchCase()
    integer keywaiting = Query(key)     // set keywaiting to current key value
    integer keyflags   = GetKeyFlags()  // set keyflags to current shift flags
                                        // for "keywaiting" key

    // In the following, the first "when"  translates alpha UPPERCASE to alpha
    // lowercase characters if (CAPSLOCK and a SHIFT key are active) or
    // (CAPSLOCK is NOT active and a SHIFT key is not active).

    // The second
    // "when" translates alpha lowercase to alpha UPPERCASE characters if
    // (CAPSLOCK IS active and a SHIFT key is NOT active) or (CAPSLOCK is NOT
    // active and a SHIFT key IS active).  The third "when" adjusts <alt ALPHA>,
    // and <altshift ALPHA> sequences to the correct keycode.


    if _RIGHT_SHIFT_KEY_ <> _LEFT_SHIFT_KEY_  // if these constants aren't ==
        Warn("Macro code needs to be adjusted")
        PurgeMacro(CurrMacroFilename())
        return()
    endif

    Case keywaiting
        // 'A'..'Z'
        when 65..90                 if ((keyflags & _CAPS_LOCK_DEPRESSED_) and
                                       (keyflags & _RIGHT_SHIFT_KEY_))
                                       OR
                                       ((not(keyflags & _CAPS_LOCK_DEPRESSED_))
                                       and (not(keyflags & _RIGHT_SHIFT_KEY_)))

                                       Set(key,keywaiting+32)
                                    endif
        // 'a'..'z'
        when 97..122                if ((keyflags & (_CAPS_LOCK_DEPRESSED_))
                                       and (not(keyflags & _RIGHT_SHIFT_KEY_)))
                                       OR
                                       ((not(keyflags & (_CAPS_LOCK_DEPRESSED_)))
                                       and (keyflags & _RIGHT_SHIFT_KEY_))

                                       Set(key,keywaiting-32)
                                    endif

        when 1089..1114,1345..1370  Set(key,keywaiting+32)

    endcase
end

proc WhenLoaded()
    Hook(_AFTER_GETKEY_,SwitchCase)
end

proc WhenPurged()
    UnHook(SwitchCase)
end
