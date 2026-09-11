#INCLUDE ["colors.s"]

proc Main()
    string macroVersionS[20] = "1.0.0.0.4"
    integer oldBlackBgRgbI
    integer oldWhiteBgRgbI
    integer oldGreenFgRgbI

    bright(TRUE)
    overscan(4)

    oldBlackBgRgbI = SetColorTableValue(_BACKGROUND_, _BLACK_, 0x800000)
    oldWhiteBgRgbI = SetColorTableValue(_BACKGROUND_, _WHITE_, 0x0000A8)
    oldGreenFgRgbI = SetColorTableValue(_FOREGROUND_, _GREEN_, 0x00FF00)

    UpdateDisplay(_ALL_WINDOWS_REFRESH_)

    Warn("INTENSE2 DLL demo ", macroVersionS,
         ": bright=", getBrightState(),
         ", overscan=", getOverscanColor(),
         ". Press OK to restore the original colors. OpenAI GPT-5.6.")

    SetColorTableValue(_BACKGROUND_, _BLACK_, oldBlackBgRgbI)
    SetColorTableValue(_BACKGROUND_, _WHITE_, oldWhiteBgRgbI)
    SetColorTableValue(_FOREGROUND_, _GREEN_, oldGreenFgRgbI)

    UpdateDisplay(_ALL_WINDOWS_REFRESH_)
end
