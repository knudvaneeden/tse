// Dec.15.2024 RCH Initial creation
// Dec.24.2024 RCH Added async functions
// Dec.28.2024 RCH Added speak_load_more_voices
// Dec.29.2024 RCH Added speak_get_voice_count, fixes a bug on LoadMoreVoices() were speak_voice_count doesn't change

dll "speak.dll"
    integer proc    speak_initialize            ()

    // For synchronous speech (plays in foreground, blocking)
    integer proc    speak_text                  (string text : cstrval, integer textLength)
    integer proc    speak_text_file             (string filename : cstrval)

    // For asynchronous speech (plays in background, non-blocking)
    integer proc    speak_text_async            (string text : cstrval, integer textLength, integer uid)
    integer proc    speak_text_async_file       (string filename : cstrval, integer uid)
    integer proc    speak_text_async_pause      (integer uid)
    integer proc    speak_text_async_resume     (integer uid)
    integer proc    speak_text_async_stop       (integer uid)

    // Setters and getters
    integer proc    speak_set_volume            (integer volume_0_to_100)
    integer proc    speak_set_voice             (integer voiceNum)
    integer proc    speak_get_voice             ()
    integer proc    speak_get_voice_count       ()                                                      // Dec.29.2024 RCH added
    integer proc    speak_get_volume            ()
    integer proc    speak_get_voice_info        (integer voiceNum, var string output255 : strptr)
    integer proc    speak_get_api_info          (integer apiNum, var string output255 : strptr)         // Dec.24.2024 RCH added
    integer proc    speak_write_out_api_info    (string outputFilename : cstrval)                       // Dec.24.2024 RCH added
    integer proc    speak_load_more_voices      (string registryPath : cstrval)                         // Dec.28.2024 RCH added
end

integer   speak_voice_count           = 0
integer   speak_last_voice            = 0
integer   is_speak_initialized        = FALSE
integer   speak_show_no_msgboxes      = FALSE
string    speak_not_initialized[34]   = "SPEAK.DLL count not be initialized"

proc Initialize()
    if is_speak_initialized == FALSE
        speak_voice_count = speak_initialize()
        if speak_voice_count >= 1
            // We have at least one voice to work with
            speak_set_voice(0)
            speak_set_volume(50)
            is_speak_initialized = TRUE
        endif
    endif
end

proc SpeakNotInitialized()

    string text[47] = "SPEAK.DLL:  The engine could not be initialized"

    if speak_show_no_msgboxes == FALSE
        MsgBox(text)
    else
        Message(text)
    endif
end

proc Speak(string text)
    Initialize()
    if is_speak_initialized
        speak_text(text, Length(text))
        return()
    endif
    SpeakNotInitialized()
end

proc SpeakAsync(string text, integer uid)
    Initialize()
    if is_speak_initialized
        speak_text_async(text, Length(text), uid)
        return()
    endif
    SpeakNotInitialized()
end

proc SpeakAsyncPause(integer uid)
    Initialize()
    if is_speak_initialized
        speak_text_async_pause(uid)
        return()
    endif
    SpeakNotInitialized()
end

proc SpeakAsyncResume(integer uid)
    Initialize()
    if is_speak_initialized
        speak_text_async_resume(uid)
        return()
    endif
    SpeakNotInitialized()
end

proc SpeakAsyncStop(integer uid)
    Initialize()
    if is_speak_initialized
        speak_text_async_stop(uid)
        return()
    endif
    SpeakNotInitialized()
end

integer proc SetVolume(integer volume)
    Initialize()
    if is_speak_initialized
        volume = speak_set_volume(volume)
        return(volume)
    endif
    SpeakNotInitialized()
    return(-1)
end

integer proc GetVolume()
    Initialize()
    if is_speak_initialized
        return(speak_get_volume())
    endif
    SpeakNotInitialized()
    return(-1)
end

