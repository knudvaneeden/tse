/*
   Macro          EdWihTSE.
   Author         Carlo.Hogeveen@xs4all.nl.
   Date           1 Aug 2004.
   Compatibility  TSE 4.0 upwards.

   This is a more interactive version of the macro posted by Sammy Mitchell,
   which was the same as the "Edit with TSE" option you get when you install
   TSE.

   Dutch was added as an alternative language, depending on the existence
   of the constant DUTCH. You can enable/disable Dutch by respectively
   uncommenting/commenting the line "#define DUTCH TRUE".
*/

// #define DUTCH TRUE

#ifdef DUTCH
   string text1  [40] = '"Bewerken met TSE" wordt toegevoegd ... '
   string text2  [18] = "&Bewerken met TSE"
   string text3  [33] = '"Bewerken met TSE" is toegevoegd.'
   string text4  [40] = '"Bewerken met TSE" wordt verwijderd ... '
   string text5  [33] = '"Bewerken met TSE" is verwijderd.'
   string text6  [75] = 'Toevoegen van een "Bewerken met TSE" keuze aan het Windows rechtermuismenu.'
   string text7 [255] = "Waarschuwing: deze menukeuze kan conflicteren met de MS-Office Snelkoppeling Balk. "
                      + "Je kunt de menukeuze echter altijd weer verwijderen."
                      + Chr(13)
                      + "Wil je doorgaan?"
   string text8  [33] = '"Bewerken met TSE" is toegevoegd.'
   string text9  [12] = "Geannuleerd."
#else
   string text1  [35] = '"Edit with TSE" is being added ... '
   string text2  [14] = "Edit with &TSE"
   string text3  [31] = '"Edit with TSE" has been added.'
   string text4  [37] = '"Edit with TSE" is being deleted ... '
   string text5  [36] = '"Edit with TSE" has been deleted.'
   string text6  [65] = 'Adding an "Edit with TSE" choice to the Windows Right-Mouse menu.'
   string text7 [255] = "Warning: this menu-choice can conflict with the MS-Office Shortcut Bar."
                      + Chr(13)
                      + "On the other hand you can always remove this menu-choice later on."
                      + Chr(13)
                      + "Do you wish to continue?"
   string text8  [22] = '"Edit with TSE" added.'
   string text9  [10] = "Cancelled."
#endif

dll "<advapi32.dll>"
    integer proc RegCreateKeyEx(
        integer start,
        string mkeyname:cstrval,
        integer zero,
        string s1:cstrval,
        integer zero2,
        integer access,
        integer zero3,
        var integer Key,
        var integer status):"RegCreateKeyExA"
    integer proc RegSetValueEx(
        integer Key,
        string name:cstrval,
        integer zero1,
        integer reg_sz,
        string content:cstrval,
        integer content_len):"RegSetValueExA"
    integer proc RegOpenKeyEx(
        integer start,
        string mkeyname:cstrval,
        integer zero,
        integer access,
        var integer Key):"RegOpenKeyExA"
    integer proc RegDeleteKey(
        integer Key,
        string subkey:cstrval):"RegDeleteKeyA"
end

constant
    ERROR_SUCCESS = 0,
    HKEY_CLASSES_ROOT = 0x80000000,
    HKEY_CURRENT_USER = 0x80000001,
    HKEY_LOCAL_MACHINE = 0x80000002,
    HKEY_USERS = 0x80000003,
    HKEY_PERFORMANCE_DATA = 0x80000004,
    HKEY_CURRENT_CONFIG = 0x80000005,
    HKEY_DYN_DATA = 0x80000006,

    STANDARD_RIGHTS_ALL = 0x001F0000,
    SYNCHRONIZE = 0x00100000,
    KEY_QUERY_VALUE = 0x0001,
    KEY_SET_VALUE = 0x0002,
    KEY_CREATE_SUB_KEY = 0x0004,
    KEY_ENUMERATE_SUB_KEYS = 0x0008,
    KEY_NOTIFY = 0x0010,
    KEY_CREATE_LINK = 0x0020,

    KEY_ALL_ACCESS = ((STANDARD_RIGHTS_ALL|KEY_QUERY_VALUE|
        KEY_SET_VALUE|KEY_CREATE_SUB_KEY|KEY_ENUMERATE_SUB_KEYS|
        KEY_NOTIFY|KEY_CREATE_LINK)&(~SYNCHRONIZE)),

    REG_SZ = 1   // Unicode nul terminated string

