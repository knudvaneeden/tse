Author: Chris Shuffett

Date: 5/11/2000

Purpose: To demonstrate how to customize the sign-on screen which displays when
the editor is first invoked and which also displays after the last file is quit
if quit-to-prompt is turned on.

Contents:
Dly_log.s - An example macro to demonstrate calling a macro from the customized
sign-on screen.  Compile this into your path for supplemental files.

Readme.txt - This readme file.

Superc.ui - A comparison of the original TSE-Pro v2.8 user interface with a
version with the modifications.

Instructions:
Examine the Superc.ui file in order to determine how to modify your tse.ui
file. To see the full effect of these changes you'll want to select the
PROMPT Empty Command-Line Action and turn on the EditFile Prompt on Quit
interactive options.

The signon line in the original TSE-Pro v2.8 user interface is located in the
WhenLoaded procedure and is surrounded by text which looks like this.

    // _STARTUP_PROMPT_ case and error loading specified file cases come here
    if NumFiles() == 0
        SignOn()
        EditFile()
    endif

With the modifications in place the user interface will then look like this.

    // _STARTUP_PROMPT_ case and error loading specified file cases come here
    if NumFiles() == 0
        mSignOn()
        Hook(_PROMPT_STARTUP_, mEditStartup)
        EditFile()
        Dos("EXIT", _DONT_PROMPT_|_DONT_CLEAR_)
        UnHook(mEditStartup)
        Disable(EditPromptKeys)

        if Query(QuitToPrompt)
            Hook(_ON_FILE_QUIT_, mSignOnReturn)
        endif
    endif

Notes:  This has been tested with Win95, Win98, and WinNT4.  Several
differences were found between these operating systems.  For Win95 users you
may want to change the DOS(start...) command.  On NT the mouse clicks from the
calling session are some how passed to the new session causing miss positioning
of the cursor in the daily log file.  Also incorporated into this demonstration
is a modified version of the Maximize/Restore macro posted to the discussion
group by Michael Durland on 8/17/99.