proc SetVoice(integer voice)
    Initialize()
    if is_speak_initialized
        if voice < speak_voice_count
            speak_last_voice = voice
            speak_set_voice(voice)
            return()
        endif
        Message("SPEAK.DLL:  Voice " + Str(voice) + " is invalid.  Max voice is " + Str(speak_voice_count - 1))
        return()
    endif
    SpeakNotInitialized()
end

// Call with -1 to use the current voice
string proc GetVoice(integer voice)

    integer len
    string output255[255] = Format(" " : 255)

    Initialize()
    if is_speak_initialized
        if voice < 0
            voice = speak_get_voice()
        endif
        if voice < speak_voice_count
            len = speak_get_voice_info(voice, output255)
            if len > 0
                return(LeftStr(output255, len))
            endif
            return("An error occurred while retrieving voice #" + Str(voice) + ".  Error #" + Str(Abs(len)))
        else
            return("Invalid voice #" + Str(voice) + ", must be 0 thru " + Str(speak_voice_count - 1))
        endif
    endif
    SpeakNotInitialized()
    return(speak_not_initialized)

end

integer proc LoadMoreVoices(string registryPath)

    integer count, before

    Initialize()
    if is_speak_initialized
        count = speak_load_more_voices(registryPath)
		before = speak_voice_count
		speak_voice_count = speak_get_voice_count()
		Message("SPEAK.DLL:  " + Str(count) + " voice" + iif(count <> 1, "s", "") + " loaded.  " + iif(count <> 0, "Was " + Str(before) + ", now ", "") + Str(speak_voice_count) + " voice" + iif(count <> 1, "s", "") + " available.")
    else
        count = -1
        SpeakNotInitialized()
    endif
    return(count)

end

proc SpeakChooseVoice()

    integer ok
    string text[3] = ""

    Initialize()
    if is_speak_initialized
        ok = AskNumeric("Please choose a voice number 0 to " + Str(speak_voice_count - 1) + ":", text)
        if ok and Val(text) >= 0 and val(text) < speak_voice_count
            SetVoice(Val(text))
            Message("SPEAK.DLL:  Voice is now set to #" + text + " of " + Str(speak_voice_count - 1) + " " + Chr(34) + GetVoice(Val(text)) + Chr(34))
            return()
        endif
        Message("SPEAK.DLL:  Voice #" + text + " is invalid.  Must be 0 to " + Str(speak_voice_count -1))
        return()
    endif
    SpeakNotInitialized()

end

proc SpeakPrevVoice()

	integer voice
	string text[255] = ""

    Initialize()
    if is_speak_initialized
    	voice = speak_get_voice()
    	if voice > 0
    		SetVoice(voice - 1)
    	else
    		SetVoice(speak_voice_count - 1)
    	endif
    	voice = speak_get_voice()
    	text  = "Current voice is set to #" + Str(voice) + " of " + Str(speak_voice_count - 1) + ".  " + GetVoice(voice) + "."
        Message("SPEAK.DLL:  " + text)
    	SpeakAsync(text, 10)
    	return()
    endif
    SpeakNotInitialized()

end

proc SpeakNextVoice()

	integer voice
	string text[255] = ""

    Initialize()
    if is_speak_initialized
    	voice = speak_get_voice()
    	if voice < speak_voice_count - 1
    		SetVoice(voice + 1)
    	else
    		SetVoice(0)
    	endif
    	voice = speak_get_voice()
    	text  = "Current voice is set to #" + Str(voice) + " of " + Str(speak_voice_count - 1) + ".  " + GetVoice(voice) + "."
        Message("SPEAK.DLL:  " + text)
    	SpeakAsync(text, 10)
    	return()
    endif
    SpeakNotInitialized()

end

proc SpeakChooseText()

    integer ok
    string text[255] = "This is " + GetVoice(speak_last_voice)

    Initialize()
    if is_speak_initialized
        ok = Ask("Please choose some text to speak:", text)
        if ok
            Message("SPEAK.DLL:  " + text)
            SpeakAsync(text, 10)
        endif
    endif
