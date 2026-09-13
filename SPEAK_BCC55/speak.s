// SPEAK SAL interface/demo for speak_bcc55.dll - package version 1.0.0.0.0 (2026-09-13)
dll "speak.dll"
    integer proc    speak_initialize        ()

	// For synchronous speech (plays in foreground, blocking)
    integer proc    speak_text              (string text : cstrval, integer textLength)
    integer proc    speak_text_file         (string filename : cstrval)

	// For asynchronous speech (plays in background, non-blocking)
    integer proc    speak_text_async        (string text : cstrval, integer textLength, integer uid)
    integer proc    speak_text_async_file   (string filename : cstrval, integer uid)
    integer proc    speak_text_async_pause  (integer uid)
    integer proc    speak_text_async_resume (integer uid)
    integer proc    speak_text_async_stop   (integer uid)

	// Setters and getters
    integer proc    speak_set_volume        (integer volume_0_to_100)
    integer proc    speak_set_voice         (integer voiceNum)
    integer proc    speak_get_voice_info    (integer voiceNum, var string output255 : strptr)
end

integer   speak_voice_count        = 0
integer   is_speak_initialized     = FALSE
integer   speak_show_no_msgboxes   = FALSE

proc Initialize()
    if is_speak_initialized == FALSE
        speak_voice_count = speak_initialize()
        if speak_voice_count >= 1
            // We have at least one voice to work with
            speak_set_voice(0)
            speak_set_volume(35)
            is_speak_initialized = TRUE
        endif
    endif
end

proc Speak(string text)
    Initialize()
    if is_speak_initialized
        speak_text(text, Length(text))
    else
        if speak_show_no_msgboxes == FALSE
            MsgBox("The speak.dll engine could not be initialized")
        endif
    endif
end

proc SpeakAsync(string text, integer uid)
    Initialize()
    if is_speak_initialized
        speak_text_async(text, Length(text), uid)
    else
        if speak_show_no_msgboxes == FALSE
            MsgBox("The speak.dll engine could not be initialized")
        endif
    endif
end

proc SpeakAsyncPause(integer uid)
    Initialize()
    if is_speak_initialized
        speak_text_async_pause(uid)
    endif
end

proc SpeakAsyncResume(integer uid)
    Initialize()
    if is_speak_initialized
        speak_text_async_resume(uid)
    endif
end

proc SpeakAsyncStop(integer uid)
    Initialize()
    if is_speak_initialized
        speak_text_async_stop(uid)
    endif
end

proc SetVolume(integer volume)
    Initialize()
    if is_speak_initialized
        speak_set_volume(volume)
    endif
end

proc SetVoice(integer voice)
    Initialize()
    if is_speak_initialized
        if voice < speak_voice_count
            speak_set_voice(voice)
        endif
    endif
end

string proc GetVoice(integer voice)

    integer len
    string output255[255] = Format(" " : 255)

    Initialize()
    if is_speak_initialized
        if voice < speak_voice_count
            len = speak_get_voice_info(voice, output255)
            if len > 0
                return(SubStr(output255, len))
            endif
            return("An error occurred while retrieving voice #" + Str(voice) + ".  Error #" + Str(len))
        else
            return("Invalid voice #" + Str(voice) + ", must be 0 thru " + Str(speak_voice_count - 1))
        endif
    endif

    return("The speak.dll engine could not be initialized")
end

proc WhenLoaded()
    Speak("Welcome.  You've got SPEAK DLL.")
end

<Ctrl F8>   SpeakAsync("This is a test of the emergency broadcasting system.  This is only a test.  Had this been an actual emergency, you probably should be taking action right now rather than listening to SPEAK DLL do its thing.", 10)
<Ctrl F9>	SpeakAsyncPause(10)
<Ctrl F10>	SpeakAsyncResume(10)
<Ctrl F11>	SpeakAsyncStop(10)

