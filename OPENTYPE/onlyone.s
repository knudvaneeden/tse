/****************************************************************************
 * OnlyOne -- force only a single copy of TSE to run in a Win32 system.     *
 * When a file is opened with TSE and it is already running, then the       *
 * existing copy of TSE is brought to the foreground, and it edits the file *
 *                                                                          *
 * Optionally, the instance of TSE that is originally called can wait       *
 * hidden in the background until the file is quit.  To the calling         *
 * application it will appear as if TSE itself exits when you quit this     *
 * file.  This behaviour is useful for some programs that use termination   *
 * of the editor as indication that you are finished editing the file.      *
 *                                                                          *
 * Optionally, onlyone can force TSE to autosave all files when the window  *
 * focus leaves TSE.                                                        *
 *                                                                          *
 * This is either loadable as a TSE AutoLoad macro (recommended) or bundled *
 * into the .UI file and burned into your User Interface.                   *
 *                                                                          *
 * (c) 1996, 1998 Rick VanNorman <rick@neverslow.com>                       *
 * Updated by Michael Graham <magmac@occamstoothbrush.com>:                 *
 *     - Win98/Win2K support                                                *
 *     - make calling app wait for file quit (and variations)               *
 *     - optionally return focus to calling app on file quit                *
 *                                                                          *
 * Use freely, please keep the copyright notice intact.                     *
 * The authors assume no responsibility for the use or misuse of this       *
 * software. Use at your own risk.                                          *
 *                                                                          *
 ****************************************************************************/

/* SAVE_FILES_ON_LOSING_FOCUS: set this to TRUE if you want
   this macro to save all files every time tse TSE window loses
   focus and another application comes to the foreground.
*/
#define SAVE_FILES_ON_LOSING_FOCUS FALSE

/* SHOW_TSE_WINDOW_RESTORED: set this to TRUE if you want
   this macro to force TSE's window into the Restored state
*/
#define SHOW_TSE_WINDOW_RESTORED FALSE

/* Set this to TRUE if you want to compile this on it's own and
   put it in TSE's autoload list.  Set it to FALSE if you want
   to #include it in your .UI file.  Note that if you decide
   to include it in your UI file, you will also have to place
   the following line in your WhenLoaded() function:
       onlyone()

*/
#define USE_AS_STANDALONE_MACRO TRUE

// Editfile flags - pick from these to choose default behaviour
constant FLAG_WAIT_FOR_FILE_QUIT    = 1
constant FLAG_WAIT_FOR_PARENT_FOCUS = 2
constant FLAG_RETURN_FOCUS          = 4
constant FLAG_PERSIST_HIDDEN        = 8

constant DEFAULT_CLIENT_SERVER_BEHAVIOUR = FLAG_WAIT_FOR_PARENT_FOCUS

//*************************************************************************

#define DEBUG_MODE FALSE

//*************************************************************************
// Import the necessary functions from Windows DLL's

dll "<user32.dll>"

integer proc ShowWindow(
    integer handle,
    integer flags
   ) : "ShowWindow"

integer proc SetForegroundWindow(
       integer handle
   ) : "SetForegroundWindow"

integer proc GetForegroundWindow(
   ) : "GetForegroundWindow"

integer proc SetWindowPos(
    integer handle,
    integer place,
    integer x,
    integer y,
    integer xs,
    integer yx,
    integer flags
   ) : "SetWindowPos"

integer proc BringWindowToTop(
    integer handle
   ) : "BringWindowToTop"

integer proc AllowSetForegroundWindow(
    integer handle
   ) : "AllowSetForegroundWindow"

integer proc SetActiveWindow(
    integer handle
   ) : "SetActiveWindow"

integer proc GetWindow(
    integer handle,
    integer relationship
   ) : "GetWindow"

integer proc GetWindowText(
    integer handle,
    integer lpstring,
    integer nmaxCount
   ) : "GetWindowTextA"

integer proc GetWindowTextLength(
    integer handle
   ) : "GetWindowTextLengthA"

end

dll "<kernel32.dll>"

integer proc CreateFileMapping(
    integer handle,
    integer security,
    integer protect,
    integer highsize,
    integer lowsize,
    string name : cstrval
   ) : "CreateFileMappingA"

integer proc OpenFileMapping(
    integer access,
    integer inherit,
    string name : cstrval
   ) : "OpenFileMappingA"

