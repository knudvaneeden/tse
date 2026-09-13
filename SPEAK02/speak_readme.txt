The speak.dll plugin was written by:

    Author:  rick.c.hodgin@gmail.com.
      Date:  December 15, 2024

-----
It has a simple API:

    Variables:
        speak_initialized                       // Boolean, if the speak.dll initializes successfully then it's TRUE
        speak_no_msgboxes                       // Boolean, specifies if MsgBox() alerts should popup, FALSE by default (meaning they will pop up)
        speak_voice_count                       // Integer, indicates how many voices are available, use GetVoice() to see its internal identifier

    Functions:
        Speak(text)                             // Speaks the text, is blocking until completed
        SetVolume(0..100)                       // Returns volume if successful, negative if error
        SetVoice(0..speak_voice_count - 1)      // Returns voice if successful, negative if error
        GetVoice(0..speak_voice_count - 1)      // Returns voice info based on what the internal SAPI engine specifies

This DLL will work with any application that can use DLLs.
It is no specific to The SemWare Editor.

Enjoy.  Please contact me with any questions or bug fixes.
If you do, please reference speak.dll for The SemWare Editor.

--
Rick C. Hodgin
Luke 6:37

