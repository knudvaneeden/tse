FORWARD INTEGER PROC FNProgramRunKeyShortcutAutohotkeyCaseAllB( STRING s1 )
FORWARD PROC Main()


// --- MAIN --- //

#DEFINE ELIST_INCLUDED FALSE
#include [ "eList.s" ]
//
PROC Main()
 //
 STRING s1[255] = ""
 //
 INTEGER bufferI = 0
 //
 PushPosition()
 bufferI = CreateTempBuffer()
 PopPosition()
 //
 PushPosition()
 PushBlock()
 //
 GotoBufferId( bufferI )
 //
 AddLine( '<WindowsKey + +>                  ; Open Magnifier and zoom in.' )
 AddLine( '<WindowsKey + ,>                  ; Temporarily peek at the desktop.' )
 AddLine( '<WindowsKey + ->                  ; Zoom out in Magnifier.' )
 AddLine( '<WindowsKey + .>                  ; Show the "Emoji" menu.' )
 AddLine( '<WindowsKey + />                  ; Begin IME reconversion. An Input Method Editor (IME) enables a user to input text in a natural language (e.g. Chinese). The user types combinations of keys. The IME generates then the equivalent character.' )
 AddLine( '<WindowsKey + 1>                  ; Open the desktop and start the app pinned on the taskbar in the position indicated by the number 1. If the app is already running switch to that app.' )
 AddLine( '<WindowsKey + 2>                  ; Open the desktop and start the app pinned on the taskbar in the position indicated by the number 2. If the app is already running switch to that app.' )
 AddLine( '<WindowsKey + 3>                  ; Open the desktop and start the app pinned on the taskbar in the position indicated by the number 3. If the app is already running switch to that app.' )
 AddLine( '<WindowsKey + 4>                  ; Open the desktop and start the app pinned on the taskbar in the position indicated by the number 4. If the app is already running switch to that app.' )
 AddLine( '<WindowsKey + 5>                  ; Open the desktop and start the app pinned on the taskbar in the position indicated by the number 5. If the app is already running switch to that app.' )
 AddLine( '<WindowsKey + 6>                  ; Open the desktop and start the app pinned on the taskbar in the position indicated by the number 6. If the app is already running switch to that app.' )
 AddLine( '<WindowsKey + 7>                  ; Open the desktop and start the app pinned on the taskbar in the position indicated by the number 7. If the app is already running switch to that app.' )
 AddLine( '<WindowsKey + 8>                  ; Open the desktop and start the app pinned on the taskbar in the position indicated by the number 8. If the app is already running switch to that app.' )
 AddLine( '<WindowsKey + 9>                  ; Open the desktop and start the app pinned on the taskbar in the position indicated by the number 9. If the app is already running switch to that app.' )
 AddLine( '<WindowsKey + ;>                  ; Show the "Emoji" menu' )
 AddLine( '<WindowsKey + A>                  ; Show the "Notifications" and "Quick Settings" menu on the right side of the screen' )
 AddLine( '<WindowsKey + Alt + 1>            ; Open the desktop and open the "Jump" menu for the app pinned to the taskbar in the position indicated by the number 1.' )
 AddLine( '<WindowsKey + Alt + 2>            ; Open the desktop and open the "Jump" menu for the app pinned to the taskbar in the position indicated by the number 2.' )
 AddLine( '<WindowsKey + Alt + 3>            ; Open the desktop and open the "Jump" menu for the app pinned to the taskbar in the position indicated by the number 3.' )
 AddLine( '<WindowsKey + Alt + 4>            ; Open the desktop and open the "Jump" menu for the app pinned to the taskbar in the position indicated by the number 4.' )
 AddLine( '<WindowsKey + Alt + 5>            ; Open the desktop and open the "Jump" menu for the app pinned to the taskbar in the position indicated by the number 5.' )
 AddLine( '<WindowsKey + Alt + 6>            ; Open the desktop and open the "Jump" menu for the app pinned to the taskbar in the position indicated by the number 6.' )
 AddLine( '<WindowsKey + Alt + 7>            ; Open the desktop and open the "Jump" menu for the app pinned to the taskbar in the position indicated by the number 7.' )
 AddLine( '<WindowsKey + Alt + 8>            ; Open the desktop and open the "Jump" menu for the app pinned to the taskbar in the position indicated by the number 8.' )
 AddLine( '<WindowsKey + Alt + 9>            ; Open the desktop and open the "Jump" menu for the app pinned to the taskbar in the position indicated by the number 9.' )
 AddLine( '<WindowsKey + Alt + ArrowDown>    ; Snap window in focus to bottom half of screen (only in Microsoft Windows 11' )
 AddLine( '<WindowsKey + Alt + ArrowLeft>    ;' )
 AddLine( '<WindowsKey + Alt + ArrowRight>   ;' )
 AddLine( '<WindowsKey + Alt + ArrowUp>      ; Snap the window in focus to the top half of the screen (only in Microsoft Windows 11' )
 AddLine( '<WindowsKey + Alt + B>            ; Toggle HDR (=High Dynamic Range (controls luminosity)) on or off. Switch between HDR display and standard display (XBox Game related)' )
 AddLine( '<WindowsKey + Alt + Enter>        ; Open taskbar settings (when the taskbar has focus).' )
 AddLine( '<WindowsKey + Alt + K>            ; Toggle "Microphone Mute" (in apps that support "Call Mute")' )
 AddLine( '<WindowsKey + Alt + PrtScn>       ; Save screenshot of game window in focus to file (using Xbox Game Bar).' )
 AddLine( '<WindowsKey + Alt + R>            ; Record a video of the game window in focus (using XBox Game Bar)' )
 AddLine( '<WindowsKey + ArrowDown>          ; Remove current app from screen or minimize the desktop window.' )
 AddLine( '<WindowsKey + ArrowLeft>          ; Maximize the app or desktop window to the left side of the screen' )
 AddLine( '<WindowsKey + ArrowRight>         ; Maximize the app or desktop window to the right side of the screen.' )
 AddLine( '<WindowsKey + ArrowUp>            ; Maximize the window.' )
 AddLine( '<WindowsKey + B>                  ; Set the focus to the first icon on the taskbar corner' )
 AddLine( '<WindowsKey + C>                  ; Show "Chat" from Microsoft Teams (Cortana)' )
 AddLine( '<WindowsKey + Ctrl + 1>           ; Open the desktop and switch to the last active window of the app pinned to the taskbar in the position indicated by the number 1.' )
 AddLine( '<WindowsKey + Ctrl + 2>           ; Open the desktop and switch to the last active window of the app pinned to the taskbar in the position indicated by the number 2.' )
 AddLine( '<WindowsKey + Ctrl + 3>           ; Open the desktop and switch to the last active window of the app pinned to the taskbar in the position indicated by the number 3.' )
 AddLine( '<WindowsKey + Ctrl + 4>           ; Open the desktop and switch to the last active window of the app pinned to the taskbar in the position indicated by the number 4.' )
 AddLine( '<WindowsKey + Ctrl + 5>           ; Open the desktop and switch to the last active window of the app pinned to the taskbar in the position indicated by the number 5.' )
 AddLine( '<WindowsKey + Ctrl + 6>           ; Open the desktop and switch to the last active window of the app pinned to the taskbar in the position indicated by the number 6.' )
 AddLine( '<WindowsKey + Ctrl + 7>           ; Open the desktop and switch to the last active window of the app pinned to the taskbar in the position indicated by the number 7.' )
 AddLine( '<WindowsKey + Ctrl + 8>           ; Open the desktop and switch to the last active window of the app pinned to the taskbar in the position indicated by the number 8.' )
 AddLine( '<WindowsKey + Ctrl + 9>           ; Open the desktop and switch to the last active window of the app pinned to the taskbar in the position indicated by the number 9.' )
 AddLine( '<WindowsKey + Ctrl + ArrowDown>   ;' )
 AddLine( '<WindowsKey + Ctrl + ArrowLeft>   ; Switch between virtual desktops you have created on the left.' )
 AddLine( '<WindowsKey + Ctrl + ArrowRight>  ; Switch between virtual desktops you have created on the right.' )
 AddLine( '<WindowsKey + Ctrl + ArrowUp>     ;' )
 AddLine( '<WindowsKey + Ctrl + C>           ; Turn on color filters (you must enable this shortcut first in "Color Filter Settings")' )
 AddLine( '<WindowsKey + Ctrl + D>           ; Add a virtual desktop' )
 AddLine( '<WindowsKey + Ctrl + Enter>       ; Turn on "Narrator' )
 AddLine( '<WindowsKey + Ctrl + F4>          ; Close the virtual desktop you are using.' )
 AddLine( '<WindowsKey + Ctrl + F>           ; Search for PCs (if you are on a network)' )
 AddLine( '<WindowsKey + Ctrl + Q>           ; Show "Quick Assist" menu' )
 AddLine( '<WindowsKey + Ctrl + Shift + 1>   ; Open the desktop and open a new instance of the app located at the given position 1 on the taskbar as an administrator.' )
 AddLine( '<WindowsKey + Ctrl + Shift + 2>   ; Open the desktop and open a new instance of the app located at the given position 2 on the taskbar as an administrator.' )
 AddLine( '<WindowsKey + Ctrl + Shift + 3>   ; Open the desktop and open a new instance of the app located at the given position 3 on the taskbar as an administrator.' )
 AddLine( '<WindowsKey + Ctrl + Shift + 4>   ; Open the desktop and open a new instance of the app located at the given position 4 on the taskbar as an administrator.' )
 AddLine( '<WindowsKey + Ctrl + Shift + 5>   ; Open the desktop and open a new instance of the app located at the given position 5 on the taskbar as an administrator.' )
 AddLine( '<WindowsKey + Ctrl + Shift + 6>   ; Open the desktop and open a new instance of the app located at the given position 6 on the taskbar as an administrator.' )
 AddLine( '<WindowsKey + Ctrl + Shift + 7>   ; Open the desktop and open a new instance of the app located at the given position 7 on the taskbar as an administrator.' )
 AddLine( '<WindowsKey + Ctrl + Shift + 8>   ; Open the desktop and open a new instance of the app located at the given position 8 on the taskbar as an administrator.' )
 AddLine( '<WindowsKey + Ctrl + Shift + 9>   ; Open the desktop and open a new instance of the app located at the given position 9 on the taskbar as an administrator.' )
 AddLine( '<WindowsKey + Ctrl + Shift + B>   ; Wake PC from blank or black screen.' )
 AddLine( '<WindowsKey + Ctrl + Spacebar>    ; Change to a previously selected input.' )
 AddLine( '<WindowsKey + D>                  ; Toggle between show and hide the desktop' )
 AddLine( '<WindowsKey + E>                  ; Show Microsoft Explorer' )
 AddLine( '<WindowsKey + Enter>              ; Show the "Narrator" menu' )
 AddLine( '<WindowsKey + Escape>             ; Close Magnifier.' )
 AddLine( '<WindowsKey + F>                  ; Show "Feedback Hub" window and take a screenshot' )
 AddLine( '<WindowsKey + G>                  ; Show "Video Capture" menu (=record a screencast .mp4 (e.g. demonstration) video) + "Audio sound" menu + "CPU / GPU / RAM / VRAM / FPS Performance" + "Spotify" menu.' )
 AddLine( '<WindowsKey + H>                  ; Show "Voice Typing" menu' )
 AddLine( '<WindowsKey + Home>               ; Minimize all except the active desktop window (restores all windows on second stroke).' )
 AddLine( '<WindowsKey + I>                  ; Show "Settings" menu' )
 AddLine( '<WindowsKey + J>                  ; Show focus on a "Windows Tip" (when one is available)' )
 AddLine( '<WindowsKey + K>                  ; Show "BlueTooth" menu (e.g. for changing the BlueTooth earbuds you use on the computer) on the right side of the screen' )
 AddLine( '<WindowsKey + L>                  ; Lock your computer or switch accounts' )
 AddLine( '<WindowsKey + M>                  ; Minimize all windows on the desktop' )
 AddLine( '<WindowsKey + N>                  ; Show "Notifications" and "Calendar" (only in Microsoft Windows 11)' )
 AddLine( '<WindowsKey + O>                  ; Lock device orientation (seems not to work in Microsoft Windows 10)' )
 AddLine( '<WindowsKey + P>                  ; Show "Monitor Display" menu on the right side of the screen' )
 AddLine( '<WindowsKey + Pause>              ; Temporarily peek at the desktop' )
 AddLine( '<WindowsKey + PrtScn>             ; Save full screen screenshot to file' )
 AddLine( '<WindowsKey + R>                  ; Show "Run" box' )
 AddLine( '<WindowsKey + S>                  ; Show "Search" box' )
 AddLine( '<WindowsKey + Shift + 1>          ; Open the desktop and start a new instance of the app pinned to the taskbar in the position indicated by the number 1.' )
 AddLine( '<WindowsKey + Shift + 2>          ; Open the desktop and start a new instance of the app pinned to the taskbar in the position indicated by the number 2.' )
 AddLine( '<WindowsKey + Shift + 3>          ; Open the desktop and start a new instance of the app pinned to the taskbar in the position indicated by the number 3.' )
 AddLine( '<WindowsKey + Shift + 4>          ; Open the desktop and start a new instance of the app pinned to the taskbar in the position indicated by the number 4.' )
 AddLine( '<WindowsKey + Shift + 5>          ; Open the desktop and start a new instance of the app pinned to the taskbar in the position indicated by the number 5.' )
 AddLine( '<WindowsKey + Shift + 6>          ; Open the desktop and start a new instance of the app pinned to the taskbar in the position indicated by the number 6.' )
 AddLine( '<WindowsKey + Shift + 7>          ; Open the desktop and start a new instance of the app pinned to the taskbar in the position indicated by the number 7.' )
 AddLine( '<WindowsKey + Shift + 8>          ; Open the desktop and start a new instance of the app pinned to the taskbar in the position indicated by the number 8.' )
 AddLine( '<WindowsKey + Shift + 9>          ; Open the desktop and start a new instance of the app pinned to the taskbar in the position indicated by the number 9.' )
 AddLine( '<WindowsKey + Shift + ArrowDown>  ; Restore/minimize active desktop windows vertically, maintaining width.' )
 AddLine( '<WindowsKey + Shift + ArrowLeft>  ; Move an app or window in the desktop from one monitor left to another.' )
 AddLine( '<WindowsKey + Shift + ArrowRight> ; Move an app or window in the desktop from one monitor right to another.' )
 AddLine( '<WindowsKey + Shift + ArrowUp>    ; Stretch the desktop window to the top and bottom of the screen.' )
 AddLine( '<WindowsKey + Shift + C>          ; Show the "Charms" menu' )
 AddLine( '<WindowsKey + Shift + M>          ; Restore minimized windows on the desktop' )
 AddLine( '<WindowsKey + Shift + S>          ; Take a screenshot of part of your screen' )
 AddLine( '<WindowsKey + Shift + Spacbar>    ; Cycle backwards through language and keyboard layout.' )
 AddLine( '<WindowsKey + Shift + V>          ; Set the focus to a notification' )
 AddLine( '<WindowsKey + Spacebar            ; Switch input language and keyboard layout.' )
 AddLine( '<WindowsKey + T>                  ; Cycle through the apps on the Microsoft Windows taskbar' )
 AddLine( '<WindowsKey + Tab>                ; Show the "Activity History" menu' )
 AddLine( '<WindowsKey + U>                  ; Show the "Accessibility" menu' )
 AddLine( '<WindowsKey + V>                  ; Show the "Clipboard History" menu (must be enabled first in the settings)' )
 AddLine( '<WindowsKey + W>                  ; Show the "Widgets" menu' )
 AddLine( '<WindowsKey + X>                  ; Show the "Quick Link" menu (=the "window" icon in the left bottom of the screen)' )
 AddLine( '<WindowsKey + Y>                  ; Switch input between Microsoft Windows "Mixed Reality" and your desktop (does not work in Microsoft Windows 10' )
 AddLine( '<WindowsKey + Z>                  ; Show the "Snap" layouts (does not work in Microsoft Windows 10' )
 AddLine( '<WindowsKey>                      ; Show or hide the "Start" menu' )
 //
 GotoLine( 1 )
 // IF List( "Choose an option", 80 )
 IF eList( "Choose an option" )
  s1 = Trim( GetText( 1, 255 ) )
 ELSE
  AbandonFile( bufferI )
  PopBlock()
  PopPosition()
  RETURN()
 ENDIF
 AbandonFile( bufferI )
 PopBlock()
 PopPosition()
 //
 // do something with s1
 //
 s1 = GetToken( s1, ";", 1 )
 s1 = Trim( s1 )
 //
 Message( FNProgramRunKeyShortcutAutohotkeyCaseAllB( s1 ) ) // gives e.g. TRUE
