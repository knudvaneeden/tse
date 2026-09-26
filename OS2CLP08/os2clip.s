/************************************************************************\
  OS2CLIP.S   OS/2 clipboard access for TSE 2.5

  Author:     Dr. Sieghard Schicktanz, Kreidestr. 12, 8196 Achmuehle

  Date:       Sep 13, 1995 - Initial version
              Sep 17, 1995 - Improved version,
                             starts clip server automatically
              Oct 29, 1995 - Supports window clips now
              Nov 19, 1995 - Now running on OS/2 Warp also!

  Overview:

  This macro provides an interface to the OS/2 clipboard by means of a
  native server application (CSERVER.EXE) which must be running in order
  to get access to the clipboard contents.
  Of course, only text entries are supported.
  Cut, paste and copy operations are provided.
  Pasting into prompt boxes is also possible.

  Keys:     <Shift Ins>  Paste clipboard contents into current buffer
            <Ctrl Ins>   Copy current block or buffer to clipboard
            <Shift Del>  Move current block or buffer to clipboard
            <Ctrl Del>   Cut current block and discard it
                         (not in prompt boxes)

  Usage notes:

  The server application "CSERVER.EXE" - an OS/2 native program - must be
  running in order for the clipboard functions to work. If it does not, no
  operation is performed and an error message is displayed (using Warn ()).
  An error message is also displayed if the attempted access did fail for
  some other reason.

  After some experimentation, I finally found a way to get text copied into
  the clipboard from a text window. I had another opportunity to test the
  safety of backups made with the OS/2 version of tar... But now it works!
  So with this version, it _is_ now possible to paste text put into the
  clipboard by marking some text in a text window using the menu function.
  (And - strangely - the clip server program actually became more compact!)

  This achievement was somewaht compounded by the later finding that the
  server did not work under OS/2 Warp. So I had to rework the export func-
  tion yet again and find a means to make that functioning, too. I could
  solve the problem by direct export from an MLE control, which made the
  code a bit more straight forward but slightly larger again. But more
  important: now it works under Warp, too.

  This version also can start up the clip server program by itself (when
  loaded into TSE), relying on the separate macro "OS2Start" also provided
  in the package.
  The macro searches the TSEpath and the mac\ subdirectory for the server
  program, so if it is placed there, there is no more the need to modify
  the code.
  "OS2Start" also allows to interactively start any program, Dos _or_ OS/2,
  even PM programs, from within TSE.
  The clip server program will start only once; attempts to start further
  copies will not be honoured. This was needed to allow "blind starting"
  CSERVER.EXE from the macro's WhenLoaded () procedure.

  Yes, and BTW: The usual disclaimer applies, of course -
  "This code is provided as is. I cannot make any warranty of any kind,
  express or implied, including but not restricted to its fitness for any
  particular purpose."
  In particular, it may NOT be sold, neither the complete package nor any
  part of it separately.
  (I had to include the last sentence because the CSERVER program is built
  using the current beta version of VirtualPascal for OS/2, which does not
  allow for any commercial application!)

\************************************************************************/

// the names of the server feeds - these can be accessed from plain Dos also,
//                                 but writing requires a special open function
string OutPipe [] = '\Pipe\OutC'    // "OutC" delivers the clipboard contents
string InPipe [] =  '\Pipe\InC'     // "InC" accepts new data to the clipboard
// below: the path definitions needed to load the clip server program
string ClipServer [] = 'cserver.exe'
string MacDir [] = 'mac'            // Subdirectory to eventually search also

constant                            // keys used
    PASTE_KEY =  <Shift Ins>,       // the key assignments are set up
    COPY_KEY =   <Ctrl Ins>,        // to "emulate" the usual clipboard
    CUT_KEY =    <Shift Del>,       // access combinations
    CLEAR_KEY =  <Ctrl Del>         // they need to get used to...

integer fError = 0                  // general error variable

