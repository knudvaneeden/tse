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

Proc Exec(string cmnd, Integer flag)
    Dos(GetGlobalStr("env")+"\pgp " + cmnd, flag)
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

String Proc GetKeyList()

    integer cid = GetBufferId()       // Get Current Buffer Id
    Integer pid = GetBufferId(GetGlobalStr("KeyFile"))  // Get PickList Buffer Id
    integer pLine = 0
    string cLine[80] = ""             // Store Line here

    GotoBufferId(pid)                 // Go to pick buffer
    pLine = piView("Public KeyRing", 50, 25, _ENABLE_SEARCH_)  // View picklist
    if pLine                          // If user picked a line
        MarkLine()                    // Mark it
        cLine = GetMarkedText()       // Copy it into a string
        UnMarkBlock()                 // Unmark the block
    else
        cLine = " "
        Message("No key selected.")   // Show if user didn't pick a line
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
    GotoBufferId(cid)
    return(pid)
end

Integer Proc CreateKeyFile()
    integer cid = GetBufferID(),
            pid

    Exec(format("-kv >"+GetGlobalStr("KeyFile")), _DONTPROMPT_)
    EditFile(GetGlobalStr("KeyFile"))
    MarkLine(1,3)
    DelBlock()
    EndFile()
    MarkLine()
    Up()
    DelBlock()
    BegFile()
    MarkColumn()
    GotoColumn(30)
    EndFile()
    DelBlock()
    SaveFile()
    AbandonFile()
    GotoBufferId(cid)
    pid = LoadKeyFile()
    Return(pid)
end

String Proc UserFormat()
    string nuser[40] = ""
    return(format(nuser, ' "', GetKeyList(), '" '))
end

String Proc GetGlEnv()
    return(GetGlobalStr("env") + iif(GetGlobalInt("KeyRing"),
           "\Pubring.pgp", "\Secring.pgp"))
end

Proc AddKey()
    Exec(format("-ka "+GetGlobalStr("cfilename")+" "+GetGlEnv()), _DEFAULT_)
End

Proc CopyKey()
    string opt[2]

    if(GetGlobalInt("Radix") == 0)
        opt = " "
    else
        opt = "a "
    endif

    Exec(format("-kx"+opt+UserFormat()+GetGlobalStr("cfilename")
                +" "+GetGlEnv()), _DEFAULT_)
End

Proc RemKey()
    Exec(format("-kr "+UserFormat()+GetGlEnv()), _DEFAULT_)
End

Proc VKey()
    String opt[2] = ""

    if(GetGlobalInt("Verbose") == 0)
        opt = " "
    else
        opt = "v "
    endif

    Exec(format("-kv"+opt+UserFormat()+GetGlEnv()), _DEFAULT_)
End

Proc Finger()
    Exec(Format("-kvc "+UserFormat()+GetGlEnv()), _DEFAULT_)
End

Proc VSig()
    Exec(format("-kc "+UserFormat()+GetGlEnv()), _DEFAULT_)
End

Proc EditTrust()

    Exec(format("-ke "+UserFormat()+GetGlEnv()), _DEFAULT_)
End

Proc VCert()
    Exec(format("-kc "+UserFormat()+GetGlEnv()), _DEFAULT_)
End

Proc RevCert()
    Exec(format("-krs "+UserFormat()+GetGlEnv()), _DEFAULT_)
End

Proc CertKey()
    Exec(format("-ks "+UserFormat()+GetGlEnv()), _DEFAULT_)
End

Proc DisEnKey()
    Exec(format("-kd "+UserFormat()), _DEFAULT_)
End

Proc CertSig()
    Exec(format("-sb "+GetGlobalStr("cfilename")+" "+"-u "
                     +GetGlobalStr("YourKey")), _DEFAULT_)
End

Proc DetSig()
    Exec(format("-kx "+GetGlobalStr("cfilename")+" "+"-u "
                     +GetGlobalStr("YourKey")), _DEFAULT_)
End

