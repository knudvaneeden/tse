/******************************* Documentation ********************************

    ÚÄÄÄÄÄÄÄÄÄ¿
    ³ FilePal ³
    ÀÄÄÄÄÄÄÄÄÄÙ

<TSE Pro 2.5, 2.8, 3.x, 4.x>

FilePal will save, for a given file, the current position and bookmarks, plus
editing parameters Insert, AutoIndent, WordWrap, Margins, TabType, TabWidth,
ExpandTabs, EOLtype and EOFtype. Default values for these parameters may
also be associated with extensions, directories, or drives. Put a file on
AutoTrack and the current position, parameters and bookmarks will be
saved automatically each time the file is quit and restored on
reloading. FilePal keeps track of any number of files, even if not
loaded during the previous editing session. FilePal also supports
automatic execution of specific macros linked to filenames, extensions
directories, and drives.


Usage
ÄÄÄÄÄ

To call up the FilePal menu, hit <Ctrl F11>. Below is a description of menu
choices. Note: the "parm buffer" is a temporary system buffer created when the
macro is loaded and contains the data associated with each file, directory or
extension. This data is retrieved from file FILEPAL.DAT on startup and any
modifications are saved to that file on quitting the editor.


A) AUTO TRACK

   AutoTrack is associated with specific filenames only. When you put a file
   on AutoTrack, the current position, bookmarks and editing parameters will
   be saved automatically each time you quit the file and restored on
   re-loading (on re-loading, a reminder will flash briefly on the screen).
   The file will remain on AutoTrack until you turn it off. When you turn
   AutoTrack OFF, the file parameters will remain fixed as they were when the
   file was loaded. That is, until you clear them or overwrite them manually,
   with the commands described below.


B) FILE NAME

   Calls a sub-menu of actions associated with the current filename:

   WRITE PARMS
   Write the parameters (current position, editing parameters and bookmarks)
   associated with the current file name to the parm buffer. The saved
   parameters will remain in effect until you manually overwrite them or clear
   them (as opposed to AutoTrack).

   CLEAR PARMS
   Erase the parameters associated with the current file name. Note: This
   command also cancels AutoTrack.  The "live" parameters (the settings
   currently in effect in the editing session) won't actually be changed
   until you switch files.  If you want to clear the "live" parameters
   as well, select RELOAD from the FilePal menu.

   LOAD PARMS
   Load saved position, edit parameters and bookmarks associated with the
   current file name from the parm buffer. This is done automatically the
   first time each file is loaded into the editor. But you may want to do it
   manually, for example if the current file was loaded before the macro was,
   or if you want to restore startup parameters.

   LINK MACRO
   FilePal will ask for the name of a macro to be executed automatically upon
   editing the current file (overriding any previous link). Only one macro may
   be linked to a filename, but naturally, that macro may call others. Macro
   links are independent of saved position, editing parameters and bookmarks.

   UNLINK MACRO
   Cancel any existing link to the current filename.

   SHOW LINK
   Display the name of the macro linked to the current filename.


C) EXTENSION

   Same as FILE, except: associated with the EXTENSION of the current file and
   does not involve bookmarks.

   Filepal will use the CurrExt macro if it is availble in order to
   associate extensions with each other.

   CurrExt is available from http://www.occamstoothbrush.com/tsemac/

D) DIRECTORY

   Same as FILE except: associated with the DIRECTORY of the CURRENT FILE and
   does not involve bookmarks. Note: The directory of the current file may
   differ from the active directory.

E) DRIVE

   Same as FILE except: associated with the DRIVE of the CURRENT FILE and
   does not involve bookmarks.  This is especially useful if you map
   drives to UNIX or MAC volumes that expect different line termination
   strings.

F) HOUSEKEEPING

   GOTO BUFFER
   Display the parm buffer. The buffer is not part of the normal file ring and
   cannot be accessed through NextFile or PrevFile. The buffer cannot be
   edited directly.

   RELOAD
   Reload settings from the parm buffer, cascading as usual through the
   settings for the current DRIVE, EXTENSION, DIRECTORY, and FILENAME.
   This is the same process that happens when you first start FilePal,
   and when you switch to a new file.

   The only time that this becomes useful is when you have just used the
   CLEAR command to erase the settings for the current drive, directory
   or extension, and you also want to clear the actual settings in
   effect in the current editing session.

   CLEANUP
   Remove from the parm buffer any path or filename that no longer exists.


Installation
ÄÄÄÄÄÄÄÄÄÄÄÄ

1) Copy the files FILEPAL.S and FILEPAL.DAT to your macro directory
   (usually C:\TSE\MAC).

2) Load FILEPAL.S and edit the key assignment at the very end of this file
   to your own preference.

3) Compile FILEPAL.S

4) I suggest you add this macro to your AutoLoad list.


Miscellaneous notes
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

FilePal deals with three types of data:

    1. Startup position and bookmarks

    2. Editing parameters: Insert, AutoIndent, etc...

    3. Automatic macros

Type 1 is associated with filenames only. Types 2 and 3 may be associated with
filenames, extensions or directories (paths).

When a file is loaded into the editor (ON_FIRST_EDIT), or when you
switch to a new file in the ring (ON_CHANGING_FILES), FilePal attempts
to load all the appropriate settings based on the file's drive,
extension, directory, and name, in that order.

For instance, for the file:

    W:\tools\readme.txt

Filepal tries to find and apply settings for the following parameters:

    (start with editor default settings)
    try to match DRIVE     = w:
    try to match EXTENSION = .txt
    try to match DIRECTORY = w:\tools
    try to match FILENAME  = w:\tools\readme.txt

In each case, if it finds a match, it loads the settings for that
match.  Then it continues to the next match.  In other words, regardless
of whether or not it finds a match, it eventually loads the settings
for all the matches it finds.

This behaviour is different from previous versions of FilePal.  Previous
versions would stop when they found a match.  The new behaviour is more
powerful, however, allowing settings to cascade down from the general
case (DRIVE) to the specific case (exact FILENAME).

You can, for instance, have the following set of rules:

    1) All files on drive W: use LF-only line termination.
    2) All windows .ini files use CRLF line termination
       (even .ini files on drive W:).
    3) The file w:\apache\config\php3.ini uses LF-only line termination.

This would allow for the following cases

    w:\tools\readme.txt         - LF-only (drive overrides default)
    w:\tools\settings.ini       - CRLF    (extension overrides drive)
    w:\apache\config\php3.ini   - LF-only (filename overrides extension)

If FilePal can't find any matches at all for the current file, then
the editor defaults (i.e. those found when the macro was loaded)
remain unchanged.

At each stage, FilePal also looks for links to specific macros to execute
automatically _ON_FIRST_EDIT_ and _ON_CHANGING_FILES_. This allows, for
example, associating specific key definitions with extensions or
directories. As with editing parameters, priority goes to the filename.
If it finds no macro linked with the filename, it looks for a link with
the extension and lastly with the directory. When switching to a new
file, if the new link calls for a different macro, the last macro
executed via Filepal will be purged before execution of the new one. If
the new link calls for the same macro as the last one, that macro will
not be executed twice consecutively.

BOOKMARKS Bookmarks are not saved directly, but rather the lines and
window rows. As a consequence, the cursor column is NOT saved, which
means that restored marks always point to column 1. Secondly, if you
edit the file to add or delete lines, previously saved bookmarks will be
offset, so be sure to save file data again after editing (this will be
automatic if the file is on AutoTrack). Finally, restoring bookmarks for
a file will override marks with the same name (letter) in other files
currently loaded. On "Write parms", only the bookmarks associated with
the current file are written to the buffer.


FILEPAL.DAT
This file contains the saved data. When the macro is loaded, the editor looks
for it in the current directory, then in the editor load directory and the \MAC
subdirectory. After the macro has been in use for some time, this file will
probably contain paths or filenames that no longer exist (if you move a file
to another directory, the saved filename will no longer be valid, since it
includes the full path). The "Cleanup" function will purge obsolete filenames
and paths from the list. Or, you can edit FILEPAL.DAT manually (you will have
to actually load that file into the editor: although the FilePal menu allows
displaying the parm buffer, you can not edit the buffer directly).


RESTORE STATE
When the editor is started with the Restore State option, FilePal is inhibited.
Although FilePal resembles Restore State, note the following differences:

    - FilePal keeps track of parameters for any number of files, for as long
      as you wish, even if the files were not loaded during the previous
      editing session;

    - FilePal does *NOT* remember which files were last loaded in the editor;

    - FilePal does *NOT* save marked blocks;

    - FilePal can associate editing parameters not only with filenames, but
      also with specific extensions, directories, and drives;

    - FilePal will restore appropriate settings on changing files;

    - FilePal supports automatic macros.


DISABLING FILEPAL FROM ANOTHER MACRO
If you put FilePal in your AutoLoad list, its operation may sometimes interfere
with that of another macro. Such a macro may disable FilePal by setting the
global string 'FilePal' to 'OFF', as such:

                     SetGlobalStr('FilePal', 'OFF')

This will effectively disable FilePal hooks until the global string is reset
to 'ON' (or anything else but 'OFF') or until the editor is abandoned.


                                            Jean Heroux
                                            heroux.jean@videotron.ca
                                            99-11-05

------------------------------------------------------------------------
EOLtype, EOFtype, the DRIVE setting, and the cascade mechanism added by

                                            Michael Graham
                                            magmac@occamstoothbrush.com
                                            2001-03-11

*/
//**************************** Global Variables ***************************