integer proc fOpen2 (string fName)  // this is the special open function
    register R                      // needed for writing from Dos
    string fileName [255] = fName+ chr (0)

    R.AX= 0x6C01
    R.BX= 1     // _OPEN_READ_ONLY_
    R.CX= 0
    R.DX= 1
    R.SI= Ofs (fileName)+ 2
    R.DS= Seg (fileName)
    R.DI= 0
    R.ES= 0
    intr (0x21, R)

    if R.FLAGS & _flCARRY_
        fError= R.AX
        return (-1)
    endif

    return (R.AX)
end

// the rest is straight forward - only simplest functionality provided...

proc PipeInPrompt ()                // get first line only
    integer fromClip = fOpen (OutPipe)
    string InpLine [255] = ''

    if fromClip <> -1
        fRead (fromClip, InpLine, 255)
        fClose (fromClip)
        fromClip= Pos (chr (13), InpLine)
        if fromClip                 // contains CR?
            InpLine= InpLine [1..fromClip- 1]
        endif
        InsertText (InpLine)
    else
        Warn ('Could not read from Clipboard! Error #', fError)
     endif
end


proc PipeIn ()
    integer fromClip = fOpen (OutPipe),
            haveBlock = isBlockMarked ()

    if fromClip <> -1
        if haveBlock
            if isBlockInCurrFile ()
                GotoBlockBegin ()
                DelBlock ()
                haveBlock= FALSE
            else
                PushBlock ()
            endif
        endif

        PushPosition ()

        fReadFile (fromClip)
        fClose (fromClip)

        PopPosition ()

        if haveBlock
            PopBlock ()
        endif
    else
        Warn ('Could not read from Clipboard! Error #', fError)
     endif
end


integer proc fWriteBlock (integer BlockId, integer fHandle)
    integer BlockBuffer= CreateTempBuffer ()
    integer Success

    if BlockBuffer
        PushBlock ()
        GotoBufferId (BlockBuffer)
        CopyBlock ()
        Success= fWriteFile (fHandle)
        GotoBufferId (BlockId)
        AbandonFile (BlockBuffer)
        PopBlock ()
        return (Success)
    endif
    return (FALSE)
end


proc PipeOut ()
    integer toClip = fOpen2 (InPipe)

    if toClip <> -1
        if isCursorInBlock ()
            fWriteBlock (Query (BlockId), toClip)
        else
            fWriteFile (toClip)
        endif
        fClose (toClip)
    else
        Warn ('Could not write to Clipboard! Error #', fError)
    endif
end


proc PipeOutAndCut ()
    integer toClip = fOpen2 (InPipe)

    if toClip <> -1
        if isCursorInBlock ()
            if fWriteBlock (Query (BlockId), toClip)
                DelBlock ()
            endif
        else
            if fWriteFile (toClip)
                EmptyBuffer ()
            endif
        endif
        fClose (toClip)
    else
        Warn ('Could not write to Clipboard! Error #', fError)
    endif
end


proc CutAndDiscard ()           // just for completeness...

    if isCursorInBlock ()
        DelBlock ()
    endif
end


<PASTE_KEY>  PipeIn ()          // the key assignment are set up
<COPY_KEY>   PipeOut ()         // to "emulate" the usual clipboard
<CUT_KEY>    PipeOutAndCut ()   // access combinations
<CLEAR_KEY>  CutAndDiscard ()   // they need to get used to...


keydef ClipKeys
    <PASTE_KEY>     PipeInPrompt ()
    <COPY_KEY>      PipeOut ()
    <CUT_KEY>       PipeOutAndCut ()
end


// This is a hooked macro
proc ClipPromptStartup ()
    Enable (ClipKeys)
end


proc WhenPurged ()              // not strictly neccessary...
    UnHook (ClipPromptStartup)
end

proc WhenLoaded ()
    string ClipPath [255] = SearchPath (ClipServer, Query (TSEpath), MacDir)

    if ClipPath <> ''
        ExecMacro ('OS2Start '+ ClipPath)
        Hook (_PROMPT_STARTUP_, ClipPromptStartup)
    else
        Warn ('Could not find CSERVER.EXE')
    endif
end

proc main ()
    WhenLoaded ()
end