integer proc MapViewOfFile(
    integer handle,
    integer access,
    integer highadr,
    integer lowadr,
    integer size
   ) : "MapViewOfFile"

integer proc GetCurrentProcessId(
   ) : "GetCurrentProcessId"


end
//*************************************************************************

string TSEPro[]     = "TSE Pro-32"

// Windows Constants
constant GW_HWNDNEXT  = 2
constant GW_HWNDPREV  = 3
constant GW_HWNDFIRST = 0
constant GW_HWNDLAST  = 1

//
// MM_Name is the name of the filemapping
//

string MM_Name[] = "tse_mem"

string Switch_Char[1]                     = '+'
string Switch_Smart_Wait_For_File_Quit[1] = 'w'
string Switch_Return_Focus[1]             = 'f'
string Switch_Persist_Hidden[1]           = 'P'
string Switch_Wait_For_File_Quit[1]       = 'W'
string Switch_Return_Immediately[1]       = 'N'

integer MM_Handle  = 0   // handle of file mapping
integer MM_Address = 0   // address in our memory space of the file mapping

constant MSG_EDITFILES          = 1
constant MSG_FILES_QUIT         = 2
constant MSG_SERVER_TERMINATING = 3


integer ADDR_CLIENT_MESSAGE
integer ADDR_SERVER_MESSAGE
integer ADDR_MESSAGE_FLAGS
integer ADDR_SERVER_WINDOW_HANDLE
integer ADDR_CLIENT_PROCESS_ID
integer ADDR_CLIENT_WINDOW_HANDLE
integer ADDR_EDITFILE_DRIVE
integer ADDR_EDITFILE_PATH
integer ADDR_EDITFILE_COMMAND

integer This_Process_ID
integer This_Clients_Flags
integer Parent_Window
integer Waiting_For_Parent_Focus = FALSE

#if DEBUG_MODE
#else
integer This_Window_Hidden = 0
#endif

integer Client_ID_List_Buffer = 0
integer Client_Holding_Buffer = 0

/******************************************************************************

  Client/Server protocol details

  Message Area
  ============

  offset  bytes   sender     location name         description
  ------  ------  ------     -------------         -----------
  0       4       client     ADDR_CLIENT_MESSAGE   Location where client
                                                   places messages to be
                                                   read by server

  4       4       server     ADDR_SERVER_MESSAGE   Location where server
                                                   places messages to be
                                                   read by client

  8       4       either     ADDR_MESSAGE_FLAGS    Location where the server
                                                   or client can store
                                                   a set of flags to accompany
                                                   the message.

  Client Messages
  ===============

  message              meaning
  -------              -------
  LOAD_AND_RELEASE     load file specified in upper mem.
                       no need to record client info,
                       cos I'm outta here

  LOAD_AND_HOLD        load file specified in upper mem.
                       tell me when the user quits it

  Client Message Flags
  ====================

  flag                         description
  -------                      -----------
  FLAG_WAIT_FOR_FILE_QUIT      The client wants to be notified
                               when the file(s) it requested to be loaded
                               are quit by the user

  FLAG_WAIT_FOR_PARENT_FOCUS   The client will record the window of the
                               app that called it to have focus before
                               exiting

  FLAG_RETURN_FOCUS            Before the client exits, the server will
                               give focus to the client

  FLAG_PERSIST_HIDDEN          The client will never exit

  Server Messages
  ===============

  FILE_QUIT                    the user has exited the file you
                               asked me to load

  (In each case, when the receiver reads the message, it clears the
  sender's message bytes)

  Data Area
  =========

  offset  bytes    name                  description
  ------  ------   ----                  -----------
  8       4        SERVER_WINDOW_HANDLE  Process ID of the server process.
                                         This value is placed in the data
                                         area as soon as the server runs
                                         and is left there for all to
                                         read.  It is not associated with
                                         any message.


  12      30       (reserved)


  32      4        CLIENT_PROCESS_ID     Process ID of client process.
                                         Used by client in LOAD_AND_HOLD
                                         message, and by server in
                                         FILE_QUIT message

  32      96       (reserved)


  128     2        EDITFILE_DRIVE        String representing the drive letter
                                         current when a file is loaded
                                         used by LOAD_AND_RELEASE and
                                         LOAD_AND_HOLD messages

  130     257      EDITFILE_PATH         String representing the path
                                         current when a file is loaded
                                         used by LOAD_AND_RELEASE and
                                         LOAD_AND_HOLD messages

  387     257      EDITFILE_COMMAND      String representing the path
                                         current when a file is loaded
                                         used by LOAD_AND_RELEASE and
                                         LOAD_AND_HOLD messages

*****************************************************************************/

