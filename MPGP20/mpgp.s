// ************************************************************************/
//
// 01-08-94: Submitted by Steve Schwartz
// 08-19-94: Revised to use picklist for Public Key Selection.
//           Code for picklist Written by George De Bruin
//           and modified slightly by Steve Schwartz
//
// MPGP - User interface for use with PGP (Pretty Good Provacy) Public
//        Key Encryption system from within The Semware Editor.
//        This User interface is completely menu driven. All user
//        definable variables, for command line options to be passed to
//        PGP, are also toggles from a pulldown menu.
//
// All questions regarding this set of macros should be directed to:
// Steve Schwartz via Internet e-mail: highmage@astral.scvl.ca.us or via
// the Semware BBS.
//
// DESCRIPTION AND NOTES:
//
// These macros were written for use with my e-mail system. I use
// UUPC/Extended 1.11x (or later), and the Public Key Encryption system PGP
// 2.3a (or later). Minor modification will be required in Dpgp() and
// CleanUp() in order to use them with another e-mail system.
//
// I have taken Don Dougherty's code that gets and restores the cursors
// current position, and made two separate macros out of it. These macros
// are: GetPos() and RestPos(), they use the below listed Global Variables:
//
// The ReQuote() Procedure was taken from Mel Hulse's Quote() Macro. The
// rest of the code is a modification of Don Dougherty's ShareSpell macro.
//
// This Procedure, along with CleanUp(), check to see if the ciphertext
// is a reply to Internet e-mail or not. If it is, the quote marks (> ),
// that are most commonly used over Internet, will be removed from the
// ciphertext, and replced into the decrypted message.
//
// Note: See the PGP Documentation for information in the user definable
//       global variables. I have preset them to sign the plaintext
//       before encrypting, and output the ciphertext in ASCII Radix-64
//       format for transmission via e-mail.
//
// Epgp():
// Macro to Execute "PGP -e[opts]" on the current file to encrypt.
//
// Note: This procedure need not be used with any specific e-mail
//       system.
//
// Dpgp():
// Macro to Execute "PGP" on the current file to decrypt reply to mail
//                   received via UUPC/Extended 1.11x (or later). This
//                   will take only cipertext paragraph to be processed.
//                   Then reinsert plaintext in place of ciphertext.
//
// I have added the ability to check to see if the ciphertext is an
// Internet based e-mail reply, if it is, Cleanup() and ReQuote will
// remove, and replace the quote marks used on Internet e-mail
//
// Note: This procedure was written with for the specific reason of
//       decrypting mail received via UUPC/Extended. If you wish to use
//       it with any other e-mail system, such as MegaMail, it will
//       require a certain amount of modification to accomidate the file
//       structure of 'reply to' mail from these other systems.
//
// Revisions: This version contains a picklist feature for choosing Public
//            keys instead of typing in the recipients name when asked.
//            The routines for this are modified from code written by
//            George De Bruin of Semware Technical Support.
//
// EXTERNAL GLOBAL VARIABLES:
// These external global variables are for use by GetPos() and RestPos.
// Do not change these variables
//
//              cline       - current line in file
//              cpos        - current pos in file
//              cxofs       - current XOffset in window
//              crow        - current row in window
//
// OTHER GLOBAL VARIABLES: (defined by SetGlobalInt() & SetGlobalStr())
//   see UserGlobals() for information on these user definable global
//   variables.
//
//              Clearsig      Unix
//              Radix         KeyRing
//              Sign          Wipe
//              Text          Conv
//              Verbose       YourKey
//              More
//
// SYSTEM GLOBAL VARIABLES: (defined by SetGlobalInt() & SetGlobalStr())
// These global variables should not be changed, they define the files
// used by these macros and PGP. After Encryption or Decryption,
// dfilename and/or nfilename are deleted, to save diskspace and for
// security reasons.
//
//              env         - the environment variable PGPPATH as setup
//                            in AUTOEXEC.BAT
//              cfilename   - string that is loaded with the current
//                            filename.
//              dfilename   - encrypted filename (Dpgp() only).
//              nfilename   - encrypted filename from Epgp() or
//                            the decrypted filename from Dpgp().
//              KeyFile     - the name of the file that will contain your
//                            Publickey list to pick from.
//
// ************************************************************************/

    Integer cline, cpos, cxofs, crow
    Integer GBSilent
    Integer GBGpgReady
    Integer GIKeyBufferId
    String GSVersion[20]
    String GSIniFile[255]
    String GSGpgExe[255]
    String GSLocalUser[255]
    String GSProgramDir[255]

