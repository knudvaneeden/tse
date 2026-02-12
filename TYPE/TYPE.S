/*
   Macro:   Type.
   Author:  carlo.hogeveen@xs4all.nl.
   Date:    1 Octbober 2000.

   This macro lets TSE make typewriter sounds as you type.

   Put it and the .wav files in TSE's "mac" directory,
   and compile and load the macro.
   You can also put it in TSE's Macro AutoLoad List.
*/

constant SND_ASYNC    = 0x0001
constant SND_FILENAME = 0x00020000

dll "<winmm.dll>"
   integer proc sysPlaySound(string fn:CStrVal,
                             integer hModule,
                             integer fuSound) : "PlaySound"
end

/*
proc PlaySound(string fn)
   sysPlaySound(fn, 0, SND_FILENAME)
end
*/

proc PlaySoundAsync(string fn)
   sysPlaySound(fn, 0, SND_FILENAME|SND_ASYNC)
end

proc before_command()
   if Query(Key) shr 8 == 0
      PlaySoundAsync(LoadDir() + "mac\type.wav")
   else
      case Query(Key) & 0xff
         when 13
            PlaySoundAsync(LoadDir() + "mac\kerching.wav")
         otherwise
            PlaySoundAsync(LoadDir() + "mac\select.wav")
      endcase
   endif
end

proc WhenLoaded()
   Hook(_BEFORE_COMMAND_, before_command)
end

proc Main()
end