#ifndef MAXPATH
 #ifndef _MAXPATH_
  #define MAXPATH 255
 #else
  #define MAXPATH _MAXPATH_
 #endif
#endif
#ifndef MAXSTRINGLEN
 #define MAXSTRINGLEN 255
#endif

constant type_file=1, type_ext=2, type_dir=3, type_drive=4,
         do_msg=1, no_msg=0,
         buffer_text_attr   = Color(White on Blue),
         buffer_cursor_attr = Color(Bright Cyan on Blue),
         buffer_EOF_attr    = Color(Blue on Blue),
         buffer_status_attr = Color(Blue on Blue),
         buffer_msg_attr    = Color(Blink Bright Yellow on Black)

string parm_spec[MAXSTRINGLEN]='', file_name[MAXPATH]='', parm_file[MAXPATH]='', type_msg[11]='',
       mac_name[MAXPATH]='', prev_mac[MAXPATH]='', mac_parm[MAXPATH]='', rec_name[MAXPATH]='',
       file_header[]='ùFILESù', ext_header[]='ùEXTENSIONSù',
       dir_header[]='ùDIRECTORIESù',drive_header[]='ùDRIVESù',
       header[12]=''

integer parm_buffer=0, active_file, restoring=FALSE, auto_track = OFF,
        def_insert, def_autoindent, def_wordwrap, def_leftmargin,
        def_rightmargin, def_tabtype, def_tabwidth, def_expand,
        def_eoltype, def_eoftype,
        normal_text_attr, normal_cursor_attr, normal_status_attr,
        normal_EOF_attr, normal_msg_attr,
        changed_I, changed_L, changed_R, changed_T, changed_E