Proc LoadSettings()
    Integer originalBufferId
    String settingLine[255], lowerSettingLine[255]

    GBSilent = FALSE
    GSProgramDir = SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_)
    GSIniFile = GSProgramDir + "mpgp20.ini"
    GSGpgExe = "gpg.exe"
    GSLocalUser = ""

    if FileExists(GSIniFile)
        originalBufferId = GetBufferId()
        EditFile(GSIniFile)
        BegFile()
        repeat
            settingLine = GetText(1, 255)
            lowerSettingLine = Lower(settingLine)
            if lowerSettingLine == "silent=true"
                GBSilent = TRUE
            elseif lowerSettingLine == "silent=false"
                GBSilent = FALSE
            elseif SubStr(lowerSettingLine, 1, 4) == "gpg="
                GSGpgExe = SubStr(settingLine, 5, 251)
            elseif SubStr(lowerSettingLine, 1, 10) == "localuser="
                GSLocalUser = SubStr(settingLine, 11, 245)
            endif
        until not Down()
        AbandonFile()
        GotoBufferId(originalBufferId)
    endif
End

Proc Exec(string cmnd, Integer flag)
    Dos('"' + GSGpgExe + '" ' + cmnd, flag)
End

Proc ShowGpgFailure()
    if FileExists(GetGlobalStr("gpglog"))
        EditFile(GetGlobalStr("gpglog"))
        Warn("GnuPG did not create the expected output. Its diagnostic log is now open in TSE.")
    else
        Warn("GnuPG did not create the expected output and no diagnostic log was created. Check the gpg.exe path.")
    endif
End

/* ************************************************************************
    Macro: piView()
    Authors: SEM, SW, KAC, GDB
    Revised: GDB
    Date: 06/11/94

    Notes:

    Based on ListIt() in TSE.S.  Difference is extra parameters, and returns
    number of selected line in the buffer (if any).

   ************************************************************************ */

Integer Proc piView(string sHead, integer iWidth,
                                            integer iHeight, integer iSearch)

    integer rc = 0

    if iWidth > Query(ScreenCols)    // Make sure the window width isn't wider
        iWidth = Query(ScreenCols)   // than the screen
    endif
    if iHeight > Query(ScreenRows)   // Make sure the window height isn't taller
        iHeight = Query(ScreenRows)  // than the screen
    endif
    if not iSearch
        iSearch = _ENABLE_SEARCH_   // Assume non-anchored search
    endif
    rc = lList(sHead, iWidth, iHeight, iSearch)
    return(rc)
end /* piView() */

String Proc GetUidField(string keyLine)

    Integer charI, fieldI, startI
    String resultS[255]

    fieldI = 1
    startI = 1
    resultS = ""
    for charI = 1 to Length(keyLine) by 1
        if SubStr(keyLine, charI, 1) == ":"
            if fieldI == 10
                resultS = SubStr(keyLine, startI, charI - startI)
                return(resultS)
            endif
            fieldI = fieldI + 1
            startI = charI + 1
        endif
    endfor
    if fieldI == 10
        resultS = SubStr(keyLine, startI, 255)
    endif
    return(resultS)
End