//
// create a mapping file. return a non-zero handle to it.  the
// particular "file" we open has r/w permissions and is 1024 bytes long.
//

integer proc CreateMappedMemory(string name)
    return(CreateFileMapping(-1, 0, 4, 0, 1024, name))
end

//
// try to open an existing mapping file. a non zero handle is returned
// if it exists, zero if it doesn't
//

integer proc OpenMappedMemory(string name)
    return(OpenFileMapping(6,0,name))
end

//
// figure where the file is mapped from its handle
//

integer proc AddressOfMappedMemory(integer handle)
    integer mem_address = MapViewOfFile(handle, 6, 0, 0, 0)

    if PeekLong(mem_address)
        Warn("Shared memory not available")
        AbandonEditor()
    endif
    return(mem_address)
end

// Once file-mapped memory is available, this routine
// sets up friendly names to point to various
// locations within the block

proc SetupMappedMemoryAddresses(integer base_address)
    ADDR_CLIENT_MESSAGE       = base_address + 0
    ADDR_SERVER_MESSAGE       = base_address + 4
    ADDR_MESSAGE_FLAGS        = base_address + 8
    ADDR_SERVER_WINDOW_HANDLE = base_address + 16
    ADDR_CLIENT_PROCESS_ID    = base_address + 32
    ADDR_CLIENT_WINDOW_HANDLE = base_address + 36
    ADDR_EDITFILE_DRIVE       = base_address + 128
    ADDR_EDITFILE_PATH        = base_address + 130
    ADDR_EDITFILE_COMMAND     = base_address + 387
end

//
// copy a string from AFROM to ATO
// the string at AFROM must to be well formed
// the memory at ATO must be large enough
//

proc strcpy(integer afrom, integer ato)
    integer i, len

    len = peekbyte(afrom)

    for i = 0 to len+1
        pokebyte(ato+i, peekbyte(afrom+i))
    endfor
end

string proc BufferName(integer b)
    string path[MAXSTRINGLEN] = ''
    if 0 BufferName(0) endif
    PushPosition()
    if GotoBufferId(b)
        path = CurrFileName()
    endif
    PopPosition()
    return(path)
end

proc Debug(string msg)
    if 0 Debug('') endif
    UpdateDisplay()
    Warn(msg)
end

// ------------------------------------------------------------------


// EditFilesAndRecordClient

// Some clients ask us (the server) to open a file, but they
// want to be notified when the file is quit.
// There are two challenges here:
//   1) Which files are edited
//   2) How to associate the client id with each new file


// 1) Which files are edited
// ----------------------
// This would be simple if editfile_cmd only ever contained the
// name of a single file.
//
// Unfortunately, editfile_cmd may contain wildcards or
// switches or even macros which may load other files.
//
// Therefore, the only way to see which files have been loaded
// by the EditFile() command is to take before and after snapshots
// of the ring of files.
//
// 2) How to associate the client id with each new file
// ----------------------------------------------------
// Maintain a buffer (client_list_buffer_id) which contains
// lines in the form:
//     client_id:buffer_id:client_window_handle:client_flags
//
// These are all numbers separated by colons, but note that some
// of these numbers can be negative, if they came directly from
// Windows.

// A limitation of the current system is that each file can only
// be associated with a single client.