end

proc SpeakChooseVolume()

    integer ok, oldVolume
    string text[3] = ""

    Initialize()
    if is_speak_initialized
        text = Str(speak_get_volume())
        ok = AskNumeric("Please choose a volume 0 to 100", text)
        if ok
            if Val(text) >= 0 and val(text) <= 100
                oldVolume = SetVolume(Val(text))
                Message("SPEAK.DLL:  Volume set to " + text + ", was " + Str(oldVolume))
            else
                Message("SPEAK.DLL:  Volume not set.  Must be in range 0..100.  Is currently " + Str(oldVolume))
            endif
            return()
        endif
        Message("SPEAK.DLL:  The value " + text + " is invalid.  Must be 0 to 100")
        return()
    endif
    SpeakNotInitialized()

end

string proc GetApi(integer api)

    integer len
    string output255[255] = Format(" " : 255)

    Initialize()
    if is_speak_initialized
        len = speak_get_api_info(api, output255)
        if len > 0
            return(LeftStr(output255, len))
        endif
        return("An error occurred while retrieving API #" + Str(api) + ".  Error #" + Str(len))
    endif
    SpeakNotInitialized()
    return(speak_not_initialized)

end

string proc WriteApiToFile(string outputFilename)
    Initialize()
    if is_speak_initialized
        if speak_write_out_api_info(outputFilename) >= 0
            Message("SPEAK.DLL:  API information written to " + outputFilename)
            return("Written")
        endif
        Message("SPEAK.DLL:  An error occurred attemtping to write API information to " + outputFilename)
        return("An error occurred while attempting to write to file: " + outputFilename)
    endif
    SpeakNotInitialized()
    return(speak_not_initialized)
end

string proc InsertApiIntoEditor()

    integer api, len
    string output255[255] = Format(" " : 255)

    Initialize()
    if is_speak_initialized
        api = 0
        loop
            len = speak_get_api_info(api, output255)
            if len < 0
                break
            endif
            if len <> 0
                AddLine(LeftStr(output255, len))
            endif
            api = api + 1
        endloop
        AddLine("Found " + Str(api) + " API function" + iif(api <> 1, "s", ""))
        AddLine()
        return(GetText(1, CurrLineLen()))
    endif
    SpeakNotInitialized()
    return(speak_not_initialized)

end

string proc InsertVoicesIntoEditor()

    integer voice, len
    string output255[255] = Format(" " : 255)

    Initialize()
    if is_speak_initialized
        voice = 0
        loop
            len = speak_get_voice_info(voice, output255)
            if len < 0
                break
            endif
            if len <> 0
                AddLine("Voice #" + Str(voice) + " -- " + LeftStr(output255, len))
            endif
            voice = voice + 1
        endloop
        AddLine("Found " + Str(voice) + " voice" + iif(voice <> 1, "s", ""))
        AddLine()
        return(GetText(1, CurrLineLen()))
    endif
    SpeakNotInitialized()
    return(speak_not_initialized)

end

proc WhenLoaded()
    Speak("SPEAK DLL loaded.  Press Ctrl F7 for help.")
end

<Ctrl F7>   SpeakAsync("Press Ctrl F8 to speak some text.  Alt F9 to choose a voice number.  And Alt F10 to list all voices.", 10)
<Ctrl F8>   SpeakChooseText()

<Ctrl F9>   SpeakAsyncPause(10)
<Ctrl F10>  SpeakAsyncResume(10)
<Ctrl F11>  SpeakAsyncStop(10)

<Alt F5>	LoadMoreVoices("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\Voices")
<Alt F6>	SpeakPrevVoice()
<Alt F7>	SpeakNextVoice()
<Alt F8>    SpeakChooseVolume()
<Alt F9>    SpeakChooseVoice()

<Alt F10>   InsertVoicesIntoEditor()
<Alt F11>   InsertApiIntoEditor()

<Alt F12>   WriteApiToFile("speak_dll_api.txt")