String Proc GetKeyList()

    integer cid = GetBufferId()       // Get Current Buffer Id
    integer pLine = 0
    string cLine[255] = ""            // Store Line here

    if GIKeyBufferId
        GotoBufferId(GIKeyBufferId)
        pLine = piView("GnuPG Public Keys - select a uid: line", 70, 25, _ENABLE_SEARCH_)
        if pLine
            MarkLine()
            cLine = GetMarkedText()
            UnMarkBlock()
            if SubStr(cLine, 1, 4) == "uid:"
                cLine = GetUidField(cLine)
            else
                Warn("Select a line beginning with uid: from the GnuPG key list.")
                cLine = ""
            endif
        else
            cLine = ""
            Message("No key selected.")
        endif
    else
        Warn("The GnuPG key-list buffer is not available. Recreate the key list and try again.")
    endif
    GotoBufferId(cid)
    return(cLine)                     // Return the line
end

Integer Proc LoadKeyFile()
    integer cid = GetBufferId(),
            pid

    EditFile(GetGlobalStr("KeyFile"))
    Buffertype(_HIDDEN_)
    pid = GetBufferId()
    GIKeyBufferId = pid
    GotoBufferId(cid)
    return(pid)
end

Integer Proc CreateKeyFile()
    integer cid = GetBufferID(),
            pid

    if GIKeyBufferId
        GotoBufferId(GIKeyBufferId)
        AbandonFile()
        GIKeyBufferId = 0
        GotoBufferId(cid)
    endif
    Exec('--batch --with-colons --list-keys > "' + GetGlobalStr("KeyFile") + '"', _DONT_PROMPT_)
    EditFile(GetGlobalStr("KeyFile"))
    SaveFile()
    AbandonFile()
    GotoBufferId(cid)
    pid = LoadKeyFile()
    Return(pid)
end

String Proc UserFormat()
    string nuser[255] = ""
    nuser = GetKeyList()
    return('"' + nuser + '"')
end

Proc AddKey()
    SetGlobalStr("cfilename", CurrFileName())
    Exec('--import "' + GetGlobalStr("cfilename") + '"', _DONT_PROMPT_)
End

Proc CopyKey()
    SetGlobalStr("cfilename", CurrFileName())
    Exec('--armor --output "' + GetGlobalStr("cfilename") + '.public.asc" --export ' + UserFormat(), _DONT_PROMPT_)
End

Proc RemKey()
    Exec("--delete-keys " + UserFormat(), _DONT_PROMPT_)
End

Proc VKey()
    Exec("--list-keys " + UserFormat(), _DONT_PROMPT_)
End

Proc Finger()
    Exec("--fingerprint " + UserFormat(), _DONT_PROMPT_)
End

Proc VSig()
    Exec("--list-signatures " + UserFormat(), _DONT_PROMPT_)
End

Proc EditTrust()

    Exec("--edit-key " + UserFormat(), _DONT_PROMPT_)
End

Proc VCert()
    Exec("--list-signatures " + UserFormat(), _DONT_PROMPT_)
End

Proc RevCert()
    Warn("GnuPG signature revocation needs both key fingerprints. Use gpg --quick-revoke-sig from a command prompt.")
End

Proc CertKey()
    Exec("--sign-key " + UserFormat(), _DONT_PROMPT_)
End

Proc DisEnKey()
    Exec("--edit-key " + UserFormat(), _DONT_PROMPT_)
End

Proc CertSig()
    SetGlobalStr("cfilename", CurrFileName())
    Exec('--armor --detach-sign --local-user "' + GetGlobalStr("YourKey") + '" "' + GetGlobalStr("cfilename") + '"', _DONT_PROMPT_)
End

Proc DetSig()
    Warn("Use GnuPG --verify with the detached signature and original file.")
End

Proc EditKey()
    Exec('--edit-key "' + GetGlobalStr("YourKey") + '"', _DONT_PROMPT_)
End

