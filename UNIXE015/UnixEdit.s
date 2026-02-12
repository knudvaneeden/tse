
/*

UnixEdit.s


    UnixEdit - Edit files on a Unix Filesystem via your Windows copy of TSE.

    v0.1.5 - Jun 19, 2002

    
    Copyright (c) 2002 - Michael Graham <magmac@occamstoothbrush.com>

    This program is Free Software - you may use it, modify it and
    distribute it under the the terms of the Perl Artistic License,
    which you may find at:

          http://www.perl.com/CPAN/doc/misc/license/Artistic

    In particular, note that you use this software at your own risk!

    The latest version of my TSE macros can be found at:

        http://www.occamstoothbrush.com/tsemac/



*/


#ifndef MAX_PATH
#define MAX_PATH 255
#endif

string Watch_Directory[MAX_PATH] = 'w:\autoedit'
string Watch_File[MAX_PATH]      = 'editfile'
string Watch_Path[MAX_PATH]      = ''
integer Watch_Buffer

// Scratch string variable used by many functions
string File_Name[MAX_PATH]       = ''


// Thanks to Rick VanNorman's onlyone.s macro for
// these dll functions

dll "<user32.dll>"

    integer proc GetForegroundWindow(
    ) : "GetForegroundWindow"

    integer proc SetForegroundWindow(
           integer handle
    ) : "SetForegroundWindow"

    integer proc BringWindowToTop(
            integer handle
    ) : "BringWindowToTop"

end

// watcher:
//
// [ hooked to _IDLE_ ]
//
// watcher keeps an eye on the Watch_File.
// When it changes, it reads the file
// to find the name of the file to edit.
//
// Then, it edits the file, and empties the Watch_File.

proc watcher ()
    integer window_handle
    integer file_handle = fOpen(Watch_Path)

    if file_handle <> -1

        window_handle = GetForegroundWindow()
        SetForeGroundWindow(GetWinHandle())
        BringWindowToTop(GetWinHandle())
        SetForeGroundWindow(GetWinHandle())

        PushPosition()

        GotoBufferId(Watch_Buffer)
        EmptyBuffer()
        fReadFile(file_handle)
        BegFile()

        File_Name = GetText(1, CurrLineLen())

        fClose(file_handle)

        EraseDiskFile(Watch_Path)


        if EditFile(Watch_Directory + File_Name)
            SetBufferInt('AutoEdit::Original_Foreground_Window', window_handle)
            SetBufferInt('AutoEdit::Is_Watched_File', 1)
            KillPosition()
        else
            SetForeGroundWindow(window_handle)
            PopPosition()
            Warn("Could not edit remote file: " + File_Name)
        endif
    endif
end

// after_save_handler:
//
// [ hooked to _AFTER_FILE_SAVE_ ]
//
// before_saved_handler checks to see if the file that
// was just saved is a Watched File.
//
// If so, then it saves a control file in the same directory
// named filename.saved
//
// It also returns focus to the window that was active
// when the file first appeared.

proc after_save_handler ()
    // integer file_handle
    if ExistBufferVar('AutoEdit::Is_Watched_File')
        if EditFile(CurrFileName() + '.saved')
            InsertText('Ok')
            SaveFile()
            QuitFile()
            SetForegroundWindow(GetBufferInt('AutoEdit::Original_Foreground_Window'))
        endif
    endif
end

proc whenloaded ()
     PushPosition()
     Watch_Buffer = CreateTempBuffer()
     PopPosition()

     Watch_Directory = AddTrailingSlash(Watch_Directory)
     Watch_Path      = Watch_Directory + Watch_File

     Hook(_IDLE_, watcher)
     Hook(_AFTER_FILE_SAVE_, after_save_handler)
end