Proc EditKey()
    Exec(format("-ke "+GetGlobalStr("YourKey")+" "+GetGlEnv()), _DEFAULT_)
End

Proc RevokeKey()
    Exec(format("-kd "+GetGlobalStr("YourKey")), _DEFAULT_)
End

Proc CreateKey()
    Exec(format("-kg"), _DEFAULT_)
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
    sound(0)
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
    sound(1)

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
    string opt[18] = ""
    integer noask = 0

    if(GetGlobalInt("Radix") == 1 and GetGlobalInt("Sign") == 1
       and GetGlobalInt("Text") == 1 and GetGlobalInt("Unix") == 1)
        opt = "-feast "
    elseif (GetGlobalInt("Radix") == 1 and GetGlobalInt("Sign") == 1
       and GetGlobalInt("Text") == 1 and GetGlobalInt("More") == 1)
        opt = "-steam "
    elseif (GetGlobalInt("Radix") == 1 and GetGlobalInt("Sign") == 1
        and GetGlobalInt("Text") == 1 and GetGlobalInt("ClearSig") == 1)
        opt = "-sta +clearsig=on "
        noask = 1
    elseif (GetGlobalInt("Radix") == 1 and GetGlobalInt("Sign") == 1
       and GetGlobalInt("Text") == 1)
        opt = "-seat "
    elseif (GetGlobalInt("Wipe") == 1 and GetGlobalInt("Sign") == 1)
        opt = "-sew "
    elseif (GetGlobalInt("Radix") == 1 and GetGlobalInt("Sign") == 1)
        opt = "-sea "
    elseif (GetGlobalInt("Sign") == 1)
        opt = "-es "
    elseif (GetGlobalInt("Conv") == 1)
        opt = "-c "
        noask = 1
    else
        opt = "-e "
    endif

// If the current file has the same extension as the ciphertext file, then
// test this to make sure there is no conflict in filename.
    if(GetGlobalStr("cfilename") == GetGlobalStr("nfilename"))
        SetGlobalStr("cfilename", GetGlobalStr("tfilename"))
        ChangeCurrFilename(GetGlobalStr("tfilename"))
        EraseDiskFile(GetGlobalStr("nfilename"))
    endif

    BegFile()
    SaveFile()

    Exec(format(opt,GetGlobalStr("cfilename"), UserFormat()), _DONTPROMPT_)
                                                             // call PGP
    AbandonFile()           // get rid of the file so we can reload it
    EraseDiskFile(GetGlobalStr("cfilename"))
    EditFile(GetGlobalStr("cfilename"))     // reloads the file from disk
    InsertFile(GetGlobalStr("nfilename"))   // Insert ciphertext in place
                                            // of plaintext.
    UnMarkBlock()
    EndFile()               // position cursor at the end of the file
    CReturn()               // and insert <CR> for mail processor.
    EraseDiskFile(GetGlobalStr("nfilename"))   // delete plaintext file.
    Message("Encryption Complete!")
End
//
// End of EPGP()

// Locate the ciphertext paragraph, writes it to a temp file, then removes
// the quote marks (> ) preceeding the ciphertext.
Proc Dpgp()
    SaveFile()
    BegFile()

    CleanUp()               // remove quote marks (> ) from
                            // ciphertext from Internet reply mail.

    Exec(format(GetGlobalStr("dfilename")+" -o "+GetGlobalStr("nfilename"))
         , _DONTPROMPT_)       // Decrypt message body with PGP

    AbandonFile()              // get rid of the file so we can reload it
    EditFile(GetGlobalStr("cfilename"))     // reloads the file from disk

    RestPos(cline, cpos, cxofs, crow)
    PopBlock()              // restore block, if one was marked.

    ReQuote()                               // return quote marks (> )
                                            // to plaintext for Internet
                                            // reply mail.

    InsertFile(GetGlobalStr("nfilename"))   // insert plaintext into
                                            // message body in
                                            // place of ciphertext.

    UnMarkBlock()
    EraseDiskFile(GetGlobalStr("nfilename"))  // deletes ciphertext file
    EraseDiskFile(GetGlobalStr("dfilename"))  // deletes plaintext file
                                              // for security.
    SaveFile()
    BegFile()
    Message("Decryption Complete!")
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
     SetGlobalInt("Sign",1)       // Sign plaintext with you secret key
     SetGlobalInt("Text",0)       // option to convert to canonical text
     SetGlobalInt("Verbose",0)    // extended keyring listing
     SetGlobalInt("More",0)       // display message on screen only
     SetGlobalInt("Unix",0)       // Unix-style filter mode
     SetGlobalInt("KeyRing",0)    // which keyring file to use
     SetGlobalInt("Wipe",0)       // to wipe out plaintext completely
     SetGlobalInt("Conv",0)       // for conventional encryption
     SetGlobalStr("YourKey", "Steve Schwartz")   // Put your name here