Proc RevokeKey()
    Exec('--generate-revocation "' + GetGlobalStr("YourKey") + '"', _DONT_PROMPT_)
End

Proc CreateKey()
    Exec("--full-generate-key", _DONT_PROMPT_)
End

//  OnOffGlob() returns "On" if GetGlobalInt(s) = True, otherwise "Off".

string  Proc OnOffGlob (string s)
    Return(iif(GetGlobalInt(s),"On","Off"))
End

//  ToggleOnOff() returns toggled value and sets global variable s true/false.

integer Proc ToggleOnOff  (string s)
    Return(SetGlobalInt(s,iif(GetGlobalInt(s),0,1)))
End

//  ToggleStr() returns toggled value and sets global variable s.

integer Proc ToggleStr  (string s)
    Return(SetGlobalInt(s,iif((GetGlobalInt(s)==1),0,GetGlobalInt(s)+1)))
End
string  Proc RingType   (string s)
    case GetGlobalInt(s)
        when 0 Return("Public")
        when 1 Return("Secret")
    endcase
    Return("")
End

string  Proc EncryType   (string s)
    case GetGlobalInt(s)
        when 0 Return("Public Key  ")
        when 1 Return("Conventional")
    endcase
    Return("")
End

// Get the current cursor position in the current file.
Integer Proc GetPos()
    cline = CurrLine()      // this saves our position in the file
    cpos  = CurrPos()
    cxofs = CurrXOffset()
    crow  = CurrRow()
    Return(cline)
    Return(cpos)
    Return(cxofs)
    Return(crow)
End GetPos

// Restore cursor to postion retrieved by GetPos()
Proc RestPos(Integer cline, Integer cpos, Integer cxofs, Integer crow)
    GotoLine(cline)         // restore our position in the file
    GotoPos(cpos)
    GotoXOffset(cxofs)
    ScrollToRow(crow)
End RestPos

Integer Proc CleanUp()
    sound(0, 1)
    Find("-----BEGIN PGP", "I")
    MarkLine()
    Find("-----END PGP", "I")
    Cut()
    SaveFile()

    GetPos()                // get current position in file

    PushBlock()             // just in case a block is currently marked

    EditFile (GetGlobalStr("dfilename"))
    Paste()
    if (Find("> ", "I") <> 0)
       Find("-----BEGIN PGP", "I")
       GotoColumn(1)
       MarkColumn()
       Find("-----END PGP", "I")
       GotoColumn(2)
       DelBlock()
       SetGlobalInt("Quote",1)
    else
       SetGlobalint("Quote",0)
    endif

    BegFile()
    SaveFile()
    AbandonFile()
    sound(1, 1)

    Return(cline)           // return current position information
    Return(cpos)
    Return(cxofs)
    Return(crow)
End CleanUp

// Insert a column of quote marks (> ) ahead of the plaintext.
Proc ReQuote()
    EditFile(GetGlobalStr("nfilename"))
    if (GetGlobalInt("Quote") == 1)
       EndFile()
       CReturn()
       BegLine()

       Repeat
           Up()
           BegLine()
           InsertText( "> ", _INSERT_ )
       Until CurrLine() == 2
       EndFile()
       DelLine()
       SaveFile()
       AbandonFile()
    else
       SaveFile()
       AbandonFile()
    endif
End ReQuote