END
//
<F12> ExecMacro( "windowskeyall" )

// --- LIBRARY --- //

// library: program: run: key: shorthcut: autohotkey: case: all <description></description> <version control></version control> <version>1.0.0.0.14</version> <version control></version control> (filenamemacro=windowskeyall.s) [<Program>] [<Research>] [kn, ri, sa, 17-12-2022 01:22:24]
INTEGER PROC FNProgramRunKeyShortcutAutohotkeyCaseAllB( STRING caseS )
 // e.g. #DEFINE ELIST_INCLUDED FALSE
 // e.g. #include [ "eList.s" ]
 // e.g. //
 // e.g. PROC Main()
 // e.g.  //
 // e.g.  STRING s1[255] = ""
 // e.g.  //
 // e.g.  INTEGER bufferI = 0
 // e.g.  //
 // e.g.  PushPosition()
 // e.g.  bufferI = CreateTempBuffer()
 // e.g.  PopPosition()
 // e.g.  //
 // e.g.  PushPosition()
 // e.g.  PushBlock()
 // e.g.  //
 // e.g.  GotoBufferId( bufferI )
 // e.g.  //
 // e.g.  AddLine( '<WindowsKey + +>                  ; Open Magnifier and zoom in.' )
 // e.g.  AddLine( '<WindowsKey + ,>                  ; Temporarily peek at the desktop.' )
 // e.g.  AddLine( '<WindowsKey + ->                  ; Zoom out in Magnifier.' )
 // e.g.  AddLine( '<WindowsKey + .>                  ; Show the "Emoji" menu.' )
 // e.g.  AddLine( '<WindowsKey + />                  ; Begin IME reconversion. An Input Method Editor (IME) enables a user to input text in a natural language (e.g. Chinese). The user types combinations of keys. The IME generates then the equivalent character.' )
 // e.g.  AddLine( '<WindowsKey + 1>                  ; Open the desktop and start the app pinned on the taskbar in the position indicated by the number 1. If the app is already running switch to that app.' )
 // e.g.  AddLine( '<WindowsKey + 2>                  ; Open the desktop and start the app pinned on the taskbar in the position indicated by the number 2. If the app is already running switch to that app.' )
 // e.g.  AddLine( '<WindowsKey + 3>                  ; Open the desktop and start the app pinned on the taskbar in the position indicated by the number 3. If the app is already running switch to that app.' )
 // e.g.  AddLine( '<WindowsKey + 4>                  ; Open the desktop and start the app pinned on the taskbar in the position indicated by the number 4. If the app is already running switch to that app.' )
 // e.g.  AddLine( '<WindowsKey + 5>                  ; Open the desktop and start the app pinned on the taskbar in the position indicated by the number 5. If the app is already running switch to that app.' )
 // e.g.  AddLine( '<WindowsKey + 6>                  ; Open the desktop and start the app pinned on the taskbar in the position indicated by the number 6. If the app is already running switch to that app.' )
 // e.g.  AddLine( '<WindowsKey + 7>                  ; Open the desktop and start the app pinned on the taskbar in the position indicated by the number 7. If the app is already running switch to that app.' )
 // e.g.  AddLine( '<WindowsKey + 8>                  ; Open the desktop and start the app pinned on the taskbar in the position indicated by the number 8. If the app is already running switch to that app.' )
 // e.g.  AddLine( '<WindowsKey + 9>                  ; Open the desktop and start the app pinned on the taskbar in the position indicated by the number 9. If the app is already running switch to that app.' )
 // e.g.  AddLine( '<WindowsKey + ;>                  ; Show the "Emoji" menu' )
 // e.g.  AddLine( '<WindowsKey + A>                  ; Show the "Notifications" and "Quick Settings" menu on the right side of the screen' )
 // e.g.  AddLine( '<WindowsKey + Alt + 1>            ; Open the desktop and open the "Jump" menu for the app pinned to the taskbar in the position indicated by the number 1.' )
 // e.g.  AddLine( '<WindowsKey + Alt + 2>            ; Open the desktop and open the "Jump" menu for the app pinned to the taskbar in the position indicated by the number 2.' )
 // e.g.  AddLine( '<WindowsKey + Alt + 3>            ; Open the desktop and open the "Jump" menu for the app pinned to the taskbar in the position indicated by the number 3.' )
 // e.g.  AddLine( '<WindowsKey + Alt + 4>            ; Open the desktop and open the "Jump" menu for the app pinned to the taskbar in the position indicated by the number 4.' )
 // e.g.  AddLine( '<WindowsKey + Alt + 5>            ; Open the desktop and open the "Jump" menu for the app pinned to the taskbar in the position indicated by the number 5.' )
 // e.g.  AddLine( '<WindowsKey + Alt + 6>            ; Open the desktop and open the "Jump" menu for the app pinned to the taskbar in the position indicated by the number 6.' )
 // e.g.  AddLine( '<WindowsKey + Alt + 7>            ; Open the desktop and open the "Jump" menu for the app pinned to the taskbar in the position indicated by the number 7.' )
 // e.g.  AddLine( '<WindowsKey + Alt + 8>            ; Open the desktop and open the "Jump" menu for the app pinned to the taskbar in the position indicated by the number 8.' )
 // e.g.  AddLine( '<WindowsKey + Alt + 9>            ; Open the desktop and open the "Jump" menu for the app pinned to the taskbar in the position indicated by the number 9.' )
 // e.g.  AddLine( '<WindowsKey + Alt + ArrowDown>    ; Snap window in focus to bottom half of screen (only in Microsoft Windows 11' )
 // e.g.  AddLine( '<WindowsKey + Alt + ArrowLeft>    ;' )
 // e.g.  AddLine( '<WindowsKey + Alt + ArrowRight>   ;' )
 // e.g.  AddLine( '<WindowsKey + Alt + ArrowUp>      ; Snap the window in focus to the top half of the screen (only in Microsoft Windows 11' )
 // e.g.  AddLine( '<WindowsKey + Alt + B>            ; Toggle HDR (=High Dynamic Range (controls luminosity)) on or off. Switch between HDR display and standard display (XBox Game related)' )
 // e.g.  AddLine( '<WindowsKey + Alt + Enter>        ; Open taskbar settings (when the taskbar has focus).' )
 // e.g.  AddLine( '<WindowsKey + Alt + K>            ; Toggle "Microphone Mute" (in apps that support "Call Mute")' )
 // e.g.  AddLine( '<WindowsKey + Alt + PrtScn>       ; Save screenshot of game window in focus to file (using Xbox Game Bar).' )
 // e.g.  AddLine( '<WindowsKey + Alt + R>            ; Record a video of the game window in focus (using XBox Game Bar)' )
 // e.g.  AddLine( '<WindowsKey + ArrowDown>          ; Remove current app from screen or minimize the desktop window.' )
 // e.g.  AddLine( '<WindowsKey + ArrowLeft>          ; Maximize the app or desktop window to the left side of the screen' )
 // e.g.  AddLine( '<WindowsKey + ArrowRight>         ; Maximize the app or desktop window to the right side of the screen.' )
 // e.g.  AddLine( '<WindowsKey + ArrowUp>            ; Maximize the window.' )
 // e.g.  AddLine( '<WindowsKey + B>                  ; Set the focus to the first icon on the taskbar corner' )
 // e.g.  AddLine( '<WindowsKey + C>                  ; Show "Chat" from Microsoft Teams (Cortana)' )
 // e.g.  AddLine( '<WindowsKey + Ctrl + 1>           ; Open the desktop and switch to the last active window of the app pinned to the taskbar in the position indicated by the number 1.' )
 // e.g.  AddLine( '<WindowsKey + Ctrl + 2>           ; Open the desktop and switch to the last active window of the app pinned to the taskbar in the position indicated by the number 2.' )
 // e.g.  AddLine( '<WindowsKey + Ctrl + 3>           ; Open the desktop and switch to the last active window of the app pinned to the taskbar in the position indicated by the number 3.' )
 // e.g.  AddLine( '<WindowsKey + Ctrl + 4>           ; Open the desktop and switch to the last active window of the app pinned to the taskbar in the position indicated by the number 4.' )
 // e.g.  AddLine( '<WindowsKey + Ctrl + 5>           ; Open the desktop and switch to the last active window of the app pinned to the taskbar in the position indicated by the number 5.' )
 // e.g.  AddLine( '<WindowsKey + Ctrl + 6>           ; Open the desktop and switch to the last active window of the app pinned to the taskbar in the position indicated by the number 6.' )
 // e.g.  AddLine( '<WindowsKey + Ctrl + 7>           ; Open the desktop and switch to the last active window of the app pinned to the taskbar in the position indicated by the number 7.' )
 // e.g.  AddLine( '<WindowsKey + Ctrl + 8>           ; Open the desktop and switch to the last active window of the app pinned to the taskbar in the position indicated by the number 8.' )
 // e.g.  AddLine( '<WindowsKey + Ctrl + 9>           ; Open the desktop and switch to the last active window of the app pinned to the taskbar in the position indicated by the number 9.' )
 // e.g.  AddLine( '<WindowsKey + Ctrl + ArrowDown>   ;' )
 // e.g.  AddLine( '<WindowsKey + Ctrl + ArrowLeft>   ; Switch between virtual desktops you have created on the left.' )
 // e.g.  AddLine( '<WindowsKey + Ctrl + ArrowRight>  ; Switch between virtual desktops you have created on the right.' )
 // e.g.  AddLine( '<WindowsKey + Ctrl + ArrowUp>     ;' )
 // e.g.  AddLine( '<WindowsKey + Ctrl + C>           ; Turn on color filters (you must enable this shortcut first in "Color Filter Settings")' )
 // e.g.  AddLine( '<WindowsKey + Ctrl + D>           ; Add a virtual desktop' )
 // e.g.  AddLine( '<WindowsKey + Ctrl + Enter>       ; Turn on "Narrator' )
 // e.g.  AddLine( '<WindowsKey + Ctrl + F4>          ; Close the virtual desktop you are using.' )
 // e.g.  AddLine( '<WindowsKey + Ctrl + F>           ; Search for PCs (if you are on a network' )
 // e.g.  AddLine( '<WindowsKey + Ctrl + Q>           ; Show "Quick Assist" menu' )
 // e.g.  AddLine( '<WindowsKey + Ctrl + Shift + 1>   ; Open the desktop and open a new instance of the app located at the given position 1 on the taskbar as an administrator.' )
 // e.g.  AddLine( '<WindowsKey + Ctrl + Shift + 2>   ; Open the desktop and open a new instance of the app located at the given position 2 on the taskbar as an administrator.' )
 // e.g.  AddLine( '<WindowsKey + Ctrl + Shift + 3>   ; Open the desktop and open a new instance of the app located at the given position 3 on the taskbar as an administrator.' )
 // e.g.  AddLine( '<WindowsKey + Ctrl + Shift + 4>   ; Open the desktop and open a new instance of the app located at the given position 4 on the taskbar as an administrator.' )
 // e.g.  AddLine( '<WindowsKey + Ctrl + Shift + 5>   ; Open the desktop and open a new instance of the app located at the given position 5 on the taskbar as an administrator.' )
 // e.g.  AddLine( '<WindowsKey + Ctrl + Shift + 6>   ; Open the desktop and open a new instance of the app located at the given position 6 on the taskbar as an administrator.' )
 // e.g.  AddLine( '<WindowsKey + Ctrl + Shift + 7>   ; Open the desktop and open a new instance of the app located at the given position 7 on the taskbar as an administrator.' )
 // e.g.  AddLine( '<WindowsKey + Ctrl + Shift + 8>   ; Open the desktop and open a new instance of the app located at the given position 8 on the taskbar as an administrator.' )
 // e.g.  AddLine( '<WindowsKey + Ctrl + Shift + 9>   ; Open the desktop and open a new instance of the app located at the given position 9 on the taskbar as an administrator.' )
 // e.g.  AddLine( '<WindowsKey + Ctrl + Shift + B>   ; Wake PC from blank or black screen.' )
 // e.g.  AddLine( '<WindowsKey + Ctrl + Spacebar>    ; Change to a previously selected input.' )
 // e.g.  AddLine( '<WindowsKey + D>                  ; Toggle between show and hide the desktop' )
 // e.g.  AddLine( '<WindowsKey + E>                  ; Show Microsoft Explorer' )
 // e.g.  AddLine( '<WindowsKey + Enter>              ; Show the "Narrator" menu' )
 // e.g.  AddLine( '<WindowsKey + Escape>             ; Close Magnifier.' )
 // e.g.  AddLine( '<WindowsKey + F>                  ; Show "Feedback Hub" window and take a screenshot' )
 // e.g.  AddLine( '<WindowsKey + G>                  ; Show "Video Capture" menu (=record a screencast .mp4 (e.g. demonstration) video) + "Audio sound" menu + "CPU / GPU / RAM / VRAM / FPS Performance" + "Spotify" menu.' )
 // e.g.  AddLine( '<WindowsKey + H>                  ; Show "Voice Typing" menu' )
 // e.g.  AddLine( '<WindowsKey + Home>               ; Minimize all except the active desktop window (restores all windows on second stroke).' )
 // e.g.  AddLine( '<WindowsKey + I>                  ; Show "Settings" menu' )
 // e.g.  AddLine( '<WindowsKey + J>                  ; Show focus on a "Windows Tip" (when one is available)' )
 // e.g.  AddLine( '<WindowsKey + K>                  ; Show "BlueTooth" menu (e.g. for changing the BlueTooth earbuds you use on the computer) on the right side of the screen' )
 // e.g.  AddLine( '<WindowsKey + L>                  ; Lock your computer or switch accounts' )
 // e.g.  AddLine( '<WindowsKey + M>                  ; Minimize all windows on the desktop' )
 // e.g.  AddLine( '<WindowsKey + N>                  ; Show "Notifications" and "Calendar" (only in Microsoft Windows 11)' )
 // e.g.  AddLine( '<WindowsKey + O>                  ; Lock device orientation (seems not to work in Microsoft Windows 10)' )
 // e.g.  AddLine( '<WindowsKey + P>                  ; Show "Monitor Display" menu on the right side of the screen' )
 // e.g.  AddLine( '<WindowsKey + Pause>              ; Temporarily peek at the desktop' )
 // e.g.  AddLine( '<WindowsKey + PrtScn>             ; Save full screen screenshot to file' )
 // e.g.  AddLine( '<WindowsKey + R>                  ; Show "Run" box' )
 // e.g.  AddLine( '<WindowsKey + S>                  ; Show "Search" box' )
 // e.g.  AddLine( '<WindowsKey + Shift + 1>          ; Open the desktop and start a new instance of the app pinned to the taskbar in the position indicated by the number 1.' )
 // e.g.  AddLine( '<WindowsKey + Shift + 2>          ; Open the desktop and start a new instance of the app pinned to the taskbar in the position indicated by the number 2.' )
 // e.g.  AddLine( '<WindowsKey + Shift + 3>          ; Open the desktop and start a new instance of the app pinned to the taskbar in the position indicated by the number 3.' )
 // e.g.  AddLine( '<WindowsKey + Shift + 4>          ; Open the desktop and start a new instance of the app pinned to the taskbar in the position indicated by the number 4.' )
 // e.g.  AddLine( '<WindowsKey + Shift + 5>          ; Open the desktop and start a new instance of the app pinned to the taskbar in the position indicated by the number 5.' )
 // e.g.  AddLine( '<WindowsKey + Shift + 6>          ; Open the desktop and start a new instance of the app pinned to the taskbar in the position indicated by the number 6.' )
 // e.g.  AddLine( '<WindowsKey + Shift + 7>          ; Open the desktop and start a new instance of the app pinned to the taskbar in the position indicated by the number 7.' )
 // e.g.  AddLine( '<WindowsKey + Shift + 8>          ; Open the desktop and start a new instance of the app pinned to the taskbar in the position indicated by the number 8.' )
 // e.g.  AddLine( '<WindowsKey + Shift + 9>          ; Open the desktop and start a new instance of the app pinned to the taskbar in the position indicated by the number 9.' )
 // e.g.  AddLine( '<WindowsKey + Shift + ArrowDown>  ; Restore/minimize active desktop windows vertically, maintaining width.' )
 // e.g.  AddLine( '<WindowsKey + Shift + ArrowLeft>  ; Move an app or window in the desktop from one monitor left to another.' )
 // e.g.  AddLine( '<WindowsKey + Shift + ArrowRight> ; Move an app or window in the desktop from one monitor right to another.' )
 // e.g.  AddLine( '<WindowsKey + Shift + ArrowUp>    ; Stretch the desktop window to the top and bottom of the screen.' )
 // e.g.  AddLine( '<WindowsKey + Shift + C>          ; Show the "Charms" menu' )
 // e.g.  AddLine( '<WindowsKey + Shift + M>          ; Restore minimized windows on the desktop' )
 // e.g.  AddLine( '<WindowsKey + Shift + S>          ; Take a screenshot of part of your screen' )
 // e.g.  AddLine( '<WindowsKey + Shift + Spacbar>    ; Cycle backwards through language and keyboard layout.' )
 // e.g.  AddLine( '<WindowsKey + Shift + V>          ; Set the focus to a notification' )
 // e.g.  AddLine( '<WindowsKey + Spacebar            ; Switch input language and keyboard layout.' )
 // e.g.  AddLine( '<WindowsKey + T>                  ; Cycle through the apps on the Microsoft Windows taskbar' )
 // e.g.  AddLine( '<WindowsKey + Tab>                ; Show the "Activity History" menu' )
 // e.g.  AddLine( '<WindowsKey + U>                  ; Show the "Accessibility" menu' )
 // e.g.  AddLine( '<WindowsKey + V>                  ; Show the "Clipboard History" menu (must be enabled first in the settings)' )
 // e.g.  AddLine( '<WindowsKey + W>                  ; Show the "Widgets" menu' )
 // e.g.  AddLine( '<WindowsKey + X>                  ; Show the "Quick Link" menu (=the "window" icon in the left bottom of the screen)' )
 // e.g.  AddLine( '<WindowsKey + Y>                  ; Switch input between Microsoft Windows "Mixed Reality" and your desktop (does not work in Microsoft Windows 10' )
 // e.g.  AddLine( '<WindowsKey + Z>                  ; Show the "Snap" layouts (does not work in Microsoft Windows 10' )
 // e.g.  AddLine( '<WindowsKey>                      ; Show or hide the "Start" menu' )
 // e.g.  //
 // e.g.  GotoLine( 1 )
 // e.g.  // IF List( "Choose an option", 80 )
 // e.g.  IF eList( "Choose an option" )
 // e.g.   s1 = Trim( GetText( 1, 255 ) )
 // e.g.  ELSE
 // e.g.   AbandonFile( bufferI )
 // e.g.   PopBlock()
 // e.g.   PopPosition()
 // e.g.   RETURN()
 // e.g.  ENDIF
 // e.g.  AbandonFile( bufferI )
 // e.g.  PopBlock()
 // e.g.  PopPosition()
 // e.g.  //
 // e.g.  // do something with s1
 // e.g.  //
 // e.g.  s1 = GetToken( s1, ";", 1 )
 // e.g.  s1 = Trim( s1 )
 // e.g.  //
 // e.g.  Message( FNProgramRunKeyShortcutAutohotkeyCaseAllB( s1 ) ) // gives e.g. TRUE
 // e.g. END
 // e.g. //
 // e.g. <F12> ExecMacro( "windowskeyall" )
 //
 // ===
 //
 // Use case =
 //
 // ===
 //
 // ===
 //
 // Method =
 //
 // ===
 //
 // ===
 //
 // Example:
 //
 // Input:
 //
 /*
--- cut here: begin --------------------------------------------------
--- cut here: end ----------------------------------------------------
 */
 //
 // Output:
 //
 /*
--- cut here: begin --------------------------------------------------
--- cut here: end ----------------------------------------------------
 */
 //
 // ===
 //
 // e.g. // QuickHelp( HELPDEFFNProgramRunKeyShorthcutAutohotkeyCaseAllB )
 // e.g. HELPDEF HELPDEFFNProgramRunKeyShorthcutAutohotkeyCaseAllB
 // e.g.  title = "FNProgramRunKeyShortcutAutohotkeyCaseAllB( s1 ) help" // The help's caption
 // e.g.  x = 100 // Location
 // e.g.  y = 3 // Location
 // e.g.  //
 // e.g.  // The actual help text
 // e.g.  //
 // e.g.  "Usage:"
 // e.g.  "//"
 // e.g.  "1. Run this TSE macro"
 // e.g.  "2. Then press <CtrlAlt F1> to show this help."
 // e.g.  "3. Press <Shift Escape> to quit."
 // e.g.  "//"
 // e.g.  ""
 // e.g.  "Key: Definitions:"
 // e.g.  ""
 // e.g.  "<> = do something"
 // e.g. END
 //
 INTEGER B = FALSE
 //
 STRING outputFileNameS[255] = "c:\temp\ddd.ahk" // change this
 //
 PushPosition()
 PushBlock()
 //
 PushPosition()
 PushBlock()
 EraseDiskFile( outputFileNameS )
 IF EditFile( outputFileNameS )
  AbandonFile()
 ENDIF
 PopBlock()
 PopPosition()
 //
 EditFile( outputFileNameS )
 //
 CASE caseS
  //
  // See also: https://www.autohotkey.com/docs/v1/KeyList.htm#mouse-general
  //
  WHEN "<WindowsKey + +>"                                   AddLine( "Send, {LWin down}{+}{LWin up}" )
  WHEN "<WindowsKey + ,>"                                   AddLine( "Send, {LWin down}{,}{LWin up}" )
  WHEN "<WindowsKey + ->"                                   AddLine( "Send, {LWin down}{-}{LWin up}" )
  WHEN "<WindowsKey + .>"                                   AddLine( "Send, {LWin down}{.}{LWin up}" )
  WHEN "<WindowsKey + />"                                   AddLine( "Send, {LWin down}{/}{LWin up}" )
  WHEN "<WindowsKey + 1>"                                   AddLine( "Send, {LWin down}1{LWin up}" )
  WHEN "<WindowsKey + 2>"                                   AddLine( "Send, {LWin down}2{LWin up}" )
  WHEN "<WindowsKey + 3>"                                   AddLine( "Send, {LWin down}3{LWin up}" )
  WHEN "<WindowsKey + 4>"                                   AddLine( "Send, {LWin down}4{LWin up}" )
  WHEN "<WindowsKey + 5>"                                   AddLine( "Send, {LWin down}5{LWin up}" )
  WHEN "<WindowsKey + 6>"                                   AddLine( "Send, {LWin down}6{LWin up}" )
  WHEN "<WindowsKey + 7>"                                   AddLine( "Send, {LWin down}7{LWin up}" )
  WHEN "<WindowsKey + 8>"                                   AddLine( "Send, {LWin down}8{LWin up}" )
  WHEN "<WindowsKey + 9>"                                   AddLine( "Send, {LWin down}9{LWin up}" )
  WHEN "<WindowsKey + ;>"                                   AddLine( "Send, {LWin down};{LWin up}" )
  WHEN "<WindowsKey + A>"                                   AddLine( "Send, {LWin down}a{LWin up}" )
  WHEN "<WindowsKey + Alt + 1>"                             AddLine( "Send, {LWin down}!1{LWin up}" )
  WHEN "<WindowsKey + Alt + 2>"                             AddLine( "Send, {LWin down}!2{LWin up}" )
  WHEN "<WindowsKey + Alt + 3>"                             AddLine( "Send, {LWin down}!3{LWin up}" )
  WHEN "<WindowsKey + Alt + 4>"                             AddLine( "Send, {LWin down}!4{LWin up}" )
  WHEN "<WindowsKey + Alt + 5>"                             AddLine( "Send, {LWin down}!5{LWin up}" )
  WHEN "<WindowsKey + Alt + 6>"                             AddLine( "Send, {LWin down}!6{LWin up}" )
  WHEN "<WindowsKey + Alt + 7>"                             AddLine( "Send, {LWin down}!7{LWin up}" )
  WHEN "<WindowsKey + Alt + 8>"                             AddLine( "Send, {LWin down}!8{LWin up}" )
  WHEN "<WindowsKey + Alt + 9>"                             AddLine( "Send, {LWin down}!9{LWin up}" )
  WHEN "<WindowsKey + Alt + ArrowDown>"                     AddLine( "Send, {LWin down}!{Down}{LWin up}" )
  WHEN "<WindowsKey + Alt + ArrowLeft>"                     AddLine( "Send, {LWin down}!{Left}{LWin up}" )
  WHEN "<WindowsKey + Alt + ArrowRight>"                    AddLine( "Send, {LWin down}!{Right}{LWin up}" )
  WHEN "<WindowsKey + Alt + ArrowUp>"                       AddLine( "Send, {LWin down}!{Up}{LWin up}" )
  WHEN "<WindowsKey + Alt + B>"                             AddLine( "Send, {LWin down}!b{LWin up}" )
  WHEN "<WindowsKey + Alt + Enter>"                         AddLine( "Send, {LWin down}!{Enter}{LWin up}" )
  WHEN "<WindowsKey + Alt + K>"                             AddLine( "Send, {LWin down}!k{LWin up}" )
  WHEN "<WindowsKey + Alt + PrtScn>"                        AddLine( "Send, {LWin down}!{PrintScreen}{LWin up}" )
  WHEN "<WindowsKey + Alt + R>"                             AddLine( "Send, {LWin down}!r{LWin up}" )
  WHEN "<WindowsKey + ArrowDown>"                           AddLine( "Send, {LWin down}{Down}{LWin up}" )
  WHEN "<WindowsKey + ArrowLeft>"                           AddLine( "Send, {LWin down}{Left}{LWin up}" )
  WHEN "<WindowsKey + ArrowRight>"                          AddLine( "Send, {LWin down}{Right}{LWin up}" )
  WHEN "<WindowsKey + ArrowUp>"                             AddLine( "Send, {LWin down}{Up}{LWin up}" )
  WHEN "<WindowsKey + B>"                                   AddLine( "Send, {LWin down}b{LWin up}" )
  WHEN "<WindowsKey + C>"                                   AddLine( "Send, {LWin down}c{LWin up}" )
  WHEN "<WindowsKey + Ctrl + 1>"                            AddLine( "Send, {LWin down}^1{LWin up}" )
  WHEN "<WindowsKey + Ctrl + 2>"                            AddLine( "Send, {LWin down}^2{LWin up}" )
  WHEN "<WindowsKey + Ctrl + 3>"                            AddLine( "Send, {LWin down}^3{LWin up}" )
  WHEN "<WindowsKey + Ctrl + 4>"                            AddLine( "Send, {LWin down}^4{LWin up}" )
  WHEN "<WindowsKey + Ctrl + 5>"                            AddLine( "Send, {LWin down}^5{LWin up}" )
  WHEN "<WindowsKey + Ctrl + 6>"                            AddLine( "Send, {LWin down}^6{LWin up}" )
  WHEN "<WindowsKey + Ctrl + 7>"                            AddLine( "Send, {LWin down}^7{LWin up}" )
  WHEN "<WindowsKey + Ctrl + 8>"                            AddLine( "Send, {LWin down}^8{LWin up}" )
  WHEN "<WindowsKey + Ctrl + 9>"                            AddLine( "Send, {LWin down}^9{LWin up}" )
  WHEN "<WindowsKey + Ctrl + ArrowDown>"                    AddLine( "Send, {LWin down}^{Down}{LWin up}" )
  WHEN "<WindowsKey + Ctrl + ArrowLeft>"                    AddLine( "Send, {LWin down}^{Left}{LWin up}" )
  WHEN "<WindowsKey + Ctrl + ArrowRight>"                   AddLine( "Send, {LWin down}^{Right}{LWin up}" )
  WHEN "<WindowsKey + Ctrl + ArrowUp>"                      AddLine( "Send, {LWin down}^{Up}{LWin up}" )
  WHEN "<WindowsKey + Ctrl + C>"                            AddLine( "Send, {LWin down}^c{LWin up}" )
  WHEN "<WindowsKey + Ctrl + D>"                            AddLine( "Send, {LWin down}^d{LWin up}" )
  WHEN "<WindowsKey + Ctrl + Enter>"                        AddLine( "Send, {LWin down}^{Enter}{LWin up}" )
  WHEN "<WindowsKey + Ctrl + F>"                            AddLine( "Send, {LWin down}^f{LWin up}" )
  WHEN "<WindowsKey + Ctrl + F4>"                           AddLine( "Send, {LWin down}^{F4}{LWin up}" )
  WHEN "<WindowsKey + Ctrl + Q>"                            AddLine( "Send, {LWin down}^q{LWin up}" )
  WHEN "<WindowsKey + Ctrl + Shift + 1>"                    AddLine( "Send, {LWin down}^+1{LWin up}" )
  WHEN "<WindowsKey + Ctrl + Shift + 2>"                    AddLine( "Send, {LWin down}^+2{LWin up}" )
  WHEN "<WindowsKey + Ctrl + Shift + 3>"                    AddLine( "Send, {LWin down}^+3{LWin up}" )
  WHEN "<WindowsKey + Ctrl + Shift + 4>"                    AddLine( "Send, {LWin down}^+4{LWin up}" )
  WHEN "<WindowsKey + Ctrl + Shift + 5>"                    AddLine( "Send, {LWin down}^+5{LWin up}" )
  WHEN "<WindowsKey + Ctrl + Shift + 6>"                    AddLine( "Send, {LWin down}^+6{LWin up}" )
  WHEN "<WindowsKey + Ctrl + Shift + 7>"                    AddLine( "Send, {LWin down}^+7{LWin up}" )
  WHEN "<WindowsKey + Ctrl + Shift + 8>"                    AddLine( "Send, {LWin down}^+8{LWin up}" )
  WHEN "<WindowsKey + Ctrl + Shift + 9>"                    AddLine( "Send, {LWin down}^+9{LWin up}" )
  WHEN "<WindowsKey + Ctrl + Shift + B>"                    AddLine( "Send, {LWin down}^+b{LWin up}" )
  WHEN "<WindowsKey + Ctrl + Spacebar>"                     AddLine( "Send, {LWin down}^{Space}{LWin up}" )
  WHEN "<WindowsKey + D>"                                   AddLine( "Send, {LWin down}d{LWin up}" )
  WHEN "<WindowsKey + E>"                                   AddLine( "Send, {LWin down}e{LWin up}" )
  WHEN "<WindowsKey + Enter>"                               AddLine( "Send, {LWin down}{Enter}{LWin up}" )
  WHEN "<WindowsKey + Escape>"                              AddLine( "Send, {LWin down}{Esc}{LWin up}" )
  WHEN "<WindowsKey + F>"                                   AddLine( "Send, {LWin down}f{LWin up}" )
  WHEN "<WindowsKey + G>"                                   AddLine( "Send, {LWin down}g{LWin up}" )
  WHEN "<WindowsKey + H>"                                   AddLine( "Send, {LWin down}h{LWin up}" )
  WHEN "<WindowsKey + Home>"                                AddLine( "Send, {LWin down}{Home}{LWin up}" )
  WHEN "<WindowsKey + I>"                                   AddLine( "Send, {LWin down}i{LWin up}" )
  WHEN "<WindowsKey + J>"                                   AddLine( "Send, {LWin down}j{LWin up}" )
  WHEN "<WindowsKey + K>"                                   AddLine( "Send, {LWin down}k{LWin up}" )
  WHEN "<WindowsKey + L>"                                   AddLine( "Send, {LWin down}l{LWin up}" )
  WHEN "<WindowsKey + M>"                                   AddLine( "Send, {LWin down}m{LWin up}" )
  WHEN "<WindowsKey + N>"                                   AddLine( "Send, {LWin down}n{LWin up}" )
  WHEN "<WindowsKey + O>"                                   AddLine( "Send, {LWin down}o{LWin up}" )
  WHEN "<WindowsKey + P>"                                   AddLine( "Send, {LWin down}p{LWin up}" )
  WHEN "<WindowsKey + Pause>"                               AddLine( "Send, {LWin down}{Pause}{LWin up}" )
  WHEN "<WindowsKey + PrtScn>"                              AddLine( "Send, {LWin down}{PrintScreen}{LWin up}" )
  WHEN "<WindowsKey + R>"                                   AddLine( "Send, {LWin down}r{LWin up}" )
  WHEN "<WindowsKey + S>"                                   AddLine( "Send, {LWin down}s{LWin up}" )
  WHEN "<WindowsKey + Shift + 1>"                           AddLine( "Send, {LWin down}+1{LWin up}" )
  WHEN "<WindowsKey + Shift + 2>"                           AddLine( "Send, {LWin down}+2{LWin up}" )
  WHEN "<WindowsKey + Shift + 3>"                           AddLine( "Send, {LWin down}+3{LWin up}" )
  WHEN "<WindowsKey + Shift + 4>"                           AddLine( "Send, {LWin down}+4{LWin up}" )
  WHEN "<WindowsKey + Shift + 5>"                           AddLine( "Send, {LWin down}+5{LWin up}" )
  WHEN "<WindowsKey + Shift + 6>"                           AddLine( "Send, {LWin down}+6{LWin up}" )
  WHEN "<WindowsKey + Shift + 7>"                           AddLine( "Send, {LWin down}+7{LWin up}" )
  WHEN "<WindowsKey + Shift + 8>"                           AddLine( "Send, {LWin down}+8{LWin up}" )
  WHEN "<WindowsKey + Shift + 9>"                           AddLine( "Send, {LWin down}+9{LWin up}" )
  WHEN "<WindowsKey + Shift + ArrowDown>"                   AddLine( "Send, {LWin down}+{Down}{LWin up}" )
  WHEN "<WindowsKey + Shift + ArrowLeft>"                   AddLine( "Send, {LWin down}+{Left}{LWin up}" )
  WHEN "<WindowsKey + Shift + ArrowRight>"                  AddLine( "Send, {LWin down}+{Right}{LWin up}" )
  WHEN "<WindowsKey + Shift + ArrowUp>"                     AddLine( "Send, {LWin down}+{Up}{LWin up}" )
  WHEN "<WindowsKey + Shift + C>"                           AddLine( "Send, {LWin down}+c{LWin up}" )
  WHEN "<WindowsKey + Shift + M>"                           AddLine( "Send, {LWin down}+m{LWin up}" )
  WHEN "<WindowsKey + Shift + S>"                           AddLine( "Send, {LWin down}+s{LWin up}" )
  WHEN "<WindowsKey + Shift + Spacebar>"                    AddLine( "Send, {LWin down}+{Space}{LWin up}" )
  WHEN "<WindowsKey + Shift + V>"                           AddLine( "Send, {LWin down}+v{LWin up}" )
  WHEN "<WindowsKey + Spacebar>"                            AddLine( "Send, {LWin down}{Space}{LWin up}" )
  WHEN "<WindowsKey + T>"                                   AddLine( "Send, {LWin down}+t{LWin up}" )
  WHEN "<WindowsKey + Tab>"                                 AddLine( "Send, {LWin down}{Tab}{LWin up}" )
  WHEN "<WindowsKey + U>"                                   AddLine( "Send, {LWin down}u{LWin up}" )
  WHEN "<WindowsKey + V>"                                   AddLine( "Send, {LWin down}v{LWin up}" )
  WHEN "<WindowsKey + W>"                                   AddLine( "Send, {LWin down}w{LWin up}" )
  WHEN "<WindowsKey + X>"                                   AddLine( "Send, {LWin down}x{LWin up}" )
  WHEN "<WindowsKey + Y>"                                   AddLine( "Send, {LWin down}y{LWin up}" )
  WHEN "<WindowsKey + Z>"                                   AddLine( "Send, {LWin down}z{LWin up}" )
  WHEN "<WindowsKey>"                                       AddLine( "Send, {LWin down}{LWin up}" )
   //
  OTHERWISE
   //
   Warn( "FNProgramRunKeyShortcutAutohotkeyCaseAllB(", " ", "case", " ", ":", " ", caseS, ": not known" )
   //
   B = FALSE
   //
   RETURN( B )
   //
 ENDCASE
 //
 SaveAs( outputFileNameS, _OVERWRITE_ )
 //
 // PROCFileRun4NtAliasCommandListUser( Format( "autohotkey", " ", QuotePath( outputFileNameS ) ) )
 Dos( Format( "g:\macrorecorder\autohotkey\autohotkey.exe", " ", QuotePath( outputFileNameS ) ), _START_HIDDEN_ ) // you will have to supply the full path to the autohotkey executable
 //
 B = TRUE
 //
 IF EditFile( outputFileNameS )
  AbandonFile()
 ENDIF
 //
 PopBlock()
 PopPosition()
 //
 RETURN( B )
 //
END