integer proc delreg(integer start, string mkeyname, string subkey)
    integer Key = 0
    if RegOpenKeyEx(start, mkeyname, 0, KEY_ALL_ACCESS, Key) <>
            ERROR_SUCCESS
        return (FALSE)
    endif
    if RegDeleteKey(Key, subkey) <> ERROR_SUCCESS
        return (FALSE)
    endif
    return (TRUE)
end

/****************************************************************
 put keys into Registry
 start   : one of the predefined key (e.g. HKEY_CLASSES_ROOT)
 mkeyname: path to the key to create
 name    : subkey to create
 content : it's content
 ****************************************************************/
integer proc putreg(
        integer start,
        string mkeyname,
        string name,
        string content)
    integer hkey, status, rc

    rc = RegCreateKeyEx(
        start,
        mkeyname,
        0,
        "",
        0,
        KEY_ALL_ACCESS,
        0,
        hkey,
        status)
    if rc == ERROR_SUCCESS
        rc = RegSetValueEx(
            hkey,
            name,
            0,
            REG_SZ,
            content,
            Length(content)+1)
    endif
    return (rc == ERROR_SUCCESS)
end

proc add_edit_with_tse()
   Message(text1)
   PutReg(
      HKEY_CLASSES_ROOT,
      "*\Shell\TSE",
      "",
      text2)
   PutReg(
      HKEY_CLASSES_ROOT,
      "*\Shell\TSE\command",
      "",
      LoadDir(1) + ' "%1"')
   Delay(36)
   Message(text3)
end

proc del_edit_with_tse()
   Message(text4)
   DelReg(HKEY_CLASSES_ROOT, "*\Shell\TSE", "command")
   DelReg(HKEY_CLASSES_ROOT, "*\Shell", "TSE")
   Delay(36)
   Message(text5)
end

proc ask_add_edit_with_tse()
   if Query(Beep)
      Alarm()
   endif
   if MsgBox(text6,
             text7,
             _YES_NO_) == 1
      add_edit_with_tse()
      Delay(36)
      Message(text8)
   else
      Message(text9)
   endif
end

#ifdef DUTCH
   menu edit_with_tse_menu()
      title = '"Bewerken met TSE" keuze in het Windows rechtermuismenu'
      history
      "   &Toevoegen"  ,,,'Voeg een "Bewerken met TSE" keuze toe aan het Windows rechtermuismenu.'
      "   &Verwijderen",,,'Verwijder de "Bewerken met TSE" keuze uit het Windows rechtermuismenu.'
      "   &Annuleren"  ,,,'Annuleer het wijzigen van deze menukeuze.'
   end
#else
   menu edit_with_tse_menu()
      title = '"Edit with TSE" option in Windows Right-Mouse menu'
      history
      "   &Add"   ,,,'Add an "Edit with TSE" option to the Windows Right-Mouse menu.'
      "   &Delete",,,'Delete the "Edit with TSE" option from the Windows Right-Mouse menu.'
      "   &Cancel",,,'Cancel changing this option.'
   end
#endif

proc Main()
   UpdateDisplay(_ALL_WINDOWS_REFRESH_)
   Set(X1,10)
   Set(Y1,10)
   edit_with_tse_menu()
   if MenuOption() == 1
      ask_add_edit_with_tse()
   elseif MenuOption() == 2
      del_edit_with_tse()
   else
      Message(text9)
   endif
   UpdateDisplay(_ALL_WINDOWS_REFRESH_)
   Delay(36)
   PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end