Proc Epgp()
    String commandS[255], recipientS[255]
    Integer proceedB

    proceedB = TRUE
    SetGlobalStr("cfilename", CurrFileName())
    SetGlobalStr("efilename", SplitPath(GetGlobalStr("cfilename"), _DRIVE_ | _PATH_ | _NAME_) + iif(GetGlobalInt("Radix"), ".asc", ".gpg"))
    SetGlobalStr("gpglog", SplitPath(GetGlobalStr("cfilename"), _DRIVE_ | _PATH_) + "mpgp20_gpg.log")
    SaveFile()

    commandS = ""
    if GetGlobalInt("Radix")
        commandS = commandS + "--armor "
    endif
    if GetGlobalInt("Text")
        commandS = commandS + "--textmode "
    endif
    if GetGlobalInt("Sign")
        if GetGlobalStr("YourKey") == ""
            Warn("Set localuser= in mpgp20.ini before enabling signing.")
            proceedB = FALSE
        else
            commandS = commandS + '--sign --local-user "' + GetGlobalStr("YourKey") + '" '
        endif
    endif
    if proceedB
        if GetGlobalInt("Conv")
            commandS = commandS + "--symmetric "
        else
            recipientS = UserFormat()
            if recipientS == '""'
                proceedB = FALSE
            else
                commandS = commandS + "--encrypt --recipient " + recipientS + " "
            endif
        endif
    endif
    if proceedB
        commandS = commandS + '--output "' + GetGlobalStr("efilename") + '" "' + GetGlobalStr("cfilename") + '" 2> "' + GetGlobalStr("gpglog") + '"'
        Exec(commandS, _DONT_PROMPT_)
        if FileExists(GetGlobalStr("efilename"))
            EditFile(GetGlobalStr("efilename"))
            Message("GnuPG encryption complete. The original file was preserved.")
        else
            ShowGpgFailure()
        endif
    endif
End

Proc EncryptPublic()
    SetGlobalInt("Conv", 0)
    Epgp()
End

Proc EncryptSymmetric()
    SetGlobalInt("Conv", 1)
    Epgp()
End
//
// End of EPGP()

// Locate the ciphertext paragraph, writes it to a temp file, then removes
// the quote marks (> ) preceeding the ciphertext.
Proc Dpgp()
    String commandS[255]

    SetGlobalStr("cfilename", CurrFileName())
    SetGlobalStr("nfilename", SplitPath(GetGlobalStr("cfilename"), _DRIVE_ | _PATH_ | _NAME_) + ".decrypted")
    SetGlobalStr("gpglog", SplitPath(GetGlobalStr("cfilename"), _DRIVE_ | _PATH_) + "mpgp20_gpg.log")
    SaveFile()
    commandS = '--output "' + GetGlobalStr("nfilename") + '" --decrypt "' + GetGlobalStr("cfilename") + '" 2> "' + GetGlobalStr("gpglog") + '"'
    Exec(commandS, _DONT_PROMPT_)
    if FileExists(GetGlobalStr("nfilename"))
        EditFile(GetGlobalStr("nfilename"))
        Message("GnuPG decryption complete. The encrypted file was preserved.")
    else
        ShowGpgFailure()
    endif
End
//
// End of DPGP()

// These user defaults can be changed to accomidate the User's
// preferences. You should put, your name or a portion of your name, as
// you used when you created your Public/Secret Key Pair.
// These defaults, except for 'YourKey' are also Toggles in the Options Menu
Proc UserGlobals()
     SetGlobalInt("Clearsig",0)   // encapsulate as Clear Text
     SetGlobalInt("Radix",1)      // ciphertext in ASCII-Radix-64 format
     SetGlobalInt("Sign",0)       // signing is optional
     SetGlobalInt("Text",0)       // option to convert to canonical text
     SetGlobalInt("Verbose",0)    // extended keyring listing
     SetGlobalInt("More",0)       // display message on screen only
     SetGlobalInt("Unix",0)       // Unix-style filter mode
     SetGlobalInt("KeyRing",0)    // which keyring file to use
     SetGlobalInt("Wipe",0)       // to wipe out plaintext completely
     SetGlobalInt("Conv",0)       // for conventional encryption
     SetGlobalStr("YourKey", GSLocalUser)
End