proc EditFilesAndRecordClient(integer client_list_buffer_id, var string editfile_cmd, integer client_id, integer client_window, integer client_flags)

    integer n
    integer file_list_buffer
    integer buffer_id

    // If we are instructed to NOTIFY_ON_QUIT, we need
    // to mark each file loaded by EditFile() with the
    // process id of the Client that requested it.


    // debug('client_id: ' +str(client_id))

    file_list_buffer = CreateTempBuffer()

    if file_list_buffer

        SetHookState(OFF, _ON_CHANGING_FILES_)
        SetHookState(OFF, _ON_FIRST_EDIT_)

        PushPosition()

        n = NumFiles() + (BufferType() <> _NORMAL_)

        while n
            // debug('buffer: ' + BufferName(GetBufferId()))

            if BufferType() == _NORMAL_
                buffer_id = GetBufferId()
                GotoBufferId(file_list_buffer)
                AddLine(Str(buffer_id))
                // debug('added existing buffer: ' + BufferName(buffer_id) + ' [' + str(buffer_id) +']' )
                GotoBufferId(buffer_id)
            endif
            NextFile(_DONT_LOAD_)
            n = n - 1
        endwhile
        PopPosition()

        SetHookState(ON, _ON_CHANGING_FILES_)
        SetHookState(ON, _ON_FIRST_EDIT_)

        EditFile(editfile_cmd)   // open the new file(s)

        SetHookState(OFF, _ON_CHANGING_FILES_)
        SetHookState(OFF, _ON_FIRST_EDIT_)

        PushPosition()

        n = NumFiles() + (BufferType() <> _NORMAL_)

        while n
            // debug('buffer: ' + BufferName(GetBufferId()))
            if BufferType() == _NORMAL_
                buffer_id = GetBufferId()
                GotoBufferId(file_list_buffer)
                if not lFind('^' + Str(buffer_id) + '$', 'xg')
                    // debug('new file. client: ' + str(client_id) + '; id: ' + Str(buffer_id) + '; name: ' + BufferName(buffer_id))

                    GotoBufferId(client_list_buffer_id)
                    if not lFind('^' + Str(client_id) + ':' + Str(buffer_id) + ':', 'xg')
                        EndFile()
                        AddLine(Str(client_id) + ':' + Str(buffer_id) + ':' + Str(client_window) + ':' + Str(client_flags))
                        // debug('added client:buffer:window:flags. client: ' + str(client_id) + '; id: ' + Str(buffer_id) + '; name: ' + BufferName(buffer_id))
                    endif

                endif
                GotoBufferId(buffer_id)
            endif
            NextFile(_DONT_LOAD_)
            n = n - 1
        endwhile
        PopPosition()


        SetHookState(ON, _ON_CHANGING_FILES_)
        SetHookState(ON, _ON_FIRST_EDIT_)

        AbandonFile(file_list_buffer)

    endif

end


// When the user quits a file in the server, we should note in
// our client list (Client_ID_List_Buffer) that the file has been
// quit.  We do so by removing the line.  But before we remove the line
// we record the id of the client who originally opened this file (client_id)
//
// After we delete the line, we search for other lines which contain
// client_id.  If we don't find any, then we just quit the last
// file associated with that client_id.  Therefore, we can instruct
// the client that all of its files have been quit.

// A limitation of the current system is that each file can only
// be associated with a single client.

proc ServerQuitFileHandler()
    integer buffer_id     = GetBufferId()
    integer client_id     = 0
    integer client_flags  = 0
    integer client_window = 0

    // Goto the client:buffer list, delete the line if it exists
    // and if no more buffers for this client exist, then tell
    // the client to exit.

    PushPosition()

    if GotoBufferId(Client_ID_List_Buffer)
        if lFind('^{.*}:' + Str(buffer_id) + ':{.*}:{.*}$', 'xg')

            client_id     = Val(GetFoundText(1))
            client_window = Val(GetFoundText(2))
            client_flags  = Val(GetFoundText(3))

            // debug('client for this file: ' + str(client_id))

            DelLine()
            // debug('deleted line')

            if not lFind('^' + Str(client_id) + ':', 'xg')

                // no more lines beginning with client_id:
                // means that all of the files loaded by the
                // client are now gone.  Tell the client
                // it is free to go

                if client_flags & FLAG_RETURN_FOCUS
                    SetForegroundWindow(client_window)
                endif

                PokeLong(ADDR_CLIENT_PROCESS_ID, client_id)
                PokeLong(ADDR_SERVER_MESSAGE, MSG_FILES_QUIT)
            endif
        else
            // debug('this file '+SplitPath(CurrFileName(), _NAME_|_EXT_) + ' has no client associated with it')
        endif
    endif
    PopPosition()
end

// If the editor is being abandoned, then we broadcast
// the "SERVER_TERMINATING" message, which tells all
// clients to quit

proc ServerAbandonEditorHandler()
    PokeLong(ADDR_SERVER_MESSAGE, MSG_SERVER_TERMINATING)
end

//
// Server idle hook.  We are in the main (user-visible) instance of TSE,
// and we are waiting for client instances of TSE to notify us of
// files that we should edit.
//

