// START.S  Source code for macro for TSE and Tapcis v. 6.0
//
// Original file by George J. De Bruin, Semware Support, 5/27/95
// Modified by Guy Simpson, 5/27/95
//
// For anyone using The Semware Editor (TSE), here is a macro that I call
// "START.S" in the text form and "START.MAC" in compiled form that will
// allow you to open two windows and place the cursor in the second window
// for replying to a message.  This is a tweak of a macro that I received
// from George De Bruin at SemWare Technical Support.
//
// (The initial procedure seems a bit klutzy, I know, but I couldn't get the
// results that I wanted -- being in the second window with the message
// being replied to in the first window -- without these steps.  If anyone
// wants to tweak on it further and repost it, feel free.)
//
// If you want template expansion turned on (for using predefined signatures
// and/or taglines to your messages with TAPCIS ONLY) add the following line
// just before the "end" in the second procedure:
//
//   ExecMacro("Template")              // Load the Template Macro
//
// If you want Template expansion on at all times, simply add Template to
// the AUTOLOAD List available on the Macro Menu (near the bottom).
//
// INSTRUCTIONS:
//
// 1.  Place this file in the \TSE\MAC\SOURCE directory.
//
// 2.  Load the file into TSE and make any changes you require.
//
// 3.  Save the file!
//
// 4.  Exit TSE and compile the file externally using the following command:
//
//        \TSE\SC \tse\mac\source\start.s \tse\mac\start.mac
//
//     This will compile the macro and place the compiled version in the
//     proper location for use.
//
// 5.  Change the External Editor section of TAPCIS 6.0 so the reply line
//     reads as follows:
//
//        e root~.tmp editor~.tmp -estart
//
//     This will allow you to reply to messages automatically by simply
//     pressing the "R" key while reading in T6.

proc OnFirstEdit()
     HWindow()                          // Split the window
     NextFile()                         // Go to the next file
     GotoWindow(1)                      // Back to the original window
     PrevFile()                         // Back to the original file
     GotoWindow(2)                      // Place cursor in Reply window
     UnHook(OnFirstEdit)                // Never execute this hook again!
end

proc WhenLoaded()
     Hook(_ON_FIRST_EDIT_, OnFirstEdit) // Set up the proper hook
     PushKey(<Alt N>)                   // Do a NextFile() command
end