// These are system Global Variables, DO NOT CHANGE THESE !!!
Proc PGPGlobals()
     UserGlobals()

     SetGlobalStr("cfilename", CurrFileName())
     SetGlobalStr("nfilename", SplitPath(GetGlobalStr("cfilename"), _DRIVE_ | _PATH_ | _NAME_) +".decrypted")
     SetGlobalStr("efilename", SplitPath(GetGlobalStr("cfilename"), _DRIVE_ | _PATH_ | _NAME_) +".asc")
     SetGlobalStr("dfilename", SplitPath(GetGlobalStr("cfilename"), _DRIVE_
                               | _PATH_ | _NAME_) +".gpg")
     SetGlobalStr("tfilename", SplitPath(GetGlobalStr("cfilename"), _DRIVE_
                               | _PATH_ | _NAME_) +".stv")
     SetGlobalStr("KeyFile", GSProgramDir + "mpgp20_keys.lst")
     SetGlobalStr("gpglog", SplitPath(GetGlobalStr("cfilename"), _DRIVE_ | _PATH_) + "mpgp20_gpg.log")
End

// Menus

Menu PGP_Menu()
    "Encrypt with &Public Key" , EncryptPublic()
    "Encrypt with &Passphrase" , EncryptSymmetric()
    "&Decrypt Message"      ,   Dpgp()
    "&Create Keylist File"  ,   CreateKeyFile()
End

Menu KeyMaint()
    "&Add Key",                 AddKey()
    "&Copy Key",                CopyKey()
    "&Remove Key",              RemKey()
    "&View Keyring",            VKey()
    "&FingerPrint",             Finger()
    "View &Signiture",          VSig()
    "&Edit Trust Parms",        EditTrust()
End

Menu Cert_Menu()
    "&View Certifications",     VCert()
    "&Revoke a Certificate",    RevCert()
    "&Certify a Key",           CertKey()
    "Disable/&Enable a Key",    DisEnKey()
    "&Signiture Certificate",   CertSig()
    "&Detach a Signiture",      DetSig()
End

Menu Revoke_Menu()
    "&Edit Your UserID/Passphrase",     EditKey()
    "&Revoke Your Key",                 RevokeKey()
    "&Create Key Pair",                 CreateKey()
End

Menu Options_Menu()
    "&ASCII Armor"          [OnOffGlob("Radix"):3]      ,
                            ToggleOnOff("Radix")        ,   DontClose
    "&Sign"                 [OnOffGlob("Sign"):3]       ,
                            ToggleOnOff("Sign")         ,   DontClose
    "&Textmode"             [OnOffGlob("Text"):3]       ,
                            ToggleOnOff("Text")         ,   DontClose
End

MenuBar MainMenu()
    "&PGP"      ,             PGP_Menu()
    "&KeyMaint" ,             KeyMaint()
    "&Certification",         Cert_Menu()
    "Create/&Revoke Keys",    Revoke_menu()
    "&Options"  ,             Options_Menu()
End

Proc Main()
    GSVersion = "1.0.0.0.7"
    GIKeyBufferId = 0
    LoadSettings()

    GBGpgReady = FileExists(GSGpgExe)
    if not GBGpgReady
        if Ask("Full path to gpg.exe:", GSGpgExe, _EDIT_HISTORY_)
            GBGpgReady = FileExists(GSGpgExe)
        endif
    endif

    if GBGpgReady
        if not GBSilent
            Warn("MPGP20 " + GSVersion + ": menu-driven GnuPG encryption, decryption, and key management. Original files are preserved, but backups are recommended.")
        endif
        PGPGlobals()
        if not FileExists(GetGlobalStr("KeyFile"))
            CreateKeyFile()
        else
            LoadKeyFile()
        endif
        MainMenu()
    else
        Warn("GnuPG was not found. Set gpg= in mpgp20.ini or enter the full path when prompted.")
    endif
End

// Keys for future use.
// comment out <Ctrl d> in your TSE.UI file.

<Ctrl e>        Epgp()
<Ctrl d>        Dpgp()