#if SAVE_FILES_ON_LOSING_FOCUS
integer HadFocus = 0
#endif

proc ServerIdle()
    string new_drive[1]            = ''
    string new_dir[_MAXPATH_]      = ''
    string editfile_cmd[_MAXPATH_] = ''

    integer client_message = PeekLong(ADDR_CLIENT_MESSAGE)
    integer flags          = PeekLong(ADDR_MESSAGE_FLAGS)

    // If the client requested to edit files, process
    // that request

    if client_message == MSG_EDITFILES

        strcpy(ADDR_EDITFILE_DRIVE,   addr(new_drive))
        strcpy(ADDR_EDITFILE_PATH,    addr(new_dir))
        strcpy(ADDR_EDITFILE_COMMAND, addr(editfile_cmd))

        logdrive(new_drive)
        Chdir(new_dir)

        if flags & FLAG_WAIT_FOR_FILE_QUIT

            // Since the client wants to be notified when its files have
            // been quit, we have to record the client id along with
            // each file loaded.

            EditFilesAndRecordClient(
                Client_ID_List_Buffer,
                editfile_cmd,
                PeekLong(ADDR_CLIENT_PROCESS_ID),
                PeekLong(ADDR_CLIENT_WINDOW_HANDLE),
                PeekLong(ADDR_MESSAGE_FLAGS)
            )
        else

            // Since the client doesn't want to track its files, we can
            // just open the files normally

            EditFile(editfile_cmd)
        endif

        UpdateDisplay(_ALL_WINDOWS_REFRESH_)

        // setforegroundwindow(getwinhandle())
        // bringwindowtotop(getwinhandle())
        // setforegroundwindow(getwinhandle())

        // Reset the Client message area
        PokeLong(ADDR_CLIENT_MESSAGE, 0)

        #if SHOW_TSE_WINDOW_RESTORED
            showwindow(getwinhandle(), 9)
        #endif

    endif

    #if SAVE_FILES_ON_LOSING_FOCUS
        if GetForegroundwindow() == GetWinHandle()
            HadFocus = 1
        else

            if HadFocus
                SaveAllFiles()
                Message("Files saved")
            endif
            HadFocus = 0
        endif
    #endif

end

// The ClientIdle() hook serves two main purposes:
//    1) Process server requests to terminate the client
//    2) Defer client termination until parent app has
//       focus (if necessary)
//
// This routine also hides the client window (if necessary).

proc ClientIdle()

    integer server_message = PeekLong(ADDR_SERVER_MESSAGE)

    // Hide our own window
    #if DEBUG_MODE
    #else
        if not This_Window_Hidden
            ShowWindow(GetWinHandle(), 0)
            This_Window_Hidden = 1
        endif
    #endif

    if not (This_Clients_Flags & FLAG_PERSIST_HIDDEN)

        // Check to see if we should terminate, or if
        // we should flag that termination is pending

        // If we do not need to wait for a particular file to be quit
        // but we do need to wait for the parent to get focus
        // then flag it here.

        if (This_Clients_Flags & FLAG_WAIT_FOR_PARENT_FOCUS
        and (not (This_Clients_Flags & FLAG_WAIT_FOR_FILE_QUIT)))
            Waiting_For_Parent_Focus = TRUE
        endif

        // If we are ready to terminate, but just
        // waiting for the parent app to get focus,
        // then check if the parent app has focus.  If it
        // does, then quit.

        if Waiting_For_Parent_Focus
            if GetForegroundWindow() == Parent_Window
                AbandonEditor()
            endif
        endif

        // check the message from the server (if any)

        if server_message == MSG_FILES_QUIT
            if PeekLong(ADDR_CLIENT_PROCESS_ID) == This_Process_Id
                PokeLong(ADDR_SERVER_MESSAGE, 0)

                // The server has told us that all files that
                // we requested to be loaded have been quit.

                // That means that we are now free to exit.
                // We can either do so immediately, or
                // or, if we are supposed to wait for our
                // parent to gain focus, then we flag
                // that termination is pending.

                if This_Clients_Flags & FLAG_WAIT_FOR_PARENT_FOCUS
                    Waiting_For_Parent_Focus = TRUE
                else
                    AbandonEditor()
                endif
            endif
        endif
    endif

    // In all cases, when the server instance of TSE
    // exits, we should exit as well

    if server_message == MSG_SERVER_TERMINATING
        PokeLong(ADDR_SERVER_MESSAGE, 0)
        AbandonEditor()
    endif