End

// These are system Global Variables, DO NOT CHANGE THESE !!!
Proc PGPGlobals()
     UserGlobals()

     SetGlobalStr("env", GetEnvStr("PGPPATH"))
     SetGlobalStr("cfilename", CurrFileName())
     SetGlobalStr("nfilename", SplitPath(GetGlobalStr("cfilename"), _DRIVE_
                               | _PATH_ | _NAME_) +".asc")
     SetGlobalStr("dfilename", SplitPath(GetGlobalStr("cfilename"), _DRIVE_
                               | _PATH_ | _NAME_) +".pgp")
     SetGlobalStr("tfilename", SplitPath(GetGlobalStr("cfilename"), _DRIVE_
                               | _PATH_ | _NAME_) +".stv")
     SetGlobalStr("KeyFile", GetGlobalStr("env")+"\keyring.lst")
End

// Menus

Menu PGP_Menu()
    "&Encrypt Message"      ,   Epgp()
    "&Decrypt Message"      ,   Dpgp()
    "&Create Keylist File"  ,   CreateKeyFile()
    "Encryption &Type"          [EncryType("Conv"):12]  ,
                                ToggleStr("Conv")       ,   DontClose
End

Menu KeyMaint()
    "&KeyRing"                  [RingType("KeyRing"):6] ,
                                ToggleStr("KeyRing")    ,   DontClose
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
    "&Clearsig"             [OnOffGlob("ClearSig"):3]   ,
                            ToggleOnOff("ClearSig")     ,   DontClose
    "&Radix-64"             [OnOffGlob("Radix"):3]      ,
                            ToggleOnOff("Radix")        ,   DontClose
    "&Sign"                 [OnOffGlob("Sign"):3]       ,
                            ToggleOnOff("Sign")         ,   DontClose
    "&Textmode"             [OnOffGlob("Text"):3]       ,
                            ToggleOnOff("Text")         ,   DontClose
    "&Verbose Listing"      [OnOffGlob("Verbose"):3]    ,
                            ToggleOnOff("Verbose")      ,   DontClose
    "View &Only"            [OnOffGlob("More"):3]       ,
                            ToggleOnOff("More")         ,   DontClose
    "&Unix-Style Filter"    [OnOffGlob("Unix"):3]       ,
                            ToggleOnOff("Unix")         ,   DontClose
    "&Wipe PlainText"       [OnOffGlob("Wipe"):3]       ,
                            ToggleOnOff("Wipe")         ,   DontClose
End

MenuBar MainMenu()
    "&PGP"      ,             PGP_Menu()
    "&KeyMaint" ,             KeyMaint()
    "&Certification",         Cert_Menu()
    "Create/&Revoke Keys",    Revoke_menu()
    "&Options"  ,             Options_Menu()
End

Proc Main()
    Integer pid
    PGPGlobals()

    if not FileExists(GetGlobalStr("KeyFile"))
        pid = CreateKeyFile()
    else
        pid = LoadKeyFile()
    endif

    MainMenu()
End

// Keys for future use.
// comment out <Ctrl d> in your TSE.UI file.

<Ctrl e>        Epgp()
<Ctrl d>        Dpgp()