//****************************** Helper macros *****************************

proc debug (string msg)
    updatedisplay()
    warn(msg)
    if 0 debug('') endif
end


// Replace a single character in position p by string ins_s
string proc mReplStr(string ins_s, string orig_s, integer p)
    return(SubStr(orig_s, 1, p-1) + ins_s + SubStr(orig_s, p+1, Length(orig_s)))
end

// Replace regular expression characters by their token hex value: \xnn
string proc mRegular(string input_s)
    string reg[16] = "\.^$|?[]-~*=@#{}", work_s[MAXSTRINGLEN]=input_s, token_s[4]=''
    integer i
    for i = 1 to Length(reg)
        while Pos(reg[i], work_s)
            token_s = 'ûx' + Str(Asc(reg[i]), 16)
            work_s = mReplStr(token_s, work_s, Pos(reg[i], work_s))
        endwhile
    endfor
    while Pos('û', work_s)
        work_s = mReplStr('\', work_s, Pos('û', work_s))
    endwhile
    return(work_s)
end

// Display a temporary pop-up message
proc PopMsg(string msg, integer attr, integer time)
    integer w_col = 40 - Length(msg)/2 - 2
    UpdateDisplay()
    PopWinOpen(w_col, 12, w_col+Length(msg)+3, 14, 4, '', attr)
    Gotoxy(1,1)
    Write(' '+msg+' ')
    Gotoxy(1,1)
    PutAttr(attr, Length(msg)+2)
    Delay(time)
    PopWinClose()
end

// Will display message if condition is TRUE
proc mCondMsg(integer condition, string msg_str)
    if condition
        Message(msg_str)
    endif
end

string proc mCurrExt()
    return(iif(isMacroLoaded('CurrExt'), GetGlobalStr('CurrExt'), CurrExt()))
end

string proc mCurrDir()
    return(SplitPath(CurrFilename(),_DRIVE_|_PATH_))
end

string proc mCurrDrive()
    return(SplitPath(CurrFilename(),_DRIVE_))
end


// Find a record (passed name)
integer proc mFindRecord(string rec_name)
    if LFind('^' + mRegular(rec_name) + 'þ', 'xig')
        return(TRUE)
    endif
    return(FALSE)
end

proc mSetRecordType(integer type)
    active_file = GetBufferId()
    case type
        when type_file
            rec_name = CurrFileName()
            type_msg = ' filename '
            header = file_header
        when type_ext
            rec_name = mCurrExt()
            type_msg = ' extension '
            header = ext_header
        when type_dir
            rec_name = mCurrDir()
            type_msg = ' directory '
            header = dir_header
        when type_drive
            rec_name = mCurrDrive()
            type_msg = ' drive '
            header = drive_header
    endcase
end

//******************************** Defaults *********************************

// This procedure is called when the macro is loaded
proc mGetDefaults()
    def_insert      = Query(Insert)          //
    def_autoindent  = Query(AutoIndent)      //
    def_wordwrap    = Query(WordWrap)        // If you put FilePal
    def_leftmargin  = Query(LeftMargin)      // in your Autoload list,
    def_rightmargin = Query(RightMargin)     // these values will be
    def_tabtype     = Query(TabType)         // those of your .CFG file
    def_tabwidth    = Query(TabWidth)        //
    def_expand      = Query(ExpandTabs)      //
    def_eoltype     = Query(EOLtype)
    def_eoftype     = Query(EOFtype)
end

// This procedure sets editing parameters to the values found when the
// macro was loaded
proc mSetDefaults()
    Set(Insert,      def_insert)
    Set(AutoIndent,  def_autoindent)
    Set(WordWrap,    def_wordwrap)
    Set(LeftMargin,  def_leftmargin)
    Set(RightMargin, def_rightmargin)
    Set(TabType,     def_tabtype)
    Set(TabWidth,    def_tabwidth)
    Set(ExpandTabs,  def_expand)
    Set(EOLType,     def_eoltype)
    Set(EOFType,     def_eoftype)
end

//************************** Parm Buffer Handling ****************************

// This procedure is called when the macro is loaded
integer proc mLoadParmFile()
    active_file=GetBufferId()
    if FileExists(parm_file)
        parm_buffer=CreateTempBuffer()
        InsertFile(parm_file)
        UnmarkBlock()
        FileChanged(FALSE)
        SetGlobalInt('pf', parm_buffer)  // Make available to other macros
        GotoBufferId(active_file)
        return(TRUE)
    endif
    return(FALSE)
end

// This is called on exiting the editor, or manually through the menu
proc mSaveBufferToDisk(integer msg_cond)
    active_file=GetBufferId()
    if GotoBufferId(parm_buffer) and FileChanged()
        SaveAs(parm_file, _OVERWRITE_)
        FileChanged(FALSE)
    endif
    GotoBufferId(active_file)
    mCondMsg(msg_cond, 'Buffer saved to disk')
    return()
end

proc mBufferMessage()
    Message(Format('Use <Escape> to exit buffer':53))
end

proc mBackFromBuffer()
    Set(TextAttr, normal_text_attr)
    Set(CursorAttr, normal_cursor_attr)
    Set(EOFMarkerAttr, normal_EOF_attr)
    Set(StatusLineAttr, normal_status_attr)
    Set(MsgAttr, normal_msg_attr)
    Unhook(mBufferMessage)
    GotoBufferId(active_file)
end

// Enabled when editing/viewing the buffer
keydef inbuffer
    <CursorUp>    Up()
    <CursorDown>  Down()
    <PgUp>        PageUp()
    <PgDn>        PageDown()
    <Home>        BegFile()
    <End>         EndFile()
    <Escape>      mBackFromBuffer() Disable(inbuffer)
    <F7>          mBackFromBuffer() Disable(inbuffer)
end

// Procedure called from the Menu to go to the buffer
proc mViewBuffer()
    active_file = GetBufferId()
    normal_text_attr   = Query(TextAttr)
    normal_cursor_attr = Query(CursorAttr)
    normal_EOF_attr    = Query(EOFMarkerAttr)
    normal_status_attr = Query(StatusLineAttr)
    normal_msg_attr    = Query(MsgAttr)
    if not GotoBufferId(parm_buffer)
        Message('!!! FilePal error 1: Cannot find parm buffer')
        halt
    endif
    Set(TextAttr, buffer_text_attr)
    Set(CursorAttr, buffer_cursor_attr)
    Set(EOFMarkerAttr, buffer_EOF_attr)
    Set(StatusLineAttr, buffer_status_attr)
    Set(MsgAttr, buffer_msg_attr)
    Enable(inbuffer, _EXCLUSIVE_)
    Hook(_AFTER_COMMAND_, mBufferMessage)
    BegLine()
    ScrollToCenter()
end

proc mCleanBuffer()
    integer clean=0
    active_file=GetBufferId()
    GotoBufferId(parm_buffer)
    BegFile()
    repeat
        if PosFirstNonWhite()==1
                and CurrChar()<>46   // exclude file extensions
            parm_spec = GetText(1, CurrLineLen())
            file_name=GetText(1, (Pos('þ', parm_spec)-1))
            if not FileExists(file_name)
                DelLine()
                Up()
                clean = clean + 1
            endif
        endif
    until not Down()
    GotoBufferId(active_file)
    Message(iif(clean, 'Deleted '+Str(clean)+' item(s)', 'Nothing to do'))
end

//**************************** Writing Records ******************************

forward string proc mGetParm(string this_parm)
forward proc mGetMacName(integer msg_cond)

// Add passed string to parm_spec
proc mAddStr(string parm_str)
    parm_spec = parm_spec + parm_str
end

// Add macro name to parm_spec
proc mPutMac(string mac_name)
    mAddStr('þM'+ mac_name)
end

// Find the passed record and blank it OR insert a blank line in the
// appropriate section (if blanking existing record, save value of mac_parm)
proc mBlankRecord(string rec_name)
    mac_parm = ''
    if mFindRecord(rec_name)        // blank an existing record
        parm_spec = GetText(1, CurrLineLen())
        mac_parm = mGetParm('þM')
        DelToEOL()
    else                            // or insert a blank line
        BegFile()
        if LFind(header, 'i')       // find appropriate section
            AddLine()
        else
            Message('!!! FILEPAL error 9: header ' + header + ' not found')
            halt
        endif
        BegLine()
    endif
end

// Delete any macro link in current line of parm_buffer
integer proc mDropMac()
    string sNewRecord[255]=''
    if not LFind('þM', 'gc')
        return(FALSE)
    endif
    sNewRecord = GetText(1, CurrPos() - 1)
    if LFind('þ', 'c+')
        sNewRecord = sNewRecord + GetText(CurrPos(), CurrLineLen())
    endif
    BegLine()
    DelToEOL()
    parm_spec = sNewRecord
    InsertText(sNewRecord)
    return(TRUE)
end

// Insert a new macro link to current line of parm_buffer
proc mNewMac(string macro_name)
    mDropMac()
    EndLine()
    InsertText('þM'+macro_name)
    parm_spec = GetText(1, CurrLineLen())
end

// Display the name of the linked macro
proc mShowMac(integer type)
    mSetRecordType(type)
    if type==type_ext and not Length(rec_name)
        Message('This file has no extension')
        return()
    endif
    if not GotoBufferId(parm_buffer)
        Message('!!! FilePal error 2: Cannot find parm buffer')
        halt
    endif
    if not (mFindRecord(rec_name) and LFind('þM', 'cg'))
        Message('No macro linked to' + type_msg + Upper(rec_name))
        GotoBufferId(active_file)
        return()
    endif
    parm_spec = GetText(1, CurrLineLen())
    mac_name = mGetParm('þM')
    Message('Macro '+Upper(mac_name)+' is linked to'+type_msg + Upper(rec_name))
    GotoBufferId(active_file)
end

// Kill the macro link to the current filename, extension or directory
proc mUnlinkMac(integer type, integer msg_cond)
    mSetRecordType(type)
    if type==type_ext and not Length(rec_name)
        Message('This file has no extension')
        return()
    endif
    if not GotoBufferId(parm_buffer)
        Message('!!! FilePal error 3: Cannot find parm buffer')
        halt
    endif
    if not mFindRecord(rec_name)
        Message('This' + type_msg + 'not found in parm buffer')
        GotoBufferId(active_file)
        return()
    endif
    parm_spec = GetText(1, CurrLineLen())
    mac_name = mGetParm('þM')
    if not mDropMac()
        Message('No macro linked to this'+ type_msg)
        GotoBufferId(active_file)
        return()
    endif

// Delete line if only the record name remains
    if GetText(1, CurrLineLen())==rec_name
        DelLine()
    endif
    GotoBufferId(active_file)
    mCondMsg(msg_cond, 'Unlinked macro ' + Upper(mac_name) + ' from'
                   + type_msg + Upper(rec_name))
end

// Link a macro the the current file's name, extension or directory
proc mLinkMac(integer type, integer msg_cond)
    mSetRecordType(type)
    if type==type_ext and not Length(rec_name)
        Message('This file has no extension')
        return()
    endif
    if not Ask('Macro name?', mac_name)
        return()
    endif
    if not GotoBufferId(parm_buffer)
        Message('!!! FilePal error 4: Cannot find parm buffer')
        halt
    endif
    if not mFindRecord(rec_name)
        mBlankRecord(rec_name)
        InsertText(rec_name)
    endif
    mNewMac(mac_name)
    GotoBufferId(active_file)
    mCondMsg(msg_cond, 'Linked macro ' + Upper(mac_name) + ' to'
                   + type_msg + Upper(rec_name))
end

// Delete edit parms associated with current filename, ext, dir or drive
proc mClearEditParms(integer type, integer msg_cond)
    mSetRecordType(type)
    if type==type_file
        auto_track = OFF
    endif
    if GotoBufferId(parm_buffer) and mFindRecord(rec_name)
        parm_spec = GetText(1, CurrLineLen())
        mac_parm = mGetParm('þM')
        if Length(mac_parm)
            LFind('þ','c')
            DelToEOL()
            InsertText('þM'+ mac_parm)
            parm_spec = GetText(1, CurrLineLen())
        else
            DelLine()
            mCondMsg(msg_cond, 'Cleared parms for'+ type_msg + Upper(rec_name))
        endif
    else
        mCondMsg(msg_cond, type_msg + Upper(rec_name)+ ' not found')
    endif

    GotoBufferId(active_file)

end

proc mWriteBookmarks()
    integer mrk_no = 97
    while mrk_no < 123
        if GotoMark(Chr(mrk_no)) and (GetBufferId()==active_file)
            mAddStr('þ'+Chr(mrk_no)+Str(CurrLine())+Format(CurrRow():2:'0'))
        endif
        mrk_no = mrk_no + 1
    endwhile
end

forward integer proc mLoadParms(integer type, integer msg_cond)
forward proc mCascadeParms()
forward proc mPutAllEditParms()
forward integer proc mSetEditParms()
proc mFindChangedParms(integer t)
    string saved_parms[255]    = parm_spec
    string current_parms[255]  = ''
    string saved_rec_name[100] = rec_name
    string saved_type_msg[11]  = type_msg
    string saved_header[12]    = header
    integer saved_active_file  = active_file


    string val_I[3] = ''
    string val_L[4] = ''
    string val_R[4] = ''
    string val_T[4] = ''
    string val_E[2] = ''

    parm_spec = ''

    mPutAllEditParms()

    current_parms = parm_spec
    // debug("current parm spec: " + parm_spec)

    val_I = mGetParm('þI')
    val_L = mGetParm('þL')
    val_R = mGetParm('þR')
    val_T = mGetParm('þT')
    val_E = mGetParm('þE')

    parm_spec = ''

    // Partial cascade - up to but not including current type
    if t == type_file or t == type_dir or t == type_ext or t == type_drive
        mSetDefaults()
    endif
    if t == type_file or t == type_dir or t == type_ext
        mLoadParms(type_drive, no_msg)
    endif
    if t == type_file or t == type_dir
        mLoadParms(type_ext, no_msg)
    endif
    if t == type_file
        mLoadParms(type_dir, no_msg)
    endif

    mPutAllEditParms()
    // debug("previous parm spec: " + parm_spec)

    changed_I = val_I <> mGetParm('þI')
    changed_L = val_L <> mGetParm('þL')
    changed_R = val_R <> mGetParm('þR')
    changed_T = val_T <> mGetParm('þT')
    changed_E = val_E <> mGetParm('þE')

    // debug ( "I: " + str(changed_I) + " (val_I: " + val_I + "; Get I: " + mGetParm('þI') + ")")
    // debug ( "L: " + str(changed_L) + " (val_L: " + val_L + "; Get L: " + mGetParm('þL') + ")")
    // debug ( "R: " + str(changed_R) + " (val_R: " + val_R + "; Get R: " + mGetParm('þR') + ")")
    // debug ( "T: " + str(changed_T) + " (val_T: " + val_T + "; Get T: " + mGetParm('þT') + ")")
    // debug ( "E: " + str(changed_E) + " (val_E: " + val_E + "; Get E: " + mGetParm('þE') + ")")

    parm_spec = current_parms
    mSetEditParms()

    parm_spec   = saved_parms
    rec_name    = saved_rec_name
    type_msg    = saved_type_msg
    header      = saved_header
    active_file = saved_active_file
end


// Write all Editing parameters to parm_spec
proc mPutAllEditParms()
    mAddStr('þI'+ Str(Query(Insert))
                + Str(Query(AutoIndent))
                + Str(Query(WordWrap)))
    mAddStr('þL'+ Str(Query(LeftMargin)))

    mAddStr('þR'+ Str(Query(RightMargin)))

    mAddStr('þT'+ Str(Query(TabType))
                + Format(Query(TabWidth):2:'0')
                + Str(Query(ExpandTabs)))

    mAddStr('þE'+ Str(Query(EOLType))
                + Str(Query(EOFType)))
end

proc mPutEditParms(integer t)

    mFindChangedParms(t)

    if changed_I
        mAddStr('þI'+ Str(Query(Insert))
                    + Str(Query(AutoIndent))
                    + Str(Query(WordWrap)))
    endif

    if changed_L
        mAddStr('þL'+ Str(Query(LeftMargin)))
    endif

    if changed_R
        mAddStr('þR'+ Str(Query(RightMargin)))
    endif

    if changed_T
        mAddStr('þT'+ Str(Query(TabType))
                    + Format(Query(TabWidth):2:'0')
                    + Str(Query(ExpandTabs)))
    endif

    if changed_E
        mAddStr('þE'+ Str(Query(EOLType))
                    + Str(Query(EOFType)))
    endif
end


// Write parameters for current filename, extension or directory
integer proc mWriteParms(integer type, integer msg_cond)

    mSetRecordType(type)
    if type==type_file and (not BufferType()==_NORMAL_ or not Length(rec_name))
        mCondMsg(msg_cond, 'This file is not normal or is unnamed')
        return(FALSE)
    elseif type==type_ext and rec_name == ''
        mCondMsg(msg_cond, 'File has no extension')
        return(FALSE)
    endif
    if not GotoBufferId(parm_buffer)
        Message('Cannot find parm buffer')
        halt
    endif
    mBlankRecord(rec_name)
    case type
        when type_file
            parm_spec = rec_name + iif(auto_track, 'þA', '')
            PushPosition()  // remember record location in parm_buffer
            GotoBufferId(active_file)
            mAddStr('þP'+ Str(CurrLine()) + Format(CurrRow():2:'0'))
            mPutEditParms(type_file)
            mWriteBookmarks()
            PopPosition()   // go back to record location in parm buffer
        when type_ext
            parm_spec = rec_name
            mPutEditParms(type_ext)
        when type_dir
            parm_spec = rec_name
            mPutEditParms(type_dir)
        when type_drive
            parm_spec = rec_name
            mPutEditParms(type_drive)
    endcase
    if Length(mac_parm)
        mPutMac(mac_parm)
    endif
    BegLine()
    InsertText(parm_spec)
    if parm_spec == rec_name
        DelLine()
    endif
    mCondMsg(msg_cond, type_msg + 'defaults written')
    GotoBufferId(active_file)
    return(TRUE)
end

proc mToggleAutoTrack()
    if BufferType()==_NORMAL_  and  Length(CurrFilename())
        auto_track = not auto_track
        mWriteParms(type_file, no_msg)
        Message('AutoTrack  '+iif(auto_track,'ON','OFF'))
    endif
end

// Writes file parameters automatically if current file is on AutoTrack
proc mAutoTrack()
    file_name = CurrFilename()
    active_file = GetBufferId()
    if auto_track and GotoBufferId(parm_buffer)
       if mFindRecord(file_name) and LFind('þA','c')
           GotoBufferId(active_file)
           mWriteParms(type_file, no_msg)
       else
           GotoBufferId(active_file)
       endif
    endif
end

//**************************** Reading Records *******************************

// Return specified parameter from parm_spec
string proc mGetParm(string this_parm)
    string parm_str[35]=''
    if Pos(this_parm, parm_spec)
        parm_str = SubStr(parm_spec, Pos(this_parm, parm_spec)
                 + Length(this_parm), Length(parm_spec))
    endif
    if Pos('þ', parm_str)
        parm_str = SubStr(parm_str, 1, Pos('þ', parm_str) - 1)
    endif
    return(parm_str)
end

// Set editing parameters to values found in parm_spec
integer proc mSetEditParms()
    integer found_edit_parm = FALSE
    if Pos('þI', parm_spec)
        found_edit_parm = TRUE
        Set(Insert, Val(Substr(mGetParm('þI'), 1, 1)))
        Set(AutoIndent, Val(Substr(mGetParm('þI'), 2, 1)))
        Set(WordWrap, Val(Substr(mGetParm('þI'), 3, 1)))
    endif
    if Pos('þL', parm_spec)
        found_edit_parm = TRUE
        Set(LeftMargin, Val(mGetParm('þL')))
    endif
    if Pos('þR', parm_spec)
        found_edit_parm = TRUE
        Set(RightMargin, Val(mGetParm('þR')))
    endif
    if Pos('þT', parm_spec)
        found_edit_parm = TRUE
        Set(TabType, Val(SubStr(mGetParm('þT'),1,1)))
        Set(TabWidth, Val(SubStr(mGetParm('þT'),2,2)))
        Set(ExpandTabs, Val(SubStr(mGetParm('þT'),4,1)))
    endif
    if Pos('þE', parm_spec)
        found_edit_parm = TRUE
        Set(EOLType, Val(SubStr(mGetParm('þE'),1,1)))
        Set(EOFType, Val(SubStr(mGetParm('þE'),2,1)))
    endif
    return(found_edit_parm)
end

// Get macro name linked to current filename, extension, directory, or drive
proc mGetMacName(integer msg_cond)
    string curr_ext[10]=mCurrExt(), curr_dir[75]=mCurrDir()
    file_name = CurrFileName()
    active_file = GetBufferId()
    mac_name = ''
    if not GotoBufferId(parm_buffer)
        mCondMsg(msg_cond, 'Cannot find parm buffer')
        return()
    endif
    if mFindRecord(file_name) and LFind('þM','c')
       or  mFindRecord(curr_ext) and LFind('þM','c')
       or  mFindRecord(curr_dir) and LFind('þM','c')
        parm_spec = GetText(PosFirstNonWhite(), PosLastNonWhite())
        mac_name = mGetParm('þM')
    endif
    GotoBufferId(active_file)
end

// Set edit parameters for the passed record, according to values found in
// parm buffer. If a filename, set auto_track (not bookmarks nor position).
integer proc mLoadParms(integer type, integer msg_cond)
    mSetRecordType(type)
    if not GotoBufferId(parm_buffer)
        mCondMsg(msg_cond, 'Cannot find parm buffer')
        return(FALSE)
    endif
    if not mFindRecord(rec_name)
        mCondMsg(msg_cond, 'Cannot find'+ type_msg + Upper(rec_name))
        GotoBufferId(active_file)
        auto_track = iif(type==type_file, FALSE, auto_track)
        return(FALSE)
    endif
    parm_spec = GetText(PosFirstNonWhite(), PosLastNonWhite())
    GotoBufferId(active_file)
    if type==type_file
        if Pos('þA', parm_spec)
            auto_track = ON
        else
            auto_track = OFF
        endif
    endif
    if mSetEditParms()
        mCondMsg(msg_cond, type_msg + 'defaults loaded')
    else
        mCondMsg(msg_cond, 'Edit parms not found for' + type_msg + Upper(rec_name))
    endif
    return(TRUE)
end

proc mCascadeParms()
    mSetDefaults()
    mLoadParms(type_drive, no_msg)
    mLoadParms(type_ext, no_msg)
    mLoadParms(type_dir, no_msg)
    mLoadParms(type_file, no_msg)
end

// Get bookmarks for current file from the buffer
integer proc mLoadMarks(integer msg_cond)
    integer mrk_line, mrk_no, parm_len
    string parm_str[8]=''
    active_file=GetBufferId()
    file_name= CurrFilename()
    if not GotoBufferId(parm_buffer)
        mCondMsg(msg_cond, 'Cannot find parm buffer')
        return(FALSE)
    endif
    if not mFindRecord(file_name)
        mCondMsg(msg_cond, 'Cannot find filename')
        GotoBufferId(active_file)
        return(FALSE)
    endif
    if not LFind('þ[a-z]','xc')
        mCondMsg(msg_cond, 'Cannot find bookmarks')
        GotoBufferId(active_file)
        return(FALSE)
    endif
    parm_spec = GetText(PosFirstNonWhite(), PosLastNonWhite())
    GotoBufferId(active_file)
    PushPosition()
    mrk_no = 97
    while mrk_no < 123
        parm_str = mGetParm('þ'+Chr(mrk_no))
        parm_len = Length(parm_str)
        mrk_line = Val(Substr(parm_str, 1, parm_len - 2))
        if mrk_line > 0
            GotoLine(mrk_line)
            ScrollToRow(Val(SubStr(parm_str, parm_len - 1, 2)))
            PlaceMark(Chr(mrk_no))
        endif
        mrk_no = mrk_no + 1
    endwhile
    PopPosition()
    return(TRUE)
end

// Retrieve saved cursor line and window row from the buffer
integer proc mLoadPosition(integer msg_cond)
    string parm_str[8]=''
    integer parm_len
    active_file=GetBufferId()
    file_name= CurrFilename()
    if not GotoBufferId(parm_buffer)
        mCondMsg(msg_cond, 'Cannot find parm buffer')
        return(FALSE)
    endif
    if not mFindRecord(file_name)
        mCondMsg(msg_cond, 'Cannot find filename')
        GotoBufferId(active_file)
        return(FALSE)
    endif
    parm_spec = GetText(PosFirstNonWhite(), PosLastNonWhite())
    GotoBufferId(active_file)
    parm_str = mGetParm('þP')
    parm_len = Length(parm_str)
    GotoLine(Val(Substr(parm_str, 1, parm_len - 2)))
    ScrollToRow(Val(SubStr(parm_str, parm_len - 1, 2)))
    return(TRUE)
end

// Load file data (edit parms, position and bookmarks)
integer proc mLoadFileAll(integer msg_cond)
    if mLoadParms(type_file, msg_cond)
        mLoadPosition(msg_cond)
        if auto_track
            PopMsg('Auto Track', 106, 10)
        endif
        if mLoadMarks(no_msg) and not auto_track
            PopMsg('Bookmarks', 27, 10)
        endif
        return(TRUE)
    endif
    return(FALSE)
end

proc mExecMac()
    mGetMacName(no_msg)
    if mac_name <> prev_mac
        if Length(prev_mac)
            PurgeMacro(prev_mac)
            prev_mac = ''
        endif
        if Length(mac_name)
            ExecMacro(mac_name)
            prev_mac = mac_name
        endif
    endif
end

//********************************* Hooks ********************************

// Load edit parameters, bookmarks and position + execute macro
proc mOnFirstEdit()
    if GetGlobalStr('FilePal')=='OFF'
        return()
    endif
    // if not ( mLoadFileAll(no_msg) or mLoadParms(type_ext, no_msg)
    //                               or mLoadParms(type_dir, no_msg) )
    //     mSetDefaults()
    // endif

    if mLoadFileAll(no_msg)
        mCascadeParms()
    endif

    mExecMac()
end

// Load edit parameters only + execute macro
proc mOnChangingFiles()
    if GetGlobalStr('FilePal')=='OFF'
        return()
    endif
    // if not( mLoadParms(type_file, no_msg) or mLoadParms(type_ext, no_msg)
    //         or mLoadParms(type_dir, no_msg))
    //     mSetDefaults()
    // endif

    mCascadeParms()

    mExecMac()
end

proc mOnFileQuit()
    if GetGlobalStr('FilePal')=='OFF'
        return()
    endif
    mAutoTrack()
end

proc mOnAbandonEditor()
    if GetGlobalStr('FilePal') <> 'OFF'
        mAutoTrack()
    endif
    mSaveBufferToDisk(no_msg)
end

proc WhenPurged()
    mSaveBufferToDisk(no_msg)
    AbandonFile(parm_buffer)
end

proc WhenLoaded()
    string first_parm[3]= GetToken(Query(DosCmdLine),' ', 1)

    case first_parm
        when '-r', '-R', '/r', '/R'      // restore mode inhibits
            restoring=TRUE               // operation of FilePal
            return()
        otherwise
        parm_file=SearchPath("filepal.dat", Query(TSEPath), "mac")
            if mLoadParmFile()
                mGetDefaults()
                Hook(_ON_FIRST_EDIT_, mOnFirstEdit)
                Hook(_ON_CHANGING_FILES_, mOnChangingFiles)
                Hook(_ON_FILE_QUIT_, mOnFileQuit)
                Hook(_ON_ABANDON_EDITOR_, mOnAbandonEditor)
            endif
    endcase
end

//********************************** Menu ***********************************


menu FileMenu()
     Title = "File Name"
     history
    "&Write parms"              ,   mWriteParms(type_file, do_msg)                         ,
                                , 'Write parms for current filename'
    "&Clear parms"              ,   mClearEditParms(type_file, do_msg)                  ,
                                , 'Erase parms for current filename'
    "Load &Parms"               ,   mLoadFileAll(do_msg)                       ,
                                , 'Load parms for current filename'
    ""                          ,                      ,   Divide
    "&Link macro"               ,   mLinkMac(type_file, do_msg)                             ,
                                , 'Link macro to current filename'
    "&Unlink macro"             ,   mUnlinkMac(type_file, do_msg)                            ,
                                , 'Unlink macro from current filename'
    "&Show link"                ,   mShowMac(type_file)                             ,
                                , 'Show macro linked to current filename'
end

menu ExtMenu()
     Title = "Extension"
     history
    "&Write parms"              ,   mWriteParms(type_ext, do_msg)                          ,
                                , 'Write parms for current file extension'
    "&Clear parms"              ,   mClearEditParms(type_ext, do_msg)                   ,
                                , 'Erase parms for current file extension'
    "Load &Parms"               ,   mLoadParms(type_ext, do_msg)                      ,
                                , 'Load parms for current file extension'
    ""                          ,                      ,   Divide
    "&Link macro"               ,   mLinkMac(type_ext, do_msg)                             ,
                                , 'Link macro to current file extension'
    "&Unlink macro"             ,   mUnlinkMac(type_ext, do_msg)                            ,
                                , 'Unlink macro from current file extension'
    "&Show link"                ,   mShowMac(type_ext)                             ,
                                , 'Show macro linked to current extension'
end

menu DirMenu()
     Title = "Directory"
     history
    "&Write parms"              ,   mWriteParms(type_dir, do_msg)                          ,
                                , 'Write parms for directory of current file'
    "&Clear parms"              ,   mClearEditParms(type_dir, do_msg)                   ,
                                , 'Erase parms for directory of current file'
    "Load &Parms"               ,   mLoadParms(type_dir, do_msg)             ,
                                , 'Load parms for directory of current file'
    ""                          ,                      ,   Divide
    "&Link macro"               ,   mLinkMac(type_dir, do_msg)                     ,
                                , 'Link macro to directory of current file'
    "&Unlink macro"             ,   mUnlinkMac(type_dir, do_msg)                     ,
                                , 'Unlink macro from directory of current file'
    "&Show link"                ,   mShowMac(type_dir)                             ,
                                , 'Show macro linked to directory of current file'
end

menu DriveMenu()
     Title = "Drive"
     history
    "&Write parms"              ,   mWriteParms(type_drive, do_msg)                          ,
                                , 'Write parms for drive of current file'
    "&Clear parms"              ,   mClearEditParms(type_drive, do_msg)                   ,
                                , 'Erase parms for drive of current file'
    "Load &Parms"               ,   mLoadParms(type_drive, do_msg)             ,
                                , 'Load parms for drive of current file'
    ""                          ,                      ,   Divide
    "&Link macro"               ,   mLinkMac(type_drive, do_msg)                     ,
                                , 'Link macro to drive of current file'
    "&Unlink macro"             ,   mUnlinkMac(type_drive, do_msg)                     ,
                                , 'Unlink macro from drive of current file'
    "&Show link"                ,   mShowMac(type_drive)                             ,
                                , 'Show macro linked to drive of current file'
end


menu FilePalMenu()
     Title = "FilePal"
     history
     x=57
     y=10
    "&AutoTrack"
     [iif(auto_track, 'ON', 'OFF'):3]
                                ,   mToggleAutoTrack()                         ,
                                , 'Toggle AutoTrack for current file'
    "&File Name    "           ,   FileMenu()                      , DontClose
                                , 'Relative to current filename'
    "&Directory    "           ,   DirMenu()                       , DontClose
                                , 'Relative to directory of current file'
    "&Extension    "           ,   ExtMenu()                       , DontClose
                                , 'Relative to current file extension'
    "D&rive    "               ,   DriveMenu()                       , DontClose
                                , 'Relative to directory of current file'
    "parm buffer"               ,                      ,   Divide
    "&View buffer"              ,   mViewBuffer()                   ,
                                , 'Display buffer contents'
    "Re&load"                  ,   mCascadeParms()                  ,
                                , 'Reload settings for current file'
    "&Cleanup"                  ,   mCleanBuffer()                  ,
                                , 'Delete obsolete filenames and paths'
end

proc mInvokeMenu()
    if restoring
        Message('FILEPAL inhibited by Restore State')
        return()
    elseif GetBufferId() == parm_buffer   // si le menu est appel‚ alors
        GotoBufferId(active_file)        // que le buffer est affich‚
        Disable(inbuffer)
        UpdateDisplay()
    else
        active_file = GetBufferId()
        if not GotoBufferId(parm_buffer)  // v‚rifier que le buffer est l…
            Message('!!! FilePal error 5: Cannot find Parm Buffer')
            halt
        endif
        GotoBufferId(active_file)
    endif
    FilePalMenu()
end

<Ctrl F11>      mInvokeMenu()