end

// To become a client, we do the following:
//   * Open the file-mapped memory block
//   * Setup our addresses in this block
//   * Find the window handle of the app that called us (our parent app)
//   * Build the message to the server, then send it:
//      - current drive
//      - current directory
//      - dos command line (for EditFile())
//      - client process id, window handle and flags
//   * Bring the server window to the foreground
//   * Create a "placeholder" buffer so that we can stay open
//     in the background with a single file
//   * Abandon all other files in the ring to conserve memory
//   * Clear the Dos command line so that we don't edit all the files
//     that we also sent to the server
//   * Hook the ClientIdle() routine to handle requests from the server
//

proc SetupClient(var string command_line)
    integer server_window_handle = 0
    integer n

    string curr_drive[1]
    string curr_dir[_MAXPATH_]

    MM_Address = AddressOfMappedMemory(MM_Handle)

    SetupMappedMemoryAddresses(MM_Address)

    // Find our parent window.  Usually this will be the window
    // next in the Z-Order
    Parent_Window = GetWindow(GetWinHandle(), GW_HWNDNEXT)

    // But for some reason, sometimes there's a window in-between
    // us and our parent that has no title text, so if it exists
    // we ignore it and get the next window *after* that one

    if not GetWindowTextLength(Parent_Window)
        Parent_Window = GetWindow(Parent_Window, GW_HWNDNEXT)
    endif

    // debug('this_win: ' + str(GetWinHandle()) + '; next_win: ' + str(Parent_Window) +'; text: ' + window_text + '; (len: '+str(textlen)+')')
    // debug('this_win: ' + str(GetWinHandle()) + '; next_win: ' + str(Parent_Window))

    // Find our process id
    This_Process_ID = GetCurrentProcessID()

    // Setup the server

    curr_drive   = GetDrive()
    curr_dir     = GetDir(curr_drive)

    // Copy the message information to shared memory
    strcpy(addr(curr_drive)   , ADDR_EDITFILE_DRIVE)
    strcpy(addr(curr_dir)     , ADDR_EDITFILE_PATH)
    strcpy(addr(command_line) , ADDR_EDITFILE_COMMAND)

    PokeLong(ADDR_CLIENT_PROCESS_ID,    This_Process_ID)
    PokeLong(ADDR_CLIENT_WINDOW_HANDLE, GetWinHandle())
    PokeLong(ADDR_MESSAGE_FLAGS,        This_Clients_Flags)

    // Add the message itself
    PokeLong(ADDR_CLIENT_MESSAGE,       MSG_EDITFILES)

    // Bring the server window to the foreground
    server_window_handle = PeekLong(ADDR_SERVER_WINDOW_HANDLE)

    if server_window_handle
        SetForegroundWindow(server_window_handle)
        // BringWindowToTop(server_window_handle)
        // BringWindowToTop(GetWinHandle())
        // SetForegroundWindow(server_window_handle)
    endif

    // Create a buffer so we don't exit automatically
    // when we exit all files.

    Client_Holding_Buffer = CreateBuffer('[ *** onlyone placeholder *** ]')

    if GotoBufferId(Client_Holding_Buffer)
        Addline("This is a TSE background window - waiting for exit signal")
        FileChanged(FALSE)
    endif

    // Exit all files except the placeholder
    n = NumFiles() + (BufferType() <> _NORMAL_)

    while n
        if GetBufferID() <> Client_Holding_Buffer
            AbandonFile()
        endif
        NextFile()
        n = n - 1
    endwhile

    GotoBufferId(Client_Holding_Buffer)

    // Clear the command line
    Set(DosCmdLine, '')

    if This_Clients_Flags & FLAG_WAIT_FOR_FILE_QUIT
    or This_Clients_Flags & FLAG_PERSIST_HIDDEN
    or This_Clients_Flags & FLAG_WAIT_FOR_PARENT_FOCUS

        hook(_IDLE_, ClientIdle)    // and hook what we need

    else
        AbandonEditor()
    endif
end

// To become the server, we do the following:
//   * Create the file-mapped memory block
//   * Setup our addresses in this block
//   * Advertise the server window handle
//     so that clients can give it focus
//   * Prepare for notifying clients when their
//     files have been quit:
//      - Create the client list buffer
//      - Hook _ON_FILE_QUIT_ and _ON_ABANDON_EDITOR_
//   * Hook the ServerIdle() routine

proc SetupServer()

    MM_Handle  = CreateMappedMemory(MM_Name)
    MM_Address = AddressOfMappedMemory(MM_Handle)

    SetupMappedMemoryAddresses(MM_Address)

    // Clear the message areas
    PokeLong(ADDR_SERVER_MESSAGE, 0)
    PokeLong(ADDR_CLIENT_MESSAGE, 0)

    // Advertise our window handle so that clients can
    // bring us to the foreground when necessary
    PokeLong(ADDR_SERVER_WINDOW_HANDLE, GetWinHandle())

    Client_ID_List_Buffer = CreateTempBuffer()

    // set up our hooks
    hook(_IDLE_,              ServerIdle)
    hook(_ON_FILE_QUIT_,      ServerQuitFileHandler)
    hook(_ON_ABANDON_EDITOR_, ServerAbandonEditorHandler)
end

// OnlyOne() is the main entry point to this macro
// It should be called from the WhenLoaded function (either
// the macro's or the ui's, as appropriate)
//
// It does the following:
//  * sets the client flags based on command line switches
//  * trims the commandline to remove these switches
//  * Attempts to open the file-mapped memory block
//    - if successful, then becomes a client:   runs  SetupClient()
//    - if failed,     then becomes the server: runs  SetupServer()


proc OnlyOne()

    // Clear the message areas (undecided on this one...)
    // PokeLong(ADDR_SERVER_MESSAGE, 0)
    // PokeLong(ADDR_CLIENT_MESSAGE, 0)

    // Read command line and set client flags

    string command_line[_MAX_PATH_] = LTrim(Query(DosCmdLine))
    integer matched_flags = FALSE

    This_Clients_Flags = DEFAULT_CLIENT_SERVER_BEHAVIOUR

    if command_line[1:1] == Switch_Char
        case command_line[2:1]
           when Switch_Wait_For_File_Quit
               This_Clients_Flags = FLAG_WAIT_FOR_FILE_QUIT
               // debug('client_flags: '+Str(This_Clients_Flags)+'(FLAG_WAIT_FOR_FILE_QUIT)')
               matched_flags = TRUE

           when Switch_Smart_Wait_For_File_Quit
               This_Clients_Flags = FLAG_WAIT_FOR_FILE_QUIT | FLAG_WAIT_FOR_PARENT_FOCUS
               // debug('client_flags: '+Str(This_Clients_Flags)+'(FLAG_WAIT_FOR_FILE_QUIT | FLAG_WAIT_FOR_PARENT_FOCUS)')
               matched_flags = TRUE

           when Switch_Return_Immediately
               This_Clients_Flags = 0
               // debug('client_flags: '+Str(This_Clients_Flags)+'(none)')
               matched_flags = TRUE

           when Switch_Return_Focus
               This_Clients_Flags = FLAG_WAIT_FOR_FILE_QUIT | FLAG_RETURN_FOCUS
               // debug('client_flags: '+Str(This_Clients_Flags)+'(FLAG_WAIT_FOR_FILE_QUIT | FLAG_RETURN_FOCUS)')
               matched_flags = TRUE

           when Switch_Persist_Hidden
               This_Clients_Flags = FLAG_PERSIST_HIDDEN
               // debug('client_flags: '+Str(This_Clients_Flags)+'(FLAG_PERSIST_HIDDEN)')
               matched_flags = TRUE

        endcase

        if matched_flags
            command_line = command_line[3:Length(command_line) - 2]
            Set(DosCmdLine, command_line)
        endif

    endif

    // Set window title based on command line and TSEPro variable:

    SetWindowTitle(SplitPath(command_line, _NAME_|_EXT_) + " - " + TSEPro)

    // Attempt to open shared memory

    MM_Handle = OpenMappedMemory(MM_Name)

    if MM_Handle       // non-zero handle means already open
                       // and therefore we should become a client

        SetupClient(command_line)

    else               // we must become a server
                       // and set up our listening routines
        SetupServer()
    endif
end

#if USE_AS_STANDALONE_MACRO
proc WhenLoaded()
    OnlyOne()
end
#endif

proc WhenPurged()
    if Client_ID_List_Buffer
        AbandonFile(Client_ID_List_Buffer)
    endif
    if Client_Holding_Buffer
        AbandonFile(Client_Holding_Buffer)
    endif
end



